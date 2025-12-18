//
//  CollaborationSession.swift
//  SpatialCRM
//
//  Collaboration session data model for multi-user features
//

import Foundation
import SwiftData

@Model
final class CollaborationSession {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var type: SessionType
    var startedAt: Date
    var endedAt: Date?

    // Participants
    @Relationship(deleteRule: .nullify) var participants: [SalesRep]

    // Annotations and shared state
    @Relationship(deleteRule: .cascade) var annotations: [Annotation]
    var sharedViewStateData: Data?  // Encoded SharedViewState

    // Metadata
    var createdBy: SalesRep?
    var isActive: Bool

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        type: SessionType,
        createdBy: SalesRep? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.startedAt = Date()
        self.createdBy = createdBy
        self.isActive = true

        // Initialize relationships
        self.participants = []
        self.annotations = []
    }

    // MARK: - Methods

    func end() {
        endedAt = Date()
        isActive = false
    }

    func addParticipant(_ rep: SalesRep) {
        if !participants.contains(where: { $0.id == rep.id }) {
            participants.append(rep)
        }
    }

    func removeParticipant(_ rep: SalesRep) {
        participants.removeAll { $0.id == rep.id }
    }

    // MARK: - Computed Properties

    var duration: TimeInterval? {
        guard let ended = endedAt else { return nil }
        return ended.timeIntervalSince(startedAt)
    }

    var sharedViewState: SharedViewState? {
        get {
            guard let data = sharedViewStateData else { return nil }
            return try? JSONDecoder().decode(SharedViewState.self, from: data)
        }
        set {
            sharedViewStateData = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - Annotation Model

@Model
final class Annotation {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var text: String
    var positionX: Float
    var positionY: Float
    var positionZ: Float
    var colorHex: String
    var createdBy: SalesRep?
    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        text: String,
        position: SIMD3<Float>,
        color: String = "#FF9500",
        createdBy: SalesRep? = nil
    ) {
        self.id = id
        self.text = text
        self.positionX = position.x
        self.positionY = position.y
        self.positionZ = position.z
        self.colorHex = color
        self.createdBy = createdBy
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    var position: SIMD3<Float> {
        get { SIMD3(positionX, positionY, positionZ) }
        set {
            positionX = newValue.x
            positionY = newValue.y
            positionZ = newValue.z
        }
    }
}

// MARK: - Supporting Types

enum SessionType: String, Codable {
    case dealWarRoom
    case accountPlanning
    case territoryReview
    case coachingSession
    case forecastReview

    var displayName: String {
        switch self {
        case .dealWarRoom: return "Deal War Room"
        case .accountPlanning: return "Account Planning"
        case .territoryReview: return "Territory Review"
        case .coachingSession: return "Coaching Session"
        case .forecastReview: return "Forecast Review"
        }
    }

    var icon: String {
        switch self {
        case .dealWarRoom: return "target"
        case .accountPlanning: return "building.2"
        case .territoryReview: return "map"
        case .coachingSession: return "person.2"
        case .forecastReview: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct SharedViewState: Codable {
    var viewType: String
    var selectedEntityId: UUID?
    var cameraPosition: SIMD3<Float>
    var cameraRotation: SIMD3<Float>
    var zoomLevel: Float
    var filters: [String: String]

    init(
        viewType: String = "dashboard",
        selectedEntityId: UUID? = nil,
        cameraPosition: SIMD3<Float> = SIMD3(0, 0, 3),
        cameraRotation: SIMD3<Float> = SIMD3(0, 0, 0),
        zoomLevel: Float = 1.0,
        filters: [String: String] = [:]
    ) {
        self.viewType = viewType
        self.selectedEntityId = selectedEntityId
        self.cameraPosition = cameraPosition
        self.cameraRotation = cameraRotation
        self.zoomLevel = zoomLevel
        self.filters = filters
    }
}

// MARK: - Sample Data

extension CollaborationSession {
    static var sample: CollaborationSession {
        CollaborationSession(
            name: "Acme Corp Deal Review",
            type: .dealWarRoom
        )
    }
}
