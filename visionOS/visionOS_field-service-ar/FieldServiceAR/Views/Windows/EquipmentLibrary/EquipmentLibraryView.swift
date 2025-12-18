//
//  EquipmentLibraryView.swift
//  FieldServiceAR
//
//  Equipment library browser window
//

import SwiftUI
import SwiftData

struct EquipmentLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @State private var searchText = ""
    @State private var selectedCategory: EquipmentCategory?
    @State private var equipment: [Equipment] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBarView

                // Category filters
                categoryFilterView

                // Equipment grid
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredEquipment.isEmpty {
                    emptyStateView
                } else {
                    equipmentGridView
                }
            }
            .navigationTitle("Equipment Library")
        }
        .task {
            await loadEquipment()
        }
    }

    // MARK: - Search Bar

    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search equipment...", text: $searchText)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.regularMaterial)
    }

    // MARK: - Category Filter

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    category: nil,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(EquipmentCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Equipment Grid

    private var equipmentGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 250), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredEquipment) { item in
                    EquipmentGridItem(equipment: item) {
                        openWindow(id: "equipment-3d", value: item.id)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Equipment Found",
            systemImage: "magnifyingglass",
            description: Text("Try adjusting your search or filters")
        )
    }

    // MARK: - Data

    private var filteredEquipment: [Equipment] {
        var filtered = equipment

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter {
                $0.name.lowercased().contains(query) ||
                $0.manufacturer.lowercased().contains(query) ||
                $0.modelNumber.lowercased().contains(query)
            }
        }

        return filtered
    }

    private func loadEquipment() async {
        isLoading = true
        defer { isLoading = false }

        let container = DependencyContainer()
        let repository = EquipmentRepository(modelContainer: container.modelContainer)

        do {
            equipment = try await repository.fetchAll()
        } catch {
            print("Error loading equipment: \(error)")
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: EquipmentCategory?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.icon)
                    Text(category.rawValue)
                } else {
                    Text("All")
                }
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.accentColor : Color.secondary.opacity(0.2)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Equipment Grid Item

struct EquipmentGridItem: View {
    let equipment: Equipment
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preview image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(.tertiary)
                .aspectRatio(4/3, contentMode: .fit)
                .overlay {
                    Image(systemName: equipment.category.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(equipment.manufacturer) \(equipment.modelNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    Label(equipment.category.rawValue, systemImage: equipment.category.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button("View 3D") {
                        action()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hoverEffect()
    }
}

#Preview {
    EquipmentLibraryView()
        .frame(width: 900, height: 650)
}
