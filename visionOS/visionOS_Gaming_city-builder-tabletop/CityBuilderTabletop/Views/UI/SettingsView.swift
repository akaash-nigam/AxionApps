import SwiftUI

/// Settings window view
struct SettingsView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        NavigationStack {
            Form {
                Section("Game Settings") {
                    LabeledContent("Simulation Speed") {
                        Picker("Speed", selection: .constant(SimulationSpeed.normal)) {
                            Text("Paused").tag(SimulationSpeed.paused)
                            Text("Slow").tag(SimulationSpeed.slow)
                            Text("Normal").tag(SimulationSpeed.normal)
                            Text("Fast").tag(SimulationSpeed.fast)
                            Text("Ultra Fast").tag(SimulationSpeed.ultraFast)
                        }
                    }
                }

                Section("City Info") {
                    LabeledContent("City Name", value: coordinator.gameState.cityData.name)
                    LabeledContent("Population", value: "\(coordinator.gameState.cityData.population)")
                    LabeledContent("Treasury", value: String(format: "$%.0f", coordinator.gameState.cityData.economy.treasury))
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "MVP Alpha")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(GameCoordinator())
}
