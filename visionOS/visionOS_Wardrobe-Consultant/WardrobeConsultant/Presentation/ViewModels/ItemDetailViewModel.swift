//
//  ItemDetailViewModel.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class ItemDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var item: WardrobeItem
    @Published var relatedOutfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false

    // MARK: - Dependencies
    private let wardrobeRepository: WardrobeRepository
    private let outfitRepository: OutfitRepository

    // MARK: - Initialization
    init(
        item: WardrobeItem,
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared,
        outfitRepository: OutfitRepository = CoreDataOutfitRepository.shared
    ) {
        self.item = item
        self.wardrobeRepository = wardrobeRepository
        self.outfitRepository = outfitRepository
    }

    // MARK: - Data Loading
    func loadRelatedOutfits() async {
        isLoading = true

        do {
            relatedOutfits = try await outfitRepository.fetchByItemID(item.id)
            isLoading = false
        } catch {
            errorMessage = "Failed to load related outfits: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Actions
    func toggleFavorite() async {
        do {
            item.isFavorite.toggle()
            try await wardrobeRepository.update(item)
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
            item.isFavorite.toggle() // Revert on error
        }
    }

    func incrementTimesWorn() async {
        do {
            item.timesWorn += 1
            item.lastWornDate = Date()
            try await wardrobeRepository.update(item)
        } catch {
            errorMessage = "Failed to update wear count: \(error.localizedDescription)"
        }
    }

    func deleteItem() async -> Bool {
        do {
            try await wardrobeRepository.delete(item.id)
            return true
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
            return false
        }
    }

    func updateItem(_ updatedItem: WardrobeItem) async {
        do {
            try await wardrobeRepository.update(updatedItem)
            item = updatedItem
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }

    // MARK: - Computed Properties
    var costPerWear: Decimal? {
        guard let price = item.purchasePrice, item.timesWorn > 0 else { return nil }
        return price / Decimal(item.timesWorn)
    }

    var ageInDays: Int? {
        Calendar.current.dateComponents([.day], from: item.purchaseDate, to: Date()).day
    }
}
