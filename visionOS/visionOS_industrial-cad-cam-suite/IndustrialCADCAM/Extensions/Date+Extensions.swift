import Foundation

/// Extensions for Date to support formatting and common operations
public extension Date {

    // MARK: - Formatting

    /// Format date with specified style
    /// - Parameters:
    ///   - dateStyle: Date style
    ///   - timeStyle: Time style
    /// - Returns: Formatted string
    func formatted(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }

    /// Format as short date (MM/DD/YYYY)
    var shortDateString: String {
        return formatted(dateStyle: .short, timeStyle: .none)
    }

    /// Format as medium date (Mon DD, YYYY)
    var mediumDateString: String {
        return formatted(dateStyle: .medium, timeStyle: .none)
    }

    /// Format as long date (Month DD, YYYY)
    var longDateString: String {
        return formatted(dateStyle: .long, timeStyle: .none)
    }

    /// Format as full date and time
    var fullDateTimeString: String {
        return formatted(dateStyle: .full, timeStyle: .medium)
    }

    /// Format as time only
    var timeString: String {
        return formatted(dateStyle: .none, timeStyle: .short)
    }

    /// Format with custom format
    /// - Parameter format: Custom format string (e.g., "yyyy-MM-dd")
    /// - Returns: Formatted string
    func formatted(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// Format as ISO 8601 string
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

    /// Format for file names (safe characters only)
    var filenameSafeString: String {
        return formatted(format: "yyyy-MM-dd_HH-mm-ss")
    }

    // MARK: - Relative Formatting

    /// Format as relative time (e.g., "2 hours ago", "in 3 days")
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format as short relative time (e.g., "2h ago")
    var shortRelativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    // MARK: - Components

    /// Get year component
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    /// Get month component (1-12)
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    /// Get day component
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    /// Get hour component (0-23)
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }

    /// Get minute component (0-59)
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }

    /// Get second component (0-59)
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }

    /// Get weekday (1 = Sunday, 7 = Saturday)
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }

    /// Get weekday name
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    /// Get month name
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    // MARK: - Comparisons

    /// Check if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    /// Check if date is tomorrow
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is this week
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Check if date is this month
    var isThisMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Check if date is this year
    var isThisYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    /// Check if date is in the past
    var isPast: Bool {
        return self < Date()
    }

    /// Check if date is in the future
    var isFuture: Bool {
        return self > Date()
    }

    /// Check if date is weekend
    var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }

    // MARK: - Date Arithmetic

    /// Add days to date
    /// - Parameter days: Number of days to add
    /// - Returns: New date
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Add hours to date
    /// - Parameter hours: Number of hours to add
    /// - Returns: New date
    func adding(hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    /// Add minutes to date
    /// - Parameter minutes: Number of minutes to add
    /// - Returns: New date
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    /// Add seconds to date
    /// - Parameter seconds: Number of seconds to add
    /// - Returns: New date
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self) ?? self
    }

    /// Add months to date
    /// - Parameter months: Number of months to add
    /// - Returns: New date
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Add years to date
    /// - Parameter years: Number of years to add
    /// - Returns: New date
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }

    // MARK: - Date Manipulation

    /// Get start of day (midnight)
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Get end of day (23:59:59.999)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Get start of week
    var startOfWeek: Date {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Get start of month
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Get start of year
    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    // MARK: - Time Intervals

    /// Get time interval since now
    var timeIntervalSinceNow: TimeInterval {
        return timeIntervalSince(Date())
    }

    /// Get days since date
    /// - Parameter date: Reference date
    /// - Returns: Number of days
    func days(since date: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: date, to: self)
        return components.day ?? 0
    }

    /// Get hours since date
    /// - Parameter date: Reference date
    /// - Returns: Number of hours
    func hours(since date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: date, to: self)
        return components.hour ?? 0
    }

    /// Get minutes since date
    /// - Parameter date: Reference date
    /// - Returns: Number of minutes
    func minutes(since date: Date) -> Int {
        let components = Calendar.current.dateComponents([.minute], from: date, to: self)
        return components.minute ?? 0
    }

    // MARK: - Age Calculation

    /// Calculate age in years
    var ageInYears: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }

    // MARK: - Timestamp

    /// Get Unix timestamp (seconds since 1970)
    var unixTimestamp: Int {
        return Int(timeIntervalSince1970)
    }

    /// Create date from Unix timestamp
    /// - Parameter timestamp: Unix timestamp
    /// - Returns: Date
    static func from(unixTimestamp timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    // MARK: - Time Zone

    /// Convert to different time zone
    /// - Parameter timeZone: Target time zone
    /// - Returns: Date in target time zone
    func converted(to timeZone: TimeZone) -> Date {
        let seconds = TimeInterval(timeZone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // MARK: - Validation

    /// Check if date is valid (not too far in past or future)
    var isReasonable: Bool {
        let hundredYearsAgo = Date().adding(years: -100)
        let hundredYearsFromNow = Date().adding(years: 100)
        return self > hundredYearsAgo && self < hundredYearsFromNow
    }

    // MARK: - Helper Initializers

    /// Create date from components
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month (1-12)
    ///   - day: Day
    ///   - hour: Hour (0-23)
    ///   - minute: Minute (0-59)
    ///   - second: Second (0-59)
    /// - Returns: Date or nil if invalid
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)
    }

    /// Create date from string with format
    /// - Parameters:
    ///   - string: Date string
    ///   - format: Format pattern
    /// - Returns: Date or nil if parsing fails
    static func from(string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }

    /// Create date from ISO 8601 string
    /// - Parameter string: ISO 8601 date string
    /// - Returns: Date or nil if parsing fails
    static func fromISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
}

// MARK: - TimeInterval Extensions

public extension TimeInterval {

    /// Convert to days
    var days: Double {
        return self / (24 * 60 * 60)
    }

    /// Convert to hours
    var hours: Double {
        return self / (60 * 60)
    }

    /// Convert to minutes
    var minutes: Double {
        return self / 60
    }

    /// Format as duration string
    var durationString: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// Format as human-readable duration
    var humanReadableDuration: String {
        let days = Int(self.days)
        let hours = Int(self.hours) % 24
        let minutes = Int(self.minutes) % 60

        var parts: [String] = []

        if days > 0 {
            parts.append("\(days)d")
        }
        if hours > 0 {
            parts.append("\(hours)h")
        }
        if minutes > 0 {
            parts.append("\(minutes)m")
        }

        return parts.isEmpty ? "0m" : parts.joined(separator: " ")
    }
}
