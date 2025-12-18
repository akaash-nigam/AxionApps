//
//  AppDependencies.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Dependency Injection Container
//

import Foundation
import CoreData

/// Central dependency injection container for the app
/// Provides singleton instances of services following the Service Locator pattern
class AppDependencies {

    // MARK: - Shared Instance

    static let shared = AppDependencies()

    // MARK: - Core Services

    /// Recognition service for appliance identification
    lazy var recognitionService: RecognitionServiceProtocol = {
        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "1" {
            return MockRecognitionService()
        }
        #endif
        return RecognitionService()
    }()

    /// Manual service for fetching appliance manuals
    lazy var manualService: ManualServiceProtocol = {
        #if DEBUG
        if ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "1" {
            return MockManualService()
        }
        #endif
        return ManualService(
            apiClient: apiClient,
            cacheManager: cacheManager
        )
    }()

    /// Maintenance service for scheduling and tracking maintenance
    lazy var maintenanceService: MaintenanceServiceProtocol = {
        return MaintenanceService(
            repository: maintenanceRepository,
            notificationManager: notificationManager
        )
    }()

    /// Inventory service for managing appliance inventory
    lazy var inventoryService: InventoryServiceProtocol = {
        return InventoryService(
            repository: inventoryRepository,
            recognitionService: recognitionService
        )
    }()

    // MARK: - Repositories

    lazy var inventoryRepository: InventoryRepositoryProtocol = {
        return CoreDataInventoryRepository(
            context: PersistenceController.shared.container.viewContext
        )
    }()

    lazy var maintenanceRepository: MaintenanceRepositoryProtocol = {
        return CoreDataMaintenanceRepository(
            context: PersistenceController.shared.container.viewContext
        )
    }()

    // MARK: - Infrastructure

    lazy var apiClient: APIClient = {
        return URLSessionAPIClient(baseURL: Configuration.apiBaseURL)
    }()

    lazy var cacheManager: CacheManager = {
        return TwoLevelCacheManager()
    }()

    lazy var notificationManager: NotificationManager = {
        return LocalNotificationManager()
    }()

    // MARK: - Private Init (Singleton)

    private init() {
        print("🔧 AppDependencies initialized")
    }
}
