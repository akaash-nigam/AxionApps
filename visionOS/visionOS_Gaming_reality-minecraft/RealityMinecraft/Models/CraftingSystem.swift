//
//  CraftingSystem.swift
//  Reality Minecraft
//
//  Crafting system for creating items from recipes
//

import Foundation

// MARK: - Crafting Recipe

/// Represents a crafting recipe
struct CraftingRecipe: Codable {
    let id: String
    let pattern: [[String?]] // 2D grid pattern (max 3x3)
    let result: String // Item type to create
    let resultQuantity: Int

    /// Check if a crafting grid matches this recipe
    func matches(grid: [[String?]]) -> Bool {
        // Simple pattern matching (could be enhanced with rotation/mirroring)
        guard grid.count >= pattern.count else { return false }

        for (row, patternRow) in pattern.enumerated() {
            guard grid[row].count >= patternRow.count else { return false }

            for (col, patternItem) in patternRow.enumerated() {
                if grid[row][col] != patternItem {
                    return false
                }
            }
        }

        return true
    }
}

// MARK: - Recipe Registry

/// Registry of all crafting recipes
class RecipeRegistry {
    static let shared = RecipeRegistry()

    private var recipes: [CraftingRecipe] = []

    private init() {
        registerDefaultRecipes()
    }

    /// Register default Minecraft recipes
    private func registerDefaultRecipes() {
        // Wooden Planks from Log
        register(CraftingRecipe(
            id: "oak_planks",
            pattern: [["oak_log"]],
            result: "oak_planks",
            resultQuantity: 4
        ))

        // Sticks from Planks
        register(CraftingRecipe(
            id: "sticks",
            pattern: [
                ["oak_planks"],
                ["oak_planks"]
            ],
            result: "stick",
            resultQuantity: 4
        ))

        // Crafting Table
        register(CraftingRecipe(
            id: "crafting_table",
            pattern: [
                ["oak_planks", "oak_planks"],
                ["oak_planks", "oak_planks"]
            ],
            result: "crafting_table",
            resultQuantity: 1
        ))

        // Wooden Pickaxe
        register(CraftingRecipe(
            id: "wooden_pickaxe",
            pattern: [
                ["oak_planks", "oak_planks", "oak_planks"],
                [nil, "stick", nil],
                [nil, "stick", nil]
            ],
            result: "wooden_pickaxe",
            resultQuantity: 1
        ))

        // Stone Pickaxe
        register(CraftingRecipe(
            id: "stone_pickaxe",
            pattern: [
                ["cobblestone", "cobblestone", "cobblestone"],
                [nil, "stick", nil],
                [nil, "stick", nil]
            ],
            result: "stone_pickaxe",
            resultQuantity: 1
        ))

        // Wooden Axe
        register(CraftingRecipe(
            id: "wooden_axe",
            pattern: [
                ["oak_planks", "oak_planks"],
                ["oak_planks", "stick"],
                [nil, "stick"]
            ],
            result: "wooden_axe",
            resultQuantity: 1
        ))

        // Wooden Sword
        register(CraftingRecipe(
            id: "wooden_sword",
            pattern: [
                ["oak_planks"],
                ["oak_planks"],
                ["stick"]
            ],
            result: "wooden_sword",
            resultQuantity: 1
        ))

        // Torch
        register(CraftingRecipe(
            id: "torch",
            pattern: [
                ["coal"],
                ["stick"]
            ],
            result: "torch",
            resultQuantity: 4
        ))

        // Chest
        register(CraftingRecipe(
            id: "chest",
            pattern: [
                ["oak_planks", "oak_planks", "oak_planks"],
                ["oak_planks", nil, "oak_planks"],
                ["oak_planks", "oak_planks", "oak_planks"]
            ],
            result: "chest",
            resultQuantity: 1
        ))
    }

    /// Register a new recipe
    func register(_ recipe: CraftingRecipe) {
        recipes.append(recipe)
    }

    /// Find matching recipe for crafting grid
    func findRecipe(for grid: [[String?]]) -> CraftingRecipe? {
        for recipe in recipes {
            if recipe.matches(grid: grid) {
                return recipe
            }
        }
        return nil
    }

    /// Get all recipes
    func getAllRecipes() -> [CraftingRecipe] {
        return recipes
    }

    /// Get recipes that produce a specific item
    func getRecipesFor(item: String) -> [CraftingRecipe] {
        return recipes.filter { $0.result == item }
    }
}

// MARK: - Crafting Manager

/// Manages crafting operations
class CraftingManager {
    private let registry = RecipeRegistry.shared

    /// Attempt to craft from a crafting grid
    func craft(grid: [[String?]], inventory: Inventory) -> CraftingResult {
        // Find matching recipe
        guard let recipe = registry.findRecipe(for: grid) else {
            return .failure(.noRecipeFound)
        }

        // Check if player has required ingredients
        if !hasRequiredIngredients(recipe: recipe, inventory: inventory) {
            return .failure(.insufficientMaterials)
        }

        // Remove ingredients from inventory
        removeIngredients(recipe: recipe, inventory: inventory)

        // Add result to inventory
        let success = inventory.addItem(recipe.result, quantity: recipe.resultQuantity)

        if success {
            return .success(item: recipe.result, quantity: recipe.resultQuantity)
        } else {
            // Inventory full - return ingredients
            returnIngredients(recipe: recipe, inventory: inventory)
            return .failure(.inventoryFull)
        }
    }

    private func hasRequiredIngredients(recipe: CraftingRecipe, inventory: Inventory) -> Bool {
        var requiredItems: [String: Int] = [:]

        // Count required items
        for row in recipe.pattern {
            for item in row {
                if let item = item {
                    requiredItems[item, default: 0] += 1
                }
            }
        }

        // Check inventory
        for (item, quantity) in requiredItems {
            if !inventory.hasItem(item, quantity: quantity) {
                return false
            }
        }

        return true
    }

    private func removeIngredients(recipe: CraftingRecipe, inventory: Inventory) {
        var itemsToRemove: [String: Int] = [:]

        for row in recipe.pattern {
            for item in row {
                if let item = item {
                    itemsToRemove[item, default: 0] += 1
                }
            }
        }

        for (item, quantity) in itemsToRemove {
            inventory.removeItem(item, quantity: quantity)
        }
    }

    private func returnIngredients(recipe: CraftingRecipe, inventory: Inventory) {
        var itemsToReturn: [String: Int] = [:]

        for row in recipe.pattern {
            for item in row {
                if let item = item {
                    itemsToReturn[item, default: 0] += 1
                }
            }
        }

        for (item, quantity) in itemsToReturn {
            inventory.addItem(item, quantity: quantity)
        }
    }

    /// Get available recipes based on current inventory
    func getAvailableRecipes(inventory: Inventory) -> [CraftingRecipe] {
        return registry.getAllRecipes().filter { recipe in
            hasRequiredIngredients(recipe: recipe, inventory: inventory)
        }
    }
}

// MARK: - Crafting Result

enum CraftingResult {
    case success(item: String, quantity: Int)
    case failure(CraftingError)
}

enum CraftingError {
    case noRecipeFound
    case insufficientMaterials
    case inventoryFull
}
