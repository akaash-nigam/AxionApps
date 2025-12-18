# Error Handling & Offline Strategy

## Overview

This document defines error handling patterns and offline functionality for Physical-Digital Twins, ensuring graceful degradation and excellent user experience without network connectivity.

## Offline-First Principles

1. **Core Functionality Works Offline**: Recognition (except API enrichment), inventory viewing, AR visualization
2. **Queue Network Operations**: Sync, API calls queued for when online
3. **Clear Status Indicators**: Show sync status, queue size
4. **Graceful Degradation**: Disable features that require network

## Offline Capabilities

### ✅ Available Offline

- View inventory
- Browse digital twins
- AR visualization of existing twins
- Object recognition (barcode, ML classification)
- Manual data entry
- Photo capture
- Edit existing items
- Delete items
- Search and filter inventory

### ❌ Requires Network

- API enrichment (product details, book ratings)
- CloudKit sync
- Recipe suggestions
- Recall checks
- Resale value updates
- ML model updates

## Error Types

### Network Errors

```swift
enum NetworkError: LocalizedError {
    case offline
    case timeout
    case serverError(Int)
    case invalidResponse
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .offline:
            return "No internet connection. Some features unavailable."
        case .timeout:
            return "Request timed out. Please try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .invalidResponse:
            return "Invalid server response."
        case .rateLimitExceeded:
            return "Too many requests. Please wait and try again."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .offline:
            return "Check your connection and try again."
        case .timeout:
            return "Check your connection speed."
        case .serverError:
            return "The service may be temporarily unavailable."
        case .invalidResponse:
            return "Please update the app to the latest version."
        case .rateLimitExceeded:
            return "Wait a few minutes before trying again."
        }
    }
}
```

### Data Errors

```swift
enum DataError: LocalizedError {
    case saveFailed
    case fetchFailed
    case corruptedData
    case migrationFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data."
        case .fetchFailed:
            return "Failed to load data."
        case .corruptedData:
            return "Data is corrupted and cannot be read."
        case .migrationFailed:
            return "Failed to migrate data to new version."
        }
    }
}
```

### Recognition Errors

```swift
enum RecognitionError: LocalizedError {
    case unrecognized
    case lowConfidence
    case poorLighting
    case objectTooFar
    case modelLoadFailed

    var errorDescription: String? {
        switch self {
        case .unrecognized:
            return "Couldn't identify this object."
        case .lowConfidence:
            return "Not sure what this object is."
        case .poorLighting:
            return "Lighting is too poor for recognition."
        case .objectTooFar:
            return "Object is too far away."
        case .modelLoadFailed:
            return "Recognition model failed to load."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unrecognized, .lowConfidence:
            return "Try scanning a barcode or entering details manually."
        case .poorLighting:
            return "Move to better lighting or turn on lights."
        case .objectTooFar:
            return "Move closer to the object (10-50cm optimal)."
        case .modelLoadFailed:
            return "Restart the app or reinstall if problem persists."
        }
    }
}
```

## Error Handling Patterns

### Service Layer

```swift
class ProductAPIService {
    func fetchProductInfo(barcode: String) async throws -> ProductInfo {
        do {
            return try await performNetworkRequest(barcode)
        } catch let error as NetworkError {
            // Log error
            logger.error("API fetch failed: \(error)")

            // Check if we have cached data
            if let cached = await cache.get(key: "product:\(barcode)") as? ProductInfo {
                logger.info("Returning cached product info")
                return cached
            }

            // No cache available, throw error
            throw error
        }
    }
}
```

### ViewModel Layer

```swift
@MainActor
@Observable
class ScanningViewModel {
    var error: AppError?
    var showError = false

    func processBarcode(_ barcode: String) async {
        do {
            let productInfo = try await apiService.fetchProductInfo(barcode: barcode)
            // Success path
        } catch let error as NetworkError where error == .offline {
            // Offline: Create basic twin without enrichment
            createBasicTwin(barcode: barcode)
            showOfflineNotice()
        } catch {
            // Other error: Show to user
            self.error = AppError(from: error)
            self.showError = true
        }
    }

    private func showOfflineNotice() {
        // Show non-intrusive message
        showToast("Offline mode: Basic info only. Will enrich when online.")
    }
}
```

### View Layer

```swift
struct ScanningView: View {
    @Bindable var viewModel: ScanningViewModel

    var body: some View {
        // ... scanning UI ...

        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.error = nil
            }

            if let recovery = viewModel.error?.recoverySuggestion {
                Button("Help") {
                    showHelp(recovery)
                }
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}
```

## Offline Queue System

### Operation Queue

