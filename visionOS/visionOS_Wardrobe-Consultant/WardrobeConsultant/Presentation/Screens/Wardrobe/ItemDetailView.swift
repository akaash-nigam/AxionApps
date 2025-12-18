//
//  ItemDetailView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false

    init(item: WardrobeItem) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(item: item))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Photo Section
                itemPhotoSection

                // Basic Info
                basicInfoSection

                // Details
                detailsSection

                // Statistics
                statisticsSection

                // Related Outfits
                if !viewModel.relatedOutfits.isEmpty {
                    relatedOutfitsSection
                }

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    Task {
                        await viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: viewModel.item.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.item.isFavorite ? .red : .primary)
                }

                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }

                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditItemView(item: viewModel.item) { updatedItem in
                Task {
                    await viewModel.updateItem(updatedItem)
                }
            }
        }
        .confirmationDialog(
            "Delete Item",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteItem() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this item? This action cannot be undone.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await viewModel.loadRelatedOutfits()
        }
    }

    // MARK: - Photo Section
    private var itemPhotoSection: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: viewModel.item.primaryColor) ?? .blue)
            .aspectRatio(3/4, contentMode: .fit)
            .frame(maxWidth: 400)
            .frame(maxWidth: .infinity)
            .overlay {
                if viewModel.item.isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                                .padding()
                        }
                        Spacer()
                    }
                }
            }
    }

    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.item.category.rawValue.capitalized)
                        .font(.title)
                        .fontWeight(.bold)

                    if let brand = viewModel.item.brand {
                        Text(brand)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                ColorIndicator(color: Color(hex: viewModel.item.primaryColor) ?? .blue)
            }

            if let secondaryColor = viewModel.item.secondaryColor {
                HStack(spacing: 8) {
                    Text("Secondary Color:")
                        .foregroundStyle(.secondary)
                    ColorIndicator(color: Color(hex: secondaryColor) ?? .gray)
                }
            }
        }
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)

            DetailRow(label: "Size", value: viewModel.item.size)
            DetailRow(label: "Fabric", value: viewModel.item.fabricType.rawValue.capitalized)
            DetailRow(label: "Pattern", value: viewModel.item.pattern.rawValue.capitalized)
            DetailRow(label: "Condition", value: viewModel.item.condition.rawValue.capitalized)

            if !viewModel.item.season.isEmpty {
                DetailRow(
                    label: "Seasons",
                    value: viewModel.item.season.map { $0.rawValue.capitalized }.joined(separator: ", ")
                )
            }

            if !viewModel.item.occasions.isEmpty {
                DetailRow(
                    label: "Occasions",
                    value: viewModel.item.occasions.map { $0.rawValue.capitalized }.joined(separator: ", ")
                )
            }

            if let retailer = viewModel.item.retailer {
                DetailRow(label: "Retailer", value: retailer)
            }

            if let notes = viewModel.item.notes {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(notes)
                        .font(.body)
                }
            }

            if let care = viewModel.item.careInstructions {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Care Instructions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(care)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)

            HStack(spacing: 16) {
                StatBox(
                    icon: "eye.fill",
                    label: "Times Worn",
                    value: "\(viewModel.item.timesWorn)"
                )

                if let costPerWear = viewModel.costPerWear {
                    StatBox(
                        icon: "dollarsign.circle.fill",
                        label: "Cost Per Wear",
                        value: String(format: "$%.2f", NSDecimalNumber(decimal: costPerWear).doubleValue)
                    )
                }

                if let age = viewModel.ageInDays {
                    StatBox(
                        icon: "calendar",
                        label: "Days Owned",
                        value: "\(age)"
                    )
                }
            }

            if let lastWorn = viewModel.item.lastWornDate {
                DetailRow(
                    label: "Last Worn",
                    value: lastWorn.formatted(date: .abbreviated, time: .omitted)
                )
            }

            if let purchasePrice = viewModel.item.purchasePrice {
                DetailRow(
                    label: "Purchase Price",
                    value: String(format: "$%.2f", NSDecimalNumber(decimal: purchasePrice).doubleValue)
                )
            }

            DetailRow(
                label: "Added",
                value: viewModel.item.createdAt.formatted(date: .abbreviated, time: .omitted)
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Related Outfits Section
    private var relatedOutfitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appears in \(viewModel.relatedOutfits.count) Outfits")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.relatedOutfits) { outfit in
                        NavigationLink {
                            OutfitDetailView(outfit: outfit)
                        } label: {
                            OutfitMiniCard(outfit: outfit)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.incrementTimesWorn()
                }
            } label: {
                Label("Mark as Worn Today", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                // TODO: Implement outfit creation with this item
            } label: {
                Label("Create Outfit with This Item", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

struct ColorIndicator: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay {
                Circle()
                    .stroke(.secondary, lineWidth: 1)
            }
    }
}

struct StatBox: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct OutfitMiniCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.gradient)
                .frame(width: 120, height: 90)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

            Text(outfit.name ?? "Untitled")
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
}

// MARK: - Edit Item View (Placeholder)
struct EditItemView: View {
    let item: WardrobeItem
    let onSave: (WardrobeItem) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var editedItem: WardrobeItem

    init(item: WardrobeItem, onSave: @escaping (WardrobeItem) -> Void) {
        self.item = item
        self.onSave = onSave
        _editedItem = State(initialValue: item)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Brand", text: Binding(
                        get: { editedItem.brand ?? "" },
                        set: { editedItem.brand = $0.isEmpty ? nil : $0 }
                    ))

                    TextField("Size", text: $editedItem.size)
                }

                Section("Notes") {
                    TextEditor(text: Binding(
                        get: { editedItem.notes ?? "" },
                        set: { editedItem.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(height: 100)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(editedItem)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ItemDetailView(item: TestDataFactory.shared.createTestWardrobeItem(
            category: .tShirt,
            primaryColor: "#4169E1",
            brand: "Nike",
            timesWorn: 15,
            isFavorite: true
        ))
    }
}
