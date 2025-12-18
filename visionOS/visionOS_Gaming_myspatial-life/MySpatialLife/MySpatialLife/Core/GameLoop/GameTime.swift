import Foundation

/// Manages game time, converting real time to simulation time
struct GameTime: Codable {
    var simulationSpeed: TimeSpeed
    var currentDate: Date
    var gameStartDate: Date

    // Time conversion constants
    static let minutesPerGameDay = 1440.0  // 24 hours * 60 minutes
    static let realSecondsPerGameMinute: [TimeSpeed: Double] = [
        .paused: 0,
        .normal: 2.0,      // 1 real second = 30 sim seconds (48 min/day)
        .fast: 0.5,        // 1 real second = 2 sim minutes (12 min/day)
        .veryFast: 0.167   // 1 real second = 6 sim minutes (4 min/day)
    ]

    init(startDate: Date = Date(), speed: TimeSpeed = .normal) {
        self.gameStartDate = startDate
        self.currentDate = startDate
        self.simulationSpeed = speed
    }

    /// Advance game time by real-world delta
    mutating func advance(by realDelta: TimeInterval) {
        guard simulationSpeed != .paused else { return }

        let secondsPerSimMinute = Self.realSecondsPerGameMinute[simulationSpeed]!
        let simMinutes = realDelta / secondsPerSimMinute
        let simSeconds = simMinutes * 60.0

        currentDate = currentDate.addingTimeInterval(simSeconds)
    }

    /// Get elapsed game time since start
    var elapsedGameTime: TimeInterval {
        currentDate.timeIntervalSince(gameStartDate)
    }

    /// Get current game day (0-based)
    var gameDay: Int {
        let elapsed = elapsedGameTime
        return Int(elapsed / (Self.minutesPerGameDay * 60))
    }

    /// Get time of day
    var timeOfDay: TimeOfDay {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDate)

        switch hour {
        case 5..<12:
            return .morning
        case 12..<17:
            return .afternoon
        case 17..<21:
            return .evening
        default:
            return .night
        }
    }

    enum TimeOfDay: String, Codable {
        case morning
        case afternoon
        case evening
        case night
    }
}
