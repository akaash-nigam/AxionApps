import Foundation

/// Represents the different species of virtual pets available
public enum PetSpecies: String, Codable, CaseIterable, Sendable {
    case luminos = "Luminos"
    case fluffkins = "Fluffkins"
    case crystalites = "Crystalites"
    case aquarians = "Aquarians"
    case shadowlings = "Shadowlings"

    /// Display name for the species
    public var displayName: String {
        rawValue
    }

    /// Description of the pet species
    public var description: String {
        switch self {
        case .luminos:
            return "Light creatures that love windows and sunny spots"
        case .fluffkins:
            return "Furry companions that prefer soft surfaces"
        case .crystalites:
            return "Geometric beings that organize spaces"
        case .aquarians:
            return "Float through air like swimming"
        case .shadowlings:
            return "Shy creatures that hide often"
        }
    }

    /// Base mass for physics calculations (in kg)
    public var baseMass: Float {
        switch self {
        case .luminos:
            return 0.5
        case .fluffkins:
            return 2.0
        case .crystalites:
            return 3.0
        case .aquarians:
            return 1.0
        case .shadowlings:
            return 0.3
        }
    }

    /// 3D model name
    public var modelName: String {
        return "\(rawValue)_Model"
    }

    /// Emoji representation
    public var emoji: String {
        switch self {
        case .luminos:
            return "✨"
        case .fluffkins:
            return "🐾"
        case .crystalites:
            return "💎"
        case .aquarians:
            return "🌊"
        case .shadowlings:
            return "🌑"
        }
    }
}
