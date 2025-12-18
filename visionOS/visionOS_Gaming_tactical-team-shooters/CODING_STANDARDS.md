# Coding Standards - Tactical Team Shooters

Swift coding standards and best practices for the project.

## General Principles

1. **Clarity over Brevity**: Code should be self-documenting
2. **Consistency**: Follow established patterns
3. **Safety**: Prefer safe constructs over force unwrapping
4. **Performance**: Write performant code, but profile first
5. **Testability**: Write code that's easy to test

## Naming Conventions

### Types (PascalCase)

```swift
// Classes
class GameStateManager { }
class NetworkManager { }

// Structs
struct Player { }
struct Weapon { }

// Enums
enum GameMode { }
enum TeamSide { }

// Protocols
protocol Damageable { }
protocol Movable { }
```

### Variables & Functions (camelCase)

```swift
// Variables
var playerHealth: Double
var currentWeapon: Weapon
let maxPlayers = 10

// Functions
func calculateDamage() -> Int
func updatePlayerPosition()
```

### Constants

```swift
// Global constants: PascalCase with namespace
enum GameConstants {
    static let MaxPlayers = 10
    static let RoundTime: TimeInterval = 115
}

// Local constants: camelCase
let maxSpeed: Float = 10.0
```

### Booleans

```swift
// Prefix with is/has/should/can
var isAlive: Bool
var hasWeapon: Bool
var shouldRespawn: Bool
var canShoot: Bool
```

## Code Organization

### File Structure

```swift
// 1. Imports
import SwiftUI
import RealityKit

// 2. Type Definition
struct Player: Codable {
    // 3. Properties
    let id: UUID
    var username: String

    // 4. Computed Properties
    var displayName: String {
        username
    }

    // 5. Initialization
    init(username: String) {
        self.id = UUID()
        self.username = username
    }

    // 6. Methods
    func takeDamage(_ amount: Double) {
        // Implementation
    }
}

// 7. Extensions
extension Player: Identifiable { }
```

### MARK Comments

```swift
class GameManager {
    // MARK: - Properties

    private var players: [Player] = []

    // MARK: - Lifecycle

    init() { }

    // MARK: - Public Methods

    func startGame() { }

    // MARK: - Private Methods

    private func resetState() { }
}
```

## Swift Language Features

### Optionals

```swift
// ❌ Avoid force unwrapping
let player = players[id]!

// ✅ Use optional binding
guard let player = players[id] else {
    return
}

// ✅ Use optional chaining
player?.takeDamage(10)

// ✅ Use nil coalescing
let health = player?.health ?? 100
```

### Type Inference

```swift
// ✅ Let Swift infer obvious types
let name = "Player1"
let count = 42
var players: [Player] = []  // Type needed for empty array

// ❌ Avoid redundant types
let name: String = "Player1"  // Redundant
```

### Access Control

```swift
// Always specify access control
public class GameManager { }
internal struct GameState { }
private var playerData: [Player]

// Default to private, expose only what's needed
private func helper() { }
public func publicAPI() { }
```

### Swift Concurrency

```swift
// Use async/await
func loadData() async throws -> Data {
    try await networkManager.fetch()
}

// Use actors for shared mutable state
actor PlayerManager {
    private var players: [UUID: Player] = [:]

    func addPlayer(_ player: Player) {
        players[player.id] = player
    }
}

// Mark UI code with @MainActor
@MainActor
class GameViewModel: ObservableObject {
    @Published var players: [Player] = []
}
```

### Error Handling

```swift
// Define custom errors
enum GameError: Error {
    case playerNotFound
    case teamFull
    case invalidWeapon
}

// Use throws for recoverable errors
func getPlayer(_ id: UUID) throws -> Player {
    guard let player = players[id] else {
        throw GameError.playerNotFound
    }
    return player
}

// Handle errors properly
do {
    let player = try getPlayer(id)
} catch GameError.playerNotFound {
    print("Player not found")
} catch {
    print("Unexpected error: \(error)")
}
```

## Code Style

### Spacing

```swift
// Space after commas
let array = [1, 2, 3]
func foo(a: Int, b: Int) { }

// Space around operators
let sum = a + b
let product = a * b

// No space for unary operators
let negative = -value
let unwrapped = optional!

// Space after control flow keywords
if condition { }
for item in items { }
while running { }
```

### Braces

```swift
// Opening brace on same line
if condition {
    doSomething()
}

// Closing brace on new line
func foo() {
    // Code
}

// Multiline: Closing brace aligned with opening
let closure = {
    print("Hello")
}
```

### Line Length

- **Maximum 120 characters**
- Break long lines logically

