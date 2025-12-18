//
//  InventoryTests.swift
//  Reality Minecraft Tests
//
//  Unit tests for inventory system
//

import XCTest
@testable import Reality_Minecraft

final class InventoryTests: XCTestCase {

    var inventory: Inventory!

    override func setUp() {
        super.setUp()
        inventory = Inventory(maxSlots: 36)
    }

    override func tearDown() {
        inventory = nil
        super.tearDown()
    }

    // MARK: - Basic Inventory Tests

    func testInventoryCreation() {
        XCTAssertEqual(inventory.maxSlots, 36)
        XCTAssertEqual(inventory.slots.count, 36)
    }

    func testEmptyInventory() {
        for slot in inventory.slots {
            XCTAssertTrue(slot.isEmpty)
        }
    }

    // MARK: - Add Item Tests

    func testAddSingleItem() {
        let success = inventory.addItem("dirt", quantity: 1)

        XCTAssertTrue(success)
        XCTAssertEqual(inventory.getItemQuantity("dirt"), 1)
    }

    func testAddMultipleItems() {
        let success = inventory.addItem("stone", quantity: 10)

        XCTAssertTrue(success)
        XCTAssertEqual(inventory.getItemQuantity("stone"), 10)
    }

    func testAddItemStacking() {
        inventory.addItem("dirt", quantity: 32)
        inventory.addItem("dirt", quantity: 20)

        XCTAssertEqual(inventory.getItemQuantity("dirt"), 52)
    }

    func testAddItemMaxStack() {
        inventory.addItem("stone", quantity: 64)

        // Try to add more
        inventory.addItem("stone", quantity: 10)

        // Should create a new stack
        XCTAssertEqual(inventory.getItemQuantity("stone"), 74)
    }

    func testAddItemToFullInventory() {
        // Fill inventory completely
        for i in 0..<36 {
            inventory.setItem(at: i, slot: InventorySlot(itemType: "dirt", quantity: 64))
        }

        let success = inventory.addItem("stone", quantity: 1)

        XCTAssertFalse(success, "Should fail when inventory is full")
    }

    // MARK: - Remove Item Tests

    func testRemoveSingleItem() {
        inventory.addItem("dirt", quantity: 10)

        let success = inventory.removeItem("dirt", quantity: 1)

        XCTAssertTrue(success)
        XCTAssertEqual(inventory.getItemQuantity("dirt"), 9)
    }

    func testRemoveAllItems() {
        inventory.addItem("stone", quantity: 64)

        let success = inventory.removeItem("stone", quantity: 64)

        XCTAssertTrue(success)
        XCTAssertEqual(inventory.getItemQuantity("stone"), 0)
    }

    func testRemoveMoreThanExists() {
        inventory.addItem("dirt", quantity: 10)

        let success = inventory.removeItem("dirt", quantity: 20)

        XCTAssertFalse(success, "Should fail when trying to remove more than exists")
        XCTAssertEqual(inventory.getItemQuantity("dirt"), 10, "Should not remove any if insufficient")
    }

    func testRemoveNonexistentItem() {
        let success = inventory.removeItem("diamond", quantity: 1)

        XCTAssertFalse(success)
    }

    // MARK: - Has Item Tests

    func testHasItem() {
        inventory.addItem("coal", quantity: 5)

        XCTAssertTrue(inventory.hasItem("coal", quantity: 5))
        XCTAssertTrue(inventory.hasItem("coal", quantity: 3))
        XCTAssertFalse(inventory.hasItem("coal", quantity: 10))
    }

    func testHasItemAcrossStacks() {
        inventory.addItem("stone", quantity: 64)
        inventory.addItem("stone", quantity: 30)

        XCTAssertTrue(inventory.hasItem("stone", quantity: 94))
        XCTAssertFalse(inventory.hasItem("stone", quantity: 100))
    }

    // MARK: - Slot Management Tests

    func testGetItem() {
        inventory.addItem("dirt", quantity: 5)

        let item = inventory.getItem(at: 0)

        XCTAssertNotNil(item)
        XCTAssertEqual(item?.itemType, "dirt")
        XCTAssertEqual(item?.quantity, 5)
    }

    func testSetItem() {
        let slot = InventorySlot(itemType: "diamond", quantity: 3)
        inventory.setItem(at: 5, slot: slot)

        let retrieved = inventory.getItem(at: 5)

        XCTAssertEqual(retrieved?.itemType, "diamond")
        XCTAssertEqual(retrieved?.quantity, 3)
    }

