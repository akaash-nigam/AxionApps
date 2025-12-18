//
//  Infrastructure.swift
//  SmartCityCommandPlatform
//
//  Infrastructure system models
//

import SwiftData
import Foundation
import CoreLocation

// MARK: - Infrastructure

@Model
final class Infrastructure {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: InfrastructureType
    var status: OperationalStatus
    var health: Double // 0-100%
    var capacity: Double
    var currentLoad: Double

    @Relationship var city: City?
    @Relationship(deleteRule: .cascade) var components: [InfrastructureComponent]
    @Relationship(deleteRule: .cascade) var sensors: [IoTSensor]

    var lastMaintenance: Date
    var nextMaintenance: Date
    var criticality: CriticalityLevel

    init(name: String, type: InfrastructureType, capacity: Double, criticality: CriticalityLevel) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.status = .operational
        self.health = 100.0
        self.capacity = capacity
        self.currentLoad = 0
        self.components = []
        self.sensors = []
        self.lastMaintenance = Date()
        self.nextMaintenance = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        self.criticality = criticality
    }
}

enum CriticalityLevel: String, Codable {
    case low
    case medium
    case high
    case critical
}

// MARK: - Infrastructure Component

@Model
final class InfrastructureComponent {
    @Attribute(.unique) var id: UUID
    var name: String
    var componentType: String
    var location: CLLocationCoordinate2D
    var status: OperationalStatus
    var installDate: Date
    var lifespan: Int // years

    @Relationship var infrastructure: Infrastructure?

    var needsReplacement: Bool {
        let age = Calendar.current.dateComponents([.year], from: installDate, to: Date()).year ?? 0
        return age >= lifespan
    }

    init(name: String, componentType: String, location: CLLocationCoordinate2D, status: OperationalStatus = .operational, installDate: Date = Date(), lifespan: Int = 20) {
        self.id = UUID()
        self.name = name
        self.componentType = componentType
        self.location = location
        self.status = status
        self.installDate = installDate
        self.lifespan = lifespan
    }
}
