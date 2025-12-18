//
//  CaseRepository.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

/// Repository for legal case data access
@MainActor
class CaseRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    func insert(_ legalCase: LegalCase) throws {
        modelContext.insert(legalCase)
        try modelContext.save()
    }

    func fetch(id: UUID) throws -> LegalCase? {
        let descriptor = FetchDescriptor<LegalCase>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchAll() throws -> [LegalCase] {
        let descriptor = FetchDescriptor<LegalCase>(
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() throws -> [LegalCase] {
        let descriptor = FetchDescriptor<LegalCase>(
            predicate: #Predicate { $0.status == .active },
            sortBy: [SortDescriptor(\.lastModified, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func update(_ legalCase: LegalCase) throws {
        legalCase.lastModified = Date()
        try modelContext.save()
    }

    func delete(_ legalCase: LegalCase) throws {
        modelContext.delete(legalCase)
        try modelContext.save()
    }

    // MARK: - Search

    func search(query: String) throws -> [LegalCase] {
        let descriptor = FetchDescriptor<LegalCase>(
            predicate: #Predicate { legalCase in
                legalCase.title.localizedStandardContains(query) ||
                legalCase.caseNumber.localizedStandardContains(query) ||
                legalCase.caseDescription.localizedStandardContains(query)
            }
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Statistics

    func updateStatistics(for caseId: UUID) throws {
        guard let legalCase = try fetch(id: caseId) else { return }

        // Count documents
        legalCase.documentCount = legalCase.documents.count

        // Count relevant documents
        legalCase.relevantDocumentCount = legalCase.documents.filter { $0.isRelevant }.count

        // Count privileged documents
        legalCase.privilegedDocumentCount = legalCase.documents.filter { $0.isPrivileged }.count

        // Calculate review progress
        let reviewedCount = legalCase.documents.filter { $0.isReviewed }.count
        legalCase.reviewProgress = legalCase.documentCount > 0
            ? Double(reviewedCount) / Double(legalCase.documentCount)
            : 0.0

        try modelContext.save()
    }
}
