//
//  OutfitListViewModel.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

@MainActor
class OutfitListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var outfits: [Outfit] = []
    @Published var filteredOutfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedOccasion: OccasionType?
    @Published var showFavoritesOnly = false
    @Published var showAIGeneratedOnly = false

    // MARK: - Dependencies
    private let outfitRepository: OutfitRepository

    // MARK: - Initialization
    init(outfitRepository: OutfitRepository = CoreDataOutfitRepository.shared) {
        self.outfitRepository = outfitRepository
    }

    // MARK: - Data Loading
    func loadOutfits() async {
        isLoading = true
        errorMessage = nil

        do {
            outfits = try await outfitRepository.fetchAll()
            applyFilters()
            isLoading = false
        } catch {
            errorMessage = "Failed to load outfits: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Filtering
    func applyFilters() {
        var result = outfits

        // Filter by favorites
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // Filter by AI generated
        if showAIGeneratedOnly {
            result = result.filter { $0.isAIGenerated }
        }

        // Filter by occasion
        if let occasion = selectedOccasion {
            result = result.filter { $0.occasionType == occasion }
        }

        // Sort by creation date (most recent first)
        result = result.sorted { $0.createdAt > $1.createdAt }

        filteredOutfits = result
    }

    // MARK: - Actions
    func toggleFavorite(_ outfit: Outfit) async {
        do {
            var updatedOutfit = outfit
            updatedOutfit.isFavorite.toggle()
            try await outfitRepository.update(updatedOutfit)

            // Update local copy
            if let index = outfits.firstIndex(where: { $0.id == outfit.id }) {
                outfits[index] = updatedOutfit
            }
            applyFilters()
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }

    func deleteOutfit(_ outfit: Outfit) async {
        do {
            try await outfitRepository.delete(outfit.id)

            // Remove from local array
            outfits.removeAll { $0.id == outfit.id }
            applyFilters()
        } catch {
            errorMessage = "Failed to delete outfit: \(error.localizedDescription)"
        }
    }

    func refresh() async {
        await loadOutfits()
    }

    // MARK: - Filter Management
    func clearFilters() {
        selectedOccasion = nil
        showFavoritesOnly = false
        showAIGeneratedOnly = false
        applyFilters()
    }

    func hasActiveFilters() -> Bool {
        return selectedOccasion != nil || showFavoritesOnly || showAIGeneratedOnly
    }
}
