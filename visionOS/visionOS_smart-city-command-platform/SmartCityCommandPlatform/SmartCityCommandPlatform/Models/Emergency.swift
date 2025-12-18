//
//  Emergency.swift
//  SmartCityCommandPlatform
//
//  Emergency incident and response models
//

import SwiftData
import Foundation
import CoreLocation

// MARK: - Emergency Incident

@Model
final class EmergencyIncident {
    @Attribute(.unique) var id: UUID
    var incidentNumber: String
    var type: IncidentType
    var severity: IncidentSeverity
    var status: IncidentStatus

    var location: CLLocationCoordinate2D
    var address: String
    var description: String

    var reportedAt: Date
    var dispatchedAt: Date?
    var resolvedAt: Date?

    @Relationship(deleteRule: .cascade) var responses: [EmergencyResponse]
    @Relationship(deleteRule: .cascade) var updates: [IncidentUpdate]

    var affectedCitizens: Int
    var estimatedImpact: String

    init(type: IncidentType, severity: IncidentSeverity, location: CLLocationCoordinate2D, description: String) {
        self.id = UUID()
        self.incidentNumber = "INC-\(Int(Date().timeIntervalSince1970))"
        self.type = type
        self.severity = severity
        self.status = .reported
        self.location = location
        self.address = ""
        self.description = description
        self.reportedAt = Date()
        self.responses = []
        self.updates = []
        self.affectedCitizens = 0
        self.estimatedImpact = ""
    }
}

enum IncidentType: String, Codable {
    case fire
    case medical
    case crime
    case accident
    case infrastructure
    case natural
    case hazmat
    case civil
}

enum IncidentSeverity: String, Codable {
    case low
    case medium
    case high
    case critical
    case catastrophic
}

enum IncidentStatus: String, Codable {
    case reported
    case dispatched
    case responding
    case onScene
    case contained
    case resolved
    case closed
}

// MARK: - Emergency Response

@Model
final class EmergencyResponse {
    @Attribute(.unique) var id: UUID
    var unitId: String
    var unitType: EmergencyUnitType
    var status: ResponseStatus

    var dispatchedAt: Date
    var arrivedAt: Date?
    var clearedAt: Date?

    var currentLocation: CLLocationCoordinate2D?
    var route: [CLLocationCoordinate2D]

    @Relationship var incident: EmergencyIncident?

    init(unitId: String, unitType: EmergencyUnitType) {
        self.id = UUID()
        self.unitId = unitId
        self.unitType = unitType
        self.status = .dispatched
        self.dispatchedAt = Date()
        self.route = []
    }
}

enum EmergencyUnitType: String, Codable {
    case fire
    case police
    case ambulance
    case hazmat
    case rescue
    case utility
}

enum ResponseStatus: String, Codable {
    case dispatched
    case enRoute
    case onScene
    case returning
    case available
}

// MARK: - Incident Update

@Model
final class IncidentUpdate {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var message: String
    var updatedBy: String

    @Relationship var incident: EmergencyIncident?

    init(message: String, updatedBy: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.message = message
        self.updatedBy = updatedBy
    }
}
