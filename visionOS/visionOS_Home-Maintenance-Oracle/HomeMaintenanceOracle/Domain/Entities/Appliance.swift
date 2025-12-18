//
//  Appliance.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Domain model for appliances
//

import Foundation

struct Appliance: Identifiable, Codable {
    let id: UUID
    var brand: String
    var model: String
    var serialNumber: String?
    var category: ApplianceCategory
    var installDate: Date?
    var purchaseDate: Date?
    var purchasePrice: Double?
    var warrantyExpiry: Date?
    var notes: String?
    var roomLocation: String?
    var createdAt: Date
    var updatedAt: Date

    var categoryIcon: String {
        category.icon
    }

    init(
        id: UUID = UUID(),
        brand: String,
        model: String,
        serialNumber: String? = nil,
        category: ApplianceCategory,
        installDate: Date? = nil,
        purchaseDate: Date? = nil,
        purchasePrice: Double? = nil,
        warrantyExpiry: Date? = nil,
        notes: String? = nil,
        roomLocation: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.serialNumber = serialNumber
        self.category = category
        self.installDate = installDate
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.warrantyExpiry = warrantyExpiry
        self.notes = notes
        self.roomLocation = roomLocation
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - ApplianceCategory

enum ApplianceCategory: String, Codable, CaseIterable, Identifiable {
    case refrigerator
    case oven
    case dishwasher
    case washer = "washing_machine"
    case dryer
    case microwave
    case hvac = "hvac_indoor_unit"
    case waterHeater = "water_heater"
    case garageDoor = "garage_door_opener"
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .refrigerator: return "Refrigerator"
        case .oven: return "Oven"
        case .dishwasher: return "Dishwasher"
        case .washer: return "Washing Machine"
        case .dryer: return "Dryer"
        case .microwave: return "Microwave"
        case .hvac: return "HVAC"
        case .waterHeater: return "Water Heater"
        case .garageDoor: return "Garage Door"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .refrigerator: return "refrigerator.fill"
        case .oven: return "stove.fill"
        case .dishwasher: return "dishwasher.fill"
        case .washer: return "washer.fill"
        case .dryer: return "dryer.fill"
        case .microwave: return "microwave.fill"
        case .hvac: return "air.conditioner.horizontal.fill"
        case .waterHeater: return "water.heater"
        case .garageDoor: return "garage.closed"
        case .other: return "cube.box.fill"
        }
    }
}
