//
//  VisualizationEngineTests.swift
//  AIAgentCoordinatorTests
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import XCTest
import simd
@testable import AIAgentCoordinator

/// Unit tests for VisualizationEngine
final class VisualizationEngineTests: XCTestCase {

    var sut: VisualizationEngine!
    var testAgents: [AIAgent]!

    override func setUp() {
        super.setUp()
        sut = VisualizationEngine()
        testAgents = createTestAgents(count: 10)
    }

    override func tearDown() {
        sut = nil
        testAgents = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createTestAgents(count: Int) -> [AIAgent] {
        (0..<count).map { i in
            AIAgent(
                name: "agent-\(i)",
                type: .general,
                platform: .openai,
                status: .active,
                agentDescription: "Test agent \(i)",
                endpoint: nil,
                tags: []
            )
        }
    }

    // MARK: - Layout Algorithm Tests

    func testGalaxyLayout() {
        // When
        sut.layoutAlgorithm = .galaxy
        let positions = sut.calculatePositions(for: testAgents)

        // Then
        XCTAssertEqual(positions.count, testAgents.count)
        for (agentId, position) in positions {
            XCTAssertTrue(testAgents.contains { $0.id == agentId })
            // Check position is within reasonable bounds
            XCTAssertGreaterThanOrEqual(position.x, -10)
            XCTAssertLessThanOrEqual(position.x, 10)
        }
    }

    func testGridLayout() {
        // When
        sut.layoutAlgorithm = .grid
        let positions = sut.calculatePositions(for: testAgents)

        // Then
        XCTAssertEqual(positions.count, testAgents.count)
        // Grid should have organized spacing
        let positionArray = Array(positions.values)
        for position in positionArray {
            XCTAssertNotEqual(position, SIMD3(0, 0, 0), "All positions should be set")
        }
    }

    func testClusterLayout() {
        // Given - agents with different platforms
        let diverseAgents = [
            AIAgent(name: "a1", type: .general, platform: .openai, status: .active, agentDescription: "", endpoint: nil, tags: []),
            AIAgent(name: "a2", type: .general, platform: .openai, status: .active, agentDescription: "", endpoint: nil, tags: []),
            AIAgent(name: "a3", type: .general, platform: .anthropic, status: .active, agentDescription: "", endpoint: nil, tags: []),
            AIAgent(name: "a4", type: .general, platform: .aws, status: .active, agentDescription: "", endpoint: nil, tags: [])
        ]

        // When
        sut.layoutAlgorithm = .cluster
        let positions = sut.calculatePositions(for: diverseAgents)

        // Then
        XCTAssertEqual(positions.count, diverseAgents.count)
    }

    func testLandscapeLayout() {
        // When
        sut.layoutAlgorithm = .landscape
        let positions = sut.calculatePositions(for: testAgents)

        // Then
        XCTAssertEqual(positions.count, testAgents.count)
        // Landscape should use Y axis for height (performance)
        for position in positions.values {
            XCTAssertGreaterThanOrEqual(position.y, 0, "Y should represent height")
        }
    }

    func testRiverLayout() {
        // When
        sut.layoutAlgorithm = .river
        let positions = sut.calculatePositions(for: testAgents)

        // Then
        XCTAssertEqual(positions.count, testAgents.count)
    }

    // MARK: - LOD Tests

    func testLODCalculation() {
        // Test different distances
        let tests: [(Float, LODLevel)] = [
            (0.5, .high),
            (1.5, .high),
            (5.0, .medium),
            (25.0, .low),
            (100.0, .minimal)
        ]

        for (distance, expectedLOD) in tests {
            let lod = sut.calculateLOD(distance: distance)
            XCTAssertEqual(lod, expectedLOD, "Distance \(distance) should be \(expectedLOD)")
        }
    }

    func testVisualParameters() {
        // Test that each LOD level has appropriate parameters
        let lodLevels: [LODLevel] = [.high, .medium, .low, .minimal]

        for lod in lodLevels {
            let params = sut.visualParameters(for: lod)

            switch lod {
            case .high:
                XCTAssertTrue(params.showLabels)
                XCTAssertTrue(params.showMetrics)
                XCTAssertGreaterThan(params.sphereSegments, 16)
            case .medium:
                XCTAssertTrue(params.showLabels)
                XCTAssertFalse(params.showMetrics)
            case .low:
                XCTAssertFalse(params.showLabels)
                XCTAssertFalse(params.showMetrics)
            case .minimal:
                XCTAssertFalse(params.showLabels)
                XCTAssertEqual(params.particleCount, 0)
            }
        }
    }

    // MARK: - Color Mapping Tests

    func testColorForStatus() {
        let tests: [(AgentStatus, SIMD3<Float>)] = [
            (.active, SIMD3(0.0, 1.0, 0.0)),  // Green
            (.idle, SIMD3(0.5, 0.5, 0.5)),    // Gray
            (.error, SIMD3(1.0, 0.0, 0.0)),   // Red
            (.learning, SIMD3(1.0, 0.8, 0.0)) // Yellow
        ]

        for (status, expectedColor) in tests {
            let color = sut.colorForStatus(status)
            XCTAssertEqual(color, expectedColor)
        }
    }

    func testColorForPlatform() {
        let platforms: [AIPlatform] = [.openai, .anthropic, .aws, .azure, .googleCloud, .custom]

        for platform in platforms {
            let color = sut.colorForPlatform(platform)
            // Check that color values are valid (0-1 range)
            XCTAssertGreaterThanOrEqual(color.x, 0)
            XCTAssertLessThanOrEqual(color.x, 1)
            XCTAssertGreaterThanOrEqual(color.y, 0)
            XCTAssertLessThanOrEqual(color.y, 1)
            XCTAssertGreaterThanOrEqual(color.z, 0)
            XCTAssertLessThanOrEqual(color.z, 1)
        }
    }

    // MARK: - Performance Tests

    func testLargeAgentSetPerformance() {
        // Create a large set of agents
        let largeAgentSet = createTestAgents(count: 1000)

        measure {
            _ = sut.calculatePositions(for: largeAgentSet)
        }
    }

    func testLayoutSwitchingPerformance() {
        let algorithms: [VisualizationEngine.LayoutAlgorithm] = [
            .galaxy, .grid, .cluster, .force, .landscape, .river
        ]

        measure {
            for algorithm in algorithms {
                sut.layoutAlgorithm = algorithm
                _ = sut.calculatePositions(for: testAgents)
            }
        }
    }
}
