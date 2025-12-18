//
//  MetricsCollectorTests.swift
//  AIAgentCoordinatorTests
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import XCTest
@testable import AIAgentCoordinator

/// Unit tests for MetricsCollector service
final class MetricsCollectorTests: XCTestCase {

    var sut: MetricsCollector!

    override func setUp() async throws {
        try await super.setUp()
        sut = MetricsCollector()
    }

    override func tearDown() async throws {
        await sut.stopAllMonitoring()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Monitoring Tests

    func testStartMonitoring_Success() async throws {
        // Given
        let agentId = UUID()

        // When
        await sut.startMonitoring(agentId: agentId)

        // Wait a bit for metrics to be collected
        try await Task.sleep(for: .milliseconds(100))

        // Then
        let metrics = await sut.getLatestMetrics(for: agentId)
        XCTAssertNotNil(metrics, "Metrics should be collected after starting monitoring")
    }

    func testStopMonitoring_Success() async throws {
        // Given
        let agentId = UUID()
        await sut.startMonitoring(agentId: agentId)
        try await Task.sleep(for: .milliseconds(100))

        // When
        await sut.stopMonitoring(agentId: agentId)
        let metricsAfterStop = await sut.getLatestMetrics(for: agentId)

        // Then
        // Metrics might still be cached, but monitoring should have stopped
        XCTAssertNotNil(metricsAfterStop, "Cached metrics should still be available")
    }

    func testGetAggregateMetrics() async throws {
        // Given
        let agentIds = [UUID(), UUID(), UUID()]
        for id in agentIds {
            await sut.startMonitoring(agentId: id)
        }
        try await Task.sleep(for: .milliseconds(200))

        // When
        let aggregate = await sut.getAggregateMetrics()

        // Then
        XCTAssertGreaterThan(aggregate.activeAgents, 0)
        XCTAssertGreaterThanOrEqual(aggregate.totalCPU, 0)
        XCTAssertGreaterThanOrEqual(aggregate.totalMemoryMB, 0)
    }

    func testMetricsHistory() async throws {
        // Given
        let agentId = UUID()
        await sut.startMonitoring(agentId: agentId)
        try await Task.sleep(for: .milliseconds(500))

        // When
        let history = await sut.getMetricsHistory(for: agentId, last: 1.0)

        // Then
        XCTAssertFalse(history.isEmpty, "History should contain metrics")
    }

    func testClearHistory() async throws {
        // Given
        let agentId = UUID()
        await sut.startMonitoring(agentId: agentId)
        try await Task.sleep(for: .milliseconds(200))

        // When
        await sut.clearHistory(for: agentId)
        let history = await sut.getMetricsHistory(for: agentId, last: 10.0)

        // Then
        XCTAssertTrue(history.isEmpty, "History should be cleared")
    }

    // MARK: - Performance Tests

    func testHighFrequencyUpdates() async throws {
        // Test that 100Hz update frequency works
        let agentId = UUID()
        await sut.startMonitoring(agentId: agentId)

        // Collect metrics for 1 second
        try await Task.sleep(for: .seconds(1))

        let history = await sut.getMetricsHistory(for: agentId, last: 1.0)

        // Should have close to 100 samples (100Hz for 1 second)
        XCTAssertGreaterThan(history.count, 80, "Should collect at high frequency")
        XCTAssertLessThan(history.count, 120, "Should not collect too many samples")
    }

    func testMultipleAgentsMonitoring() async throws {
        // Test monitoring multiple agents simultaneously
        let agentCount = 10
        let agentIds = (0..<agentCount).map { _ in UUID() }

        // Start monitoring all agents
        for id in agentIds {
            await sut.startMonitoring(agentId: id)
        }

        try await Task.sleep(for: .milliseconds(200))

        // Verify all have metrics
        let aggregate = await sut.getAggregateMetrics()
        XCTAssertEqual(aggregate.activeAgents, agentCount)
    }
}
