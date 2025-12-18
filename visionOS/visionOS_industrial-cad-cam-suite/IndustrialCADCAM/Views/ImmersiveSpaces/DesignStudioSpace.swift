import SwiftUI
import RealityKit

struct DesignStudioSpace: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = DesignStudioViewModel()

    var body: some View {
        RealityView { content in
            await viewModel.setup(content: content)
        } update: { content in
            viewModel.update(content: content)
        } attachments: {
            // Floating Tool Palette
            Attachment(id: "tool-palette") {
                FloatingToolPalette()
            }

            // Spatial Properties Panel
            Attachment(id: "properties") {
                SpatialPropertiesPanel()
            }
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    viewModel.handleDrag(value)
                }
        )
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    viewModel.handleTap(value.entity)
                }
        )
    }
}

struct FloatingToolPalette: View {
    @State private var selectedTool: DesignTool = .select

    var body: some View {
        HStack(spacing: 12) {
            ForEach(DesignTool.allTools, id: \.self) { tool in
                ToolButton(
                    tool: tool,
                    isSelected: selectedTool == tool
                ) {
                    selectedTool = tool
                }
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}

struct ToolButton: View {
    let tool: DesignTool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .primary)

                Text(tool.name)
                    .font(.caption2)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct SpatialPropertiesPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Properties")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                PropertyRow(label: "X", value: "100.00 mm")
                PropertyRow(label: "Y", value: "50.00 mm")
                PropertyRow(label: "Z", value: "25.00 mm")
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                PropertyRow(label: "Material", value: "Aluminum")
                PropertyRow(label: "Mass", value: "265 g")
            }
        }
        .frame(width: 250)
        .padding()
        .glassBackgroundEffect()
    }
}

struct PropertyRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

@Observable
class DesignStudioViewModel {
    var designEntities: [Entity] = []
    var selectedEntity: Entity?
    var currentTool: DesignTool = .select

    // Workspace state
    var gridFloor: Entity?
    var toolPalette: Entity?

    func setup(content: RealityViewContent) async {
        // Create immersive environment
        await createEnvironment(content: content)

        // Create sample design content
        let sampleParts = await createSampleParts()
        designEntities = sampleParts
        sampleParts.forEach { content.add($0) }

        // Add ambient lighting
        let ambientLight = AmbientLightComponent(color: .white, intensity: 500)
        let lightEntity = Entity()
        lightEntity.components.set(ambientLight)
        content.add(lightEntity)

        // Add directional lights
        for i in 0..<3 {
            let light = DirectionalLight()
            light.light.intensity = 2000
            let angle = Float(i) * .pi * 2.0 / 3.0
            light.position = [
                cos(angle) * 3,
                2,
                sin(angle) * 3
            ]
            light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
            content.add(light)
        }
    }

    func update(content: RealityViewContent) {
        // Update entity states based on interactions
    }

    func handleDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        guard currentTool == .move else { return }

        let entity = value.entity
        let translation = value.convert(value.translation3D, from: .local, to: .scene)

        entity.position += SIMD3<Float>(
            Float(translation.x),
            Float(translation.y),
            Float(translation.z)
        )
    }

    func handleTap(_ entity: Entity) {
        // Deselect previous
        if let previous = selectedEntity {
            removeHighlight(from: previous)
        }

        // Select new
        selectedEntity = entity
        addHighlight(to: entity)
    }

    private func createEnvironment(content: RealityViewContent) async {
        // Create grid floor
        let grid = createGridFloor()
        gridFloor = grid
        content.add(grid)

        // Create workspace boundaries (subtle)
        let boundary = createWorkspaceBoundary()
        content.add(boundary)
    }

    private func createGridFloor() -> Entity {
        let entity = Entity()

        // Large grid plane
        let mesh = MeshResource.generatePlane(width: 10, depth: 10)

        var material = UnlitMaterial(color: .white.withAlphaComponent(0.05))
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        entity.position = [0, -1, 0]

        return entity
    }

    private func createWorkspaceBoundary() -> Entity {
        let entity = Entity()

        // Cylindrical workspace boundary
        let mesh = MeshResource.generateCylinder(height: 3, radius: 5)

        var material = UnlitMaterial(color: .blue.withAlphaComponent(0.02))
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        return entity
    }

    private func createSampleParts() async -> [Entity] {
        var entities: [Entity] = []

        // Create a few sample parts arranged in space
        let shapes: [(MeshResource, Color)] = [
            (.generateBox(size: 0.3), .gray),
            (.generateBox(size: [0.2, 0.4, 0.2]), .blue),
            (.generateSphere(radius: 0.15), .green)
        ]

        for (index, (mesh, color)) in shapes.enumerated() {
            let entity = Entity()

            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(tint: color)
            material.metallic = 0.8
            material.roughness = 0.3

            entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
            entity.components.set(InputTargetComponent())
            entity.components.set(HoverEffectComponent())

            entity.position = [
                Float(index - 1) * 0.5,
                0.5,
                -1.5
            ]

            entities.append(entity)
        }

        return entities
    }

    private func addHighlight(to entity: Entity) {
        // Add selection highlight (outline or glow)
        if var model = entity.components[ModelComponent.self] {
            // In production, would add outline/glow material
        }
    }

    private func removeHighlight(from entity: Entity) {
        // Remove selection highlight
    }
}

extension DesignTool {
    static let allTools: [DesignTool] = [
        .select, .move, .rotate, .scale,
        .extrude, .revolve, .fillet, .chamfer,
        .measure, .section
    ]

    var icon: String {
        switch self {
        case .select: return "arrow.up.left.and.arrow.down.right"
        case .move: return "move.3d"
        case .rotate: return "rotate.3d"
        case .scale: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .extrude: return "arrow.up"
        case .revolve: return "arrow.triangle.2.circlepath"
        case .fillet: return "circle.lefthalf.filled"
        case .chamfer: return "triangle"
        case .measure: return "ruler"
        case .section: return "scissors"
        }
    }

    var name: String {
        String(describing: self).capitalized
    }
}

#Preview(immersionStyle: .mixed) {
    DesignStudioSpace()
        .environment(AppState())
}
