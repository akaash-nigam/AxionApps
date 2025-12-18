import SwiftUI

/// Floating tool palette for building and editing
struct ToolPaletteView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 12) {
            // Zone tools
            HStack(spacing: 8) {
                ToolButton(icon: "house.fill", title: "Residential", isSelected: false) {
                    coordinator.selectTool(.zone(.residential))
                }

                ToolButton(icon: "building.2.fill", title: "Commercial", isSelected: false) {
                    coordinator.selectTool(.zone(.commercial))
                }

                ToolButton(icon: "gearshape.fill", title: "Industrial", isSelected: false) {
                    coordinator.selectTool(.zone(.industrial))
                }
            }

            // Building tools
            HStack(spacing: 8) {
                ToolButton(icon: "road.lanes", title: "Road", isSelected: false) {
                    coordinator.selectTool(.road)
                }

                ToolButton(icon: "trash", title: "Delete", isSelected: false) {
                    coordinator.selectTool(.delete)
                }

                ToolButton(icon: "info.circle", title: "Inspect", isSelected: false) {
                    coordinator.selectTool(.inspect)
                }
            }

            // Simulation controls
            HStack(spacing: 8) {
                Button {
                    coordinator.togglePause()
                } label: {
                    Image(systemName: coordinator.isPaused ? "play.fill" : "pause.fill")
                }
                .buttonStyle(.borderedProminent)

                Menu {
                    Button("Slow (0.5x)") { coordinator.setSimulationSpeed(.slow) }
                    Button("Normal (1x)") { coordinator.setSimulationSpeed(.normal) }
                    Button("Fast (2x)") { coordinator.setSimulationSpeed(.fast) }
                } label: {
                    Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}

struct ToolButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption2)
            }
            .frame(width: 60, height: 60)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? .blue : .primary)
    }
}

#Preview {
    ToolPaletteView()
        .environment(GameCoordinator())
}
