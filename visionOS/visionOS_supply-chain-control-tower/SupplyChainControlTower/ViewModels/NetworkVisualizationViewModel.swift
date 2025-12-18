//
//  NetworkVisualizationViewModel.swift
//  SupplyChainControlTower
//
//  ViewModel for 3D network visualization
//

import Foundation
import Observation
import RealityKit

@Observable
@MainActor
class NetworkVisualizationViewModel {

    // MARK: - Published State

    var selectedNode: Node?
    var highlightedRoute: Edge?
    var visibleNodes: [Node] = []
    var lodLevel: LODLevel = .high
    var cameraPosition: SIMD3<Float> = [0, 0, 2]

    // MARK: - Settings

    var showLabels: Bool = true
    var showRoutes: Bool = true
    var showFlows: Bool = true
    var nodeScale: Float = 1.0

    // MARK: - Performance

    private var lastUpdateTime: Date = Date()
    private let updateThreshold: TimeInterval = 0.016 // ~60 FPS

    // MARK: - Actions

    /// Select a node
    func selectNode(_ node: Node) {
        selectedNode = node
    }

    /// Deselect current node
    func deselectNode() {
        selectedNode = nil
    }

    /// Highlight a route
    func highlightRoute(_ edge: Edge) {
        highlightedRoute = edge
    }

    /// Update visible nodes based on camera position
    func updateVisibleNodes(from network: SupplyChainNetwork, cameraPosition: SIMD3<Float>) {
        self.cameraPosition = cameraPosition

        // Frustum culling - only show nodes within view
        visibleNodes = network.nodes.filter { node in
            // Calculate distance from camera
            let nodePos = node.location.toCartesian(radius: 2.5)
            let distance = simd_distance(nodePos, cameraPosition)

            // Only show if within range
            return distance < 10.0
        }

        // Update LOD based on distance
        updateLODLevel()
    }

    /// Update Level of Detail based on camera distance
    private func updateLODLevel() {
        let avgDistance = visibleNodes.reduce(0.0) { sum, node in
            let nodePos = node.location.toCartesian(radius: 2.5)
            return sum + Double(simd_distance(nodePos, cameraPosition))
        } / Double(max(visibleNodes.count, 1))

        if avgDistance < 2.0 {
            lodLevel = .high
        } else if avgDistance < 5.0 {
            lodLevel = .medium
        } else if avgDistance < 10.0 {
            lodLevel = .low
        } else {
            lodLevel = .minimal
        }
    }

    /// Check if update is needed (throttle updates)
    func shouldUpdate() -> Bool {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdateTime)

        if elapsed >= updateThreshold {
            lastUpdateTime = now
            return true
        }

        return false
    }

    /// Get node color based on status and selection
    func nodeColor(for node: Node) -> UIColor {
        if selectedNode?.id == node.id {
            return .systemBlue
        }

        switch node.status {
        case .healthy: return .systemGreen
        case .warning: return .systemYellow
        case .critical: return .systemRed
        case .offline: return .systemGray
        }
    }

    /// Get node size based on capacity and LOD
    func nodeSize(for node: Node) -> Float {
        let baseSize: Float = 0.02
        let capacityMultiplier = Float(node.capacity.utilization) * 0.05

        let size = baseSize + capacityMultiplier

        // Scale based on LOD
        switch lodLevel {
        case .high: return size * nodeScale
        case .medium: return size * nodeScale * 0.8
        case .low: return size * nodeScale * 0.6
        case .minimal: return size * nodeScale * 0.4
        }
    }
}

// MARK: - LOD Level

enum LODLevel {
    case high
    case medium
    case low
    case minimal

    var maxEntities: Int {
        switch self {
        case .high: return 10000
        case .medium: return 5000
        case .low: return 2000
        case .minimal: return 500
        }
    }

    var showLabels: Bool {
        switch self {
        case .high: return true
        case .medium: return true
        case .low: return false
        case .minimal: return false
        }
    }
}
