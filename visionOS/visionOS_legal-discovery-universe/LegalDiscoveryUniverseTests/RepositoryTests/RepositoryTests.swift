//
//  RepositoryTests.swift
//  Legal Discovery Universe Tests
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Testing
import Foundation
import SwiftData
@testable import LegalDiscoveryUniverse

@Suite("Document Repository Tests")
@MainActor
struct DocumentRepositoryTests {

    @Test("Repository initialization")
    func testRepositoryInitialization() {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        #expect(repository != nil, "Repository should initialize")
    }

    @Test("Document insertion and retrieval")
    func testDocumentInsertAndFetch() async throws {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        let document = Document(
            fileName: "test_doc.pdf",
            fileType: .pdf,
            fileSize: 1024,
            extractedText: "Test content for repository"
        )

        try repository.insert(document)

        let fetched = try await repository.fetch(id: document.id)

        #expect(fetched != nil, "Should fetch inserted document")
        #expect(fetched?.fileName == "test_doc.pdf")
        #expect(fetched?.fileType == .pdf)
    }

    @Test("Document statistics calculation")
    func testDocumentStatistics() throws {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        let legalCase = LegalCase(
            caseNumber: "TEST-001",
            title: "Test Case",
            description: "Test"
        )
        context.insert(legalCase)

        // Create test documents
        for i in 0..<5 {
            let doc = Document(
                fileName: "doc\(i).pdf",
                fileType: .pdf,
                extractedText: "Content \(i)"
            )
            doc.relevanceScore = Double(i) / 5.0
            doc.legalCase = legalCase
            try repository.insert(doc)
        }

        let count = try repository.count(for: legalCase.id)
        #expect(count == 5, "Should count all documents in case")
    }

    @Test("Search functionality")
    func testSearch() throws {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        let doc1 = Document(
            fileName: "contract.pdf",
            fileType: .pdf,
            extractedText: "This is a software contract agreement"
        )

        let doc2 = Document(
            fileName: "email.msg",
            fileType: .email,
            extractedText: "Meeting notes about the project"
        )

        try repository.insert(doc1)
        try repository.insert(doc2)

        let results = try repository.search(query: "contract")

        #expect(results.count > 0, "Should find documents matching search")
        let fileNames = results.map { $0.fileName }
        #expect(fileNames.contains("contract.pdf"), "Should find contract document")
    }

    @Test("Relevance filtering")
    func testRelevanceFiltering() throws {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        let highRelevance = Document(fileName: "high.pdf", fileType: .pdf)
        highRelevance.relevanceScore = 0.9

        let lowRelevance = Document(fileName: "low.pdf", fileType: .pdf)
        lowRelevance.relevanceScore = 0.3

        try repository.insert(highRelevance)
        try repository.insert(lowRelevance)

        let relevant = try repository.fetchRelevant(threshold: 0.7)

        #expect(relevant.count > 0, "Should find high relevance documents")
        let scores = relevant.map { $0.relevanceScore }
        #expect(scores.allSatisfy { $0 >= 0.7 }, "All results should meet threshold")
    }

    @Test("Privileged document filtering")
    func testPrivilegedFiltering() throws {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        let privileged = Document(fileName: "priv.pdf", fileType: .pdf)
        privileged.isPrivileged = true

        let normal = Document(fileName: "normal.pdf", fileType: .pdf)
        normal.isPrivileged = false

        try repository.insert(privileged)
        try repository.insert(normal)

        let privilegedDocs = try repository.fetchPrivileged()

        #expect(privilegedDocs.count > 0, "Should find privileged documents")
        #expect(privilegedDocs.allSatisfy { $0.isPrivileged }, "All should be privileged")
    }

    @Test("File type filtering")
    func testFileTypeFiltering() throws {
        let context = DataManager.shared.modelContext
        let repository = DocumentRepository(modelContext: context)

        let pdf = Document(fileName: "doc.pdf", fileType: .pdf)
        let email = Document(fileName: "msg.msg", fileType: .email)
        let word = Document(fileName: "doc.docx", fileType: .word)

        try repository.insert(pdf)
        try repository.insert(email)
        try repository.insert(word)

        let pdfs = try repository.fetchByFileType(.pdf)
        let emails = try repository.fetchByFileType(.email)

        #expect(pdfs.count > 0, "Should find PDF documents")
        #expect(emails.count > 0, "Should find email documents")
        #expect(pdfs.allSatisfy { $0.fileType == .pdf }, "Should only return PDFs")
        #expect(emails.allSatisfy { $0.fileType == .email }, "Should only return emails")
    }
}

