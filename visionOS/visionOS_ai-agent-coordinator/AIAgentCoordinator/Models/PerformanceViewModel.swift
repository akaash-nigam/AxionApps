//
//  PerformanceViewModel.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import Observation

/// ViewModel for performance monitoring and analytics
/// Provides aggregated metrics and historical data analysis
@Observable
@MainActor
final class PerformanceViewModel {

    // MARK: - Properties

    /// Metrics collector service
    private let metricsCollector: MetricsCollector

    /// Agent coordinator
    private let coordinator: AgentCoordinator

    /// Aggregate metrics across all agents
    private(set) var aggregateMetrics: AggregateMetrics = .zero

    /// Historical data for charts
    private(set) var historicalData: [TimePeriod: [TimestampedMetrics]] = [:]

    /// Selected time period for charts
    var selectedTimePeriod: TimePeriod = .lastHour {
        didSet {
            Task {
                await loadHistoricalData()
            }
        }
    }

    /// Performance alerts
    private(set) var alerts: [PerformanceAlert] = []

    /// Is monitoring active
    private(set) var isMonitoring = false

    /// Update interval for real-time data
    private let updateInterval: TimeInterval = 1.0 // 1 second

    /// Monitoring task
    private var monitoringTask: Task<Void, Never>?

    // MARK: - Initialization

    init(metricsCollector: MetricsCollector, coordinator: AgentCoordinator) {
        self.metricsCollector = metricsCollector
        self.coordinator = coordinator
    }

    convenience init() {
        self.init(
            metricsCollector: MetricsCollector(),
            coordinator: AgentCoordinator()
        )
    }

    // MARK: - Lifecycle

    /// Start performance monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        monitoringTask = Task {
            await monitor()
        }
    }

    /// Stop performance monitoring
    func stopMonitoring() {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    /// Main monitoring loop
    private func monitor() async {
        while !Task.isCancelled {
            await updateMetrics()
            await checkForAlerts()

            try? await Task.sleep(for: .seconds(updateInterval))
        }
    }

    // MARK: - Metrics Updates

    /// Update aggregate metrics
    private func updateMetrics() async {
        aggregateMetrics = await metricsCollector.getAggregateMetrics()
    }

    /// Load historical data for selected period
    private func loadHistoricalData() async {
        let duration = selectedTimePeriod.duration

        // Get data for each monitored agent
        for agent in coordinator.agents {
            let history = await metricsCollector.getMetricsHistory(
                for: agent.id,
                last: duration
            )

            if !history.isEmpty {
                historicalData[selectedTimePeriod] = history
            }
        }
    }

    // MARK: - Alerts

    /// Check for performance issues and generate alerts
    private func checkForAlerts() async {
        var newAlerts: [PerformanceAlert] = []

        for agent in coordinator.agents {
            guard let metrics = await metricsCollector.getLatestMetrics(for: agent.id) else {
                continue
            }

            // High CPU usage
            if metrics.cpuUsage * 100 > 90 {
                newAlerts.append(PerformanceAlert(
                    id: UUID(),
                    agentId: agent.id,
                    agentName: agent.name,
                    severity: .high,
                    type: .highCPU,
                    message: "CPU usage at \(Int(metrics.cpuUsage * 100))%",
                    timestamp: Date()
                ))
            }

            // High memory usage
            let memoryMB = Double(metrics.memoryUsage) / (1024 * 1024)
            if memoryMB > 4000 {
                newAlerts.append(PerformanceAlert(
                    id: UUID(),
                    agentId: agent.id,
                    agentName: agent.name,
                    severity: .medium,
                    type: .highMemory,
                    message: "Memory usage at \(Int(memoryMB))MB",
                    timestamp: Date()
                ))
            }

            // High error rate
            if metrics.errorRate > 0.05 {
                newAlerts.append(PerformanceAlert(
                    id: UUID(),
                    agentId: agent.id,
                    agentName: agent.name,
                    severity: .high,
                    type: .highErrorRate,
                    message: "Error rate at \(Int(metrics.errorRate * 100))%",
                    timestamp: Date()
                ))
            }

            // High latency
            let latencyMs = metrics.averageLatency * 1000
            if latencyMs > 1000 {
                newAlerts.append(PerformanceAlert(
                    id: UUID(),
                    agentId: agent.id,
                    agentName: agent.name,
                    severity: .medium,
                    type: .highLatency,
                    message: "Latency at \(Int(latencyMs))ms",
                    timestamp: Date()
                ))
            }
        }

        alerts = newAlerts
    }

    /// Dismiss an alert
    func dismissAlert(_ alert: PerformanceAlert) {
        alerts.removeAll { $0.id == alert.id }
    }

    /// Dismiss all alerts
    func dismissAllAlerts() {
        alerts.removeAll()
    }

    // MARK: - Analytics

    /// Calculate trends over time
    func calculateTrends() -> PerformanceTrends {
        guard let currentPeriodData = historicalData[selectedTimePeriod],
              !currentPeriodData.isEmpty else {
            return PerformanceTrends.zero
        }

        // Calculate averages for first and last halves
        let midpoint = currentPeriodData.count / 2
        let firstHalf = Array(currentPeriodData[0..<midpoint])
        let secondHalf = Array(currentPeriodData[midpoint..<currentPeriodData.count])

        let firstAvgCPU = firstHalf.map { $0.metrics.cpuUsage * 100 }.reduce(0, +) / Double(firstHalf.count)
        let secondAvgCPU = secondHalf.map { $0.metrics.cpuUsage * 100 }.reduce(0, +) / Double(secondHalf.count)

        let firstAvgMem = firstHalf.map { Double($0.metrics.memoryUsage) / (1024 * 1024) }.reduce(0, +) / Double(firstHalf.count)
        let secondAvgMem = secondHalf.map { Double($0.metrics.memoryUsage) / (1024 * 1024) }.reduce(0, +) / Double(secondHalf.count)

        return PerformanceTrends(
            cpuTrend: calculateTrendDirection(from: firstAvgCPU, to: secondAvgCPU),
            memoryTrend: calculateTrendDirection(from: firstAvgMem, to: secondAvgMem),
            latencyTrend: .stable,
            errorRateTrend: .stable
        )
    }

    private func calculateTrendDirection(from first: Double, to second: Double) -> TrendDirection {
        let change = ((second - first) / first) * 100

        if change > 10 {
            return .increasing
        } else if change < -10 {
            return .decreasing
        } else {
            return .stable
        }
    }

    /// Get top N agents by metric
    func topAgents(by metric: MetricType, count: Int = 5) async -> [AgentPerformance] {
        var performances: [AgentPerformance] = []

        for agent in coordinator.agents {
            guard let metrics = await metricsCollector.getLatestMetrics(for: agent.id) else {
                continue
            }

            let value: Double
            switch metric {
            case .cpu:
                value = metrics.cpuUsage * 100
            case .memory:
                value = Double(metrics.memoryUsage) / (1024 * 1024)
            case .requests:
                value = metrics.requestsPerSecond
            case .latency:
                value = metrics.averageLatency * 1000
            case .errorRate:
                value = metrics.errorRate
            }

            performances.append(AgentPerformance(
                agentId: agent.id,
                agentName: agent.name,
                metricType: metric,
                value: value
            ))
        }

        return Array(performances.sorted { $0.value > $1.value }.prefix(count))
    }

    // MARK: - Export

    /// Export performance data as CSV
    func exportData() -> String {
        var csv = "Timestamp,Agent,CPU,Memory,Requests,Latency,ErrorRate\n"

        for (_, data) in historicalData {
            for timestamped in data {
                let metrics = timestamped.metrics
                csv += "\(timestamped.timestamp),"
                csv += "Unknown," // Would need agent mapping
                csv += "\(metrics.cpuUsage * 100),"
                csv += "\(Double(metrics.memoryUsage) / (1024 * 1024)),"
                csv += "\(metrics.requestsPerSecond),"
                csv += "\(metrics.averageLatency * 1000),"
                csv += "\(metrics.errorRate)\n"
            }
        }

        return csv
    }
}

