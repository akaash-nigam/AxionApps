import Foundation
import SwiftData

// MARK: - Innovation Service Protocol
protocol InnovationServiceProtocol {
    func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea
    func updateIdea(_ idea: InnovationIdea) async throws
    func deleteIdea(_ id: UUID) async throws
    func fetchIdeas(filter: IdeaFilter?) async throws -> [InnovationIdea]
    func searchIdeas(query: String) async throws -> [InnovationIdea]
    func fetchIdea(id: UUID) async throws -> InnovationIdea?
}

// MARK: - Innovation Service Implementation
@Observable
final class InnovationService: InnovationServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea {
        modelContext.insert(idea)

        // Create analytics for the idea
        let analytics = IdeaAnalytics()
        analytics.idea = idea
        idea.analytics = analytics
        modelContext.insert(analytics)

        try modelContext.save()

        // Track event
        await AnalyticsService.shared.trackEvent(.ideaCreated(ideaID: idea.id))

        return idea
    }

    func updateIdea(_ idea: InnovationIdea) async throws {
        idea.lastModified = Date()
        try modelContext.save()

        await AnalyticsService.shared.trackEvent(.ideaUpdated(ideaID: idea.id))
    }

    func deleteIdea(_ id: UUID) async throws {
        let descriptor = FetchDescriptor<InnovationIdea>(
            predicate: #Predicate { $0.id == id }
        )

        guard let ideas = try? modelContext.fetch(descriptor),
              let idea = ideas.first else {
            throw ServiceError.notFound
        }

        modelContext.delete(idea)
        try modelContext.save()

        await AnalyticsService.shared.trackEvent(.ideaDeleted(ideaID: id))
    }

    func fetchIdeas(filter: IdeaFilter? = nil) async throws -> [InnovationIdea] {
        var descriptor = FetchDescriptor<InnovationIdea>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )

        if let filter = filter, !filter.isEmpty {
            var predicates: [Predicate<InnovationIdea>] = []

            if let category = filter.category {
                predicates.append(#Predicate { $0.category == category })
            }

            if let status = filter.status {
                predicates.append(#Predicate { $0.status == status })
            }

            if let minPriority = filter.minPriority {
                predicates.append(#Predicate { $0.priority >= minPriority })
            }

            if !predicates.isEmpty {
                descriptor.predicate = predicates.reduce(into: predicates.first!) { result, predicate in
                    // Combine predicates
                }
            }
        }

        return try modelContext.fetch(descriptor)
    }

    func searchIdeas(query: String) async throws -> [InnovationIdea] {
        let descriptor = FetchDescriptor<InnovationIdea>(
            predicate: #Predicate { idea in
                idea.title.localizedStandardContains(query) ||
                idea.ideaDescription.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchIdea(id: UUID) async throws -> InnovationIdea? {
        let descriptor = FetchDescriptor<InnovationIdea>(
            predicate: #Predicate { $0.id == id }
        )

        return try modelContext.fetch(descriptor).first
    }
}

// MARK: - Service Error
enum ServiceError: LocalizedError {
    case notFound
    case invalidData
    case networkError
    case unauthorized
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested resource was not found"
        case .invalidData:
            return "Invalid data provided"
        case .networkError:
            return "Network connection error"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let message):
            return "Server error: \\(message)"
        }
    }
}
