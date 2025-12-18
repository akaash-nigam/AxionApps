//
//  CitizenServices.swift
//  SmartCityCommandPlatform
//
//  Citizen request and service models
//

import SwiftData
import Foundation
import CoreLocation

// MARK: - Citizen Request

@Model
final class CitizenRequest {
    @Attribute(.unique) var id: UUID
    var requestNumber: String
    var type: RequestType
    var category: String
    var priority: RequestPriority
    var status: RequestStatus

    var description: String
    var location: CLLocationCoordinate2D?
    var address: String?

    var submittedAt: Date
    var assignedAt: Date?
    var completedAt: Date?

    var assignedDepartment: String?
    var assignedStaff: String?

    @Relationship(deleteRule: .cascade) var updates: [RequestUpdate]

    init(type: RequestType, category: String, description: String, priority: RequestPriority) {
        self.id = UUID()
        self.requestNumber = "REQ-\(Int(Date().timeIntervalSince1970))"
        self.type = type
        self.category = category
        self.priority = priority
        self.status = .submitted
        self.description = description
        self.submittedAt = Date()
        self.updates = []
    }
}

enum RequestType: String, Codable {
    case complaint
    case request
    case inquiry
    case report
    case permit
}

enum RequestPriority: String, Codable {
    case low
    case normal
    case high
    case urgent
}

enum RequestStatus: String, Codable {
    case submitted
    case assigned
    case inProgress
    case resolved
    case closed
}

// MARK: - Request Update

@Model
final class RequestUpdate {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var message: String
    var updatedBy: String

    @Relationship var request: CitizenRequest?

    init(message: String, updatedBy: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.message = message
        self.updatedBy = updatedBy
    }
}
