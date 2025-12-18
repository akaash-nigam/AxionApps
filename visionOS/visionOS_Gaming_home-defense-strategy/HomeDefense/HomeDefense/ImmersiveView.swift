import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @State private var turretCount = 0

    var body: some View {
        RealityView { content in
            // Create a simple turret entity
            let turret = createTurret()
            turret.position = [0, 1.0, -2]
            content.add(turret)

            // Note: visionOS provides automatic ambient lighting
            // AmbientLightComponent is no longer available in visionOS 2.0
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    print("Tapped entity at: \(value.location3D)")
                    turretCount += 1
                }
        )
    }

    private func createTurret() -> ModelEntity {
        // Create a simple turret using primitive shapes
        let base = ModelEntity(
            mesh: .generateCylinder(height: 0.2, radius: 0.15),
            materials: [SimpleMaterial(color: .gray, isMetallic: true)]
        )

        let barrel = ModelEntity(
            mesh: .generateBox(width: 0.05, height: 0.05, depth: 0.3),
            materials: [SimpleMaterial(color: .darkGray, isMetallic: true)]
        )
        barrel.position = [0, 0.15, 0]

        let turret = ModelEntity()
        turret.addChild(base)
        turret.addChild(barrel)

        // Add collision component for interaction
        turret.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.2)]))
        turret.components.set(InputTargetComponent())

        return turret
    }
}

#Preview {
    ImmersiveView()
}
