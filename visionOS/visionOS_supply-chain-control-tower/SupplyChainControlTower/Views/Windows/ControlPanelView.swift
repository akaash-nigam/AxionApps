//
//  ControlPanelView.swift
//  SupplyChainControlTower
//
//  Control panel for filters and display options
//

import SwiftUI

struct ControlPanelView: View {
    @Environment(AppState.self) private var appState
    @State private var routeDensity: Double = 0.8
    @State private var nodeLabels: Double = 0.5
    @State private var flowSpeed: Double = 0.6

    var body: some View {
        NavigationStack {
            Form {
                // View Mode Section
                Section("View Mode") {
                    Picker("Display", selection: Bindable(appState).viewMode) {
                        Label("Globe", systemImage: "globe").tag(ViewMode.globe)
                        Label("Network", systemImage: "network").tag(ViewMode.network)
                        Label("Flows", systemImage: "arrow.triangle.branch").tag(ViewMode.flows)
                        Label("Inventory", systemImage: "cube.box").tag(ViewMode.inventory)
                    }
                    .pickerStyle(.segmented)
                }

                // Time Range Section
                Section("Time Range") {
                    Picker("Range", selection: Bindable(appState).filters.timeRange) {
                        Text("Now").tag(TimeRange.now)
                        Text("24 Hours").tag(TimeRange.last24Hours)
                        Text("7 Days").tag(TimeRange.last7Days)
                        Text("30 Days").tag(TimeRange.last30Days)
                    }
                    .pickerStyle(.segmented)
                }

                // Filters Section
                Section("Filters") {
                    Toggle("Delayed shipments", isOn: Bindable(appState).filters.showDelayed)
                    Toggle("Critical items only", isOn: Bindable(appState).filters.showCriticalOnly)
                    Toggle("International only", isOn: Bindable(appState).filters.showInternationalOnly)
                    Toggle("High value (>$100K)", isOn: Bindable(appState).filters.showHighValue)
                }

                // Display Options Section
                Section("Display Options") {
                    VStack(alignment: .leading, spacing: 16) {
                        SliderControl(
                            label: "Route Density",
                            value: $routeDensity,
                            range: 0...1
                        )

                        SliderControl(
                            label: "Node Labels",
                            value: $nodeLabels,
                            range: 0...1
                        )

                        SliderControl(
                            label: "Flow Speed",
                            value: $flowSpeed,
                            range: 0...1
                        )
                    }
                }

                // Actions Section
                Section {
                    Button(action: resetView) {
                        Label("Reset View", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }

                    Button(action: savePreset) {
                        Label("Save Preset", systemImage: "bookmark")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Network Controls")
        }
    }

    private func resetView() {
        appState.filters = FilterState()
        routeDensity = 0.8
        nodeLabels = 0.5
        flowSpeed = 0.6
    }

    private func savePreset() {
        // TODO: Implement preset saving
    }
}

// MARK: - Slider Control

struct SliderControl: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: range)
        }
    }
}

#Preview {
    ControlPanelView()
        .environment(AppState())
}
