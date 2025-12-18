//
//  SearchEngineTests.swift
//  Institutional Memory Vault Tests
//
//  Unit tests for SearchEngine service
//

import Testing
import Foundation
import SwiftData
@testable import InstitutionalMemoryVault

@Suite("Search Engine Tests")
struct SearchEngineTests {

    // MARK: - Setup

    private func createTestModelContext() -> ModelContext {
        let schema = Schema([
            KnowledgeEntity.self,
            Employee.self,
            Department.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try! ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    private func populateTestData(context: ModelContext) {
        // Create test knowledge items
        let knowledge1 = KnowledgeEntity(
            title: "Swift Programming Guide",
            content: "A comprehensive guide to Swift programming language",
            contentType: .document,
            tags: ["swift", "programming", "guide"]
        )

        let knowledge2 = KnowledgeEntity(
            title: "visionOS Best Practices",
            content: "Best practices for developing spatial computing applications",
            contentType: .expertise,
            tags: ["visionOS", "spatial", "best-practices"]
        )

        let knowledge3 = KnowledgeEntity(
            title: "Product Launch Decision",
            content: "Strategic decision to launch new product in Q4",
            contentType: .decision,
            tags: ["product", "launch", "strategy"]
        )

        context.insert(knowledge1)
        context.insert(knowledge2)
        context.insert(knowledge3)

        try! context.save()
    }

    // MARK: - Text Search Tests

    @Test("Basic text search")
    func testBasicSearch() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.search(query: "Swift")
        #expect(results.count > 0)
        #expect(results.first?.knowledge.title.contains("Swift") == true)
    }

    @Test("Search with multiple keywords")
    func testMultiKeywordSearch() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.search(query: "visionOS spatial")
        #expect(results.count > 0)

        if let first = results.first {
            #expect(first.knowledge.title.contains("visionOS") || first.knowledge.content.contains("spatial"))
        }
    }

    @Test("Search returns empty for no matches")
    func testNoMatchesSearch() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.search(query: "nonexistent keyword xyz")
        #expect(results.isEmpty)
    }

    @Test("Case insensitive search")
    func testCaseInsensitiveSearch() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let results1 = try await engine.search(query: "SWIFT")
        let results2 = try await engine.search(query: "swift")
        let results3 = try await engine.search(query: "Swift")