    func testSwapSlots() {
        inventory.addItem("dirt", quantity: 10)
        inventory.addItem("stone", quantity: 20)

        // Assuming dirt is in slot 0 and stone is in slot 1
        inventory.swapSlots(from: 0, to: 1)

        let slot0 = inventory.getItem(at: 0)
        let slot1 = inventory.getItem(at: 1)

        XCTAssertEqual(slot0?.itemType, "stone")
        XCTAssertEqual(slot1?.itemType, "dirt")
    }

    func testInvalidSlotAccess() {
        let item = inventory.getItem(at: 100)
        XCTAssertNil(item, "Should return nil for invalid slot index")
    }

    // MARK: - Clear Inventory Tests

    func testClearInventory() {
        inventory.addItem("dirt", quantity: 64)
        inventory.addItem("stone", quantity: 32)

        inventory.clear()

        XCTAssertEqual(inventory.getItemQuantity("dirt"), 0)
        XCTAssertEqual(inventory.getItemQuantity("stone"), 0)

        for slot in inventory.slots {
            XCTAssertTrue(slot.isEmpty)
        }
    }

    // MARK: - Inventory Slot Tests

    func testInventorySlotEmpty() {
        let emptySlot = InventorySlot()
        XCTAssertTrue(emptySlot.isEmpty)

        let filledSlot = InventorySlot(itemType: "dirt", quantity: 1)
        XCTAssertFalse(filledSlot.isEmpty)
    }

    func testInventorySlotStackable() {
        let stackableSlot = InventorySlot(itemType: "dirt", quantity: 32)
        XCTAssertTrue(stackableSlot.isStackable)

        let fullSlot = InventorySlot(itemType: "dirt", quantity: 64)
        XCTAssertFalse(fullSlot.isStackable)
    }

    // MARK: - Hotbar Tests

    func testHotbarCreation() {
        let hotbar = Hotbar(inventory: inventory)

        XCTAssertEqual(hotbar.selectedSlot, 0)
    }

    func testHotbarSelectSlot() {
        let hotbar = Hotbar(inventory: inventory)

        hotbar.selectSlot(5)
        XCTAssertEqual(hotbar.selectedSlot, 5)

        // Test invalid slot
        hotbar.selectSlot(10)
        XCTAssertEqual(hotbar.selectedSlot, 5, "Should not change on invalid slot")
    }

    func testHotbarGetSelectedItem() {
        inventory.addItem("dirt", quantity: 10)
        let hotbar = Hotbar(inventory: inventory)

        hotbar.selectSlot(0)
        let item = hotbar.getSelectedItem()

        XCTAssertNotNil(item)
        XCTAssertEqual(item?.itemType, "dirt")
    }

    func testHotbarGetAllSlots() {
        let hotbar = Hotbar(inventory: inventory)

        inventory.addItem("dirt", quantity: 10)
        inventory.addItem("stone", quantity: 20)

        let slots = hotbar.getAllSlots()

        XCTAssertEqual(slots.count, 9)
        XCTAssertEqual(slots[0].itemType, "dirt")
        XCTAssertEqual(slots[1].itemType, "stone")
    }

    // MARK: - Codable Tests

    func testInventoryCodable() throws {
        inventory.addItem("dirt", quantity: 32)
        inventory.addItem("stone", quantity: 64)

        let encoder = JSONEncoder()
        let data = try encoder.encode(inventory)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Inventory.self, from: data)

        XCTAssertEqual(decoded.maxSlots, inventory.maxSlots)
        XCTAssertEqual(decoded.getItemQuantity("dirt"), 32)
        XCTAssertEqual(decoded.getItemQuantity("stone"), 64)
    }

    // MARK: - Performance Tests

    func testAddItemPerformance() {
        measure {
            for _ in 0..<100 {
                inventory.addItem("dirt", quantity: 1)
            }
        }
    }

    func testInventorySearchPerformance() {
        // Fill inventory
        for i in 0..<36 {
            inventory.setItem(at: i, slot: InventorySlot(itemType: "item_\(i)", quantity: 64))
        }

        measure {
            for i in 0..<36 {
                _ = inventory.hasItem("item_\(i)", quantity: 1)
            }
        }
    }
}
