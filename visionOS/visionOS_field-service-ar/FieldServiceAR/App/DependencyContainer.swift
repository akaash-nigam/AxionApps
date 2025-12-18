//
//  DependencyContainer.swift
//  FieldServiceAR
//
//  Dependency injection container
//

import Foundation
import SwiftData

@MainActor
class DependencyContainer {
    // MARK: - Singletons

    lazy var appState = AppState()

    lazy var modelContainer: ModelContainer = {
        let schema = Schema([
            Equipment.self,
            ServiceJob.self,
            RepairProcedure.self,
            ProcedureStep.self,
            Component.self,
            Customer.self,
            Technician.self,
            CollaborationSession.self,
            DiagnosticResult.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Repositories

    lazy var jobRepository: JobRepository = {
        JobRepository(modelContainer: modelContainer)
    }()

    lazy var equipmentRepository: EquipmentRepository = {
        EquipmentRepository(modelContainer: modelContainer)
    }()

    lazy var procedureRepository: ProcedureRepository = {
        ProcedureRepository(modelContainer: modelContainer)
    }()

    // MARK: - Services

    lazy var apiClient: FieldServiceAPIClient = {
        FieldServiceAPIClientImpl(
            baseURL: Configuration.apiBaseURL,
            authProvider: authProvider
        )
    }()

    lazy var authProvider: AuthenticationProvider = {
        AuthenticationProviderImpl()
    }()

    lazy var recognitionService: EquipmentRecognitionService = {
        EquipmentRecognitionServiceImpl(
            repository: equipmentRepository
        )
    }()

    lazy var procedureService: ProcedureManagementService = {
        ProcedureManagementServiceImpl(
            repository: procedureRepository
        )
    }()

    lazy var collaborationService: CollaborationService = {
        CollaborationServiceImpl()
    }()

    lazy var diagnosticService: DiagnosticService = {
        DiagnosticServiceImpl(apiClient: apiClient)
    }()

    lazy var syncService: SyncService = {
        SyncServiceImpl(
            apiClient: apiClient,
            modelContainer: modelContainer
        )
    }()
}

// Configuration
struct Configuration {
    static var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "https://dev-api.fieldservice.com")!
        #else
        return URL(string: "https://api.fieldservice.com")!
        #endif
    }

    static var environment: String {
        #if DEBUG
        return "development"
        #else
        return "production"
        #endif
    }
}
