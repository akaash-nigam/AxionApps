import Foundation

/// Represents a player in the Spatial Pictionary game
/// - Codable for network synchronization and persistence
/// - Identifiable for SwiftUI list rendering
struct Player: Identifiable, Codable, Equatable {
    // MARK: - Properties

    /// Unique identifier for the player
    let id: UUID

    /// Player's display name
    var name: String

    /// Player's avatar configuration
    var avatar: AvatarConfiguration

    /// Current score in the game session
    var score: Int

    /// Whether this player is on the local device
    var isLocal: Bool

    /// Device identifier for multiplayer sync
    var deviceID: String

    /// Spatial experience level (0-100)
    /// Used for comfort mode selection and difficulty adjustment
    var spatialExperience: Int

    // MARK: - Statistics

    /// Total games played by this player
    var gamesPlayed: Int = 0

    /// Number of correct guesses
    var correctGuesses: Int = 0

    /// Number of drawings completed
    var drawingsCompleted: Int = 0

    /// Average time to guess correctly (in seconds)
    var averageGuessTime: TimeInterval = 0.0

    /// Success rate (0.0 - 1.0)
    var successRate: Float {
        guard correctGuesses > 0 else { return 0.0 }
        return Float(correctGuesses) / Float(gamesPlayed)
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        avatar: AvatarConfiguration,
        score: Int = 0,
        isLocal: Bool,
        deviceID: String,
        spatialExperience: Int = 0
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.score = score
        self.isLocal = isLocal
        self.deviceID = deviceID
        self.spatialExperience = spatialExperience
    }

    // MARK: - Methods

    /// Update statistics after completing a round
    mutating func updateStatistics(
        correct: Bool,
        guessTime: TimeInterval?
    ) {
        gamesPlayed += 1

        if correct {
            correctGuesses += 1

            if let guessTime = guessTime {
                // Update running average
                let totalTime = averageGuessTime * Double(correctGuesses - 1)
                averageGuessTime = (totalTime + guessTime) / Double(correctGuesses)
            }
        }
    }

    /// Update drawing statistics
    mutating func recordDrawing() {
        drawingsCompleted += 1
    }
}

// MARK: - Avatar Configuration

struct AvatarConfiguration: Codable, Equatable {
    var colorScheme: ColorScheme
    var accessoryType: AccessoryType
    var customization: [String: String]

    enum ColorScheme: String, Codable {
        case blue, red, green, purple, orange, pink, yellow, teal
    }

    enum AccessoryType: String, Codable {
        case none, hat, glasses, headphones, crown
    }

    static var `default`: AvatarConfiguration {
        AvatarConfiguration(
            colorScheme: .blue,
            accessoryType: .none,
            customization: [:]
        )
    }
}

// MARK: - Player Extensions

extension Player {
    /// Returns a mock player for testing
    static func mock(name: String = "TestPlayer") -> Player {
        Player(
            name: name,
            avatar: .default,
            isLocal: true,
            deviceID: "mock-device"
        )
    }

    /// Returns an array of mock players for testing
    static func mockPlayers(count: Int) -> [Player] {
        (1...count).map { i in
            Player.mock(name: "Player\(i)")
        }
    }
}
