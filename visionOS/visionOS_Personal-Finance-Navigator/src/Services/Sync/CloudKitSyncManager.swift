// CloudKitSyncManager.swift
// Personal Finance Navigator
// Manages CloudKit synchronization for Core Data

import Foundation
import CoreData
import CloudKit
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "cloudkit")

/// Manages CloudKit synchronization and conflict resolution
@MainActor
class CloudKitSyncManager: ObservableObject {
    // MARK: - Published State

    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var syncError: String?
    @Published private(set) var isCloudKitAvailable = false

    // MARK: - Dependencies

    private let container: NSPersistentCloudKitContainer
    private let cloudKitContainer: CKContainer

    // MARK: - Init

    init(container: NSPersistentCloudKitContainer) {
        self.container = container
        self.cloudKitContainer = CKContainer(identifier: "iCloud.com.pfn.PersonalFinanceNavigator")

        Task {
            await checkCloudKitAvailability()
            setupNotifications()
        }
    }

    // MARK: - CloudKit Availability

    func checkCloudKitAvailability() async {
        do {
            let status = try await cloudKitContainer.accountStatus()
            isCloudKitAvailable = (status == .available)

            if !isCloudKitAvailable {
                logger.warning("CloudKit not available: \(status.rawValue)")
                syncError = cloudKitErrorMessage(for: status)
            } else {
                logger.info("CloudKit is available")
            }
        } catch {
            logger.error("Failed to check CloudKit status: \(error.localizedDescription)")
            isCloudKitAvailable = false
            syncError = "Unable to check iCloud status"
        }
    }

    // MARK: - Sync Management

    /// Manually triggers a sync
    func sync() async {
        guard isCloudKitAvailable else {
            syncError = "iCloud is not available"
            return
        }

        guard !isSyncing else {
            logger.debug("Sync already in progress")
            return
        }

        isSyncing = true
        syncError = nil

        do {
            // NSPersistentCloudKitContainer handles sync automatically
            // We just need to save the context to trigger sync
            try await container.viewContext.perform {
                if self.container.viewContext.hasChanges {
                    try self.container.viewContext.save()
                }
            }

            lastSyncDate = Date()
            logger.info("CloudKit sync completed")
        } catch {
            logger.error("CloudKit sync failed: \(error.localizedDescription)")
            syncError = "Sync failed: \(error.localizedDescription)"
        }

        isSyncing = false
    }

    // MARK: - Notifications

    private func setupNotifications() {
        // Listen for remote change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange),
            name: NSPersistentCloudKitContainer.eventChangedNotification,
            object: container
        )

        // Listen for store import notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStoreImport),
            name: NSPersistentStore.remoteChangeNotification,
            object: nil
        )
    }

    @objc private func handleRemoteChange(_ notification: Notification) {
        Task { @MainActor in
            logger.debug("Remote change detected")
            // The container handles the actual sync
            // We just update our UI state
            lastSyncDate = Date()
        }
    }

    @objc private func handleStoreImport(_ notification: Notification) {
        Task { @MainActor in
            logger.debug("Store import detected")
            lastSyncDate = Date()
        }
    }

    // MARK: - Conflict Resolution

    /// NSPersistentCloudKitContainer handles conflicts automatically using merge policies
    /// We configure the merge policy in the container setup
    func configureMergePolicy() {
        // Use "server wins" for most conflicts
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // For more complex scenarios, we could implement custom conflict resolution:
        // container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }

    // MARK: - Error Handling

    private func cloudKitErrorMessage(for status: CKAccountStatus) -> String {
        switch status {
        case .couldNotDetermine:
            return "Unable to determine iCloud status"
        case .noAccount:
            return "Please sign in to iCloud in Settings"
        case .restricted:
            return "iCloud access is restricted"
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable"
        case .available:
            return ""
        @unknown default:
            return "Unknown iCloud status"
        }
    }

    // MARK: - Export/Import

    /// Exports all data (for backup or migration)
    func exportData() async throws -> Data {
        // This would export the entire Core Data store
        // Implementation depends on specific requirements
        logger.info("Exporting data...")
        throw NSError(domain: "CloudKitSync", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented"])
    }

    /// Imports data from backup
    func importData(_ data: Data) async throws {
        logger.info("Importing data...")
        throw NSError(domain: "CloudKitSync", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented"])
    }
}

// MARK: - Sync Status View

import SwiftUI

struct SyncStatusView: View {
    @ObservedObject var syncManager: CloudKitSyncManager

    var body: some View {
        HStack(spacing: 8) {
            if syncManager.isSyncing {
                ProgressView()
                    .scaleEffect(0.7)
                Text("Syncing...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !syncManager.isCloudKitAvailable {
                Image(systemName: "icloud.slash")
                    .foregroundColor(.orange)
                Text("iCloud Unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let lastSync = syncManager.lastSyncDate {
                Image(systemName: "icloud")
                    .foregroundColor(.blue)
                Text("Synced \(timeAgo(lastSync))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "icloud")
                    .foregroundColor(.gray)
                Text("Not synced")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if syncManager.syncError != nil {
                Button(action: {
                    Task {
                        await syncManager.sync()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial)
        .clipShape(Capsule())
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m ago"
        } else if seconds < 86400 {
            return "\(Int(seconds / 3600))h ago"
        } else {
            return "\(Int(seconds / 86400))d ago"
        }
    }
}

// MARK: - Configuration

extension NSPersistentCloudKitContainer {
    /// Configures CloudKit sync options
    static func configured(name: String) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: name)

        // Configure CloudKit options
        if let description = container.persistentStoreDescriptions.first {
            // Enable remote change notifications
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            // Enable history tracking (required for CloudKit)
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

            // Configure CloudKit container options
            let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.pfn.PersonalFinanceNavigator")
            description.cloudKitContainerOptions = cloudKitOptions
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                logger.error("Core Data failed to load: \(error.localizedDescription)")
                fatalError("Core Data load error: \(error)")
            }
        }

        // Configure merge policy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }
}
