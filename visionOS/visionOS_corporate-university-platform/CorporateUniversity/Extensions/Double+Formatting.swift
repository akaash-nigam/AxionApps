//
//  Double+Formatting.swift
//  CorporateUniversity
//
//  Utility extensions for number formatting and conversion
//

import Foundation

extension Double {
    // MARK: - Time Formatting

    /// Convert seconds to human-readable time string
    /// Examples: "2h 30m", "45m", "1h 15m 30s"
    var asTimeString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 {
            components.append("\(minutes)m")
        }
        if seconds > 0 && hours == 0 {
            components.append("\(seconds)s")
        }

        return components.isEmpty ? "0s" : components.joined(separator: " ")
    }

    /// Convert seconds to hours and minutes
    /// Example: "2 hours, 30 minutes"
    var asDetailedTimeString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours) \(hours == 1 ? "hour" : "hours")")
        }
        if minutes > 0 {
            components.append("\(minutes) \(minutes == 1 ? "minute" : "minutes")")
        }

        return components.isEmpty ? "Less than a minute" : components.joined(separator: ", ")
    }

    /// Convert to hours with decimal
    /// Example: 7200 seconds = "2.0 hours"
    var asHours: String {
        let hours = self / 3600
        return String(format: "%.1f hours", hours)
    }

    /// Convert to minutes
    var asMinutes: String {
        let minutes = self / 60
        return String(format: "%.0f minutes", minutes)
    }

    // MARK: - Percentage Formatting

    /// Format as percentage
    /// Example: 0.85 → "85%"
    var asPercentage: String {
        String(format: "%.0f%%", self)
    }

    /// Format as percentage with decimal
    /// Example: 0.856 → "85.6%"
    var asPercentageWithDecimal: String {
        String(format: "%.1f%%", self)
    }

    /// Format as percentage from 0-100 range
    /// Example: 85 → "85%"
    var asPercentageFrom100: String {
        String(format: "%.0f%%", self)
    }

    // MARK: - Currency Formatting

    /// Format as currency (USD)
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    /// Format as currency with specific currency code
    func asCurrency(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "0.00"
    }

    // MARK: - Decimal Formatting

    /// Format with specific number of decimal places
    func formatted(decimalPlaces: Int) -> String {
        String(format: "%.\(decimalPlaces)f", self)
    }

    /// Format with thousands separator
    var withThousandsSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    // MARK: - Score Formatting

    /// Format as score out of 100
    /// Example: 87.5 → "87.5/100"
    var asScore: String {
        String(format: "%.1f/100", self)
    }

    /// Format as grade letter
    /// Example: 92.5 → "A"
    var asGradeLetter: String {
        switch self {
        case 90...100:
            return "A"
        case 80..<90:
            return "B"
        case 70..<80:
            return "C"
        case 60..<70:
            return "D"
        default:
            return "F"
        }
    }

    /// Get grade with +/- modifiers
    /// Example: 87 → "B+"
    var asDetailedGrade: String {
        let letter: String
        let modifier: String

        switch self {
        case 97...100:
            return "A+"
        case 93..<97:
            return "A"
        case 90..<93:
            return "A-"
        case 87..<90:
            return "B+"
        case 83..<87:
            return "B"
        case 80..<83:
            return "B-"
        case 77..<80:
            return "C+"
        case 73..<77:
            return "C"
        case 70..<73:
            return "C-"
        case 67..<70:
            return "D+"
        case 63..<67:
            return "D"
        case 60..<63:
            return "D-"
        default:
            return "F"
        }
    }

    // MARK: - File Size Formatting

    /// Format bytes as human-readable file size
    /// Example: 1536 → "1.5 KB"
    var asFileSize: String {
        let bytes = self
        let kilobyte = 1024.0
        let megabyte = kilobyte * 1024
        let gigabyte = megabyte * 1024
        let terabyte = gigabyte * 1024

        if bytes < kilobyte {
            return "\(Int(bytes)) B"
        } else if bytes < megabyte {
            return String(format: "%.1f KB", bytes / kilobyte)
        } else if bytes < gigabyte {
            return String(format: "%.1f MB", bytes / megabyte)
        } else if bytes < terabyte {
            return String(format: "%.2f GB", bytes / gigabyte)
        } else {
            return String(format: "%.2f TB", bytes / terabyte)
        }
    }

    // MARK: - Distance Formatting

    /// Format meters as distance
    /// Example: 1500 → "1.5 km"
    var asDistance: String {
        if self < 1000 {
            return String(format: "%.0f m", self)
        } else {
            return String(format: "%.1f km", self / 1000)
        }
    }

    // MARK: - Abbreviation

    /// Format with K, M, B abbreviations
    /// Example: 1500 → "1.5K", 1500000 → "1.5M"
    var abbreviated: String {
        let thousand = 1_000.0
        let million = 1_000_000.0
        let billion = 1_000_000_000.0

        if abs(self) < thousand {
            return String(format: "%.0f", self)
        } else if abs(self) < million {
            return String(format: "%.1fK", self / thousand)
        } else if abs(self) < billion {
            return String(format: "%.1fM", self / million)
        } else {
            return String(format: "%.1fB", self / billion)
        }
    }

    // MARK: - Ordinal

    /// Convert to ordinal string
    /// Example: 1 → "1st", 2 → "2nd", 3 → "3rd", 4 → "4th"
    var asOrdinal: String {
        let number = Int(self)
        let suffix: String

        if number % 100 >= 11 && number % 100 <= 13 {
            suffix = "th"
        } else {
            switch number % 10 {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default:
                suffix = "th"
            }
        }

        return "\(number)\(suffix)"
    }

    // MARK: - Rating

    /// Format as star rating
    /// Example: 4.5 → "★★★★½"
    var asStarRating: String {
        let fullStars = Int(self)
        let hasHalfStar = self.truncatingRemainder(dividingBy: 1) >= 0.5
        let emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0)

        return String(repeating: "★", count: fullStars) +
               (hasHalfStar ? "½" : "") +
               String(repeating: "☆", count: emptyStars)
    }

    /// Format as numeric rating
    /// Example: 4.7 → "4.7/5.0"
    var asNumericRating: String {
        String(format: "%.1f/5.0", self)
    }

    // MARK: - Comparison

    /// Check if close to another value within tolerance
    func isClose(to value: Double, tolerance: Double = 0.001) -> Bool {
        abs(self - value) < tolerance
    }

    /// Clamp value between min and max
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }

    // MARK: - Rounding

    /// Round to specified decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Round up to nearest integer
    var roundedUp: Int {
        Int(self.rounded(.up))
    }

    /// Round down to nearest integer
    var roundedDown: Int {
        Int(self.rounded(.down))
    }

    // MARK: - Conversion Helpers

    /// Convert hours to seconds
    static func hours(_ hours: Double) -> Double {
        hours * 3600
    }

    /// Convert minutes to seconds
    static func minutes(_ minutes: Double) -> Double {
        minutes * 60
    }

    /// Convert days to seconds
    static func days(_ days: Double) -> Double {
        days * 86400
    }
}