```swift
// ✅ Break long function calls
someFunction(
    parameter1: value1,
    parameter2: value2,
    parameter3: value3
)

// ✅ Break long conditions
if veryLongCondition1
    && veryLongCondition2
    && veryLongCondition3 {
    // Code
}
```

### Indentation

- **4 spaces** (no tabs)
- Align continuation lines

```swift
let result = someFunction(
    parameter1: value1,
    parameter2: value2
)  // 4 spaces
```

## Best Practices

### Use Value Types

```swift
// ✅ Prefer structs for data models
struct Player {
    var health: Double
}

// Classes only when needed
class GameEngine {
    // Requires identity or reference semantics
}
```

### Immutability

```swift
// ✅ Prefer let over var
let constant = 10

// Use var only when mutation needed
var mutableValue = 0
mutableValue += 1
```

### Guard for Early Returns

```swift
// ✅ Use guard for validation
func process(_ player: Player?) {
    guard let player = player else {
        return
    }

    // Happy path
    player.update()
}

// ❌ Avoid nested if
func process(_ player: Player?) {
    if let player = player {
        player.update()
    }
}
```

### Switch Exhaustiveness

```swift
// ✅ Handle all cases
switch gameMode {
case .teamDeathmatch:
    setupTDM()
case .bombDefusal:
    setupBombDefusal()
case .controlPoint:
    setupControlPoint()
// No default needed - compiler enforces exhaustiveness
}
```

### Trailing Closures

```swift
// ✅ Use trailing closure syntax
players.filter { $0.isAlive }

// ✅ Multiple trailing closures (Swift 5.3+)
UIView.animate(withDuration: 0.3) {
    view.alpha = 0
} completion: { _ in
    view.removeFromSuperview()
}
```

### Collection Methods

```swift
// ✅ Use functional methods
let alivePlayers = players.filter(\.isAlive)
let playerNames = players.map(\.username)
let totalHealth = players.reduce(0) { $0 + $1.health }

// ❌ Avoid manual loops when collection methods work
var names: [String] = []
for player in players {
    names.append(player.username)
}
```

## Documentation

### Function Documentation

```swift
/// Calculates damage based on weapon and distance.
///
/// This function considers weapon stats, distance falloff,
/// and armor mitigation.
///
/// - Parameters:
///   - weapon: The weapon used for the attack
///   - distance: Distance in meters
///   - armor: Target's armor value
/// - Returns: Final damage value
/// - Throws: `WeaponError` if weapon stats are invalid
func calculateDamage(
    weapon: Weapon,
    distance: Float,
    armor: Double
) throws -> Int {
    // Implementation
}
```

### Inline Comments

```swift
// MARK: - Player Management

// TODO: Implement player ranking system
// FIXME: Memory leak in player cleanup
// NOTE: This uses client-side prediction

// Explain complex logic
// Calculate time-to-kill based on RPM and damage
let shotsNeeded = ceil(100.0 / Double(damage))
let timeBetweenShots = 60.0 / fireRate
let ttk = (shotsNeeded - 1) * timeBetweenShots
```

## Performance Guidelines

### Avoid Premature Optimization

```swift
// ✅ Write clear code first
func findPlayer(_ id: UUID) -> Player? {
    players.first { $0.id == id }
}

// Optimize if profiling shows bottleneck
```

### Use Lazy Collections

```swift
// For expensive transformations
let results = hugeArray
    .lazy
    .filter { expensiveCheck($0) }
    .map { expensiveTransform($0) }
    .prefix(10)
```

### Prefer Structs

```swift
// Value types are generally faster
struct FastData {
    var value: Int
}

// Classes when reference semantics needed
class RequiresIdentity {
    var value: Int
}
```

## Testing

### Testable Code

```swift
// ✅ Inject dependencies
class GameManager {
    private let networkManager: NetworkManaging

    init(networkManager: NetworkManaging = NetworkManager()) {
        self.networkManager = networkManager
    }
}

// ❌ Hard-coded dependencies
class GameManager {
    private let networkManager = NetworkManager()
}
```

### Test Naming

```swift
func testPlayerStatsKDRWithDeaths() {
    // Given
    var player = Player(username: "Test")
    player.stats.kills = 10
    player.stats.deaths = 5

    // When
    let kdr = player.stats.kdr

    // Then
    XCTAssertEqual(kdr, 2.0)
}
```

## SwiftLint

Configure SwiftLint to enforce these standards:

```bash
# Install
brew install swiftlint

# Run
swiftlint

# Auto-fix
swiftlint --fix
```

See `.swiftlint.yml` for configuration.

## Code Review Checklist

See [CODE_REVIEW_CHECKLIST.md](CODE_REVIEW_CHECKLIST.md) for complete checklist.

## References

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
- [Google Swift Style Guide](https://google.github.io/swift/)
