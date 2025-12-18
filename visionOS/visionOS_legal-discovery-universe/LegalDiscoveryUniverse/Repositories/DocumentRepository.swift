//
//  DocumentRepository.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

/// Repository for document data access with caching
@MainActor
class DocumentRepository {
    private let modelContext: ModelContext
    private let cacheManager: CacheManager

    init(modelContext: ModelContext, cacheManager: CacheManager = .shared) {
        self.modelContext = modelContext
        self.cacheManager = cacheManager
    }

    // MARK: - CRUD Operations

    func insert(_ document: Document) throws {
        modelContext.insert(document)
        try modelContext.save()
        Task {
            await cacheManager.cache(document)
        }
    }

    func insertBatch(_ documents: [Document]) throws {
        for document in documents {
            modelContext.insert(document)
        }
        try modelContext.save()

        Task {
            for document in documents {
                await cacheManager.cache(document)
            }
        }
    }

    func fetch(id: UUID) async throws -> Document? {
        // Try cache first
        if let cached = await cacheManager.getDocument(id: id) {
            return cached
        }

        // Fetch from database
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate { $0.id == id }
        )

        let documents = try modelContext.fetch(descriptor)
        if let document = documents.first {
            await cacheManager.cache(document)
        }
        return documents.first
    }

    func fetchAll(for caseId: UUID) throws -> [Document] {
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate { $0.legalCase?.id == caseId },
            sortBy: [SortDescriptor(\.relevanceScore, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func update(_ document: Document) throws {
        document.modifiedDate = Date()
        try modelContext.save()

        Task {
            await cacheManager.invalidate(documentId: document.id)
            await cacheManager.cache(document)
        }
    }

    func delete(_ document: Document) throws {
        modelContext.delete(document)
        try modelContext.save()

        Task {
            await cacheManager.invalidate(documentId: document.id)
        }
    }

    // MARK: - Search Operations

    func search(query: String, in caseId: UUID? = nil) throws -> [Document] {
        var predicates: [Predicate<Document>] = []

        // Text search
        predicates.append(#Predicate { document in
            document.fileName.localizedStandardContains(query) ||
            document.extractedText.localizedStandardContains(query)
        })

        // Case filter
        if let caseId {
            predicates.append(#Predicate { $0.legalCase?.id == caseId })
        }

        let combinedPredicate = predicates.reduce(into: #Predicate<Document> { _ in true }) { result, predicate in
            result = #Predicate { document in
                result.evaluate(document) && predicate.evaluate(document)
            }
        }

        let descriptor = FetchDescriptor<Document>(
            predicate: combinedPredicate,
            sortBy: [SortDescriptor(\.relevanceScore, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchRelevant(threshold: Double = 0.7, caseId: UUID? = nil) throws -> [Document] {
        var predicate = #Predicate<Document> { $0.relevanceScore >= threshold }

        if let caseId {
            predicate = #Predicate {
                $0.relevanceScore >= threshold && $0.legalCase?.id == caseId
            }
        }

        let descriptor = FetchDescriptor<Document>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.relevanceScore, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchPrivileged(caseId: UUID? = nil) throws -> [Document] {
        var predicate = #Predicate<Document> { $0.isPrivileged == true }

        if let caseId {
            predicate = #Predicate {
                $0.isPrivileged == true && $0.legalCase?.id == caseId
            }
        }

        let descriptor = FetchDescriptor<Document>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    func fetchByFileType(_ fileType: FileType, caseId: UUID? = nil) throws -> [Document] {
        var predicate = #Predicate<Document> { $0.fileType == fileType }

        if let caseId {
            predicate = #Predicate {
                $0.fileType == fileType && $0.legalCase?.id == caseId
            }
        }

        let descriptor = FetchDescriptor<Document>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Statistics

    func count(for caseId: UUID) throws -> Int {
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate { $0.legalCase?.id == caseId }
        )
        return try modelContext.fetchCount(descriptor)
    }

    func relevantCount(for caseId: UUID, threshold: Double = 0.7) throws -> Int {
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate {
                $0.legalCase?.id == caseId && $0.relevanceScore >= threshold
            }
        )
        return try modelContext.fetchCount(descriptor)
    }

    func privilegedCount(for caseId: UUID) throws -> Int {
        let descriptor = FetchDescriptor<Document>(
            predicate: #Predicate {
                $0.legalCase?.id == caseId && $0.isPrivileged == true
            }
        )
        return try modelContext.fetchCount(descriptor)
    }
}

// MARK: - Cache Manager

actor CacheManager {
    static let shared = CacheManager()

    private var documentCache: [UUID: Document] = [:]
    private let maxCacheSize = 100

    func cache(_ document: Document) {
        // Limit cache size
        if documentCache.count >= maxCacheSize {
            // Remove oldest entry (simplified - could use LRU)
            if let firstKey = documentCache.keys.first {
                documentCache.removeValue(forKey: firstKey)
            }
        }
        documentCache[document.id] = document
    }

    func getDocument(id: UUID) -> Document? {
        return documentCache[id]
    }

    func invalidate(documentId: UUID) {
        documentCache.removeValue(forKey: documentId)
    }

    func clear() {
        documentCache.removeAll()
    }
}
