//
//  Timeline.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import Foundation
import SwiftData

@Model
final class Timeline {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var title: String
    var timelineDescription: String?

    @Relationship(deleteRule: .cascade) var events: [TimelineEvent]

    var startDate: Date
    var endDate: Date
    var spatialVisualizationType: TimelineVisualization

    var createdDate: Date
    var lastModified: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        startDate: Date = Date(),
        endDate: Date = Date(),
        visualizationType: TimelineVisualization = .river
    ) {
        self.id = id
        self.title = title
        self.timelineDescription = description
        self.startDate = startDate
        self.endDate = endDate
        self.spatialVisualizationType = visualizationType
        self.events = []
        self.createdDate = Date()
        self.lastModified = Date()
    }

    // MARK: - Computed Properties

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var eventCount: Int {
        events.count
    }

    var sortedEvents: [TimelineEvent] {
        events.sorted { $0.eventDate < $1.eventDate }
    }

    var criticalEvents: [TimelineEvent] {
        events.filter { $0.importance > 0.8 }
    }

    // MARK: - Methods

    func addEvent(_ event: TimelineEvent) {
        events.append(event)

        // Update timeline date range if needed
        if event.eventDate < startDate {
            startDate = event.eventDate
        }
        if event.eventDate > endDate {
            endDate = event.eventDate
        }

        lastModified = Date()
    }

    func removeEvent(_ event: TimelineEvent) {
        events.removeAll { $0.id == event.id }
        lastModified = Date()
    }

    func updateDateRange() {
        guard !events.isEmpty else { return }

        let dates = events.map { $0.eventDate }
        startDate = dates.min() ?? Date()
        endDate = dates.max() ?? Date()
    }
}

// MARK: - Timeline Event

@Model
final class TimelineEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventDescription: String
    var eventDate: Date
    var eventType: EventType
    var importance: Double

    @Relationship var relatedDocuments: [LegalDocument]
    @Relationship var involvedEntities: [LegalEntity]

    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?

    var createdDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        eventDate: Date,
        type: EventType = .general,
        importance: Double = 0.5
    ) {
        self.id = id
        self.title = title
        self.eventDescription = description
        self.eventDate = eventDate
        self.eventType = type
        self.importance = max(0.0, min(1.0, importance))
        self.relatedDocuments = []
        self.involvedEntities = []
        self.createdDate = Date()
    }

    var spatialPosition: SIMD3<Float>? {
        get {
            guard let x = spatialPositionX,
                  let y = spatialPositionY,
                  let z = spatialPositionZ else {
                return nil
            }
            return SIMD3<Float>(x, y, z)
        }
        set {
            if let position = newValue {
                spatialPositionX = position.x
                spatialPositionY = position.y
                spatialPositionZ = position.z
            } else {
                spatialPositionX = nil
                spatialPositionY = nil
                spatialPositionZ = nil
            }
        }
    }

    var isCritical: Bool {
        importance > 0.8
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: eventDate)
    }
}

// MARK: - Supporting Types

enum TimelineVisualization: String, Codable {
    case river = "River"
    case linear = "Linear"
    case radial = "Radial"
    case layered = "Layered"

    var description: String {
        switch self {
        case .river:
            return "Events flow like a river from past to future"
        case .linear:
            return "Events displayed on a linear timeline"
        case .radial:
            return "Events arranged in a circular pattern"
        case .layered:
            return "Events shown in parallel tracks/layers"
        }
    }
}

enum EventType: String, Codable {
    case general = "General"
    case documentCreated = "Document Created"
    case documentSent = "Document Sent"
    case documentSigned = "Document Signed"
    case meeting = "Meeting"
    case phoneCall = "Phone Call"
    case email = "Email"
    case transaction = "Transaction"
    case deadline = "Deadline"
    case filing = "Court Filing"
    case hearing = "Hearing"
    case deposition = "Deposition"
    case discovery = "Discovery Event"
    case settlement = "Settlement"
    case critical = "Critical Event"

    var iconName: String {
        switch self {
        case .general: return "circle.fill"
        case .documentCreated: return "doc.fill"
        case .documentSent: return "paperplane.fill"
        case .documentSigned: return "signature"
        case .meeting: return "person.2.fill"
        case .phoneCall: return "phone.fill"
        case .email: return "envelope.fill"
        case .transaction: return "dollarsign.circle.fill"
        case .deadline: return "alarm.fill"
        case .filing: return "folder.fill"
        case .hearing: return "building.columns.fill"
        case .deposition: return "mic.fill"
        case .discovery: return "magnifyingglass"
        case .settlement: return "handshake.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }

    var color: String {
        switch self {
        case .general: return "gray"
        case .documentCreated: return "blue"
        case .documentSent: return "cyan"
        case .documentSigned: return "green"
        case .meeting: return "purple"
        case .phoneCall: return "blue"
        case .email: return "green"
        case .transaction: return "green"
        case .deadline: return "orange"
        case .filing: return "brown"
        case .hearing: return "purple"
        case .deposition: return "indigo"
        case .discovery: return "blue"
        case .settlement: return "green"
        case .critical: return "red"
        }
    }

    var size: EventSize {
        switch self {
        case .critical, .settlement, .hearing:
            return .large
        case .deadline, .filing, .deposition:
            return .medium
        default:
            return .small
        }
    }
}

enum EventSize {
    case small  // 30pt
    case medium // 60pt
    case large  // 100pt

    var pointSize: Float {
        switch self {
        case .small: return 30
        case .medium: return 60
        case .large: return 100
        }
    }
}
