# Analytics & Observability Design
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Overview](#overview)
2. [Privacy-Preserving Analytics](#privacy-preserving-analytics)
3. [Event Tracking](#event-tracking)
4. [Error Logging](#error-logging)
5. [Performance Metrics](#performance-metrics)
6. [User Behavior Analytics](#user-behavior-analytics)
7. [Dashboards & Alerts](#dashboards--alerts)

## Overview

### Analytics Goals
- **Product Insights**: Understand feature usage
- **Performance Monitoring**: Track app health
- **Error Detection**: Identify and fix issues quickly
- **User Experience**: Improve based on behavior patterns
- **Business Metrics**: Track KPIs and success metrics

### Privacy Principles
- **No PII**: Never track personal identifiable information
- **No Financial Data**: Never log actual amounts or merchant names
- **Anonymized**: Use hashed user IDs
- **Opt-out**: Users can disable analytics
- **Transparent**: Clear communication about what's tracked

## Privacy-Preserving Analytics

### Anonymous User Identification

```swift
// AnalyticsManager.swift
actor AnalyticsManager {
    private let anonymousUserId: String

    init() {
        // Generate persistent anonymous ID
        if let stored = UserDefaults.standard.string(forKey: "anonymous_user_id") {
            self.anonymousUserId = stored
        } else {
            // Create hash of iCloud user ID
            let icloudId = getCurrentiCloudUserID() ?? UUID().uuidString
            self.anonymousUserId = SHA256.hash(data: Data(icloudId.utf8))
                .compactMap { String(format: "%02x", $0) }
                .joined()

            UserDefaults.standard.set(anonymousUserId, forKey: "anonymous_user_id")
        }
    }

    private func getCurrentiCloudUserID() -> String? {
        // Fetch iCloud container user record ID
        // This is hashed, so it's anonymous
        nil // Simplified for spec
    }
}
```

### Safe Event Tracking

```swift
// AnalyticsEvent.swift
struct AnalyticsEvent {
    let name: String
    let timestamp: Date
    let properties: [String: AnalyticsValue]

    enum AnalyticsValue {
        case string(String)
        case int(Int)
        case double(Double)
        case bool(Bool)

        // NO support for Decimal (could contain financial data)
        // NO support for Date (could reveal personal schedule)
    }

    // Validate event doesn't contain PII
    func validate() -> Bool {
        // Check for common PII patterns
        for (key, value) in properties {
            if containsPII(key: key, value: value) {
                Logger.analytics.error("Event '\(name)' contains PII in '\(key)'")
                return false
            }
        }
        return true
    }

    private func containsPII(key: String, value: AnalyticsValue) -> Bool {
        let piiKeys = ["email", "phone", "name", "address", "ssn", "account"]

        // Check if key contains PII-related terms
        let lowercaseKey = key.lowercased()
        if piiKeys.contains(where: { lowercaseKey.contains($0) }) {
            return true
        }

        // Check if value looks like PII
        switch value {
        case .string(let str):
            // Email pattern
            if str.contains("@") && str.contains(".") {
                return true
            }
            // Phone pattern
            if str.range(of: #"\d{3}-\d{3}-\d{4}"#, options: .regularExpression) != nil {
                return true
            }
        default:
            break
        }

        return false
    }
}
```

## Event Tracking

### Event Taxonomy

```swift
// Events.swift
enum AnalyticsEventName: String {
    // App Lifecycle
    case appLaunched = "app_launched"
    case appBackgrounded = "app_backgrounded"
    case appForegrounded = "app_foregrounded"

    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"
    case bankConnected = "bank_connected"
    case bankConnectionFailed = "bank_connection_failed"

    // Navigation
    case screenViewed = "screen_viewed"
    case tabChanged = "tab_changed"

    // Transactions
    case transactionsViewed = "transactions_viewed"
    case transactionDetailViewed = "transaction_detail_viewed"
    case transactionCategoryChanged = "transaction_category_changed"
    case transactionsSynced = "transactions_synced"

    // Budget
    case budgetCreated = "budget_created"
    case budgetViewed = "budget_viewed"
    case budgetCategoryUpdated = "budget_category_updated"
    case budgetAlertTriggered = "budget_alert_triggered"
    case budgetExceeded = "budget_exceeded"

    // Goals
    case goalCreated = "goal_created"
    case goalViewed = "goal_viewed"
    case goalContribution = "goal_contribution"
    case goalAchieved = "goal_achieved"

    // Investments
    case investmentsViewed = "investments_viewed"
    case investmentsSynced = "investments_synced"

    // Debt
    case debtPaymentRecorded = "debt_payment_recorded"
    case debtPayoffStrategyChanged = "debt_payoff_strategy_changed"

    // Settings
    case settingsViewed = "settings_viewed"
    case privacyModeToggled = "privacy_mode_toggled"
    case biometricAuthToggled = "biometric_auth_toggled"

    // Errors
    case errorOccurred = "error_occurred"
    case syncFailed = "sync_failed"
}
```

### Event Tracking Implementation

```swift
// AnalyticsTracker.swift
actor AnalyticsTracker {
    private let analyticsManager: AnalyticsManager
    private var eventQueue: [AnalyticsEvent] = []
    private let maxQueueSize = 100

    func track(_ eventName: AnalyticsEventName, properties: [String: AnalyticsValue] = [:]) {
        var enrichedProperties = properties

        // Add standard properties
        enrichedProperties["platform"] = .string("visionOS")
        enrichedProperties["app_version"] = .string(AppVersion.current)
        enrichedProperties["os_version"] = .string(UIDevice.current.systemVersion)

        let event = AnalyticsEvent(
            name: eventName.rawValue,
            timestamp: Date(),
            properties: enrichedProperties
        )

        // Validate before tracking
        guard event.validate() else {
            Logger.analytics.error("Event validation failed: \(eventName.rawValue)")
            return
        }

        eventQueue.append(event)

        // Flush if queue is full
        if eventQueue.count >= maxQueueSize {
            Task {
                await flush()
            }
        }
    }

    func flush() async {
        guard !eventQueue.isEmpty else { return }

        let eventsToSend = eventQueue
        eventQueue.removeAll()

        // Send to analytics backend
        do {
            try await sendEvents(eventsToSend)
            Logger.analytics.info("Flushed \(eventsToSend.count) events")
        } catch {
            Logger.analytics.error("Failed to send events: \(error)")
            // Re-queue events
            eventQueue.append(contentsOf: eventsToSend)
        }
    }

    private func sendEvents(_ events: [AnalyticsEvent]) async throws {
        // Send to analytics service (e.g., custom backend, TelemetryDeck)
        // DO NOT use services that collect PII (avoid Google Analytics, etc.)
    }
}
```

### Usage Examples

```swift
// Track screen view
func viewDidAppear() {
    Task {
        await analyticsTracker.track(
            .screenViewed,
            properties: [
                "screen_name": .string("dashboard")
            ]
        )
    }
}

// Track feature usage (no amounts!)
func budgetCreated(strategy: BudgetStrategy) {
    Task {
        await analyticsTracker.track(
            .budgetCreated,
            properties: [
                "strategy": .string(strategy.rawValue),
                "category_count": .int(categories.count)
            ]
        )
    }
}

// Track errors (no sensitive info!)
func handleError(_ error: Error) {
    Task {
        await analyticsTracker.track(
            .errorOccurred,
            properties: [
                "error_type": .string(String(describing: type(of: error))),
                "error_domain": .string((error as NSError).domain),
                "error_code": .int((error as NSError).code)
            ]
        )
    }
}
```

## Error Logging

### Error Logger

```swift
// ErrorLogger.swift
actor ErrorLogger {
    private var errorLog: [ErrorEntry] = []
    private let maxLogSize = 1000

    struct ErrorEntry {
        let id: UUID
        let timestamp: Date
        let error: Error
        let context: [String: String]
        let stackTrace: [String]

        var sanitized: ErrorEntry {
            // Remove any sensitive data from context
            var sanitizedContext = context
            let sensitiveKeys = ["token", "password", "key", "secret"]

            for key in sanitizedContext.keys {
                if sensitiveKeys.contains(where: { key.lowercased().contains($0) }) {
                    sanitizedContext[key] = "[REDACTED]"
                }
            }

            return ErrorEntry(
                id: id,
                timestamp: timestamp,
                error: error,
                context: sanitizedContext,
                stackTrace: stackTrace
            )
        }
    }

    func log(_ error: Error, context: [String: String] = [:]) {
        let entry = ErrorEntry(
            id: UUID(),
            timestamp: Date(),
            error: error,
            context: context,
            stackTrace: Thread.callStackSymbols
        )

        errorLog.append(entry.sanitized)

        // Keep log size manageable
        if errorLog.count > maxLogSize {
            errorLog.removeFirst(errorLog.count - maxLogSize)
        }

        // Log to system
        Logger.error.error("Error: \(error.localizedDescription)")

        // Send critical errors immediately
        if isCritical(error) {
            Task {
                await sendErrorReport(entry)
            }
        }
    }

    private func isCritical(_ error: Error) -> Bool {
        // Database errors, security errors, crashes
        error is DatabaseError || error is SecurityError
    }

    private func sendErrorReport(_ entry: ErrorEntry) async {
        // Send to error tracking service
        // Use privacy-preserving service (e.g., custom backend)
    }

    func getRecentErrors(count: Int = 10) -> [ErrorEntry] {
        Array(errorLog.suffix(count))
    }
}
```

## Performance Metrics

### Performance Tracker

```swift
// PerformanceTracker.swift
actor PerformanceTracker {
    private var metrics: [String: [PerformanceSample]] = [:]

    struct PerformanceSample {
        let timestamp: Date
        let duration: TimeInterval
        let success: Bool
    }

    func recordMetric(_ operation: String, duration: TimeInterval, success: Bool = true) {
        let sample = PerformanceSample(
            timestamp: Date(),
            duration: duration,
            success: success
        )

        metrics[operation, default: []].append(sample)

        // Log slow operations
        if duration > 1.0 {
            Logger.performance.warning("\(operation) took \(duration)s")

            // Track slow operations
            Task {
                await analyticsTracker.track(
                    .errorOccurred,
                    properties: [
                        "type": .string("slow_operation"),
                        "operation": .string(operation),
                        "duration_ms": .int(Int(duration * 1000))
                    ]
                )
            }
        }
    }

    func getStatistics(for operation: String) -> OperationStatistics? {
        guard let samples = metrics[operation], !samples.isEmpty else {
            return nil
        }

        let durations = samples.map { $0.duration }
        let successCount = samples.filter { $0.success }.count

        return OperationStatistics(
            operation: operation,
            count: samples.count,
            averageDuration: durations.reduce(0, +) / Double(durations.count),
            minDuration: durations.min() ?? 0,
            maxDuration: durations.max() ?? 0,
            successRate: Double(successCount) / Double(samples.count),
            p50: percentile(durations, 0.5),
            p95: percentile(durations, 0.95),
            p99: percentile(durations, 0.99)
        )
    }

    private func percentile(_ values: [TimeInterval], _ p: Double) -> TimeInterval {
        let sorted = values.sorted()
        let index = Int(Double(sorted.count) * p)
        return sorted[min(index, sorted.count - 1)]
    }
}

struct OperationStatistics {
    let operation: String
    let count: Int
    let averageDuration: TimeInterval
    let minDuration: TimeInterval
    let maxDuration: TimeInterval
    let successRate: Double
    let p50: TimeInterval
    let p95: TimeInterval
    let p99: TimeInterval
}
```

## User Behavior Analytics

### Session Tracking

```swift
// SessionTracker.swift
@Observable
@MainActor
class SessionTracker {
    private var sessionId: UUID
    private var sessionStart: Date
    private var screenViewCount = 0
    private var eventCount = 0

    init() {
        self.sessionId = UUID()
        self.sessionStart = Date()
        startSession()
    }

    func startSession() {
        Task {
            await analyticsTracker.track(
                .appLaunched,
                properties: [
                    "session_id": .string(sessionId.uuidString)
                ]
            )
        }
    }

    func endSession() {
        let duration = Date().timeIntervalSince(sessionStart)

        Task {
            await analyticsTracker.track(
                .appBackgrounded,
                properties: [
                    "session_id": .string(sessionId.uuidString),
                    "session_duration_seconds": .int(Int(duration)),
                    "screen_view_count": .int(screenViewCount),
                    "event_count": .int(eventCount)
                ]
            )

            await analyticsTracker.flush()
        }
    }

    func trackScreenView(_ screenName: String) {
        screenViewCount += 1

        Task {
            await analyticsTracker.track(
                .screenViewed,
                properties: [
                    "session_id": .string(sessionId.uuidString),
                    "screen_name": .string(screenName),
                    "view_count": .int(screenViewCount)
                ]
            )
        }
    }
}
```

### Funnel Tracking

```swift
// FunnelTracker.swift
actor FunnelTracker {
    enum OnboardingFunnel: String {
        case started = "onboarding_started"
        case bankSelection = "onboarding_bank_selection"
        case bankConnection = "onboarding_bank_connection"
        case budgetSetup = "onboarding_budget_setup"
        case completed = "onboarding_completed"
    }

    private var currentFunnel: [String] = []

    func trackStep(_ step: OnboardingFunnel) {
        currentFunnel.append(step.rawValue)

        Task {
            await analyticsTracker.track(
                .screenViewed,
                properties: [
                    "funnel_step": .string(step.rawValue),
                    "funnel_position": .int(currentFunnel.count)
                ]
            )
        }
    }

    func completeFunnel() {
        // Track funnel completion
        Task {
            await analyticsTracker.track(
                .onboardingCompleted,
                properties: [
                    "funnel_steps": .int(currentFunnel.count),
                    "completed": .bool(true)
                ]
            )
        }

        currentFunnel.removeAll()
    }

    func abandonFunnel(at step: OnboardingFunnel) {
        // Track funnel abandonment for optimization
        Task {
            await analyticsTracker.track(
                .onboardingSkipped,
                properties: [
                    "abandoned_at": .string(step.rawValue),
                    "steps_completed": .int(currentFunnel.count)
                ]
            )
        }

        currentFunnel.removeAll()
    }
}
```

## Dashboards & Alerts

### Key Metrics Dashboard

```
┌─────────────────────────────────────────────────────────┐
│          Personal Finance Navigator Metrics             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Daily Active Users:     5,234  (+12% vs yesterday)    │
│  Monthly Active Users:  45,678  (+8% vs last month)    │
│  Sessions Today:        15,432                          │
│  Avg Session Duration:   12m 34s                        │
│                                                         │
│  Feature Usage (Last 7 Days):                           │
│    Budget Management:    78%                            │
│    Transaction View:     92%                            │
│    Investment Tracking:  34%                            │
│    Goal Management:      56%                            │
│                                                         │
│  Performance:                                           │
│    Avg App Launch Time:  1.8s  (Target: <2s) ✓         │
│    Avg Sync Time:        7.2s  (Target: <10s) ✓        │
│    Error Rate:           0.2%  (Target: <1%) ✓         │
│    Crash Rate:           0.05% (Target: <0.1%) ✓       │
│                                                         │
│  User Satisfaction:                                     │
│    NPS Score:            67                             │
│    App Store Rating:     4.7/5.0                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Alert Configuration

```swift
// AlertManager.swift
actor AlertManager {
    enum AlertThreshold {
        case errorRate(Double)           // % of requests
        case crashRate(Double)           // % of sessions
        case slowOperation(TimeInterval)  // Seconds
        case highMemory(UInt64)          // Bytes
        case lowConversion(Double)       // % conversion
    }

    func checkThresholds(metrics: AppMetrics) {
        // Error rate too high
        if metrics.errorRate > 0.05 { // 5%
            sendAlert(.errorRate(metrics.errorRate))
        }

        // Crash rate too high
        if metrics.crashRate > 0.01 { // 1%
            sendAlert(.crashRate(metrics.crashRate))
        }

        // Slow operations
        if metrics.avgSyncTime > 15.0 { // 15 seconds
            sendAlert(.slowOperation(metrics.avgSyncTime))
        }

        // Low onboarding conversion
        if metrics.onboardingConversion < 0.5 { // 50%
            sendAlert(.lowConversion(metrics.onboardingConversion))
        }
    }

    private func sendAlert(_ threshold: AlertThreshold) {
        // Send alert to team (Slack, email, PagerDuty, etc.)
        Logger.analytics.critical("Alert triggered: \(threshold)")
    }
}
```

### A/B Testing Framework

```swift
// ABTestManager.swift
actor ABTestManager {
    private let anonymousUserId: String

    enum Experiment: String {
        case budgetCreationFlow = "budget_creation_flow_v2"
        case onboardingLength = "onboarding_length"
    }

    enum Variant: String {
        case control
        case variantA
        case variantB
    }

    func getVariant(for experiment: Experiment) -> Variant {
        // Consistent variant assignment based on user ID
        let hash = abs(anonymousUserId.hashValue)
        let bucket = hash % 100

        switch experiment {
        case .budgetCreationFlow:
            // 50/50 split
            return bucket < 50 ? .control : .variantA

        case .onboardingLength:
            // 33/33/33 split
            if bucket < 33 {
                return .control
            } else if bucket < 66 {
                return .variantA
            } else {
                return .variantB
            }
        }
    }

    func trackExperiment(_ experiment: Experiment, variant: Variant, event: String) {
        Task {
            await analyticsTracker.track(
                .screenViewed,
                properties: [
                    "experiment": .string(experiment.rawValue),
                    "variant": .string(variant.rawValue),
                    "event": .string(event)
                ]
            )
        }
    }
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: Begin Implementation
