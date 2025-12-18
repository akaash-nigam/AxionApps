//
//  SyncCoordinator.swift
//  Reality Annotation Platform
//
//  Coordinates synchronization between local SwiftData and CloudKit
//

import Foundation
import CloudKit

// MARK: - Sync Status

enum SyncStatus: Equatable {
    case idle
    case syncing
    case error(String)
    case offline

    static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.offline, .offline):
            return true
        case (.error(let lhs), .error(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

// MARK: - Sync Coordinator Protocol

protocol SyncCoordinator {
    /// Start automatic background sync
    func startSync() async

    /// Stop background sync
    func stopSync()

    /// Force immediate sync
    func syncNow() async throws

    /// Sync status
    var syncStatus: SyncStatus { get }

    /// Last successful sync time
    var lastSyncTime: Date? { get }
}

// MARK: - Default Sync Coordinator

@MainActor
@Observable
class DefaultSyncCoordinator: SyncCoordinator {
    var syncStatus: SyncStatus = .idle
    var lastSyncTime: Date?

    private let cloudKitService: CloudKitService
    private let annotationService: AnnotationService
    private let layerService: LayerService

    private var syncTask: Task<Void, Never>?
    private let syncInterval: TimeInterval = 60 // Sync every 60 seconds
    private var isEnabled: Bool = true

    init(
        cloudKitService: CloudKitService,
        annotationService: AnnotationService,
        layerService: LayerService
    ) {
        self.cloudKitService = cloudKitService
        self.annotationService = annotationService
        self.layerService = layerService
    }

    // MARK: - Public Methods

    func startSync() async {
        print("🔄 Starting automatic sync...")

        // Check CloudKit availability
        do {
            let status = try await cloudKitService.checkAccountStatus()
            guard status == .available else {
                print("⚠️ CloudKit not available: \(status)")
                syncStatus = .offline
                return
            }
        } catch {
            print("⚠️ Failed to check CloudKit status: \(error)")
            syncStatus = .offline
            return
        }

        // Start background sync loop
        syncTask?.cancel()
        syncTask = Task {
            while !Task.isCancelled && isEnabled {
                do {
                    try await syncNow()
                    try await Task.sleep(for: .seconds(syncInterval))
                } catch is CancellationError {
                    break
                } catch {
                    syncStatus = .error(error.localizedDescription)
                    print("⚠️ Sync error: \(error)")
                    // Back off on error
                    try? await Task.sleep(for: .seconds(syncInterval * 2))
                }
            }
        }
    }

    func stopSync() {
        print("⏹️ Stopping automatic sync...")
        syncTask?.cancel()
        syncTask = nil
        if syncStatus == .syncing {
            syncStatus = .idle
        }
    }

    func syncNow() async throws {
        guard !Task.isCancelled else { return }

        print("🔄 Starting sync...")
        syncStatus = .syncing

        // 1. Upload local changes
        try await uploadPendingAnnotations()
        try await uploadPendingLayers()

        // 2. Download remote changes
        try await downloadRemoteAnnotations()
        try await downloadRemoteLayers()

        // 3. Update timestamp
        lastSyncTime = Date()
        syncStatus = .idle

        print("✅ Sync completed successfully")
    }

    // MARK: - Upload

    private func uploadPendingAnnotations() async throws {
        print("📤 Uploading pending annotations...")

        // Fetch all annotations pending sync
        let allAnnotations = try await annotationService.fetchAnnotations()
        let pendingAnnotations = allAnnotations.filter { $0.isPendingSync && !$0.isDeleted }

        guard !pendingAnnotations.isEmpty else {
            print("   No pending annotations to upload")
            return
        }

        print("   Found \(pendingAnnotations.count) pending annotations")

        for annotation in pendingAnnotations {
            do {
                // Upload to CloudKit
                _ = try await cloudKitService.upload(annotation)

                // Mark as synced
                var syncedAnnotation = annotation
                syncedAnnotation.isPendingSync = false
                syncedAnnotation.lastSyncedAt = Date()
                try await annotationService.updateAnnotation(syncedAnnotation)
            } catch {
                print("⚠️ Failed to upload annotation \(annotation.id): \(error)")
                // Continue with other annotations
            }
        }
    }

    private func uploadPendingLayers() async throws {
        print("📤 Uploading pending layers...")

        // Fetch all layers pending sync
        let allLayers = try await layerService.fetchLayers()
        let pendingLayers = allLayers.filter { $0.isPendingSync && !$0.isDeleted }

        guard !pendingLayers.isEmpty else {
            print("   No pending layers to upload")
            return
        }

        print("   Found \(pendingLayers.count) pending layers")

        for layer in pendingLayers {
            do {
                // Upload to CloudKit
                _ = try await cloudKitService.upload(layer)

                // Mark as synced
                var syncedLayer = layer
                syncedLayer.isPendingSync = false
                syncedLayer.lastSyncedAt = Date()
                try await layerService.updateLayer(syncedLayer)
            } catch {
                print("⚠️ Failed to upload layer \(layer.id): \(error)")
                // Continue with other layers
            }
        }
    }

    // MARK: - Download

    private func downloadRemoteAnnotations() async throws {
        print("📥 Downloading remote annotations...")

        // Fetch changes from CloudKit
        let changes = try await cloudKitService.fetchChanges(
            recordType: Annotation.recordType,
            since: lastSyncTime
        )

        guard !changes.isEmpty else {
            print("   No remote annotation changes")
            return
        }

        print("   Found \(changes.count) remote changes")

        for change in changes {
            do {
                switch change {
                case .created(let record), .updated(let record):
                    try await handleAnnotationUpdate(record)
                case .deleted(let recordID):
                    try await handleAnnotationDelete(recordID)
                }
            } catch {
                print("⚠️ Failed to process change: \(error)")
                // Continue with other changes
            }
        }
    }

    private func downloadRemoteLayers() async throws {
        print("📥 Downloading remote layers...")

        // Fetch changes from CloudKit
        let changes = try await cloudKitService.fetchChanges(
            recordType: Layer.recordType,
            since: lastSyncTime
        )

        guard !changes.isEmpty else {
            print("   No remote layer changes")
            return
        }

        print("   Found \(changes.count) remote changes")

        for change in changes {
            do {
                switch change {
                case .created(let record), .updated(let record):
                    try await handleLayerUpdate(record)
                case .deleted(let recordID):
                    try await handleLayerDelete(recordID)
                }
            } catch {
                print("⚠️ Failed to process change: \(error)")
                // Continue with other changes
            }
        }
    }

    // MARK: - Conflict Resolution

    private func handleAnnotationUpdate(_ record: CKRecord) async throws {
        let recordName = record.recordID.recordName
        guard let annotationID = UUID(uuidString: recordName) else {
            throw SyncableError.conversionFailed("Invalid UUID: \(recordName)")
        }

        // Check if annotation exists locally
        let allAnnotations = try await annotationService.fetchAnnotations()
        if let existingAnnotation = allAnnotations.first(where: { $0.id == annotationID }) {
            // Conflict resolution: Last-write-wins
            let remoteModificationDate = record.modificationDate ?? Date.distantPast
            if existingAnnotation.updatedAt > remoteModificationDate {
                print("   Local is newer - keeping local version for \(annotationID)")
                // Don't update - local wins
            } else {
                print("   Remote is newer - updating local version for \(annotationID)")
                // Update from remote
                var updatedAnnotation = existingAnnotation
                try updatedAnnotation.updateFrom(record: record)
                updatedAnnotation.isPendingSync = false
                updatedAnnotation.lastSyncedAt = Date()
                try await annotationService.updateAnnotation(updatedAnnotation)
            }
        } else {
            // New annotation from remote
            print("   Creating new annotation from remote: \(annotationID)")
            var newAnnotation = Annotation(
                type: .text,
                title: nil,
                contentText: "",
                position: SIMD3(0, 0, 0),
                layerID: UUID(),
                ownerID: ""
            )
            try newAnnotation.updateFrom(record: record)
            newAnnotation.isPendingSync = false
            newAnnotation.lastSyncedAt = Date()

            // Create via service
            // Note: We can't use createAnnotation because it validates - just save directly
            // TODO: Add a way to insert without validation
            print("   ⚠️ Skipping remote annotation creation - need insert method")
        }
    }

    private func handleLayerUpdate(_ record: CKRecord) async throws {
        let recordName = record.recordID.recordName
        guard let layerID = UUID(uuidString: recordName) else {
            throw SyncableError.conversionFailed("Invalid UUID: \(recordName)")
        }

        // Check if layer exists locally
        let allLayers = try await layerService.fetchLayers()
        if let existingLayer = allLayers.first(where: { $0.id == layerID }) {
            // Conflict resolution: Last-write-wins
            let remoteModificationDate = record.modificationDate ?? Date.distantPast
            if existingLayer.updatedAt > remoteModificationDate {
                print("   Local is newer - keeping local version for \(layerID)")
            } else {
                print("   Remote is newer - updating local version for \(layerID)")
                var updatedLayer = existingLayer
                try updatedLayer.updateFrom(record: record)
                updatedLayer.isPendingSync = false
                updatedLayer.lastSyncedAt = Date()
                try await layerService.updateLayer(updatedLayer)
            }
        } else {
            print("   ⚠️ Skipping remote layer creation - need insert method")
        }
    }

    private func handleAnnotationDelete(_ recordID: CKRecord.ID) async throws {
        let recordName = recordID.recordName
        guard let annotationID = UUID(uuidString: recordName) else {
            throw SyncableError.conversionFailed("Invalid UUID: \(recordName)")
        }

        print("   Deleting annotation: \(annotationID)")
        try await annotationService.deleteAnnotation(id: annotationID)
    }

    private func handleLayerDelete(_ recordID: CKRecord.ID) async throws {
        let recordName = recordID.recordName
        guard let layerID = UUID(uuidString: recordName) else {
            throw SyncableError.conversionFailed("Invalid UUID: \(recordName)")
        }

        print("   Deleting layer: \(layerID)")
        try await layerService.deleteLayer(id: layerID)
    }
}