// MARK: - Supporting Types

/// Time period for historical data
enum TimePeriod {
    case last5Minutes
    case last15Minutes
    case lastHour
    case last6Hours
    case last24Hours

    var duration: TimeInterval {
        switch self {
        case .last5Minutes: return 5 * 60
        case .last15Minutes: return 15 * 60
        case .lastHour: return 60 * 60
        case .last6Hours: return 6 * 60 * 60
        case .last24Hours: return 24 * 60 * 60
        }
    }
}

/// Performance alert
struct PerformanceAlert: Identifiable {
    let id: UUID
    let agentId: UUID
    let agentName: String
    let severity: AlertSeverity
    let type: AlertType
    let message: String
    let timestamp: Date
}

enum AlertSeverity {
    case low
    case medium
    case high
    case critical
}

enum AlertType {
    case highCPU
    case highMemory
    case highLatency
    case highErrorRate
    case agentDown
}

/// Performance trends
struct PerformanceTrends {
    let cpuTrend: TrendDirection
    let memoryTrend: TrendDirection
    let latencyTrend: TrendDirection
    let errorRateTrend: TrendDirection

    static var zero: PerformanceTrends {
        PerformanceTrends(
            cpuTrend: .stable,
            memoryTrend: .stable,
            latencyTrend: .stable,
            errorRateTrend: .stable
        )
    }
}

enum TrendDirection {
    case increasing
    case decreasing
    case stable
}

/// Metric type for sorting
enum MetricType: String {
    case cpu = "CPU"
    case memory = "Memory"
    case requests = "Requests"
    case latency = "Latency"
    case errorRate = "Error Rate"
}

/// Agent performance snapshot
struct AgentPerformance {
    let agentId: UUID
    let agentName: String
    let metricType: MetricType
    let value: Double
}