// MARK: - Int Extensions

extension Int {
    /// Convert to Double
    var asDouble: Double {
        Double(self)
    }

    /// Format with thousands separator
    var withThousandsSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    /// Format as ordinal
    var asOrdinal: String {
        asDouble.asOrdinal
    }

    /// Format with abbreviation
    var abbreviated: String {
        asDouble.abbreviated
    }

    /// Convert seconds to time string
    var asTimeString: String {
        asDouble.asTimeString
    }

    /// Format as file size
    var asFileSize: String {
        asDouble.asFileSize
    }

    /// Check if number is even
    var isEven: Bool {
        self % 2 == 0
    }

    /// Check if number is odd
    var isOdd: Bool {
        !isEven
    }

    /// Check if number is prime
    var isPrime: Bool {
        guard self > 1 else { return false }
        guard self != 2 else { return true }
        guard self % 2 != 0 else { return false }

        let sqrtValue = Int(Double(self).squareRoot())
        for i in stride(from: 3, through: sqrtValue, by: 2) {
            if self % i == 0 {
                return false
            }
        }
        return true
    }

    /// Get factorial
    var factorial: Int {
        guard self >= 0 else { return 0 }
        return self == 0 ? 1 : self * (self - 1).factorial
    }
}

// MARK: - Percentage Helper

struct Percentage {
    let value: Double

    /// Initialize from 0-100 scale
    init(from100: Double) {
        self.value = from100
    }

    /// Initialize from 0-1 scale
    init(from1: Double) {
        self.value = from1 * 100
    }

    /// Get value as 0-100 scale
    var as100: Double {
        value
    }

    /// Get value as 0-1 scale
    var as1: Double {
        value / 100
    }

    /// Formatted string
    var formatted: String {
        value.asPercentageFrom100
    }
}

// MARK: - Progress Helper

extension Double {
    /// Calculate progress percentage between two values
    static func progress(current: Double, total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (current / total) * 100
    }

    /// Calculate progress from completed/total items
    static func progress(completed: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(completed) / Double(total)) * 100
    }
}

// MARK: - Statistical Helpers

extension Collection where Element == Double {
    /// Calculate average
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }

    /// Calculate median
    var median: Double {
        let sorted = sorted()
        let count = sorted.count

        guard count > 0 else { return 0 }

        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2
        } else {
            return sorted[count / 2]
        }
    }

    /// Calculate standard deviation
    var standardDeviation: Double {
        let avg = average
        let variance = map { pow($0 - avg, 2) }.reduce(0, +) / Double(count)
        return sqrt(variance)
    }

    /// Find minimum value
    var minimum: Double? {
        self.min()
    }

    /// Find maximum value
    var maximum: Double? {
        self.max()
    }

    /// Calculate sum
    var sum: Double {
        reduce(0, +)
    }
}
