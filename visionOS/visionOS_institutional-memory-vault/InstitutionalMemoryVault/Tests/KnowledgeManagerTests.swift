//
//  KnowledgeManagerTests.swift
//  Institutional Memory Vault Tests
//
//  Unit tests for KnowledgeManager service
//

import Testing
import Foundation
import SwiftData
@testable import InstitutionalMemoryVault

@Suite("Knowledge Manager Tests")
struct KnowledgeManagerTests {

    // MARK: - Setup

    private func createTestModelContext() -> ModelContext {
        let schema = Schema([
            KnowledgeEntity.self,
            Employee.self,
            Department.self,
            Organization.self,
            KnowledgeConnection.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // Use in-memory store for testing
        )

        let container = try! ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    // MARK: - CRUD Tests

    @Test("Create knowledge entity")
    func testCreateKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let knowledgeId = try await manager.createKnowledge(
            title: "Test Knowledge",
            content: "This is test content",
            contentType: .document,
            tags: ["test", "sample"],
            accessLevel: .publicOrg
        )

        #expect(knowledgeId != UUID())

        // Verify it was saved
        let fetched = try await manager.fetchKnowledge(id: knowledgeId)
        #expect(fetched.title == "Test Knowledge")
        #expect(fetched.content == "This is test content")
        #expect(fetched.contentType == .document)
        #expect(fetched.tags.contains("test"))
    }

    @Test("Fetch knowledge by ID")
    func testFetchKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let id = try await manager.createKnowledge(
            title: "Fetch Test",
            content: "Content to fetch",
            contentType: .expertise
        )

        let knowledge = try await manager.fetchKnowledge(id: id)
        #expect(knowledge.id == id)
        #expect(knowledge.title == "Fetch Test")
    }

    @Test("Update knowledge entity")
    func testUpdateKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let id = try await manager.createKnowledge(
            title: "Original Title",
            content: "Original content",
            contentType: .document
        )

        let knowledge = try await manager.fetchKnowledge(id: id)
        knowledge.title = "Updated Title"
        knowledge.content = "Updated content"

        try await manager.updateKnowledge(knowledge)

        let updated = try await manager.fetchKnowledge(id: id)
        #expect(updated.title == "Updated Title")
        #expect(updated.content == "Updated content")
    }

    @Test("Delete knowledge entity")
    func testDeleteKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let id = try await manager.createKnowledge(
            title: "To Delete",
            content: "Will be deleted",
            contentType: .document
        )

        try await manager.deleteKnowledge(id: id)

        // Should throw error when trying to fetch deleted item
        await #expect(throws: KnowledgeError.self) {
            try await manager.fetchKnowledge(id: id)
        }
    }

    // MARK: - Query Tests

    @Test("Fetch all knowledge")
    func testFetchAllKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        // Create multiple knowledge items
        _ = try await manager.createKnowledge(title: "First", content: "Content 1", contentType: .document)
        _ = try await manager.createKnowledge(title: "Second", content: "Content 2", contentType: .expertise)
        _ = try await manager.createKnowledge(title: "Third", content: "Content 3", contentType: .decision)

        let all = try await manager.fetchAllKnowledge()
        #expect(all.count == 3)
    }

    @Test("Fetch knowledge by type")
    func testFetchKnowledgeByType() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        _ = try await manager.createKnowledge(title: "Doc", content: "Content", contentType: .document)
        _ = try await manager.createKnowledge(title: "Expert", content: "Content", contentType: .expertise)
        _ = try await manager.createKnowledge(title: "Doc2", content: "Content", contentType: .document)

        let documents = try await manager.fetchKnowledge(ofType: .document)
        #expect(documents.count == 2)
        #expect(documents.allSatisfy { $0.contentType == .document })
    }

    @Test("Fetch recent knowledge")
    func testFetchRecentKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        // Create 15 items
        for i in 1...15 {
            _ = try await manager.createKnowledge(
                title: "Item \(i)",
                content: "Content \(i)",
                contentType: .document
            )
        }

        let recent = try await manager.fetchRecentKnowledge(limit: 10)
        #expect(recent.count == 10)
    }

    // MARK: - Connection Tests

    @Test("Create connection between knowledge")
    func testCreateConnection() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let sourceId = try await manager.createKnowledge(
            title: "Source",
            content: "Source content",
            contentType: .document
        )

        let targetId = try await manager.createKnowledge(
            title: "Target",
            content: "Target content",
            contentType: .document
        )

        let connectionId = try await manager.createConnection(
            from: sourceId,
            to: targetId,
            type: .relatedTo,
            strength: 0.8
        )

        #expect(connectionId != UUID())
    }

    @Test("Fetch related knowledge")
    func testFetchRelatedKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let mainId = try await manager.createKnowledge(
            title: "Main",
            content: "Main content",
            contentType: .document
        )

        let relatedId = try await manager.createKnowledge(
            title: "Related",
            content: "Related content",
            contentType: .document
        )

        _ = try await manager.createConnection(
            from: mainId,
            to: relatedId,
            type: .relatedTo
        )

        let related = try await manager.fetchRelatedKnowledge(to: mainId, limit: 10)
        #expect(related.count == 1)
        #expect(related.first?.id == relatedId)
    }

    // MARK: - Statistics Tests

    @Test("Update statistics")
    func testUpdateStatistics() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        #expect(manager.totalKnowledge == 0)

        _ = try await manager.createKnowledge(title: "Test", content: "Content", contentType: .document)
        await manager.updateStatistics()

        #expect(manager.totalKnowledge == 1)
    }

    // MARK: - Error Handling Tests

    @Test("Fetch non-existent knowledge throws error")
    func testFetchNonExistentKnowledge() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let fakeId = UUID()

        await #expect(throws: KnowledgeError.self) {
            try await manager.fetchKnowledge(id: fakeId)
        }
    }

    @Test("Create connection with invalid IDs throws error")
    func testInvalidConnection() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let validId = try await manager.createKnowledge(
            title: "Valid",
            content: "Content",
            contentType: .document
        )
        let fakeId = UUID()

        await #expect(throws: KnowledgeError.invalidConnection) {
            try await manager.createConnection(
                from: validId,
                to: fakeId,
                type: .relatedTo
            )
        }
    }

    // MARK: - Cache Tests

    @Test("Cache management")
    func testCacheManagement() async throws {
        let context = createTestModelContext()
        let manager = KnowledgeManager(modelContext: context)

        let id = try await manager.createKnowledge(
            title: "Cached",
            content: "Content",
            contentType: .document
        )

        // First fetch populates cache
        _ = try await manager.fetchKnowledge(id: id)

        // Clear cache
        manager.clearCache()

        // Should still be able to fetch from database
        let knowledge = try await manager.fetchKnowledge(id: id)
        #expect(knowledge.title == "Cached")
    }
}