        #expect(results1.count == results2.count)
        #expect(results2.count == results3.count)
    }

    // MARK: - Relevance Scoring Tests

    @Test("Title match scores higher than content match")
    func testRelevanceScoring() async throws {
        let context = createTestModelContext()

        let titleMatch = KnowledgeEntity(
            title: "Swift Programming",
            content: "Learn about programming",
            contentType: .document
        )

        let contentMatch = KnowledgeEntity(
            title: "Programming Guide",
            content: "Swift is a powerful language",
            contentType: .document
        )

        context.insert(titleMatch)
        context.insert(contentMatch)
        try! context.save()

        let engine = SearchEngine(modelContext: context)
        let results = try await engine.search(query: "Swift")

        #expect(results.count == 2)
        // Title match should score higher
        #expect(results[0].relevanceScore > results[1].relevanceScore)
    }

    // MARK: - Tag Search Tests

    @Test("Search by single tag")
    func testTagSearch() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.searchByTags(tags: ["swift"])
        #expect(results.count > 0)
        #expect(results.allSatisfy { knowledge in
            knowledge.tags.contains { $0.lowercased() == "swift" }
        })
    }

    @Test("Search by multiple tags (match any)")
    func testMultipleTagsMatchAny() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.searchByTags(
            tags: ["swift", "visionOS"],
            matchAll: false
        )

        #expect(results.count >= 2)
    }

    @Test("Search by multiple tags (match all)")
    func testMultipleTagsMatchAll() async throws {
        let context = createTestModelContext()

        let multiTagged = KnowledgeEntity(
            title: "Combined Guide",
            content: "Content",
            contentType: .document,
            tags: ["swift", "visionOS", "advanced"]
        )

        context.insert(multiTagged)
        try! context.save()

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.searchByTags(
            tags: ["swift", "visionOS"],
            matchAll: true
        )

        #expect(results.count == 1)
        #expect(results.first?.tags.contains("swift") == true)
        #expect(results.first?.tags.contains("visionOS") == true)
    }

    // MARK: - Filter Tests

    @Test("Search with content type filter")
    func testContentTypeFilter() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let filters = SearchFilters(contentType: .expertise)
        let results = try await engine.search(query: "visionOS", filters: filters)

        #expect(results.count > 0)
        #expect(results.allSatisfy { $0.knowledge.contentType == .expertise })
    }

    @Test("Search with date range filter")
    func testDateRangeFilter() async throws {
        let context = createTestModelContext()

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!

        let recent = KnowledgeEntity(
            title: "Recent Knowledge",
            content: "Created today",
            contentType: .document,
            createdDate: today
        )

        let old = KnowledgeEntity(
            title: "Old Knowledge",
            content: "Created last week",
            contentType: .document,
            createdDate: lastWeek
        )

        context.insert(recent)
        context.insert(old)
        try! context.save()

        let engine = SearchEngine(modelContext: context)

        let filters = SearchFilters(startDate: yesterday)
        let results = try await engine.search(query: "Knowledge", filters: filters)

        #expect(results.count == 1)
        #expect(results.first?.knowledge.title == "Recent Knowledge")
    }

    // MARK: - Search Suggestions Tests

    @Test("Get search suggestions")
    func testSearchSuggestions() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let suggestions = try await engine.getSuggestions(partialQuery: "Swi")
        #expect(suggestions.contains { $0.lowercased().contains("swift") })
    }

    @Test("Suggestions require minimum 2 characters")
    func testSuggestionsMinimumLength() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let suggestions = try await engine.getSuggestions(partialQuery: "S")
        #expect(suggestions.isEmpty)
    }

    // MARK: - Search History Tests

    @Test("Search history is recorded")
    func testSearchHistory() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        _ = try await engine.search(query: "Swift")
        _ = try await engine.search(query: "visionOS")

        let history = await engine.getSearchHistory(limit: 10)
        #expect(history.count == 2)
        #expect(history[0].text == "visionOS") // Most recent first
        #expect(history[1].text == "Swift")
    }

    @Test("Popular searches tracked")
    func testPopularSearches() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        // Search for "Swift" multiple times
        _ = try await engine.search(query: "Swift")
        _ = try await engine.search(query: "Swift")
        _ = try await engine.search(query: "Swift")
        _ = try await engine.search(query: "visionOS")

        let popular = await engine.getPopularSearches(limit: 10)
        #expect(popular.first == "Swift")
    }

    @Test("Clear search history")
    func testClearHistory() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        _ = try await engine.search(query: "Swift")
        await engine.clearSearchHistory()

        let history = await engine.getSearchHistory(limit: 10)
        #expect(history.isEmpty)
    }

    // MARK: - Available Filters Tests

    @Test("Get available filters")
    func testAvailableFilters() async throws {
        let context = createTestModelContext()
        populateTestData(context: context)

        let engine = SearchEngine(modelContext: context)

        let filters = try await engine.getAvailableFilters()

        #expect(filters.contentTypes.count > 0)
        #expect(filters.tags.count > 0)
    }

    // MARK: - Performance Tests

    @Test("Search with limit")
    func testSearchLimit() async throws {
        let context = createTestModelContext()

        // Create 100 test items
        for i in 1...100 {
            let knowledge = KnowledgeEntity(
                title: "Test Item \(i)",
                content: "Content about testing",
                contentType: .document
            )
            context.insert(knowledge)
        }
        try! context.save()

        let engine = SearchEngine(modelContext: context)

        let results = try await engine.search(query: "Test", limit: 10)
        #expect(results.count == 10)
    }

    @Test("Search returns results sorted by relevance")
    func testResultsSorting() async throws {
        let context = createTestModelContext()

        let exact = KnowledgeEntity(
            title: "Swift",
            content: "About Swift",
            contentType: .document
        )

        let partial = KnowledgeEntity(
            title: "SwiftUI Guide",
            content: "Guide to SwiftUI",
            contentType: .document
        )

        context.insert(exact)
        context.insert(partial)
        try! context.save()

        let engine = SearchEngine(modelContext: context)
        let results = try await engine.search(query: "Swift")

        // Results should be sorted by relevance (descending)
        for i in 0..<(results.count - 1) {
            #expect(results[i].relevanceScore >= results[i + 1].relevanceScore)
        }
    }
}
