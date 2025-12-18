//
//  SpatialLayoutEngine.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import RealityKit

/// Handles spatial positioning of scene cards in 3D timeline
struct SpatialLayoutEngine {
    // MARK: - Layout Configuration

    /// Spacing between cards (in meters)
    static let cardSpacingX: Float = 0.4    // 40cm horizontal
    static let cardSpacingY: Float = 0.5    // 50cm vertical
    static let cardSpacingZ: Float = 0.3    // 30cm depth (between acts)

    /// Act positions (Z-depth for each act)
    static let actDepths: [Int: Float] = [
        1: 0.0,      // Act I at front
        2: -0.5,     // Act II slightly behind
        3: -1.0      // Act III furthest back
    ]

    // MARK: - Position Calculation

    /// Calculate 3D positions for all scene cards organized by acts
    func calculatePositions(for scenes: [Scene], in containerSize: CGSize) -> [Scene: SIMD3<Float>] {
        var positions: [Scene: SIMD3<Float>] = [:]

        // Group scenes by act
        let scenesByAct = Dictionary(grouping: scenes) { $0.position.act }

        // Calculate positions for each act
        for (act, actScenes) in scenesByAct.sorted(by: { $0.key < $1.key }) {
            let actPositions = calculateActLayout(
                scenes: actScenes,
                act: act,
                containerSize: containerSize
            )

            positions.merge(actPositions) { _, new in new }
        }

        return positions
    }

    // MARK: - Act Layout

    private func calculateActLayout(
        scenes: [Scene],
        act: Int,
        containerSize: CGSize
    ) -> [Scene: SIMD3<Float>] {
        var positions: [Scene: SIMD3<Float>] = [:]

        let cardWidth = SceneCardEntity.cardWidth
        let cardHeight = SceneCardEntity.cardHeight

        // Determine grid layout
        let maxCardsPerRow = Int(Float(containerSize.width) / (cardWidth + Self.cardSpacingX))
        let rows = (scenes.count + maxCardsPerRow - 1) / maxCardsPerRow

        // Calculate starting position (top-left of grid)
        let totalWidth = Float(min(scenes.count, maxCardsPerRow)) * (cardWidth + Self.cardSpacingX) - Self.cardSpacingX
        let totalHeight = Float(rows) * (cardHeight + Self.cardSpacingY) - Self.cardSpacingY

        let startX = -totalWidth / 2.0
        let startY = totalHeight / 2.0
        let depth = Self.actDepths[act] ?? 0.0

        // Position each scene in the grid
        for (index, scene) in scenes.enumerated() {
            let row = index / maxCardsPerRow
            let col = index % maxCardsPerRow

            let x = startX + Float(col) * (cardWidth + Self.cardSpacingX) + cardWidth / 2.0
            let y = startY - Float(row) * (cardHeight + Self.cardSpacingY) - cardHeight / 2.0
            let z = depth

            positions[scene] = SIMD3<Float>(x, y, z)
        }

        return positions
    }

    // MARK: - Dynamic Layout

    /// Calculate position for a single card in an existing layout
    func calculateInsertPosition(
        at index: Int,
        in scenes: [Scene],
        containerSize: CGSize
    ) -> SIMD3<Float> {
        guard index < scenes.count else {
            // Append to end
            return calculateAppendPosition(after: scenes, containerSize: containerSize)
        }

        let scene = scenes[index]
        let positions = calculatePositions(for: scenes, in: containerSize)

        return positions[scene] ?? .zero
    }

    private func calculateAppendPosition(
        after scenes: [Scene],
        containerSize: CGSize
    ) -> SIMD3<Float> {
        guard let lastScene = scenes.last else {
            return SIMD3<Float>(0, 0, 0)
        }

        let positions = calculatePositions(for: scenes, in: containerSize)
        guard var lastPosition = positions[lastScene] else {
            return SIMD3<Float>(0, 0, 0)
        }

        // Position to the right of last card
        lastPosition.x += SceneCardEntity.cardWidth + Self.cardSpacingX

        return lastPosition
    }

    // MARK: - Act Transitions

    /// Get visual divider positions between acts
    func getActDividerPositions(
        for scenes: [Scene],
        containerSize: CGSize
    ) -> [ActDivider] {
        var dividers: [ActDivider] = []

        let actNumbers = Set(scenes.map { $0.position.act }).sorted()

        for (index, act) in actNumbers.enumerated() {
            guard index < actNumbers.count - 1 else { continue }

            let nextAct = actNumbers[index + 1]

            // Position divider between acts
            let currentDepth = Self.actDepths[act] ?? 0.0
            let nextDepth = Self.actDepths[nextAct] ?? 0.0
            let dividerDepth = (currentDepth + nextDepth) / 2.0

            dividers.append(ActDivider(
                fromAct: act,
                toAct: nextAct,
                position: SIMD3<Float>(0, 0, dividerDepth)
            ))
        }

        return dividers
    }
}

// MARK: - Supporting Types

/// Visual divider between acts in timeline
struct ActDivider {
    let fromAct: Int
    let toAct: Int
    let position: SIMD3<Float>

    var label: String {
        "Act \(fromAct) → Act \(toAct)"
    }
}

// MARK: - Layout Validation

extension SpatialLayoutEngine {
    /// Validate that all cards are positioned within container bounds
    func validate(
        positions: [Scene: SIMD3<Float>],
        containerSize: CGSize
    ) -> Bool {
        let maxX = Float(containerSize.width) / 2.0
        let maxY = Float(containerSize.height) / 2.0

        for position in positions.values {
            if abs(position.x) > maxX || abs(position.y) > maxY {
                return false
            }
        }

        return true
    }

    /// Get bounding box of all positioned cards
    func calculateBoundingBox(
        positions: [Scene: SIMD3<Float>]
    ) -> (min: SIMD3<Float>, max: SIMD3<Float>) {
        guard !positions.isEmpty else {
            return (.zero, .zero)
        }

        let values = Array(positions.values)
        let minX = values.map { $0.x }.min() ?? 0
        let minY = values.map { $0.y }.min() ?? 0
        let minZ = values.map { $0.z }.min() ?? 0
        let maxX = values.map { $0.x }.max() ?? 0
        let maxY = values.map { $0.y }.max() ?? 0
        let maxZ = values.map { $0.z }.max() ?? 0

        return (
            SIMD3<Float>(minX, minY, minZ),
            SIMD3<Float>(maxX, maxY, maxZ)
        )
    }
}
