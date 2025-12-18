import SwiftUI
import RealityKit

struct SimulationVisualizationVolume: View {
    @State private var viewModel = SimulationViewModel()

    var body: some View {
        ZStack {
            RealityView { content in
                await viewModel.setup(content: content)
            } update: { content in
                viewModel.update(content: content)
            }

            VStack {
                HStack {
                    Spacer()

                    // Legend
                    SimulationLegend(
                        minValue: viewModel.minValue,
                        maxValue: viewModel.maxValue,
                        unit: viewModel.unit
                    )
                    .padding()
                }

                Spacer()

                SimulationControls(viewModel: viewModel)
                    .padding()
            }
        }
    }
}

struct SimulationLegend: View {
    let minValue: Double
    let maxValue: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stress Analysis")
                .font(.headline)

            LinearGradient(
                colors: [.blue, .green, .yellow, .orange, .red],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(width: 30, height: 150)
            .overlay(alignment: .topTrailing) {
                Text("\(Int(maxValue)) \(unit)")
                    .font(.caption)
                    .offset(x: 40)
            }
            .overlay(alignment: .bottomTrailing) {
                Text("\(Int(minValue)) \(unit)")
                    .font(.caption)
                    .offset(x: 40)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding()
        .glassBackgroundEffect()
    }
}

struct SimulationControls: View {
    @Bindable var viewModel: SimulationViewModel

    var body: some View {
        VStack(spacing: 12) {
            Picker("Simulation Type", selection: $viewModel.simulationType) {
                Text("Stress").tag(SimulationType.stress)
                Text("Thermal").tag(SimulationType.thermal)
                Text("Modal").tag(SimulationType.modal)
            }
            .pickerStyle(.segmented)

            HStack {
                Button("Run Simulation") {
                    viewModel.runSimulation()
                }
                .buttonStyle(.borderedProminent)

                Button("Export Results") {
                    viewModel.exportResults()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 400)
        .glassBackgroundEffect()
    }
}

@Observable
class SimulationViewModel {
    var simulationType: SimulationType = .stress
    var partEntity: Entity?
    var minValue: Double = 0
    var maxValue: Double = 180
    var unit: String = "MPa"
    var isRunning: Bool = false

    func setup(content: RealityViewContent) async {
        let entity = await createPartWithStressColors()
        partEntity = entity
        content.add(entity)

        // Add lighting
        let light = DirectionalLight()
        light.light.intensity = 2500
        light.position = [1, 2, 1]
        content.add(light)
    }

    func update(content: RealityViewContent) {
        // Update visualization based on simulation type
        updateColorMap()
    }

    func runSimulation() {
        isRunning = true

        // Simulate analysis
        Task {
            try? await Task.sleep(for: .seconds(2))

            await MainActor.run {
                updateResults()
                isRunning = false
            }
        }
    }

    func exportResults() {
        // Export simulation data
    }

    private func updateColorMap() {
        guard let entity = partEntity else { return }

        switch simulationType {
        case .stress:
            minValue = 0
            maxValue = 180
            unit = "MPa"
        case .thermal:
            minValue = 20
            maxValue = 150
            unit = "°C"
        case .modal:
            minValue = 0
            maxValue = 500
            unit = "Hz"
        }
    }

    private func updateResults() {
        // Update part color based on simulation results
    }

    private func createPartWithStressColors() async -> Entity {
        let entity = Entity()

        let mesh = MeshResource.generateBox(size: 0.3)

        // Create gradient material simulating stress
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .blue) // Would be color-mapped in production

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        return entity
    }
}

enum SimulationType {
    case stress
    case thermal
    case modal
}

#Preview {
    SimulationVisualizationVolume()
}
