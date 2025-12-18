//
//  HemisphereLayout.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.5: Basic 3D Code Window
//

import RealityKit
import simd

/// Spatial layout algorithm for positioning code windows in a hemisphere around the user
class HemisphereLayout {
    // MARK: - Configuration

    let radius: Float
    let centerHeight: Float
    let centerDistance: Float
    let scale: SIMD3<Float>

    init(
        radius: Float = 1.5,
        centerHeight: Float = 1.5,
        centerDistance: Float = 2.0,
        scale: SIMD3<Float> = [1, 1, 1]
    ) {
        self.radius = radius
        self.centerHeight = centerHeight
        self.centerDistance = centerDistance
        self.scale = scale
    }

    // MARK: - Position Calculation

    /// Calculates positions for entities in hemisphere layout using golden ratio distribution
    func calculatePositions(for count: Int) -> [Transform] {
        guard count > 0 else { return [] }

        var transforms: [Transform] = []

        // Golden ratio for optimal sphere packing
        let goldenRatio: Float = (1.0 + sqrt(5.0)) / 2.0
        let goldenAngle = 2.0 * .pi * (1.0 - 1.0 / goldenRatio)

        for i in 0..<count {
            let t = Float(i) / Float(max(count - 1, 1))

            // Spherical coordinates using golden ratio
            // This creates an even distribution without clustering
            let inclination = acos(1.0 - t)  // 0 to π/2 (hemisphere only)
            let azimuth = goldenAngle * Float(i)

            // Convert spherical to Cartesian coordinates
            let x = radius * sin(inclination) * cos(azimuth)
            let y = radius * cos(inclination)  // y >= 0 for hemisphere
            let z = -radius * sin(inclination) * sin(azimuth) - centerDistance

            // Adjust y to be around eye level
            let position = SIMD3<Float>(x, y + centerHeight, z)

            // Calculate rotation to face toward user
            let lookAt = SIMD3<Float>(0, centerHeight, 0)  // User's eye position
            let direction = normalize(lookAt - position)
            let rotation = rotationToFace(direction: direction)

            transforms.append(Transform(
                scale: scale,
                rotation: rotation,
                translation: position
            ))
        }

        return transforms
    }

    /// Calculates positions for a list of FileNodes, handling both files and directories
    func calculatePositions(for nodes: [FileNode]) -> [(node: FileNode, transform: Transform)] {
        let transforms = calculatePositions(for: nodes.count)

        return zip(nodes, transforms).map { node, transform in
            (node: node, transform: transform)
        }
    }

    // MARK: - Helper Functions

    /// Calculates rotation quaternion to face a given direction
    private func rotationToFace(direction: SIMD3<Float>) -> simd_quatf {
        let up = SIMD3<Float>(0, 1, 0)

        // Calculate right vector
        let right = normalize(cross(up, direction))

        // Recalculate up to ensure orthogonality
        let correctedUp = cross(direction, right)

        // Create rotation matrix from right, up, and forward (-direction) vectors
        let rotationMatrix = simd_float3x3(right, correctedUp, -direction)

        return simd_quatf(rotationMatrix)
    }

    /// Calculates a single position for a specific index
    func calculatePosition(at index: Int, totalCount: Int) -> Transform {
        let transforms = calculatePositions(for: totalCount)
        return transforms[index]
    }
}

// MARK: - Alternative Layout Algorithms

/// Focus mode layout: one file large and centered, others minimized
class FocusLayout {
    let focusPosition = SIMD3<Float>(0, 1.5, -1.5)
    let focusScale = SIMD3<Float>(1.2, 1.2, 1.0)
    let contextScale = SIMD3<Float>(0.3, 0.3, 1.0)
    let contextRadius: Float = 1.0

    func calculatePositions(for nodes: [FileNode], focusedIndex: Int) -> [(node: FileNode, transform: Transform)] {
        var result: [(node: FileNode, transform: Transform)] = []

        for (index, node) in nodes.enumerated() {
            if index == focusedIndex {
                // Main focused window - center and large
                let transform = Transform(
                    scale: focusScale,
                    translation: focusPosition
                )
                result.append((node: node, transform: transform))
            } else {
                // Context windows - small and arranged in arc below
                let contextIndex = index < focusedIndex ? index : index - 1
                let angle = Float(contextIndex) * 0.3 - Float(nodes.count - 1) * 0.15

                let x = contextRadius * sin(angle)
                let y: Float = 0.8
                let z = -1.8 - contextRadius * cos(angle)

                let transform = Transform(
                    scale: contextScale,
                    translation: SIMD3<Float>(x, y, z)
                )
                result.append((node: node, transform: transform))
            }
        }

        return result
    }
}

/// Comparison mode layout: two files side-by-side
class ComparisonLayout {
    let separation: Float = 0.8
    let position = SIMD3<Float>(0, 1.5, -1.5)
    let scale = SIMD3<Float>(0.9, 1.0, 1.0)

    func calculatePositions(for nodes: [FileNode]) -> [(node: FileNode, transform: Transform)] {
        guard nodes.count == 2 else { return [] }

        let leftPosition = position + SIMD3<Float>(-separation / 2, 0, 0)
        let rightPosition = position + SIMD3<Float>(separation / 2, 0, 0)

        return [
            (node: nodes[0], transform: Transform(scale: scale, translation: leftPosition)),
            (node: nodes[1], transform: Transform(scale: scale, translation: rightPosition))
        ]
    }
}

/// Grid layout: simple grid arrangement
class GridLayout {
    let spacing: Float = 0.8
    let centerHeight: Float = 1.5
    let centerDistance: Float = 2.0
    let columns: Int

    init(columns: Int = 3) {
        self.columns = columns
    }

    func calculatePositions(for count: Int) -> [Transform] {
        var transforms: [Transform] = []
        let rows = (count + columns - 1) / columns

        for i in 0..<count {
            let row = i / columns
            let col = i % columns

            // Center the grid
            let x = Float(col) * spacing - Float(columns - 1) * spacing / 2
            let y = centerHeight + Float(rows - 1 - row) * spacing - Float(rows - 1) * spacing / 2
            let z = -centerDistance

            let position = SIMD3<Float>(x, y, z)

            transforms.append(Transform(translation: position))
        }

        return transforms
    }
}

// MARK: - Layout Animation Helper

/// Animates transitions between layouts
class LayoutAnimator {
    /// Animates entities from current positions to new layout
    static func animateLayoutTransition(
        entities: [Entity],
        to transforms: [Transform],
        duration: TimeInterval = 0.5
    ) {
        for (entity, transform) in zip(entities, transforms) {
            // Create animation from current transform to target
            let animation = FromToByAnimation(
                from: entity.transform,
                to: transform,
                duration: duration,
                timing: .easeInOut,
                bindTarget: .transform
            )

            entity.playAnimation(animation.repeat())
        }
    }
}
