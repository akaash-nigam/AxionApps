//
//  DataStore.swift
//  SpatialMeetingPlatform
//
//  Local data persistence using SwiftData
//

import Foundation
import SwiftData

class DataStore: DataStoreProtocol {

    // In real implementation, this would use SwiftData's ModelContext
    // For this demonstration, we'll use a simple in-memory store

    private var meetings: [UUID: Meeting] = [:]

    // MARK: - DataStoreProtocol

    func save(_ meeting: Meeting) throws {
        meetings[meeting.id] = meeting
        print("Saved meeting: \(meeting.title)")
    }

    func fetch(id: UUID) throws -> Meeting? {
        return meetings[id]
    }

    func fetchAll(filter: MeetingFilter) throws -> [Meeting] {
        var results = Array(meetings.values)

        // Apply filters
        if let status = filter.status {
            results = results.filter { $0.status == status }
        }

        if let startDate = filter.startDate {
            results = results.filter { $0.scheduledStart >= startDate }
        }

        if let endDate = filter.endDate {
            results = results.filter { $0.scheduledStart <= endDate }
        }

        return results.sorted { $0.scheduledStart < $1.scheduledStart }
    }

    func delete(id: UUID) throws {
        meetings.removeValue(forKey: id)
        print("Deleted meeting: \(id)")
    }
}
