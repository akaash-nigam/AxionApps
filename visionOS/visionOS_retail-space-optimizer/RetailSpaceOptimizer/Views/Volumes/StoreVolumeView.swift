import SwiftUI
import RealityKit

/// 3D volumetric view of a store
struct StoreVolumeView: View {
    let storeID: UUID
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext

    @State private var selectedFixture: Fixture?
    @State private var showingFixtureLibrary = false
    @State private var viewMode: VolumeViewMode = .layout

    var body: some View {
        ZStack {
            // 3D Scene
            RealityView { content in
                await setupScene(content: content)
            } update: { content in
                updateScene(content: content)
            }
            .gesture(
                DragGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        handleDrag(value)
                    }
            )

            // Floating Toolbar
            VStack {
                FloatingToolbar(
                    viewMode: $viewMode,
                    showingFixtureLibrary: $showingFixtureLibrary
                )
                .padding()

                Spacer()

                // Bottom controls
                if showingFixtureLibrary {
                    FixtureLibrary(onSelect: { fixtureType in
                        addFixture(type: fixtureType)
                    })
                    .padding()
                }
            }
        }
    }

    // MARK: - Scene Setup

    private func setupScene(content: RealityViewContent) async {
        // Create floor grid
        let floor = createFloorGrid()
        content.add(floor)

        // Add lighting
        let sunlight = DirectionalLight()
        sunlight.light.intensity = 50000
        sunlight.position = [5, 10, 5]
        sunlight.look(at: [0, 0, 0], from: sunlight.position, relativeTo: nil)
        content.add(sunlight)

        let ambient = AmbientLight()
        ambient.light.intensity = 3000
        content.add(ambient)

        // Load store fixtures
        // In a real implementation, would fetch from modelContext and create entities
    }

    private func updateScene(content: RealityViewContent) {
        // Update scene based on state changes
    }

    private func createFloorGrid() -> Entity {
        let gridEntity = Entity()

        // Create grid mesh
        // In a real implementation, would create actual grid geometry

        return gridEntity
    }

    // MARK: - Interaction Handlers

    private func handleDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        // Handle fixture dragging
        if let entity = value.entity as? ModelEntity {
            // Update entity position
            let translation = value.convert(value.translation3D, from: .local, to: .scene)
            entity.position = SIMD3<Float>(translation)
        }
    }

    private func addFixture(type: FixtureType) {
        // Create and add new fixture to store
        let fixture = Fixture(
            type: type,
            name: "\(type.displayName) \(UUID().uuidString.prefix(4))",
            dimensions: FixtureDimensions.standard
        )

        // In a real implementation, would:
        // 1. Create RealityKit entity
        // 2. Add to scene
        // 3. Save to modelContext
    }
}

// MARK: - Volume View Mode

enum VolumeViewMode {
    case layout
    case analytics
    case edit

    var icon: String {
        switch self {
        case .layout: return "square.grid.3x3"
        case .analytics: return "chart.bar.fill"
        case .edit: return "pencil"
        }
    }

    var title: String {
        switch self {
        case .layout: return "Layout"
        case .analytics: return "Analytics"
        case .edit: return "Edit"
        }
    }
}

// MARK: - Floating Toolbar

struct FloatingToolbar: View {
    @Binding var viewMode: VolumeViewMode
    @Binding var showingFixtureLibrary: Bool

    var body: some View {
        HStack(spacing: 16) {
            // View mode buttons
            ForEach([VolumeViewMode.layout, .analytics, .edit], id: \.title) { mode in
                Button(action: { viewMode = mode }) {
                    Label(mode.title, systemImage: mode.icon)
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
                .tint(viewMode == mode ? .blue : .gray)
            }

            Divider()
                .frame(height: 24)

            Button(action: { showingFixtureLibrary.toggle() }) {
                Label("Fixtures", systemImage: "plus.rectangle.on.folder")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)

            Button(action: {}) {
                Label("Settings", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}

// MARK: - Fixture Library

struct FixtureLibrary: View {
    let onSelect: (FixtureType) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(FixtureType.allCases, id: \.rawValue) { type in
                    FixtureCard(type: type) {
                        onSelect(type)
                    }
                }
            }
            .padding()
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(height: 120)
    }
}

struct FixtureCard: View {
    let type: FixtureType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(type.displayName)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StoreVolumeView(storeID: UUID())
        .environment(AppModel())
}
