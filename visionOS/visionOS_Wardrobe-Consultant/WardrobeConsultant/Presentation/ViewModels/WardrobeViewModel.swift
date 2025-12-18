//
//  WardrobeViewModel.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class WardrobeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var items: [WardrobeItem] = []
    @Published var filteredItems: [WardrobeItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: ClothingCategory?
    @Published var selectedSeason: Season?
    @Published var showFavoritesOnly = false
    @Published var sortOption: SortOption = .recentlyAdded

    // MARK: - Dependencies
    private let wardrobeRepository: WardrobeRepository

    // MARK: - Initialization
    init(wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared) {
        self.wardrobeRepository = wardrobeRepository
    }

    // MARK: - Data Loading
    func loadItems() async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await wardrobeRepository.fetchAll()
            applyFilters()
            isLoading = false
        } catch {
            errorMessage = "Failed to load wardrobe: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func searchItems() async {
        guard !searchText.isEmpty else {
            applyFilters()
            return
        }

        isLoading = true

        do {
            let results = try await wardrobeRepository.search(query: searchText)
            items = results
            applyFilters()
            isLoading = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Filtering
    func applyFilters() {
        var result = items

        // Filter by favorites
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Filter by season
        if let season = selectedSeason {
            result = result.filter { $0.season.contains(season) }
        }

        // Apply sorting
        result = sortItems(result, by: sortOption)

        filteredItems = result
    }

    private func sortItems(_ items: [WardrobeItem], by option: SortOption) -> [WardrobeItem] {
        switch option {
        case .recentlyAdded:
            return items.sorted { $0.createdAt > $1.createdAt }
        case .mostWorn:
            return items.sorted { $0.timesWorn > $1.timesWorn }
        case .leastWorn:
            return items.sorted { $0.timesWorn < $1.timesWorn }
        case .alphabetical:
            return items.sorted { ($0.brand ?? "") < ($1.brand ?? "") }
        }
    }

    // MARK: - Actions
    func toggleFavorite(_ item: WardrobeItem) async {
        do {
            var updatedItem = item
            updatedItem.isFavorite.toggle()
            try await wardrobeRepository.update(updatedItem)

            // Update local copy
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = updatedItem
            }
            applyFilters()
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }

    func deleteItem(_ item: WardrobeItem) async {
        do {
            try await wardrobeRepository.delete(item.id)

            // Remove from local array
            items.removeAll { $0.id == item.id }
            applyFilters()
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }

    func refresh() async {
        await loadItems()
    }

    // MARK: - Filter Management
    func clearFilters() {
        selectedCategory = nil
        selectedSeason = nil
        showFavoritesOnly = false
        searchText = ""
        applyFilters()
    }

    func hasActiveFilters() -> Bool {
        return selectedCategory != nil || selectedSeason != nil || showFavoritesOnly || !searchText.isEmpty
    }
}

// MARK: - Sort Options
enum SortOption: String, CaseIterable, Identifiable {
    case recentlyAdded = "Recently Added"
    case mostWorn = "Most Worn"
    case leastWorn = "Least Worn"
    case alphabetical = "Alphabetical"

    var id: String { rawValue }
}
