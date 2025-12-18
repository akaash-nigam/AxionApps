import SwiftUI
import SwiftData
import Observation

/// ViewModel for issue management and tracking
/// Handles issue CRUD operations, filtering, and notifications
@MainActor
@Observable
final class IssueViewModel {
    // MARK: - Properties

    private(set) var issues: [Issue] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var selectedIssue: Issue?
    var filterPriority: IssuePriority?
    var filterStatus: IssueStatus?
    var filterCategory: IssueCategory?
    var filterAssignee: TeamMember?
    var searchText = ""
    var showOnlyOverdue = false
    var sortOrder: SortOrder = .dueDate

    enum SortOrder {
        case dueDate, priority, createdDate, status
    }

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let syncService: SyncService

    // MARK: - Initialization

    init(modelContext: ModelContext, syncService: SyncService = .shared) {
        self.modelContext = modelContext
        self.syncService = syncService
    }

    // MARK: - Public Methods

    /// Load all issues from database
    func loadIssues() {
        isLoading = true
        errorMessage = nil

        do {
            let descriptor = FetchDescriptor<Issue>(
                sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
            )
            issues = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load issues: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Create a new issue
    func createIssue(
        title: String,
        description: String,
        category: IssueCategory,
        priority: IssuePriority,
        dueDate: Date,
        assignedTo: String = "",
        position: SIMD3<Float>? = nil,
        relatedElementIDs: [String] = []
    ) throws {
        let issue = Issue(
            title: title,
            description: description,
            type: category,
            priority: priority,
            status: .open,
            assignedTo: assignedTo,
            reporter: "Current User", // TODO: Get from auth service
            dueDate: dueDate
        )

        if let pos = position {
            issue.positionX = pos.x
            issue.positionY = pos.y
            issue.positionZ = pos.z
        }
        issue.relatedElementIDs = relatedElementIDs

        modelContext.insert(issue)
        try modelContext.save()

        // Queue for sync
        syncService.queueChange(Change(type: .create, entityType: "Issue", entityId: issue.id))

        issues.append(issue)
    }

    /// Update an existing issue
    func updateIssue(_ issue: Issue) throws {
        try modelContext.save()

        // Queue for sync
        syncService.queueChange(Change(type: .update, entityType: "Issue", entityId: issue.id))
    }

    /// Delete an issue
    func deleteIssue(_ issue: Issue) throws {
        let issueId = issue.id
        modelContext.delete(issue)
        try modelContext.save()

        // Queue for sync
        syncService.queueChange(Change(type: .delete, entityType: "Issue", entityId: issueId))

        issues.removeAll { $0.id == issueId }
        if selectedIssue?.id == issueId {
            selectedIssue = nil
        }
    }

    /// Add comment to issue
    func addComment(to issue: Issue, text: String, author: String) throws {
        let comment = IssueComment(
            text: text,
            author: author,
            timestamp: Date()
        )

        issue.comments.append(comment)
        try modelContext.save()
    }

    /// Resolve an issue
    func resolveIssue(_ issue: Issue) throws {
        issue.status = .resolved
        issue.resolvedDate = Date()
        try modelContext.save()
    }

    /// Reopen an issue
    func reopenIssue(_ issue: Issue) throws {
        issue.status = .open
        issue.resolvedDate = nil
        try modelContext.save()
    }

    /// Assign issue to team member
    func assignIssue(_ issue: Issue, to memberName: String) throws {
        issue.assignedTo = memberName
        try modelContext.save()
    }

    /// Update issue priority
    func updatePriority(_ issue: Issue, to priority: IssuePriority) throws {
        issue.priority = priority
        try modelContext.save()
    }

    /// Filter issues based on current criteria
    func filteredIssues() -> [Issue] {
        var filtered = issues

        // Apply priority filter
        if let priority = filterPriority {
            filtered = filtered.filter { $0.priority == priority }
        }

        // Apply status filter
        if let status = filterStatus {
            filtered = filtered.filter { $0.status == status }
        }

        // Apply category filter
        if let category = filterCategory {
            filtered = filtered.filter { $0.type == category }
        }

        // Apply assignee filter
        if let assignee = filterAssignee {
            filtered = filtered.filter { $0.assignedTo == assignee.name }
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.issueDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply overdue filter
        if showOnlyOverdue {
            filtered = filtered.filter { $0.isOverdue }
        }

        // Apply sorting
        switch sortOrder {
        case .dueDate:
            filtered.sort { $0.dueDate < $1.dueDate }
        case .priority:
            filtered.sort { $0.priority > $1.priority }
        case .createdDate:
            filtered.sort { $0.createdDate > $1.createdDate }
        case .status:
            filtered.sort { $0.status.rawValue < $1.status.rawValue }
        }

        return filtered
    }

    /// Get issue statistics
    func getStatistics() -> IssueStatistics {
        let total = issues.count
        let open = issues.filter { $0.status == .open }.count
        let inProgress = issues.filter { $0.status == .inProgress }.count
        let resolved = issues.filter { $0.status == .resolved }.count
        let overdue = issues.filter { $0.isOverdue }.count

        let byPriority = Dictionary(grouping: issues) { $0.priority }
        let byCategory = Dictionary(grouping: issues) { $0.type }

        return IssueStatistics(
            total: total,
            open: open,
            inProgress: inProgress,
            resolved: resolved,
            overdue: overdue,
            critical: byPriority[.critical]?.count ?? 0,
            high: byPriority[.high]?.count ?? 0,
            medium: byPriority[.medium]?.count ?? 0,
            low: byPriority[.low]?.count ?? 0,
            safetyIssues: byCategory[.safety]?.count ?? 0,
            qualityIssues: byCategory[.quality]?.count ?? 0
        )
    }

    /// Get issues nearing due date
    func getUpcomingIssues(within days: Int = 7) -> [Issue] {
        let threshold = Date().addingTimeInterval(TimeInterval(days * 86400))
        return issues.filter { issue in
            issue.status != .resolved &&
            issue.dueDate <= threshold &&
            issue.dueDate >= Date()
        }.sorted { $0.dueDate < $1.dueDate }
    }

    /// Get issues by location proximity
    func getIssuesNearby(position: SIMD3<Float>, radius: Float = 10.0) -> [Issue] {
        issues.filter { issue in
            guard let issuePos = issue.position else { return false }
            let distance = simd_distance(position, issuePos)
            return distance <= radius
        }
    }

    /// Export issues report
    func exportReport(format: ExportFormat) -> Data? {
        // TODO: Generate report in specified format
        return nil
    }
}

// MARK: - Supporting Types

struct IssueStatistics {
    let total: Int
    let open: Int
    let inProgress: Int
    let resolved: Int
    let overdue: Int
    let critical: Int
    let high: Int
    let medium: Int
    let low: Int
    let safetyIssues: Int
    let qualityIssues: Int

    var resolutionRate: Double {
        guard total > 0 else { return 0.0 }
        return Double(resolved) / Double(total)
    }

    var criticalPercentage: Double {
        guard total > 0 else { return 0.0 }
        return Double(critical) / Double(total) * 100
    }
}

enum ExportFormat {
    case pdf, csv, json
}
