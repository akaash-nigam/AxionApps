//
//  Safety.swift
//  Construction Site Manager
//
//  Safety monitoring models
//

import Foundation
import SwiftData
import simd

// MARK: - Danger Zone

/// Represents a hazardous area on the construction site
@Model
final class DangerZone {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: DangerType
    var severity: SafetySeverity
    var boundaryPoints: [SIMD3<Float>]  // 3D polygon vertices
    var isActive: Bool
    var warningDistance: Float  // Meters
    var restrictions: [String]
    var responsibleParty: String
    var startTime: Date?
    var endTime: Date?
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: DangerType,
        severity: SafetySeverity,
        boundaryPoints: [SIMD3<Float>],
        isActive: Bool = true,
        warningDistance: Float = 2.0,
        restrictions: [String] = [],
        responsibleParty: String,
        startTime: Date? = nil,
        endTime: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.severity = severity
        self.boundaryPoints = boundaryPoints
        self.isActive = isActive
        self.warningDistance = warningDistance
        self.restrictions = restrictions
        self.responsibleParty = responsibleParty
        self.startTime = startTime
        self.endTime = endTime
        self.createdDate = Date()
    }

    var isCurrentlyActive: Bool {
        guard isActive else { return false }

        let now = Date()

        if let start = startTime, now < start {
            return false
        }

        if let end = endTime, now > end {
            return false
        }

        return true
    }

    func containsPoint(_ point: SIMD3<Float>) -> Bool {
        // Simple 2D point-in-polygon test (XZ plane)
        // For production, use proper 3D containment test
        var inside = false
        let x = point.x
        let z = point.z

        var j = boundaryPoints.count - 1
        for i in 0..<boundaryPoints.count {
            let xi = boundaryPoints[i].x
            let zi = boundaryPoints[i].z
            let xj = boundaryPoints[j].x
            let zj = boundaryPoints[j].z

            if ((zi > z) != (zj > z)) &&
               (x < (xj - xi) * (z - zi) / (zj - zi) + xi) {
                inside.toggle()
            }
            j = i
        }

        return inside
    }

    func distanceToPoint(_ point: SIMD3<Float>) -> Float {
        // Simplified distance calculation
        // For production, calculate proper distance to polygon
        guard !boundaryPoints.isEmpty else { return .infinity }

        var minDistance: Float = .infinity
        for boundaryPoint in boundaryPoints {
            let distance = simd_distance(point, boundaryPoint)
            minDistance = min(minDistance, distance)
        }

        return minDistance
    }
}

// MARK: - Safety Alert

/// Represents a safety alert or violation
@Model
final class SafetyAlert {
    @Attribute(.unique) var id: UUID
    var type: SafetyAlertType
    var severity: SafetySeverity
    var message: String
    var location: SIMD3<Float>?
    var dangerZoneID: UUID?
    var workerID: String?
    var timestamp: Date
    var acknowledgedBy: String?
    var acknowledgedAt: Date?
    var resolved: Bool
    var resolvedAt: Date?
    var notes: String?

    init(
        id: UUID = UUID(),
        type: SafetyAlertType,
        severity: SafetySeverity,
        message: String,
        location: SIMD3<Float>? = nil,
        dangerZoneID: UUID? = nil,
        workerID: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.message = message
        self.location = location
        self.dangerZoneID = dangerZoneID
        self.workerID = workerID
        self.timestamp = timestamp
        self.resolved = false
    }

    var isAcknowledged: Bool {
        acknowledgedBy != nil
    }

    var responseTime: TimeInterval? {
        guard let ackTime = acknowledgedAt else { return nil }
        return ackTime.timeIntervalSince(timestamp)
    }
}

enum SafetyAlertType: String, Codable {
    case proximityViolation
    case ppeViolation
    case unauthorizedAccess
    case equipmentHazard
    case environmentalHazard
    case emergencyAlert

    var displayName: String {
        switch self {
        case .proximityViolation: return "Proximity Violation"
        case .ppeViolation: return "PPE Violation"
        case .unauthorizedAccess: return "Unauthorized Access"
        case .equipmentHazard: return "Equipment Hazard"
        case .environmentalHazard: return "Environmental Hazard"
        case .emergencyAlert: return "Emergency Alert"
        }
    }

