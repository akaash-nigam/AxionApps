//
//  AIServiceTests.swift
//  SpatialCRMTests
//
//  Unit tests for AI Service
//

import Testing
import Foundation
@testable import SpatialCRM

@Suite("AI Service Tests")
struct AIServiceTests {

    @Test("Opportunity scoring returns valid score")
    func testOpportunityScoringValidRange() async throws {
        let aiService = AIService()
        let opp = Opportunity(
            name: "Test Deal",
            amount: 500_000,
            stage: .negotiation,
            probability: 75
        )

        let score = try await aiService.scoreOpportunity(opp)

        #expect(score.value >= 0 && score.value <= 100)
        #expect(score.confidence >= 0 && score.confidence <= 1)
        #expect(!score.factors.isEmpty)
    }

    @Test("High value deals get higher scores")
    func testHighValueDealScoring() async throws {
        let aiService = AIService()

        let highValueDeal = Opportunity(
            name: "Enterprise Deal",
            amount: 2_000_000,
            stage: .negotiation
        )

        let lowValueDeal = Opportunity(
            name: "Small Deal",
            amount: 50_000,
            stage: .negotiation
        )

        let highScore = try await aiService.scoreOpportunity(highValueDeal)
        let lowScore = try await aiService.scoreOpportunity(lowValueDeal)

        #expect(highScore.value > lowScore.value)
    }

    @Test("Advanced stage deals get higher scores")
    func testStageBasedScoring() async throws {
        let aiService = AIService()

        let lateStage = Opportunity(
            name: "Late Deal",
            amount: 100_000,
            stage: .negotiation
        )

        let earlyStage = Opportunity(
            name: "Early Deal",
            amount: 100_000,
            stage: .prospecting
        )

        let lateScore = try await aiService.scoreOpportunity(lateStage)
        let earlyScore = try await aiService.scoreOpportunity(earlyStage)

        #expect(lateScore.value > earlyScore.value)
    }

    @Test("Churn prediction returns valid risk score")
    func testChurnPredictionValidRange() async throws {
        let aiService = AIService()
        let account = Account(
            name: "Test Corp",
            healthScore: 45.0,
            riskLevel: .high
        )

        let prediction = try await aiService.predictChurnRisk(for: account)

        #expect(prediction.riskScore >= 0 && prediction.riskScore <= 100)
        #expect(prediction.timeframe > 0)
        #expect(!prediction.factors.isEmpty)
        #expect(!prediction.recommendations.isEmpty)
    }

    @Test("Low health score increases churn risk")
    func testLowHealthScoreChurnRisk() async throws {
        let aiService = AIService()

        let unhealthyAccount = Account(
            name: "Unhealthy Corp",
            healthScore: 30.0,
            riskLevel: .high
        )

        let healthyAccount = Account(
            name: "Healthy Corp",
            healthScore: 90.0,
            riskLevel: .low
        )

        let unhealthyPrediction = try await aiService.predictChurnRisk(for: unhealthyAccount)
        let healthyPrediction = try await aiService.predictChurnRisk(for: healthyAccount)

        #expect(unhealthyPrediction.riskScore > healthyPrediction.riskScore)
    }

    @Test("Next actions suggestions are stage appropriate")
    func testNextActionsSuggestions() async throws {
        let aiService = AIService()

        let prospectingOpp = Opportunity(
            name: "Early Deal",
            amount: 100_000,
            stage: .prospecting
        )

        let negotiationOpp = Opportunity(
            name: "Late Deal",
            amount: 100_000,
            stage: .negotiation
        )

        let prospectingActions = try await aiService.suggestNextActions(for: prospectingOpp)
        let negotiationActions = try await aiService.suggestNextActions(for: negotiationOpp)

        #expect(!prospectingActions.isEmpty)
        #expect(!negotiationActions.isEmpty)

        // Actions should be different for different stages
        let prospectingTitles = prospectingActions.map { $0.title }
        let negotiationTitles = negotiationActions.map { $0.title }
        #expect(prospectingTitles != negotiationTitles)
    }

    @Test("Urgent actions for deals closing soon")
    func testUrgentActionsForClosingDeals() async throws {
        let aiService = AIService()

        let closingSoon = Opportunity(
            name: "Urgent Deal",
            amount: 100_000,
            stage: .negotiation,
            expectedCloseDate: Date().addingTimeInterval(3 * 24 * 60 * 60) // 3 days
        )

        let actions = try await aiService.suggestNextActions(for: closingSoon)

        // Should have at least one urgent action
        let hasUrgent = actions.contains { $0.priority == .urgent }
        #expect(hasUrgent == true)
    }

    @Test("Cross-sell opportunities identification")
    func testCrossSellOpportunities() async throws {
        let aiService = AIService()
        let account = Account(name: "Test Corp")

        let products = try await aiService.identifyCrossSellOpportunities(for: account)

        #expect(!products.isEmpty)
        for product in products {
            #expect(product.estimatedValue > 0)
            #expect(product.fitScore >= 0 && product.fitScore <= 1)
        }
    }

    @Test("Stakeholder network analysis")
    func testStakeholderNetworkAnalysis() async throws {
        let aiService = AIService()
        let account = Account(name: "Test Corp")

        // Add some contacts
        let contact1 = Contact(
            firstName: "John",
            lastName: "Doe",
            email: "john@test.com",
            title: "CEO",
            role: .champion,
            influenceScore: 95
        )

        let contact2 = Contact(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@test.com",
            title: "CTO",
            role: .influencer,
            influenceScore: 85
        )

        account.contacts = [contact1, contact2]

        let network = try await aiService.analyzeStakeholderNetwork(for: account)

        #expect(network.nodes.count == 2)
        #expect(network.nodes[0].influence > 0)
    }

    @Test("Decision makers identification")
    func testDecisionMakersIdentification() async throws {
        let aiService = AIService()
        let account = Account(name: "Test Corp")

        let decisionMaker = Contact(
            firstName: "CEO",
            lastName: "Boss",
            email: "ceo@test.com",
            title: "Chief Executive Officer",
            isDecisionMaker: true
        )

        let regularContact = Contact(
            firstName: "Regular",
            lastName: "User",
            email: "user@test.com",
            title: "Analyst",
            isDecisionMaker: false
        )

        account.contacts = [regularContact, decisionMaker]

        let decisionMakers = try await aiService.identifyDecisionMakers(in: account)

        #expect(decisionMakers.count == 1)
        #expect(decisionMakers[0].isDecisionMaker == true)
    }

    @Test("Influence score calculation")
    func testInfluenceScoreCalculation() async throws {
        let aiService = AIService()

        let ceo = Contact(
            firstName: "CEO",
            lastName: "Boss",
            email: "ceo@test.com",
            title: "CEO",
            isDecisionMaker: true
        )

        let score = try await aiService.calculateInfluenceScore(for: ceo)

        #expect(score >= 0 && score <= 100)
        // CEO should have high influence
        #expect(score > 70)
    }

    @Test("Natural language query processing")
    func testNaturalLanguageQuery() async throws {
        let aiService = AIService()

        let result = try await aiService.processNaturalLanguageQuery(
            "show me deals over 500000"
        )

        #expect(!result.intent.isEmpty)
        #expect(result.confidence >= 0 && result.confidence <= 1)
    }
}
