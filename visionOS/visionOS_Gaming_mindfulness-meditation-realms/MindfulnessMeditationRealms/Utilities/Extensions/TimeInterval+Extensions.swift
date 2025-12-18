import Foundation

extension TimeInterval {

    // MARK: - Formatting

    /// Format as MM:SS string
    var formattedMinutesSeconds: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Format as HH:MM:SS string
    var formattedHoursMinutesSeconds: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Format as readable string like "5 minutes" or "1 hour 30 minutes"
    var readableString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours) hour\(hours == 1 ? "" : "s")")
        }

        if minutes > 0 {
            components.append("\(minutes) minute\(minutes == 1 ? "" : "s")")
        }

        if seconds > 0 && hours == 0 {
            components.append("\(seconds) second\(seconds == 1 ? "" : "s")")
        }

        if components.isEmpty {
            return "0 seconds"
        }

        return components.joined(separator: " ")
    }

    /// Short readable string like "5m" or "1h 30m"
    var shortString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            let seconds = Int(self) % 60
            return "\(seconds)s"
        }
    }

    // MARK: - Conversion

    /// Convert to minutes
    var minutes: Double {
        self / 60.0
    }

    /// Convert to hours
    var hours: Double {
        self / 3600.0
    }

    /// Convert to days
    var days: Double {
        self / 86400.0
    }

    // MARK: - Constructors

    /// Create TimeInterval from minutes
    static func minutes(_ value: Double) -> TimeInterval {
        value * 60.0
    }

    /// Create TimeInterval from hours
    static func hours(_ value: Double) -> TimeInterval {
        value * 3600.0
    }

    /// Create TimeInterval from days
    static func days(_ value: Double) -> TimeInterval {
        value * 86400.0
    }

    // MARK: - Meditation-Specific

    /// Check if duration is within typical meditation range
    var isTypicalMeditationDuration: Bool {
        self >= 60 && self <= 3600 // 1 minute to 1 hour
    }

    /// Round to nearest 5 minutes
    var roundedToFiveMinutes: TimeInterval {
        let minutes = self.minutes
        let rounded = (minutes / 5).rounded() * 5
        return TimeInterval.minutes(rounded)
    }

    /// Get quality tier based on duration
    var meditationDurationTier: String {
        let mins = self.minutes

        if mins < 5 {
            return "Quick"
        } else if mins < 15 {
            return "Standard"
        } else if mins < 30 {
            return "Extended"
        } else {
            return "Deep Practice"
        }
    }
}
