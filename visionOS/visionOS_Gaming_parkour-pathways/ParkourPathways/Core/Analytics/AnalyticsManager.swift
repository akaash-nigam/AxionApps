//
//  AnalyticsManager.swift
//  Parkour Pathways
//
//  Central analytics and telemetry system
//

import Foundation
import OSLog
import Combine

/// Central analytics manager coordinating event tracking, performance monitoring, and crash reporting
@MainActor
class AnalyticsManager: ObservableObject {

    // MARK: - Singleton

    static let shared = AnalyticsManager()

    // MARK: - Published Properties

    @Published var isEnabled: Bool = true
    @Published var performanceMetrics: PerformanceMetrics = PerformanceMetrics()

    // MARK: - Dependencies

    private let eventTracker: EventTracker
    private let performanceMonitor: PerformanceMonitor
    private let crashReporter: CrashReporter

    // MARK: - State

    private var sessionId: UUID = UUID()
    private var sessionStartTime: Date = Date()
    private var currentUserId: UUID?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        self.eventTracker = EventTracker()
        self.performanceMonitor = PerformanceMonitor()
        self.crashReporter = CrashReporter()

        setupSession()
        setupPerformanceMonitoring()
    }

    // MARK: - Setup

    private func setupSession() {
        // Track session start
        trackEvent(.sessionStart(
            sessionId: sessionId,
            timestamp: sessionStartTime
        ))

        // Setup session end tracking
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.endSession()
            }
            .store(in: &cancellables)
    }

    private func setupPerformanceMonitoring() {
        // Subscribe to performance updates
        performanceMonitor.$currentMetrics
            .sink { [weak self] metrics in
                self?.performanceMetrics = metrics
                self?.checkPerformanceThresholds(metrics)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API - User Tracking

    /// Set the current user ID for analytics
    func setUserId(_ userId: UUID) {
        currentUserId = userId
        eventTracker.setUserId(userId)
        performanceMonitor.setUserId(userId)
        crashReporter.setUserId(userId)
    }

    /// Set user properties for analytics
    func setUserProperties(_ properties: [String: Any]) {
        eventTracker.setUserProperties(properties)
    }

    // MARK: - Public API - Event Tracking

    /// Track an analytics event
    func trackEvent(_ event: AnalyticsEvent) {
        guard isEnabled else { return }

        eventTracker.track(event, userId: currentUserId, sessionId: sessionId)

        // Also log critical events
        if event.isCritical {
            logCriticalEvent(event)
        }
    }

    /// Track screen view
    func trackScreenView(_ screenName: String, parameters: [String: Any] = [:]) {
        trackEvent(.screenView(
            screenName: screenName,
            parameters: parameters,
            timestamp: Date()
        ))
    }

    /// Track gameplay event
    func trackGameplayEvent(
        _ eventName: String,
        courseId: UUID?,
        parameters: [String: Any] = [:]
    ) {
        trackEvent(.gameplay(
            eventName: eventName,
            courseId: courseId,
            parameters: parameters,
            timestamp: Date()
        ))
    }

    /// Track purchase/monetization event
    func trackPurchase(productId: String, price: Decimal, currency: String) {
        trackEvent(.purchase(
            productId: productId,
            price: price,
            currency: currency,
            timestamp: Date()
        ))
    }

    /// Track achievement unlocked
    func trackAchievement(_ achievementId: String, value: Int = 100) {
        trackEvent(.achievementUnlocked(
            achievementId: achievementId,
            value: value,
            timestamp: Date()
        ))
    }

    // MARK: - Public API - Performance Monitoring

    /// Start performance monitoring
    func startPerformanceMonitoring() {
        performanceMonitor.start()
    }

    /// Stop performance monitoring
    func stopPerformanceMonitoring() {
        performanceMonitor.stop()
    }

    /// Record a performance timing
    func recordTiming(category: String, name: String, duration: TimeInterval) {
        performanceMonitor.recordTiming(
            category: category,
            name: name,
            duration: duration
        )

        // Track as event if significant
        if duration > 1.0 { // More than 1 second
            trackEvent(.performance(
                metric: "timing_\(category)_\(name)",
                value: duration,
                unit: "seconds",
                timestamp: Date()
            ))
        }
    }

    /// Record frame rate sample
    func recordFrameRate(_ fps: Double) {
        performanceMonitor.recordFrameRate(fps)
    }

    /// Record memory usage
    func recordMemoryUsage(_ bytes: Int64) {
        performanceMonitor.recordMemoryUsage(bytes)
    }

    // MARK: - Public API - Error & Crash Reporting

    /// Report an error
    func reportError(_ error: Error, context: [String: Any] = [:]) {
        crashReporter.reportError(
            error,
            context: context,
            userId: currentUserId,
            sessionId: sessionId
        )

        // Also track as event
        trackEvent(.error(
            errorType: String(describing: type(of: error)),
            errorMessage: error.localizedDescription,
            context: context,
            timestamp: Date()
        ))
    }

    /// Report a non-fatal issue
    func reportIssue(_ message: String, severity: IssueSeverity, context: [String: Any] = [:]) {
        crashReporter.reportIssue(
            message: message,
            severity: severity,
            context: context,
            userId: currentUserId,
            sessionId: sessionId
        )
    }

    /// Set crash reporting custom keys
    func setCrashReportingKey(_ key: String, value: String) {
        crashReporter.setCustomKey(key, value: value)
    }

    // MARK: - Public API - Funnel Tracking

    /// Track funnel step (e.g., onboarding, course selection)
    func trackFunnelStep(_ funnelName: String, step: Int, stepName: String) {
        trackEvent(.funnel(
            funnelName: funnelName,
            step: step,
            stepName: stepName,
            timestamp: Date()
        ))
    }

    /// Track funnel completion
    func trackFunnelCompletion(_ funnelName: String, duration: TimeInterval) {
        trackEvent(.funnelComplete(
            funnelName: funnelName,
            duration: duration,
            timestamp: Date()
        ))
    }

    // MARK: - Public API - A/B Testing

    /// Get experiment variant for user
    func getExperimentVariant(_ experimentId: String) -> String {
        // Simple hash-based assignment
        let userId = currentUserId?.uuidString ?? sessionId.uuidString
        let hash = "\(experimentId)_\(userId)".hashValue
        let variant = abs(hash) % 2 == 0 ? "A" : "B"

        // Track assignment
        trackEvent(.experimentAssignment(
            experimentId: experimentId,
            variant: variant,
            timestamp: Date()
        ))

        return variant
    }

    // MARK: - Public API - Session Management

    /// End the current session
    func endSession() {
        let duration = Date().timeIntervalSince(sessionStartTime)

        trackEvent(.sessionEnd(
            sessionId: sessionId,
            duration: duration,
            timestamp: Date()
        ))

        // Flush all pending data
        flush()
    }

    /// Force flush all analytics data
    func flush() {
        eventTracker.flush()
        performanceMonitor.flush()
        crashReporter.flush()
    }

    // MARK: - Private Helpers

    private func checkPerformanceThresholds(_ metrics: PerformanceMetrics) {
        // Alert if frame rate drops below threshold
        if metrics.averageFPS < 60 {
            reportIssue(
                "Low frame rate detected: \(metrics.averageFPS) FPS",
                severity: .warning,
                context: [
                    "average_fps": metrics.averageFPS,
                    "min_fps": metrics.minFPS,
                    "memory_mb": metrics.memoryUsageMB
                ]
            )
        }

        // Alert if memory usage is high
        if metrics.memoryUsageMB > 1500 { // 1.5 GB
            reportIssue(
                "High memory usage: \(metrics.memoryUsageMB) MB",
                severity: .warning,
                context: [
                    "memory_mb": metrics.memoryUsageMB,
                    "peak_memory_mb": metrics.peakMemoryMB
                ]
            )
        }
    }

    private func logCriticalEvent(_ event: AnalyticsEvent) {
        let logger = Logger(subsystem: "com.parkourpathways", category: "Analytics")
        logger.critical("Critical Event: \(event.name)")
    }
}

// MARK: - Supporting Types

enum AnalyticsEvent {
    case sessionStart(sessionId: UUID, timestamp: Date)
    case sessionEnd(sessionId: UUID, duration: TimeInterval, timestamp: Date)
    case screenView(screenName: String, parameters: [String: Any], timestamp: Date)
    case gameplay(eventName: String, courseId: UUID?, parameters: [String: Any], timestamp: Date)
    case purchase(productId: String, price: Decimal, currency: String, timestamp: Date)
    case achievementUnlocked(achievementId: String, value: Int, timestamp: Date)
    case performance(metric: String, value: Double, unit: String, timestamp: Date)
    case error(errorType: String, errorMessage: String, context: [String: Any], timestamp: Date)
    case funnel(funnelName: String, step: Int, stepName: String, timestamp: Date)
    case funnelComplete(funnelName: String, duration: TimeInterval, timestamp: Date)
    case experimentAssignment(experimentId: String, variant: String, timestamp: Date)

    var name: String {
        switch self {
        case .sessionStart: return "session_start"
        case .sessionEnd: return "session_end"
        case .screenView: return "screen_view"
        case .gameplay: return "gameplay"
        case .purchase: return "purchase"
        case .achievementUnlocked: return "achievement_unlocked"
        case .performance: return "performance"
        case .error: return "error"
        case .funnel: return "funnel_step"
        case .funnelComplete: return "funnel_complete"
        case .experimentAssignment: return "experiment_assignment"
        }
    }

    var isCritical: Bool {
        switch self {
        case .error, .purchase:
            return true
        default:
            return false
        }
    }
}

struct PerformanceMetrics {
    var averageFPS: Double = 0
    var minFPS: Double = 0
    var maxFPS: Double = 0
    var memoryUsageMB: Double = 0
    var peakMemoryMB: Double = 0
    var cpuUsagePercent: Double = 0
    var networkLatency: TimeInterval = 0
}

enum IssueSeverity: String {
    case debug
    case info
    case warning
    case error
    case critical
}