    var icon: String {
        switch self {
        case .proximityViolation: return "figure.walk.circle"
        case .ppeViolation: return "person.badge.shield.checkmark"
        case .unauthorizedAccess: return "lock.shield"
        case .equipmentHazard: return "wrench.and.screwdriver"
        case .environmentalHazard: return "cloud.bolt"
        case .emergencyAlert: return "alarm.waves.left.and.right"
        }
    }
}

// MARK: - Safety Incident

/// Records a safety incident
@Model
final class SafetyIncident {
    @Attribute(.unique) var id: UUID
    var title: String
    var incidentDescription: String
    var severity: SafetySeverity
    var location: String
    var positionX: Float?
    var positionY: Float?
    var positionZ: Float?
    var involvedPersonnel: [String]
    var witnesses: [String]
    var timestamp: Date
    var reportedBy: String
    var reportedAt: Date
    var investigationStatus: InvestigationStatus
    var rootCause: String?
    var correctiveActions: [String]
    var photoURLs: [String]
    var documentURLs: [String]

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        severity: SafetySeverity,
        location: String,
        position: SIMD3<Float>? = nil,
        involvedPersonnel: [String] = [],
        witnesses: [String] = [],
        timestamp: Date = Date(),
        reportedBy: String,
        reportedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.incidentDescription = description
        self.severity = severity
        self.location = location
        self.involvedPersonnel = involvedPersonnel
        self.witnesses = witnesses
        self.timestamp = timestamp
        self.reportedBy = reportedBy
        self.reportedAt = reportedAt
        self.investigationStatus = .reported
        self.correctiveActions = []
        self.photoURLs = []
        self.documentURLs = []

        if let pos = position {
            self.positionX = pos.x
            self.positionY = pos.y
            self.positionZ = pos.z
        }
    }

    var position: SIMD3<Float>? {
        guard let x = positionX, let y = positionY, let z = positionZ else { return nil }
        return SIMD3<Float>(x, y, z)
    }
}

enum InvestigationStatus: String, Codable {
    case reported
    case investigating
    case completed
    case closed

    var displayName: String {
        switch self {
        case .reported: return "Reported"
        case .investigating: return "Investigating"
        case .completed: return "Completed"
        case .closed: return "Closed"
        }
    }
}

// MARK: - PPE Requirement

/// Personal Protective Equipment requirement for an area
struct PPERequirement: Codable, Identifiable, Equatable {
    var id: UUID
    var area: String
    var requiredEquipment: [PPEType]
    var isEnforced: Bool

    init(
        id: UUID = UUID(),
        area: String,
        requiredEquipment: [PPEType],
        isEnforced: Bool = true
    ) {
        self.id = id
        self.area = area
        self.requiredEquipment = requiredEquipment
        self.isEnforced = isEnforced
    }
}

enum PPEType: String, Codable, CaseIterable {
    case hardHat
    case safetyGlasses
    case safetyVest
    case steelToedBoots
    case gloves
    case respirator
    case hearingProtection
    case fallProtection

    var displayName: String {
        switch self {
        case .hardHat: return "Hard Hat"
        case .safetyGlasses: return "Safety Glasses"
        case .safetyVest: return "Safety Vest"
        case .steelToedBoots: return "Steel-Toed Boots"
        case .gloves: return "Gloves"
        case .respirator: return "Respirator"
        case .hearingProtection: return "Hearing Protection"
        case .fallProtection: return "Fall Protection"
        }
    }

    var icon: String {
        switch self {
        case .hardHat: return "shield.fill"
        case .safetyGlasses: return "eyeglasses"
        case .safetyVest: return "person.fill"
        case .steelToedBoots: return "shoeprints.fill"
        case .gloves: return "hand.raised.fill"
        case .respirator: return "lungs.fill"
        case .hearingProtection: return "ear.fill"
        case .fallProtection: return "figure.fall"
        }
    }
}
