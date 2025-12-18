//
//  AgentMetrics.swift
//  AI Agent Coordinator
//
//  Performance and health metrics for AI agents
//

import Foundation
import SwiftData

@Model
final class AgentMetrics: Identifiable, Codable, @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var agentId: UUID
    var timestamp: Date

    // MARK: - Performance Metrics
    var requestsPerSecond: Double
    var averageLatency: TimeInterval
    var p95Latency: TimeInterval
    var p99Latency: TimeInterval
    var errorRate: Double

    // MARK: - Resource Metrics
    var cpuUsage: Double
    var memoryUsage: Int64
    var networkBytesIn: Int64
    var networkBytesOut: Int64

    // MARK: - Quality Metrics
    var successRate: Double
    var accuracyScore: Double?
    var throughput: Double

    // MARK: - Health Metrics

    /// Overall health score (0.0 - 1.0) combining multiple factors
    var healthScore: Double

    // MARK: - Cost Metrics
    var apiCallsCount: Int
    var estimatedCost: Decimal

    init(
        id: UUID = UUID(),
        agentId: UUID,
        timestamp: Date = Date(),
        requestsPerSecond: Double = 0,
        averageLatency: TimeInterval = 0,
        p95Latency: TimeInterval = 0,
        p99Latency: TimeInterval = 0,
        errorRate: Double = 0,
        cpuUsage: Double = 0,
        memoryUsage: Int64 = 0,
        networkBytesIn: Int64 = 0,
        networkBytesOut: Int64 = 0,
        successRate: Double = 1.0,
        accuracyScore: Double? = nil,
        throughput: Double = 0,
        healthScore: Double = 1.0,
        apiCallsCount: Int = 0,
        estimatedCost: Decimal = 0
    ) {
        self.id = id
        self.agentId = agentId
        self.timestamp = timestamp
        self.requestsPerSecond = requestsPerSecond
        self.averageLatency = averageLatency
        self.p95Latency = p95Latency
        self.p99Latency = p99Latency
        self.errorRate = errorRate
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.networkBytesIn = networkBytesIn
        self.networkBytesOut = networkBytesOut
        self.successRate = successRate
        self.accuracyScore = accuracyScore
        self.throughput = throughput
        self.healthScore = healthScore
        self.apiCallsCount = apiCallsCount
        self.estimatedCost = estimatedCost
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, agentId, timestamp
        case requestsPerSecond, averageLatency, p95Latency, p99Latency, errorRate
        case cpuUsage, memoryUsage, networkBytesIn, networkBytesOut
        case successRate, accuracyScore, throughput, healthScore
        case apiCallsCount, estimatedCost
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        agentId = try container.decode(UUID.self, forKey: .agentId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        requestsPerSecond = try container.decode(Double.self, forKey: .requestsPerSecond)
        averageLatency = try container.decode(TimeInterval.self, forKey: .averageLatency)
        p95Latency = try container.decode(TimeInterval.self, forKey: .p95Latency)
        p99Latency = try container.decode(TimeInterval.self, forKey: .p99Latency)
        errorRate = try container.decode(Double.self, forKey: .errorRate)
        cpuUsage = try container.decode(Double.self, forKey: .cpuUsage)
        memoryUsage = try container.decode(Int64.self, forKey: .memoryUsage)
        networkBytesIn = try container.decode(Int64.self, forKey: .networkBytesIn)
        networkBytesOut = try container.decode(Int64.self, forKey: .networkBytesOut)
        successRate = try container.decode(Double.self, forKey: .successRate)
        accuracyScore = try container.decodeIfPresent(Double.self, forKey: .accuracyScore)
        throughput = try container.decode(Double.self, forKey: .throughput)
        healthScore = try container.decodeIfPresent(Double.self, forKey: .healthScore) ?? 1.0
        apiCallsCount = try container.decode(Int.self, forKey: .apiCallsCount)
        estimatedCost = try container.decode(Decimal.self, forKey: .estimatedCost)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(agentId, forKey: .agentId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(requestsPerSecond, forKey: .requestsPerSecond)
        try container.encode(averageLatency, forKey: .averageLatency)
        try container.encode(p95Latency, forKey: .p95Latency)
        try container.encode(p99Latency, forKey: .p99Latency)
        try container.encode(errorRate, forKey: .errorRate)
        try container.encode(cpuUsage, forKey: .cpuUsage)
        try container.encode(memoryUsage, forKey: .memoryUsage)
        try container.encode(networkBytesIn, forKey: .networkBytesIn)
        try container.encode(networkBytesOut, forKey: .networkBytesOut)
        try container.encode(successRate, forKey: .successRate)
        try container.encodeIfPresent(accuracyScore, forKey: .accuracyScore)
        try container.encode(throughput, forKey: .throughput)
        try container.encode(healthScore, forKey: .healthScore)
        try container.encode(apiCallsCount, forKey: .apiCallsCount)
        try container.encode(estimatedCost, forKey: .estimatedCost)
    }

    // MARK: - Utility Methods
    var formattedLatency: String {
        String(format: "%.0fms", averageLatency * 1000)
    }

    var formattedCPU: String {
        String(format: "%.1f%%", cpuUsage * 100)
    }

    var formattedMemory: String {
        ByteCountFormatter.string(fromByteCount: memoryUsage, countStyle: .memory)
    }

    var healthStatus: HealthStatus {
        if errorRate > 0.1 || cpuUsage > 0.9 {
            return .critical
        } else if errorRate > 0.05 || cpuUsage > 0.7 {
            return .warning
        } else {
            return .healthy
        }
    }

    enum HealthStatus {
        case healthy
        case warning
        case critical
    }
}
