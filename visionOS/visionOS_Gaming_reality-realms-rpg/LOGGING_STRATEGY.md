# Reality Realms RPG - Logging Strategy

## Table of Contents

- [Overview](#overview)
- [Logging Principles](#logging-principles)
- [Logging Levels](#logging-levels)
- [Using os_log](#using-oslog)
- [Structured Logging](#structured-logging)
- [Performance Logging](#performance-logging)
- [What to Log](#what-to-log)
- [What NOT to Log](#what-not-to-log)
- [Log Analysis](#log-analysis)
- [Privacy and Security](#privacy-and-security)
- [Debugging Workflows](#debugging-workflows)
- [Production Monitoring](#production-monitoring)

---

## Overview

Effective logging is essential for debugging, monitoring, and understanding Reality Realms RPG's behavior in development and production. This guide establishes logging standards and best practices.

### Why Logging Matters

1. **Debugging**: Understand what happened during development
2. **Performance**: Track performance metrics and identify bottlenecks
3. **User Issues**: Diagnose problems reported by players
4. **Analytics**: Understand game usage patterns
5. **Compliance**: Maintain audit trails for sensitive operations

### Logging Philosophy

- **Signal over Noise**: Log important events, not every operation
- **Context is King**: Include relevant context with every log
- **Performance Aware**: Logging should not impact frame rate
- **Privacy First**: Never log personally identifiable information
- **Actionable**: Logs should help you fix problems

---

## Logging Principles

### The Logging Hierarchy

```
            ┌──────────────┐
            │   CRITICAL   │  System-threatening errors (crashes)
            ├──────────────┤
           │     ERROR      │  Recoverable errors (failed operations)
           ├────────────────┤
          │     WARNING     │  Unexpected but handled situations
          ├─────────────────┤
         │       INFO       │  Important business events
         ├──────────────────┤
        │       DEBUG       │  Detailed debugging information
        └───────────────────┘
```

### Key Principles

1. **Be Specific**: "Player health updated: 80 → 60" not "Health changed"
2. **Be Consistent**: Use same format for similar events
3. **Be Concise**: Get to the point quickly
4. **Be Contextual**: Include relevant state information
5. **Be Timely**: Log at the right time (before/after operations)

### Logging Best Practices

```swift
// ❌ Bad logging
print("Error")
print("Thing happened")
print(someVariable)

// ✅ Good logging
logger.error("Failed to load save data: file not found at \(path)")
logger.info("Player \(playerID) entered combat with \(enemyCount) enemies")
logger.debug("Health component state: current=\(current), max=\(max), regen=\(regen)")
```

---

## Logging Levels

### Critical

**When**: System-threatening errors that will crash or severely impair the app

**Examples**:
- Unrecoverable memory errors
- Critical resource failures
- Data corruption detected

**Usage**:
```swift
logger.critical("Failed to initialize RealityKit: \(error.localizedDescription)")
logger.critical("Memory pressure critical: \(memoryMB)MB used, app will crash")
logger.critical("Save data corrupted beyond recovery: \(savePath)")
```

**Guidelines**:
- Use sparingly (should be rare in production)
- Include full context
- These may trigger crash reports

### Error

**When**: Operations fail but app can continue

**Examples**:
- Network request failed
- Asset failed to load
- Save/load failed

**Usage**:
```swift
logger.error("Failed to load texture '\(textureName)': \(error)")
logger.error("Multiplayer connection failed: timeout after \(timeout)s")
logger.error("Room mapping failed: insufficient tracking quality")
```

**Guidelines**:
- Include error details
- Log before recovery attempt
- Helps diagnose user-reported issues

### Warning

**When**: Unexpected but handled situations

**Examples**:
- Using fallback values
- Performance degradation
- Deprecated API usage

**Usage**:
```swift
logger.warning("FPS dropped below target: \(fps) < \(targetFPS)")
logger.warning("Using placeholder texture for missing asset: \(assetName)")
logger.warning("Entity count exceeded recommended limit: \(count) > \(limit)")
```

**Guidelines**:
- Indicates potential issues
- Helps identify edge cases
- May indicate future problems

### Info

**When**: Important business events and state changes

**Examples**:
- Game state transitions
- Player achievements
- Major system initialization

**Usage**:
```swift
logger.info("Game state: \(oldState) → \(newState)")
logger.info("Player leveled up: Lv\(level) (XP: \(xp))")
logger.info("Multiplayer session started: \(sessionID) with \(playerCount) players")
```

**Guidelines**:
- Track application flow
- Useful for understanding user sessions
- Should be understandable without code

### Debug

**When**: Detailed information for debugging

**Examples**:
- Function entry/exit
- Variable values
- Intermediate calculations

**Usage**:
```swift
logger.debug("updateAI() called for entity \(entityID), state: \(aiState)")
logger.debug("Combat calculation: damage=\(damage), multiplier=\(mult), final=\(final)")
logger.debug("Loaded \(assetCount) assets in \(duration)ms")
```

**Guidelines**:
- Disable in production (or filter)
- Include detailed context
- Don't worry about verbosity

---

## Using os_log

Apple's Unified Logging System is the recommended logging framework for visionOS.

### Setting Up Loggers

```swift
import os.log

// Subsystem: Reverse DNS of your app
// Category: Area of functionality
extension Logger {
    // Game subsystem
    static let game = Logger(subsystem: "com.realityrealms.rpg", category: "game")
    static let combat = Logger(subsystem: "com.realityrealms.rpg", category: "combat")
    static let ai = Logger(subsystem: "com.realityrealms.rpg", category: "ai")

    // Systems subsystem
    static let performance = Logger(subsystem: "com.realityrealms.rpg", category: "performance")
    static let networking = Logger(subsystem: "com.realityrealms.rpg", category: "networking")
    static let persistence = Logger(subsystem: "com.realityrealms.rpg", category: "persistence")

    // Spatial subsystem
    static let spatial = Logger(subsystem: "com.realityrealms.rpg", category: "spatial")
    static let arkit = Logger(subsystem: "com.realityrealms.rpg", category: "arkit")

    // UI subsystem
    static let ui = Logger(subsystem: "com.realityrealms.rpg", category: "ui")
}
```

### Basic Logging

```swift
import os.log

class GameStateManager {
    private let logger = Logger.game

    func transition(to newState: GameState) {
        let oldState = currentState

        logger.info("State transition: \(oldState.description) → \(newState.description)")

        currentState = newState

        logger.debug("State history updated: \(self.stateHistory.count) entries")
    }
}
```

### Privacy Annotations

Protect sensitive data:

```swift
// Public: Always logged
logger.info("Player joined game")

// Private: Redacted by default (shows <private>)
logger.info("Player name: \(playerName, privacy: .private)")

// Sensitive: Never logged, even when private data is enabled
logger.info("Password hash: \(hash, privacy: .sensitive)")

// Auto: Automatic privacy (default)
logger.info("Entity ID: \(entityID)")  // Treated as private
```

### String Interpolation

Use proper interpolation for performance:

```swift
// ✅ Good: Efficient
logger.debug("Player position: \(x), \(y), \(z)")

// ❌ Bad: Creates string even if debug disabled
logger.debug("Player position: \(String(describing: position))")
```

### Log Formatting

```swift
// Numbers
logger.info("FPS: \(fps, format: .fixed(precision: 1))")
logger.info("Memory: \(memoryMB, format: .fixed(precision: 2))MB")

// Alignment
logger.debug("Value: \(value, align: .right(columns: 10))")

// Custom formatting
logger.info("Duration: \(duration * 1000, format: .fixed(precision: 2))ms")
```

---

## Structured Logging

### Event-Based Logging

Log complete events with all context:

```swift
struct LogEvent {
    let timestamp: Date
    let level: OSLogType
    let category: String
    let message: String
    let metadata: [String: Any]

    func log() {
        let logger = Logger(subsystem: "com.realityrealms.rpg", category: category)

        let metadataStr = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        let fullMessage = "\(message) [\(metadataStr)]"

        switch level {
        case .debug:
            logger.debug("\(fullMessage)")
        case .info:
            logger.info("\(fullMessage)")
        case .error:
            logger.error("\(fullMessage)")
        default:
            logger.notice("\(fullMessage)")
        }
    }
}

// Usage
LogEvent(
    timestamp: Date(),
    level: .info,
    category: "combat",
    message: "Damage dealt",
    metadata: [
        "attacker": attackerID.uuidString,
        "target": targetID.uuidString,
        "damage": damage,
        "type": damageType.rawValue,
        "critical": isCritical
    ]
).log()
```

### Signposts for Performance

Track time intervals:

```swift
import os.signpost

class PerformanceLogger {
    private let signposter = OSSignposter(subsystem: "com.realityrealms.rpg", category: .pointsOfInterest)

    func measureOperation<T>(name: String, operation: () throws -> T) rethrows -> T {
        let signpostID = signposter.makeSignpostID()
        let state = signposter.beginInterval(name, id: signpostID)

        defer {
            signposter.endInterval(name, state)
        }

        return try operation()
    }

    // Async version
    func measureOperation<T>(name: String, operation: () async throws -> T) async rethrows -> T {
        let signpostID = signposter.makeSignpostID()
        let state = signposter.beginInterval(name, id: signpostID)

        defer {
            signposter.endInterval(name, state)
        }

        return try await operation()
    }
}

// Usage
let perfLogger = PerformanceLogger()

let result = perfLogger.measureOperation(name: "Load Game State") {
    try loadGameState()
}

// View in Instruments: os_signpost interval "Load Game State"
```

### Activity Tracing

Track related operations:

```swift
import os.activity

func loadGameData() {
    os_activity_initiate("Load Game Data", .userInitiated) { activity in
        logger.info("Starting game data load")

        os_activity_scope(activity) {
            loadPlayerData()
            loadWorldState()
            loadInventory()
        }

        logger.info("Game data load complete")
    }
}
```

---

## Performance Logging

### Frame Performance

```swift
class PerformanceLogger {
    private let logger = Logger.performance
    private var frameCount = 0
    private var totalFrameTime: TimeInterval = 0
    private var slowFrameCount = 0

    func logFrame(deltaTime: TimeInterval) {
        frameCount += 1
        totalFrameTime += deltaTime

        let fps = 1.0 / deltaTime

        // Log slow frames
        if deltaTime > 0.0139 {  // > 72 FPS
            slowFrameCount += 1
            logger.warning("Slow frame: \(deltaTime * 1000, format: .fixed(precision: 2))ms (\(fps, format: .fixed(precision: 1)) FPS)")
        }

        // Log summary every 5 seconds
        if frameCount % 450 == 0 {  // 90 FPS * 5 seconds
            let avgFPS = Double(frameCount) / totalFrameTime

            logger.info("""
                Performance summary:
                  Avg FPS: \(avgFPS, format: .fixed(precision: 1))
                  Slow frames: \(self.slowFrameCount) (\(Double(self.slowFrameCount) / Double(self.frameCount) * 100, format: .fixed(precision: 1))%)
                  Total frames: \(self.frameCount)
                """)

            // Reset counters
            frameCount = 0
            totalFrameTime = 0
            slowFrameCount = 0
        }
    }
}
```

### System Performance

```swift
class SystemPerformanceLogger {
    private let logger = Logger.performance

    func logSystemUpdate(system: String, duration: TimeInterval, entityCount: Int) {
        let budgets: [String: TimeInterval] = [
            "Combat": 0.002,    // 2ms
            "AI": 0.0015,       // 1.5ms
            "Physics": 0.002,   // 2ms
            "Rendering": 0.004  // 4ms
        ]

        if let budget = budgets[system], duration > budget {
            logger.warning("\(system) over budget: \(duration * 1000, format: .fixed(precision: 2))ms (budget: \(budget * 1000, format: .fixed(precision: 2))ms, entities: \(entityCount))")
        } else {
            logger.debug("\(system) update: \(duration * 1000, format: .fixed(precision: 2))ms (\(entityCount) entities)")
        }
    }
}

// Usage in systems
let startTime = Date()
// ... perform update ...
let duration = Date().timeIntervalSince(startTime)

SystemPerformanceLogger.shared.logSystemUpdate(
    system: "Combat",
    duration: duration,
    entityCount: combatEntities.count
)
```

### Memory Logging

```swift
class MemoryLogger {
    private let logger = Logger.performance

    func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            logger.error("Failed to get memory info")
            return
        }

        let usedMB = Double(info.resident_size) / 1024 / 1024
        let budgetMB = 4096.0  // 4GB budget

        if usedMB > budgetMB * 0.9 {
            logger.warning("Memory usage high: \(usedMB, format: .fixed(precision: 1))MB / \(budgetMB, format: .fixed(precision: 0))MB")
        } else {
            logger.debug("Memory usage: \(usedMB, format: .fixed(precision: 1))MB")
        }
    }
}
```

---

## What to Log

### Game State Changes

```swift
// State transitions
logger.info("Game state: \(oldState) → \(newState)")

// Gameplay events
logger.info("Player entered combat with \(enemyCount) enemies")
logger.info("Quest '\(questName)' completed")
logger.info("Player leveled up: \(level - 1) → \(level)")

// Multiplayer events
logger.info("Player joined: \(playerName)")
logger.info("Multiplayer session started: \(sessionID)")
```

### System Initialization

```swift
logger.info("🎮 Game initialized")
logger.info("📡 EventBus initialized")
logger.info("📊 PerformanceMonitor started")
logger.info("🎯 GameStateManager ready")
logger.debug("Loaded \(entityCount) entities from save data")
```

### Errors and Warnings

```swift
// All errors
logger.error("Failed to load asset '\(name)': \(error)")

// Performance warnings
logger.warning("FPS below target: \(fps) < \(targetFPS)")

// Validation warnings
logger.warning("Entity count exceeds limit: \(count) > \(maxCount)")
```

### User Actions

```swift
// Major actions
logger.info("Player cast spell: \(spellName)")
logger.info("Player equipped item: \(itemName)")

// Don't log every minor action
// logger.debug("Player moved")  // Too noisy!
```

### Asset Loading

```swift
logger.info("Loading assets for level: \(levelName)")
logger.debug("Loaded texture: \(textureName) (\(sizeKB)KB)")
logger.info("Asset loading complete: \(assetCount) assets in \(duration, format: .fixed(precision: 2))s")
```

### Network Operations

```swift
logger.info("Connecting to server: \(serverURL)")
logger.debug("Sending packet: \(packetType) (\(sizeBytes) bytes)")
logger.info("Multiplayer sync: \(playerCount) players, latency \(latency, format: .fixed(precision: 0))ms")
```

---

## What NOT to Log

### Personally Identifiable Information (PII)

```swift
// ❌ NEVER log these
logger.info("Player email: \(email)")  // PII
logger.info("Player name: \(realName)")  // PII (use privacy: .private or UUID)
logger.info("Device ID: \(deviceID)")  // PII
logger.info("Location: \(coordinates)")  // PII

// ✅ Use anonymized identifiers
logger.info("Player: \(playerID.uuidString)")  // UUID, not real name
logger.info("Session: \(sessionID.uuidString)")
```

### Passwords and Secrets

```swift
// ❌ NEVER log these
logger.info("Password: \(password)")
logger.info("Auth token: \(token)")
logger.info("API key: \(apiKey)")

// ✅ Log that authentication occurred, not credentials
logger.info("User authenticated successfully")
```

### High-Frequency Events

```swift
// ❌ Don't log every frame
func update(deltaTime: TimeInterval) {
    logger.debug("Update called")  // Called 90 times/second!
}

// ✅ Log summaries or threshold breaches
func update(deltaTime: TimeInterval) {
    frameCount += 1

    if frameCount % 450 == 0 {  // Every 5 seconds
        logger.debug("Processed \(frameCount) frames")
        frameCount = 0
    }
}
```

### Redundant Information

```swift
// ❌ Redundant logging
logger.info("Starting combat")
// ... combat code ...
logger.info("Combat started")  // Redundant!

// ✅ Log once with complete info
logger.info("Combat started: \(enemyCount) enemies, difficulty: \(difficulty)")
```

### Large Data Structures

```swift
// ❌ Don't log entire arrays/dictionaries
logger.debug("All entities: \(allEntities)")  // Could be hundreds!

// ✅ Log summaries
logger.debug("Entity count: \(allEntities.count)")
logger.debug("Active entities: \(allEntities.filter { $0.isActive }.count)")
```

---

## Log Analysis

### Viewing Logs in Console

**Console.app** (macOS):

1. Open Console app
2. Connect Vision Pro device
3. Filter by subsystem: `com.realityrealms.rpg`
4. Filter by category: `game`, `combat`, etc.
5. Filter by level: Error, Warning, Info, Debug

**Xcode Console**:

1. Run app in Xcode
2. View console (⌘⇧Y)
3. Filter using search box

### Command Line Tools

```bash
# View logs from device
log show --predicate 'subsystem == "com.realityrealms.rpg"' --last 1h

# Filter by category
log show --predicate 'subsystem == "com.realityrealms.rpg" && category == "combat"'

# Filter by level
log show --predicate 'subsystem == "com.realityrealms.rpg" && messageType >= "error"'

# Export logs
log collect --output ~/Desktop/realityrealms.logarchive

# Stream live logs
log stream --predicate 'subsystem == "com.realityrealms.rpg"'
```

### Log Patterns to Look For

#### Performance Issues

```
grep "FPS below" logs.txt
grep "over budget" logs.txt
grep "Memory usage high" logs.txt
```

#### Error Chains

```
grep "ERROR" logs.txt | head -20
# Look for patterns in error sequences
```

#### State Transitions

```
grep "State transition" logs.txt
# Verify expected state flow
```

---

## Privacy and Security

### GDPR Compliance

```swift
// Anonymize all user data
struct UserEventLogger {
    func logEvent(_ event: String, userID: UUID) {
        // Use anonymized ID, not real name/email
        logger.info("\(event) [user: \(userID.uuidString, privacy: .private)]")
    }
}
```

### Privacy Best Practices

1. **Default to Private**: Mark all strings as private
   ```swift
   logger.info("User action: \(action, privacy: .private)")
   ```

2. **Use UUIDs**: Never log real names or emails
   ```swift
   let playerID = UUID()  // Use this
   let playerName = "John"  // Never log this
   ```

3. **Sanitize Input**: Remove sensitive data before logging
   ```swift
   func sanitize(_ text: String) -> String {
       // Remove email patterns
       return text.replacingOccurrences(
           of: #"\S+@\S+\.\S+"#,
           with: "[email]",
           options: .regularExpression
       )
   }
   ```

4. **Audit Logs**: Review logs for accidental PII leakage

---

## Debugging Workflows

### Debug Mode Logging

```swift
#if DEBUG
let logger = Logger(subsystem: "com.realityrealms.rpg", category: "debug")

func debugLog(_ message: String, file: String = #file, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    logger.debug("[\(fileName):\(line)] \(message)")
}
#else
func debugLog(_ message: String, file: String = #file, line: Int = #line) {
    // No-op in release
}
#endif

// Usage
debugLog("Player position: \(position)")
```

### Conditional Logging

```swift
class GameLogger {
    private let logger = Logger.game

    // Control logging with environment variable
    private let verboseLogging = ProcessInfo.processInfo.environment["VERBOSE_LOGGING"] == "1"

    func debug(_ message: String) {
        if verboseLogging {
            logger.debug("\(message)")
        }
    }
}

// Set in Xcode scheme: Edit Scheme → Run → Arguments → Environment Variables
// VERBOSE_LOGGING = 1
```

### Feature Flags for Logging

```swift
enum LogFeature: String {
    case combat
    case ai
    case networking
    case physics

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "log_\(rawValue)")
    }
}

// Usage
if LogFeature.combat.isEnabled {
    logger.debug("Combat details: \(details)")
}

// Enable via settings or developer menu
UserDefaults.standard.set(true, forKey: "log_combat")
```

---

## Production Monitoring

### Crash Reporting Integration

```swift
class CrashLogger {
    func logCriticalError(_ error: Error, context: String) {
        // Log to os_log
        Logger.game.critical("\(context): \(error.localizedDescription)")

        // Also send to crash reporting service
        #if !DEBUG
        // Integrate with Crashlytics, Sentry, etc.
        logToCrashService(error, context: context)
        #endif
    }
}
```

### Analytics Events

```swift
struct AnalyticsLogger {
    func logEvent(_ event: String, parameters: [String: Any] = [:]) {
        // Log locally
        Logger.game.info("Analytics: \(event) \(parameters)")

        // Send to analytics service (not PII!)
        #if !DEBUG
        Analytics.logEvent(event, parameters: parameters)
        #endif
    }
}

// Usage
AnalyticsLogger.shared.logEvent("level_complete", parameters: [
    "level": 5,
    "duration": 123.4,
    "enemies_defeated": 15
])
```

### Remote Logging

```swift
class RemoteLogger {
    func sendLogs() async {
        // Collect recent logs
        let logs = collectRecentLogs()

        // Anonymize
        let sanitized = logs.map { sanitize($0) }

        // Send to server (only in production, opt-in)
        if userConsentedToLogging {
            try? await uploadLogs(sanitized)
        }
    }
}
```

---

## Example: Complete Logging Setup

```swift
import os.log

// MARK: - Logger Extension

extension Logger {
    // Game loggers
    static let game = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "game")
    static let combat = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "combat")
    static let ai = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ai")

    // System loggers
    static let performance = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "performance")
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    static let persistence = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "persistence")

    // Spatial loggers
    static let spatial = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "spatial")
}

// MARK: - Logging Helper

class GameLogger {
    static let shared = GameLogger()

    private init() {}

    func logStateChange(from: GameState, to: GameState) {
        Logger.game.info("State: \(from.description) → \(to.description)")
    }

    func logCombatEvent(attacker: UUID, target: UUID, damage: Int) {
        Logger.combat.info("Damage: \(damage) [\(attacker.uuidString, privacy: .private) → \(target.uuidString, privacy: .private)]")
    }

    func logPerformanceWarning(system: String, duration: TimeInterval, budget: TimeInterval) {
        Logger.performance.warning("\(system) over budget: \(duration * 1000, format: .fixed(precision: 2))ms > \(budget * 1000, format: .fixed(precision: 2))ms")
    }

    func logError(_ error: Error, context: String) {
        Logger.game.error("\(context): \(error.localizedDescription)")
    }
}

// MARK: - Usage Examples

class CombatSystem {
    func performAttack(attacker: GameEntity, target: GameEntity) {
        Logger.combat.debug("performAttack() called [attacker=\(attacker.id), target=\(target.id)]")

        let damage = calculateDamage(attacker, target)

        Logger.combat.info("Attack: \(damage) damage dealt")

        GameLogger.shared.logCombatEvent(
            attacker: attacker.id,
            target: target.id,
            damage: damage
        )
    }
}

class GameStateManager {
    func transition(to newState: GameState) {
        let oldState = currentState

        GameLogger.shared.logStateChange(from: oldState, to: newState)

        currentState = newState
    }
}
```

---

## Quick Reference

### When to Use Each Level

| Level    | When to Use | Example |
|----------|-------------|---------|
| Critical | App-threatening errors | `Failed to initialize Metal` |
| Error | Operation failures | `Failed to load save data` |
| Warning | Unexpected situations | `FPS below target` |
| Info | Important events | `Player leveled up` |
| Debug | Detailed debugging | `Entity position updated` |

### Log Format Template

```swift
// State change
logger.info("\(component): \(oldValue) → \(newValue)")

// Operation start
logger.debug("\(operation)() called [\(context)]")

// Operation complete
logger.info("\(operation) complete: \(result) (\(duration)ms)")

// Error
logger.error("\(operation) failed: \(error) [\(context)]")

// Performance
logger.warning("\(system) over budget: \(actual)ms > \(budget)ms")
```

---

**Logging Strategy Version**: 1.0
**Last Updated**: 2025-11-19
**Maintained By**: Reality Realms Development Team

---

**Remember**: Log what you need to debug, but respect user privacy. When in doubt, log less rather than more.
