//
//  MetricsCollector.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import Observation

/// Service for collecting and aggregating agent metrics in real-time
/// Supports sub-second latency monitoring for up to 50,000 agents
actor MetricsCollector {

    // MARK: - Constants

    /// Maximum history size per agent (10 minutes at 100Hz = 60,000 samples)
    private static let defaultMaxHistorySize = 60_000

    /// Default update frequency in Hz (updates per second)
    private static let defaultUpdateFrequency: Int = 100

    // MARK: - Properties

    /// Active monitoring sessions (agentId -> Task)
    private var monitoringSessions: [UUID: Task<Void, Never>] = [:]

    /// Metrics cache (agentId -> latest metrics)
    private var metricsCache: [UUID: AgentMetrics] = [:]

    /// Metrics history using efficient circular buffer (agentId -> time series)
    private var metricsHistory: [UUID: CircularBuffer<TimestampedMetrics>] = [:]

    /// Maximum history size per agent
    private let maxHistorySize: Int

    /// Update frequency in Hz (updates per second)
    private let updateFrequency: Int

    /// Metrics update continuation for streaming
    private var updateContinuation: AsyncStream<MetricsUpdate>.Continuation?

    // MARK: - Initialization

    init(maxHistorySize: Int = defaultMaxHistorySize, updateFrequency: Int = defaultUpdateFrequency) {
        self.maxHistorySize = maxHistorySize
        self.updateFrequency = updateFrequency
    }

    // MARK: - Monitoring Control

    /// Start monitoring an agent
    func startMonitoring(agentId: UUID) {
        // Cancel existing session if any
        monitoringSessions[agentId]?.cancel()

        // Create new monitoring task
        let task = Task {
            await monitorAgent(agentId)
        }

        monitoringSessions[agentId] = task
    }

    /// Stop monitoring an agent
    func stopMonitoring(agentId: UUID) {
        monitoringSessions[agentId]?.cancel()
        monitoringSessions.removeValue(forKey: agentId)
    }

    /// Stop all monitoring
    func stopAllMonitoring() {
        for task in monitoringSessions.values {
            task.cancel()
        }
        monitoringSessions.removeAll()
    }

    // MARK: - Metrics Collection

    /// Monitor an agent continuously
    private func monitorAgent(_ agentId: UUID) async {
        let interval = 1.0 / Double(updateFrequency) // 100Hz = 10ms

        while !Task.isCancelled {
            // Collect metrics
            let metrics = await collectMetrics(for: agentId)

            // Update cache
            metricsCache[agentId] = metrics

            // Update history
            addToHistory(agentId: agentId, metrics: metrics)

            // Publish update
            updateContinuation?.yield(MetricsUpdate(agentId: agentId, metrics: metrics))

            // Sleep for update interval
            try? await Task.sleep(for: .milliseconds(Int(interval * 1000)))
        }
    }

    /// Collect metrics for a specific agent
    private func collectMetrics(for agentId: UUID) async -> AgentMetrics {
        // In production, this would query the actual agent platform
        // For now, we'll generate realistic simulated metrics

        let previousMetrics = metricsCache[agentId]

        let cpuUsage = simulateCPU(previous: previousMetrics?.cpuUsage)
        let errorRate = simulateErrorRate(previous: previousMetrics?.errorRate)
        let averageLatency = simulateLatency(previous: previousMetrics?.averageLatency)

        // Calculate health score based on metrics
        let healthScore = calculateHealthScore(cpuUsage: cpuUsage, errorRate: errorRate, latency: averageLatency)

        return AgentMetrics(
            agentId: agentId,
            timestamp: Date(),
            requestsPerSecond: simulateRequests(previous: previousMetrics?.requestsPerSecond),
            averageLatency: averageLatency,
            p95Latency: averageLatency * 1.5,
            p99Latency: averageLatency * 2.0,
            errorRate: errorRate,
            cpuUsage: cpuUsage,
            memoryUsage: Int64(simulateMemory(previous: previousMetrics.map { Double($0.memoryUsage) }) * 1024 * 1024), // Convert MB to bytes
            networkBytesIn: Int64(simulateNetwork(previous: previousMetrics.map { Double($0.networkBytesIn) / 1024 }) * 1024), // KB/s
            networkBytesOut: Int64(simulateNetwork(previous: previousMetrics.map { Double($0.networkBytesOut) / 1024 }) * 1024),
            successRate: 1.0 - errorRate,
            throughput: simulateRequests(previous: previousMetrics?.throughput),
            healthScore: healthScore
        )
    }

    /// Calculate health score based on key metrics
    private func calculateHealthScore(cpuUsage: Double, errorRate: Double, latency: TimeInterval) -> Double {
        var score = 1.0

        // CPU penalty (usage above 70% reduces score)
        if cpuUsage > 0.7 {
            score -= (cpuUsage - 0.7) * 2.0
        }

        // Error rate penalty
        score -= errorRate * 5.0

        // Latency penalty (latency above 100ms reduces score)
        if latency > 0.1 {
            score -= (latency - 0.1) * 2.0
        }

        return max(0.0, min(1.0, score))
    }

    // MARK: - Metrics Retrieval

    /// Get latest metrics for an agent
    func getLatestMetrics(for agentId: UUID) -> AgentMetrics? {
        metricsCache[agentId]
    }

    /// Get metrics history for an agent within a time duration
    func getMetricsHistory(for agentId: UUID, last duration: TimeInterval) -> [TimestampedMetrics] {
        guard let history = metricsHistory[agentId] else { return [] }

        let cutoffDate = Date().addingTimeInterval(-duration)
        return history.elements(where: \.timestamp, greaterThanOrEqualTo: cutoffDate)
    }

    /// Get the most recent N metrics for an agent
    func getRecentMetrics(for agentId: UUID, count: Int) -> [TimestampedMetrics] {
        guard let history = metricsHistory[agentId] else { return [] }
        return history.suffix(count)
    }

    /// Get all cached metrics
    func getAllMetrics() -> [UUID: AgentMetrics] {
        metricsCache
    }

    // MARK: - Metrics Aggregation

    /// Get aggregate metrics across all agents using single-pass aggregation
    /// to avoid multiple iterations and prevent division by zero
    func getAggregateMetrics() -> AggregateMetrics {
        let allMetrics = Array(metricsCache.values)

        guard !allMetrics.isEmpty else {
            return AggregateMetrics.zero
        }

        // Single-pass aggregation for efficiency
        var totalCPU: Double = 0
        var totalMemoryMB: Double = 0
        var totalRequestsPerSecond: Double = 0
        var totalLatencyMs: Double = 0
        var latencyCount: Int = 0
        var totalErrorRate: Double = 0
        var totalHealthScore: Double = 0

        for metrics in allMetrics {
            totalCPU += metrics.cpuUsage
            totalMemoryMB += Double(metrics.memoryUsage) / (1024 * 1024) // Convert bytes to MB
            totalRequestsPerSecond += metrics.requestsPerSecond
            totalLatencyMs += metrics.averageLatency * 1000 // Convert to ms
            latencyCount += 1
            totalErrorRate += metrics.errorRate
            totalHealthScore += metrics.healthScore
        }

        let count = Double(allMetrics.count)

        return AggregateMetrics(
            totalCPU: totalCPU / count,
            totalMemoryMB: totalMemoryMB,
            totalRequestsPerSecond: totalRequestsPerSecond,
            averageLatencyMs: latencyCount > 0 ? totalLatencyMs / Double(latencyCount) : 0,
            totalErrorRate: totalErrorRate / count,
            averageHealthScore: totalHealthScore / count,
            activeAgents: allMetrics.count
        )
    }

    // MARK: - History Management

    /// Add metrics to history using efficient circular buffer
    /// O(1) insertion - no need to resize or shift elements
    private func addToHistory(agentId: UUID, metrics: AgentMetrics) {
        // Get or create circular buffer for this agent
        if metricsHistory[agentId] == nil {
            metricsHistory[agentId] = CircularBuffer(capacity: maxHistorySize)
        }

        let timestamped = TimestampedMetrics(
            timestamp: metrics.timestamp,
            metrics: metrics
        )

        // Circular buffer automatically overwrites oldest entry when full
        metricsHistory[agentId]?.append(timestamped)
    }

    /// Clear history for an agent
    func clearHistory(for agentId: UUID) {
        metricsHistory[agentId]?.removeAll()
        metricsHistory.removeValue(forKey: agentId)
    }

    /// Clear all history
    func clearAllHistory() {
        for agentId in metricsHistory.keys {
            metricsHistory[agentId]?.removeAll()
        }
        metricsHistory.removeAll()
    }

    /// Get the number of history entries for an agent
    func historyCount(for agentId: UUID) -> Int {
        metricsHistory[agentId]?.count ?? 0
    }

    // MARK: - Streaming

    /// Stream metrics updates
    func metricsStream() -> AsyncStream<MetricsUpdate> {
        AsyncStream { continuation in
            self.updateContinuation = continuation

            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.clearContinuation()
                }
            }
        }
    }

    private func clearContinuation() {
        updateContinuation = nil
    }

    // MARK: - Simulation Helpers (for development/testing)

    /// Simulate CPU usage (0.0 - 1.0 as percentage)
    private func simulateCPU(previous: Double?) -> Double {
        let base = previous ?? Double.random(in: 0.2...0.6)
        let change = Double.random(in: -0.05...0.05)
        return max(0, min(1.0, base + change))
    }

    /// Simulate memory usage in MB
    private func simulateMemory(previous: Double?) -> Double {
        let base = previous ?? Double.random(in: 500...2000)
        let change = Double.random(in: -50...50)
        return max(0, base + change)
    }

    /// Simulate network throughput in KB/s
    private func simulateNetwork(previous: Double?) -> Double {
        let base = previous ?? Double.random(in: 1...100)
        let change = Double.random(in: -10...10)
        return max(0, base + change)
    }

    /// Simulate requests per second
    private func simulateRequests(previous: Double?) -> Double {
        let base = previous ?? Double.random(in: 10...500)
        let change = Double.random(in: -20...20)
        return max(0, base + change)
    }

    /// Simulate average latency in seconds (TimeInterval)
    private func simulateLatency(previous: TimeInterval?) -> TimeInterval {
        let base = previous ?? Double.random(in: 0.01...0.1) // 10-100ms
        let change = Double.random(in: -0.005...0.005)
        return max(0.001, base + change)
    }

    /// Simulate error rate (0.0 - 1.0)
    private func simulateErrorRate(previous: Double?) -> Double {
        let base = previous ?? Double.random(in: 0...0.05)
        let change = Double.random(in: -0.01...0.01)
        return max(0, min(1, base + change))
    }
}

// MARK: - Supporting Types

/// Timestamped metrics for history
struct TimestampedMetrics: Sendable {
    let timestamp: Date
    let metrics: AgentMetrics
}

/// Metrics update event
struct MetricsUpdate: Sendable {
    let agentId: UUID
    let metrics: AgentMetrics
}

/// Aggregate metrics across all agents
struct AggregateMetrics: Sendable {
    let totalCPU: Double
    let totalMemoryMB: Double
    let totalRequestsPerSecond: Double
    let averageLatencyMs: Double
    let totalErrorRate: Double
    let averageHealthScore: Double
    let activeAgents: Int

    static var zero: AggregateMetrics {
        AggregateMetrics(
            totalCPU: 0,
            totalMemoryMB: 0,
            totalRequestsPerSecond: 0,
            averageLatencyMs: 0,
            totalErrorRate: 0,
            averageHealthScore: 0,
            activeAgents: 0
        )
    }
}
