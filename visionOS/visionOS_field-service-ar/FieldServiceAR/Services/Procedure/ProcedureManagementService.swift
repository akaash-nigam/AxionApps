//
//  ProcedureManagementService.swift
//  FieldServiceAR
//
//  Procedure management service
//

import Foundation
import RealityKit

protocol ProcedureManagementService {
    func loadProcedure(for equipment: Equipment, issue: String) async throws -> RepairProcedure
    func overlayStep(_ step: ProcedureStep, on anchor: AnchorEntity) async
    func completeStep(_ stepId: UUID, evidence: [MediaEvidence]) async throws
}

actor ProcedureManagementServiceImpl: ProcedureManagementService {
    private let repository: ProcedureRepository

    init(repository: ProcedureRepository) {
        self.repository = repository
    }

    func loadProcedure(for equipment: Equipment, issue: String) async throws -> RepairProcedure {
        // TODO: Load procedure for equipment and issue
        let procedures = try await repository.fetchForEquipment(equipment.id)
        guard let procedure = procedures.first else {
            throw ProcedureError.notFound
        }
        return procedure
    }

    func overlayStep(_ step: ProcedureStep, on anchor: AnchorEntity) async {
        // TODO: Create and position AR overlay for step
    }

    func completeStep(_ stepId: UUID, evidence: [MediaEvidence]) async throws {
        // TODO: Mark step as complete and save evidence
    }
}

enum ProcedureError: Error {
    case notFound
    case invalidStep
}
