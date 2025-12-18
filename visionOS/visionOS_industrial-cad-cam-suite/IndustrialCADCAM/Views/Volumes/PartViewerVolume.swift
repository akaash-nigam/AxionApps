import SwiftUI
import RealityKit

struct PartViewerVolume: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = PartViewerViewModel()

    var body: some View {
        ZStack {
            // 3D Content
            RealityView { content in
                await viewModel.setup(content: content)
            } update: { content in
                viewModel.update(content: content)
            }
            .gesture(
                DragGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        viewModel.handleDrag(value)
                    }
            )
            .gesture(
                MagnifyGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        viewModel.handleMagnify(value)
                    }
            )

            // Overlay Controls
            VStack {
                Spacer()

                ViewerControls(viewModel: viewModel)
                    .padding()
            }
        }
    }
}

struct ViewerControls: View {
    @Bindable var viewModel: PartViewerViewModel

    var body: some View {
        HStack(spacing: 16) {
            ControlButton(icon: "rotate.3d", label: "Rotate") {
                viewModel.resetRotation()
            }

            ControlButton(icon: "ruler", label: "Measure") {
                viewModel.toggleMeasure()
            }

            ControlButton(icon: "scissors", label: "Section") {
                viewModel.toggleSection()
            }

            ControlButton(icon: "paintbrush", label: "Material") {
                viewModel.toggleMaterialPicker()
            }

            ControlButton(icon: "arrow.clockwise", label: "Reset") {
                viewModel.resetView()
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}

struct ControlButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)

                Text(label)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
    }
}

@Observable
class PartViewerViewModel {
    var partEntity: Entity?
    var currentRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
    var currentScale: Float = 1.0
    var measureMode: Bool = false
    var sectionMode: Bool = false

    func setup(content: RealityViewContent) async {
        // Create sample part entity
        let entity = await createSamplePartEntity()
        partEntity = entity
        content.add(entity)

        // Add lighting
        let ambientLight = DirectionalLight()
        ambientLight.light.intensity = 3000
        ambientLight.light.color = .white
        ambientLight.position = [0, 2, 0]
        content.add(ambientLight)

        // Add grid
        let grid = createGridFloor()
        content.add(grid)
    }

    func update(content: RealityViewContent) {
        guard let entity = partEntity else { return }
        entity.orientation = currentRotation
        entity.scale = [currentScale, currentScale, currentScale]
    }

    func handleDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        let translation = value.translation
        let rotation = simd_quatf(
            angle: Float(translation.width) * 0.01,
            axis: [0, 1, 0]
        )
        currentRotation = rotation * currentRotation
    }

    func handleMagnify(_ value: EntityTargetValue<MagnifyGesture.Value>) {
        currentScale *= Float(value.magnification)
        currentScale = max(0.1, min(currentScale, 3.0))
    }

    func resetRotation() {
        currentRotation = simd_quatf(angle: 0, axis: [0, 1, 0])
    }

    func resetView() {
        currentRotation = simd_quatf(angle: 0, axis: [0, 1, 0])
        currentScale = 1.0
    }

    func toggleMeasure() {
        measureMode.toggle()
    }

    func toggleSection() {
        sectionMode.toggle()
    }

    func toggleMaterialPicker() {
        // Show material picker
    }

    private func createSamplePartEntity() async -> Entity {
        let entity = Entity()

        // Create simple cube mesh
        let mesh = MeshResource.generateBox(size: 0.3)

        // Create PBR material
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .gray)
        material.roughness = 0.3
        material.metallic = 1.0

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        // Add input target
        entity.components.set(InputTargetComponent())

        // Add hover effect
        entity.components.set(HoverEffectComponent())

        return entity
    }

    private func createGridFloor() -> Entity {
        let entity = Entity()

        // Create grid plane
        let mesh = MeshResource.generatePlane(width: 2.0, depth: 2.0)

        var material = UnlitMaterial(color: .white.withAlphaComponent(0.1))
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        entity.position = [0, -0.3, 0]

        return entity
    }
}

#Preview {
    PartViewerVolume()
        .environment(AppState())
}
