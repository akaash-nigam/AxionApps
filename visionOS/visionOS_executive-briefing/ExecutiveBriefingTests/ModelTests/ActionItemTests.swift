import XCTest
import SwiftData
@testable import ExecutiveBriefing

final class ActionItemTests: XCTestCase {
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([ActionItem.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: configuration)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    func testActionItemInitialization() {
        // Given
        let actionItem = ActionItem(
            role: .ceo,
            title: "Announce AR/VR as strategic priority",
            descriptionText: "Make public announcement"
        )

        // Then
        XCTAssertNotNil(actionItem.id)
        XCTAssertEqual(actionItem.role, .ceo)
        XCTAssertEqual(actionItem.title, "Announce AR/VR as strategic priority")
        XCTAssertFalse(actionItem.completed)
        XCTAssertNil(actionItem.completedDate)
        XCTAssertEqual(actionItem.priority, 5) // Default priority
    }

    func testActionItemMarkComplete() {
        // Given
        let actionItem = ActionItem(
            role: .cfo,
            title: "Develop AR/VR investment thesis",
            descriptionText: "Create detailed investment plan"
        )

        // When
        actionItem.markComplete()

        // Then
        XCTAssertTrue(actionItem.completed)
        XCTAssertNotNil(actionItem.completedDate)
    }

    func testActionItemMarkIncomplete() {
        // Given
        let actionItem = ActionItem(
            role: .cto,
            title: "Assess technical readiness",
            descriptionText: "Evaluate current infrastructure"
        )
        actionItem.markComplete()

        // When
        actionItem.markIncomplete()

        // Then
        XCTAssertFalse(actionItem.completed)
        XCTAssertNil(actionItem.completedDate)
    }

    func testActionItemPriorityLabels() {
        // Test priority labels
        let critical = ActionItem(role: .ceo, title: "Test", descriptionText: "Test", priority: 1)
        let high = ActionItem(role: .ceo, title: "Test", descriptionText: "Test", priority: 2)
        let medium = ActionItem(role: .ceo, title: "Test", descriptionText: "Test", priority: 3)
        let normal = ActionItem(role: .ceo, title: "Test", descriptionText: "Test", priority: 5)
        let low = ActionItem(role: .ceo, title: "Test", descriptionText: "Test", priority: 10)

        XCTAssertEqual(critical.priorityLabel, "Critical")
        XCTAssertEqual(high.priorityLabel, "High")
        XCTAssertEqual(medium.priorityLabel, "Medium")
        XCTAssertEqual(normal.priorityLabel, "Normal")
        XCTAssertEqual(low.priorityLabel, "Low")
    }

    func testActionItemAccessibilityDescription() {
        // Given
        let actionItem = ActionItem(
            role: .cmo,
            title: "Explore customer experiences",
            descriptionText: "Research AR/VR customer touchpoints",
            priority: 2
        )

        // When
        let description = actionItem.accessibilityDescription

        // Then
        XCTAssertTrue(description.contains("Explore customer experiences"))
        XCTAssertTrue(description.contains("CMO"))
        XCTAssertTrue(description.contains("High priority"))
        XCTAssertTrue(description.contains("not completed"))

        // Mark complete and test again
        actionItem.markComplete()
        let completedDescription = actionItem.accessibilityDescription
        XCTAssertTrue(completedDescription.contains("completed"))
    }

    func testExecutiveRoleDisplayNames() {
        XCTAssertEqual(ExecutiveRole.ceo.displayName, "CEO")
        XCTAssertEqual(ExecutiveRole.cfo.displayName, "CFO")
        XCTAssertEqual(ExecutiveRole.cto.displayName, "CTO")
        XCTAssertEqual(ExecutiveRole.cio.displayName, "CIO")
        XCTAssertEqual(ExecutiveRole.chro.displayName, "CHRO")
        XCTAssertEqual(ExecutiveRole.cmo.displayName, "CMO")
        XCTAssertEqual(ExecutiveRole.legal.displayName, "Legal/Risk")
    }

    func testExecutiveRoleIcons() {
        // Verify all roles have icons
        for role in ExecutiveRole.allCases {
            XCTAssertFalse(role.icon.isEmpty)
        }
    }

    func testActionItemPersistence() async throws {
        // Given
        let actionItem = ActionItem(
            role: .ceo,
            title: "Test Action",
            descriptionText: "Test Description"
        )

        // When
        modelContext.insert(actionItem)
        try modelContext.save()

        // Then
        let fetchDescriptor = FetchDescriptor<ActionItem>()
        let fetchedItems = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems.first?.title, "Test Action")
    }
}
