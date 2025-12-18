//
//  DateExtensions.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation

extension Date {
    /// Returns a formatted string for legal documents
    var legalDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Returns a formatted string with time for timestamps
    var legalTimestampFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns relative date description (e.g., "2 days ago")
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Checks if date is within a given range
    func isWithin(_ range: DateRange) -> Bool {
        return self >= range.start && self <= range.end
    }

    /// Returns the start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Creates a date from legal document format (MM/DD/YYYY)
    static func fromLegalFormat(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: string)
    }

    /// Returns ISO 8601 string representation
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}

extension DateRange {
    /// Common legal date ranges
    static func last30Days() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
        return DateRange(start: start, end: end)
    }

    static func last90Days() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -90, to: end) ?? end
        return DateRange(start: start, end: end)
    }

    static func lastYear() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .year, value: -1, to: end) ?? end
        return DateRange(start: start, end: end)
    }

    static func custom(from: Date, to: Date) -> DateRange {
        DateRange(start: from, end: to)
    }

    /// Check if range contains a date
    func contains(_ date: Date) -> Bool {
        return date >= start && date <= end
    }

    /// Duration in days
    var durationInDays: Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
}
