import SwiftUI
import RealityKit

struct EarthImmersiveView: View {
    @Environment(AppState.self) private var appState
    @State private var earthEntity = Entity()
    @State private var rotationAngle: Float = 0

    var body: some View {
        RealityView { content in
            // Create Earth sphere
            let earth = createEarthSphere()
            earthEntity.addChild(earth)

            // Position Earth 5m in front of user
            earthEntity.position = [0, 0, -5]

            content.add(earthEntity)

            // Add atmosphere
            let atmosphere = createAtmosphere()
            earthEntity.addChild(atmosphere)

            // Add facility markers
            if let facilities = appState.facilities as? [Facility] {
                for facility in facilities {
                    let marker = createFacilityMarker(facility)
                    earthEntity.addChild(marker)
                }
            }

            // Setup lighting
            setupLighting(in: content)
        } update: { content in
            // Update visualization when data changes
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    // Rotate Earth
                    let delta = value.velocity.width
                    rotationAngle += Float(delta) * 0.001
                    earthEntity.transform.rotation = simd_quatf(
                        angle: rotationAngle,
                        axis: [0, 1, 0]
                    )
                }
        )
    }

    private func createEarthSphere() -> Entity {
        // Create Earth sphere (3m diameter)
        let mesh = MeshResource.generateSphere(radius: 1.5)

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .blue)  // Would use Earth texture
        material.roughness = 0.9
        material.metallic = 0.0

        let earth = ModelEntity(mesh: mesh, materials: [material])

        // Add slow rotation
        let rotation = Transform(
            rotation: simd_quatf(angle: .pi / 60, axis: [0, 1, 0])
        )

        return earth
    }

    private func createAtmosphere() -> Entity {
        let mesh = MeshResource.generateSphere(radius: 1.6)

        var material = SimpleMaterial()
        material.color = .init(tint: .blue.opacity(0.2))

        let atmosphere = ModelEntity(mesh: mesh, materials: [material])
        return atmosphere
    }

    private func createFacilityMarker(_ facility: Facility) -> Entity {
        let marker = ModelEntity(
            mesh: .generateBox(size: 0.05),
            materials: [SimpleMaterial(color: .red, isMetallic: false)]
        )

        // Calculate position on Earth surface
        let position = calculateEarthPosition(
            latitude: facility.location.latitude,
            longitude: facility.location.longitude
        )
        marker.position = position

        return marker
    }

    private func calculateEarthPosition(latitude: Double, longitude: Double) -> SIMD3<Float> {
        let radius: Float = 1.5

        let lat = Float(latitude) * .pi / 180.0
        let lon = Float(longitude) * .pi / 180.0

        let x = radius * cos(lat) * cos(lon)
        let y = radius * sin(lat)
        let z = radius * cos(lat) * sin(lon)

        return SIMD3<Float>(x, y, z)
    }

    private func setupLighting(in content: RealityViewContent) {
        // Ambient light
        var ambientLight = PointLight()
        ambientLight.light.intensity = 500
        let ambientEntity = Entity()
        ambientEntity.components.set(ambientLight)
        ambientEntity.position = [0, 2, 0]
        content.add(ambientEntity)

        // Directional light (sun)
        var directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1000
        let sunEntity = Entity()
        sunEntity.components.set(directionalLight)
        sunEntity.look(at: [0, 0, 0], from: [5, 5, 5], relativeTo: nil)
        content.add(sunEntity)
    }
}

#Preview {
    EarthImmersiveView()
        .environment(AppState())
}
