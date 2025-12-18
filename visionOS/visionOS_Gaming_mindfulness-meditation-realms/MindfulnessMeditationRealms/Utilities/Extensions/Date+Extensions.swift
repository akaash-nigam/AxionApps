import Foundation

extension Date {

    // MARK: - Formatting

    /// Returns a user-friendly string representation of the date
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Returns a user-friendly time string
    func formattedTime(style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = style
        return formatter.string(from: self)
    }

    /// Returns a relative string like "2 hours ago" or "yesterday"
    func relativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    // MARK: - Comparison

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is within the current week
    var isThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return false
        }

        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return false
        }

        return self >= weekStart && self < weekEnd
    }

    /// Check if date is within the current month
    var isThisMonth: Bool {
        let calendar = Calendar.current
        let now = Date()

        return calendar.component(.month, from: self) == calendar.component(.month, from: now) &&
               calendar.component(.year, from: self) == calendar.component(.year, from: now)
    }

    /// Check if date is within the current year
    var isThisYear: Bool {
        let calendar = Calendar.current
        let now = Date()

        return calendar.component(.year, from: self) == calendar.component(.year, from: now)
    }

    /// Check if two dates are on the same day
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    // MARK: - Date Components

    /// Start of day (00:00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// End of day (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Start of month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// End of month
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }

    // MARK: - Date Arithmetic

    /// Add days to date
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Add weeks to date
    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    /// Add months to date
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    /// Add years to date
    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }

    /// Days between two dates
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: other.startOfDay)
        return abs(components.day ?? 0)
    }

    // MARK: - Streak Helpers

    /// Check if date is consecutive day after another date
    func isConsecutiveDay(after other: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: other.startOfDay, to: self.startOfDay)
        return components.day == 1
    }

    /// Check if date is within same day or next day
    func isWithinStreakWindow(of other: Date) -> Bool {
        if isSameDay(as: other) {
            return true
        }

        return isConsecutiveDay(after: other)
    }

    // MARK: - Time of Day

    /// Get hour (0-23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    /// Get minute (0-59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    /// Check if time is in morning (6am-12pm)
    var isMorning: Bool {
        let hour = self.hour
        return hour >= 6 && hour < 12
    }

    /// Check if time is in afternoon (12pm-6pm)
    var isAfternoon: Bool {
        let hour = self.hour
        return hour >= 12 && hour < 18
    }

    /// Check if time is in evening (6pm-10pm)
    var isEvening: Bool {
        let hour = self.hour
        return hour >= 18 && hour < 22
    }

    /// Check if time is at night (10pm-6am)
    var isNight: Bool {
        let hour = self.hour
        return hour >= 22 || hour < 6
    }

    // MARK: - ISO8601

    /// ISO8601 string representation
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

    /// Create date from ISO8601 string
    static func from(iso8601 string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }

    // MARK: - Age Calculations

    /// Years since date (useful for "days since first session" etc)
    var yearsSince: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self, to: Date())
        return components.year ?? 0
    }

    /// Months since date
    var monthsSince: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: self, to: Date())
        return components.month ?? 0
    }

    /// Days since date
    var daysSince: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: Date())
        return components.day ?? 0
    }
}
