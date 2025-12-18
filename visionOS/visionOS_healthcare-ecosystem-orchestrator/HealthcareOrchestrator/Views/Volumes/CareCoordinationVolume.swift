import SwiftUI
import RealityKit

struct CareCoordinationVolume: View {
    @Environment(\.modelContext) private var modelContext
    @State private var rotationAngle: Angle = .zero

    var body: some View {
        RealityView { content in
            // Create 3D scene for patient journey visualization
            let patientJourneyEntity = await createPatientJourneyVisualization()
            content.add(patientJourneyEntity)
        } update: { content in
            // Update content based on real-time data
        }
        .gesture(
            RotateGesture3D()
                .onChanged { value in
                    rotationAngle = value.rotation.angle
                }
        )
        .overlay(alignment: .topLeading) {
            // UI Controls
            VStack(alignment: .leading, spacing: 16) {
                Text("Care Coordination")
                    .font(.title)
                    .bold()

                Text("Visualizing patient journey and care pathways")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button {
                        // Reset view
                        rotationAngle = .zero
                    } label: {
                        Label("Reset View", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        // Show timeline
                    } label: {
                        Label("Timeline", systemImage: "clock.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding()
        }
    }

    // MARK: - 3D Scene Creation
    private func createPatientJourneyVisualization() async -> Entity {
        let rootEntity = Entity()

        // Create central patient sphere
        let patientSphere = await createPatientSphere()
        patientSphere.position = [0, 0, 0]
        rootEntity.addChild(patientSphere)

        // Create care pathway lines
        let carePathway = await createCarePathway()
        rootEntity.addChild(carePathway)

        // Create milestone nodes
        let milestones = await createMilestoneNodes()
        for milestone in milestones {
            rootEntity.addChild(milestone)
        }

        // Add ambient lighting
        let lightEntity = Entity()
        lightEntity.components.set(DirectionalLightComponent())
        rootEntity.addChild(lightEntity)

        return rootEntity
    }

    private func createPatientSphere() async -> Entity {
        let sphereEntity = Entity()

        // Create sphere mesh
        let sphereMesh = MeshResource.generateSphere(radius: 0.2)
        var material = SimpleMaterial()
        material.color = .init(tint: .blue.withAlphaComponent(0.7))
        material.metallic = 0.8
        material.roughness = 0.2

        sphereEntity.components.set(ModelComponent(mesh: sphereMesh, materials: [material]))

        // Add rotation animation
        let rotationAnimation = FromToByAnimation<Transform>(
            from: .init(rotation: simd_quatf(angle: 0, axis: [0, 1, 0])),
            to: .init(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0])),
            duration: 10,
            timing: .linear,
            isAdditive: false,
            bindTarget: .transform,
            repeatMode: .repeat
        )

        if let animationResource = try? AnimationResource.generate(with: rotationAnimation) {
            sphereEntity.playAnimation(animationResource)
        }

        return sphereEntity
    }

    private func createCarePathway() async -> Entity {
        let pathwayEntity = Entity()

        // Create a curved path representing the patient journey
        let points: [SIMD3<Float>] = [
            [-0.5, -0.3, 0],
            [-0.2, 0, 0.2],
            [0, 0.2, 0],
            [0.2, 0, 0.2],
            [0.5, -0.3, 0]
        ]

        // Create line segments between points
        for i in 0..<(points.count - 1) {
            let lineEntity = Entity()
            let cylinderMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.01)
            var material = SimpleMaterial()
            material.color = .init(tint: .green.withAlphaComponent(0.8))

            lineEntity.components.set(ModelComponent(mesh: cylinderMesh, materials: [material]))
            lineEntity.position = points[i]

            pathwayEntity.addChild(lineEntity)
        }

        return pathwayEntity
    }

    private func createMilestoneNodes() async -> [Entity] {
        var milestones: [Entity] = []

        let positions: [SIMD3<Float>] = [
            [-0.5, -0.3, 0],  // Admission
            [-0.2, 0, 0.2],   // Diagnosis
            [0, 0.2, 0],      // Treatment
            [0.2, 0, 0.2],    // Recovery
            [0.5, -0.3, 0]    // Discharge
        ]

        for (index, position) in positions.enumerated() {
            let milestoneEntity = Entity()

            // Create sphere for milestone
            let sphereMesh = MeshResource.generateSphere(radius: 0.08)
            var material = SimpleMaterial()
            material.color = .init(tint: .orange.withAlphaComponent(0.9))

            milestoneEntity.components.set(ModelComponent(mesh: sphereMesh, materials: [material]))
            milestoneEntity.position = position

            // Add interaction component
            milestoneEntity.components.set(InputTargetComponent())
            milestoneEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.08)]))

            milestones.append(milestoneEntity)
        }

        return milestones
    }
}

#Preview {
    CareCoordinationVolume()
        .modelContainer(for: Patient.self, inMemory: true)
}
