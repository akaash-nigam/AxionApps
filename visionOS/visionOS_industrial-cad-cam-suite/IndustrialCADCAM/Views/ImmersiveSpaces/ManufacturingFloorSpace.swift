import SwiftUI
import RealityKit

struct ManufacturingFloorSpace: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ManufacturingFloorViewModel()

    var body: some View {
        RealityView { content in
            await viewModel.setup(content: content)
        } update: { content in
            viewModel.update(content: content)
        } attachments: {
            Attachment(id: "machine-info") {
                MachineInfoPanel()
            }

            Attachment(id: "process-timeline") {
                ProcessTimelinePanel()
            }
        }
    }
}

struct MachineInfoPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CNC Mill - Machine 01")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Status", value: "Running", color: .green)
                InfoRow(label: "Progress", value: "65%", color: .blue)
                InfoRow(label: "Time Left", value: "15 min", color: .orange)
            }

            ProgressView(value: 0.65)
                .tint(.blue)
        }
        .frame(width: 300)
        .padding()
        .glassBackgroundEffect()
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }
}

struct ProcessTimelinePanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Production Timeline")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                TimelineStep(name: "Roughing", status: .completed)
                TimelineStep(name: "Finishing", status: .inProgress)
                TimelineStep(name: "Inspection", status: .pending)
                TimelineStep(name: "Assembly", status: .pending)
            }
        }
        .frame(width: 300)
        .padding()
        .glassBackgroundEffect()
    }
}

struct TimelineStep: View {
    let name: String
    let status: StepStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.icon)
                .foregroundStyle(status.color)

            Text(name)
                .font(.subheadline)

            Spacer()
        }
    }

    enum StepStatus {
        case completed
        case inProgress
        case pending

        var icon: String {
            switch self {
            case .completed: return "checkmark.circle.fill"
            case .inProgress: return "clock.fill"
            case .pending: return "circle"
            }
        }

        var color: Color {
            switch self {
            case .completed: return .green
            case .inProgress: return .blue
            case .pending: return .gray
            }
        }
    }
}

@Observable
class ManufacturingFloorViewModel {
    var machines: [Entity] = []
    var parts: [Entity] = []
    var floor: Entity?

    func setup(content: RealityViewContent) async {
        // Create factory floor
        let floor = createFactoryFloor()
        self.floor = floor
        content.add(floor)

        // Create machine representations
        let machines = await createMachines()
        self.machines = machines
        machines.forEach { content.add($0) }

        // Add lighting
        setupLighting(content: content)
    }

    func update(content: RealityViewContent) {
        // Update machine animations, part movements, etc.
    }

    private func createFactoryFloor() -> Entity {
        let entity = Entity()

        // Large floor mesh
        let mesh = MeshResource.generatePlane(width: 20, depth: 20)

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .gray.withAlphaComponent(0.3))
        material.roughness = 0.8

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        entity.position = [0, -1.5, 0]

        return entity
    }

    private func createMachines() async -> [Entity] {
        var machines: [Entity] = []

        // Create 3 machines
        let machinePositions: [SIMD3<Float>] = [
            [-3, 0, -3],
            [0, 0, -3],
            [3, 0, -3]
        ]

        for (index, position) in machinePositions.enumerated() {
            let machine = createMachineEntity(type: index)
            machine.position = position
            machines.append(machine)
        }

        return machines
    }

    private func createMachineEntity(type: Int) -> Entity {
        let entity = Entity()

        // Simple box representation of machine
        let mesh = MeshResource.generateBox(size: [1, 1.5, 0.8])

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: [.blue, .green, .orange][type])
        material.metallic = 0.7

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        return entity
    }

    private func setupLighting(content: RealityViewContent) {
        // Ambient factory lighting
        let ambient = AmbientLightComponent(color: .white, intensity: 800)
        let ambientEntity = Entity()
        ambientEntity.components.set(ambient)
        content.add(ambientEntity)

        // Overhead lights
        for i in 0..<4 {
            let light = PointLight()
            light.light.intensity = 5000
            light.position = [
                Float((i % 2) * 4 - 2),
                3,
                Float((i / 2) * 4 - 2)
            ]
            content.add(light)
        }
    }
}

#Preview(immersionStyle: .full) {
    ManufacturingFloorSpace()
        .environment(AppState())
}
