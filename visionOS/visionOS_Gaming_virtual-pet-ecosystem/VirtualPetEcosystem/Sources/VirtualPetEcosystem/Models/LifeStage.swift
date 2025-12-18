import Foundation

/// Represents the life stages a pet goes through
public enum LifeStage: String, Codable, CaseIterable, Sendable {
    case baby = "Baby"
    case youth = "Youth"
    case adult = "Adult"
    case elder = "Elder"

    /// Age range in days for this life stage
    public var ageRange: ClosedRange<Double> {
        switch self {
        case .baby:
            return 0...29
        case .youth:
            return 30...89
        case .adult:
            return 90...364
        case .elder:
            return 365...Double.infinity
        }
    }

    /// Returns the life stage for a given age in days
    public static func stage(for ageInDays: Double) -> LifeStage {
        switch ageInDays {
        case 0..<30:
            return .baby
        case 30..<90:
            return .youth
        case 90..<365:
            return .adult
        default:
            return .elder
        }
    }

    /// Size multiplier for this life stage
    public var sizeMultiplier: Float {
        switch self {
        case .baby:
            return 0.6
        case .youth:
            return 0.8
        case .adult:
            return 1.0
        case .elder:
            return 0.95
        }
    }

    /// Can this life stage breed?
    public var canBreed: Bool {
        self == .adult
    }
}
