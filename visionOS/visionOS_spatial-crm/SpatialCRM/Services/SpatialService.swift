//
//  SpatialService.swift
//  SpatialCRM
//
//  Service for spatial layout calculations and 3D positioning
//

import Foundation
import RealityKit

@Observable
final class SpatialService {
    // MARK: - Properties

    var isProcessing: Bool = false

    // MARK: - Layout Calculations

    func calculateCustomerPositions(accounts: [Account]) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]

        // Arrange in galaxy formation
        // Tier 1 accounts (high revenue) closer to center
        // Tier 2 and 3 accounts in outer orbits

        let sorted = accounts.sorted { $0.revenue > $1.revenue }

        for (index, account) in sorted.enumerated() {
            let tier = getTier(for: account.revenue)
            let radius = Float(tier) * 2.0  // 2m, 4m, 6m from center

            // Distribute evenly around orbit
            let accountsInTier = sorted.filter { getTier(for: $0.revenue) == tier }.count
            let angle = Float(index) * (2 * .pi / Float(accountsInTier))

            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y = Float.random(in: -0.5...0.5)  // Slight vertical variation

            positions[account.id] = SIMD3(x, y, z)
        }

        return positions
    }

    func generatePipelineFlow(opportunities: [Opportunity]) -> FlowVisualization {
        var stagePositions: [DealStage: [SIMD3<Float>]] = [:]

        // Group by stage
        let byStage = Dictionary(grouping: opportunities) { $0.stage }

        for stage in DealStage.allCases {
            guard stage != .closedWon && stage != .closedLost else { continue }

            let oppsInStage = byStage[stage] ?? []
            var positions: [SIMD3<Float>] = []

            // Arrange horizontally within stage
            for (index, _) in oppsInStage.enumerated() {
                let x = Float(index - oppsInStage.count / 2) * 0.3
                let y = Float(stage.rawValue) * 0.5  // Vertical position by stage
                let z = 0.0

                positions.append(SIMD3(x, y, z))
            }

            stagePositions[stage] = positions
        }

        return FlowVisualization(stagePositions: stagePositions)
    }

    func createTerritoryMap(territory: Territory) -> TerrainMap {
        // Generate procedural terrain based on territory data
        let resolution = 50  // 50x50 grid
        var heightMap: [[Float]] = Array(repeating: Array(repeating: 0, count: resolution), count: resolution)

        // Generate height based on revenue distribution
        for x in 0..<resolution {
            for z in 0..<resolution {
                // Simple noise-based height generation
                let height = Float.random(in: 0...1) * Float(truncating: territory.quota as NSDecimalNumber) / 1_000_000
                heightMap[x][z] = height
            }
        }

        return TerrainMap(
            heightMap: heightMap,
            size: SIMD2(Float(resolution), Float(resolution)),
            scale: 0.1
        )
    }

    // MARK: - Force-Directed Layout

    func applyForceDirectedLayout(to contacts: [Contact], iterations: Int = 100) -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]
        var velocities: [UUID: SIMD3<Float>] = [:]

        // Initialize random positions
        for contact in contacts {
            let randomPos = SIMD3<Float>(
                Float.random(in: -2...2),
                Float.random(in: -2...2),
                Float.random(in: -2...2)
            )
            positions[contact.id] = randomPos
            velocities[contact.id] = SIMD3<Float>(0, 0, 0)
        }

        // Run simulation
        for _ in 0..<iterations {
            var forces: [UUID: SIMD3<Float>] = [:]

            // Initialize forces
            for contact in contacts {
                forces[contact.id] = SIMD3<Float>(0, 0, 0)
            }

            // Repulsion between all nodes
            for i in 0..<contacts.count {
                for j in (i+1)..<contacts.count {
                    let contact1 = contacts[i]
                    let contact2 = contacts[j]

                    guard let pos1 = positions[contact1.id],
                          let pos2 = positions[contact2.id] else { continue }

                    let delta = pos1 - pos2
                    let distance = max(length(delta), 0.1)
                    let repulsionForce = delta / (distance * distance) * 0.5

                    forces[contact1.id]? += repulsionForce
                    forces[contact2.id]? -= repulsionForce
                }
            }

            // Attraction along edges (relationships)
            for contact in contacts {
                for relationship in contact.relationships {
                    guard let toContact = relationship.toContact,
                          let pos1 = positions[contact.id],
                          let pos2 = positions[toContact.id] else { continue }

                    let delta = pos2 - pos1
                    let distance = length(delta)
                    let attractionForce = delta * 0.1 * Float(relationship.strength / 100)

                    forces[contact.id]? += attractionForce
                    forces[toContact.id]? -= attractionForce
                }
            }

            // Update positions
            let damping: Float = 0.9
            for contact in contacts {
                if let force = forces[contact.id],
                   var velocity = velocities[contact.id],
                   var position = positions[contact.id] {

                    velocity += force * 0.016  // 60 FPS
                    velocity *= damping
                    position += velocity * 0.016

                    velocities[contact.id] = velocity
                    positions[contact.id] = position
                }
            }
        }

        return positions
    }

    // MARK: - Helper Methods

    private func getTier(for revenue: Decimal) -> Int {
        if revenue > 5_000_000 {
            return 1
        } else if revenue > 1_000_000 {
            return 2
        } else {
            return 3
        }
    }
}

// MARK: - Supporting Types

struct FlowVisualization {
    let stagePositions: [DealStage: [SIMD3<Float>]]
}

struct TerrainMap {
    let heightMap: [[Float]]
    let size: SIMD2<Float>
    let scale: Float
}
