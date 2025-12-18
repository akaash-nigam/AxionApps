# Error Handling & Edge Cases

## Error Types

### Network Errors
```swift
enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case rateLimitExceeded(retryAfter: TimeInterval)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "Request timed out. Please try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .invalidResponse:
            return "Invalid response from server."
        case .rateLimitExceeded(let seconds):
            return "Rate limit exceeded. Please wait \(Int(seconds)) seconds."
        }
    }
}
```

### AI Service Errors
```swift
enum AIError: Error, LocalizedError {
    case apiKeyMissing
    case quotaExceeded
    case contextTooLong
    case inappropriateContent
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API configuration error. Please contact support."
        case .quotaExceeded:
            return "Usage limit reached. Please upgrade your subscription."
        case .contextTooLong:
            return "Conversation too long. Starting fresh conversation."
        case .inappropriateContent:
            return "Content violates usage policy."
        case .modelUnavailable:
            return "AI service temporarily unavailable."
        }
    }
}
```

### ARKit Errors
```swift
enum ARError: Error, LocalizedError {
    case trackingLost
    case insufficientLighting
    case worldMapFailed
    case anchorCreationFailed

    var errorDescription: String? {
        switch self {
        case .trackingLost:
            return "Spatial tracking lost. Please move slowly and look around."
        case .insufficientLighting:
            return "Room too dark. Please improve lighting."
        case .worldMapFailed:
            return "Failed to save spatial data."
        case .anchorCreationFailed:
            return "Failed to place object in space."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .trackingLost:
            return "Move slowly and look at different parts of the room."
        case .insufficientLighting:
            return "Turn on lights or move to a brighter area."
        case .worldMapFailed:
            return "Try again or restart the app."
        case .anchorCreationFailed:
            return "Point at a flat surface and try again."
        }
    }
}
```

## Error Handling Patterns

### Result Type
```swift
func translateWord(_ word: String) async -> Result<String, TranslationError> {
    do {
        let translation = try await languageService.translate(word)
        return .success(translation)
    } catch {
        if let networkError = error as? NetworkError {
            return .failure(.networkError(networkError))
        } else {
            return .failure(.unknown(error))
        }
    }
}

enum TranslationError: Error {
    case networkError(NetworkError)
    case wordNotFound
    case unknown(Error)
}
```

### Error Recovery
```swift
class ErrorRecoveryManager {
    func attemptRecovery(from error: Error) async -> Bool {
        switch error {
        case let networkError as NetworkError:
            return await recoverFromNetworkError(networkError)
        case let arError as ARError:
            return await recoverFromARError(arError)
        default:
            return false
        }
    }

    private func recoverFromNetworkError(_ error: NetworkError) async -> Bool {
        switch error {
        case .noConnection:
            // Wait for connection
            return await waitForConnection()
        case .timeout:
            // Retry with longer timeout
            return await retryWithTimeout()
        case .rateLimitExceeded(let delay):
            // Wait and retry
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            return true
        default:
            return false
        }
    }

    private func recoverFromARError(_ error: ARError) async -> Bool {
        switch error {
        case .trackingLost:
            // Show guidance to user
            showTrackingGuidance()
            return true
        default:
            return false
        }
    }
}
```

## Edge Cases

### Empty States
```swift
struct EmptyStateView: View {
    let type: EmptyStateType

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: type.icon)
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text(type.title)
                .font(.title2)

            Text(type.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let action = type.action {
                Button(action.title) {
                    action.handler()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
    }
}

enum EmptyStateType {
    case noLanguages
    case noVocabulary
    case noConversations
    case noEnvironments

    var icon: String {
        switch self {
        case .noLanguages: return "globe"
        case .noVocabulary: return "book"
        case .noConversations: return "bubble.left.and.bubble.right"
        case .noEnvironments: return "building.2"
        }
    }

    var title: String {
        switch self {
        case .noLanguages: return "No Languages"
        case .noVocabulary: return "No Vocabulary"
        case .noConversations: return "No Conversations"
        case .noEnvironments: return "No Environments"
        }
    }

    var message: String {
        switch self {
        case .noLanguages:
            return "Add a language to start learning"
        case .noVocabulary:
            return "Start a session to learn new words"
        case .noConversations:
            return "Begin your first conversation to practice"
        case .noEnvironments:
            return "Download an environment to get started"
        }
    }
}
```

