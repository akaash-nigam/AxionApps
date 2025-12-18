//
//  City.swift
//  SmartCityCommandPlatform
//
//  Core city data models
//

import SwiftData
import Foundation
import CoreLocation

// MARK: - City

@Model
final class City {
    @Attribute(.unique) var id: UUID
    var name: String
    var population: Int
    var area: Double // sq km
    var boundaries: [CLLocationCoordinate2D]
    var centerCoordinate: CLLocationCoordinate2D

    @Relationship(deleteRule: .cascade) var districts: [District]
    @Relationship(deleteRule: .cascade) var infrastructure: [Infrastructure]
    @Relationship(deleteRule: .cascade) var sensors: [IoTSensor]

    var lastUpdated: Date
    var metadata: [String: String]

    init(name: String, population: Int, area: Double, centerCoordinate: CLLocationCoordinate2D) {
        self.id = UUID()
        self.name = name
        self.population = population
        self.area = area
        self.centerCoordinate = centerCoordinate
        self.lastUpdated = Date()
        self.districts = []
        self.infrastructure = []
        self.sensors = []
        self.boundaries = []
        self.metadata = [:]
    }
}

// MARK: - District

@Model
final class District {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: DistrictType
    var boundaries: [CLLocationCoordinate2D]
    var population: Int
    var area: Double

    @Relationship var city: City?
    @Relationship(deleteRule: .cascade) var buildings: [Building]

    init(name: String, type: DistrictType, population: Int, area: Double) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.population = population
        self.area = area
        self.boundaries = []
        self.buildings = []
    }
}

enum DistrictType: String, Codable {
    case residential
    case commercial
    case industrial
    case mixed
    case government
    case park
}

// MARK: - Building

@Model
final class Building {
    @Attribute(.unique) var id: UUID
    var name: String?
    var address: String
    var location: CLLocationCoordinate2D
    var height: Double // meters
    var floors: Int
    var type: BuildingType
    var occupancy: Int

    @Relationship var district: District?
    @Relationship(deleteRule: .cascade) var utilities: [UtilityConnection]

    var model3DAsset: String? // Reference to USDZ model

    init(address: String, location: CLLocationCoordinate2D, height: Double, type: BuildingType) {
        self.id = UUID()
        self.address = address
        self.location = location
        self.height = height
        self.floors = Int(height / 3.5) // Estimate
        self.type = type
        self.occupancy = 0
        self.utilities = []
    }
}

enum BuildingType: String, Codable {
    case residential
    case commercial
    case industrial
    case government
    case hospital
    case school
    case emergency
}

// MARK: - Utility Connection

@Model
final class UtilityConnection {
    @Attribute(.unique) var id: UUID
    var utilityType: InfrastructureType
    var serviceLevel: String
    var status: OperationalStatus

    @Relationship var building: Building?

    init(utilityType: InfrastructureType, serviceLevel: String, status: OperationalStatus = .operational) {
        self.id = UUID()
        self.utilityType = utilityType
        self.serviceLevel = serviceLevel
        self.status = status
    }
}

// MARK: - Supporting Types

enum InfrastructureType: String, Codable {
    case water
    case power
    case gas
    case telecommunications
    case sewage
    case stormwater
    case roads
    case bridges
    case tunnels
}

enum OperationalStatus: String, Codable {
    case operational
    case degraded
    case maintenance
    case failure
    case emergency

    var color: String {
        switch self {
        case .operational: return "green"
        case .degraded: return "yellow"
        case .maintenance: return "blue"
        case .failure: return "red"
        case .emergency: return "red"
        }
    }
}
