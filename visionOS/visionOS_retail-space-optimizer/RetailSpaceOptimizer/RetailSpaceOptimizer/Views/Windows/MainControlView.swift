import SwiftUI
import SwiftData

struct MainControlView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext

    @Query private var stores: [Store]

    @State private var showingCreateStore = false
    @State private var selectedStore: Store?

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedStore) {
                Section("My Stores") {
                    ForEach(stores) { store in
                        StoreCard(store: store)
                            .tag(store)
                    }
                }
            }
            .navigationTitle("Retail Space Optimizer")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingCreateStore = true }) {
                        Label("New Store", systemImage: "plus.circle.fill")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: { openWindow(id: "settings") }) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
        } detail: {
            if let store = selectedStore {
                StoreDetailView(store: store)
            } else {
                EmptyStoreView()
            }
        }
        .sheet(isPresented: $showingCreateStore) {
            CreateStoreView()
        }
    }
}

// MARK: - Store Card

struct StoreCard: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "storefront.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading) {
                    Text(store.name)
                        .font(.headline)

                    Text(store.location.city)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // Metrics preview
            if let metrics = store.performanceMetrics?.first {
                HStack(spacing: 16) {
                    MetricPreview(
                        icon: "chart.bar.fill",
                        value: "$\(metrics.salesPerSquareFoot)",
                        label: "per sqft"
                    )

                    MetricPreview(
                        icon: "arrow.up.forward",
                        value: "18%",
                        label: "vs last month"
                    )
                }
                .font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct MetricPreview: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.caption.bold())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Store Detail View

struct StoreDetailView: View {
    let store: Store
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text(store.name)
                    .font(.title.bold())

                Text("\(store.location.address), \(store.location.city)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Quick Actions
            HStack(spacing: 16) {
                ActionButton(
                    title: "Edit Layout",
                    icon: "square.grid.3x3",
                    color: .blue
                ) {
                    openWindow(id: "editor", value: store.id)
                }

                ActionButton(
                    title: "3D Preview",
                    icon: "cube.fill",
                    color: .purple
                ) {
                    openWindow(id: "storePreview", value: store.id)
                }

                ActionButton(
                    title: "Analytics",
                    icon: "chart.bar.fill",
                    color: .green
                ) {
                    openWindow(id: "analytics", value: store.id)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State

struct EmptyStoreView: View {
    var body: some View {
        ContentUnavailableView(
            "No Store Selected",
            systemImage: "storefront",
            description: Text("Select a store from the list to view details")
        )
    }
}

// MARK: - Create Store View

struct CreateStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var width: Double = 20
    @State private var length: Double = 30
    @State private var height: Double = 4

    var body: some View {
        NavigationStack {
            Form {
                Section("Store Information") {
                    TextField("Store Name", text: $name)
                }

                Section("Location") {
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Postal Code", text: $postalCode)
                }

                Section("Dimensions") {
                    HStack {
                        Text("Width")
                        Spacer()
                        TextField("Width", value: $width, format: .number)
                            .frame(width: 80)
                        Text("m")
                    }

                    HStack {
                        Text("Length")
                        Spacer()
                        TextField("Length", value: $length, format: .number)
                            .frame(width: 80)
                        Text("m")
                    }

                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $height, format: .number)
                            .frame(width: 80)
                        Text("m")
                    }
                }
            }
            .navigationTitle("Create Store")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createStore()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 600)
    }

    private func createStore() {
        let store = Store(
            name: name,
            location: StoreLocation(
                address: address,
                city: city,
                state: state,
                country: "USA",
                postalCode: postalCode
            ),
            dimensions: StoreDimensions(
                width: Float(width),
                length: Float(length),
                height: Float(height)
            )
        )

        modelContext.insert(store)
        dismiss()
    }
}
