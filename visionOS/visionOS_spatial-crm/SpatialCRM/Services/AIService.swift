//
//  AIService.swift
//  SpatialCRM
//
//  AI-powered intelligence service
//

import Foundation

@Observable
final class AIService {
    // MARK: - Properties

    var isProcessing: Bool = false
    var error: Error?

    private let apiKey: String
    private let baseURL = URL(string: "https://api.openai.com/v1")!

    // MARK: - Initialization

    init(apiKey: String = "your-api-key-here") {
        self.apiKey = apiKey
    }

    // MARK: - Opportunity Intelligence

    func scoreOpportunity(_ opportunity: Opportunity) async throws -> AIScore {
        isProcessing = true
        defer { isProcessing = false }

        // In production, this would call an AI model
        // For now, simple rule-based scoring
        var score: Double = 50.0

        // Factor 1: Deal stage (0-30 points)
        let stageScore: Double = switch opportunity.stage {
        case .prospecting: 5
        case .qualification: 10
        case .needsAnalysis: 15
        case .proposal: 20
        case .negotiation: 25
        case .closedWon: 30
        case .closedLost: 0
        }
        score += stageScore

        // Factor 2: Deal size (0-20 points)
        if opportunity.amount > 1_000_000 {
            score += 20
        } else if opportunity.amount > 500_000 {
            score += 15
        } else if opportunity.amount > 100_000 {
            score += 10
        } else {
            score += 5
        }

        // Factor 3: Time to close (0-20 points)
        let daysToClose = opportunity.daysToClose
        if daysToClose < 30 {
            score += 20
        } else if daysToClose < 60 {
            score += 15
        } else if daysToClose < 90 {
            score += 10
        } else {
            score += 5
        }

        // Factor 4: Account health (0-15 points)
        if let account = opportunity.account {
            score += account.healthScore * 0.15
        }

        // Factor 5: Recent activity (0-15 points)
        let recentActivities = opportunity.activities.filter {
            guard let completed = $0.completedAt else { return false }
            return completed > Date().addingTimeInterval(-7 * 24 * 60 * 60) // Last 7 days
        }
        score += min(Double(recentActivities.count) * 3, 15)

        let finalScore = min(max(score, 0), 100)

        return AIScore(
            value: finalScore,
            confidence: 0.85,
            factors: [
                "Stage: \(opportunity.stage.displayName)",
                "Value: \(opportunity.amount.formatted(.currency(code: "USD")))",
                "Close Date: \(opportunity.daysToClose) days",
                "Recent Activity: \(recentActivities.count) in last 7 days"
            ]
        )
    }

    func predictChurnRisk(for account: Account) async throws -> ChurnPrediction {
        isProcessing = true
        defer { isProcessing = false }

        var riskScore: Double = 0

        // Factor 1: Low health score
        if account.healthScore < 50 {
            riskScore += 30
        } else if account.healthScore < 70 {
            riskScore += 15
        }

        // Factor 2: No recent activity
        let recentActivities = account.activities.filter {
            guard let completed = $0.completedAt else { return false }
            return completed > Date().addingTimeInterval(-30 * 24 * 60 * 60)
        }
        if recentActivities.isEmpty {
            riskScore += 25
        } else if recentActivities.count < 3 {
            riskScore += 10
        }

        // Factor 3: Negative sentiment
        let negativeSentiment = account.activities.filter {
            $0.sentiment == .negative || $0.sentiment == .veryNegative
        }
        riskScore += min(Double(negativeSentiment.count) * 5, 20)

        // Factor 4: No active opportunities
        if account.opportunities.filter({ $0.status == .active }).isEmpty {
            riskScore += 15
        }

        // Factor 5: High risk level
        switch account.riskLevel {
        case .critical:
            riskScore += 20
        case .high:
            riskScore += 10
        case .medium:
            riskScore += 5
        case .low:
            riskScore += 0
        }

        let finalRisk = min(max(riskScore, 0), 100)
        let timeframe = 90 // days

        return ChurnPrediction(
            riskScore: finalRisk,
            timeframe: timeframe,
            factors: [
                "Health Score: \(Int(account.healthScore))",
                "Recent Activity: \(recentActivities.count) in last 30 days",
                "Risk Level: \(account.riskLevel.rawValue.capitalized)"
            ],
            recommendations: generateChurnRecommendations(riskScore: finalRisk, account: account)
        )
    }

