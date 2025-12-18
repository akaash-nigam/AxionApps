//
//  ProcedureRepository.swift
//  FieldServiceAR
//
//  Repository for RepairProcedure data access
//

import Foundation
import SwiftData

@ModelActor
actor ProcedureRepository {
    func fetchAll() throws -> [RepairProcedure] {
        let descriptor = FetchDescriptor<RepairProcedure>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> RepairProcedure? {
        let predicate = #Predicate<RepairProcedure> { procedure in
            procedure.id == id
        }

        let descriptor = FetchDescriptor<RepairProcedure>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func fetchForEquipment(_ equipmentId: UUID) throws -> [RepairProcedure] {
        let predicate = #Predicate<RepairProcedure> { procedure in
            procedure.equipmentId == equipmentId
        }

        let descriptor = FetchDescriptor<RepairProcedure>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title)]
        )

        return try modelContext.fetch(descriptor)
    }

    func save(_ procedure: RepairProcedure) throws {
        modelContext.insert(procedure)
        try modelContext.save()
    }

    func update(_ procedure: RepairProcedure) throws {
        procedure.updatedAt = Date()
        try modelContext.save()
    }

    func delete(_ procedure: RepairProcedure) throws {
        modelContext.delete(procedure)
        try modelContext.save()
    }
}
