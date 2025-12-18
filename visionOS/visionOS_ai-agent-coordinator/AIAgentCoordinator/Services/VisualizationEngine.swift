//
//  VisualizationEngine.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import RealityKit
import simd

/// Engine for generating 3D visualizations of AI agent networks
/// Handles layout algorithms, LOD systems, and visual representations
@Observable
final class VisualizationEngine {

    // MARK: - Properties

    /// Current layout algorithm
    var layoutAlgorithm: LayoutAlgorithm = .galaxy

    /// Level of detail settings
    var lodSettings = LODSettings()

    /// Maximum agents to render
    var maxAgents = AppConstants.maxAgentsVisualized

    /// Current scene bounds
    var sceneBounds: SIMD3<Float> = VisualizationConstants.defaultSceneBounds

    // MARK: - Layout Algorithms

    /// Available layout algorithms
    enum LayoutAlgorithm {
        case galaxy        // Spiral galaxy formation
        case grid          // Regular 3D grid
        case cluster       // Hierarchical clustering
        case force         // Force-directed graph
        case landscape     // Performance landscape (height = performance)
        case river         // Decision flow river
    }

    // MARK: - Position Calculation

    /// Calculate positions for agents based on current layout
    func calculatePositions(for agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        switch layoutAlgorithm {
        case .galaxy:
            return galaxyLayout(agents: agents)
        case .grid:
            return gridLayout(agents: agents)
        case .cluster:
            return clusterLayout(agents: agents)
        case .force:
            return forceDirectedLayout(agents: agents)
        case .landscape:
            return landscapeLayout(agents: agents)
        case .river:
            return riverLayout(agents: agents)
        }
    }

    // MARK: - Galaxy Layout

    /// Galaxy/spiral layout - agents arranged in spiral arms
    private func galaxyLayout(agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        let armCount = VisualizationConstants.galaxySpiralArmCount
        let agentsPerArm = max(1, agents.count / armCount)

        for (index, agent) in agents.enumerated() {
            let armIndex = index / agentsPerArm
            let positionInArm = index % agentsPerArm

            // Spiral parameters
            let angle = Float(armIndex) * (2 * .pi / Float(armCount)) +
                        Float(positionInArm) * VisualizationConstants.galaxyAngleIncrement
            let radius = Float(positionInArm) * VisualizationConstants.galaxyRadiusIncrement + VisualizationConstants.galaxyBaseRadius

            // Calculate position
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y = Float.random(in: VisualizationConstants.galaxyVerticalVariation)

            positions[agent.id] = SIMD3(x, y, z)
        }

        return positions
    }

    // MARK: - Grid Layout

    /// Regular 3D grid layout
    private func gridLayout(agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        let gridSize = ceil(pow(Double(agents.count), 1.0/3.0)) // Cube root
        let spacing = VisualizationConstants.gridSpacing

        for (index, agent) in agents.enumerated() {
            let x = Float(index % Int(gridSize)) * spacing
            let y = Float((index / Int(gridSize)) % Int(gridSize)) * spacing
            let z = Float(index / (Int(gridSize) * Int(gridSize))) * spacing

            positions[agent.id] = SIMD3(x, y, z) - SIMD3(
                Float(gridSize) * spacing / 2,
                Float(gridSize) * spacing / 2,
                Float(gridSize) * spacing / 2
            )
        }

        return positions
    }

    // MARK: - Cluster Layout

    /// Hierarchical cluster layout - group by type/platform
    private func clusterLayout(agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        // Group by platform
        let grouped = Dictionary(grouping: agents, by: \.platform)

        let clusterRadius = VisualizationConstants.clusterRadius
        let clusterCount = max(1, Float(grouped.count))

        for (platformIndex, (_, platformAgents)) in grouped.enumerated() {
            // Cluster center position
            let angle = Float(platformIndex) * (2 * .pi / clusterCount)
            let clusterCenter = SIMD3(
                clusterRadius * cos(angle),
                0,
                clusterRadius * sin(angle)
            )

            // Position agents within cluster
            for (agentIndex, agent) in platformAgents.enumerated() {
                let localAngle = Float(agentIndex) * (2 * .pi / max(1, Float(platformAgents.count)))
                let localRadius = Float.random(in: VisualizationConstants.clusterInnerRadiusRange)

                let localPos = SIMD3(
                    localRadius * cos(localAngle),
                    Float.random(in: VisualizationConstants.galaxyVerticalVariation),
                    localRadius * sin(localAngle)
                )

                positions[agent.id] = clusterCenter + localPos
            }
        }

        return positions
    }

    // MARK: - Force-Directed Layout

    /// Force-directed graph layout (simplified)
    private func forceDirectedLayout(agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        // Initialize with random positions
        var positions: [UUID: SIMD3<Float>] = [:]
        for agent in agents {
            positions[agent.id] = SIMD3(
                Float.random(in: -5...5),
                Float.random(in: -5...5),
                Float.random(in: -5...5)
            )
        }

        // Simple force-directed simulation (would be more complex in production)
        // This is a placeholder - real implementation would run iteratively
        return positions
    }

    // MARK: - Landscape Layout