    func suggestNextActions(for opportunity: Opportunity) async throws -> [Action] {
        isProcessing = true
        defer { isProcessing = false }

        var actions: [Action] = []

        // Stage-specific suggestions
        switch opportunity.stage {
        case .prospecting:
            actions.append(Action(
                title: "Schedule discovery call",
                priority: .high,
                description: "Set up initial meeting to understand needs",
                estimatedImpact: 0.3
            ))

        case .qualification:
            actions.append(Action(
                title: "Complete BANT qualification",
                priority: .high,
                description: "Validate Budget, Authority, Need, and Timeline",
                estimatedImpact: 0.4
            ))

        case .needsAnalysis:
            actions.append(Action(
                title: "Conduct product demonstration",
                priority: .high,
                description: "Show how solution addresses key pain points",
                estimatedImpact: 0.5
            ))

        case .proposal:
            actions.append(Action(
                title: "Send customized proposal",
                priority: .high,
                description: "Include pricing, timeline, and ROI analysis",
                estimatedImpact: 0.6
            ))

        case .negotiation:
            actions.append(Action(
                title: "Address final objections",
                priority: .high,
                description: "Schedule executive meeting to finalize terms",
                estimatedImpact: 0.7
            ))

        case .closedWon, .closedLost:
            break
        }

        // Time-based actions
        if opportunity.daysToClose < 7 {
            actions.append(Action(
                title: "Follow up urgently",
                priority: .urgent,
                description: "Deal closing soon - ensure all stakeholders aligned",
                estimatedImpact: 0.8
            ))
        }

        // Activity-based actions
        let recentActivities = opportunity.activities.filter {
            guard let scheduled = $0.scheduledAt else { return false }
            return scheduled > Date().addingTimeInterval(-14 * 24 * 60 * 60)
        }

        if recentActivities.isEmpty {
            actions.append(Action(
                title: "Re-engage contact",
                priority: .medium,
                description: "No activity in 2 weeks - reach out to maintain momentum",
                estimatedImpact: 0.4
            ))
        }

        return actions.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }

    func identifyCrossSellOpportunities(for account: Account) async throws -> [Product] {
        // Mock implementation - would use ML model in production
        return [
            Product(
                name: "Enterprise Analytics Module",
                description: "Advanced analytics and reporting",
                estimatedValue: 50_000,
                fitScore: 0.85
            ),
            Product(
                name: "Premium Support Package",
                description: "24/7 dedicated support team",
                estimatedValue: 25_000,
                fitScore: 0.72
            )
        ]
    }

    // MARK: - Relationship Intelligence

    func analyzeStakeholderNetwork(for account: Account) async throws -> NetworkGraph {
        let contacts = account.contacts
        var nodes: [NetworkNode] = []
        var edges: [NetworkEdge] = []

        // Create nodes for each contact
        for contact in contacts {
            nodes.append(NetworkNode(
                id: contact.id,
                name: contact.fullName,
                role: contact.role,
                influence: contact.influenceScore,
                isDecisionMaker: contact.isDecisionMaker
            ))
        }

        // Create edges based on relationships
        for contact in contacts {
            for relationship in contact.relationships {
                if let toContact = relationship.toContact {
                    edges.append(NetworkEdge(
                        fromId: contact.id,
                        toId: toContact.id,
                        strength: relationship.strength,
                        type: relationship.relationshipType
                    ))
                }
            }
        }

        return NetworkGraph(nodes: nodes, edges: edges)
    }

