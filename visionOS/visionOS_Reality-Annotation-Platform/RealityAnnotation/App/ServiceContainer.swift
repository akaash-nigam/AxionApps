//
//  ServiceContainer.swift
//  Reality Annotation Platform
//
//  Dependency injection container
//

import Foundation
import SwiftData

@MainActor
class ServiceContainer {
    static let shared = ServiceContainer()

    // MARK: - Model Container

    let modelContainer: ModelContainer

    // MARK: - Data Sources

    private lazy var localDataSource: LocalDataSource = {
        SwiftDataSource(modelContainer: modelContainer)
    }()

    // MARK: - Repositories

    lazy var annotationRepository: AnnotationRepository = {
        DefaultAnnotationRepository(localDataSource: localDataSource)
    }()

    lazy var layerRepository: LayerRepository = {
        DefaultLayerRepository(localDataSource: localDataSource)
    }()

    // MARK: - Services

    lazy var annotationService: AnnotationService = {
        DefaultAnnotationService(
            repository: annotationRepository,
            currentUserID: getCurrentUserID()
        )
    }()

    lazy var layerService: LayerService = {
        DefaultLayerService(
            repository: layerRepository,
            annotationRepository: annotationRepository,
            currentUserID: getCurrentUserID()
        )
    }()

    // MARK: - CloudKit Sync

    lazy var cloudKitService: CloudKitService = {
        DefaultCloudKitService(scope: .private)
    }()

    lazy var syncCoordinator: SyncCoordinator = {
        DefaultSyncCoordinator(
            cloudKitService: cloudKitService,
            annotationService: annotationService,
            layerService: layerService
        )
    }()

    // MARK: - Initialization

    init(modelContainer: ModelContainer? = nil) {
        if let container = modelContainer {
            self.modelContainer = container
        } else {
            // Create default container
            do {
                let schema = Schema([
                    Annotation.self,
                    Layer.self,
                    User.self,
                    Comment.self,
                    ARWorldMapData.self
                ])

                let config = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )

                self.modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [config]
                )
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }

        print("🔧 ServiceContainer initialized")
    }

    // MARK: - Helpers

    private func getCurrentUserID() -> String {
        // TODO: Get from authentication service
        // For now, return hardcoded user ID
        return "current-user-\(UUID().uuidString.prefix(8))"
    }
}