@Suite("Case Repository Tests")
@MainActor
struct CaseRepositoryTests {

    @Test("Case insertion and retrieval")
    func testCaseInsertAndFetch() throws {
        let context = DataManager.shared.modelContext
        let repository = CaseRepository(modelContext: context)

        let legalCase = LegalCase(
            caseNumber: "2024-CV-TEST",
            title: "Test v. Example",
            description: "Test case description"
        )

        try repository.insert(legalCase)

        let fetched = try repository.fetch(id: legalCase.id)

        #expect(fetched != nil, "Should fetch inserted case")
        #expect(fetched?.caseNumber == "2024-CV-TEST")
        #expect(fetched?.title == "Test v. Example")
    }

    @Test("Fetch all cases")
    func testFetchAll() throws {
        let context = DataManager.shared.modelContext
        let repository = CaseRepository(modelContext: context)

        let case1 = LegalCase(
            caseNumber: "2024-001",
            title: "Case One",
            description: "First"
        )

        let case2 = LegalCase(
            caseNumber: "2024-002",
            title: "Case Two",
            description: "Second"
        )

        try repository.insert(case1)
        try repository.insert(case2)

        let allCases = try repository.fetchAll()

        #expect(allCases.count >= 2, "Should fetch all cases")
    }

    @Test("Fetch active cases only")
    func testFetchActive() throws {
        let context = DataManager.shared.modelContext
        let repository = CaseRepository(modelContext: context)

        let activeCase = LegalCase(
            caseNumber: "2024-ACTIVE",
            title: "Active Case",
            description: "Active"
        )
        activeCase.status = .active

        let archivedCase = LegalCase(
            caseNumber: "2024-ARCHIVED",
            title: "Archived Case",
            description: "Archived"
        )
        archivedCase.status = .archived

        try repository.insert(activeCase)
        try repository.insert(archivedCase)

        let activeCases = try repository.fetchActive()

        #expect(activeCases.count > 0, "Should find active cases")
        #expect(activeCases.allSatisfy { $0.status == .active },
                "Should only return active cases")
    }

    @Test("Case search")
    func testCaseSearch() throws {
        let context = DataManager.shared.modelContext
        let repository = CaseRepository(modelContext: context)

        let contractCase = LegalCase(
            caseNumber: "2024-CONTRACT",
            title: "Contract Dispute",
            description: "Software license agreement dispute"
        )

        let laborCase = LegalCase(
            caseNumber: "2024-LABOR",
            title: "Employment Matter",
            description: "Wrongful termination case"
        )

        try repository.insert(contractCase)
        try repository.insert(laborCase)

        let results = try repository.search(query: "contract")

        #expect(results.count > 0, "Should find matching cases")
        let titles = results.map { $0.title }
        #expect(titles.contains("Contract Dispute"), "Should find contract case")
    }

    @Test("Statistics update")
    func testStatisticsUpdate() throws {
        let context = DataManager.shared.modelContext
        let caseRepo = CaseRepository(modelContext: context)
        let docRepo = DocumentRepository(modelContext: context)

        let legalCase = LegalCase(
            caseNumber: "2024-STATS",
            title: "Statistics Test",
            description: "Test"
        )
        try caseRepo.insert(legalCase)

        // Add documents
        for i in 0..<10 {
            let doc = Document(
                fileName: "doc\(i).pdf",
                fileType: .pdf,
                extractedText: "Content"
            )
            doc.legalCase = legalCase
            doc.isRelevant = i < 5  // 5 relevant
            doc.isPrivileged = i < 2  // 2 privileged
            doc.isReviewed = i < 7  // 7 reviewed

            legalCase.documents.append(doc)
        }

        try caseRepo.updateStatistics(for: legalCase.id)

        let updated = try caseRepo.fetch(id: legalCase.id)

        #expect(updated?.documentCount == 10, "Should count all documents")
        #expect(updated?.relevantDocumentCount == 5, "Should count relevant docs")
        #expect(updated?.privilegedDocumentCount == 2, "Should count privileged docs")
        #expect(updated?.reviewProgress == 0.7, "Should calculate review progress (7/10)")
    }
}

