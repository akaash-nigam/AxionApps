//
//  CalendarService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import EventKit

/// Service for calendar integration
@MainActor
class CalendarService {
    static let shared = CalendarService()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Authorization
    /// Request calendar access
    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    // MARK: - Fetch Events
    /// Fetch upcoming events
    func fetchUpcomingEvents(days: Int = 7) async throws -> [CalendarEvent] {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)

        return events.map { event in
            CalendarEvent(
                title: event.title ?? "Untitled",
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                isAllDay: event.isAllDay,
                suggestedOccasion: suggestOccasion(for: event)
            )
        }
    }

    // MARK: - Event Analysis
    private func suggestOccasion(for event: EKEvent) -> OccasionType {
        let title = event.title?.lowercased() ?? ""

        if title.contains("interview") || title.contains("meeting") {
            return .interview
        } else if title.contains("presentation") {
            return .workPresentation
        } else if title.contains("work") || title.contains("office") {
            return .work
        } else if title.contains("party") || title.contains("celebration") {
            return .party
        } else if title.contains("wedding") {
            return .wedding
        } else if title.contains("date") || title.contains("dinner") {
            return .dateNight
        } else if title.contains("gym") || title.contains("workout") {
            return .gym
        } else if title.contains("brunch") || title.contains("lunch") {
            return .brunch
        } else if event.location?.lowercased().contains("office") ?? false {
            return .work
        }

        return .casual
    }
}

// MARK: - Calendar Event Model
struct CalendarEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let isAllDay: Bool
    let suggestedOccasion: OccasionType

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }
}
