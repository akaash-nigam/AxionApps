//
//  Formatters.swift
//  SurgicalTrainingUniverse
//
//  Reusable formatters for consistent data presentation
//

import Foundation

enum Formatters {

    // MARK: - Date Formatters

    /// Short date formatter (e.g., "1/15/25")
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    /// Medium date formatter (e.g., "Jan 15, 2025")
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    /// Long date formatter (e.g., "January 15, 2025")
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    /// Full date and time formatter (e.g., "January 15, 2025 at 3:30 PM")
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    /// Time only formatter (e.g., "3:30 PM")
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    /// ISO8601 formatter
    static let iso8601 = ISO8601DateFormatter()

    /// Relative date formatter (e.g., "2 hours ago")
    static let relativeDate: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    /// Short relative date formatter (e.g., "2h ago")
    static let shortRelativeDate: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    // MARK: - Number Formatters

    /// Decimal formatter with 1 decimal place
    static let decimal1: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    /// Decimal formatter with 2 decimal places
    static let decimal2: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    /// Whole number formatter
    static let wholeNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Percentage formatter (e.g., "85.5%")
    static let percentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1 // Input already in 0-100 range
        return formatter
    }()

    /// Currency formatter
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    /// Scientific notation formatter
    static let scientific: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    // MARK: - Score Formatters

    /// Format score as percentage string (e.g., "85.5%")
    static func formatScore(_ score: Double) -> String {
        String(format: "%.1f%%", score.clamped(to: 0...100))
    }

    /// Format score as whole percentage (e.g., "86%")
    static func formatScoreWhole(_ score: Double) -> String {
        String(format: "%.0f%%", score.clamped(to: 0...100))
    }

    /// Format score as detailed percentage (e.g., "85.52%")
    static func formatScoreDetailed(_ score: Double) -> String {
        String(format: "%.2f%%", score.clamped(to: 0...100))
    }

    /// Format score with letter grade (e.g., "85.5% (B)")
    static func formatScoreWithGrade(_ score: Double) -> String {
        let scoreString = formatScore(score)
        let grade = CalculationHelpers.calculateGrade(from: score)
        return "\(scoreString) (\(grade))"
    }

    // MARK: - Duration Formatters

    /// Format duration as MM:SS (e.g., "05:30")
    static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Format duration as HH:MM:SS (e.g., "01:05:30")
    static func formatDurationLong(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Format duration as human-readable string (e.g., "1h 5m 30s")
    static func formatDurationHuman(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        var components: [String] = []
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 || components.isEmpty { components.append("\(seconds)s") }

        return components.joined(separator: " ")
    }

    /// Format duration as verbose string (e.g., "1 hour, 5 minutes, 30 seconds")
    static func formatDurationVerbose(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        var components: [String] = []

        if hours == 1 {
            components.append("1 hour")
        } else if hours > 1 {
            components.append("\(hours) hours")
        }

        if minutes == 1 {
            components.append("1 minute")
        } else if minutes > 1 {
            components.append("\(minutes) minutes")
        }

        if seconds == 1 {
            components.append("1 second")
        } else if seconds > 1 || components.isEmpty {
            components.append("\(seconds) seconds")
        }

        return components.joined(separator: ", ")
    }

    // MARK: - File Size Formatters

    /// Format bytes as human-readable string (e.g., "1.5 MB")
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        return formatter.string(fromByteCount: bytes)
    }

    // MARK: - List Formatters

    /// Format list of strings with oxford comma
    static func formatList(_ items: [String]) -> String {
        guard !items.isEmpty else { return "" }
        guard items.count > 1 else { return items[0] }
        guard items.count > 2 else { return items.joined(separator: " and ") }

        let allButLast = items.dropLast().joined(separator: ", ")
        return "\(allButLast), and \(items.last!)"
    }

    /// Format list with bullet points
    static func formatBulletList(_ items: [String]) -> String {
        items.map { "• \($0)" }.joined(separator: "\n")
    }

    /// Format numbered list
    static func formatNumberedList(_ items: [String]) -> String {
        items.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
    }

    // MARK: - Position Formatters

    /// Format 3D position (e.g., "(0.5, 1.2, -0.3)")
    static func formatPosition(_ position: SIMD3<Float>) -> String {
        String(format: "(%.2f, %.2f, %.2f)", position.x, position.y, position.z)
    }

    /// Format position with labels (e.g., "X: 0.5, Y: 1.2, Z: -0.3")
    static func formatPositionLabeled(_ position: SIMD3<Float>) -> String {
        String(format: "X: %.2f, Y: %.2f, Z: %.2f", position.x, position.y, position.z)
    }

    // MARK: - Custom Formatting Functions

    /// Format with ordinal indicator (e.g., "1st", "2nd", "3rd", "4th")
    static func formatOrdinal(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    /// Format large number with abbreviation (e.g., "1.5K", "2.3M")
    static func formatLargeNumber(_ number: Double) -> String {
        let thousand = 1000.0
        let million = 1_000_000.0
        let billion = 1_000_000_000.0

        if number >= billion {
            return String(format: "%.1fB", number / billion)
        } else if number >= million {
            return String(format: "%.1fM", number / million)
        } else if number >= thousand {
            return String(format: "%.1fK", number / thousand)
        } else {
            return String(format: "%.0f", number)
        }
    }

    /// Format phone number (US format)
    static func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleaned = phoneNumber.numericOnly
        guard cleaned.count == 10 else { return phoneNumber }

        let areaCode = cleaned.prefix(3)
        let exchange = cleaned.dropFirst(3).prefix(3)
        let subscriber = cleaned.suffix(4)

        return "(\(areaCode)) \(exchange)-\(subscriber)"
    }

    /// Format credit card number (masked, e.g., "**** **** **** 1234")
    static func formatCreditCardMasked(_ cardNumber: String) -> String {
        let cleaned = cardNumber.numericOnly
        guard cleaned.count >= 4 else { return cardNumber }

        let lastFour = cleaned.suffix(4)
        return "**** **** **** \(lastFour)"
    }

    /// Pluralize word based on count
    static func pluralize(_ word: String, count: Int, pluralForm: String? = nil) -> String {
        if count == 1 {
            return word
        } else if let pluralForm = pluralForm {
            return pluralForm
        } else {
            return word + "s"
        }
    }

    /// Format with count and pluralization (e.g., "5 items", "1 item")
    static func formatCountWithPlural(_ count: Int, singular: String, plural: String? = nil) -> String {
        let pluralized = pluralize(singular, count: count, pluralForm: plural)
        return "\(count) \(pluralized)"
    }
}

// MARK: - Format Extensions

extension Date {
    /// Format using short date formatter
    var formattedShort: String {
        Formatters.shortDate.string(from: self)
    }

    /// Format using medium date formatter
    var formattedMedium: String {
        Formatters.mediumDate.string(from: self)
    }

    /// Format using long date formatter
    var formattedLong: String {
        Formatters.longDate.string(from: self)
    }

    /// Format as full date and time
    var formattedFull: String {
        Formatters.fullDateTime.string(from: self)
    }

    /// Format as relative time
    var formattedRelative: String {
        Formatters.relativeDate.localizedString(for: self, relativeTo: Date())
    }
}

extension Double {
    /// Format as score percentage
    var formattedScore: String {
        Formatters.formatScore(self)
    }

    /// Format as duration
    var formattedDuration: String {
        Formatters.formatDuration(self)
    }
}

extension TimeInterval {
    /// Format as duration string
    var formattedDuration: String {
        Formatters.formatDuration(self)
    }

    /// Format as long duration string
    var formattedDurationLong: String {
        Formatters.formatDurationLong(self)
    }

    /// Format as human-readable duration
    var formattedDurationHuman: String {
        Formatters.formatDurationHuman(self)
    }
}
