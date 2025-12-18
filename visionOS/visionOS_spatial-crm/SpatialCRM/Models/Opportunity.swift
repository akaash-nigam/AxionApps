//
//  Opportunity.swift
//  SpatialCRM
//
//  Opportunity/Deal data model
//

import Foundation
import SwiftData

@Model
final class Opportunity {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Decimal
    var stage: DealStage
    var probability: Double
    var expectedCloseDate: Date
    var closeDate: Date?
    var status: OpportunityStatus
    var type: DealType
    var description: String?

    // AI-Powered Fields
    var aiScore: Double
    var riskFactors: [String]
    var suggestedActions: [String]
    var velocity: Double  // Days to move between stages

    // Spatial Properties
    var pipelinePositionX: Float
    var pipelinePositionY: Float
    var pipelinePositionZ: Float
    var visualScale: Float

    // Relationships
    var account: Account?
    @Relationship(deleteRule: .nullify) var contacts: [Contact]
    @Relationship(deleteRule: .cascade) var activities: [Activity]
    @Relationship(deleteRule: .nullify) var competitors: [Competitor]
    var owner: SalesRep?

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastStageChangeAt: Date?
    var externalId: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        amount: Decimal,
        stage: DealStage = .prospecting,
        probability: Double = 10.0,
        expectedCloseDate: Date = Date().addingTimeInterval(60 * 24 * 60 * 60), // 60 days
        status: OpportunityStatus = .active,
        type: DealType = .newBusiness
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.stage = stage
        self.probability = probability
        self.expectedCloseDate = expectedCloseDate
        self.status = status
        self.type = type

        // Initialize AI fields
        self.aiScore = 50.0
        self.riskFactors = []
        self.suggestedActions = []
        self.velocity = 0

        // Initialize spatial properties
        self.pipelinePositionX = 0
        self.pipelinePositionY = Float(stage.rawValue)
        self.pipelinePositionZ = 0
        self.visualScale = 1.0

        // Initialize relationships
        self.contacts = []
        self.activities = []
        self.competitors = []

        // Set timestamps
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastStageChangeAt = Date()
    }

    // MARK: - Methods

    func progress(to newStage: DealStage) {
        stage = newStage
        lastStageChangeAt = Date()
        updatedAt = Date()

        // Update probability based on stage
        probability = newStage.typicalProbability

        // Update spatial position
        pipelinePositionY = Float(newStage.rawValue)

        // Log activity
        // Activities would be added here
    }

    func close(won: Bool) {
        if won {
            stage = .closedWon
            status = .won
            probability = 100
        } else {
            stage = .closedLost
            status = .lost
            probability = 0
        }
        closeDate = Date()
        updatedAt = Date()
    }

    // MARK: - Computed Properties

    var pipelinePosition: SIMD3<Float> {
        get { SIMD3(pipelinePositionX, pipelinePositionY, pipelinePositionZ) }
        set {
            pipelinePositionX = newValue.x
            pipelinePositionY = newValue.y
            pipelinePositionZ = newValue.z
        }
    }

    var daysToClose: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expectedCloseDate)
        return components.day ?? 0
    }

    var isOverdue: Bool {
        status == .active && expectedCloseDate < Date()
    }
}

// MARK: - Supporting Types

enum DealStage: Int, Codable, CaseIterable {
    case prospecting = 0
    case qualification = 1
    case needsAnalysis = 2
    case proposal = 3
    case negotiation = 4
    case closedWon = 5
    case closedLost = 6

    var displayName: String {
        switch self {
        case .prospecting: return "Prospecting"
        case .qualification: return "Qualification"
        case .needsAnalysis: return "Needs Analysis"
        case .proposal: return "Proposal"
        case .negotiation: return "Negotiation"
        case .closedWon: return "Closed Won"
        case .closedLost: return "Closed Lost"
        }
    }

    var typicalProbability: Double {
        switch self {
        case .prospecting: return 10
        case .qualification: return 25
        case .needsAnalysis: return 40
        case .proposal: return 60
        case .negotiation: return 80
        case .closedWon: return 100
        case .closedLost: return 0
        }
    }
}

enum OpportunityStatus: String, Codable {
    case active
    case won
    case lost
    case onHold
}

enum DealType: String, Codable {
    case newBusiness
    case existingCustomer
    case renewal
    case upsell
    case crossSell
}

@Model
final class Competitor {
    @Attribute(.unique) var id: UUID
    var name: String
    var strength: Double
    var weaknesses: [String]
    var createdAt: Date

    init(name: String, strength: Double = 50.0) {
        self.id = UUID()
        self.name = name
        self.strength = strength
        self.weaknesses = []
        self.createdAt = Date()
    }
}

// MARK: - Sample Data

extension Opportunity {
    static var sample: Opportunity {
        let opp = Opportunity(
            name: "Acme Corp - Enterprise License",
            amount: 500_000,
            stage: .negotiation,
            probability: 75,
            expectedCloseDate: Date().addingTimeInterval(14 * 24 * 60 * 60), // 14 days
            status: .active,
            type: .newBusiness
        )
        opp.description = "500-user enterprise license with premium support"
        opp.aiScore = 85
        opp.riskFactors = ["Budget approval pending"]
        opp.suggestedActions = ["Schedule CFO meeting", "Prepare ROI analysis"]
        return opp
    }

    static var samples: [Opportunity] {
        [
            Opportunity(name: "Acme Corp - Enterprise License", amount: 500_000, stage: .negotiation, probability: 75, expectedCloseDate: Date().addingTimeInterval(14 * 24 * 60 * 60)),
            Opportunity(name: "TechCo - Annual Subscription", amount: 250_000, stage: .proposal, probability: 60, expectedCloseDate: Date().addingTimeInterval(30 * 24 * 60 * 60)),
            Opportunity(name: "StartupX - Starter Pack", amount: 100_000, stage: .qualification, probability: 25, expectedCloseDate: Date().addingTimeInterval(60 * 24 * 60 * 60)),
            Opportunity(name: "Global Enterprises - Renewal", amount: 750_000, stage: .needsAnalysis, probability: 40, expectedCloseDate: Date().addingTimeInterval(45 * 24 * 60 * 60)),
            Opportunity(name: "MegaCorp - Expansion", amount: 1_000_000, stage: .prospecting, probability: 10, expectedCloseDate: Date().addingTimeInterval(90 * 24 * 60 * 60))
        ]
    }
}
