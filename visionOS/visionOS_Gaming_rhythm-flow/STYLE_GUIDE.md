# Swift Style Guide - Rhythm Flow

This style guide defines coding standards for Rhythm Flow. Consistent code style improves readability and maintainability.

---

## Table of Contents

1. [General Principles](#general-principles)
2. [Naming Conventions](#naming-conventions)
3. [Code Organization](#code-organization)
4. [Spacing and Formatting](#spacing-and-formatting)
5. [Comments and Documentation](#comments-and-documentation)
6. [Swift Language Features](#swift-language-features)
7. [visionOS Specific](#visionos-specific)
8. [SwiftLint Configuration](#swiftlint-configuration)

---

## General Principles

### Clarity at the Point of Use

**Code should be clear and explicit:**

```swift
// ✅ Good - Clear intent
let averageScore = scores.reduce(0, +) / scores.count

// ❌ Bad - Unclear abbreviations
let avg = scrs.reduce(0, +) / scrs.count
```

### Prefer Clarity Over Brevity

```swift
// ✅ Good - Descriptive name
func calculateComboBonusMultiplier(for comboCount: Int) -> Float

// ❌ Bad - Too terse
func calcBonus(c: Int) -> Float
```

### Write for Readers

Code is read more often than written. Optimize for readability.

---

## Naming Conventions

### Types and Protocols

**PascalCase** for types, protocols, and enums:

```swift
// ✅ Good
class ScoreManager { }
protocol Hittable { }
enum NoteType { }
struct PlayerProfile { }

// ❌ Bad
class score_manager { }
protocol hittable { }
```

### Functions and Variables

**camelCase** for functions, variables, and constants:

```swift
// ✅ Good
var currentCombo: Int = 0
let maxComboMultiplier: Float = 2.5
func registerHit(_ quality: HitQuality) { }

// ❌ Bad
var CurrentCombo: Int = 0
let MAX_COMBO_MULTIPLIER: Float = 2.5
func RegisterHit(_ quality: HitQuality) { }
```

### Constants

Use **lowercase camelCase** even for constants (not SCREAMING_SNAKE_CASE):

```swift
// ✅ Good
let maxPlayers = 4
let defaultDifficulty: Difficulty = .normal
private let spawnLeadTime: TimeInterval = 2.0

// ❌ Bad
let MAX_PLAYERS = 4
let DEFAULT_DIFFICULTY: Difficulty = .normal
```

### Enums

Use **singular** names for enums, **lowercase** for cases:

```swift
// ✅ Good
enum Difficulty {
    case easy
    case normal
    case hard
    case expert
    case expertPlus
}

// ❌ Bad
enum Difficulties {  // Plural
    case Easy        // Uppercase
    case Normal
}
```

### Protocols

**Descriptive names** without suffixes like "Protocol":

```swift
// ✅ Good
protocol Hittable {
    func onHit(_ quality: HitQuality)
}

protocol ScoreCalculating {
    func calculateScore() -> Int
}

// ❌ Bad
protocol HittableProtocol { }  // Redundant suffix
protocol IHittable { }         // Hungarian notation
```

### Abbreviations

**Avoid abbreviations** unless universally understood:

```swift
// ✅ Good
let urlString: String
let htmlParser: HTMLParser
let userIdentifier: UUID

// ❌ Bad
let usrId: UUID
let bgColor: UIColor
```

---

## Code Organization

### File Structure

```swift
// 1. Imports
import SwiftUI
import RealityKit

// 2. Type Definition
@Observable
class ScoreManager {

    // 3. Properties
    // 3a. Public properties
    private(set) var currentScore: Int = 0

    // 3b. Private properties
    private let comboMultipliers: [Int: Float]

    // 4. Initialization
    init() {
        // Setup
    }

    // 5. Public Methods
    func registerHit(_ quality: HitQuality, noteValue: Int) {
        // Implementation
    }

    // 6. Private Methods
    private func updateMultiplier() {
        // Implementation
    }
}

// 7. Extensions
extension ScoreManager {
    func exportStatistics() -> [String: Any] {
        // Implementation
    }
}
```

### MARK Comments

Use `// MARK:` to organize code sections:

```swift
class GameEngine {

    // MARK: - Properties

    private var activeNotes: [UUID: NoteEntity] = [:]
    private var notePool: NoteEntityPool

    // MARK: - Initialization

    init() {
        // Setup
    }

    // MARK: - Public Methods

    func update(deltaTime: TimeInterval) async {
        // Implementation
    }

    // MARK: - Private Methods

    private func spawnNotes() {
        // Implementation
    }

    // MARK: - Helper Methods

    private func cleanupNotes() {
        // Implementation
    }
}
```

### Extension Organization

Group related functionality in extensions:

```swift
// MARK: - Codable Conformance
extension PlayerProfile: Codable {
    // Encoding/decoding logic
}

// MARK: - Equatable Conformance
extension PlayerProfile: Equatable {
    static func == (lhs: PlayerProfile, rhs: PlayerProfile) -> Bool {
        lhs.id == rhs.id
    }
}
```

---

## Spacing and Formatting

### Indentation

**4 spaces** (no tabs):

```swift
// ✅ Good
func registerHit(_ quality: HitQuality) {
    if quality == .perfect {
        currentCombo += 1
    }
}
```

### Line Length

**Maximum 120 characters** per line:

```swift
// ✅ Good - Break long function calls
let result = calculateFinalScore(
    baseScore: score,
    accuracy: accuracy,
    combo: maxCombo,
    multiplier: multiplier
)

// ❌ Bad - Too long
let result = calculateFinalScore(baseScore: score, accuracy: accuracy, combo: maxCombo, multiplier: multiplier, bonuses: bonuses)
```

### Braces

**Opening brace on same line**, closing brace on new line:

```swift
// ✅ Good
if condition {
    doSomething()
}

// ❌ Bad
if condition
{
    doSomething()
}
```

### Spacing

**One blank line** between methods, **no blank lines** inside methods (unless grouping):

```swift
class ScoreManager {
    func methodOne() {
        // Implementation
    }

    func methodTwo() {
        // Implementation
    }
}
```

### Commas

**Space after comma**, no space before:

```swift
// ✅ Good
let array = [1, 2, 3, 4]
func foo(a: Int, b: Int, c: Int)

// ❌ Bad
let array = [1,2,3,4]
func foo(a: Int,b: Int,c: Int)
```

### Colons

**No space before colon**, space after:

```swift
// ✅ Good
var dictionary: [String: Int]
class ScoreManager: ObservableObject

// ❌ Bad
var dictionary : [String : Int]
class ScoreManager : ObservableObject
```

---

## Comments and Documentation

### Documentation Comments

Use **triple-slash (`///`)** for public APIs:

```swift
/// Registers a hit event and updates the score.
///
/// This method updates the current score, combo counter, and multiplier
/// based on the quality of the hit and the note's base value.
///
/// - Parameters:
///   - quality: The hit quality (Perfect, Great, Good, Okay, or Miss)
///   - noteValue: The base point value of the note
///
/// - Returns: The points earned for this hit (after multipliers)
public func registerHit(_ quality: HitQuality, noteValue: Int) -> Int {
    // Implementation
}
```

### Inline Comments

Use **double-slash (`//`)** for inline comments:

```swift
// Calculate bonus points for perfect hits
let bonus = quality == .perfect ? 15 : 0

// Update combo multiplier at milestones
if currentCombo >= 100 {
    multiplier = 2.0  // 2x multiplier at 100 combo
}
```

### TODO and FIXME

```swift
// TODO: Implement haptic feedback for hits
// FIXME: Hit detection occasionally misses notes at high BPM
// MARK: - Deprecated - Remove in v2.0
```

### Avoid Obvious Comments

```swift
// ❌ Bad - Obvious
currentCombo += 1  // Increment combo

// ✅ Good - Adds value
currentCombo += 1  // Maintain combo streak for multiplier calculation
```

---

## Swift Language Features

### Type Inference

**Use type inference** where type is obvious:

```swift
// ✅ Good
let name = "Rhythm Flow"
let count = 10
var scores: [Int] = []  // Type annotation when empty

// ❌ Bad - Unnecessary annotations
let name: String = "Rhythm Flow"
let count: Int = 10
```

### Optionals

**Avoid force unwrapping** (`!`) unless absolutely safe:

```swift
// ✅ Good - Safe unwrapping
if let score = scores.first {
    print(score)
}

guard let username = profile.username else {
    return
}

// ❌ Bad - Force unwrap
let score = scores.first!  // Will crash if empty
```

### Guard Statements

**Use guard** for early exits:

```swift
// ✅ Good
guard quality != .miss else {
    resetCombo()
    return
}

currentCombo += 1
updateMultiplier()

// ❌ Bad - Deep nesting
if quality != .miss {
    currentCombo += 1
    updateMultiplier()
} else {
    resetCombo()
}
```

### Closures

**Trailing closure syntax** when last parameter:

```swift
// ✅ Good
noteEvents.filter { $0.timestamp > currentTime }
scores.sorted { $0 > $1 }

// ❌ Bad
noteEvents.filter({ $0.timestamp > currentTime })
```

**Implicit returns** for single-expression closures:

```swift
// ✅ Good
let doubled = numbers.map { $0 * 2 }

// ❌ Bad - Unnecessary return
let doubled = numbers.map { return $0 * 2 }
```

### Access Control

**Be explicit** about access levels:

```swift
// ✅ Good
public class ScoreManager {
    public private(set) var currentScore: Int = 0
    private var multiplier: Float = 1.0

    public func registerHit(_ quality: HitQuality) {
        // Public API
    }

    private func updateMultiplier() {
        // Internal implementation
    }
}
```

### Property Observers

```swift
var currentCombo: Int = 0 {
    didSet {
        if currentCombo == 0 {
            multiplier = 1.0
        } else {
            updateMultiplier()
        }
    }
}
```

### Computed Properties

**Prefer computed properties** over getter methods:

```swift
// ✅ Good
var accuracy: Double {
    guard totalHits > 0 else { return 0 }
    return Double(successfulHits) / Double(totalHits)
}

// ❌ Bad
func getAccuracy() -> Double {
    guard totalHits > 0 else { return 0 }
    return Double(successfulHits) / Double(totalHits)
}
```

---

## visionOS Specific

### Observable Macro

Use `@Observable` for state management:

```swift
@Observable
class AppCoordinator {
    var gameState: GameState = .mainMenu
    var selectedSong: Song?

    func startGame() {
        gameState = .playing
    }
}
```

### Main Actor

**Annotate UI classes** with `@MainActor`:

```swift
@MainActor
class GameEngine {
    func update(deltaTime: TimeInterval) async {
        // Safe to update UI
    }
}
```

### Async/Await

**Prefer async/await** over completion handlers:

```swift
// ✅ Good
func loadSong(_ song: Song) async throws {
    let audio = try await audioEngine.load(song.audioFileName)
    let beatMap = try await loadBeatMap(song.beatMapFileNames[difficulty]!)
    // Continue...
}

// ❌ Bad - Completion handlers
func loadSong(_ song: Song, completion: @escaping (Result<Void, Error>) -> Void) {
    // Callback hell
}
```

### RealityKit Entities

```swift
// Organize entity creation in separate methods
private func createNoteEntity(for noteEvent: NoteEvent) -> ModelEntity {
    let mesh = MeshResource.generateBox(size: 0.1)
    let material = SimpleMaterial(color: .cyan, isMetallic: true)
    return ModelEntity(mesh: mesh, materials: [material])
}
```

---

## SwiftLint Configuration

Create `.swiftlint.yml` in project root:

```yaml
included:
  - RhythmFlow/RhythmFlow
excluded:
  - Pods
  - RhythmFlow/RhythmFlow.xcodeproj

disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - explicit_init
  - force_unwrapping

line_length:
  warning: 120
  error: 150
  ignores_comments: true

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500

identifier_name:
  min_length:
    warning: 2
  max_length:
    warning: 50
    error: 60
  excluded:
    - id
    - x
    - y
    - z

cyclomatic_complexity:
  warning: 15
  error: 25
```

---

## Best Practices Summary

### Do ✅

- Use descriptive names
- Prefer `let` over `var`
- Use guard for early exits
- Document public APIs
- Use extensions for protocol conformance
- Prefer value types (struct) over reference types (class)
- Use Swift's native types
- Handle errors gracefully
- Write testable code
- Keep functions focused and small

### Don't ❌

- Force unwrap optionals (!)
- Use `try!` except in truly safe contexts
- Leave commented-out code
- Use magic numbers (define constants)
- Create deep nesting (>3 levels)
- Make classes when structs will do
- Ignore compiler warnings
- Use Objective-C patterns unnecessarily
- Abbreviate names cryptically
- Write functions longer than 50 lines

---

## Examples

### Good Code Example

```swift
import RealityKit
import SwiftUI

/// Manages the player's score, combo, and statistics during gameplay.
@Observable
@MainActor
public class ScoreManager {

    // MARK: - Public Properties

    /// Current score for the active session
    public private(set) var currentScore: Int = 0

    /// Current combo count (consecutive successful hits)
    public private(set) var currentCombo: Int = 0

    /// Active score multiplier based on combo milestones
    public private(set) var multiplier: Float = 1.0

    // MARK: - Private Properties

    /// Combo thresholds and their corresponding multipliers
    private let comboMultipliers: [Int: Float] = [
        10: 1.1,
        25: 1.25,
        50: 1.5,
        100: 2.0,
        200: 2.5
    ]

    /// Statistics for the current session
    private var statistics: SessionStatistics

    // MARK: - Initialization

    public init() {
        self.statistics = SessionStatistics()
    }

    // MARK: - Public Methods

    /// Registers a hit and calculates points earned.
    ///
    /// - Parameters:
    ///   - quality: The quality of the hit
    ///   - noteValue: Base point value of the note
    /// - Returns: Total points earned including bonuses
    public func registerHit(_ quality: HitQuality, noteValue: Int) -> Int {
        guard quality != .miss else {
            resetCombo()
            statistics.missedHits += 1
            return 0
        }

        // Update statistics
        updateStatistics(for: quality)

        // Calculate points
        let basePoints = noteValue
        let qualityBonus = calculateQualityBonus(for: quality, basePoints: basePoints)
        let totalPoints = Int(Float(basePoints + qualityBonus) * multiplier)

        // Update score and combo
        currentScore += totalPoints
        currentCombo += 1
        updateMultiplier()

        return totalPoints
    }

    // MARK: - Private Methods

    /// Updates the multiplier based on current combo count
    private func updateMultiplier() {
        // Find the highest applicable multiplier
        let applicableMultipliers = comboMultipliers
            .filter { $0.key <= currentCombo }
            .values

        multiplier = applicableMultipliers.max() ?? 1.0
    }

    /// Calculates quality bonus points
    private func calculateQualityBonus(for quality: HitQuality, basePoints: Int) -> Int {
        switch quality {
        case .perfect:
            return Int(Float(basePoints) * 0.15)  // 15% bonus
        case .great:
            return Int(Float(basePoints) * 0.10)  // 10% bonus
        case .good:
            return Int(Float(basePoints) * 0.05)  // 5% bonus
        case .okay, .miss:
            return 0
        }
    }

    /// Resets the combo counter and multiplier
    private func resetCombo() {
        currentCombo = 0
        multiplier = 1.0
    }

    /// Updates session statistics
    private func updateStatistics(for quality: HitQuality) {
        switch quality {
        case .perfect:
            statistics.perfectHits += 1
        case .great:
            statistics.greatHits += 1
        case .good:
            statistics.goodHits += 1
        case .okay:
            statistics.okayHits += 1
        case .miss:
            statistics.missedHits += 1
        }
    }
}

// MARK: - Supporting Types

private struct SessionStatistics {
    var perfectHits: Int = 0
    var greatHits: Int = 0
    var goodHits: Int = 0
    var okayHits: Int = 0
    var missedHits: Int = 0
}
```

---

**This style guide is a living document. Suggest improvements via pull requests!**

**Last Updated**: 2024