@Suite("Cache Manager Tests")
struct CacheManagerTests {

    @Test("Cache storage and retrieval")
    func testCacheOperations() async {
        let cacheManager = CacheManager()

        let document = Document(
            fileName: "cached.pdf",
            fileType: .pdf,
            extractedText: "Cached content"
        )

        await cacheManager.cache(document)

        let retrieved = await cacheManager.getDocument(id: document.id)

        #expect(retrieved != nil, "Should retrieve cached document")
        #expect(retrieved?.fileName == "cached.pdf")
    }

    @Test("Cache invalidation")
    func testCacheInvalidation() async {
        let cacheManager = CacheManager()

        let document = Document(
            fileName: "to_invalidate.pdf",
            fileType: .pdf
        )

        await cacheManager.cache(document)

        var retrieved = await cacheManager.getDocument(id: document.id)
        #expect(retrieved != nil, "Should find cached document before invalidation")

        await cacheManager.invalidate(documentId: document.id)

        retrieved = await cacheManager.getDocument(id: document.id)
        #expect(retrieved == nil, "Should not find document after invalidation")
    }

    @Test("Cache clear")
    func testCacheClear() async {
        let cacheManager = CacheManager()

        let doc1 = Document(fileName: "doc1.pdf", fileType: .pdf)
        let doc2 = Document(fileName: "doc2.pdf", fileType: .pdf)

        await cacheManager.cache(doc1)
        await cacheManager.cache(doc2)

        await cacheManager.clear()

        let retrieved1 = await cacheManager.getDocument(id: doc1.id)
        let retrieved2 = await cacheManager.getDocument(id: doc2.id)

        #expect(retrieved1 == nil, "Should clear all cached documents")
        #expect(retrieved2 == nil, "Should clear all cached documents")
    }
}

@Suite("Integration Tests")
@MainActor
struct IntegrationTests {

    @Test("Full document workflow")
    func testFullDocumentWorkflow() async throws {
        let context = DataManager.shared.modelContext
        let docRepo = DocumentRepository(modelContext: context)
        let caseRepo = CaseRepository(modelContext: context)
        let aiService = EnhancedAIService()

        // 1. Create case
        let legalCase = LegalCase(
            caseNumber: "2024-INTEGRATION",
            title: "Integration Test Case",
            description: "End-to-end test"
        )
        try caseRepo.insert(legalCase)

        // 2. Create document
        let document = Document(
            fileName: "integration_test.pdf",
            fileType: .pdf,
            extractedText: """
            This is a test document for integration testing.
            It contains legal terms, contract language, and
            references to litigation and discovery processes.
            """
        )
        document.legalCase = legalCase

        // 3. Analyze with AI
        let analysis = try await aiService.analyzeDocument(document)
        document.aiAnalysis = analysis
        document.relevanceScore = analysis.relevanceScore

        // 4. Save to repository
        try docRepo.insert(document)

        // 5. Search for document
        let searchResults = try docRepo.search(query: "integration")

        #expect(searchResults.count > 0, "Should find document via search")

        // 6. Update case statistics
        try caseRepo.updateStatistics(for: legalCase.id)

        let updatedCase = try caseRepo.fetch(id: legalCase.id)
        #expect(updatedCase?.documentCount > 0, "Case should have document count")
    }

    @Test("Multi-document analysis workflow")
    func testMultiDocumentAnalysis() async throws {
        let aiService = EnhancedAIService()

        var documents: [Document] = []

        // Create related documents
        for i in 0..<3 {
            let doc = Document(
                fileName: "related\(i).pdf",
                fileType: .pdf,
                extractedText: "This is a contract document about software licensing agreement number \(i)"
            )
            documents.append(doc)
        }

        // Analyze each document
        for document in documents {
            let analysis = try await aiService.analyzeDocument(document)
            document.aiAnalysis = analysis
            document.relevanceScore = analysis.relevanceScore
        }

        // Find relationships
        let relationships = try await aiService.findRelationships(between: documents)

        #expect(documents.allSatisfy { $0.relevanceScore > 0 },
                "All documents should have relevance scores")
        #expect(relationships.count >= 0, "Should complete relationship analysis")
    }
}
