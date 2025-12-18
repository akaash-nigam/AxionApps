# Error Handling & Resilience Design
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document defines the error handling strategy and resilience patterns for the Living Building System, ensuring graceful degradation and recovery from failures.

## 2. Error Handling Principles

1. **User-Friendly Messages**: Clear, actionable error messages
2. **Graceful Degradation**: Core features work even when some services fail
3. **Automatic Recovery**: Retry transient errors automatically
4. **Fail Fast**: Detect errors early and fail cleanly
5. **Logging**: Log all errors for debugging
6. **No Silent Failures**: Always surface errors to user or logs

## 3. Error Taxonomy

### 3.1 Error Types

```swift
enum LBSError: LocalizedError {
    // Network errors
    case networkUnavailable
    case networkTimeout
    case rateLimitExceeded

    // Device errors
    case deviceNotFound(UUID)
    case deviceUnreachable(UUID)
    case deviceCommandFailed(UUID, underlying: Error)

    // Authorization errors
    case authorizationDenied
    case authenticationFailed
    case insufficientPermissions

    // Data errors
    case dataCorruption
    case dataNotFound
    case invalidData(String)

    // Service errors
    case serviceUnavailable(String)
    case apiError(statusCode: Int, message: String)

    // Spatial errors
    case spatialTrackingLost
    case anchorNotFound
    case roomScanFailed

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable. Check your connection."

        case .networkTimeout:
            return "Request timed out. Please try again."

        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment."

        case .deviceNotFound(let id):
            return "Device not found: \(id)"

        case .deviceUnreachable(let id):
            return "Device is not reachable: \(id)"

        case .deviceCommandFailed(let id, let error):
            return "Failed to control device \(id): \(error.localizedDescription)"

        case .authorizationDenied:
            return "Authorization denied. Grant permission in Settings."

        case .authenticationFailed:
            return "Authentication failed. Check your credentials."

        case .insufficientPermissions:
            return "You don't have permission to perform this action."

        case .dataCorruption:
            return "Data corruption detected. App will reset."

        case .dataNotFound:
            return "Requested data not found."

        case .invalidData(let details):
            return "Invalid data: \(details)"

        case .serviceUnavailable(let service):
            return "\(service) is currently unavailable."

        case .apiError(let code, let message):
            return "API Error (\(code)): \(message)"

        case .spatialTrackingLost:
            return "Spatial tracking lost. Move to a well-lit area."

        case .anchorNotFound:
            return "Spatial anchor not found. Rescan the room."

        case .roomScanFailed:
            return "Room scan failed. Try again."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Connect to Wi-Fi or cellular data."

        case .networkTimeout:
            return "Check your internet connection and try again."

        case .rateLimitExceeded:
            return "Wait a few minutes before trying again."

        case .deviceUnreachable:
            return "Make sure the device is powered on and connected to your network."

        case .authorizationDenied:
            return "Go to Settings > Living Building System and enable required permissions."

        case .spatialTrackingLost:
            return "Move to a well-lit area and avoid rapid movements."

        case .anchorNotFound:
            return "Rescan the room using the Room Setup feature."

        default:
            return nil
        }
    }

    var isRetryable: Bool {
        switch self {
        case .networkTimeout, .networkUnavailable, .deviceUnreachable,
             .rateLimitExceeded, .serviceUnavailable:
            return true
        default:
            return false
        }
    }
}
```

### 3.2 Error Severity

```swift
enum ErrorSeverity {
    case info // Informational, no action needed
    case warning // User should be aware but can continue
    case error // Requires user attention
    case critical // App cannot function properly

    var icon: String {
        switch self {
        case .info: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.circle.fill"
        case .critical: "exclamationmark.octagon.fill"
        }
    }

    var color: Color {
        switch self {
        case .info: .blue
        case .warning: .yellow
        case .error: .red
        case .critical: .red
        }
    }
}

extension LBSError {
    var severity: ErrorSeverity {
        switch self {
        case .rateLimitExceeded, .spatialTrackingLost:
            return .warning

        case .deviceUnreachable, .networkTimeout:
            return .warning

        case .authorizationDenied, .deviceCommandFailed:
            return .error

        case .dataCorruption, .authenticationFailed:
            return .critical

        default:
            return .error
        }
    }
}
```

## 4. Error Handling Patterns

### 4.1 Try-Catch with Context

```swift
func toggleDevice(_ device: SmartDevice) async throws {
    do {
        try await homeKitService.toggleDevice(device)
    } catch let error as HomeKitError {
        // Convert to app-specific error with context
        throw LBSError.deviceCommandFailed(device.id, underlying: error)
    } catch {
        // Wrap unknown errors
        throw LBSError.deviceCommandFailed(device.id, underlying: error)
    }
}
```

### 4.2 Result Type for Non-Throwing Functions

