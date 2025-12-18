//
//  InventoryListView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Appliance inventory list
//

import SwiftUI
import CoreData

struct InventoryListView: View {

    // MARK: - Properties

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ApplianceEntity.createdAt, ascending: false)],
        animation: .default
    )
    private var appliances: FetchedResults<ApplianceEntity>

    @State private var searchText = ""
    @State private var selectedCategory: ApplianceCategory?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if appliances.isEmpty {
                    emptyStateView
                } else {
                    applianceListView
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Add appliance action
                    } label: {
                        Label("Add Appliance", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search appliances")
        }
    }

    // MARK: - View Components

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Appliances", systemImage: "cube.box")
        } description: {
            Text("Start by scanning an appliance or adding one manually")
        } actions: {
            Button("Scan Appliance") {
                // Navigate to scanning
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var applianceListView: some View {
        List {
            ForEach(filteredAppliances) { applianceEntity in
                NavigationLink {
                    // Convert ApplianceEntity to Appliance domain model
                    ApplianceDetailView(appliance: applianceEntity.toAppliance())
                } label: {
                    ApplianceRowView(appliance: applianceEntity)
                }
            }
            .onDelete(perform: deleteAppliances)
        }
    }

    // MARK: - Computed Properties

    private var filteredAppliances: [ApplianceEntity] {
        appliances.filter { appliance in
            if !searchText.isEmpty {
                return appliance.brand?.localizedCaseInsensitiveContains(searchText) == true ||
                       appliance.model?.localizedCaseInsensitiveContains(searchText) == true
            }
            if let category = selectedCategory {
                return appliance.category == category.rawValue
            }
            return true
        }
    }

    // MARK: - Actions

    private func deleteAppliances(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredAppliances[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

// MARK: - Appliance Row View

struct ApplianceRowView: View {
    let appliance: ApplianceEntity

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: categoryIcon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(appliance.brand ?? "Unknown Brand")
                    .font(.headline)

                Text(appliance.model ?? "Unknown Model")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let location = appliance.roomLocation {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Status indicator
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(.vertical, 4)
    }

    private var categoryIcon: String {
        guard let category = ApplianceCategory(rawValue: appliance.category ?? "") else {
            return "cube.box.fill"
        }
        return category.icon
    }
}

// MARK: - Preview

#Preview {
    InventoryListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
