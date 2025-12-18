import Foundation

/// Represents a historical time period in the game
enum HistoricalEra: String, Codable, CaseIterable, Identifiable {
    // Ancient Civilizations
    case ancientEgypt = "ancient_egypt"
    case ancientGreece = "ancient_greece"
    case ancientRome = "ancient_rome"
    case ancientChina = "ancient_china"

    // Medieval Period
    case medievalEurope = "medieval_europe"
    case islamicGoldenAge = "islamic_golden_age"
    case feudalJapan = "feudal_japan"

    // Renaissance & Exploration
    case renaissance = "renaissance"
    case ageOfExploration = "age_of_exploration"

    // Modern Era
    case industrialRevolution = "industrial_revolution"
    case victorianEra = "victorian_era"
    case modernEra = "modern_era"

    // Future
    case nearFuture = "near_future"

    var id: String { rawValue }

    // MARK: - Era Information

    /// Display name of the era
    var name: String {
        switch self {
        case .ancientEgypt: return "Ancient Egypt"
        case .ancientGreece: return "Ancient Greece"
        case .ancientRome: return "Ancient Rome"
        case .ancientChina: return "Ancient China"
        case .medievalEurope: return "Medieval Europe"
        case .islamicGoldenAge: return "Islamic Golden Age"
        case .feudalJapan: return "Feudal Japan"
        case .renaissance: return "Renaissance"
        case .ageOfExploration: return "Age of Exploration"
        case .industrialRevolution: return "Industrial Revolution"
        case .victorianEra: return "Victorian Era"
        case .modernEra: return "Modern Era"
        case .nearFuture: return "Near Future"
        }
    }

    /// Time period span
    var timePeriod: String {
        switch self {
        case .ancientEgypt: return "3100 BCE - 30 BCE"
        case .ancientGreece: return "800 BCE - 146 BCE"
        case .ancientRome: return "753 BCE - 476 CE"
        case .ancientChina: return "2070 BCE - 220 CE"
        case .medievalEurope: return "476 CE - 1500 CE"
        case .islamicGoldenAge: return "750 CE - 1258 CE"
        case .feudalJapan: return "1185 CE - 1868 CE"
        case .renaissance: return "1300 CE - 1600 CE"
        case .ageOfExploration: return "1400 CE - 1600 CE"
        case .industrialRevolution: return "1760 CE - 1840 CE"
        case .victorianEra: return "1837 CE - 1901 CE"
        case .modernEra: return "1900 CE - Present"
        case .nearFuture: return "2050 CE - 2100 CE"
        }
    }

    /// Short description of the era
    var description: String {
        switch self {
        case .ancientEgypt:
            return "Explore the land of pharaohs, pyramids, and hieroglyphics along the Nile River."
        case .ancientGreece:
            return "Discover the birthplace of democracy, philosophy, and Western civilization."
        case .ancientRome:
            return "Walk through the mighty Roman Empire at its height of power and influence."
        case .ancientChina:
            return "Journey through ancient dynasties, the Great Wall, and the Silk Road."
        case .medievalEurope:
            return "Enter the age of castles, knights, and the feudal system."
        case .islamicGoldenAge:
            return "Experience the height of science, mathematics, and cultural achievement."
        case .feudalJapan:
            return "Meet samurai warriors and explore traditional Japanese culture."
        case .renaissance:
            return "Witness the rebirth of art, science, and humanist philosophy."
        case .ageOfExploration:
            return "Sail with explorers discovering new lands and trade routes."
        case .industrialRevolution:
            return "See how steam power and factories transformed the world."
        case .victorianEra:
            return "Experience Britain's golden age of innovation and empire."
        case .modernEra:
            return "Explore the rapid technological and social changes of the 20th century."
        case .nearFuture:
            return "Imagine possible futures based on current technology trends."
        }
    }

    /// Key learning themes for this era
    var learningThemes: [String] {
        switch self {
        case .ancientEgypt:
            return ["Civilization Development", "Religious Practices", "Architecture", "Hieroglyphics", "Trade"]
        case .ancientGreece:
            return ["Democracy", "Philosophy", "Mathematics", "Arts", "Olympics"]
        case .ancientRome:
            return ["Engineering", "Government", "Military", "Law", "Latin Language"]
        case .ancientChina:
            return ["Dynasties", "Inventions", "Philosophy", "Great Wall", "Silk Road"]
        case .medievalEurope:
            return ["Feudalism", "Knights", "Castles", "Religion", "Guilds"]
        case .islamicGoldenAge:
            return ["Mathematics", "Astronomy", "Medicine", "Architecture", "Translation Movement"]
        case .feudalJapan:
            return ["Samurai Code", "Shogunate", "Art", "Religion", "Isolation"]
        case .renaissance:
            return ["Art", "Science", "Humanism", "Printing Press", "Banking"]
        case .ageOfExploration:
            return ["Navigation", "Trade Routes", "Cultural Exchange", "Colonization", "Maps"]
        case .industrialRevolution:
            return ["Steam Power", "Factories", "Urbanization", "Labor", "Innovation"]
        case .victorianEra:
            return ["British Empire", "Technology", "Social Reform", "Literature", "Class System"]
        case .modernEra:
            return ["World Wars", "Technology", "Civil Rights", "Globalization", "Digital Age"]
        case .nearFuture:
            return ["AI", "Space Exploration", "Climate Solutions", "Biotechnology", "Society"]
        }
    }

