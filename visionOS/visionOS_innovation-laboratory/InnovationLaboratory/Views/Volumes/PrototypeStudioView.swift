import SwiftUI
import RealityKit

struct PrototypeStudioView: View {
    @State private var selectedPrototype: Prototype?

    var body: some View {
        RealityView { content in
            setupPrototypeStudio(content: content)
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                }
        )
        .overlay(alignment: .topLeading) {
            studioControls
        }
    }

    private var studioControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prototype Studio")
                .font(.title2)
                .fontWeight(.bold)

            Button("Add Model") {
                addPrototypeModel()
            }
            .buttonStyle(.bordered)

            Button("Run Simulation") {
                runSimulation()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }

    @MainActor
    private func setupPrototypeStudio(content: RealityViewContent) {
        // Create workbench
        let mesh = MeshResource.generateBox(size: [0.8, 0.05, 0.8])
        var material = SimpleMaterial()
        material.color = .init(tint: .gray.withAlphaComponent(0.5))

        let workbench = ModelEntity(mesh: mesh, materials: [material])
        workbench.position = [0, -0.3, -0.5]

        content.add(workbench)

        // Add sample prototype
        addSamplePrototype(to: content)
    }

    @MainActor
    private func addSamplePrototype(to content: RealityViewContent) {
        let mesh = MeshResource.generateBox(size: 0.2)
        var material = SimpleMaterial()
        material.color = .init(tint: .blue.withAlphaComponent(0.8))

        let prototype = ModelEntity(mesh: mesh, materials: [material])
        prototype.position = [0, 0, -0.5]

        // Add physics
        prototype.components.set(PhysicsBodyComponent(
            massProperties: .default,
            mode: .dynamic
        ))

        content.add(prototype)
    }

    private func addPrototypeModel() {
        print("Adding new prototype model")
    }

    private func runSimulation() {
        print("Running simulation")
    }
}

#Preview(windowStyle: .volumetric) {
    PrototypeStudioView()
}
