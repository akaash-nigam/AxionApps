//
//  CraftingSystemTests.swift
//  Reality Minecraft Tests
//
//  Unit tests for crafting system
//

import XCTest
@testable import Reality_Minecraft

final class CraftingSystemTests: XCTestCase {

    var craftingManager: CraftingManager!
    var inventory: Inventory!

    override func setUp() {
        super.setUp()
        craftingManager = CraftingManager()
        inventory = Inventory(maxSlots: 36)
    }

    override func tearDown() {
        craftingManager = nil
        inventory = nil
        super.tearDown()
    }

    // MARK: - Recipe Registry Tests

    func testRecipeRegistryExists() {
        let registry = RecipeRegistry.shared
        let recipes = registry.getAllRecipes()

        XCTAssertGreaterThan(recipes.count, 0, "Should have registered recipes")
    }

    func testBasicRecipes() {
        let registry = RecipeRegistry.shared

        // Test oak planks recipe exists
        let planksRecipes = registry.getRecipesFor(item: "oak_planks")
        XCTAssertGreaterThan(planksRecipes.count, 0)

        // Test sticks recipe exists
        let sticksRecipes = registry.getRecipesFor(item: "stick")
        XCTAssertGreaterThan(sticksRecipes.count, 0)

        // Test crafting table recipe exists
        let tableRecipes = registry.getRecipesFor(item: "crafting_table")
        XCTAssertGreaterThan(tableRecipes.count, 0)
    }

    // MARK: - Recipe Matching Tests

    func testSimpleRecipeMatching() {
        let registry = RecipeRegistry.shared

        // Test oak planks recipe (1 log = 4 planks)
        let planksGrid: [[String?]] = [["oak_log"]]
        let planksRecipe = registry.findRecipe(for: planksGrid)

        XCTAssertNotNil(planksRecipe)
        XCTAssertEqual(planksRecipe?.result, "oak_planks")
        XCTAssertEqual(planksRecipe?.resultQuantity, 4)
    }

    func testTwoItemRecipeMatching() {
        let registry = RecipeRegistry.shared

        // Test sticks recipe (2 planks = 4 sticks)
        let sticksGrid: [[String?]] = [
            ["oak_planks"],
            ["oak_planks"]
        ]
        let sticksRecipe = registry.findRecipe(for: sticksGrid)

        XCTAssertNotNil(sticksRecipe)
        XCTAssertEqual(sticksRecipe?.result, "stick")
        XCTAssertEqual(sticksRecipe?.resultQuantity, 4)
    }

    func testComplexRecipeMatching() {
        let registry = RecipeRegistry.shared

        // Test wooden pickaxe recipe
        let pickaxeGrid: [[String?]] = [
            ["oak_planks", "oak_planks", "oak_planks"],
            [nil, "stick", nil],
            [nil, "stick", nil]
        ]
        let pickaxeRecipe = registry.findRecipe(for: pickaxeGrid)

        XCTAssertNotNil(pickaxeRecipe)
        XCTAssertEqual(pickaxeRecipe?.result, "wooden_pickaxe")
        XCTAssertEqual(pickaxeRecipe?.resultQuantity, 1)
    }

    func testNoMatchingRecipe() {
        let registry = RecipeRegistry.shared

        // Test invalid recipe
        let invalidGrid: [[String?]] = [
            ["dirt", "dirt"],
            ["stone", "stone"]
        ]
        let recipe = registry.findRecipe(for: invalidGrid)

        XCTAssertNil(recipe, "Should not find recipe for invalid pattern")
    }

    // MARK: - Crafting Tests

