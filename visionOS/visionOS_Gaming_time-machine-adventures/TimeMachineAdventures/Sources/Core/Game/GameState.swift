import Foundation

/// Represents the current state of the game
enum GameState: Equatable, Codable {
    case initializing
    case calibrating        // Room scanning and setup
    case mainMenu
    case selectingEra
    case loadingEra(HistoricalEra)
    case exploring(HistoricalEra)          // Active historical exploration
    case examiningArtifact(String)  // artifactID
    case conversing(String)         // characterID
    case solvingMystery(String)     // mysteryID
    case viewingTimeline
    case pause
    case settings
    case assessment(String)         // assessmentID

    /// Whether the state represents active gameplay
    var isActiveGameplay: Bool {
        switch self {
        case .exploring, .examiningArtifact, .conversing, .solvingMystery:
            return true
        default:
            return false
        }
    }

    /// Whether the state allows background audio
    var allowsBackgroundAudio: Bool {
        switch self {
        case .exploring, .examiningArtifact, .conversing, .solvingMystery:
            return true
        default:
            return false
        }
    }

    /// Whether this state requires immersive space
    var requiresImmersiveSpace: Bool {
        switch self {
        case .exploring, .examiningArtifact, .conversing, .solvingMystery:
            return true
        default:
            return false
        }
    }
}

/// Represents the spatial mode of the application
enum SpatialMode: Equatable {
    case window             // Traditional 2D window (tutorial, menus)
    case volumetric         // 3D volume (artifact examination)
    case immersiveSpace     // Full environment (historical exploration)
}

/// Difficulty level for educational content
enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner        // Ages 8-10
    case intermediate    // Ages 11-14
    case advanced        // Ages 15-18
    case expert          // Adult/Educator

    var ageRange: ClosedRange<Int> {
        switch self {
        case .beginner: return 8...10
        case .intermediate: return 11...14
        case .advanced: return 15...18
        case .expert: return 19...99
        }
    }

    var questionCount: Int {
        switch self {
        case .beginner: return 5
        case .intermediate: return 7
        case .advanced: return 10
        case .expert: return 15
        }
    }

    var passingScore: Float {
        switch self {
        case .beginner: return 0.7      // 70%
        case .intermediate: return 0.75  // 75%
        case .advanced: return 0.8       // 80%
        case .expert: return 0.85        // 85%
        }
    }

    var artifactCount: Int {
        switch self {
        case .beginner: return 3
        case .intermediate: return 5
        case .advanced: return 7
        case .expert: return 10
        }
    }
}

/// Educational level classification
enum EducationalLevel: String, Codable {
    case explorer
    case investigator
    case historian
    case timeMaster

    var title: String {
        switch self {
        case .explorer: return "Explorer"
        case .investigator: return "Investigator"
        case .historian: return "Historian"
        case .timeMaster: return "Time Master"
        }
    }
}

/// Relationship level with historical characters
enum RelationshipLevel: Int, Codable, Comparable {
    case stranger = 0          // Initial meeting
    case acquaintance = 1      // 3+ conversations
    case friend = 2            // Complete character quest
    case confidant = 3         // Share personal stories
    case mentor = 4            // Character teaches advanced concepts

    static func < (lhs: RelationshipLevel, rhs: RelationshipLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var conversationsRequired: Int {
        switch self {
        case .stranger: return 0
        case .acquaintance: return 3
        case .friend: return 10
        case .confidant: return 20
        case .mentor: return 40
        }
    }
}
