import Testing
import SwiftData
@testable import ConstructionSiteManager

@Suite("IssueViewModel Tests")
struct IssueViewModelTests {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let viewModel: IssueViewModel

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Issue.self, TeamMember.self, Comment.self,
            configurations: config
        )
        modelContext = modelContainer.mainContext
        viewModel = IssueViewModel(modelContext: modelContext)
    }

    @Test("Create new issue")
    func testCreateIssue() throws {
        // Arrange
        let title = "Foundation Crack"
        let description = "Visible crack in foundation slab"
        let category: IssueCategory = .quality
        let priority: IssuePriority = .high
        let dueDate = Date().addingTimeInterval(86400 * 7)

        // Act
        try viewModel.createIssue(
            title: title,
            description: description,
            category: category,
            priority: priority,
            dueDate: dueDate
        )

        // Assert
        #expect(viewModel.issues.count == 1)

        let issue = viewModel.issues.first!
        #expect(issue.title == title)
        #expect(issue.description == description)
        #expect(issue.category == category)
        #expect(issue.priority == priority)
        #expect(issue.status == .open)
    }

    @Test("Add comment to issue")
    func testAddComment() throws {
        // Arrange
        let issue = Issue(
            title: "Test Issue",
            description: "Description",
            category: .safety,
            priority: .medium,
            status: .open,
            dueDate: Date()
        )
        modelContext.insert(issue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        try viewModel.addComment(to: issue, text: "This needs immediate attention", author: "John Doe")

        // Assert
        #expect(issue.comments.count == 1)
        #expect(issue.comments.first?.text == "This needs immediate attention")
        #expect(issue.comments.first?.author == "John Doe")
    }

    @Test("Resolve issue")
    func testResolveIssue() throws {
        // Arrange
        let issue = Issue(
            title: "Test Issue",
            description: "Description",
            category: .safety,
            priority: .medium,
            status: .open,
            dueDate: Date()
        )
        modelContext.insert(issue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        try viewModel.resolveIssue(issue)

        // Assert
        #expect(issue.status == .resolved)
        #expect(issue.resolvedDate != nil)
    }

    @Test("Reopen issue")
    func testReopenIssue() throws {
        // Arrange
        let issue = Issue(
            title: "Test Issue",
            description: "Description",
            category: .safety,
            priority: .medium,
            status: .resolved,
            dueDate: Date()
        )
        issue.resolvedDate = Date()
        modelContext.insert(issue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        try viewModel.reopenIssue(issue)

        // Assert
        #expect(issue.status == .open)
        #expect(issue.resolvedDate == nil)
    }

    @Test("Assign issue to team member")
    func testAssignIssue() throws {
        // Arrange
        let issue = Issue(
            title: "Test Issue",
            description: "Description",
            category: .safety,
            priority: .medium,
            status: .open,
            dueDate: Date()
        )

        let member = TeamMember(
            name: "Jane Smith",
            role: .siteEngineer,
            email: "jane@example.com",
            phoneNumber: "555-0100",
            company: "ABC Construction"
        )

        modelContext.insert(issue)
        modelContext.insert(member)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        try viewModel.assignIssue(issue, to: member)

        // Assert
        #expect(issue.assignee?.id == member.id)
        #expect(issue.assignee?.name == "Jane Smith")
    }

    @Test("Update priority")
    func testUpdatePriority() throws {
        // Arrange
        let issue = Issue(
            title: "Test Issue",
            description: "Description",
            category: .safety,
            priority: .low,
            status: .open,
            dueDate: Date()
        )
        modelContext.insert(issue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        try viewModel.updatePriority(issue, to: .critical)

        // Assert
        #expect(issue.priority == .critical)
    }

    @Test("Filter by priority")
    func testFilterByPriority() throws {
        // Arrange
        let criticalIssue = Issue(
            title: "Critical Issue",
            description: "Critical",
            category: .safety,
            priority: .critical,
            status: .open,
            dueDate: Date()
        )

        let lowIssue = Issue(
            title: "Low Issue",
            description: "Low",
            category: .quality,
            priority: .low,
            status: .open,
            dueDate: Date()
        )

        modelContext.insert(criticalIssue)
        modelContext.insert(lowIssue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        viewModel.filterPriority = .critical
        let filtered = viewModel.filteredIssues()

        // Assert
        #expect(filtered.count == 1)
        #expect(filtered.first?.priority == .critical)
    }

    @Test("Filter by status")
    func testFilterByStatus() throws {
        // Arrange
        let openIssue = Issue(
            title: "Open Issue",
            description: "Open",
            category: .safety,
            priority: .medium,
            status: .open,
            dueDate: Date()
        )

        let resolvedIssue = Issue(
            title: "Resolved Issue",
            description: "Resolved",
            category: .quality,
            priority: .medium,
            status: .resolved,
            dueDate: Date()
        )

        modelContext.insert(openIssue)
        modelContext.insert(resolvedIssue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        viewModel.filterStatus = .resolved
        let filtered = viewModel.filteredIssues()

        // Assert
        #expect(filtered.count == 1)
        #expect(filtered.first?.status == .resolved)
    }

    @Test("Show only overdue issues")
    func testShowOnlyOverdue() throws {
        // Arrange
        let overdueIssue = Issue(
            title: "Overdue Issue",
            description: "Overdue",
            category: .safety,
            priority: .high,
            status: .open,
            dueDate: Date().addingTimeInterval(-86400) // Yesterday
        )

        let upcomingIssue = Issue(
            title: "Upcoming Issue",
            description: "Upcoming",
            category: .quality,
            priority: .medium,
            status: .open,
            dueDate: Date().addingTimeInterval(86400) // Tomorrow
        )

        modelContext.insert(overdueIssue)
        modelContext.insert(upcomingIssue)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        viewModel.showOnlyOverdue = true
        let filtered = viewModel.filteredIssues()

        // Assert
        #expect(filtered.count == 1)
        #expect(filtered.first?.isOverdue == true)
    }

    @Test("Get upcoming issues")
    func testGetUpcomingIssues() throws {
        // Arrange
        let soon = Issue(
            title: "Due Soon",
            description: "Soon",
            category: .safety,
            priority: .high,
            status: .open,
            dueDate: Date().addingTimeInterval(86400 * 3) // 3 days
        )

        let later = Issue(
            title: "Due Later",
            description: "Later",
            category: .quality,
            priority: .medium,
            status: .open,
            dueDate: Date().addingTimeInterval(86400 * 30) // 30 days
        )

        modelContext.insert(soon)
        modelContext.insert(later)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        let upcoming = viewModel.getUpcomingIssues(within: 7)

        // Assert
        #expect(upcoming.count == 1)
        #expect(upcoming.first?.title == "Due Soon")
    }

    @Test("Get statistics")
    func testGetStatistics() throws {
        // Arrange
        let issues = [
            Issue(title: "Open 1", description: "D", category: .safety, priority: .critical, status: .open, dueDate: Date()),
            Issue(title: "In Progress", description: "D", category: .quality, priority: .high, status: .inProgress, dueDate: Date()),
            Issue(title: "Resolved", description: "D", category: .schedule, priority: .medium, status: .resolved, dueDate: Date()),
            Issue(title: "Overdue", description: "D", category: .safety, priority: .high, status: .open, dueDate: Date().addingTimeInterval(-86400))
        ]

        for issue in issues {
            modelContext.insert(issue)
        }
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        let stats = viewModel.getStatistics()

        // Assert
        #expect(stats.total == 4)
        #expect(stats.open == 2) // "Open 1" and "Overdue"
        #expect(stats.inProgress == 1)
        #expect(stats.resolved == 1)
        #expect(stats.overdue == 1)
        #expect(stats.critical == 1)
        #expect(stats.high == 2)
        #expect(stats.safetyIssues == 2)
    }

    @Test("Search issues by text")
    func testSearchIssues() throws {
        // Arrange
        let issue1 = Issue(
            title: "Foundation Crack",
            description: "Visible crack in concrete",
            category: .quality,
            priority: .high,
            status: .open,
            dueDate: Date()
        )

        let issue2 = Issue(
            title: "Safety Violation",
            description: "Missing guardrails",
            category: .safety,
            priority: .critical,
            status: .open,
            dueDate: Date()
        )

        modelContext.insert(issue1)
        modelContext.insert(issue2)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        viewModel.searchText = "Foundation"
        let filtered = viewModel.filteredIssues()

        // Assert
        #expect(filtered.count == 1)
        #expect(filtered.first?.title == "Foundation Crack")
    }

    @Test("Sort by due date")
    func testSortByDueDate() throws {
        // Arrange
        let later = Issue(
            title: "Later",
            description: "D",
            category: .quality,
            priority: .medium,
            status: .open,
            dueDate: Date().addingTimeInterval(86400 * 7)
        )

        let sooner = Issue(
            title: "Sooner",
            description: "D",
            category: .safety,
            priority: .high,
            status: .open,
            dueDate: Date().addingTimeInterval(86400 * 3)
        )

        modelContext.insert(later)
        modelContext.insert(sooner)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        viewModel.sortOrder = .dueDate
        let sorted = viewModel.filteredIssues()

        // Assert
        #expect(sorted[0].title == "Sooner")
        #expect(sorted[1].title == "Later")
    }

    @Test("Sort by priority")
    func testSortByPriority() throws {
        // Arrange
        let low = Issue(
            title: "Low Priority",
            description: "D",
            category: .quality,
            priority: .low,
            status: .open,
            dueDate: Date()
        )

        let critical = Issue(
            title: "Critical Priority",
            description: "D",
            category: .safety,
            priority: .critical,
            status: .open,
            dueDate: Date()
        )

        modelContext.insert(low)
        modelContext.insert(critical)
        try modelContext.save()

        viewModel.loadIssues()

        // Act
        viewModel.sortOrder = .priority
        let sorted = viewModel.filteredIssues()

        // Assert
        #expect(sorted[0].title == "Critical Priority")
        #expect(sorted[1].title == "Low Priority")
    }
}
