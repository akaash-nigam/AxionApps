//
//  Activity.swift
//  SpatialCRM
//
//  Activity/Task data model
//

import Foundation
import SwiftData

@Model
final class Activity {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var type: ActivityType
    var subject: String
    var activityDescription: String?
    var scheduledAt: Date?
    var completedAt: Date?
    var duration: TimeInterval?
    var outcome: ActivityOutcome?

    // AI Insights
    var sentiment: Sentiment?
    var keyTopics: [String]
    var competitorMentions: [String]
    var transcription: String?

    // Relationships
    var account: Account?
    var contact: Contact?
    var opportunity: Opportunity?
    var owner: SalesRep?

    // Metadata
    var createdAt: Date
    var externalId: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        type: ActivityType,
        subject: String,
        description: String? = nil,
        scheduledAt: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.subject = subject
        self.activityDescription = description
        self.scheduledAt = scheduledAt

        // Initialize AI fields
        self.keyTopics = []
        self.competitorMentions = []

        // Set timestamp
        self.createdAt = Date()
    }

    // MARK: - Methods

    func complete(outcome: ActivityOutcome) {
        self.completedAt = Date()
        self.outcome = outcome

        if let scheduledAt = scheduledAt {
            self.duration = Date().timeIntervalSince(scheduledAt)
        }
    }

    // MARK: - Computed Properties

    var isCompleted: Bool {
        completedAt != nil
    }

    var isOverdue: Bool {
        guard let scheduled = scheduledAt, !isCompleted else { return false }
        return scheduled < Date()
    }

    var formattedDuration: String {
        guard let duration = duration else { return "—" }
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            return "\(hours) hr \(minutes % 60) min"
        }
    }
}

// MARK: - Supporting Types

enum ActivityType: String, Codable, CaseIterable {
    case call
    case meeting
    case email
    case task
    case note
    case demo
    case presentation
    case proposal

    var icon: String {
        switch self {
        case .call: return "phone.fill"
        case .meeting: return "person.2.fill"
        case .email: return "envelope.fill"
        case .task: return "checkmark.circle.fill"
        case .note: return "note.text"
        case .demo: return "play.rectangle.fill"
        case .presentation: return "rectangle.on.rectangle.angled"
        case .proposal: return "doc.text.fill"
        }
    }
}

enum ActivityOutcome: String, Codable {
    case successful
    case unsuccessful
    case rescheduled
    case noAnswer
    case leftMessage
}

enum Sentiment: String, Codable {
    case veryPositive
    case positive
    case neutral
    case negative
    case veryNegative

    var emoji: String {
        switch self {
        case .veryPositive: return "😄"
        case .positive: return "🙂"
        case .neutral: return "😐"
        case .negative: return "😟"
        case .veryNegative: return "😞"
        }
    }

    var score: Double {
        switch self {
        case .veryPositive: return 1.0
        case .positive: return 0.5
        case .neutral: return 0.0
        case .negative: return -0.5
        case .veryNegative: return -1.0
        }
    }
}

// MARK: - Sample Data

extension Activity {
    static var sample: Activity {
        let activity = Activity(
            type: .meeting,
            subject: "Product Demo with Acme Corp",
            description: "Demonstrate new features and discuss implementation timeline",
            scheduledAt: Date()
        )
        activity.sentiment = .positive
        activity.keyTopics = ["Implementation", "Timeline", "Pricing"]
        return activity
    }

    static var samples: [Activity] {
        [
            Activity(type: .call, subject: "Follow-up call with John", scheduledAt: Date().addingTimeInterval(-3600)),
            Activity(type: .meeting, subject: "Product Demo", scheduledAt: Date().addingTimeInterval(7200)),
            Activity(type: .email, subject: "Send proposal", scheduledAt: Date().addingTimeInterval(86400)),
            Activity(type: .task, subject: "Prepare presentation", scheduledAt: Date().addingTimeInterval(172800)),
            Activity(type: .demo, subject: "Technical demo for CTO", scheduledAt: Date().addingTimeInterval(259200))
        ]
    }
}
