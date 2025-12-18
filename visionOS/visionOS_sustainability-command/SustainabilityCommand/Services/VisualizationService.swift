import Foundation
import RealityKit
import Observation

// MARK: - Visualization Service

@Observable
final class VisualizationService {
    // MARK: - Earth Visualization

    func createEarthVisualization() -> EarthVisualizationData {
        // Create base Earth entity
        let earthEntity = createEarthSphere()

        return EarthVisualizationData(
            earthModel: earthEntity,
            atmosphereLayer: createAtmosphere(),
            facilityMarkers: [],
            supplyChainPaths: [],
            impactZones: []
        )
    }

    private func createEarthSphere() -> ModelEntity {
        // Create a sphere mesh for Earth
        let mesh = MeshResource.generateSphere(radius: 1.5)  // 3m diameter

        // Material would use Earth texture
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .blue)  // Placeholder
        material.roughness = 0.9
        material.metallic = 0.0

        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }

    private func createAtmosphere() -> Entity {
        let entity = Entity()
        // Would add atmospheric effects
        return entity
    }

    // MARK: - Facility Markers

    func createFacilityMarker(for facility: Facility) -> FacilityMarker3D {
        let position = calculateEarthPosition(
            latitude: facility.location.latitude,
            longitude: facility.location.longitude,
            radius: 1.5
        )

        let entity = ModelEntity(
            mesh: .generateBox(size: 0.05),
            materials: [SimpleMaterial(color: .red, isMetallic: false)]
        )
        entity.position = position

        return FacilityMarker3D(
            position: position,
            emissions: facility.emissions,
            entity: entity
        )
    }

    private func calculateEarthPosition(
        latitude: Double,
        longitude: Double,
        radius: Float
    ) -> SIMD3<Float> {
        let lat = Float(latitude) * .pi / 180.0
        let lon = Float(longitude) * .pi / 180.0

        let x = radius * cos(lat) * cos(lon)
        let y = radius * sin(lat)
        let z = radius * cos(lat) * sin(lon)

        return SIMD3<Float>(x, y, z)
    }

    // MARK: - Level of Detail

    func optimizeLOD(distance: Float) {
        // Adjust detail level based on distance
    }

    func cullNonVisibleEntities() {
        // Remove entities outside view frustum
    }
}

// MARK: - Supporting Types

struct EarthVisualizationData {
    let earthModel: ModelEntity
    let atmosphereLayer: Entity
    var facilityMarkers: [FacilityMarker3D]
    var supplyChainPaths: [Path3D]
    var impactZones: [ImpactZone3D]
}

struct FacilityMarker3D {
    let position: SIMD3<Float>
    let emissions: Double
    let entity: ModelEntity
}

struct Path3D {
    let start: SIMD3<Float>
    let end: SIMD3<Float>
    let emissions: Double
}

struct ImpactZone3D {
    let center: SIMD3<Float>
    let radius: Float
    let severity: Float
}
