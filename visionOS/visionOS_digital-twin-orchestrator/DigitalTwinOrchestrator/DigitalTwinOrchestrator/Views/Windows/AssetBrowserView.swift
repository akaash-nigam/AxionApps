import SwiftUI
import SwiftData

struct AssetBrowserView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Query private var twins: [DigitalTwin]

    @State private var searchText = ""
    @State private var selectedTwin: DigitalTwin?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTwin) {
                Section("All Assets") {
                    ForEach(filteredTwins) { twin in
                        AssetRow(twin: twin)
                            .tag(twin)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search assets...")
            .navigationTitle("Asset Browser")
        } detail: {
            if let twin = selectedTwin {
                AssetDetailView(twin: twin)
            } else {
                ContentUnavailableView(
                    "Select an Asset",
                    systemImage: "gearshape.2",
                    description: Text("Choose an asset from the list to view details")
                )
            }
        }
        .toolbar {
            Button {
                if let twin = selectedTwin {
                    openWindow(id: "twin-volume", value: twin.id)
                }
            } label: {
                Label("View in 3D", systemImage: "cube.fill")
            }
            .disabled(selectedTwin == nil)
        }
    }

    private var filteredTwins: [DigitalTwin] {
        if searchText.isEmpty {
            return twins.sorted { $0.name < $1.name }
        } else {
            return twins.filter { twin in
                twin.name.localizedCaseInsensitiveContains(searchText) ||
                twin.assetType.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct AssetRow: View {
    let twin: DigitalTwin

    var body: some View {
        HStack {
            Image(systemName: twin.assetType.iconName)
                .font(.title2)
                .foregroundStyle(Color(twin.statusColor))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(twin.name)
                    .font(.headline)

                Text(twin.assetType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let location = twin.location {
                    Text(location.displayString)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(twin.healthScore))%")
                    .font(.headline)
                    .foregroundStyle(Color(twin.statusColor))

                Text(twin.operationalStatus.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AssetDetailView: View {
    let twin: DigitalTwin

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: twin.assetType.iconName)
                            .font(.system(size: 48))
                            .foregroundStyle(Color(twin.statusColor))

                        VStack(alignment: .leading) {
                            Text(twin.name)
                                .font(.largeTitle)
                                .bold()

                            Text(twin.assetType.displayName)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("\(Int(twin.healthScore))%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color(twin.statusColor))

                            Text("Health Score")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // Sensors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sensors (\(twin.sensors.count))")
                        .font(.title2)
                        .bold()

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(twin.sensors) { sensor in
                            SensorCard(sensor: sensor)
                        }
                    }
                }

                Divider()

                // Components
                VStack(alignment: .leading, spacing: 12) {
                    Text("Components (\(twin.components.count))")
                        .font(.title2)
                        .bold()

                    ForEach(twin.components) { component in
                        ComponentRow(component: component)
                    }
                }

                Divider()

                // Predictions
                if !twin.predictions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Predictions")
                            .font(.title2)
                            .bold()

                        ForEach(twin.predictions) { prediction in
                            PredictionCard(prediction: prediction)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct SensorCard: View {
    let sensor: Sensor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: sensor.sensorType.iconName)
                    .foregroundStyle(Color(sensor.statusColor))

                Text(sensor.name)
                    .font(.headline)

                Spacer()
            }

            Text(sensor.formattedValue)
                .font(.title3)
                .bold()

            Text(sensor.sensorType.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ComponentRow: View {
    let component: Component

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(component.name)
                    .font(.headline)

                Text(component.componentType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(component.healthScore))%")
                .font(.subheadline)
                .foregroundStyle(Color(component.statusColor))
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    AssetBrowserView()
        .frame(width: 800, height: 600)
}