```swift
class OfflineOperationQueue {
    private var queue: [QueuedOperation] = []

    func enqueue(_ operation: QueuedOperation) {
        queue.append(operation)
        saveQueue()
    }

    func processQueue() async {
        guard NetworkMonitor.shared.isConnected else { return }

        for operation in queue {
            do {
                try await operation.execute()
                queue.removeAll { $0.id == operation.id }
            } catch {
                logger.error("Failed to execute queued operation: \(error)")
                // Keep in queue for retry
            }
        }

        saveQueue()
    }
}

struct QueuedOperation: Codable {
    let id: UUID
    let type: OperationType
    let data: Data
    let createdAt: Date

    enum OperationType: String, Codable {
        case syncTwin
        case fetchAPI
        case uploadPhoto
    }

    func execute() async throws {
        switch type {
        case .syncTwin:
            try await executeSyncTwin()
        case .fetchAPI:
            try await executeFetchAPI()
        case .uploadPhoto:
            try await executeUploadPhoto()
        }
    }
}
```

### Network Monitoring

```swift
import Network

@Observable
class NetworkMonitor {
    static let shared = NetworkMonitor()

    var isConnected = false
    var connectionType: ConnectionType = .unknown

    private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied

                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else {
                    self?.connectionType = .unknown
                }

                if self?.isConnected == true {
                    self?.notifyConnectionRestored()
                }
            }
        }

        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    private func notifyConnectionRestored() {
        // Process offline queue
        Task {
            await OfflineOperationQueue.shared.processQueue()
        }
    }

    enum ConnectionType {
        case wifi, cellular, unknown
    }
}
```

## User Feedback

### Status Indicators

```swift
struct NetworkStatusBanner: View {
    @Environment(NetworkMonitor.self) private var networkMonitor
    @Environment(OfflineOperationQueue.self) private var queue

    var body: some View {
        if !networkMonitor.isConnected {
            HStack {
                Image(systemName: "wifi.slash")
                Text("Offline Mode")
                Spacer()
                if queue.count > 0 {
                    Text("\(queue.count) pending")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.yellow.opacity(0.2))
        }
    }
}
```

### Toast Messages

```swift
struct ToastView: View {
    let message: String
    let type: ToastType

    var body: some View {
        HStack {
            Image(systemName: type.icon)
            Text(message)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
    }

    enum ToastType {
        case info, success, warning, error

        var icon: String {
            switch self {
            case .info: return "info.circle"
            case .success: return "checkmark.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.circle"
            }
        }
    }
}
```

## Retry Logic

### Exponential Backoff

```swift
class RetryManager {
    func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var currentDelay = initialDelay

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                if attempt == maxAttempts {
                    throw error
                }

                logger.warning("Attempt \(attempt) failed, retrying in \(currentDelay)s")
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                currentDelay *= 2 // Exponential backoff
            }
        }

        fatalError("Should not reach here")
    }
}

// Usage
let result = try await RetryManager().retry {
    try await apiService.fetchProductInfo(barcode: barcode)
}
```

## Data Consistency

### Conflict Resolution

```swift
class ConflictResolver {
    func resolve(_ conflict: SyncConflict) async -> ResolvedData {
        switch conflict.type {
        case .lastWriteWins:
            return conflict.local.updatedAt > conflict.remote.updatedAt
                ? conflict.local
                : conflict.remote

        case .manual:
            // Present to user
            return await presentConflictToUser(conflict)

        case .merge:
            // Merge non-conflicting fields
            return mergeData(local: conflict.local, remote: conflict.remote)
        }
    }
}
```

## Logging & Monitoring

```swift
import OSLog

let logger = Logger(subsystem: "com.app.physicaldigitaltwins", category: "errors")

class ErrorTracker {
    static func track(_ error: Error, context: [String: Any] = [:]) {
        logger.error("Error: \(error.localizedDescription)")

        // Log to analytics (if enabled)
        if UserDefaults.standard.bool(forKey: "analyticsEnabled") {
            // Track error for analysis
        }

        // For critical errors, consider crash reporting
        if isCritical(error) {
            // Report to crash service
        }
    }

    private static func isCritical(_ error: Error) -> Bool {
        // Determine if error is critical
        return false
    }
}
```

## Summary

This error handling strategy provides:
- **Offline-First**: Core features work without network
- **Graceful Degradation**: Non-critical features degrade elegantly
- **Clear Communication**: Users understand what's happening
- **Automatic Recovery**: Retry failed operations automatically
- **Data Consistency**: Handle sync conflicts intelligently

Good error handling is invisible when things work and helpful when they don't.
