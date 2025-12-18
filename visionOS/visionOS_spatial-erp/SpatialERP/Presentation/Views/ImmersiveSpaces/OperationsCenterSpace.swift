import SwiftUI
import RealityKit

struct OperationsCenterSpace: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OperationsCenterViewModel()

    var body: some View {
        RealityView { content in
            let scene = await viewModel.createCommandCenter()
            content.add(scene)
        } update: { content in
            await viewModel.updateScene(content: content)
        }
        .task {
            await viewModel.loadData()
        }
    }
}

@Observable
class OperationsCenterViewModel {
    private var rootEntity: Entity?

    func loadData() async {
        // Load operational data
        try? await Task.sleep(for: .milliseconds(100))
    }

    func createCommandCenter() async -> Entity {
        let root = Entity()

        // Create radial dashboard layout
        let frontDashboard = createDashboard(
            title: "Strategic Overview",
            position: [0, 0, -2.5],
            size: [3.0, 2.0]
        )
        root.addChild(frontDashboard)

        // Right panel - Financial
        let rightPanel = createDashboard(
            title: "Financial Metrics",
            position: [2, 0, 0],
            size: [2.5, 2.0]
        )
        rightPanel.orientation = simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])
        root.addChild(rightPanel)

        // Left panel - Operations
        let leftPanel = createDashboard(
            title: "Operations Status",
            position: [-2, 0, 0],
            size: [2.5, 2.0]
        )
        leftPanel.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
        root.addChild(leftPanel)

        // Floor - Supply chain network
        let floorDisplay = createFloorNetwork()
        root.addChild(floorDisplay)

        // Center console
        let console = createCenterConsole()
        root.addChild(console)

        rootEntity = root
        return root
    }

    func updateScene(content: RealityViewContent) async {
        // Update with real-time data
    }

    private func createDashboard(title: String, position: SIMD3<Float>, size: [Float]) -> Entity {
        let entity = Entity()
        entity.position = position

        // Create panel background
        let panel = ModelEntity(
            mesh: .generatePlane(width: size[0], height: size[1]),
            materials: [createGlassMaterial()]
        )
        entity.addChild(panel)

        // Add title
        let titleText = createTextLabel(title, position: [0, size[1]/2 - 0.1, 0.01])
        entity.addChild(titleText)

        return entity
    }

    private func createFloorNetwork() -> Entity {
        let entity = Entity()
        entity.position = [0, -1.5, 0]

        // Create circular floor display
        let floor = ModelEntity(
            mesh: .generatePlane(width: 4.0, depth: 4.0, cornerRadius: 2.0),
            materials: [createGlassMaterial(tint: .systemBlue.withAlphaComponent(0.1))]
        )
        floor.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        entity.addChild(floor)

        return entity
    }

    private func createCenterConsole() -> Entity {
        let entity = Entity()
        entity.position = [0, -0.8, 0.6]

        // Create control panel
        let console = ModelEntity(
            mesh: .generateBox(width: 0.8, height: 0.1, depth: 0.5),
            materials: [createGlassMaterial()]
        )
        entity.addChild(console)

        return entity
    }

    private func createGlassMaterial(tint: UIColor = .white.withAlphaComponent(0.1)) -> Material {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: tint)
        material.metallic = 0.0
        material.roughness = 0.1
        material.blending = .transparent(opacity: 0.3)
        return material
    }

    private func createTextLabel(_ text: String, position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.position = position

        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.05, weight: .semibold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let textEntity = ModelEntity(
            mesh: textMesh,
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )

        textEntity.components.set(BillboardComponent())
        entity.addChild(textEntity)

        return entity
    }
}

#Preview {
    OperationsCenterSpace()
        .environment(AppState())
}
