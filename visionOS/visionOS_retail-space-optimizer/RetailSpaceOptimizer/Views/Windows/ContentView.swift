import SwiftUI
import SwiftData

/// Main dashboard view
struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Query private var stores: [Store]
    @State private var searchText = ""
    @State private var showingNewStoreSheet = false

    var filteredStores: [Store] {
        if searchText.isEmpty {
            return stores
        }
        return stores.filter { store in
            store.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar with store list
            List(filteredStores, selection: Binding(
                get: { appModel.selectedStore },
                set: { appModel.selectedStore = $0 }
            )) { store in
                StoreRow(store: store)
                    .tag(store)
            }
            .navigationTitle("Retail Optimizer")
            .searchable(text: $searchText, prompt: "Search stores")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewStoreSheet = true }) {
                        Label("New Store", systemImage: "plus")
                    }
                }
            }
        } detail: {
            // Main content area
            if let selectedStore = appModel.selectedStore {
                StoreDetailView(store: selectedStore)
            } else {
                EmptyStoreView()
            }
        }
        .sheet(isPresented: $showingNewStoreSheet) {
            NewStoreView()
                .environment(appModel)
        }
    }
}

// MARK: - Store Row

struct StoreRow: View {
    let store: Store

    var body: some View {
        HStack {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)

                Text("\(store.location.city), \(store.location.state)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(store.fixtureCount) fixtures")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Store Detail View

struct StoreDetailView: View {
    let store: Store
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("\(store.location.address), \(store.location.city)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: { openWindow(id: "analytics", value: store.id) }) {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }
                    .buttonStyle(.bordered)

                    Button(action: { openWindow(id: "store-volume", value: store.id) }) {
                        Label("Open 3D", systemImage: "cube.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Quick Stats
            ScrollView {
                VStack(spacing: 24) {
                    // Metrics Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        MetricCard(
                            title: "Floor Area",
                            value: String(format: "%.0f m²", store.floorArea),
                            icon: "square.grid.2x2",
                            color: .blue
                        )

                        MetricCard(
                            title: "Fixtures",
                            value: "\(store.fixtureCount)",
                            icon: "rectangle.stack.fill",
                            color: .orange
                        )

                        MetricCard(
                            title: "Products",
                            value: "\(store.productCount)",
                            icon: "cube.box.fill",
                            color: .green
                        )
                    }

                    // Recent Activity
                    GroupBox("Recent Activity") {
                        VStack(alignment: .leading, spacing: 12) {
                            ActivityRow(
                                icon: "clock.fill",
                                title: "Last updated",
                                subtitle: store.updatedAt.formatted(date: .abbreviated, time: .shortened),
                                color: .gray
                            )

                            ActivityRow(
                                icon: "calendar",
                                title: "Created",
                                subtitle: store.createdAt.formatted(date: .abbreviated, time: .omitted),
                                color: .blue
                            )
                        }
                        .padding(.vertical, 4)
                    }

                    // Actions
                    GroupBox("Actions") {
                        VStack(spacing: 12) {
                            ActionButton(
                                title: "View in 3D",
                                icon: "cube.fill",
                                color: .blue
                            ) {
                                openWindow(id: "store-volume", value: store.id)
                            }

                            ActionButton(
                                title: "View Analytics",
                                icon: "chart.bar.fill",
                                color: .green
                            ) {
                                openWindow(id: "analytics", value: store.id)
                            }

                            ActionButton(
                                title: "Generate Suggestions",
                                icon: "lightbulb.fill",
                                color: .yellow
                            ) {
                                // Generate AI suggestions
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(color)
        }
        .buttonStyle(.plain)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptyStoreView: View {
    var body: some View {
        ContentUnavailableView(
            "No Store Selected",
            systemImage: "building.2",
            description: Text("Select a store from the list or create a new one to get started")
        )
    }
}

// MARK: - New Store View

struct NewStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var country = "USA"
    @State private var width: Double = 20
    @State private var depth: Double = 30
    @State private var height: Double = 4

    var body: some View {
        NavigationStack {
            Form {
                Section("Store Information") {
                    TextField("Store Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Country", text: $country)
                }

                Section("Dimensions (meters)") {
                    LabeledContent("Width") {
                        TextField("Width", value: $width, format: .number)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Depth") {
                        TextField("Depth", value: $depth, format: .number)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Height") {
                        TextField("Height", value: $height, format: .number)
                            .multilineTextAlignment(.trailing)
                    }

                    LabeledContent("Floor Area") {
                        Text(String(format: "%.0f m²", width * depth))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createStore()
                        dismiss()
                    }
                    .disabled(name.isEmpty || city.isEmpty)
                }
            }
        }
    }

    private func createStore() {
        let store = Store(
            name: name,
            location: StoreLocation(
                address: address,
                city: city,
                state: state,
                country: country,
                postalCode: nil,
                coordinates: nil
            ),
            dimensions: StoreDimensions(
                width: width,
                depth: depth,
                height: height
            )
        )

        modelContext.insert(store)
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
