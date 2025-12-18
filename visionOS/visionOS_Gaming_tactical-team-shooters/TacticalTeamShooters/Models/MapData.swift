import Foundation

/// Map data and management
actor MapDataManager {
    static let shared = MapDataManager()

    private var maps: [GameMap] = []

    func loadMaps() async {
        // TODO: Load map definitions
        print("Maps loaded")
    }

    func getCurrentMap() async -> GameMap {
        // TODO: Return current map
        return GameMap(id: UUID(), name: "Industrial Complex", theme: "industrial")
    }
}

struct GameMap: Codable {
    var id: UUID
    var name: String
    var theme: String
    var spawnPoints: [SpawnPoint] = []
}
