//
//  CollaborationSession.swift
//  FieldServiceAR
//
//  Collaboration session model
//

import Foundation
import SwiftData

@Model
final class CollaborationSession {
    @Attribute(.unique) var id: UUID
    var jobId: UUID

    // Participants
    var fieldTechnicianId: UUID
    var fieldTechnicianName: String
    var remoteExpertId: UUID?
    var remoteExpertName: String?

    // Session timing
    var startTime: Date
    var endTime: Date?

    // Connection
    var connectionQuality: ConnectionQuality = .unknown

    // Content
    @Relationship(deleteRule: .cascade)
    var annotations: [SpatialAnnotation] = []

    var chatMessages: [String] = []

    // Recording
    var recordingFileName: String?
    var sessionSummary: String?

    init(
        id: UUID = UUID(),
        jobId: UUID,
        fieldTechnicianId: UUID,
        fieldTechnicianName: String,
        remoteExpertId: UUID? = nil,
        remoteExpertName: String? = nil
    ) {
        self.id = id
        self.jobId = jobId
        self.fieldTechnicianId = fieldTechnicianId
        self.fieldTechnicianName = fieldTechnicianName
        self.remoteExpertId = remoteExpertId
        self.remoteExpertName = remoteExpertName
        self.startTime = Date()
    }

    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }

    var isActive: Bool {
        endTime == nil
    }

    func end(summary: String? = nil) {
        endTime = Date()
        sessionSummary = summary
    }
}

// Spatial Annotation
@Model
final class SpatialAnnotation {
    @Attribute(.unique) var id: UUID
    var sessionId: UUID
    var authorId: UUID
    var authorName: String
    var timestamp: Date

    // Spatial data
    var anchorTransformData: Data?
    var annotationType: AnnotationType

    // Visual data
    var strokePathData: Data? // Encoded array of SIMD3<Float>
    var color: String // Hex color
    var text: String?

    // Voice note
    var voiceNoteFileName: String?

    // Lifecycle
    var isPinned: Bool = false
    var expiresAt: Date?

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        authorId: UUID,
        authorName: String,
        annotationType: AnnotationType,
        color: String = "#007AFF"
    ) {
        self.id = id
        self.sessionId = sessionId
        self.authorId = authorId
        self.authorName = authorName
        self.timestamp = Date()
        self.annotationType = annotationType
        self.color = color

        // Default expiration: 30 seconds
        if !isPinned {
            self.expiresAt = Date().addingTimeInterval(30)
        }
    }

    var isExpired: Bool {
        guard let expiry = expiresAt else { return false }
        return Date() > expiry
    }

    func pin() {
        isPinned = true
        expiresAt = nil
    }
}

// Annotation Type
enum AnnotationType: String, Codable {
    case arrow = "Arrow"
    case circle = "Circle"
    case freehand = "Freehand"
    case text = "Text"
    case pointer = "Pointer"
}

// Connection Quality
enum ConnectionQuality: String, Codable {
    case unknown = "Unknown"
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"

    var color: String {
        switch self {
        case .unknown: return "#8E8E93"
        case .poor: return "#FF3B30"
        case .fair: return "#FF9500"
        case .good: return "#FFD700"
        case .excellent: return "#34C759"
        }
    }
}
