import SwiftUI
import RealityKit

/// Volume view for 3D data visualizations
struct DataVisualizationVolume: View {
    let type: VisualizationType

    var body: some View {
        RealityView { content in
            // Create 3D visualization based on type
            let entity = createVisualization(for: type)
            content.add(entity)
        }
        .navigationTitle(type.displayName)
    }

    private func createVisualization(for type: VisualizationType) -> Entity {
        let rootEntity = Entity()

        switch type {
        case .roiComparison:
            // Create simple 3D bar chart placeholder
            for i in 0..<5 {
                let bar = createBar(height: Float(i + 1) * 0.1, position: SIMD3(Float(i) * 0.15 - 0.3, 0, 0))
                rootEntity.addChild(bar)
            }

        case .decisionMatrix:
            // Create decision matrix placeholder
            let plane = createPlane()
            rootEntity.addChild(plane)

        case .investmentTimeline:
            // Create timeline placeholder
            let timeline = createTimeline()
            rootEntity.addChild(timeline)

        default:
            // Placeholder for other types
            let sphere = createSphere()
            rootEntity.addChild(sphere)
        }

        return rootEntity
    }

    private func createBar(height: Float, position: SIMD3<Float>) -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 0.1, height: height, depth: 0.1)
        let material = SimpleMaterial(color: .blue, roughness: 0.2, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = position
        entity.position.y = height / 2 // Center at base
        return entity
    }

    private func createPlane() -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        let material = SimpleMaterial(color: .white.withAlphaComponent(0.3), roughness: 0.5, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func createTimeline() -> Entity {
        let root = Entity()
        for i in 0..<3 {
            let sphere = createSphere()
            sphere.position = SIMD3(Float(i) * 0.2 - 0.2, 0, 0)
            root.addChild(sphere)
        }
        return root
    }

    private func createSphere() -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .green, roughness: 0.2, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}

#Preview {
    DataVisualizationVolume(type: .roiComparison)
}
