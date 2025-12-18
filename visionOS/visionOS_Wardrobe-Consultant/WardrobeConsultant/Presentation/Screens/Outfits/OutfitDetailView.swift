//
//  OutfitDetailView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit
    @StateObject private var viewModel: OutfitDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(outfit: Outfit) {
        self.outfit = outfit
        _viewModel = StateObject(wrappedValue: OutfitDetailViewModel(outfit: outfit))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Outfit Preview
                outfitPreviewSection

                // Basic Info
                basicInfoSection

                // Items in Outfit
                itemsSection

                // Details
                detailsSection

                // Statistics
                statisticsSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle(outfit.name ?? "Outfit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    Task {
                        await viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: viewModel.outfit.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.outfit.isFavorite ? .red : .primary)
                }

                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete Outfit",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteOutfit() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this outfit? This action cannot be undone.")
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

    // MARK: - Outfit Preview Section
    private var outfitPreviewSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                .aspectRatio(4/3, contentMode: .fit)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)

            VStack {
                HStack {
                    if outfit.isAIGenerated {
                        Label("AI Generated", systemImage: "sparkles")
                            .font(.caption)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                    }

                    Spacer()
                }
                .padding()

                Spacer()

                Image(systemName: "hanger")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()
            }
        }
    }

    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(outfit.name ?? "Untitled Outfit")
                        .font(.title)
                        .fontWeight(.bold)

                    HStack {
                        Image(systemName: occasionIcon(for: outfit.occasionType))
                        Text(outfit.occasionType.rawValue.capitalized)
                    }
                    .font(.title3)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if let notes = outfit.styleNotes {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Items Section
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Items (\(viewModel.items.count))")
                .font(.headline)

            if viewModel.items.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("No items found")
                        .foregroundStyle(.secondary)
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(viewModel.items) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            OutfitItemCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)

            DetailRow(
                label: "Temperature Range",
                value: "\(outfit.minTemperature)°-\(outfit.maxTemperature)°"
            )

            if !outfit.weatherConditions.isEmpty {
                DetailRow(
                    label: "Weather",
                    value: outfit.weatherConditions.map { $0.rawValue.capitalized }.joined(separator: ", ")
                )
            }

            if outfit.isAIGenerated {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Confidence Score")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.0f%%", outfit.confidenceScore * 100))
                        .fontWeight(.medium)
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
                    value: "\(outfit.timesWorn)"
                )

                StatBox(
                    icon: "calendar",
                    label: "Created",
                    value: outfit.createdAt.formatted(.relative(presentation: .named))
                )
            }

            if let lastWorn = outfit.lastWornDate {
                DetailRow(
                    label: "Last Worn",
                    value: lastWorn.formatted(date: .abbreviated, time: .omitted)
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.markAsWornToday()
                }
            } label: {
                Label("Wore This Today", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - Helper Functions
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

// MARK: - Outfit Item Card
struct OutfitItemCard: View {
    let item: WardrobeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: item.primaryColor) ?? .blue)
                .aspectRatio(3/4, contentMode: .fit)

            Text(item.category.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            if let brand = item.brand {
                Text(brand)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Outfit Detail ViewModel
@MainActor
class OutfitDetailViewModel: ObservableObject {
    @Published var outfit: Outfit
    @Published var items: [WardrobeItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false

    private let outfitRepository: OutfitRepository
    private let wardrobeRepository: WardrobeRepository

    init(
        outfit: Outfit,
        outfitRepository: OutfitRepository = CoreDataOutfitRepository.shared,
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared
    ) {
        self.outfit = outfit
        self.outfitRepository = outfitRepository
        self.wardrobeRepository = wardrobeRepository
    }

    func loadItems() async {
        isLoading = true

        do {
            let allItems = try await wardrobeRepository.fetchAll()
            items = allItems.filter { outfit.itemIDs.contains($0.id) }
            isLoading = false
        } catch {
            errorMessage = "Failed to load items: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func toggleFavorite() async {
        do {
            outfit.isFavorite.toggle()
            try await outfitRepository.update(outfit)
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
            outfit.isFavorite.toggle()
        }
    }

    func markAsWornToday() async {
        do {
            outfit.timesWorn += 1
            outfit.lastWornDate = Date()
            try await outfitRepository.update(outfit)

            // Also increment times worn for each item
            for item in items {
                var updatedItem = item
                updatedItem.timesWorn += 1
                updatedItem.lastWornDate = Date()
                try await wardrobeRepository.update(updatedItem)
            }
        } catch {
            errorMessage = "Failed to update wear count: \(error.localizedDescription)"
        }
    }

    func deleteOutfit() async -> Bool {
        do {
            try await outfitRepository.delete(outfit.id)
            return true
        } catch {
            errorMessage = "Failed to delete outfit: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        OutfitDetailView(outfit: TestDataFactory.shared.createTestOutfit(
            name: "Casual Weekend",
            occasionType: .casual,
            itemIDs: [UUID(), UUID(), UUID()],
            isAIGenerated: true
        ))
    }
}
