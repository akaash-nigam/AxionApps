//
//  ServiceJob.swift
//  FieldServiceAR
//
//  Service job model
//

import Foundation
import SwiftData

@Model
final class ServiceJob {
    @Attribute(.unique) var id: UUID
    var workOrderNumber: String
    var title: String
    var jobDescription: String?

    // Status
    var status: JobStatus = .scheduled
    var priority: JobPriority = .medium

    // Scheduling
    var scheduledDate: Date
    var estimatedDuration: TimeInterval
    var actualStartTime: Date?
    var actualEndTime: Date?

    // Location
    var customerName: String
    var siteName: String
    var address: String
    var latitude: Double?
    var longitude: Double?

    // Assignment
    var assignedTechnicianId: UUID?
    var assignedTechnicianName: String?

    // Equipment
    var equipmentId: UUID
    var equipmentManufacturer: String
    var equipmentModel: String

    // Procedures and Parts
    @Relationship(deleteRule: .cascade)
    var procedures: [RepairProcedure] = []

    var requiredPartNumbers: [String] = []

    // Offline sync
    var needsUpload: Bool = false
    var lastSyncDate: Date?

    // Evidence
    @Relationship(deleteRule: .cascade)
    var capturedEvidence: [MediaEvidence] = []

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        workOrderNumber: String,
        title: String,
        jobDescription: String? = nil,
        scheduledDate: Date,
        estimatedDuration: TimeInterval,
        customerName: String,
        siteName: String,
        address: String,
        equipmentId: UUID,
        equipmentManufacturer: String,
        equipmentModel: String
    ) {
        self.id = id
        self.workOrderNumber = workOrderNumber
        self.title = title
        self.jobDescription = jobDescription
        self.scheduledDate = scheduledDate
        self.estimatedDuration = estimatedDuration
        self.customerName = customerName
        self.siteName = siteName
        self.address = address
        self.equipmentId = equipmentId
        self.equipmentManufacturer = equipmentManufacturer
        self.equipmentModel = equipmentModel
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }

    var isUpcoming: Bool {
        scheduledDate > Date()
    }

    var isOverdue: Bool {
        scheduledDate < Date() && status != .completed
    }

    var actualDuration: TimeInterval? {
        guard let start = actualStartTime, let end = actualEndTime else {
            return nil
        }
        return end.timeIntervalSince(start)
    }

    func start() {
        status = .inProgress
        actualStartTime = Date()
        updatedAt = Date()
    }

    func complete() {
        status = .completed
        actualEndTime = Date()
        needsUpload = true
        updatedAt = Date()
    }
}

// Job Status
enum JobStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
    case cancelled = "Cancelled"

    var color: String {
        switch self {
        case .scheduled: return "#8E8E93"
        case .inProgress: return "#007AFF"
        case .onHold: return "#FFD700"
        case .completed: return "#34C759"
        case .cancelled: return "#FF3B30"
        }
    }
}

// Job Priority
enum JobPriority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var order: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }
}

// Media Evidence
@Model
final class MediaEvidence {
    @Attribute(.unique) var id: UUID
    var type: MediaType
    var fileName: String
    var capturedAt: Date
    var stepId: UUID?
    var notes: String?

    init(
        id: UUID = UUID(),
        type: MediaType,
        fileName: String,
        capturedAt: Date = Date(),
        stepId: UUID? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.capturedAt = capturedAt
        self.stepId = stepId
        self.notes = notes
    }
}

enum MediaType: String, Codable {
    case photo = "Photo"
    case video = "Video"
    case audio = "Audio"
}