    func identifyDecisionMakers(in account: Account) async throws -> [Contact] {
        return account.contacts
            .filter { $0.isDecisionMaker || $0.influenceScore > 80 }
            .sorted { $0.influenceScore > $1.influenceScore }
    }

    func calculateInfluenceScore(for contact: Contact) async throws -> Double {
        var score: Double = 50.0

        // Factor 1: Title-based influence
        let title = contact.title.lowercased()
        if title.contains("ceo") || title.contains("president") {
            score += 30
        } else if title.contains("cto") || title.contains("cfo") || title.contains("vp") {
            score += 20
        } else if title.contains("director") || title.contains("manager") {
            score += 10
        }

        // Factor 2: Decision maker flag
        if contact.isDecisionMaker {
            score += 15
        }

        // Factor 3: Activity engagement
        if contact.activities.count > 10 {
            score += 10
        } else if contact.activities.count > 5 {
            score += 5
        }

        // Factor 4: Relationship connections
        score += min(Double(contact.relationships.count) * 2, 15)

        return min(max(score, 0), 100)
    }

    // MARK: - Natural Language Processing

    func processNaturalLanguageQuery(_ query: String) async throws -> QueryResult {
        // Mock implementation - would use NLP model in production
        let lowercasedQuery = query.lowercased()

        if lowercasedQuery.contains("deal") && lowercasedQuery.contains("over") {
            return QueryResult(
                intent: "filter_opportunities",
                parameters: ["amount": "500000"],
                confidence: 0.9
            )
        } else if lowercasedQuery.contains("customer") || lowercasedQuery.contains("account") {
            return QueryResult(
                intent: "show_accounts",
                parameters: [:],
                confidence: 0.85
            )
        } else {
            return QueryResult(
                intent: "general_search",
                parameters: ["query": query],
                confidence: 0.5
            )
        }
    }

    // MARK: - Helper Methods

    private func generateChurnRecommendations(riskScore: Double, account: Account) -> [String] {
        var recommendations: [String] = []

        if riskScore > 70 {
            recommendations.append("Schedule executive business review immediately")
            recommendations.append("Assign dedicated customer success manager")
        }

        if account.healthScore < 50 {
            recommendations.append("Conduct satisfaction survey")
        }

        if account.activities.filter({
            guard let completed = $0.completedAt else { return false }
            return completed > Date().addingTimeInterval(-30 * 24 * 60 * 60)
        }).count < 3 {
            recommendations.append("Increase engagement frequency")
        }

        recommendations.append("Review product usage metrics")
        recommendations.append("Identify upsell opportunities to increase stickiness")

        return recommendations
    }
}

// MARK: - Supporting Types

struct AIScore {
    let value: Double
    let confidence: Double
    let factors: [String]
}

struct ChurnPrediction {
    let riskScore: Double
    let timeframe: Int  // days
    let factors: [String]
    let recommendations: [String]
}

struct Action {
    let title: String
    let priority: ActionPriority
    let description: String
    let estimatedImpact: Double  // 0.0 to 1.0
}

enum ActionPriority: Int {
    case urgent = 4
    case high = 3
    case medium = 2
    case low = 1
}

struct Product {
    let name: String
    let description: String
    let estimatedValue: Decimal
    let fitScore: Double  // 0.0 to 1.0
}

struct NetworkGraph {
    let nodes: [NetworkNode]
    let edges: [NetworkEdge]
}

struct NetworkNode {
    let id: UUID
    let name: String
    let role: ContactRole
    let influence: Double
    let isDecisionMaker: Bool
}

struct NetworkEdge {
    let fromId: UUID
    let toId: UUID
    let strength: Double
    let type: String
}

struct QueryResult {
    let intent: String
    let parameters: [String: String]
    let confidence: Double
}