    /// Unlock requirements
    var unlockRequirements: UnlockRequirements {
        switch self {
        case .ancientEgypt:
            return UnlockRequirements(isInitiallyUnlocked: true)
        case .ancientGreece:
            return UnlockRequirements(
                previousEraCompletion: 0.8,
                artifactsRequired: 10,
                mysteriesCompleted: 3
            )
        case .ancientRome:
            return UnlockRequirements(
                previousEraCompletion: 0.8,
                artifactsRequired: 15,
                mysteriesCompleted: 4
            )
        case .medievalEurope:
            return UnlockRequirements(
                previousEraCompletion: 0.85,
                artifactsRequired: 20,
                mysteriesCompleted: 5
            )
        default:
            return UnlockRequirements(
                previousEraCompletion: 0.8,
                artifactsRequired: 15,
                mysteriesCompleted: 4
            )
        }
    }

    /// Color theme for the era
    var colorTheme: EraColorTheme {
        switch self {
        case .ancientEgypt:
            return EraColorTheme(
                primary: "#D4AF37",      // Gold
                secondary: "#1F4788",    // Lapis Blue
                accent: "#E2725B"        // Terracotta
            )
        case .ancientGreece:
            return EraColorTheme(
                primary: "#F8F8FF",      // Marble White
                secondary: "#4A90A4",    // Aegean Blue
                accent: "#FFD700"        // Gold
            )
        case .ancientRome:
            return EraColorTheme(
                primary: "#800020",      // Burgundy
                secondary: "#CD7F32",    // Bronze
                accent: "#FFD700"        // Gold
            )
        case .medievalEurope:
            return EraColorTheme(
                primary: "#002366",      // Royal Blue
                secondary: "#228B22",    // Forest Green
                accent: "#FFD700"        // Gold Leaf
            )
        case .renaissance:
            return EraColorTheme(
                primary: "#DC143C",      // Crimson
                secondary: "#0047AB",    // Venetian Blue
                accent: "#50C878"        // Emerald
            )
        default:
            return EraColorTheme(
                primary: "#4A4A4A",      // Gray
                secondary: "#6A6A6A",    // Light Gray
                accent: "#FFD700"        // Gold
            )
        }
    }

    /// Recommended minimum age for this era's content
    var minimumAge: Int {
        switch self {
        case .ancientEgypt, .ancientGreece:
            return 8  // Good starter eras
        case .medievalEurope, .feudalJapan:
            return 10 // Some complex themes
        case .industrialRevolution, .victorianEra:
            return 12 // Social issues
        case .modernEra:
            return 14 // War, conflict themes
        case .nearFuture:
            return 10 // Speculative but educational
        default:
            return 10
        }
    }

    /// Asset bundle name for this era
    var assetBundleName: String {
        "Era_\(rawValue)"
    }
}

// MARK: - Supporting Types

/// Requirements to unlock an era
struct UnlockRequirements: Codable {
    let isInitiallyUnlocked: Bool
    let previousEraCompletion: Float  // 0.0 - 1.0
    let artifactsRequired: Int
    let mysteriesCompleted: Int

    init(isInitiallyUnlocked: Bool = false,
         previousEraCompletion: Float = 0.8,
         artifactsRequired: Int = 10,
         mysteriesCompleted: Int = 3) {
        self.isInitiallyUnlocked = isInitiallyUnlocked
        self.previousEraCompletion = previousEraCompletion
        self.artifactsRequired = artifactsRequired
        self.mysteriesCompleted = mysteriesCompleted
    }
}

/// Color theme for an era
struct EraColorTheme: Codable {
    let primary: String    // Hex color
    let secondary: String  // Hex color
    let accent: String     // Hex color

    var primaryColor: String { primary }
    var secondaryColor: String { secondary }
    var accentColor: String { accent }
}

// MARK: - Era Progression

extension HistoricalEra {
    /// Get the next era in chronological order
    var nextEra: HistoricalEra? {
        let allEras = Self.chronologicalOrder
        guard let currentIndex = allEras.firstIndex(of: self),
              currentIndex + 1 < allEras.count else {
            return nil
        }
        return allEras[currentIndex + 1]
    }

    /// Get the previous era in chronological order
    var previousEra: HistoricalEra? {
        let allEras = Self.chronologicalOrder
        guard let currentIndex = allEras.firstIndex(of: self),
              currentIndex > 0 else {
            return nil
        }
        return allEras[currentIndex - 1]
    }

    /// All eras in chronological order
    static var chronologicalOrder: [HistoricalEra] {
        [
            .ancientEgypt,
            .ancientChina,
            .ancientGreece,
            .ancientRome,
            .islamicGoldenAge,
            .medievalEurope,
            .feudalJapan,
            .renaissance,
            .ageOfExploration,
            .industrialRevolution,
            .victorianEra,
            .modernEra,
            .nearFuture
        ]
    }

    /// Check if this era is unlocked for a given player
    func isUnlocked(progress: PlayerProgress) -> Bool {
        // Always unlocked
        if unlockRequirements.isInitiallyUnlocked {
            return true
        }

        // Check previous era completion
        guard let previousEra = previousEra else {
            return true // First era
        }

        let previousProgress = progress.eraProgress[previousEra] ?? 0
        return previousProgress >= unlockRequirements.previousEraCompletion
    }
}

/// Player progress tracking
struct PlayerProgress: Codable {
    var eraProgress: [HistoricalEra: Float] = [:]
    var artifactsCollected: Set<String> = []
    var mysteriesCompleted: Set<String> = []

    func completion(for era: HistoricalEra) -> Float {
        eraProgress[era] ?? 0.0
    }
}
