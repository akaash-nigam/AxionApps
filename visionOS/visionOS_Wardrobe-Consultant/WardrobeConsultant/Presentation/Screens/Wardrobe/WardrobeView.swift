//
//  WardrobeView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct WardrobeView: View {
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var showFilters = false
    @State private var showAddItem = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.filteredItems.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("My Wardrobe")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if viewModel.hasActiveFilters() {
                        Button {
                            viewModel.clearFilters()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }

                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }

                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search wardrobe...")
            .onChange(of: viewModel.searchText) { _, newValue in
                Task {
                    await viewModel.searchItems()
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView()
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
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
                await viewModel.loadItems()
            }
        }
    }

    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Filter Summary
                if viewModel.hasActiveFilters() {
                    filterSummary
                }

                // Items Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredItems) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            WardrobeItemGridCell(
                                item: item,
                                onToggleFavorite: {
                                    Task {
                                        await viewModel.toggleFavorite(item)
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Filter Summary
    private var filterSummary: some View {
        HStack {
            if let category = viewModel.selectedCategory {
                FilterChip(text: category.rawValue.capitalized) {
                    viewModel.selectedCategory = nil
                    viewModel.applyFilters()
                }
            }

            if let season = viewModel.selectedSeason {
                FilterChip(text: season.rawValue.capitalized) {
                    viewModel.selectedSeason = nil
                    viewModel.applyFilters()
                }
            }

            if viewModel.showFavoritesOnly {
                FilterChip(text: "Favorites") {
                    viewModel.showFavoritesOnly = false
                    viewModel.applyFilters()
                }
            }

            Spacer()

            Text("\(viewModel.filteredItems.count) items")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tshirt")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Items Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start building your wardrobe by adding your first item")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showAddItem = true
            } label: {
                Label("Add Item", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
        }
    }
}

// MARK: - Wardrobe Item Grid Cell
struct WardrobeItemGridCell: View {
    let item: WardrobeItem
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Item Photo
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: item.primaryColor) ?? .blue)
                    .aspectRatio(3/4, contentMode: .fit)

                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            onToggleFavorite()
                        } label: {
                            Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(item.isFavorite ? .red : .white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
                    Spacer()
                }
            }

            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let brand = item.brand {
                    Text(brand)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "eye")
                        .font(.caption2)
                    Text("\(item.timesWorn)x worn")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @ObservedObject var viewModel: WardrobeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Category Filter
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All").tag(nil as ClothingCategory?)
                        ForEach(ClothingCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category as ClothingCategory?)
                        }
                    }
                }

                // Season Filter
                Section("Season") {
                    Picker("Season", selection: $viewModel.selectedSeason) {
                        Text("All").tag(nil as Season?)
                        ForEach(Season.allCases, id: \.self) { season in
                            Text(season.rawValue.capitalized).tag(season as Season?)
                        }
                    }
                }

                // Other Filters
                Section("Other") {
                    Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
                }

                // Sort Options
                Section("Sort By") {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        viewModel.clearFilters()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.selectedCategory) { _, _ in
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.selectedSeason) { _, _ in
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.showFavoritesOnly) { _, _ in
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.sortOption) { _, _ in
                viewModel.applyFilters()
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.blue.opacity(0.2))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview {
    WardrobeView()
}
