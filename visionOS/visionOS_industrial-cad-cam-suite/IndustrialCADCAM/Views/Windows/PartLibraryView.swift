import SwiftUI

struct PartLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: PartCategory = .all

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()

                // Category Selector
                Picker("Category", selection: $selectedCategory) {
                    ForEach(PartCategory.allCases) { category in
                        Text(category.name).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Divider()

                // Parts Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 120))
                    ], spacing: 16) {
                        ForEach(filteredParts) { item in
                            PartLibraryItem(item: item)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Part Library")
        }
    }

    var filteredParts: [LibraryPart] {
        LibraryPart.standardParts.filter { part in
            (selectedCategory == .all || part.category == selectedCategory) &&
            (searchText.isEmpty || part.name.localizedCaseInsensitiveContains(searchText))
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search parts...", text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PartLibraryItem: View {
    let item: LibraryPart

    var body: some View {
        VStack(spacing: 8) {
            // 3D Preview Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item.color.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)

                Image(systemName: item.icon)
                    .font(.largeTitle)
                    .foregroundStyle(item.color)
            }

            VStack(spacing: 2) {
                Text(item.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(item.size)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hoverEffect()
        .onTapGesture {
            // Add to design
        }
    }
}

// MARK: - Supporting Types
enum PartCategory: String, Identifiable, CaseIterable {
    case all
    case fasteners
    case bearings
    case structural
    case custom

    var id: String { rawValue }

    var name: String {
        switch self {
        case .all: return "All Parts"
        case .fasteners: return "Fasteners"
        case .bearings: return "Bearings"
        case .structural: return "Structural"
        case .custom: return "Custom"
        }
    }
}

struct LibraryPart: Identifiable {
    let id = UUID()
    let name: String
    let category: PartCategory
    let icon: String
    let color: Color
    let size: String

    static let standardParts: [LibraryPart] = [
        // Fasteners
        LibraryPart(name: "Hex Bolt M8×20", category: .fasteners, icon: "arrow.up", color: .blue, size: "M8"),
        LibraryPart(name: "Hex Nut M8", category: .fasteners, icon: "hexagon", color: .blue, size: "M8"),
        LibraryPart(name: "Washer M8", category: .fasteners, icon: "circle", color: .blue, size: "M8"),
        LibraryPart(name: "Socket Screw M6×25", category: .fasteners, icon: "arrow.up", color: .blue, size: "M6"),

        // Bearings
        LibraryPart(name: "Ball Bearing 608ZZ", category: .bearings, icon: "circle.circle", color: .green, size: "8×22×7"),
        LibraryPart(name: "Thrust Bearing", category: .bearings, icon: "circle.grid.cross", color: .green, size: "10×24×9"),

        // Structural
        LibraryPart(name: "Angle Bracket", category: .structural, icon: "l.square", color: .orange, size: "50×50"),
        LibraryPart(name: "T-Slot Extrusion", category: .structural, icon: "rectangle.portrait", color: .orange, size: "20×20×500"),
        LibraryPart(name: "Mounting Plate", category: .structural, icon: "square", color: .orange, size: "100×100"),

        // Custom
        LibraryPart(name: "Custom Part 1", category: .custom, icon: "cube", color: .purple, size: "Custom"),
        LibraryPart(name: "Custom Part 2", category: .custom, icon: "cube.fill", color: .purple, size: "Custom"),
    ]
}

#Preview {
    PartLibraryView()
        .frame(width: 500, height: 700)
}
