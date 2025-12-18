//
//  VisualizationService.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import RealityKit

actor VisualizationService {

    // MARK: - Public Methods

    func generateLandscape(from organization: Organization) async throws -> CulturalLandscape {
        // Generate 3D landscape from org data
        let landscape = CulturalLandscape(organizationId: organization.id)

        // Create regions for each value
        for (index, value) in organization.culturalValues.enumerated() {
            let region = createRegion(for: value, at: index)
            landscape.regions.append(region)
        }

        return landscape
    }

    func updateRegionHealth(regionId: UUID, score: Double) async {
        // Update visual representation based on health
        print("Updating region \(regionId) health to \(score)")
    }

    // MARK: - Private Helpers

    private func createRegion(for value: CulturalValue, at index: Int) -> CulturalRegion {
        // Position regions in a circle
        let angle = (Double(index) / Double(5)) * 2 * .pi
        let radius: Float = 5.0
        let x = Float(cos(angle)) * radius
        let z = Float(sin(angle)) * radius

        let regionType = determineRegionType(for: value.name)

        return CulturalRegion(
            valueId: value.id,
            name: "\(value.name) \(regionType.rawValue.capitalized)",
            regionType: regionType,
            healthScore: value.alignmentScore,
            position: SIMD3<Float>(x, 0, z)
        )
    }

    private func determineRegionType(for valueName: String) -> RegionType {
        switch valueName.lowercased() {
        case "innovation": return .forest
        case "collaboration": return .bridge
        case "trust": return .valley
        case "purpose": return .mountain
        case "transparency": return .river
        default: return .territory
        }
    }
}
