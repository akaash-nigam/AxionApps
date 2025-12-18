//
//  KnowledgeManager.swift
//  Institutional Memory Vault
//
//  Central service for managing knowledge entities
//

import Foundation
import SwiftData

@Observable
final class KnowledgeManager {
    private let modelContext: ModelContext

    // In-memory cache for performance
    private var cache: [UUID: KnowledgeEntity] = [:]

    // Statistics
    var totalKnowledge: Int = 0
    var totalConnections: Int = 0

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await updateStatistics()
        }
    }

    // MARK: - CRUD Operations

    /// Create a new knowledge entity
    func createKnowledge(
        title: String,
        content: String,
        contentType: KnowledgeContentType,
        author: Employee? = nil,
        department: Department? = nil,
        tags: [String] = [],
        accessLevel: AccessLevel = .publicOrg
    ) async throws -> UUID {
        let knowledge = KnowledgeEntity(
            title: title,
            content: content,
            contentType: contentType,
            author: author,
            department: department,
            tags: tags,
            accessLevel: accessLevel
        )

        modelContext.insert(knowledge)

        do {
            try modelContext.save()
            cache[knowledge.id] = knowledge
            totalKnowledge += 1
            return knowledge.id
        } catch {
            throw KnowledgeError.creationFailed(error)
        }
    }

    /// Fetch a knowledge entity by ID
    func fetchKnowledge(id: UUID) async throws -> KnowledgeEntity {
        // Check cache first
        if let cached = cache[id] {
            return cached
        }

        let descriptor = FetchDescriptor<KnowledgeEntity>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let results = try modelContext.fetch(descriptor)
            guard let knowledge = results.first else {
                throw KnowledgeError.notFound(id)
            }
            cache[id] = knowledge
            return knowledge
        } catch {
            throw KnowledgeError.fetchFailed(error)
        }
    }

    /// Update an existing knowledge entity
    func updateKnowledge(_ knowledge: KnowledgeEntity) async throws {
        knowledge.lastModified = Date()

        do {
            try modelContext.save()
            cache[knowledge.id] = knowledge
        } catch {
            throw KnowledgeError.updateFailed(error)
        }
    }

    /// Delete a knowledge entity
    func deleteKnowledge(id: UUID) async throws {
        guard let knowledge = try? await fetchKnowledge(id: id) else {
            throw KnowledgeError.notFound(id)
        }

        modelContext.delete(knowledge)

        do {
            try modelContext.save()
            cache.removeValue(forKey: id)
            totalKnowledge -= 1
        } catch {
            throw KnowledgeError.deletionFailed(error)
        }
    }

    // MARK: - Query Operations

    /// Fetch all knowledge entities
    func fetchAllKnowledge(
        sortBy: KnowledgeSortOption = .dateDescending,
        limit: Int? = nil
    ) async throws -> [KnowledgeEntity] {
        var descriptor = FetchDescriptor<KnowledgeEntity>()

        // Apply sorting
        switch sortBy {
        case .dateAscending:
            descriptor.sortBy = [SortDescriptor(\.createdDate, order: .forward)]
        case .dateDescending:
            descriptor.sortBy = [SortDescriptor(\.createdDate, order: .reverse)]
        case .titleAscending:
            descriptor.sortBy = [SortDescriptor(\.title, order: .forward)]
        case .titleDescending:
            descriptor.sortBy = [SortDescriptor(\.title, order: .reverse)]
        case .relevance:
            descriptor.sortBy = [SortDescriptor(\.lastModified, order: .reverse)]
        }

        // Apply limit
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        do {
            let results = try modelContext.fetch(descriptor)
            return results
        } catch {
            throw KnowledgeError.fetchFailed(error)
        }
    }

    /// Fetch knowledge by content type
    func fetchKnowledge(
        ofType type: KnowledgeContentType,
        limit: Int? = nil
    ) async throws -> [KnowledgeEntity] {
        var descriptor = FetchDescriptor<KnowledgeEntity>(
            predicate: #Predicate { $0.contentType == type }
        )
        descriptor.sortBy = [SortDescriptor(\.createdDate, order: .reverse)]

        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        do {
            let results = try modelContext.fetch(descriptor)
            return results
        } catch {
            throw KnowledgeError.fetchFailed(error)
        }
    }

    /// Fetch knowledge by department
    func fetchKnowledge(
        inDepartment departmentId: UUID,
        limit: Int? = nil
    ) async throws -> [KnowledgeEntity] {
        var descriptor = FetchDescriptor<KnowledgeEntity>(
            predicate: #Predicate { $0.department?.id == departmentId }
        )
        descriptor.sortBy = [SortDescriptor(\.createdDate, order: .reverse)]

        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        do {
            let results = try modelContext.fetch(descriptor)
            return results
        } catch {
            throw KnowledgeError.fetchFailed(error)
        }
    }

    /// Fetch recent knowledge
    func fetchRecentKnowledge(limit: Int = 10) async throws -> [KnowledgeEntity] {
        return try await fetchAllKnowledge(sortBy: .dateDescending, limit: limit)
    }

    // MARK: - Connection Management

    /// Create a connection between two knowledge entities
    func createConnection(
        from sourceId: UUID,
        to targetId: UUID,
        type: ConnectionType,
        strength: Float = 1.0,
        context: String? = nil,
        createdBy: Employee? = nil
    ) async throws -> UUID {
        guard let source = try? await fetchKnowledge(id: sourceId),
              let target = try? await fetchKnowledge(id: targetId) else {
            throw KnowledgeError.invalidConnection
        }

        let connection = KnowledgeConnection(
            sourceEntity: source,
            targetEntity: target,
            connectionType: type,
            strength: strength,
            context: context,
            createdBy: createdBy
        )

        modelContext.insert(connection)

        do {
            try modelContext.save()
            totalConnections += 1
            return connection.id
        } catch {
            throw KnowledgeError.connectionFailed(error)
        }
    }

    /// Fetch related knowledge based on connections
    func fetchRelatedKnowledge(
        to knowledgeId: UUID,
        limit: Int = 10
    ) async throws -> [KnowledgeEntity] {
        let descriptor = FetchDescriptor<KnowledgeConnection>(
            predicate: #Predicate {
                $0.sourceEntity?.id == knowledgeId || $0.targetEntity?.id == knowledgeId
            }
        )

        do {
            let connections = try modelContext.fetch(descriptor)
            let relatedIds = connections.compactMap { connection in
                if connection.sourceEntity?.id == knowledgeId {
                    return connection.targetEntity
                } else {
                    return connection.sourceEntity
                }
            }

            return Array(relatedIds.prefix(limit))
        } catch {
            throw KnowledgeError.fetchFailed(error)
        }
    }

    // MARK: - Statistics

    func updateStatistics() async {
        let knowledgeDescriptor = FetchDescriptor<KnowledgeEntity>()
        let connectionDescriptor = FetchDescriptor<KnowledgeConnection>()

        do {
            let knowledge = try modelContext.fetch(knowledgeDescriptor)
            let connections = try modelContext.fetch(connectionDescriptor)

            totalKnowledge = knowledge.count
            totalConnections = connections.count
        } catch {
            print("Failed to update statistics: \(error)")
        }
    }

    // MARK: - Cache Management

    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Supporting Types

enum KnowledgeSortOption {
    case dateAscending
    case dateDescending
    case titleAscending
    case titleDescending
    case relevance
}

enum KnowledgeError: LocalizedError {
    case creationFailed(Error)
    case fetchFailed(Error)
    case updateFailed(Error)
    case deletionFailed(Error)
    case notFound(UUID)
    case invalidConnection
    case connectionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .creationFailed(let error):
            return "Failed to create knowledge: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch knowledge: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update knowledge: \(error.localizedDescription)"
        case .deletionFailed(let error):
            return "Failed to delete knowledge: \(error.localizedDescription)"
        case .notFound(let id):
            return "Knowledge with ID \(id) not found"
        case .invalidConnection:
            return "Invalid connection: one or both entities not found"
        case .connectionFailed(let error):
            return "Failed to create connection: \(error.localizedDescription)"
        }
    }
}
