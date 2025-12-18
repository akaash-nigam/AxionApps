//
//  EquipmentRepository.swift
//  FieldServiceAR
//
//  Repository for Equipment data access
//

import Foundation
import SwiftData

@ModelActor
actor EquipmentRepository {
    func fetchAll() throws -> [Equipment] {
        let descriptor = FetchDescriptor<Equipment>(
            sortBy: [SortDescriptor(\.manufacturer), SortDescriptor(\.modelNumber)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> Equipment? {
        let predicate = #Predicate<Equipment> { equipment in
            equipment.id == id
        }

        let descriptor = FetchDescriptor<Equipment>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func fetchByCategory(_ category: EquipmentCategory) throws -> [Equipment] {
        let predicate = #Predicate<Equipment> { equipment in
            equipment.category == category
        }

        let descriptor = FetchDescriptor<Equipment>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.manufacturer)]
        )

        return try modelContext.fetch(descriptor)
    }

    func search(query: String) throws -> [Equipment] {
        let lowercaseQuery = query.lowercased()
        let predicate = #Predicate<Equipment> { equipment in
            equipment.manufacturer.lowercased().contains(lowercaseQuery) ||
            equipment.modelNumber.lowercased().contains(lowercaseQuery) ||
            equipment.name.lowercased().contains(lowercaseQuery)
        }

        let descriptor = FetchDescriptor<Equipment>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    func save(_ equipment: Equipment) throws {
        modelContext.insert(equipment)
        try modelContext.save()
    }

    func update(_ equipment: Equipment) throws {
        equipment.update()
        try modelContext.save()
    }

    func delete(_ equipment: Equipment) throws {
        modelContext.delete(equipment)
        try modelContext.save()
    }
}
