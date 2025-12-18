//
//  Date+Extensions.swift
//  CorporateUniversity
//
//  Utility extensions for Date manipulation and formatting
//

import Foundation

extension Date {
    /// Returns a human-readable "time ago" string
    /// Examples: "2 hours ago", "3 days ago", "Just now"
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: self, to: now)

        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }

        if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        }

        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        }

        if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        }

        if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        }

        if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        }

        return "Just now"
    }

    /// Format date with a specific style
    func formatted(style: DateFormatStyle) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current

        switch style {
        case .short:
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        case .medium:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        case .long:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        case .full:
            formatter.dateStyle = .full
            formatter.timeStyle = .none
        case .shortWithTime:
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        case .mediumWithTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        case .custom(let format):
            formatter.dateFormat = format
        }

        return formatter.string(from: self)
    }

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Check if date is this week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Check if date is this month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Check if date is this year
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    /// Check if date is a weekend
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }

    /// Get the start of the day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Get the end of the day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Get the start of the week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Get the end of the week
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek) ?? self
    }

    /// Get the start of the month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Get the end of the month
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    /// Get the start of the year
    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Get the end of the year
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfYear) ?? self
    }

    /// Add days to the date
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Add weeks to the date
    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    /// Add months to the date
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Add years to the date
    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }

    /// Get day of week (1 = Sunday, 7 = Saturday)
    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// Get day of month (1-31)
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Get month (1-12)
    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    /// Get year
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Get hour (0-23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    /// Get minute (0-59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    /// Get friendly month name
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    /// Get short month name
    var shortMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }

    /// Get day name (Monday, Tuesday, etc.)
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    /// Get short day name (Mon, Tue, etc.)
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    /// Calculate days between two dates
    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: date.startOfDay)
        return abs(components.day ?? 0)
    }

    /// Calculate hours between two dates
    func hoursBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: self, to: date)
        return abs(components.hour ?? 0)
    }

    /// Calculate minutes between two dates
    func minutesBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: self, to: date)
        return abs(components.minute ?? 0)
    }

    /// Check if date is between two other dates
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        return (startDate...endDate).contains(self)
    }

    /// Get age from birthdate
    var age: Int {
        Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }

    /// Convert to ISO 8601 string
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

    /// Create date from ISO 8601 string
    static func from(iso8601String: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: iso8601String)
    }

    /// Create date from string with format
    static func from(string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

/// Date formatting styles
enum DateFormatStyle {
    case short              // 1/1/24
    case medium             // Jan 1, 2024
    case long               // January 1, 2024
    case full               // Monday, January 1, 2024
    case shortWithTime      // 1/1/24, 3:30 PM
    case mediumWithTime     // Jan 1, 2024, 3:30 PM
    case custom(String)     // Custom format string
}

// MARK: - Convenience Initializers

extension Date {
    /// Create date from components
    init?(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second

        guard let date = Calendar.current.date(from: components) else {
            return nil
        }
        self = date
    }
}

// MARK: - Time Intervals

extension Date {
    /// Seconds since this date
    var secondsSince: TimeInterval {
        Date().timeIntervalSince(self)
    }

    /// Minutes since this date
    var minutesSince: Double {
        secondsSince / 60
    }

    /// Hours since this date
    var hoursSince: Double {
        secondsSince / 3600
    }

    /// Days since this date
    var daysSince: Double {
        secondsSince / 86400
    }
}
