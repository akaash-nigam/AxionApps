import XCTest
import SwiftData
@testable import ExecutiveBriefing

final class DecisionPointTests: XCTestCase {
    func testDecisionPointInitialization() {
        // Given
        let decision = DecisionPoint(
            title: "Platform Strategy",
            question: "Closed ecosystem vs. open standards?",
            recommendation: "Hybrid approach"
        )

        // Then
        XCTAssertNotNil(decision.id)
        XCTAssertEqual(decision.title, "Platform Strategy")
        XCTAssertEqual(decision.question, "Closed ecosystem vs. open standards?")
        XCTAssertEqual(decision.recommendation, "Hybrid approach")
        XCTAssertEqual(decision.priority, 5) // Default
        XCTAssertEqual(decision.impact, 5) // Default
        XCTAssertEqual(decision.feasibility, 5) // Default
    }

    func testNormalizedScores() {
        // Given
        let decision = DecisionPoint(
            title: "Test",
            question: "Test?",
            recommendation: "Test",
            impact: 8,
            feasibility: 6
        )

        // Then
        XCTAssertEqual(decision.normalizedImpact, 0.8)
        XCTAssertEqual(decision.normalizedFeasibility, 0.6)
    }

    func testDecisionQuadrants() {
        // High impact, high feasibility
        let q1 = DecisionPoint(
            title: "Test",
            question: "Test?",
            recommendation: "Test",
            impact: 9,
            feasibility: 8
        )
        XCTAssertEqual(q1.quadrant, .highImpactHighFeasibility)

        // High impact, low feasibility
        let q2 = DecisionPoint(
            title: "Test",
            question: "Test?",
            recommendation: "Test",
            impact: 9,
            feasibility: 3
        )
        XCTAssertEqual(q2.quadrant, .highImpactLowFeasibility)

        // Low impact, high feasibility
        let q3 = DecisionPoint(
            title: "Test",
            question: "Test?",
            recommendation: "Test",
            impact: 3,
            feasibility: 8
        )
        XCTAssertEqual(q3.quadrant, .lowImpactHighFeasibility)

        // Low impact, low feasibility
        let q4 = DecisionPoint(
            title: "Test",
            question: "Test?",
            recommendation: "Test",
            impact: 3,
            feasibility: 3
        )
        XCTAssertEqual(q4.quadrant, .lowImpactLowFeasibility)
    }

    func testDecisionQuadrantLabels() {
        XCTAssertEqual(
            DecisionQuadrant.highImpactHighFeasibility.label,
            "Priority Actions"
        )
        XCTAssertEqual(
            DecisionQuadrant.highImpactLowFeasibility.label,
            "Strategic Investments"
        )
        XCTAssertEqual(
            DecisionQuadrant.lowImpactHighFeasibility.label,
            "Quick Wins"
        )
        XCTAssertEqual(
            DecisionQuadrant.lowImpactLowFeasibility.label,
            "Low Priority"
        )
    }

    func testDecisionOptionInitialization() {
        // Given
        let option = DecisionOption(
            title: "Closed Ecosystem",
            descriptionText: "Use proprietary platform",
            pros: ["Better control", "Integrated experience"],
            cons: ["Vendor lock-in", "Higher cost"]
        )

        // Then
        XCTAssertNotNil(option.id)
        XCTAssertEqual(option.title, "Closed Ecosystem")
        XCTAssertEqual(option.pros.count, 2)
        XCTAssertEqual(option.cons.count, 2)
    }

    func testDecisionWithOptions() {
        // Given
        let option1 = DecisionOption(
            title: "Option A",
            descriptionText: "First option"
        )
        let option2 = DecisionOption(
            title: "Option B",
            descriptionText: "Second option"
        )

        let decision = DecisionPoint(
            title: "Test Decision",
            question: "Which option?",
            options: [option1, option2],
            recommendation: "Option A"
        )

        // Then
        XCTAssertEqual(decision.options.count, 2)
    }
}
