//
//  FarmManager.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

// MARK: - Farm Manager

@Observable
final class FarmManager {
    // MARK: - Properties

    var farms: [Farm] = []
    var activeFarm: Farm?
    var selectedField: Field?

    var isLoading = false
    var error: Error?

    // MARK: - Initialization

    init() {
        // Initialize with mock data for development
        if AppConstants.useMockData {
            loadMockData()
        }
    }

    // MARK: - Farm Management

    func loadFarms() {
        isLoading = true

        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            if AppConstants.useMockData {
                self.loadMockData()
            }

            self.isLoading = false
        }
    }

    func selectFarm(_ farm: Farm) {
        activeFarm = farm
        selectedField = nil  // Clear field selection when changing farms
    }

    func selectField(_ field: Field) {
        selectedField = field

        // Ensure the field's farm is active
        if let farm = field.farm, farm != activeFarm {
            activeFarm = farm
        }
    }

    func addFarm(_ farm: Farm) {
        farms.append(farm)
        activeFarm = farm
    }

    func removeFarm(_ farm: Farm) {
        farms.removeAll { $0.id == farm.id }

        if activeFarm?.id == farm.id {
            activeFarm = farms.first
        }
    }

    // MARK: - Field Management

    func addField(to farm: Farm, field: Field) {
        farm.fields.append(field)
        field.farm = farm
    }

    func removeField(_ field: Field) {
        guard let farm = field.farm else { return }
        farm.fields.removeAll { $0.id == field.id }

        if selectedField?.id == field.id {
            selectedField = nil
        }
    }

    func updateFieldHealth(_ field: Field, health: Double) {
        field.updateHealth(score: health)
    }

    // MARK: - Data Queries

    var fieldsNeedingAttention: [Field] {
        guard let farm = activeFarm else { return [] }
        return farm.fields.filter { $0.needsAttention }
    }

    var totalAcresManaged: Double {
        farms.reduce(0) { $0 + $1.totalAcres }
    }

    var averageHealthAcrossAllFarms: Double {
        guard !farms.isEmpty else { return 0 }
        let totalHealth = farms.map { $0.averageHealth }.reduce(0, +)
        return totalHealth / Double(farms.count)
    }

    func fieldsWithIssues(in farm: Farm) -> [Field] {
        farm.fields.filter { field in
            guard let health = field.currentHealthScore else { return true }
            return health < 70.0
        }
    }

    // MARK: - Mock Data

    func loadMockData() {
        let mockFarm1 = Farm.mock(name: "Riverside Farm", acreage: 5200)
        let mockFarm2 = Farm.mock(name: "Sunset Acres", acreage: 3800)

        // Add some variety to second farm
        mockFarm2.fields = [
            Field.mock(name: "North Field", acreage: 450, cropType: .wheat, farm: mockFarm2, health: 91),
            Field.mock(name: "South Field", acreage: 380, cropType: .corn, farm: mockFarm2, health: 87),
            Field.mock(name: "East Field", acreage: 290, cropType: .soybeans, farm: mockFarm2, health: 75),
            Field.mock(name: "West Field", acreage: 320, cropType: .corn, farm: mockFarm2, health: 93),
        ]

        farms = [mockFarm1, mockFarm2]
        activeFarm = mockFarm1
    }
}
