//
//  AppState.swift
//  PhysicalDigitalTwins
//
//  Global app state
//

import Foundation
import Observation

@Observable
@MainActor
class AppState {
    // Dependencies
    let dependencies: AppDependencies

    // State
    var inventory: InventoryState
    var isScanning = false
    var currentError: AppError?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.inventory = InventoryState()

        // Load initial inventory
        Task {
            await loadInventory()
        }
    }

    // MARK: - Actions

    func startScanning() {
        isScanning = true
    }

    func stopScanning() {
        isScanning = false
    }

    func loadInventory() async {
        do {
            let items = try await dependencies.storageService.fetchAllItems()
            inventory.items = items
            inventory.updateStats()
        } catch {
            currentError = AppError(from: error)
        }
    }

    func addItem(_ item: InventoryItem) async {
        do {
            try await dependencies.storageService.saveItem(item)
            await loadInventory()
            HapticManager.shared.itemAdded()
        } catch {
            currentError = AppError(from: error)
            HapticManager.shared.error()
        }
    }

    func updateItem(_ item: InventoryItem) async {
        do {
            try await dependencies.storageService.saveItem(item)
            await loadInventory()
            HapticManager.shared.light()
        } catch {
            currentError = AppError(from: error)
            HapticManager.shared.error()
        }
    }

    func deleteItem(_ item: InventoryItem) async {
        do {
            // Delete photos first if they exist
            if !item.photosPaths.isEmpty {
                try await dependencies.photoService.deleteAllPhotos(paths: item.photosPaths)
            }

            // Then delete the item from storage
            try await dependencies.storageService.deleteItem(item)
            await loadInventory()
            HapticManager.shared.itemDeleted()
        } catch {
            currentError = AppError(from: error)
            HapticManager.shared.error()
        }
    }
}

// MARK: - Inventory State

@Observable
class InventoryState {
    var items: [InventoryItem] = []
    var totalValue: Decimal = 0
    var totalItems: Int = 0
    var categoryBreakdown: [ObjectCategory: Int] = [:]

    func updateStats() {
        totalItems = items.count
        totalValue = items.reduce(0) { $0 + ($1.purchasePrice ?? 0) }

        // Calculate category breakdown
        categoryBreakdown = [:]
        for item in items {
            let category = item.digitalTwin.objectType
            categoryBreakdown[category, default: 0] += 1
        }
    }
}
