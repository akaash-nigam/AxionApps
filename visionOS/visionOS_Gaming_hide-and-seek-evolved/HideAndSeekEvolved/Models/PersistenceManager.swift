import Foundation

actor PersistenceManager {
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    init() {
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Game Session
    func saveSession(_ session: GameSession) async throws {
        let url = documentsDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent("\(session.id).json")

        try createDirectoryIfNeeded(at: url.deletingLastPathComponent())

        let data = try encoder.encode(session)
        try data.write(to: url)
    }

    func loadSession(id: UUID) async throws -> GameSession {
        let url = documentsDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent("\(id).json")

        let data = try Data(contentsOf: url)
        return try decoder.decode(GameSession.self, from: data)
    }

    // MARK: - Room Layout
    func saveRoomLayout(_ layout: RoomLayout) async throws {
        let url = documentsDirectory
            .appendingPathComponent("rooms")
            .appendingPathComponent("\(layout.id).json")

        try createDirectoryIfNeeded(at: url.deletingLastPathComponent())

        let data = try encoder.encode(layout)
        try data.write(to: url)
    }

    func loadMostRecentRoomLayout() async throws -> RoomLayout? {
        let roomsDir = documentsDirectory.appendingPathComponent("rooms")

        guard fileManager.fileExists(atPath: roomsDir.path) else {
            return nil
        }

        let files = try fileManager.contentsOfDirectory(
            at: roomsDir,
            includingPropertiesForKeys: [.creationDateKey]
        )

        guard let mostRecent = files.max(by: { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            return date1 < date2
        }) else {
            return nil
        }

        let data = try Data(contentsOf: mostRecent)
        return try decoder.decode(RoomLayout.self, from: data)
    }

    // MARK: - Player Profile
    func savePlayerProfile(_ player: Player) async throws {
        let url = documentsDirectory
            .appendingPathComponent("players")
            .appendingPathComponent("\(player.id).json")

        try createDirectoryIfNeeded(at: url.deletingLastPathComponent())

        let data = try encoder.encode(player)
        try data.write(to: url)
    }

    func loadPlayerProfile(id: UUID) async throws -> Player {
        let url = documentsDirectory
            .appendingPathComponent("players")
            .appendingPathComponent("\(id).json")

        let data = try Data(contentsOf: url)
        return try decoder.decode(Player.self, from: data)
    }

    func loadAllPlayers() async throws -> [Player] {
        let playersDir = documentsDirectory.appendingPathComponent("players")

        guard fileManager.fileExists(atPath: playersDir.path) else {
            return []
        }

        let files = try fileManager.contentsOfDirectory(at: playersDir, includingPropertiesForKeys: nil)

        return try await withThrowingTaskGroup(of: Player.self) { group in
            for file in files where file.pathExtension == "json" {
                group.addTask {
                    let data = try Data(contentsOf: file)
                    return try self.decoder.decode(Player.self, from: data)
                }
            }

            var players: [Player] = []
            for try await player in group {
                players.append(player)
            }
            return players
        }
    }

    // MARK: - Helper Methods
    private func createDirectoryIfNeeded(at url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }
    }
}

// MARK: - Game Session Model
struct GameSession: Identifiable, Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date?
    var players: [Player]
    var rounds: [Round]
    var roomLayout: RoomLayout
    var settings: GameSettings

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        players: [Player],
        rounds: [Round] = [],
        roomLayout: RoomLayout,
        settings: GameSettings = GameSettings()
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.players = players
        self.rounds = rounds
        self.roomLayout = roomLayout
        self.settings = settings
    }
}

// MARK: - Game Settings
struct GameSettings: Codable {
    var roundDuration: TimeInterval = 180  // 3 minutes
    var hidingDuration: TimeInterval = 60  // 1 minute
    var numberOfRounds: Int = 5
    var enableAbilities: Bool = true
    var masterVolume: Float = 1.0
    var musicVolume: Float = 0.7
    var sfxVolume: Float = 0.9

    init() {}
}

// MARK: - Round
struct Round: Codable {
    let roundNumber: Int
    var startTime: Date
    var endTime: Date?
    var hiders: [UUID]  // Player IDs
    var seekers: [UUID] // Player IDs
    var winner: PlayerRole?
    var events: [RoundEvent]

    init(
        roundNumber: Int,
        startTime: Date = Date(),
        endTime: Date? = nil,
        hiders: [UUID],
        seekers: [UUID],
        winner: PlayerRole? = nil,
        events: [RoundEvent] = []
    ) {
        self.roundNumber = roundNumber
        self.startTime = startTime
        self.endTime = endTime
        self.hiders = hiders
        self.seekers = seekers
        self.winner = winner
        self.events = events
    }
}

// MARK: - Round Event
struct RoundEvent: Codable {
    let timestamp: Date
    let type: EventType
    let playerId: UUID?
    let details: String

    enum EventType: String, Codable {
        case playerHidden
        case playerFound
        case abilityUsed
        case boundaryViolation
        case roundTimeExpired
    }

    init(
        timestamp: Date = Date(),
        type: EventType,
        playerId: UUID? = nil,
        details: String = ""
    ) {
        self.timestamp = timestamp
        self.type = type
        self.playerId = playerId
        self.details = details
    }
}
