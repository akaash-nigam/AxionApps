//
//  OpportunityTests.swift
//  SpatialCRMTests
//
//  Unit tests for Opportunity model
//

import Testing
import Foundation
@testable import SpatialCRM

@Suite("Opportunity Model Tests")
struct OpportunityTests {

    @Test("Opportunity initialization")
    func testOpportunityInitialization() {
        let opp = Opportunity(
            name: "Enterprise Deal",
            amount: 500_000,
            stage: .negotiation,
            probability: 75.0,
            status: .active
        )

        #expect(opp.name == "Enterprise Deal")
        #expect(opp.amount == 500_000)
        #expect(opp.stage == .negotiation)
        #expect(opp.probability == 75.0)
        #expect(opp.status == .active)
    }

    @Test("Opportunity stage progression")
    func testStageProgression() {
        let opp = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            stage: .qualification
        )

        #expect(opp.stage == .qualification)

        opp.progress(to: .needsAnalysis)
        #expect(opp.stage == .needsAnalysis)
        #expect(opp.probability == DealStage.needsAnalysis.typicalProbability)
    }

    @Test("Opportunity close won")
    func testCloseWon() {
        let opp = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            stage: .negotiation
        )

        opp.close(won: true)

        #expect(opp.stage == .closedWon)
        #expect(opp.status == .won)
        #expect(opp.probability == 100)
        #expect(opp.closeDate != nil)
    }

    @Test("Opportunity close lost")
    func testCloseLost() {
        let opp = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            stage: .proposal
        )

        opp.close(won: false)

        #expect(opp.stage == .closedLost)
        #expect(opp.status == .lost)
        #expect(opp.probability == 0)
        #expect(opp.closeDate != nil)
    }

    @Test("Days to close calculation")
    func testDaysToClose() {
        let futureDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days
        let opp = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            expectedCloseDate: futureDate
        )

        let days = opp.daysToClose
        #expect(days >= 29 && days <= 31) // Allow for minor timing differences
    }

    @Test("Overdue opportunity detection")
    func testOverdueDetection() {
        let pastDate = Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7 days ago
        let opp = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            expectedCloseDate: pastDate,
            status: .active
        )

        #expect(opp.isOverdue == true)
    }

    @Test("Not overdue when closed")
    func testNotOverdueWhenClosed() {
        let pastDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let opp = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            expectedCloseDate: pastDate,
            status: .won
        )

        #expect(opp.isOverdue == false)
    }

    @Test("Deal stage display names")
    func testStageDisplayNames() {
        #expect(DealStage.prospecting.displayName == "Prospecting")
        #expect(DealStage.qualification.displayName == "Qualification")
        #expect(DealStage.needsAnalysis.displayName == "Needs Analysis")
        #expect(DealStage.proposal.displayName == "Proposal")
        #expect(DealStage.negotiation.displayName == "Negotiation")
        #expect(DealStage.closedWon.displayName == "Closed Won")
        #expect(DealStage.closedLost.displayName == "Closed Lost")
    }

    @Test("Deal stage typical probabilities")
    func testStageTypicalProbabilities() {
        #expect(DealStage.prospecting.typicalProbability == 10)
        #expect(DealStage.qualification.typicalProbability == 25)
        #expect(DealStage.needsAnalysis.typicalProbability == 40)
        #expect(DealStage.proposal.typicalProbability == 60)
        #expect(DealStage.negotiation.typicalProbability == 80)
        #expect(DealStage.closedWon.typicalProbability == 100)
        #expect(DealStage.closedLost.typicalProbability == 0)
    }

    @Test("Pipeline position property")
    func testPipelinePosition() {
        let opp = Opportunity(name: "Test Deal", amount: 100_000)
        opp.pipelinePositionX = 1.0
        opp.pipelinePositionY = 2.0
        opp.pipelinePositionZ = 3.0

        let position = opp.pipelinePosition
        #expect(position.x == 1.0)
        #expect(position.y == 2.0)
        #expect(position.z == 3.0)
    }

    @Test("Opportunity sample data")
    func testSampleData() {
        let sample = Opportunity.sample

        #expect(sample.amount > 0)
        #expect(sample.aiScore >= 0 && sample.aiScore <= 100)
        #expect(!sample.riskFactors.isEmpty)
        #expect(!sample.suggestedActions.isEmpty)
    }
}
