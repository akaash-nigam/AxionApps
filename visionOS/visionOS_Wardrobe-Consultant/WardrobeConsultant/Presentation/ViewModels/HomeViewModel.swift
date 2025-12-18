//
//  HomeViewModel.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var recentItems: [WardrobeItem] = []
    @Published var suggestedOutfits: [Outfit] = []
    @Published var favoriteItems: [WardrobeItem] = []
    @Published var wardrobeStats: WardrobeStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let wardrobeRepository: WardrobeRepository
    private let outfitRepository: OutfitRepository
    private let userProfileRepository: UserProfileRepository

    // MARK: - Initialization
    init(
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared,
        outfitRepository: OutfitRepository = CoreDataOutfitRepository.shared,
        userProfileRepository: UserProfileRepository = CoreDataUserProfileRepository.shared
    ) {
        self.wardrobeRepository = wardrobeRepository
        self.outfitRepository = outfitRepository
        self.userProfileRepository = userProfileRepository
    }

    // MARK: - Data Loading
    func loadDashboardData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let recentItemsTask = wardrobeRepository.getRecentlyAdded(limit: 6)
            async let favoriteItemsTask = wardrobeRepository.fetchFavorites()
            async let suggestedOutfitsTask = outfitRepository.getRecentlyCreated(limit: 3)
            async let statsTask = loadWardrobeStats()

            recentItems = try await recentItemsTask
            favoriteItems = try await favoriteItemsTask
            suggestedOutfits = try await suggestedOutfitsTask
            wardrobeStats = try await statsTask

            isLoading = false
        } catch {
            errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func loadWardrobeStats() async throws -> WardrobeStats {
        async let totalCount = wardrobeRepository.getTotalItemCount()
        async let mostWorn = wardrobeRepository.getMostWorn(limit: 1)
        async let outfitCount = outfitRepository.getTotalOutfitCount()

        return WardrobeStats(
            totalItems: try await totalCount,
            totalOutfits: try await outfitCount,
            mostWornItem: try await mostWorn.first
        )
    }

    // MARK: - Actions
    func toggleFavorite(_ item: WardrobeItem) async {
        do {
            var updatedItem = item
            updatedItem.isFavorite.toggle()
            try await wardrobeRepository.update(updatedItem)

            // Refresh data
            await loadDashboardData()
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }

    func refresh() async {
        await loadDashboardData()
    }
}

// MARK: - Supporting Types
struct WardrobeStats {
    let totalItems: Int
    let totalOutfits: Int
    let mostWornItem: WardrobeItem?

    var itemsPerOutfit: Double {
        guard totalOutfits > 0 else { return 0 }
        return Double(totalItems) / Double(totalOutfits)
    }
}
