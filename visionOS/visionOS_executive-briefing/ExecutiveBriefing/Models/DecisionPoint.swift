import Foundation
import SwiftData

/// Represents a strategic decision point
@Model
final class DecisionPoint {
    /// Unique identifier
    var id: UUID

    /// Decision title
    var title: String

    /// Question being addressed
    var question: String

    /// Available options
    @Relationship(deleteRule: .cascade)
    var options: [DecisionOption]

    /// Recommended approach
    var recommendation: String

    /// Decision category
    var category: String?

    /// Priority level (1 = highest)
    var priority: Int

    /// Impact score (0-10)
    var impact: Int

    /// Feasibility score (0-10)
    var feasibility: Int

    /// Initialize a new decision point
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Decision title
    ///   - question: Question being addressed
    ///   - options: Available options
    ///   - recommendation: Recommended approach
    ///   - category: Optional category
    ///   - priority: Priority level
    ///   - impact: Impact score (0-10)
    ///   - feasibility: Feasibility score (0-10)
    init(
        id: UUID = UUID(),
        title: String,
        question: String,
        options: [DecisionOption] = [],
        recommendation: String,
        category: String? = nil,
        priority: Int = 5,
        impact: Int = 5,
        feasibility: Int = 5
    ) {
        self.id = id
        self.title = title
        self.question = question
        self.options = options
        self.recommendation = recommendation
        self.category = category
        self.priority = priority
        self.impact = impact
        self.feasibility = feasibility
    }

    /// Position in decision matrix (normalized 0-1)
    var normalizedImpact: Float {
        Float(impact) / 10.0
    }

    var normalizedFeasibility: Float {
        Float(feasibility) / 10.0
    }

    /// Quadrant in decision matrix
    var quadrant: DecisionQuadrant {
        let highImpact = impact >= 6
        let highFeasibility = feasibility >= 6

        switch (highImpact, highFeasibility) {
        case (true, true): return .highImpactHighFeasibility
        case (true, false): return .highImpactLowFeasibility
        case (false, true): return .lowImpactHighFeasibility
        case (false, false): return .lowImpactLowFeasibility
        }
    }
}

/// Decision matrix quadrants
enum DecisionQuadrant {
    case highImpactHighFeasibility   // Do first
    case highImpactLowFeasibility     // Strategic investment
    case lowImpactHighFeasibility     // Quick wins
    case lowImpactLowFeasibility      // Deprioritize

    var label: String {
        switch self {
        case .highImpactHighFeasibility: return "Priority Actions"
        case .highImpactLowFeasibility: return "Strategic Investments"
        case .lowImpactHighFeasibility: return "Quick Wins"
        case .lowImpactLowFeasibility: return "Low Priority"
        }
    }
}

/// A decision option
@Model
final class DecisionOption {
    /// Unique identifier
    var id: UUID

    /// Option title
    var title: String

    /// Detailed description
    var descriptionText: String

    /// Advantages
    var pros: [String]

    /// Disadvantages
    var cons: [String]

    /// Estimated cost
    var estimatedCost: String?

    /// Timeframe
    var timeframe: String?

    /// Initialize a new decision option
    init(
        id: UUID = UUID(),
        title: String,
        descriptionText: String,
        pros: [String] = [],
        cons: [String] = [],
        estimatedCost: String? = nil,
        timeframe: String? = nil
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.pros = pros
        self.cons = cons
        self.estimatedCost = estimatedCost
        self.timeframe = timeframe
    }
}

// MARK: - Hashable & Equatable
extension DecisionPoint: Hashable {
    static func == (lhs: DecisionPoint, rhs: DecisionPoint) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension DecisionOption: Hashable {
    static func == (lhs: DecisionOption, rhs: DecisionOption) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
