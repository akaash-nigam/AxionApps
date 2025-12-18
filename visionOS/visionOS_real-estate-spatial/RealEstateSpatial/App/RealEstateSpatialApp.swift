//
//  RealEstateSpatialApp.swift
//  RealEstateSpatial
//
//  Main application entry point for visionOS
//

import SwiftUI
import SwiftData

@main
struct RealEstateSpatialApp: App {
    @State private var appModel = AppModel()
    @State private var immersionLevel: ImmersionStyle = .mixed

    var body: some Scene {
        // MARK: - Main Browser Window

        WindowGroup("Properties", id: "browser") {
            PropertyBrowserView()
                .environment(appModel)
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)

        // MARK: - Property Detail Window

        WindowGroup(id: "property-detail", for: UUID.self) { $propertyID in
            if let propertyID {
                PropertyDetailView(propertyID: propertyID)
                    .environment(appModel)
            } else {
                ContentUnavailableView(
                    "Property Not Found",
                    systemImage: "house.slash",
                    description: Text("The selected property could not be loaded.")
                )
            }
        }
        .defaultSize(width: 900, height: 1000)
        .modelContainer(sharedModelContainer)

        // MARK: - 3D Floor Plan Volume

        WindowGroup(id: "floor-plan-3d", for: UUID.self) { $propertyID in
            if let propertyID {
                FloorPlan3DView(propertyID: propertyID)
                    .environment(appModel)
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.2, depth: 1.5, in: .meters)
        .modelContainer(sharedModelContainer)

        // MARK: - Immersive Property Tour

        ImmersiveSpace(id: "property-tour", for: UUID.self) { $propertyID in
            if let propertyID {
                PropertyTourImmersiveView(propertyID: propertyID)
                    .environment(appModel)
            }
        }
        .immersionStyle(selection: $immersionLevel, in: .mixed, .progressive, .full)
        .modelContainer(sharedModelContainer)

        // MARK: - Agent Dashboard (Optional)

        #if AGENT_BUILD
        WindowGroup("Dashboard", id: "agent-dashboard") {
            AgentDashboardView()
                .environment(appModel)
        }
        .defaultSize(width: 1400, height: 900)
        .modelContainer(sharedModelContainer)
        #endif
    }

    // MARK: - Model Container

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Property.self,
            Room.self,
            User.self,
            ViewingSession.self,
            SearchQuery.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}

// MARK: - Property Detail View (Placeholder)

struct PropertyDetailView: View {
    let propertyID: UUID
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var property: Property?
    @State private var selectedTab: DetailTab = .overview

    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case photos = "Photos"
        case floorPlan = "Floor Plan"
        case neighborhood = "Neighborhood"
    }

    var body: some View {
        NavigationStack {
            if let property {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero Image
                        heroImage

                        // Price and Actions
                        priceSection

                        // Tabs
                        Picker("Details", selection: $selectedTab) {
                            ForEach(DetailTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // Tab Content
                        Group {
                            switch selectedTab {
                            case .overview:
                                overviewSection
                            case .photos:
                                photosSection
                            case .floorPlan:
                                floorPlanSection
                            case .neighborhood:
                                neighborhoodSection
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle(property.address.street)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Start Tour") {
                            Task {
                                await startTour()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                ProgressView()
                    .task {
                        await loadProperty()
                    }
            }
        }
    }

    private var heroImage: some View {
        Rectangle()
            .fill(.gray.opacity(0.2))
            .frame(height: 400)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 64))
                    .foregroundStyle(.gray)
            }
    }

    private var priceSection: some View {
        HStack {
            VStack(alignment: .leading) {
                if let property {
                    Text(property.pricing.listPrice, format: .currency(code: "USD"))
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Est. \(property.pricing.listPrice / 360, format: .currency(code: "USD"))/mo")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button("Save", systemImage: "heart") {}
                    .buttonStyle(.bordered)

                Button("Share", systemImage: "square.and.arrow.up") {}
                    .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let property {
                // Specifications
                Text("Property Details")
                    .font(.title2)
                    .fontWeight(.bold)

                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    GridRow {
                        Label("\(property.specifications.bedrooms)", systemImage: "bed.double.fill")
                        Label("\(Int(property.specifications.bathrooms))", systemImage: "shower.fill")
                    }

                    GridRow {
                        Label("\(property.specifications.squareFeet) sq ft", systemImage: "square.fill")
                        Label("Built in \(property.specifications.yearBuilt)", systemImage: "calendar")
                    }

                    GridRow {
                        Label(property.specifications.propertyType.rawValue, systemImage: "house.fill")
                        if let hoa = property.pricing.monthlyHOA {
                            Label("\(hoa, format: .currency(code: "USD"))/mo HOA", systemImage: "building.2.fill")
                        }
                    }
                }

                // Features
                if !property.specifications.features.isEmpty {
                    Divider()

                    Text("Features")
                        .font(.headline)

                    FlowLayout(spacing: 8) {
                        ForEach(property.specifications.features, id: \.self) { feature in
                            Text(feature)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var photosSection: some View {
        Text("Photos section - coming soon")
            .foregroundStyle(.secondary)
    }

    private var floorPlanSection: some View {
        Text("Floor plan section - coming soon")
            .foregroundStyle(.secondary)
    }

    private var neighborhoodSection: some View {
        Text("Neighborhood section - coming soon")
            .foregroundStyle(.secondary)
    }

    private func loadProperty() async {
        let descriptor = FetchDescriptor<Property>(
            predicate: #Predicate { $0.id == propertyID }
        )

        property = try? modelContext.fetch(descriptor).first
    }

    private func startTour() async {
        await openImmersiveSpace(id: "property-tour", value: propertyID)
    }
}

// MARK: - Floor Plan 3D View (Placeholder)

struct FloorPlan3DView: View {
    let propertyID: UUID

    var body: some View {
        VStack {
            Text("3D Floor Plan")
                .font(.title)

            Text("Property ID: \(propertyID)")
                .font(.caption)
                .foregroundStyle(.secondary)

            // In production, this would show RealityKit content
            Spacer()
        }
        .padding()
    }
}

// MARK: - Immersive Tour View (Placeholder)

struct PropertyTourImmersiveView: View {
    let propertyID: UUID
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack {
            Text("Immersive Property Tour")
                .font(.largeTitle)

            Text("Property ID: \(propertyID)")
                .font(.caption)

            Button("Exit Tour") {
                Task {
                    await dismissImmersiveSpace()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()

            // In production, this would show RealityKit immersive content
        }
    }
}

// MARK: - Agent Dashboard (Placeholder)

#if AGENT_BUILD
struct AgentDashboardView: View {
    var body: some View {
        NavigationStack {
            Text("Agent Dashboard")
                .navigationTitle("Dashboard")
        }
    }
}
#endif

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
