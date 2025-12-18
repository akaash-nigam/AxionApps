import SwiftUI
import SwiftData

struct StoreEditorView: View {
    let storeId: UUID

    @Environment(AppState.self) private var appState
    @Query private var stores: [Store]

    @State private var selectedFixtures: Set<UUID> = []
    @State private var showingFixtureLibrary = false
    @State private var zoom: CGFloat = 1.0

    private var store: Store? {
        stores.first { $0.id == storeId }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Main canvas
            VStack(spacing: 0) {
                // Toolbar
                EditorToolbar()

                // Canvas
                if let store = store {
                    StoreCanvasView(store: store, selectedFixtures: $selectedFixtures, zoom: $zoom)
                } else {
                    ContentUnavailableView("Store not found", systemImage: "exclamationmark.triangle")
                }

                // Bottom controls
                BottomControls(zoom: $zoom)
            }

            // Sidebar
            FixtureSidebar(showingLibrary: $showingFixtureLibrary)
                .frame(width: 250)
        }
        .navigationTitle(store?.name ?? "Store Editor")
    }
}

// MARK: - Editor Toolbar

struct EditorToolbar: View {
    @Environment(\.openWindow) private var openWindow
    @State private var selectedTool: EditorTool = .select

    var body: some View {
        HStack(spacing: 12) {
            ForEach(EditorTool.allCases) { tool in
                Button(action: { selectedTool = tool }) {
                    Image(systemName: tool.icon)
                        .frame(width: 32, height: 32)
                        .background(selectedTool == tool ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .frame(height: 24)

            Button(action: {}) {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }

            Button(action: {}) {
                Label("Redo", systemImage: "arrow.uturn.forward")
            }

            Spacer()

            Button(action: {}) {
                Label("3D Preview", systemImage: "cube.fill")
            }

            Button(action: {}) {
                Label("Analytics", systemImage: "chart.bar.fill")
            }

            Button(action: {}) {
                Label("Simulate", systemImage: "play.fill")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
}

enum EditorTool: String, CaseIterable, Identifiable {
    case select, move, rotate, measure

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .select: return "arrow.up.left"
        case .move: return "arrow.up.and.down.and.arrow.left.and.right"
        case .rotate: return "arrow.triangle.2.circlepath"
        case .measure: return "ruler"
        }
    }
}

// MARK: - Store Canvas

struct StoreCanvasView: View {
    let store: Store
    @Binding var selectedFixtures: Set<UUID>
    @Binding var zoom: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                GridBackground(spacing: 50 * zoom)

                // Store outline
                StoreOutline(dimensions: store.dimensions, zoom: zoom)

                // Fixtures
                if let layout = store.layouts?.first,
                   let fixtures = layout.fixtures {
                    ForEach(fixtures) { fixture in
                        FixtureView(fixture: fixture, zoom: zoom)
                            .onTapGesture {
                                toggleSelection(fixture.id)
                            }
                            .overlay {
                                if selectedFixtures.contains(fixture.id) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.blue, lineWidth: 2)
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(white: 0.95))
    }

    private func toggleSelection(_ id: UUID) {
        if selectedFixtures.contains(id) {
            selectedFixtures.remove(id)
        } else {
            selectedFixtures.insert(id)
        }
    }
}

struct GridBackground: View {
    let spacing: CGFloat

    var body: some View {
        Canvas { context, size in
            let columns = Int(size.width / spacing)
            let rows = Int(size.height / spacing)

            for col in 0...columns {
                let x = CGFloat(col) * spacing
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.gray.opacity(0.3)),
                    lineWidth: 0.5
                )
            }

            for row in 0...rows {
                let y = CGFloat(row) * spacing
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.gray.opacity(0.3)),
                    lineWidth: 0.5
                )
            }
        }
    }
}

struct StoreOutline: View {
    let dimensions: StoreDimensions
    let zoom: CGFloat

    var body: some View {
        Rectangle()
            .stroke(Color.black, lineWidth: 3)
            .frame(
                width: CGFloat(dimensions.width) * 20 * zoom,
                height: CGFloat(dimensions.length) * 20 * zoom
            )
    }
}

struct FixtureView: View {
    let fixture: Fixture
    let zoom: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.blue.opacity(0.3))
            .frame(
                width: CGFloat(fixture.dimensions.x) * 20 * zoom,
                height: CGFloat(fixture.dimensions.z) * 20 * zoom
            )
            .overlay {
                Text(fixture.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            .position(
                x: CGFloat(fixture.position.x) * 20 * zoom,
                y: CGFloat(fixture.position.z) * 20 * zoom
            )
    }
}

// MARK: - Bottom Controls

struct BottomControls: View {
    @Binding var zoom: CGFloat

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text("Zoom:")
                Button(action: { zoom = max(0.5, zoom - 0.1) }) {
                    Image(systemName: "minus")
                }
                Slider(value: $zoom, in: 0.5...3.0)
                    .frame(width: 150)
                Button(action: { zoom = min(3.0, zoom + 0.1) }) {
                    Image(systemName: "plus")
                }
                Text("\(Int(zoom * 100))%")
                    .frame(width: 50)
            }

            Spacer()

            Toggle("Grid", isOn: .constant(true))
            Toggle("Snap", isOn: .constant(true))
        }
        .padding()
        .background(.bar)
    }
}

// MARK: - Fixture Sidebar

struct FixtureSidebar: View {
    @Binding var showingLibrary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fixtures")
                .font(.headline)

            ForEach(FixtureType.allCases, id: \.self) { type in
                FixtureCategoryRow(type: type)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
    }
}

struct FixtureCategoryRow: View {
    let type: FixtureType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(type.rawValue)
                .font(.caption.bold())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        FixtureIcon(type: type, index: index)
                    }
                }
            }
        }
    }
}

struct FixtureIcon: View {
    let type: FixtureType
    let index: Int

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: iconName)
                        .font(.title3)
                }

            Text("\(type.rawValue) \(index + 1)")
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: 70)
    }

    private var iconName: String {
        switch type {
        case .shelf: return "rectangle.stack.fill"
        case .rack: return "square.stack.3d.up.fill"
        case .table: return "square.fill"
        case .mannequin: return "figure.stand"
        case .checkout: return "cart.fill"
        case .entrance: return "door.left.hand.open"
        case .signage: return "signpost.right.fill"
        case .display: return "display"
        }
    }
}