```swift
func loadConfiguration() -> Result<Configuration, LBSError> {
    do {
        let data = try Data(contentsOf: configURL)
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        return .success(config)
    } catch {
        return .failure(.invalidData("Configuration file"))
    }
}

// Usage
switch loadConfiguration() {
case .success(let config):
    applyConfiguration(config)
case .failure(let error):
    handleError(error)
}
```

### 4.3 Optional Chaining for Graceful Degradation

```swift
// Show energy data if available, or fallback
let energyText = appState.currentEnergySnapshot?.totalPower
    .formatted(.number.precision(.fractionLength(1)))
    ?? "—"
```

## 5. Retry Logic

### 5.1 Exponential Backoff

```swift
func withRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: TimeInterval = 1.0,
    operation: @escaping () async throws -> T
) async throws -> T {
    var attempt = 0
    var delay = initialDelay

    while attempt < maxAttempts {
        do {
            return try await operation()
        } catch {
            attempt += 1

            // Check if retryable
            if let lbsError = error as? LBSError, !lbsError.isRetryable {
                throw error
            }

            // Last attempt failed
            if attempt >= maxAttempts {
                throw error
            }

            // Wait before retry
            try await Task.sleep(for: .seconds(delay))
            delay *= 2 // Exponential backoff
        }
    }

    fatalError("Should never reach here")
}

// Usage
let data = try await withRetry {
    try await energyService.getCurrentReading()
}
```

### 5.2 Circuit Breaker Pattern

```swift
actor CircuitBreaker {
    enum State {
        case closed // Normal operation
        case open // Failing, reject requests
        case halfOpen // Testing if recovered
    }

    private var state: State = .closed
    private var failureCount = 0
    private var lastFailureTime: Date?
    private let failureThreshold = 5
    private let timeout: TimeInterval = 60 // Seconds

    func execute<T>(_ operation: () async throws -> T) async throws -> T {
        switch state {
        case .open:
            // Check if timeout elapsed
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > timeout {
                state = .halfOpen
            } else {
                throw LBSError.serviceUnavailable("Circuit breaker open")
            }

        case .halfOpen:
            // Try one request
            do {
                let result = try await operation()
                reset()
                return result
            } catch {
                open()
                throw error
            }

        case .closed:
            break
        }

        // Execute operation
        do {
            let result = try await operation()
            return result
        } catch {
            recordFailure()
            throw error
        }
    }

    private func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()

        if failureCount >= failureThreshold {
            open()
        }
    }

    private func open() {
        state = .open
        print("Circuit breaker opened")
    }

    private func reset() {
        state = .closed
        failureCount = 0
        lastFailureTime = nil
        print("Circuit breaker closed")
    }
}

// Usage
class EnergyService {
    private let circuitBreaker = CircuitBreaker()

    func getCurrentReading() async throws -> EnergyReading {
        try await circuitBreaker.execute {
            try await _getCurrentReading()
        }
    }
}
```

## 6. Offline Mode

### 6.1 Offline Detection

```swift
actor OfflineManager {
    private var isOffline = false
    private let monitor = NWPathMonitor()

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updateStatus(path.status != .satisfied)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }

    private func updateStatus(_ offline: Bool) {
        isOffline = offline

        NotificationCenter.default.post(
            name: .networkStatusChanged,
            object: !offline
        )
    }

    func isOnline() async -> Bool {
        !isOffline
    }
}
```

### 6.2 Cached Data Fallback

```swift
class CachedDataService {
    private let cache: NSCache<NSString, AnyObject>
    private let offlineManager: OfflineManager

    func fetchData<T>(
        key: String,
        fetch: () async throws -> T
    ) async throws -> T where T: AnyObject {
        // Try cache first if offline
        if await offlineManager.isOnline() == false {
            if let cached = cache.object(forKey: key as NSString) as? T {
                return cached
            }
            throw LBSError.networkUnavailable
        }

        // Fetch fresh data
        do {
            let data = try await fetch()
            cache.setObject(data, forKey: key as NSString)
            return data
        } catch {
            // Fallback to cache on error
            if let cached = cache.object(forKey: key as NSString) as? T {
                return cached
            }
            throw error
        }
    }
}
```

## 7. User-Facing Error Display

### 7.1 Error Banner

```swift
struct ErrorBanner: View {
    let error: LBSError
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: error.severity.icon)
                .foregroundStyle(error.severity.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(error.localizedDescription)
                    .font(.headline)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Dismiss", action: onDismiss)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
```

### 7.2 Error Alert

```swift
struct ErrorAlert: ViewModifier {
    @Binding var error: LBSError?

    func body(content: Content) -> some View {
        content
            .alert(
                error?.localizedDescription ?? "Error",
                isPresented: .constant(error != nil),
                presenting: error
            ) { error in
                Button("OK") {
                    self.error = nil
                }

                if error.isRetryable {
                    Button("Retry") {
                        // Trigger retry
                    }
                }
            } message: { error in
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                }
            }
    }
}
```

