import Foundation
import SwiftData
import OSLog

/// Service for managing briefing content
actor BriefingContentService {
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExecutiveBriefing", category: "ContentService")

    enum ServiceError: Error, LocalizedError {
        case notFound
        case fetchFailed(Error)
        case saveFailed(Error)

        var errorDescription: String? {
            switch self {
            case .notFound:
                return "Content not found"
            case .fetchFailed(let error):
                return "Failed to fetch content: \(error.localizedDescription)"
            case .saveFailed(let error):
                return "Failed to save: \(error.localizedDescription)"
            }
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Briefing Sections

    /// Load all briefing sections ordered by section order
    func loadBriefing() async throws -> [BriefingSection] {
        logger.info("Loading briefing sections...")

        do {
            let descriptor = FetchDescriptor<BriefingSection>(
                sortBy: [SortDescriptor(\.order)]
            )
            let sections = try modelContext.fetch(descriptor)

            logger.info("Loaded \(sections.count) sections")
            return sections
        } catch {
            logger.error("Failed to load briefing: \(error.localizedDescription)")
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Get a specific section by ID
    func getSection(id: UUID) async throws -> BriefingSection? {
        do {
            let descriptor = FetchDescriptor<BriefingSection>(
                predicate: #Predicate { $0.id == id }
            )
            return try modelContext.fetch(descriptor).first
        } catch {
            logger.error("Failed to fetch section: \(error.localizedDescription)")
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Search content across all sections
    func searchContent(query: String) async throws -> [SearchResult] {
        logger.info("Searching for: \(query)")

        let sections = try await loadBriefing()
        var results: [SearchResult] = []

        let lowercasedQuery = query.lowercased()

        for section in sections {
            // Search in section title
            if section.title.lowercased().contains(lowercasedQuery) {
                results.append(SearchResult(
                    section: section,
                    contentBlock: nil,
                    matchType: .title
                ))
            }

            // Search in content blocks
            for block in section.content {
                if block.content.lowercased().contains(lowercasedQuery) {
                    results.append(SearchResult(
                        section: section,
                        contentBlock: block,
                        matchType: .content
                    ))
                }
            }
        }

        logger.info("Found \(results.count) results")
        return results
    }

    // MARK: - Use Cases

    /// Load all use cases ordered by order field
    func loadUseCases() async throws -> [UseCase] {
        do {
            let descriptor = FetchDescriptor<UseCase>(
                sortBy: [SortDescriptor(\.order)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Get top N use cases by ROI
    func getTopUseCasesByROI(limit: Int = 10) async throws -> [UseCase] {
        do {
            let descriptor = FetchDescriptor<UseCase>(
                sortBy: [SortDescriptor(\.roi, order: .reverse)]
            )
            let allCases = try modelContext.fetch(descriptor)
            return Array(allCases.prefix(limit))
        } catch {
            throw ServiceError.fetchFailed(error)
        }
    }

    // MARK: - Action Items

    /// Load action items for a specific role
    func getActionItems(for role: ExecutiveRole) async throws -> [ActionItem] {
        do {
            let descriptor = FetchDescriptor<ActionItem>(
                predicate: #Predicate { $0.role == role },
                sortBy: [SortDescriptor(\.priority), SortDescriptor(\.order)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Load all action items
    func getAllActionItems() async throws -> [ActionItem] {
        do {
            let descriptor = FetchDescriptor<ActionItem>(
                sortBy: [SortDescriptor(\.role.rawValue), SortDescriptor(\.order)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Toggle action item completion status
    func toggleActionItem(_ item: ActionItem) async throws {
        if item.completed {
            item.markIncomplete()
        } else {
            item.markComplete()
        }

        do {
            try modelContext.save()
            logger.info("Toggled action item: \(item.title)")
        } catch {
            throw ServiceError.saveFailed(error)
        }
    }

    // MARK: - Investment Phases

    /// Load all investment phases
    func getInvestmentPhases() async throws -> [InvestmentPhase] {
        do {
            let descriptor = FetchDescriptor<InvestmentPhase>(
                sortBy: [SortDescriptor(\.order)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Toggle checklist item completion
    func toggleChecklistItem(_ item: ChecklistItem) async throws {
        item.completed.toggle()

        do {
            try modelContext.save()
            logger.info("Toggled checklist item: \(item.task)")
        } catch {
            throw ServiceError.saveFailed(error)
        }
    }

    // MARK: - Progress Tracking

    /// Get or create user progress
    func getUserProgress() async throws -> UserProgress {
        do {
            let descriptor = FetchDescriptor<UserProgress>()
            if let existing = try modelContext.fetch(descriptor).first {
                return existing
            } else {
                // Create new progress
                let progress = UserProgress()
                modelContext.insert(progress)
                try modelContext.save()
                return progress
            }
        } catch {
            throw ServiceError.fetchFailed(error)
        }
    }

    /// Record section visit
    func recordSectionVisit(_ sectionId: UUID) async throws {
        let progress = try await getUserProgress()
        progress.visitSection(sectionId)

        do {
            try modelContext.save()
        } catch {
            throw ServiceError.saveFailed(error)
        }
    }

    /// Add time spent in app
    func recordTimeSpent(_ duration: TimeInterval) async throws {
        let progress = try await getUserProgress()
        progress.addTimeSpent(duration)

        do {
            try modelContext.save()
        } catch {
            throw ServiceError.saveFailed(error)
        }
    }
}

// MARK: - Supporting Types

/// Search result containing match information
struct SearchResult: Identifiable {
    let id = UUID()
    let section: BriefingSection
    let contentBlock: ContentBlock?
    let matchType: MatchType

    enum MatchType {
        case title
        case content
    }

    var displayText: String {
        switch matchType {
        case .title:
            return section.title
        case .content:
            return contentBlock?.content ?? ""
        }
    }
}
