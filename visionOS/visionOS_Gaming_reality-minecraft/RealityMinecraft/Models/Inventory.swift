//
//  Inventory.swift
//  Reality Minecraft
//
//  Player inventory and item management
//

import Foundation

// MARK: - Inventory

/// Player inventory system
class Inventory: ObservableObject, Codable {
    @Published var slots: [InventorySlot]
    let maxSlots: Int

    private enum CodingKeys: String, CodingKey {
        case slots, maxSlots
    }

    init(maxSlots: Int = 36) {
        self.maxSlots = maxSlots
        self.slots = Array(repeating: InventorySlot(), count: maxSlots)
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maxSlots = try container.decode(Int.self, forKey: .maxSlots)
        slots = try container.decode([InventorySlot].self, forKey: .slots)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxSlots, forKey: .maxSlots)
        try container.encode(slots, forKey: .slots)
    }

    // MARK: - Item Management

    /// Add item to inventory
    @discardableResult
    func addItem(_ itemType: String, quantity: Int = 1) -> Bool {
        // First try to stack with existing items
        for (index, slot) in slots.enumerated() {
            if slot.itemType == itemType && slot.quantity < 64 {
                let spaceAvailable = 64 - slot.quantity
                let amountToAdd = min(quantity, spaceAvailable)

                slots[index].quantity += amountToAdd

                if amountToAdd == quantity {
                    return true
                } else {
                    // Continue adding remaining items
                    return addItem(itemType, quantity: quantity - amountToAdd)
                }
            }
        }

        // Find empty slot
        if let emptyIndex = slots.firstIndex(where: { $0.isEmpty }) {
            slots[emptyIndex] = InventorySlot(itemType: itemType, quantity: quantity)
            return true
        }

        // Inventory full
        return false
    }

    /// Remove item from inventory
    @discardableResult
    func removeItem(_ itemType: String, quantity: Int = 1) -> Bool {
        var remainingToRemove = quantity

        for (index, slot) in slots.enumerated() {
            if slot.itemType == itemType {
                let amountToRemove = min(slot.quantity, remainingToRemove)
                slots[index].quantity -= amountToRemove
                remainingToRemove -= amountToRemove

                if slots[index].quantity == 0 {
                    slots[index] = InventorySlot() // Clear slot
                }

                if remainingToRemove == 0 {
                    return true
                }
            }
        }

        return remainingToRemove == 0
    }

    /// Check if inventory contains item
    func hasItem(_ itemType: String, quantity: Int = 1) -> Bool {
        var totalQuantity = 0

        for slot in slots {
            if slot.itemType == itemType {
                totalQuantity += slot.quantity
            }
        }

        return totalQuantity >= quantity
    }

    /// Get total quantity of item
    func getItemQuantity(_ itemType: String) -> Int {
        return slots.reduce(0) { total, slot in
            slot.itemType == itemType ? total + slot.quantity : total
        }
    }

    /// Clear inventory
    func clear() {
        slots = Array(repeating: InventorySlot(), count: maxSlots)
    }

    /// Get item at slot index
    func getItem(at index: Int) -> InventorySlot? {
        guard index >= 0 && index < maxSlots else { return nil }
        return slots[index]
    }

    /// Set item at slot index
    func setItem(at index: Int, slot: InventorySlot) {
        guard index >= 0 && index < maxSlots else { return }
        slots[index] = slot
    }

    /// Swap items between two slots
    func swapSlots(from: Int, to: Int) {
        guard from >= 0 && from < maxSlots && to >= 0 && to < maxSlots else { return }
        let temp = slots[from]
        slots[from] = slots[to]
        slots[to] = temp
    }
}

// MARK: - Inventory Slot

/// A single slot in the inventory
struct InventorySlot: Codable, Equatable {
    var itemType: String?
    var quantity: Int
    var metadata: [String: String]?

    init(itemType: String? = nil, quantity: Int = 0, metadata: [String: String]? = nil) {
        self.itemType = itemType
        self.quantity = quantity
        self.metadata = metadata
    }

    var isEmpty: Bool {
        return itemType == nil || quantity == 0
    }

    var isStackable: Bool {
        return quantity < 64
    }
}

// MARK: - Hotbar

/// Quick-access hotbar (first 9 slots of inventory)
class Hotbar {
    private weak var inventory: Inventory?
    private(set) var selectedSlot: Int = 0

    init(inventory: Inventory) {
        self.inventory = inventory
    }

    /// Select a hotbar slot (0-8)
    func selectSlot(_ index: Int) {
        guard index >= 0 && index < 9 else { return }
        selectedSlot = index
    }

    /// Get currently selected item
    func getSelectedItem() -> InventorySlot? {
        return inventory?.getItem(at: selectedSlot)
    }

    /// Get item at hotbar slot
    func getItem(at index: Int) -> InventorySlot? {
        guard index >= 0 && index < 9 else { return nil }
        return inventory?.getItem(at: index)
    }

    /// Get all hotbar slots
    func getAllSlots() -> [InventorySlot] {
        guard let inventory = inventory else {
            return Array(repeating: InventorySlot(), count: 9)
        }

        return (0..<9).map { inventory.getItem(at: $0) ?? InventorySlot() }
    }
}
