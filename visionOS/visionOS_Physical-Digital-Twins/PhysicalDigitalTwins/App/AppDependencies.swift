//
//  AppDependencies.swift
//  PhysicalDigitalTwins
//
//  Dependency injection container
//

import Foundation

@MainActor
class AppDependencies {
    // Core services
    lazy var persistenceController: PersistenceController = {
        PersistenceController.shared
    }()

    lazy var storageService: StorageService = {
        CoreDataStorageService(persistenceController: persistenceController)
    }()

    lazy var visionService: VisionService = {
        VisionServiceImpl()
    }()

    lazy var apiService: ProductAPIService = {
        ProductAPIAggregator(
            googleBooksAPI: GoogleBooksAPI(),
            upcDatabaseAPI: UPCDatabaseAPI()
        )
    }()

    lazy var twinFactory: TwinFactory = {
        TwinFactory(apiService: apiService)
    }()

    lazy var photoService: PhotoService = {
        FileSystemPhotoService()
    }()
}
