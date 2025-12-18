//
//  SearchEngine.swift
//  Institutional Memory Vault
//
//  Advanced search functionality for knowledge discovery
//

import Foundation
import SwiftData

actor SearchEngine {
    private let modelContext: ModelContext

    // Search history for analytics
    private var searchHistory: [SearchQuery] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Text Search

    /// Perform a full-text search across knowledge entities
    func search(
        query: String,
        filters: SearchFilters? = nil,
        limit: Int = 50
    ) async throws -> [SearchResult] {
        // Record search query
        let searchQuery = SearchQuery(text: query, timestamp: Date())
        searchHistory.append(searchQuery)

        // Fetch all knowledge (in production, this would use a proper search index)
        let descriptor = FetchDescriptor<KnowledgeEntity>()
        let allKnowledge = try modelContext.fetch(descriptor)

        var results: [SearchResult] = []

        for knowledge in allKnowledge {
            // Calculate relevance score
            var score = calculateRelevanceScore(knowledge: knowledge, query: query)

            // Apply filters
            if let filters = filters {
                if !matchesFilters(knowledge: knowledge, filters: filters) {
                    continue
                }
            }

            if score > 0 {
                results.append(SearchResult(
                    knowledge: knowledge,
                    relevanceScore: score,
                    matchedFields: determineMatchedFields(knowledge: knowledge, query: query)
                ))
            }
        }

        // Sort by relevance
        results.sort { $0.relevanceScore > $1.relevanceScore }

        // Apply limit
        return Array(results.prefix(limit))
    }

    /// Search by tags
    func searchByTags(
        tags: [String],
        matchAll: Bool = false,
        limit: Int = 50
    ) async throws -> [KnowledgeEntity] {
        let descriptor = FetchDescriptor<KnowledgeEntity>()
        let allKnowledge = try modelContext.fetch(descriptor)

        let results = allKnowledge.filter { knowledge in
            if matchAll {
                // Must have all specified tags
                return tags.allSatisfy { tag in
                    knowledge.tags.contains { $0.lowercased() == tag.lowercased() }
                }
            } else {
                // Must have at least one of the specified tags
                return tags.contains { tag in
                    knowledge.tags.contains { $0.lowercased() == tag.lowercased() }
                }
            }
        }

        return Array(results.prefix(limit))
    }

    // MARK: - Semantic Search (Placeholder for future implementation)

    /// Semantic search using embeddings
    /// In production, this would use a vector database like Qdrant
    func semanticSearch(
        query: String,
        limit: Int = 20
    ) async throws -> [SearchResult] {
        // For now, fallback to text search
        // In production, this would:
        // 1. Generate embedding for query
        // 2. Query vector database
        // 3. Return nearest neighbors
        return try await search(query: query, limit: limit)
    }

    // MARK: - Faceted Search

    /// Get available filter options based on current data
    func getAvailableFilters() async throws -> AvailableFilters {
        let descriptor = FetchDescriptor<KnowledgeEntity>()
        let allKnowledge = try modelContext.fetch(descriptor)

        let contentTypes = Set(allKnowledge.map { $0.contentType })
        let departments = Set(allKnowledge.compactMap { $0.department?.name })
        let tags = Set(allKnowledge.flatMap { $0.tags })
        let authors = Set(allKnowledge.compactMap { $0.author?.name })

        return AvailableFilters(
            contentTypes: Array(contentTypes),
            departments: Array(departments),
            tags: Array(tags),
            authors: Array(authors)
        )
    }

    // MARK: - Search Suggestions

    /// Get search suggestions based on partial query
    func getSuggestions(partialQuery: String, limit: Int = 10) async throws -> [String] {
        guard partialQuery.count >= 2 else { return [] }

        let descriptor = FetchDescriptor<KnowledgeEntity>()
        let allKnowledge = try modelContext.fetch(descriptor)

        var suggestions = Set<String>()

        // Suggest titles
        for knowledge in allKnowledge {
            if knowledge.title.lowercased().contains(partialQuery.lowercased()) {
                suggestions.insert(knowledge.title)
            }
        }

        // Suggest tags
        for knowledge in allKnowledge {
            for tag in knowledge.tags where tag.lowercased().contains(partialQuery.lowercased()) {
                suggestions.insert(tag)
            }
        }

        return Array(suggestions.prefix(limit))
    }

    // MARK: - Search Analytics

    func getSearchHistory(limit: Int = 20) -> [SearchQuery] {
        return Array(searchHistory.suffix(limit).reversed())
    }

    func getPopularSearches(limit: Int = 10) -> [String] {
        let queryCounts = Dictionary(grouping: searchHistory, by: { $0.text })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }

        return Array(queryCounts.prefix(limit).map { $0.key })
    }

    func clearSearchHistory() {
        searchHistory.removeAll()
    }

    // MARK: - Private Helpers

    private func calculateRelevanceScore(knowledge: KnowledgeEntity, query: String) -> Float {
        var score: Float = 0.0
        let queryLower = query.lowercased()
        let words = queryLower.split(separator: " ").map(String.init)

        // Title match (highest weight)
        let titleLower = knowledge.title.lowercased()
        if titleLower == queryLower {
            score += 10.0
        } else if titleLower.contains(queryLower) {
            score += 5.0
        } else {
            for word in words where titleLower.contains(word) {
                score += 2.0
            }
        }

        // Content match
        let contentLower = knowledge.content.lowercased()
        if contentLower.contains(queryLower) {
            score += 3.0
        } else {
            for word in words where contentLower.contains(word) {
                score += 0.5
            }
        }

        // Tag match
        for tag in knowledge.tags {
            if tag.lowercased() == queryLower {
                score += 4.0
            } else if tag.lowercased().contains(queryLower) {
                score += 2.0
            }
        }

        // Boost recent content
        let daysSinceModified = Date().timeIntervalSince(knowledge.lastModified) / 86400
        if daysSinceModified < 30 {
            score *= 1.2
        }

        return score
    }

    private func determineMatchedFields(knowledge: KnowledgeEntity, query: String) -> [String] {
        var fields: [String] = []
        let queryLower = query.lowercased()

        if knowledge.title.lowercased().contains(queryLower) {
            fields.append("title")
        }
        if knowledge.content.lowercased().contains(queryLower) {
            fields.append("content")
        }
        if knowledge.tags.contains(where: { $0.lowercased().contains(queryLower) }) {
            fields.append("tags")
        }

        return fields
    }

    private func matchesFilters(knowledge: KnowledgeEntity, filters: SearchFilters) -> Bool {
        // Content type filter
        if let contentType = filters.contentType, knowledge.contentType != contentType {
            return false
        }

        // Department filter
        if let departmentId = filters.departmentId, knowledge.department?.id != departmentId {
            return false
        }

        // Date range filter
        if let startDate = filters.startDate, knowledge.createdDate < startDate {
            return false
        }
        if let endDate = filters.endDate, knowledge.createdDate > endDate {
            return false
        }

        // Access level filter
        if let accessLevel = filters.accessLevel, knowledge.accessLevel != accessLevel {
            return false
        }

        return true
    }
}

// MARK: - Supporting Types

struct SearchResult {
    let knowledge: KnowledgeEntity
    let relevanceScore: Float
    let matchedFields: [String]
}

struct SearchFilters {
    var contentType: KnowledgeContentType?
    var departmentId: UUID?
    var startDate: Date?
    var endDate: Date?
    var accessLevel: AccessLevel?
    var tags: [String]?
}

struct SearchQuery {
    let text: String
    let timestamp: Date
}

struct AvailableFilters {
    let contentTypes: [KnowledgeContentType]
    let departments: [String]
    let tags: [String]
    let authors: [String]
}
