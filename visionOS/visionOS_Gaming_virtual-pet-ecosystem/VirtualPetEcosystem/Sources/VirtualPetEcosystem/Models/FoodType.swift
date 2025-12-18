import Foundation

/// Types of food that can be given to pets
public enum FoodType: String, Codable, CaseIterable, Sendable {
    case regularFood = "Regular Food"
    case premiumFood = "Premium Food"
    case treat = "Treat"
    case specialtyFood = "Specialty Food"

    /// How much this food satisfies hunger (0.0 - 1.0)
    public var nutritionValue: Float {
        switch self {
        case .regularFood:
            return 0.3
        case .premiumFood:
            return 0.5
        case .treat:
            return 0.1
        case .specialtyFood:
            return 0.7
        }
    }

    /// Happiness bonus from eating this food (0.0 - 1.0)
    public var happinessBonus: Float {
        switch self {
        case .regularFood:
            return 0.1
        case .premiumFood:
            return 0.2
        case .treat:
            return 0.4
        case .specialtyFood:
            return 0.3
        }
    }

    /// Emoji representation
    public var emoji: String {
        switch self {
        case .regularFood:
            return "🍖"
        case .premiumFood:
            return "🥩"
        case .treat:
            return "🍪"
        case .specialtyFood:
            return "⭐🍖"
        }
    }

    /// Cost in virtual currency
    public var cost: Int {
        switch self {
        case .regularFood:
            return 10
        case .premiumFood:
            return 25
        case .treat:
            return 15
        case .specialtyFood:
            return 50
        }
    }
}