    func testSuccessfulCrafting() {
        // Add ingredients for oak planks
        inventory.addItem("oak_log", quantity: 1)

        let grid: [[String?]] = [["oak_log"]]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success(let item, let quantity):
            XCTAssertEqual(item, "oak_planks")
            XCTAssertEqual(quantity, 4)
            XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 4)
            XCTAssertEqual(inventory.getItemQuantity("oak_log"), 0)
        case .failure:
            XCTFail("Crafting should succeed")
        }
    }

    func testCraftingWithInsufficientMaterials() {
        // No materials in inventory
        let grid: [[String?]] = [["oak_log"]]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success:
            XCTFail("Crafting should fail with insufficient materials")
        case .failure(let error):
            XCTAssertEqual(error, .insufficientMaterials)
        }
    }

    func testCraftingWithNoRecipe() {
        inventory.addItem("dirt", quantity: 10)

        let grid: [[String?]] = [
            ["dirt", "dirt"],
            ["dirt", "dirt"]
        ]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success:
            XCTFail("Crafting should fail with no recipe")
        case .failure(let error):
            XCTAssertEqual(error, .noRecipeFound)
        }
    }

    func testCraftingConsumesIngredients() {
        inventory.addItem("oak_log", quantity: 5)

        let grid: [[String?]] = [["oak_log"]]
        _ = craftingManager.craft(grid: grid, inventory: inventory)

        XCTAssertEqual(inventory.getItemQuantity("oak_log"), 4, "Should consume 1 log")
        XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 4, "Should create 4 planks")
    }

    func testCraftingMultipleItems() {
        inventory.addItem("oak_planks", quantity: 4)

        // Craft crafting table (uses 4 planks)
        let grid: [[String?]] = [
            ["oak_planks", "oak_planks"],
            ["oak_planks", "oak_planks"]
        ]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success:
            XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 0)
            XCTAssertEqual(inventory.getItemQuantity("crafting_table"), 1)
        case .failure:
            XCTFail("Crafting should succeed")
        }
    }

    func testCraftingToolRecipe() {
        // Add materials for wooden pickaxe
        inventory.addItem("oak_planks", quantity: 3)
        inventory.addItem("stick", quantity: 2)

        let grid: [[String?]] = [
            ["oak_planks", "oak_planks", "oak_planks"],
            [nil, "stick", nil],
            [nil, "stick", nil]
        ]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success(let item, _):
            XCTAssertEqual(item, "wooden_pickaxe")
            XCTAssertEqual(inventory.getItemQuantity("wooden_pickaxe"), 1)
        case .failure:
            XCTFail("Crafting should succeed")
        }
    }

    func testCraftingTorches() {
        inventory.addItem("coal", quantity: 1)
        inventory.addItem("stick", quantity: 1)

        let grid: [[String?]] = [
            ["coal"],
            ["stick"]
        ]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success(let item, let quantity):
            XCTAssertEqual(item, "torch")
            XCTAssertEqual(quantity, 4, "Should create 4 torches")
        case .failure:
            XCTFail("Crafting should succeed")
        }
    }

    // MARK: - Available Recipes Tests

    func testGetAvailableRecipes() {
        inventory.addItem("oak_log", quantity: 2)
        inventory.addItem("oak_planks", quantity: 10)
        inventory.addItem("stick", quantity: 4)

        let available = craftingManager.getAvailableRecipes(inventory: inventory)

        XCTAssertGreaterThan(available.count, 0, "Should have available recipes")

        let recipeIds = available.map { $0.id }
        XCTAssertTrue(recipeIds.contains("oak_planks"), "Should be able to craft planks")
        XCTAssertTrue(recipeIds.contains("sticks"), "Should be able to craft sticks")
    }

    func testNoAvailableRecipes() {
        // Empty inventory
        let available = craftingManager.getAvailableRecipes(inventory: inventory)

        XCTAssertEqual(available.count, 0, "Should have no available recipes with empty inventory")
    }

    // MARK: - Edge Cases

    func testCraftingWithFullInventory() {
        // Fill inventory
        for i in 0..<36 {
            inventory.setItem(at: i, slot: InventorySlot(itemType: "dirt", quantity: 64))
        }

        // Try to craft (requires removing ingredients and adding result)
        let grid: [[String?]] = [["oak_log"]]
        let result = craftingManager.craft(grid: grid, inventory: inventory)

        switch result {
        case .success:
            XCTFail("Should fail when inventory is full")
        case .failure(let error):
            XCTAssertEqual(error, .inventoryFull)
        }
    }

    func testCraftingPreservesOtherItems() {
        inventory.addItem("dirt", quantity: 10)
        inventory.addItem("oak_log", quantity: 1)

        let grid: [[String?]] = [["oak_log"]]
        _ = craftingManager.craft(grid: grid, inventory: inventory)

        XCTAssertEqual(inventory.getItemQuantity("dirt"), 10, "Should preserve other items")
    }

    func testComplexCraftingChain() {
        // Simulate crafting chain: log -> planks -> sticks -> pickaxe

        // Step 1: Log to planks
        inventory.addItem("oak_log", quantity: 1)
        _ = craftingManager.craft(grid: [["oak_log"]], inventory: inventory)

        XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 4)

        // Step 2: Planks to sticks
        _ = craftingManager.craft(grid: [["oak_planks"], ["oak_planks"]], inventory: inventory)

        XCTAssertEqual(inventory.getItemQuantity("stick"), 4)
        XCTAssertEqual(inventory.getItemQuantity("oak_planks"), 2)

        // Step 3: Planks + sticks to pickaxe (need more planks)
        inventory.addItem("oak_planks", quantity: 1)

        let pickaxeGrid: [[String?]] = [
            ["oak_planks", "oak_planks", "oak_planks"],
            [nil, "stick", nil],
            [nil, "stick", nil]
        ]
        _ = craftingManager.craft(grid: pickaxeGrid, inventory: inventory)

        XCTAssertEqual(inventory.getItemQuantity("wooden_pickaxe"), 1)
    }

    // MARK: - Performance Tests

    func testRecipeMatchingPerformance() {
        let registry = RecipeRegistry.shared
        let grid: [[String?]] = [
            ["oak_planks", "oak_planks", "oak_planks"],
            [nil, "stick", nil],
            [nil, "stick", nil]
        ]

        measure {
            for _ in 0..<1000 {
                _ = registry.findRecipe(for: grid)
            }
        }
    }

    func testCraftingPerformance() {
        inventory.addItem("oak_log", quantity: 100)

        measure {
            for _ in 0..<50 {
                _ = craftingManager.craft(grid: [["oak_log"]], inventory: inventory)
            }
        }
    }
}
