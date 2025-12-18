//
//  JobRepository.swift
//  FieldServiceAR
//
//  Repository for ServiceJob data access
//

import Foundation
import SwiftData

@ModelActor
actor JobRepository {
    func fetchAll() throws -> [ServiceJob] {
        let descriptor = FetchDescriptor<ServiceJob>(
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchToday() throws -> [ServiceJob] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<ServiceJob> { job in
            job.scheduledDate >= start && job.scheduledDate < end
        }

        let descriptor = FetchDescriptor<ServiceJob>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledDate)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchUpcoming() throws -> [ServiceJob] {
        let now = Date()
        let predicate = #Predicate<ServiceJob> { job in
            job.scheduledDate > now && job.status == .scheduled
        }

        let descriptor = FetchDescriptor<ServiceJob>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledDate)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> ServiceJob? {
        let predicate = #Predicate<ServiceJob> { job in
            job.id == id
        }

        let descriptor = FetchDescriptor<ServiceJob>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func save(_ job: ServiceJob) throws {
        modelContext.insert(job)
        try modelContext.save()
    }

    func update(_ job: ServiceJob) throws {
        job.updatedAt = Date()
        try modelContext.save()
    }

    func delete(_ job: ServiceJob) throws {
        modelContext.delete(job)
        try modelContext.save()
    }

    func search(query: String) throws -> [ServiceJob] {
        let lowercaseQuery = query.lowercased()
        let predicate = #Predicate<ServiceJob> { job in
            job.workOrderNumber.lowercased().contains(lowercaseQuery) ||
            job.title.lowercased().contains(lowercaseQuery) ||
            job.customerName.lowercased().contains(lowercaseQuery)
        }

        let descriptor = FetchDescriptor<ServiceJob>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
}