    /// Performance landscape - height represents performance
    private func landscapeLayout(agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        let gridSize = ceil(sqrt(Double(agents.count)))
        let spacing = VisualizationConstants.gridSpacing

        for (index, agent) in agents.enumerated() {
            let x = Float(index % Int(gridSize)) * spacing
            let z = Float(index / Int(gridSize)) * spacing

            // Height based on health score
            let metrics = agent.currentMetrics
            let y = Float(metrics?.healthScore ?? 0.5) * VisualizationConstants.landscapeMaxHeight

            positions[agent.id] = SIMD3(x, y, z) - SIMD3(
                Float(gridSize) * spacing / 2,
                0,
                Float(gridSize) * spacing / 2
            )
        }

        return positions
    }

    // MARK: - River Layout

    /// Decision flow river - agents flow like a river
    private func riverLayout(agents: [AIAgent]) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        let agentCount = max(1, Float(agents.count))

        for (index, agent) in agents.enumerated() {
            let progress = Float(index) / agentCount

            // River path (sinusoidal)
            let x = sin(progress * VisualizationConstants.riverFrequency) * VisualizationConstants.riverAmplitude
            let z = progress * VisualizationConstants.riverLength - (VisualizationConstants.riverLength / 2)
            let y = Float.random(in: -0.2...0.2)

            positions[agent.id] = SIMD3(x, y, z)
        }

        return positions
    }

    // MARK: - LOD System

    /// Calculate level of detail for an agent based on distance
    func calculateLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<VisualizationConstants.lodHighDistance:
            return .high
        case VisualizationConstants.lodHighDistance..<VisualizationConstants.lodMediumDistance:
            return .medium
        case VisualizationConstants.lodMediumDistance..<VisualizationConstants.lodLowDistance:
            return .low
        default:
            return .minimal
        }
    }

    /// Get visual representation parameters for LOD level
    func visualParameters(for lod: LODLevel) -> VisualParameters {
        switch lod {
        case .high:
            return VisualParameters(
                sphereSegments: VisualizationConstants.sphereSegmentsHigh,
                showLabels: true,
                showMetrics: true,
                showConnections: true,
                particleCount: VisualizationConstants.particleCountHigh
            )
        case .medium:
            return VisualParameters(
                sphereSegments: VisualizationConstants.sphereSegmentsMedium,
                showLabels: true,
                showMetrics: false,
                showConnections: true,
                particleCount: VisualizationConstants.particleCountMedium
            )
        case .low:
            return VisualParameters(
                sphereSegments: VisualizationConstants.sphereSegmentsLow,
                showLabels: false,
                showMetrics: false,
                showConnections: false,
                particleCount: 0
            )
        case .minimal:
            return VisualParameters(
                sphereSegments: VisualizationConstants.sphereSegmentsMinimal,
                showLabels: false,
                showMetrics: false,
                showConnections: false,
                particleCount: 0
            )
        }
    }

    // MARK: - Color Mapping

    /// Get color for agent based on status
    func colorForStatus(_ status: AgentStatus) -> SIMD3<Float> {
        switch status {
        case .active:
            return SIMD3(0.0, 1.0, 0.0)  // Green
        case .idle:
            return SIMD3(0.5, 0.5, 0.5)  // Gray
        case .error:
            return SIMD3(1.0, 0.0, 0.0)  // Red
        case .learning:
            return SIMD3(1.0, 0.8, 0.0)  // Yellow/Gold
        case .optimizing:
            return SIMD3(0.0, 0.5, 1.0)  // Blue
        case .paused:
            return SIMD3(1.0, 0.5, 0.0)  // Orange
        case .terminated:
            return SIMD3(0.3, 0.3, 0.3)  // Dark gray
        }
    }

    /// Get color for platform
    func colorForPlatform(_ platform: AIPlatform) -> SIMD3<Float> {
        switch platform {
        case .openai:
            return SIMD3(0.0, 0.8, 0.6)  // Teal
        case .anthropic:
            return SIMD3(0.8, 0.4, 0.2)  // Orange
        case .aws, .awsSageMaker:
            return SIMD3(1.0, 0.6, 0.0)  // Amazon Orange
        case .azure, .azureAI:
            return SIMD3(0.0, 0.5, 1.0)  // Azure Blue
        case .googleVertexAI:
            return SIMD3(0.3, 0.7, 0.3)  // Google Green
        case .huggingFace:
            return SIMD3(1.0, 0.8, 0.0)  // Yellow
        case .custom:
            return SIMD3(0.6, 0.4, 0.8)  // Purple
        }
    }
}

// MARK: - Supporting Types

/// Level of detail levels
enum LODLevel {
    case high      // < 2m
    case medium    // 2-10m
    case low       // 10-50m
    case minimal   // > 50m
}

/// LOD settings
struct LODSettings {
    var enableLOD = true
    var highDetailDistance: Float = VisualizationConstants.lodHighDistance
    var mediumDetailDistance: Float = VisualizationConstants.lodMediumDistance
    var lowDetailDistance: Float = VisualizationConstants.lodLowDistance
}

/// Visual representation parameters
struct VisualParameters {
    let sphereSegments: Int
    let showLabels: Bool
    let showMetrics: Bool
    let showConnections: Bool
    let particleCount: Int
}
