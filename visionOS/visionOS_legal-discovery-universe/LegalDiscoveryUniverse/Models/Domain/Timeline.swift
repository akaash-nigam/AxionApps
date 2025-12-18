//
//  Timeline.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Timeline {
    @Attribute(.unique) var id: UUID
    var name: String
    var timelineDescription: String
    var createdDate: Date
    var modifiedDate: Date

    @Relationship(deleteRule: .cascade) var events: [TimelineEvent] = []
    @Relationship(inverse: \LegalCase.timelines) var legalCase: LegalCase?

    init(
        id: UUID = UUID(),
        name: String,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.timelineDescription = description
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}

@Model
final class TimelineEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventDescription: String
    var eventDate: Date
    var endDate: Date?
    var importance: EventImportance

    // Visual properties
    var color: String = "#2196F3"
    var icon: String?

    // Associated data
    var documentIds: [UUID] = []
    var entityIds: [UUID] = []

    @Relationship(inverse: \Timeline.events) var timeline: Timeline?

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        eventDate: Date,
        importance: EventImportance = .normal
    ) {
        self.id = id
        self.title = title
        self.eventDescription = description
        self.eventDate = eventDate
        self.importance = importance
    }
}

enum EventImportance: String, Codable {
    case critical
    case high
    case normal
    case low
}
