//
//  SyncService.swift
//  FieldServiceAR
//
//  Data synchronization service
//

import Foundation
import SwiftData

protocol SyncService {
    func syncJobs() async throws
    func uploadCompletedJob(_ job: ServiceJob) async throws
    func downloadProcedures(for equipment: [Equipment]) async throws
    func syncOfflineChanges() async throws
}

actor SyncServiceImpl: SyncService {
    private let apiClient: FieldServiceAPIClient
    private let modelContainer: ModelContainer

    init(apiClient: FieldServiceAPIClient, modelContainer: ModelContainer) {
        self.apiClient = apiClient
        self.modelContainer = modelContainer
    }

    func syncJobs() async throws {
        // TODO: Sync jobs from API to local database
    }

    func uploadCompletedJob(_ job: ServiceJob) async throws {
        // TODO: Upload completed job data to API
    }

    func downloadProcedures(for equipment: [Equipment]) async throws {
        // TODO: Download procedures for equipment
    }

    func syncOfflineChanges() async throws {
        // TODO: Upload any offline changes
    }
}
