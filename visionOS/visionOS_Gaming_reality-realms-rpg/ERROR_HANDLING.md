# Reality Realms RPG - Error Handling Guide

## Table of Contents

- [Overview](#overview)
- [Error Handling Philosophy](#error-handling-philosophy)
- [Swift Error Handling Patterns](#swift-error-handling-patterns)
- [Custom Error Types](#custom-error-types)
- [Error Propagation](#error-propagation)
- [Error Recovery Strategies](#error-recovery-strategies)
- [User-Facing Error Messages](#user-facing-error-messages)
- [Error Logging](#error-logging)
- [Testing Error Conditions](#testing-error-conditions)
- [Common Error Scenarios](#common-error-scenarios)
- [Best Practices](#best-practices)

---

## Overview

Robust error handling is critical for Reality Realms RPG. In a spatial computing game, errors can break immersion or, worse, cause motion sickness if they freeze or crash the experience.

### Goals

1. **User Experience**: Gracefully handle errors without disrupting gameplay
2. **Debugging**: Provide detailed error information for developers
3. **Recovery**: Automatically recover from errors when possible
4. **Transparency**: Inform users when manual intervention is needed
5. **Prevention**: Catch errors early in development

### Error Handling Principles

- **Fail Fast**: Detect errors early, don't let them propagate
- **Fail Safe**: Degrade gracefully rather than crashing
- **Fail Loudly**: Log errors comprehensively for debugging
- **Fail Informatively**: Provide actionable error messages to users

---

## Error Handling Philosophy

### The Error Handling Pyramid

```
                    ┌────────────────┐
                    │  Prevention    │  Design to avoid errors
                    ├────────────────┤
                   │   Validation     │  Check inputs, preconditions
                   ├──────────────────┤
                  │   Early Detection  │  Assert, guard statements
                  ├────────────────────┤
                 │   Graceful Recovery  │  Handle errors, fallback
                 ├──────────────────────┤
                │   User Communication   │  Show user-friendly messages
                └────────────────────────┘
```

### Error Categories

Reality Realms categorizes errors into four types:

1. **Programming Errors**: Bugs in code (precondition failures)
   - **Handling**: Assertions, crashes in debug builds
   - **Example**: Accessing array out of bounds

2. **Recoverable Errors**: Expected failures
   - **Handling**: Swift error handling, recovery logic
   - **Example**: Network timeout, file not found

3. **System Errors**: Platform/hardware failures
   - **Handling**: Graceful degradation, user notification
   - **Example**: Spatial tracking lost, low memory

4. **User Errors**: Invalid user input
   - **Handling**: Validation, user feedback
   - **Example**: Invalid character name, insufficient space

---

## Swift Error Handling Patterns

### Using throw/try/catch

Swift's native error handling is our primary mechanism.

#### Basic Pattern

```swift
enum NetworkError: Error {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
}

func fetchData() throws -> Data {
    guard hasConnection() else {
        throw NetworkError.noConnection
    }

    guard let data = performRequest() else {
        throw NetworkError.timeout
    }

    return data
}

// Usage
do {
    let data = try fetchData()
    process(data)
} catch NetworkError.noConnection {
    print("No network connection")
} catch NetworkError.timeout {
    print("Request timed out")
} catch {
    print("Unknown error: \(error)")
}
```

#### Propagating Errors

Let errors propagate up the call stack:

```swift
func loadGame() throws -> GameState {
    let saveData = try loadSaveData()          // Can throw
    let validated = try validate(saveData)     // Can throw
    return try deserialize(validated)          // Can throw
}

// Caller handles all errors
do {
    let gameState = try loadGame()
    startGame(with: gameState)
} catch {
    handleLoadError(error)
}
```

#### Optional Try (try?)

Convert errors to optionals for non-critical operations:

```swift
// Returns nil if error occurs
let config = try? loadConfiguration()

// Provide default if load fails
let settings = try? loadSettings() ?? defaultSettings
```

⚠️ **Warning**: Only use `try?` when you don't need to know why the operation failed.

#### Forced Try (try!)

Only use when you're absolutely certain an error can't occur:

```swift
// Safe because bundle resources are guaranteed to exist
let defaultImage = try! loadBundleImage("default_avatar")
```

⚠️ **Warning**: Crashes if error occurs. Only use in development or when guaranteed safe.

### Result Type

Use `Result` for asynchronous operations or when storing results:

```swift
func loadAssetAsync(
    _ name: String,
    completion: @escaping (Result<Asset, Error>) -> Void
) {
    DispatchQueue.global().async {
        do {
            let asset = try loadAsset(name)
            completion(.success(asset))
        } catch {
            completion(.failure(error))
        }
    }
}

// Usage
loadAssetAsync("player_model") { result in
    switch result {
    case .success(let asset):
        applyAsset(asset)
    case .failure(let error):
        handleError(error)
    }
}
```

### Async/Await Error Handling

For modern Swift concurrency:

```swift
func loadGameAsync() async throws -> GameState {
    let saveData = try await loadSaveDataAsync()
    let validated = try await validateAsync(saveData)
    return try await deserializeAsync(validated)
}

// Usage
Task {
    do {
        let gameState = try await loadGameAsync()
        await startGame(with: gameState)
    } catch {
        await handleError(error)
    }
}
```

---

## Custom Error Types

### Defining Game Errors

Create domain-specific error types with context:

```swift
enum GameError: Error {
    case roomMappingFailed
    case spatialTrackingLost
    case saveDataCorrupted
    case multiplayerConnectionFailed
    case insufficientSpace
    case assetLoadFailed(assetName: String)
    case invalidGameState(current: GameState, attempted: GameState)
}
```

### LocalizedError Protocol

Provide user-friendly error messages:

```swift
extension GameError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .roomMappingFailed:
            return "Failed to map your room"

        case .spatialTrackingLost:
            return "Spatial tracking lost"

        case .saveDataCorrupted:
            return "Save data is corrupted"

        case .multiplayerConnectionFailed:
            return "Failed to connect to multiplayer session"

        case .insufficientSpace:
            return "Insufficient play space"

        case .assetLoadFailed(let assetName):
            return "Failed to load asset: \(assetName)"

        case .invalidGameState(let current, let attempted):
            return "Cannot transition from \(current) to \(attempted)"
        }
    }

    var failureReason: String? {
        switch self {
        case .roomMappingFailed:
            return "Room scanning did not detect sufficient surfaces"

        case .spatialTrackingLost:
            return "The device lost tracking of your environment"

        case .saveDataCorrupted:
            return "The save file could not be read or was invalid"

        case .multiplayerConnectionFailed:
            return "Network connection was unavailable or unstable"

        case .insufficientSpace:
            return "The detected play area is less than 2m × 2m"

        case .assetLoadFailed:
            return "The asset file was missing or corrupted"

        case .invalidGameState:
            return "The requested state transition is not allowed"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .roomMappingFailed:
            return "Ensure adequate lighting and clear surfaces. Try scanning again."

        case .spatialTrackingLost:
            return "Look around slowly to re-establish tracking. Ensure good lighting."

        case .saveDataCorrupted:
            return "You may need to start a new game. Previous progress cannot be recovered."

        case .multiplayerConnectionFailed:
            return "Check your internet connection and try again."

        case .insufficientSpace:
            return "Move to a larger area with at least 2m × 2m of clear space."

        case .assetLoadFailed:
            return "Try reinstalling the game. Contact support if problem persists."

        case .invalidGameState:
            return "This is a programming error. Please report this bug."
        }
    }
}
```

### Nested Error Types

Organize errors by subsystem:

```swift
// Persistence errors
enum PersistenceError: Error {
    case fileNotFound(path: String)
    case decodingFailed(underlyingError: Error)
    case encodingFailed(underlyingError: Error)
    case permissionDenied
    case diskFull
}

// Network errors
enum NetworkError: Error {
    case noConnection
    case timeout
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case rateLimited(retryAfter: TimeInterval)
}

// ARKit errors
enum SpatialError: Error {
    case sessionFailed
    case trackingLimited(reason: String)
    case worldMapLoadFailed
    case anchorCreationFailed
}
```

### Error with Context

Include debugging information:

```swift
struct DetailedError: Error {
    let error: Error
    let context: String
    let file: String
    let line: Int
    let timestamp: Date

    init(
        _ error: Error,
        context: String,
        file: String = #file,
        line: Int = #line
    ) {
        self.error = error
        self.context = context
        self.file = file
        self.line = line
        self.timestamp = Date()
    }
}

// Usage
throw DetailedError(
    GameError.assetLoadFailed(assetName: "player"),
    context: "Loading player character during game initialization"
)
```

---

## Error Propagation

### When to Propagate

Propagate errors when:
- Caller should decide how to handle
- Error recovery requires caller's context
- Multiple callers might handle differently

```swift
func loadPlayerData() throws -> PlayerData {
    // Let caller decide how to handle file errors
    let data = try Data(contentsOf: playerDataURL)
    return try JSONDecoder().decode(PlayerData.self, from: data)
}
```

### When to Handle Locally

Handle errors locally when:
- Recovery is obvious and consistent
- Error is expected and non-critical
- Caller doesn't need to know about error

```swift
func loadOptionalConfig() -> Configuration {
    do {
        let data = try Data(contentsOf: configURL)
        return try JSONDecoder().decode(Configuration.self, from: data)
    } catch {
        // Config is optional, use defaults
        print("Using default configuration: \(error)")
        return Configuration.default
    }
}
```

### Error Transformation

Transform low-level errors to domain errors:

```swift
func loadGame() throws -> GameState {
    do {
        let data = try Data(contentsOf: saveFileURL)
        return try JSONDecoder().decode(GameState.self, from: data)
    } catch let error as DecodingError {
        // Transform JSONDecoder error to domain error
        throw GameError.saveDataCorrupted
    } catch {
        // Re-throw other errors
        throw error
    }
}
```

### Rethrowing Functions

Functions that take throwing closures:

```swift
func executeWithRetry<T>(
    maxAttempts: Int = 3,
    operation: () throws -> T
) rethrows -> T {
    var lastError: Error?

    for attempt in 1...maxAttempts {
        do {
            return try operation()
        } catch {
            lastError = error
            print("Attempt \(attempt) failed: \(error)")
        }
    }

    throw lastError!
}

// Usage
let data = try executeWithRetry {
    try fetchDataFromServer()
}
```

---

## Error Recovery Strategies

### Strategy 1: Retry

Automatically retry transient failures:

```swift
class NetworkManager {
    func fetchWithRetry<T>(
        url: URL,
        maxAttempts: Int = 3,
        retryDelay: TimeInterval = 1.0
    ) async throws -> T where T: Decodable {
        var attempt = 0
        var lastError: Error?

        while attempt < maxAttempts {
            do {
                return try await fetch(url: url)
            } catch NetworkError.timeout, NetworkError.noConnection {
                // Retry transient errors
                attempt += 1
                lastError = error
                print("Attempt \(attempt) failed, retrying...")

                if attempt < maxAttempts {
                    try await Task.sleep(for: .seconds(retryDelay))
                }
            } catch {
                // Don't retry permanent errors
                throw error
            }
        }

        throw lastError ?? NetworkError.timeout
    }
}
```

### Strategy 2: Fallback

Use fallback values or behavior:

```swift
class AssetManager {
    func loadTexture(_ name: String) -> Texture {
        do {
            return try loadTextureFromDisk(name)
        } catch {
            print("Failed to load texture '\(name)': \(error)")

            // Fallback to placeholder
            return placeholderTexture
        }
    }

    func loadModel(_ name: String) -> Model {
        // Try loading from cache
        if let cached = modelCache[name] {
            return cached
        }

        // Try loading from disk
        do {
            let model = try loadModelFromDisk(name)
            modelCache[name] = model
            return model
        } catch {
            print("Failed to load model '\(name)': \(error)")

            // Fallback to default model
            return defaultModel
        }
    }
}
```

### Strategy 3: Graceful Degradation

Reduce functionality rather than failing completely:

```swift
class GraphicsManager {
    func initializeGraphics() {
        do {
            try enableAdvancedFeatures()
        } catch {
            print("Advanced graphics features unavailable: \(error)")

            // Continue with basic features
            enableBasicFeatures()
        }
    }

    func enableAdvancedFeatures() throws {
        try enableHDR()
        try enableRayTracing()
        try enableAdvancedShadows()
    }

    func enableBasicFeatures() {
        // Always succeeds with minimal features
        enableStandardLighting()
        enableBasicShadows()
    }
}
```

### Strategy 4: User Intervention

Prompt user for action:

```swift
class RoomMappingManager {
    func scanRoom() async throws -> RoomLayout {
        do {
            return try await performRoomScan()
        } catch SpatialError.trackingLimited(let reason) {
            // Ask user to improve conditions
            let shouldRetry = await showTrackingIssueDialog(reason: reason)

            if shouldRetry {
                // Retry after user intervention
                return try await scanRoom()
            } else {
                throw SpatialError.trackingLimited(reason: reason)
            }
        }
    }

    private func showTrackingIssueDialog(reason: String) async -> Bool {
        await MainActor.run {
            // Show dialog: "Tracking Limited: \(reason). Retry?"
            // Return user's choice
            return showRetryDialog(message: reason)
        }
    }
}
```

### Strategy 5: State Reset

Reset to known good state:

```swift
class GameStateManager {
    func recoverFromError() {
        print("⚠️ Recovering from error state")

        // Save current state for debugging
        saveErrorState()

        // Clear error state
        EventBus.shared.clear()

        // Reset to safe state
        transition(to: .initialization)

        // Notify user
        showNotification("Game reset due to error. Some progress may be lost.")
    }

    private func saveErrorState() {
        // Save state for bug reports
        let errorState = [
            "currentState": currentState.description,
            "stateHistory": stateHistory.map { $0.description },
            "timestamp": Date().ISO8601Format()
        ]

        do {
            let data = try JSONEncoder().encode(errorState)
            try data.write(to: errorStateURL)
        } catch {
            print("Failed to save error state: \(error)")
        }
    }
}
```

---

## User-Facing Error Messages

### Principles

1. **Clear**: User understands what happened
2. **Actionable**: User knows what to do
3. **Non-Technical**: Avoid jargon
4. **Empathetic**: Acknowledge frustration
5. **Concise**: Get to the point

### Message Template

```
[What went wrong]

[Why it happened]

[What user can do]
```

### Examples

#### Good Error Messages

```swift
// Room mapping failed
"""
We couldn't map your room.

The room may be too dark or lack clear surfaces.

Try moving to a well-lit area with clear walls and floors.
"""

// Save failed
"""
We couldn't save your progress.

Your device may be low on storage.

Free up some storage space and try again.
"""

// Multiplayer connection failed
"""
We couldn't connect to the multiplayer session.

Your internet connection may be unstable.

Check your connection and try again.
"""
```

#### Bad Error Messages

```swift
// ❌ Too technical
"ARSession failed with error: kARAnchorUpdateAlignmentFailed"

// ❌ Not actionable
"An error occurred."

// ❌ Blaming user
"You didn't provide enough space."

// ❌ Too verbose
"The system encountered an unexpected exception while attempting to initialize the spatial anchoring subsystem. This may be due to a variety of factors including but not limited to..."
```

### Error UI Components

#### Error Dialog

```swift
struct ErrorDialog: View {
    let error: GameError
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text(error.errorDescription ?? "An error occurred")
                .font(.title2)
                .multilineTextAlignment(.center)

            Text(error.recoverySuggestion ?? "Please try again.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 15) {
                if let onRetry = onRetry {
                    Button("Try Again") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button("Dismiss") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(30)
        .background(.regularMaterial)
        .cornerRadius(20)
    }
}
```

#### Error Toast

```swift
struct ErrorToast: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(.red)

            Text(message)
                .font(.body)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(10)
    }
}
```

---

## Error Logging

### Log Levels

```swift
enum LogLevel: String {
    case debug = "🔍 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case critical = "🔥 CRITICAL"
}
```

### Error Logger

```swift
import os.log

class ErrorLogger {
    private static let logger = Logger(
        subsystem: "com.realityrealms.rpg",
        category: "errors"
    )

    static func log(
        _ error: Error,
        level: LogLevel = .error,
        context: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let location = "\(fileName):\(line) \(function)"

        var message = "\(level.rawValue) [\(location)]"

        if let context = context {
            message += " \(context):"
        }

        message += " \(error.localizedDescription)"

        // Log to unified logging system
        logger.error("\(message, privacy: .public)")

        // Also print to console in debug builds
        #if DEBUG
        print(message)

        // Print stack trace for critical errors
        if level == .critical {
            Thread.callStackSymbols.forEach { print("  \($0)") }
        }
        #endif

        // Send to crash reporting service in production
        #if !DEBUG
        if level == .critical {
            sendToCrashReporter(error, context: message)
        }
        #endif
    }

    private static func sendToCrashReporter(_ error: Error, context: String) {
        // Integrate with crash reporting service
        // e.g., Crashlytics, Sentry, etc.
    }
}

// Usage
ErrorLogger.log(
    error,
    level: .error,
    context: "Failed to load player data"
)
```

### Structured Error Logging

```swift
struct ErrorLog: Codable {
    let timestamp: Date
    let level: String
    let error: String
    let context: String?
    let file: String
    let function: String
    let line: Int
    let gameState: String
    let playerID: UUID?
    let sessionID: UUID

    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            let url = logsDirectory.appendingPathComponent("\(timestamp.ISO8601Format()).json")
            try data.write(to: url)
        } catch {
            print("Failed to save error log: \(error)")
        }
    }
}
```

---

## Testing Error Conditions

### Unit Tests for Error Cases

```swift
class ErrorHandlingTests: XCTestCase {
    func testLoadGameThrowsErrorForMissingFile() {
        XCTAssertThrowsError(try loadGame(from: nonExistentURL)) { error in
            XCTAssertTrue(error is PersistenceError)

            if case PersistenceError.fileNotFound = error {
                // Correct error type
            } else {
                XCTFail("Expected fileNotFound error")
            }
        }
    }

    func testLoadGameThrowsErrorForCorruptedData() {
        XCTAssertThrowsError(try loadGame(from: corruptedDataURL)) { error in
            XCTAssertEqual(error as? GameError, .saveDataCorrupted)
        }
    }

    func testRecoveryFromRoomMappingFailure() async throws {
        let manager = RoomMappingManager()

        // Simulate failure
        mockARSession.shouldFail = true

        do {
            _ = try await manager.scanRoom()
            XCTFail("Should have thrown error")
        } catch GameError.roomMappingFailed {
            // Expected error

            // Verify recovery attempted
            XCTAssertTrue(manager.attemptedRecovery)
        }
    }
}
```

### Integration Tests for Error Scenarios

```swift
class ErrorFlowIntegrationTests: XCTestCase {
    func testGameContinuesAfterSaveFailure() async throws {
        let gameState = GameStateManager.shared

        // Start game
        gameState.startGame()

        // Simulate save failure
        mockPersistence.shouldFail = true

        // Attempt save
        do {
            try await saveGame()
            XCTFail("Save should have failed")
        } catch {
            // Error expected
        }

        // Game should still be playable
        XCTAssertTrue(gameState.isGameActive)

        // User should be notified
        XCTAssertTrue(lastNotification?.contains("save") ?? false)
    }
}
```

---

## Common Error Scenarios

### Scenario 1: Network Failure

```swift
class MultiplayerManager {
    func joinSession(_ sessionID: String) async throws {
        do {
            try await connectToSession(sessionID)
        } catch NetworkError.noConnection {
            // Specific handling for no connection
            throw GameError.multiplayerConnectionFailed

        } catch NetworkError.timeout {
            // Retry once for timeouts
            print("Connection timed out, retrying...")
            try await Task.sleep(for: .seconds(2))

            try await connectToSession(sessionID)

        } catch NetworkError.serverError(let code, let message) {
            // Log server errors
            ErrorLogger.log(
                NetworkError.serverError(statusCode: code, message: message),
                context: "Joining multiplayer session"
            )
            throw GameError.multiplayerConnectionFailed
        }
    }
}
```

### Scenario 2: Asset Loading Failure

```swift
class AssetManager {
    func loadAsset(_ name: String) throws -> Asset {
        guard let url = Bundle.main.url(forResource: name, withExtension: "usdz") else {
            ErrorLogger.log(
                PersistenceError.fileNotFound(path: name),
                context: "Loading game asset"
            )

            // Use fallback asset
            return fallbackAsset
        }

        do {
            return try Asset.load(from: url)
        } catch {
            ErrorLogger.log(
                error,
                level: .error,
                context: "Failed to load asset: \(name)"
            )

            // Return fallback
            return fallbackAsset
        }
    }
}
```

### Scenario 3: Spatial Tracking Lost

```swift
class SpatialTrackingManager {
    func handleTrackingLost() {
        // Pause game
        GameStateManager.shared.pauseGame(true)

        // Show user notification
        EventBus.shared.publish(ShowNotificationEvent(
            title: "Tracking Lost",
            message: "Look around slowly to re-establish tracking",
            duration: 5.0
        ))

        // Try to recover
        Task {
            do {
                try await reestablishTracking()

                // Resume game
                GameStateManager.shared.pauseGame(false)

                EventBus.shared.publish(ShowNotificationEvent(
                    title: "Tracking Restored",
                    message: "Spatial tracking has been restored",
                    duration: 3.0
                ))
            } catch {
                ErrorLogger.log(
                    error,
                    level: .critical,
                    context: "Failed to restore spatial tracking"
                )

                // Return to main menu
                GameStateManager.shared.transition(to: .error("Spatial tracking unavailable"))
            }
        }
    }
}
```

---

## Best Practices

### 1. Use Specific Error Types

```swift
// ❌ Generic errors
throw NSError(domain: "GameError", code: 1, userInfo: nil)

// ✅ Specific typed errors
throw GameError.saveDataCorrupted
```

### 2. Provide Context

```swift
// ❌ No context
throw GameError.assetLoadFailed

// ✅ With context
throw GameError.assetLoadFailed(assetName: "player_model.usdz")
```

### 3. Log All Errors

```swift
do {
    try dangerousOperation()
} catch {
    // Always log, even if recovering
    ErrorLogger.log(error, context: "Dangerous operation")

    // Then handle
    useFailover()
}
```

### 4. Don't Swallow Errors

```swift
// ❌ Silent failure
do {
    try saveGame()
} catch {
    // Error ignored!
}

// ✅ Log and handle
do {
    try saveGame()
} catch {
    ErrorLogger.log(error, context: "Auto-save failed")
    showSaveFailedNotification()
}
```

### 5. Validate Early

```swift
func createCharacter(name: String, class: CharacterClass) throws -> Player {
    // Validate inputs first
    guard !name.isEmpty else {
        throw ValidationError.emptyName
    }

    guard name.count <= 20 else {
        throw ValidationError.nameTooLong
    }

    // Proceed with creation
    return Player(name: name, characterClass: class)
}
```

### 6. Use Guard for Preconditions

```swift
func updateEntity(_ entity: GameEntity) {
    // Validate preconditions
    guard entity.isActive else {
        ErrorLogger.log(
            ValidationError.inactiveEntity,
            level: .warning,
            context: "Attempted to update inactive entity"
        )
        return
    }

    // Proceed with update
    // ...
}
```

### 7. Document Error Conditions

```swift
/// Loads the game state from disk.
///
/// - Throws:
///   - `PersistenceError.fileNotFound` if save file doesn't exist
///   - `PersistenceError.decodingFailed` if save data is corrupted
///   - `GameError.saveDataCorrupted` if save data is invalid
///
/// - Returns: The loaded game state
func loadGame() throws -> GameState {
    // ...
}
```

---

**Error Handling Guide Version**: 1.0
**Last Updated**: 2025-11-19
**Maintained By**: Reality Realms Development Team

Remember: **Good error handling is invisible to users and invaluable to developers.**
