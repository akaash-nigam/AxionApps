//
//  OutfitListView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct OutfitListView: View {
    @StateObject private var viewModel = OutfitListViewModel()
    @State private var showFilters = false
    @State private var showCreateOutfit = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.filteredOutfits.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("Outfits")
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
                        showCreateOutfit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                OutfitFilterSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showCreateOutfit) {
                CreateOutfitView()
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
                await viewModel.loadOutfits()
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

                // Outfits Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredOutfits) { outfit in
                        NavigationLink {
                            OutfitDetailView(outfit: outfit)
                        } label: {
                            OutfitGridCell(
                                outfit: outfit,
                                onToggleFavorite: {
                                    Task {
                                        await viewModel.toggleFavorite(outfit)
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
            if let occasion = viewModel.selectedOccasion {
                FilterChip(text: occasion.rawValue.capitalized) {
                    viewModel.selectedOccasion = nil
                    viewModel.applyFilters()
                }
            }

            if viewModel.showFavoritesOnly {
                FilterChip(text: "Favorites") {
                    viewModel.showFavoritesOnly = false
                    viewModel.applyFilters()
                }
            }

            if viewModel.showAIGeneratedOnly {
                FilterChip(text: "AI Generated") {
                    viewModel.showAIGeneratedOnly = false
                    viewModel.applyFilters()
                }
            }

            Spacer()

            Text("\(viewModel.filteredOutfits.count) outfits")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Outfits Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create your first outfit or let AI suggest combinations for you")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showCreateOutfit = true
            } label: {
                Label("Create Outfit", systemImage: "plus")
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

// MARK: - Outfit Grid Cell
struct OutfitGridCell: View {
    let outfit: Outfit
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Outfit Preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient)
                    .aspectRatio(4/3, contentMode: .fit)

                VStack {
                    HStack {
                        if outfit.isAIGenerated {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Spacer()

                        Button {
                            onToggleFavorite()
                        } label: {
                            Image(systemName: outfit.isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(outfit.isFavorite ? .red : .white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)

                    Spacer()

                    Image(systemName: "hanger")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()
                }
            }

            // Outfit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name ?? "Untitled Outfit")
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    Image(systemName: occasionIcon(for: outfit.occasionType))
                        .font(.caption)

                    Text(outfit.occasionType.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "eye")
                        .font(.caption2)
                    Text("\(outfit.timesWorn)x worn")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    private func occasionIcon(for occasion: OccasionType) -> String {
        switch occasion {
        case .casual: return "figure.walk"
        case .work: return "briefcase.fill"
        case .formal: return "suit.fill"
        case .party: return "party.popper.fill"
        case .workout: return "figure.run"
        case .dateNight: return "heart.fill"
        case .travel: return "airplane"
        case .outdoor: return "tree.fill"
        }
    }
}

// MARK: - Outfit Filter Sheet
struct OutfitFilterSheet: View {
    @ObservedObject var viewModel: OutfitListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Occasion Filter
                Section("Occasion") {
                    Picker("Occasion", selection: $viewModel.selectedOccasion) {
                        Text("All").tag(nil as OccasionType?)
                        ForEach(OccasionType.allCases, id: \.self) { occasion in
                            Text(occasion.rawValue.capitalized).tag(occasion as OccasionType?)
                        }
                    }
                }

                // Other Filters
                Section("Other") {
                    Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
                    Toggle("AI Generated Only", isOn: $viewModel.showAIGeneratedOnly)
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
            .onChange(of: viewModel.selectedOccasion) { _, _ in
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.showFavoritesOnly) { _, _ in
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.showAIGeneratedOnly) { _, _ in
                viewModel.applyFilters()
            }
        }
    }
}

// MARK: - Create Outfit View (Placeholder)
struct CreateOutfitView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Create Outfit")
                    .font(.title)

                Text("Outfit creation will be implemented in the next epic")
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .navigationTitle("New Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OutfitListView()
}
