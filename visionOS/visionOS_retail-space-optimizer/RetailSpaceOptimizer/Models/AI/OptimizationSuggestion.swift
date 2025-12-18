import Foundation
import SwiftData

@Model
final class OptimizationSuggestion {
    @Attribute(.unique) var id: UUID
    var storeID: UUID
    var type: OptimizationType
    var title: String
    var description: String
    var rationale: String
    var predictedImpact: ImpactMetrics
    var changes: [LayoutChange]
    var confidence: Double  // 0.0 to 1.0
    var priority: SuggestionPriority
    var status: SuggestionStatus
    var generatedAt: Date
    var implementedAt: Date?
    var actualImpact: ImpactMetrics?

    init(storeID: UUID, type: OptimizationType, title: String, description: String) {
        self.id = UUID()
        self.storeID = storeID
        self.type = type
        self.title = title
        self.description = description
        self.rationale = ""
        self.predictedImpact = ImpactMetrics()
        self.changes = []
        self.confidence = 0
        self.priority = .medium
        self.status = .pending
        self.generatedAt = Date()
    }

    // MARK: - Computed Properties
    var isHighImpact: Bool {
        predictedImpact.salesIncrease > 10 || predictedImpact.conversionIncrease > 5
    }

    var isHighConfidence: Bool {
        confidence > 0.7
    }

    var shouldImplement: Bool {
        isHighImpact && isHighConfidence && status == .pending
    }

    var estimatedROI: Double {
        let revenue = Double(truncating: predictedImpact.revenueImpact as NSNumber)
        let cost = estimatedImplementationCost
        return cost > 0 ? (revenue - cost) / cost : 0
    }

    var estimatedImplementationCost: Double {
        // Simple estimate based on number of changes
        Double(changes.count) * 1000  // $1000 per change
    }
}

// MARK: - Supporting Types

enum OptimizationType: String, Codable, CaseIterable {
    case layout
    case merchandising
    case traffic
    case checkout
    case seasonal
    case promotion
    case inventory
    case staffing

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .layout: return "square.grid.3x3.fill"
        case .merchandising: return "bag.fill"
        case .traffic: return "arrow.triangle.swap"
        case .checkout: return "cart.fill"
        case .seasonal: return "calendar"
        case .promotion: return "megaphone.fill"
        case .inventory: return "shippingbox.fill"
        case .staffing: return "person.2.fill"
        }
    }
}

enum SuggestionPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical

    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }
}

enum SuggestionStatus: String, Codable {
    case pending
    case underReview
    case approved
    case implemented
    case rejected
    case archived

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .underReview: return "Under Review"
        case .approved: return "Approved"
        case .implemented: return "Implemented"
        case .rejected: return "Rejected"
        case .archived: return "Archived"
        }
    }
}

struct ImpactMetrics: Codable, Hashable {
    var salesIncrease: Double = 0  // percentage
    var conversionIncrease: Double = 0  // percentage
    var dwellTimeChange: Double = 0  // percentage (can be negative)
    var trafficChange: Double = 0  // percentage
    var revenueImpact: Decimal = 0  // absolute currency value
    var marginImpact: Decimal = 0
    var customerSatisfactionChange: Double = 0

    var totalImpactScore: Double {
        // Weighted average of different metrics
        let weights: [Double] = [0.4, 0.3, 0.1, 0.1, 0.1]
        let values: [Double] = [
            salesIncrease,
            conversionIncrease,
            dwellTimeChange,
            trafficChange,
            customerSatisfactionChange
        ]

        return zip(weights, values).map(*).reduce(0, +)
    }

    var isPositive: Bool {
        totalImpactScore > 0
    }
}

struct LayoutChange: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var changeType: ChangeType
    var fixtureID: UUID?
    var productID: UUID?
    var fromPosition: SIMD3<Double>?
    var toPosition: SIMD3<Double>?
    var fromRotation: SIMD3<Double>?
    var toRotation: SIMD3<Double>?
    var description: String
    var estimatedEffort: Effort

    var hasPositionChange: Bool {
        fromPosition != nil && toPosition != nil
    }

    var hasRotationChange: Bool {
        fromRotation != nil && toRotation != nil
    }

    var distanceMoved: Double? {
        guard let from = fromPosition, let to = toPosition else { return nil }
        return simd_distance(from, to)
    }
}

enum ChangeType: String, Codable, CaseIterable {
    case move
    case add
    case remove
    case replace
    case rotate
    case scale
    case reorganize

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .move: return "arrow.up.and.down.and.arrow.left.and.right"
        case .add: return "plus.circle.fill"
        case .remove: return "minus.circle.fill"
        case .replace: return "arrow.triangle.2.circlepath"
        case .rotate: return "rotate.right.fill"
        case .scale: return "arrow.up.left.and.down.right.magnifyingglass"
        case .reorganize: return "arrow.triangle.swap"
        }
    }
}

enum Effort: String, Codable {
    case minimal  // <1 hour
    case low      // 1-4 hours
    case medium   // 4-8 hours
    case high     // 1-2 days
    case extensive  // >2 days

    var estimatedHours: Double {
        switch self {
        case .minimal: return 0.5
        case .low: return 2
        case .medium: return 6
        case .high: return 12
        case .extensive: return 24
        }
    }
}

// MARK: - Simulation

struct SimulationParameters: Codable {
    var customerCount: Int = 1000
    var duration: TimeInterval = 86400  // 24 hours
    var peakHours: [Int] = [10, 11, 12, 13, 14, 15, 16, 17, 18]
    var averageShoppingTime: TimeInterval = 1200  // 20 minutes
    var conversionRate: Double = 0.25  // 25%
    var basketSize: (min: Double, max: Double) = (10, 100)

    var customersPerHour: Int {
        Int(Double(customerCount) / (duration / 3600))
    }
}

struct SimulationResult: Codable {
    var totalCustomers: Int
    var conversions: Int
    var totalRevenue: Decimal
    var heatmap: Heatmap
    var bottlenecks: [Bottleneck]
    var underutilizedAreas: [UnderutilizedArea]
    var recommendedChanges: [LayoutChange]

    var conversionRate: Double {
        totalCustomers > 0 ? Double(conversions) / Double(totalCustomers) : 0
    }

    var averageRevenuePerCustomer: Decimal {
        totalCustomers > 0 ? totalRevenue / Decimal(totalCustomers) : 0
    }
}

struct Bottleneck: Codable, Identifiable {
    var id: UUID = UUID()
    var location: SIMD3<Double>
    var severity: Double  // 0-1
    var affectedCustomers: Int
    var averageWaitTime: TimeInterval
    var suggestedFix: String
}

struct UnderutilizedArea: Codable, Identifiable {
    var id: UUID = UUID()
    var bounds: BoundingBox
    var utilizationRate: Double  // 0-1
    var potentialRevenue: Decimal
    var suggestedUse: String
}
