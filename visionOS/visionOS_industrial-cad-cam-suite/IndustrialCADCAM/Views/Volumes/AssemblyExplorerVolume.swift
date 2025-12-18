import SwiftUI
import RealityKit

struct AssemblyExplorerVolume: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AssemblyExplorerViewModel()

    var body: some View {
        ZStack {
            RealityView { content in
                await viewModel.setup(content: content)
            } update: { content in
                viewModel.update(content: content)
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        viewModel.handleTap(value.entity)
                    }
            )

            VStack {
                Spacer()

                AssemblyControls(viewModel: viewModel)
                    .padding()
            }
        }
    }
}

struct AssemblyControls: View {
    @Bindable var viewModel: AssemblyExplorerViewModel

    var body: some View {
        HStack(spacing: 16) {
            ControlButton(icon: "square.stack.3d.up", label: "Assemble") {
                viewModel.toggleExplode()
            }

            ControlButton(icon: "play.fill", label: "Animate") {
                viewModel.playAnimation()
            }

            ControlButton(icon: "exclamationmark.triangle", label: "Check") {
                viewModel.checkInterferences()
            }

            Slider(value: $viewModel.explosionFactor, in: 0...1) {
                Text("Explode")
            }
            .frame(width: 120)
        }
        .padding()
        .glassBackgroundEffect()
    }
}

@Observable
class AssemblyExplorerViewModel {
    var assemblyEntities: [Entity] = []
    var explosionFactor: Float = 0.0
    var isAnimating: Bool = false
    var selectedEntity: Entity?

    func setup(content: RealityViewContent) async {
        // Create sample assembly
        let assembly = await createSampleAssembly()
        assemblyEntities = assembly
        assembly.forEach { content.add($0) }

        // Add lighting
        let light = DirectionalLight()
        light.light.intensity = 3000
        light.position = [1, 2, 1]
        content.add(light)
    }

    func update(content: RealityViewContent) {
        // Update explosion state
        for (index, entity) in assemblyEntities.enumerated() {
            let offset = Float(index) * 0.2 * explosionFactor
            entity.position = [
                offset * cos(Float(index)),
                offset * 0.5,
                offset * sin(Float(index))
            ]
        }
    }

    func handleTap(_ entity: Entity) {
        selectedEntity = entity

        // Highlight selected entity
        if var model = entity.components[ModelComponent.self] {
            // Add highlight material
        }
    }

    func toggleExplode() {
        withAnimation(.easeInOut(duration: 1.0)) {
            explosionFactor = explosionFactor > 0.5 ? 0.0 : 1.0
        }
    }

    func playAnimation() {
        isAnimating.toggle()

        if isAnimating {
            // Animate assembly sequence
            Task {
                for i in 0..<assemblyEntities.count {
                    try? await Task.sleep(for: .milliseconds(500))
                    await MainActor.run {
                        assemblyEntities[i].isEnabled = true
                    }
                }
                isAnimating = false
            }
        }
    }

    func checkInterferences() {
        // Check for collisions between parts
        // Highlight interfering parts in red
    }

    private func createSampleAssembly() async -> [Entity] {
        var entities: [Entity] = []

        // Create 5 sample parts
        for i in 0..<5 {
            let entity = Entity()

            let size = Float.random(in: 0.1...0.2)
            let mesh = MeshResource.generateBox(size: size)

            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(tint: [
                .red, .green, .blue, .orange, .purple
            ][i])
            material.metallic = 0.8

            entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
            entity.components.set(InputTargetComponent())
            entity.components.set(HoverEffectComponent())

            entity.position = [
                Float(i) * 0.15 - 0.3,
                0,
                0
            ]

            entities.append(entity)
        }

        return entities
    }
}

#Preview {
    AssemblyExplorerVolume()
        .environment(AppState())
}
