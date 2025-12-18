import XCTest
import SwiftData
@testable import ExecutiveBriefing

final class InvestmentPhaseTests: XCTestCase {
    func testInvestmentPhaseInitialization() {
        // Given
        let phase = InvestmentPhase(
            name: "Foundation",
            timeline: "Q1-Q2 2025",
            budgetMin: 2000,
            budgetMax: 5000
        )

        // Then
        XCTAssertNotNil(phase.id)
        XCTAssertEqual(phase.name, "Foundation")
        XCTAssertEqual(phase.timeline, "Q1-Q2 2025")
        XCTAssertEqual(phase.budgetMin, 2000)
        XCTAssertEqual(phase.budgetMax, 5000)
        XCTAssertTrue(phase.checklist.isEmpty)
    }

    func testBudgetRange() {
        // Given
        let phase = InvestmentPhase(
            name: "Scaling",
            timeline: "Q3-Q4 2025",
            budgetMin: 5000,
            budgetMax: 15000
        )

        // Then
        XCTAssertEqual(phase.budgetRange, "$5000K-$15000K")
    }

    func testBudgetMidpoint() {
        // Given
        let phase = InvestmentPhase(
            name: "Foundation",
            timeline: "Q1-Q2 2025",
            budgetMin: 2000,
            budgetMax: 5000
        )

        // Then
        XCTAssertEqual(phase.budgetMidpoint, 3500)
    }

    func testCompletionPercentage() {
        // Given
        let item1 = ChecklistItem(task: "Task 1", completed: true)
        let item2 = ChecklistItem(task: "Task 2", completed: true)
        let item3 = ChecklistItem(task: "Task 3", completed: false)
        let item4 = ChecklistItem(task: "Task 4", completed: false)

        let phase = InvestmentPhase(
            name: "Test",
            timeline: "Q1",
            budgetMin: 1000,
            budgetMax: 2000,
            checklist: [item1, item2, item3, item4]
        )

        // Then
        XCTAssertEqual(phase.completionPercentage, 50.0)
    }

    func testIsComplete() {
        // Test incomplete phase
        let incompletePhase = InvestmentPhase(
            name: "Test",
            timeline: "Q1",
            budgetMin: 1000,
            budgetMax: 2000,
            checklist: [
                ChecklistItem(task: "Task 1", completed: true),
                ChecklistItem(task: "Task 2", completed: false)
            ]
        )
        XCTAssertFalse(incompletePhase.isComplete)

        // Test complete phase
        let completePhase = InvestmentPhase(
            name: "Test",
            timeline: "Q1",
            budgetMin: 1000,
            budgetMax: 2000,
            checklist: [
                ChecklistItem(task: "Task 1", completed: true),
                ChecklistItem(task: "Task 2", completed: true)
            ]
        )
        XCTAssertTrue(completePhase.isComplete)

        // Test empty checklist
        let emptyPhase = InvestmentPhase(
            name: "Test",
            timeline: "Q1",
            budgetMin: 1000,
            budgetMax: 2000
        )
        XCTAssertFalse(emptyPhase.isComplete)
    }

    func testChecklistItemInitialization() {
        // Given
        let item = ChecklistItem(
            task: "Launch 3-5 pilot programs",
            completed: false
        )

        // Then
        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.task, "Launch 3-5 pilot programs")
        XCTAssertFalse(item.completed)
        XCTAssertNil(item.assignee)
        XCTAssertNil(item.dueDate)
        XCTAssertEqual(item.priority, 5) // Default
    }

    func testChecklistItemWithAllProperties() {
        // Given
        let dueDate = Date()
        let item = ChecklistItem(
            task: "Test task",
            completed: true,
            assignee: "John Doe",
            dueDate: dueDate,
            priority: 1
        )

        // Then
        XCTAssertTrue(item.completed)
        XCTAssertEqual(item.assignee, "John Doe")
        XCTAssertEqual(item.dueDate, dueDate)
        XCTAssertEqual(item.priority, 1)
    }
}
