import Foundation

/// Represents a meditation environment/realm
struct MeditationEnvironment: Codable, Identifiable {

    // MARK: - Properties

    let id: String
    let name: String
    let category: EnvironmentCategory
    let description: String
    let assetPath: String
    let isPremium: Bool
    let unlockCondition: UnlockCondition?

    // Environment properties
    var defaultDuration: TimeInterval
    var ambientSoundscape: String
    var visualTheme: VisualTheme
    var difficulty: DifficultyLevel

    // MARK: - Visual Theme

    struct VisualTheme: Codable {
        let primaryColor: String        // Hex color
        let secondaryColor: String      // Hex color
        let lightingMood: LightingMood
        let particleEffects: [String]

        enum LightingMood: String, Codable {
            case dawn = "Dawn"
            case day = "Day"
            case dusk = "Dusk"
            case night = "Night"
            case ethereal = "Ethereal"
        }
    }

    // MARK: - Difficulty Level

    enum DifficultyLevel: Int, Codable {
        case beginner = 1
        case intermediate = 2
        case advanced = 3
        case expert = 4

        var description: String {
            switch self {
            case .beginner: return "Perfect for starting your practice"
            case .intermediate: return "For developing practitioners"
            case .advanced: return "Challenging for experienced meditators"
            case .expert: return "Master level practice"
            }
        }
    }

    // MARK: - Unlock Conditions

    enum UnlockCondition: Codable {
        case level(Int)
        case achievement(String)
        case sessionsCompleted(Int)
        case premium

        var description: String {
            switch self {
            case .level(let lvl):
                return "Reach level \(lvl)"
            case .achievement(let name):
                return "Unlock achievement: \(name)"
            case .sessionsCompleted(let count):
                return "Complete \(count) sessions"
            case .premium:
                return "Premium subscription required"
            }
        }
    }

    // MARK: - Initialization

    init(
        id: String,
        name: String,
        category: EnvironmentCategory,
        description: String,
        assetPath: String,
        isPremium: Bool = false,
        unlockCondition: UnlockCondition? = nil,
        defaultDuration: TimeInterval = 600,
        ambientSoundscape: String,
        visualTheme: VisualTheme,
        difficulty: DifficultyLevel = .beginner
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.assetPath = assetPath
        self.isPremium = isPremium
        self.unlockCondition = unlockCondition
        self.defaultDuration = defaultDuration
        self.ambientSoundscape = ambientSoundscape
        self.visualTheme = visualTheme
        self.difficulty = difficulty
    }

    // MARK: - Starter Environments

    static let zenGarden = MeditationEnvironment(
        id: "ZenGarden",
        name: "Zen Garden",
        category: .nature,
        description: "Traditional Japanese rock garden with raked sand and cherry blossoms",
        assetPath: "Environments/ZenGarden",
        ambientSoundscape: "zen_garden_ambience",
        visualTheme: VisualTheme(
            primaryColor: "#D4B896",
            secondaryColor: "#F5F5F0",
            lightingMood: .day,
            particleEffects: ["cherry_petals", "floating_light"]
        ),
        difficulty: .beginner
    )

    static let forestGrove = MeditationEnvironment(
        id: "ForestGrove",
        name: "Forest Grove",
        category: .nature,
        description: "Ancient forest with towering trees and dappled sunlight",
        assetPath: "Environments/ForestGrove",
        ambientSoundscape: "forest_ambience",
        visualTheme: VisualTheme(
            primaryColor: "#6B8E6B",
            secondaryColor: "#A8C99C",
            lightingMood: .day,
            particleEffects: ["floating_seeds", "light_rays"]
        ),
        difficulty: .beginner
    )

    static let oceanDepths = MeditationEnvironment(
        id: "OceanDepths",
        name: "Ocean Depths",
        category: .underwater,
        description: "Peaceful underwater sanctuary with bioluminescent life",
        assetPath: "Environments/OceanDepths",
        ambientSoundscape: "underwater_ambience",
        visualTheme: VisualTheme(
            primaryColor: "#5F9EA0",
            secondaryColor: "#87CEEB",
            lightingMood: .ethereal,
            particleEffects: ["bioluminescence", "bubbles"]
        ),
        difficulty: .intermediate
    )

    static let mountainPeak = MeditationEnvironment(
        id: "MountainPeak",
        name: "Mountain Peak",
        category: .nature,
        description: "High altitude summit above clouds at sunrise",
        assetPath: "Environments/MountainPeak",
        unlockCondition: .level(3),
        ambientSoundscape: "mountain_wind",
        visualTheme: VisualTheme(
            primaryColor: "#4A5F7F",
            secondaryColor: "#E8A87C",
            lightingMood: .dawn,
            particleEffects: ["prayer_flags", "cloud_wisps"]
        ),
        difficulty: .intermediate
    )

    static let cosmicNebula = MeditationEnvironment(
        id: "CosmicNebula",
        name: "Cosmic Nebula",
        category: .cosmic,
        description: "Float among stars in a colorful nebula",
        assetPath: "Environments/CosmicNebula",
        unlockCondition: .level(8),
        ambientSoundscape: "cosmic_ambience",
        visualTheme: VisualTheme(
            primaryColor: "#B4A7D6",
            secondaryColor: "#D8A7B1",
            lightingMood: .night,
            particleEffects: ["stardust", "cosmic_energy"]
        ),
        difficulty: .advanced
    )

    // MARK: - Default Collection

    static let starterEnvironments: [MeditationEnvironment] = [
        .zenGarden,
        .forestGrove,
        .oceanDepths
    ]

    static let allEnvironments: [MeditationEnvironment] = [
        .zenGarden,
        .forestGrove,
        .oceanDepths,
        .mountainPeak,
        .cosmicNebula
    ]
}