### Offline Mode
```swift
class OfflineModeManager {
    func handleOfflineMode() {
        // Disable features requiring internet
        disableAIConversations()

        // Enable offline features
        enableOfflineObjectLabeling()
        enableOfflinePronunciation()

        // Show notification
        showOfflineNotification()
    }

    func checkFeatureAvailability(_ feature: Feature) -> Bool {
        if NetworkMonitor.shared.isConnected {
            return true
        }

        // Check if feature works offline
        return feature.worksOffline
    }
}

enum Feature {
    case objectLabeling
    case conversations
    case pronunciation
    case grammar

    var worksOffline: Bool {
        switch self {
        case .objectLabeling: return true
        case .conversations: return false
        case .pronunciation: return true
        case .grammar: return true
        }
    }
}
```

### Device Limitations
```swift
class DeviceCapabilityChecker {
    func checkCapabilities() -> [Capability: Bool] {
        return [
            .arTracking: ARWorldTrackingConfiguration.isSupported,
            .objectDetection: true, // Always supported with Core ML
            .spatialAudio: AVAudioSession.sharedInstance().isInputAvailable,
            .neuralEngine: hasNeuralEngine()
        ]
    }

    func hasNeuralEngine() -> Bool {
        // Check for Neural Engine
        return MLModel.availableComputeDevices.contains(.neuralEngine)
    }

    func requireCapability(_ capability: Capability) throws {
        let capabilities = checkCapabilities()

        guard capabilities[capability] == true else {
            throw CapabilityError.notSupported(capability)
        }
    }
}

enum Capability {
    case arTracking
    case objectDetection
    case spatialAudio
    case neuralEngine
}

enum CapabilityError: Error {
    case notSupported(Capability)
}
```

### Resource Exhaustion
```swift
class ResourceGuard {
    func checkStorageAvailable(required: Int64) throws {
        let available = getAvailableStorage()

        guard available > required else {
            throw ResourceError.insufficientStorage(
                required: required,
                available: available
            )
        }
    }

    func checkMemoryAvailable() throws {
        let usage = getCurrentMemoryUsage()
        let limit: UInt64 = 1_200_000_000 // 1.2GB

        guard usage < limit else {
            throw ResourceError.memoryExhausted
        }
    }
}

enum ResourceError: Error, LocalizedError {
    case insufficientStorage(required: Int64, available: Int64)
    case memoryExhausted

    var errorDescription: String? {
        switch self {
        case .insufficientStorage(let required, let available):
            let requiredMB = required / 1_000_000
            let availableMB = available / 1_000_000
            return "Insufficient storage. Need \(requiredMB)MB, have \(availableMB)MB."
        case .memoryExhausted:
            return "Memory limit reached. Please restart the app."
        }
    }
}
```

## User-Facing Error Messages

```swift
class ErrorPresenter {
    func present(_ error: Error, in view: some View) {
        let alert = Alert(
            title: Text("Error"),
            message: Text(error.localizedDescription),
            primaryButton: .default(Text("Retry")) {
                retryLastAction()
            },
            secondaryButton: .cancel()
        )

        view.present(alert)
    }

    func presentToast(_ error: Error) {
        // Non-intrusive toast notification
        ToastManager.shared.show(
            message: error.localizedDescription,
            duration: 3.0,
            style: .error
        )
    }
}
```

## Logging

```swift
class ErrorLogger {
    func log(_ error: Error, context: [String: Any] = [:]) {
        var logEntry = ErrorLogEntry(
            error: error,
            timestamp: Date(),
            context: context
        )

        // Add system info
        logEntry.context["os_version"] = ProcessInfo.processInfo.operatingSystemVersionString
        logEntry.context["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"]

        // Log locally
        print("❌ Error: \(error)")

        // Send to crash reporting service (if user opted in)
        if UserDefaults.standard.bool(forKey: "crash_reporting_enabled") {
            sendToCrashReporter(logEntry)
        }
    }
}

struct ErrorLogEntry {
    let error: Error
    let timestamp: Date
    var context: [String: Any]
}
```
