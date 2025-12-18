# API Documentation - Tactical Team Shooters

Complete API reference for all models, systems, and components in Tactical Team Shooters.

## Table of Contents

- [Models](#models)
  - [Player](#player)
  - [Weapon](#weapon)
  - [Team](#team)
- [Game Systems](#game-systems)
  - [GameStateManager](#gamestatemanager)
  - [NetworkManager](#networkmanager)
- [Views](#views)
- [Utilities](#utilities)

---

## Models

### Player

The `Player` struct represents a player in the game with stats, progression, and loadout.

**Location**: `TacticalTeamShooters/Models/Player.swift`

#### Structure

```swift
struct Player: Codable, Identifiable {
    let id: UUID
    var username: String
    var rank: CompetitiveRank
    var elo: Int
    var stats: PlayerStats
    var loadout: Loadout
    var teamRole: TeamRole
    var health: Double
    var armor: Double
    var isAlive: Bool
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier for the player |
| `username` | `String` | Player's display name |
| `rank` | `CompetitiveRank` | Current competitive rank |
| `elo` | `Int` | ELO rating (0-5000) |
| `stats` | `PlayerStats` | Player statistics |
| `loadout` | `Loadout` | Equipped weapons and equipment |
| `teamRole` | `TeamRole` | Assigned team role |
| `health` | `Double` | Current health (0-100) |
| `armor` | `Double` | Current armor (0-100) |
| `isAlive` | `Bool` | Whether player is alive |

#### Initialization

```swift
// Default initialization
Player(username: String)

// With rank and role
Player(username: String, rank: CompetitiveRank, teamRole: TeamRole)
```

**Example**:
```swift
let player = Player(username: "ProGamer42")
let veteran = Player(
    username: "TacticalVet",
    rank: .veteran,
    teamRole: .sniper
)
```

---

### PlayerStats

Tracks player performance statistics.

#### Structure

```swift
struct PlayerStats: Codable {
    var kills: Int
    var deaths: Int
    var assists: Int
    var headshotKills: Int
    var shotsHit: Int
    var shotsFired: Int
    var matchesPlayed: Int
    var matchesWon: Int
}
```

#### Computed Properties

| Property | Type | Description | Formula |
|----------|------|-------------|---------|
| `kdr` | `Double` | Kill/Death ratio | `kills / deaths` (or `kills` if deaths = 0) |
| `winRate` | `Double` | Win percentage | `matchesWon / matchesPlayed` |
| `accuracy` | `Double` | Shot accuracy | `shotsHit / shotsFired` |
| `headshotPercentage` | `Double` | Headshot % | `headshotKills / kills` |

#### Methods

```swift
mutating func recordKill(headshot: Bool)
mutating func recordDeath()
mutating func recordAssist()
mutating func recordShot(hit: Bool)
```

**Example**:
```swift
var player = Player(username: "Test")
player.stats.recordKill(headshot: true)
player.stats.recordShot(hit: true)
print(player.stats.kdr)  // 1.0
```

---

### CompetitiveRank

Enum representing player ranks.

#### Cases

```swift
enum CompetitiveRank: String, Codable {
    case recruit      // 0-999 ELO
    case specialist   // 1000-1499
    case veteran      // 1500-1999
    case elite        // 2000-2499
    case master       // 2500-2999
    case legend       // 3000+
}
```

#### Properties

```swift
var displayName: String      // Human-readable name
var eloRange: ClosedRange<Int>  // ELO range for rank
var icon: String             // SF Symbol name
```

#### Static Methods

```swift
static func rank(for elo: Int) -> CompetitiveRank
```

**Example**:
```swift
let rank = CompetitiveRank.rank(for: 1750)  // .veteran
print(rank.displayName)  // "Veteran"
```

---

### TeamRole

Enum representing team roles.

#### Cases

```swift
enum TeamRole: String, Codable {
    case entryFragger
    case support
    case sniper
    case igl  // In-Game Leader
    case lurker
}
```

#### Properties

```swift
var displayName: String
var description: String
var preferredWeapons: [WeaponType]
```

**Example**:
```swift
let role = TeamRole.sniper
print(role.displayName)  // "Sniper"
print(role.description)  // "Long-range specialist..."
```

---

### Weapon

Represents weapons with stats and characteristics.

**Location**: `TacticalTeamShooters/Models/Weapon.swift`

#### Structure

```swift
struct Weapon: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: WeaponType
    var stats: WeaponStats
    var recoilPattern: RecoilPattern
    var price: Int
    var unlockLevel: Int
}
```

#### Predefined Weapons

```swift
static var ak47: Weapon
static var m4a1: Weapon
static var awp: Weapon
static var glock: Weapon
static var mp9: Weapon
static var nova: Weapon

static var allWeapons: [Weapon]
```

**Example**:
```swift
let rifle = Weapon.ak47
print(rifle.stats.damage)  // 36
print(rifle.stats.fireRate)  // 600 RPM
```

---

### WeaponStats

Weapon performance statistics.

#### Structure

```swift
struct WeaponStats: Codable {
    var damage: Int              // Base damage per bullet
    var magazineSize: Int        // Rounds per magazine
    var fireRate: Double         // Rounds per minute (RPM)
    var reloadTime: Double       // Seconds
    var range: Float             // Effective range in meters
    var accuracy: Double         // 0.0-1.0
    var muzzleVelocity: Float    // Meters per second
}
```

#### Computed Properties

```swift
var damagePerSecond: Double {
    Double(damage) * (fireRate / 60.0)
}

var timeToKill: Double {
    // Time to kill 100 HP target
    let shotsToKill = ceil(100.0 / Double(damage))
    let timeBetweenShots = 60.0 / fireRate
    return (shotsToKill - 1) * timeBetweenShots
}
```

**Example**:
```swift
let ak47 = Weapon.ak47
print(ak47.stats.damagePerSecond)  // 360 DPS
print(ak47.stats.timeToKill)  // ~0.2 seconds
```

---

### WeaponType

Categorizes weapons.

#### Cases

```swift
enum WeaponType: String, Codable {
    case assaultRifle
    case smg          // Submachine Gun
    case sniper
    case shotgun
    case pistol
    case lmg          // Light Machine Gun
}
```

#### Properties

```swift
var displayName: String
var category: WeaponCategory
```

#### WeaponCategory

```swift
enum WeaponCategory: String, Codable {
    case automatic    // Full-auto weapons
    case precision    // Snipers, semi-auto
    case closeRange   // Shotguns
    case secondary    // Pistols
}
```

---

### RecoilPattern

Defines weapon recoil behavior.

#### Structure

```swift
struct RecoilPattern: Codable {
    var verticalKick: Float      // Upward kick per shot
    var horizontalSpread: Float  // Side-to-side spread
    var resetTime: Double        // Time to reset recoil
    var pattern: [SIMD2<Float>]  // Spray pattern coordinates
}
```

#### Predefined Patterns

```swift
static var ak47Pattern: RecoilPattern
static var m4Pattern: RecoilPattern
static var awpPattern: RecoilPattern
```

**Example**:
```swift
let pattern = RecoilPattern.ak47Pattern
print(pattern.verticalKick)  // 0.15
print(pattern.pattern.count)  // 10 bullets
```

---

### Attachment

Weapon modifications.

#### Structure

```swift
struct Attachment: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: AttachmentType
    var modifiers: WeaponModifiers
}
```

#### AttachmentType

```swift
enum AttachmentType: String, Codable {
    case optic       // Sights
    case barrel      // Suppressors, compensators
    case magazine    // Extended mags
    case grip        // Foregrips
    case stock       // Stocks

    var slot: Int
    var displayName: String
}
```

---

### Team

Represents a team in multiplayer.

**Location**: `TacticalTeamShooters/Models/Team.swift`

#### Structure

```swift
struct Team: Codable, Identifiable {
    let id: UUID
    var name: String
    var players: [Player]
    var side: TeamSide
    var score: Int
}
```

#### Properties

```swift
var isFullTeam: Bool { players.count == 5 }
var averageElo: Int
```

#### Methods

```swift
mutating func addPlayer(_ player: Player) throws
mutating func removePlayer(_ playerId: UUID)
func containsPlayer(_ playerId: UUID) -> Bool
```

**Example**:
```swift
var team = Team(name: "Alpha", side: .attackers)
try team.addPlayer(player)
print(team.players.count)  // 1
```

---

### TeamSide

```swift
enum TeamSide: String, Codable {
    case attackers
    case defenders
}
```

---

### Match

Represents a game match.

#### Structure

```swift
struct Match: Codable, Identifiable {
    let id: UUID
    var teamA: Team
    var teamB: Team
    var gameMode: GameMode
    var map: GameMap
    var currentRound: Int
    var maxRounds: Int
    var state: MatchState
}
```

#### GameMode

```swift
enum GameMode: String, Codable {
    case bombDefusal      // Plant/defuse
    case teamDeathmatch   // TDM
    case controlPoint     // Capture objectives
    case elimination      // Last team standing
}
```

#### MatchState

```swift
enum MatchState: String, Codable {
    case warmup
    case active
    case halftime
    case overtime
    case finished
}
```

---

## Game Systems

### GameStateManager

Manages game state and transitions.

**Location**: `TacticalTeamShooters/Game/GameState/GameStateManager.swift`

#### Class

```swift
@Observable
class GameStateManager {
    var currentState: GameState
    var previousState: GameState?
}
```

#### GameState

```swift
enum GameState {
    case mainMenu
    case matchmaking
    case lobby(Match)
    case inGame(GamePhase)
    case pauseMenu
    case endGame(GameResult)
}
```

#### GamePhase

```swift
enum GamePhase {
    case buyPhase(timeRemaining: TimeInterval)
    case combat
    case roundEnd(winner: TeamSide)
    case bombPlanted(timeRemaining: TimeInterval)
}
```

#### Methods

```swift
func transition(to newState: GameState)
func enterState(_ state: GameState)
func exitState(_ state: GameState)
```

**Example**:
```swift
let gameState = GameStateManager()
gameState.transition(to: .matchmaking)
```

---

### NetworkManager

Handles multiplayer networking.

**Location**: `TacticalTeamShooters/Systems/NetworkSystem/NetworkManager.swift`

#### Class

```swift
class NetworkManager: NSObject, ObservableObject {
    @Published var connectedPlayers: [Player]
    @Published var connectionState: ConnectionState
    @Published var latency: TimeInterval
}
```

#### ConnectionState

```swift
enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(Error)
}
```

#### Methods

```swift
// Connection
func connect(to session: GameSession) async throws
func disconnect()

// Data Transmission
func sendPlayerInput(_ input: PlayerInput) throws
func sendGameState(_ state: GameStateSnapshot) throws

// Receiving
func handleIncomingData(_ data: Data)
```

#### PlayerInput

```swift
struct PlayerInput: Codable {
    var timestamp: TimeInterval
    var sequence: UInt32
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var actions: PlayerActions
}
```

#### PlayerActions

```swift
struct PlayerActions: OptionSet, Codable {
    static let shoot = PlayerActions(rawValue: 1 << 0)
    static let reload = PlayerActions(rawValue: 1 << 1)
    static let jump = PlayerActions(rawValue: 1 << 2)
    static let crouch = PlayerActions(rawValue: 1 << 3)
    static let switchWeapon = PlayerActions(rawValue: 1 << 4)
}
```

**Example**:
```swift
let network = NetworkManager()
await network.connect(to: session)

let input = PlayerInput(
    timestamp: CACurrentMediaTime(),
    sequence: 1,
    position: [0, 1.6, 0],
    rotation: simd_quatf(),
    actions: [.shoot]
)
network.sendPlayerInput(input)
```

---

## Views

### MainMenuView

Main menu interface.

**Location**: `TacticalTeamShooters/Views/UI/MainMenuView.swift`

```swift
struct MainMenuView: View {
    @StateObject private var gameState = GameStateManager()

    var body: some View {
        // SwiftUI implementation
    }
}
```

---

### GameHUDView

In-game heads-up display.

**Location**: `TacticalTeamShooters/Views/HUD/GameHUDView.swift`

```swift
struct GameHUDView: View {
    @ObservedObject var player: Player

    var body: some View {
        // HUD elements: health, ammo, score
    }
}
```

---

### BattlefieldView

Main gameplay RealityKit view.

**Location**: `TacticalTeamShooters/Scenes/GameScene/BattlefieldView.swift`

```swift
struct BattlefieldView: View {
    @StateObject private var arSessionManager = ARSessionManager()

    var body: some View {
        RealityView { content in
            // RealityKit scene setup
        }
    }
}
```

---

## Utilities

### Extensions

#### SIMD Codable

Makes SIMD types Codable for networking:

```swift
extension SIMD3: Codable where Scalar == Float {
    // Codable implementation
}

extension simd_quatf: Codable {
    // Codable implementation
}
```

**Example**:
```swift
let position = SIMD3<Float>(1, 2, 3)
let data = try JSONEncoder().encode(position)
let decoded = try JSONDecoder().decode(SIMD3<Float>.self, from: data)
```

---

## Constants

### Game Constants

```swift
enum GameConstants {
    static let maxPlayers = 10
    static let teamSize = 5
    static let startingHealth = 100.0
    static let maxArmor = 100.0
    static let buyTime: TimeInterval = 45
    static let roundTime: TimeInterval = 115
    static let bombTimer: TimeInterval = 40
}
```

### Physics Constants

```swift
enum PhysicsConstants {
    static let gravity: Float = 9.81
    static let bulletDrag: Float = 0.02
    static let playerHeight: Float = 1.8
    static let playerRadius: Float = 0.3
    static let movementSpeed: Float = 5.0
}
```

---

## Error Handling

### Custom Errors

```swift
enum GameError: Error {
    case teamFull
    case playerNotFound
    case invalidWeapon
    case insufficientFunds
    case networkTimeout
}
```

**Example**:
```swift
do {
    try team.addPlayer(player)
} catch GameError.teamFull {
    print("Team is full")
}
```

---

## Threading & Concurrency

### Actor Isolation

```swift
actor PlayerManager {
    private var players: [UUID: Player] = [:]

    func addPlayer(_ player: Player) {
        players[player.id] = player
    }

    func getPlayer(_ id: UUID) -> Player? {
        players[id]
    }
}
```

### MainActor

UI updates must be on main thread:

```swift
@MainActor
class GameViewModel: ObservableObject {
    @Published var players: [Player] = []
}
```

---

## Performance Considerations

### Memory Management

- Use `struct` for value types (Player, Weapon, Team)
- Use `class` for reference types requiring identity
- Leverage Copy-on-Write for collections

### Optimization Tips

```swift
// ✅ Good: Efficient filtering
let alivePlayers = players.filter(\.isAlive)

// ❌ Bad: Multiple iterations
let alive = players.filter { $0.isAlive }
let count = alive.count
```

---

## Testing

### Unit Test Example

```swift
func testPlayerKDR() {
    var player = Player(username: "Test")
    player.stats.kills = 10
    player.stats.deaths = 5

    XCTAssertEqual(player.stats.kdr, 2.0)
}
```

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for complete testing guide.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-19 | Initial API documentation |

---

## Additional Resources

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) - Technical specifications
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [CODING_STANDARDS.md](CODING_STANDARDS.md) - Coding standards

For questions or clarifications, please open an issue on GitHub.