## 8. Error Logging

### 8.1 Structured Logging

```swift
enum LogLevel {
    case debug
    case info
    case warning
    case error
    case critical
}

class Logger {
    static let shared = Logger()

    func log(
        _ message: String,
        level: LogLevel = .info,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = URL(fileURLWithPath: file).lastPathComponent

        var logMessage = "[\(timestamp)] [\(level)] [\(filename):\(line)] \(function) - \(message)"

        if let error = error {
            logMessage += " Error: \(error.localizedDescription)"
        }

        // Print to console
        print(logMessage)

        // Write to file
        writeToLogFile(logMessage)

        // Send to crash reporting (in production)
        #if !DEBUG
        if level == .error || level == .critical {
            // Send to analytics/crash reporting
        }
        #endif
    }

    private func writeToLogFile(_ message: String) {
        // Write to log file
        guard let logURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("app.log") else {
            return
        }

        let data = (message + "\n").data(using: .utf8)!

        if FileManager.default.fileExists(atPath: logURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: logURL)
        }
    }
}
```

### 8.2 Error Tracking

```swift
class ErrorTracker {
    private var errorCounts: [String: Int] = [:]

    func track(_ error: LBSError) {
        let key = String(describing: error)
        errorCounts[key, default: 0] += 1

        // Alert if error occurs too frequently
        if errorCounts[key]! > 10 {
            Logger.shared.log(
                "Error occurring frequently: \(key)",
                level: .warning
            )
        }
    }

    func getErrorStatistics() -> [(error: String, count: Int)] {
        errorCounts.map { ($0.key, $0.value) }
            .sorted { $0.count > $1.count }
    }
}
```

## 9. Graceful Degradation

### 9.1 Feature Flags

```swift
struct FeatureFlags {
    var energyMonitoring: Bool = true
    var environmentMonitoring: Bool = true
    var maintenanceTracking: Bool = true
    var voiceControl: Bool = true

    mutating func disableFeature(_ feature: Feature, reason: String) {
        Logger.shared.log("Disabling \(feature): \(reason)", level: .warning)

        switch feature {
        case .energyMonitoring:
            energyMonitoring = false
        case .environmentMonitoring:
            environmentMonitoring = false
        case .maintenanceTracking:
            maintenanceTracking = false
        case .voiceControl:
            voiceControl = false
        }
    }
}

enum Feature {
    case energyMonitoring
    case environmentMonitoring
    case maintenanceTracking
    case voiceControl
}
```

### 9.2 Fallback UI

```swift
struct EnergyView: View {
    @Environment(AppState.self) private var appState
    let featureFlags: FeatureFlags

    var body: some View {
        if featureFlags.energyMonitoring {
            if let snapshot = appState.currentEnergySnapshot {
                EnergyDashboard(snapshot: snapshot)
            } else {
                EnergyPlaceholder()
            }
        } else {
            FeatureUnavailableView(
                feature: "Energy Monitoring",
                message: "Energy monitoring is temporarily unavailable."
            )
        }
    }
}
```

## 10. Recovery Strategies

### 10.1 Auto-Recovery

```swift
class RecoveryManager {
    func attemptRecovery(from error: LBSError) async {
        switch error {
        case .spatialTrackingLost:
            // Wait and re-initialize spatial tracking
            try? await Task.sleep(for: .seconds(2))
            await reinitializeSpatialTracking()

        case .deviceUnreachable(let deviceID):
            // Retry connection after delay
            try? await Task.sleep(for: .seconds(5))
            await reconnectDevice(deviceID)

        case .networkTimeout:
            // Wait for network recovery
            await waitForNetwork()

        default:
            break
        }
    }

    private func reinitializeSpatialTracking() async {
        // Restart ARKit session
    }

    private func reconnectDevice(_ deviceID: UUID) async {
        // Attempt to reconnect device
    }

    private func waitForNetwork() async {
        // Wait for network to become available
        // with timeout
    }
}
```

### 10.2 State Recovery

```swift
class StateRecoveryManager {
    func recoverFromCorruptedState() async {
        Logger.shared.log("Attempting state recovery", level: .warning)

        // Clear corrupted data
        await clearCorruptedData()

        // Reload from last known good state
        await reloadState()

        // Re-initialize services
        await reinitializeServices()
    }

    private func clearCorruptedData() async {
        // Remove corrupted files
    }

    private func reloadState() async {
        // Load from backup or reset to defaults
    }

    private func reinitializeServices() async {
        // Reinitialize all services
    }
}
```

---

**Document Owner**: Platform Team
**Review Cycle**: Quarterly
**Next Review**: 2026-02-24
