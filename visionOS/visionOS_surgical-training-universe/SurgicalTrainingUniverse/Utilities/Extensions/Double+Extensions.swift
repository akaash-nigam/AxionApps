//
//  Double+Extensions.swift
//  SurgicalTrainingUniverse
//
//  Double extension utilities for number formatting and calculations
//

import Foundation

extension Double {

    // MARK: - Percentage Formatting

    /// Format as percentage with 1 decimal place (e.g., "85.5%")
    var percentageString: String {
        String(format: "%.1f%%", self)
    }

    /// Format as percentage with 2 decimal places (e.g., "85.52%")
    var percentageStringDetailed: String {
        String(format: "%.2f%%", self)
    }

    /// Format as whole percentage (e.g., "86%")
    var percentageStringWhole: String {
        String(format: "%.0f%%", self)
    }

    // MARK: - Number Formatting

    /// Format with 1 decimal place (e.g., "123.5")
    var formatted1: String {
        String(format: "%.1f", self)
    }

    /// Format with 2 decimal places (e.g., "123.45")
    var formatted2: String {
        String(format: "%.2f", self)
    }

    /// Format with 3 decimal places (e.g., "123.456")
    var formatted3: String {
        String(format: "%.3f", self)
    }

    /// Format as whole number (e.g., "123")
    var formattedWhole: String {
        String(format: "%.0f", self)
    }

    /// Format with thousands separator (e.g., "1,234.56")
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? formatted2
    }

    /// Format as currency (e.g., "$1,234.56")
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? formattedWithCommas
    }

    // MARK: - Scientific Notation

    /// Format in scientific notation (e.g., "1.23e+03")
    var scientificString: String {
        String(format: "%.2e", self)
    }

    // MARK: - Time Formatting

    /// Format as duration in MM:SS (e.g., "05:30")
    var durationString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Format as duration in HH:MM:SS (e.g., "01:05:30")
    var durationStringLong: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Format as human-readable duration (e.g., "1h 5m 30s")
    var humanReadableDuration: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60

        var components: [String] = []
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 || components.isEmpty { components.append("\(seconds)s") }

        return components.joined(separator: " ")
    }

    // MARK: - Rounding

    /// Round to specified decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Round up to specified decimal places
    func roundedUp(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return ceil(self * divisor) / divisor
    }

    /// Round down to specified decimal places
    func roundedDown(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return floor(self * divisor) / divisor
    }

    // MARK: - Clamping

    /// Clamp value between minimum and maximum
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }

    /// Clamp percentage value between 0 and 100
    var clampedPercentage: Double {
        clamped(to: 0...100)
    }

    // MARK: - Comparison

    /// Check if approximately equal (within tolerance)
    func isApproximately(_ other: Double, tolerance: Double = 0.0001) -> Bool {
        abs(self - other) < tolerance
    }

    /// Check if value is between range (inclusive)
    func isBetween(_ lower: Double, and upper: Double) -> Bool {
        self >= lower && self <= upper
    }

    // MARK: - Sign

    /// Get the sign of the number (-1, 0, or 1)
    var sign: Int {
        if self > 0 { return 1 }
        if self < 0 { return -1 }
        return 0
    }

    /// Check if positive
    var isPositive: Bool {
        self > 0
    }

    /// Check if negative
    var isNegative: Bool {
        self < 0
    }

    /// Absolute value
    var absolute: Double {
        abs(self)
    }

    // MARK: - Percentage Calculations

    /// Calculate percentage of total (this / total * 100)
    func percentage(of total: Double) -> Double {
        guard total != 0 else { return 0 }
        return (self / total) * 100
    }

    /// Calculate value from percentage (percentage * this / 100)
    func value(fromPercentage percentage: Double) -> Double {
        (percentage * self) / 100
    }

    // MARK: - Grade/Score

    /// Convert score to letter grade (A-F)
    var letterGrade: String {
        switch self {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }

    /// Convert score to grade with plus/minus
    var detailedLetterGrade: String {
        switch self {
        case 97...100: return "A+"
        case 93..<97: return "A"
        case 90..<93: return "A-"
        case 87..<90: return "B+"
        case 83..<87: return "B"
        case 80..<83: return "B-"
        case 77..<80: return "C+"
        case 73..<77: return "C"
        case 70..<73: return "C-"
        case 67..<70: return "D+"
        case 63..<67: return "D"
        case 60..<63: return "D-"
        default: return "F"
        }
    }

    // MARK: - Statistics

    /// Calculate standard deviation for array of doubles
    static func standardDeviation(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }

    /// Calculate average of array
    static func average(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    // MARK: - Conversion

    /// Convert to Int
    var toInt: Int {
        Int(self)
    }

    /// Convert to Float
    var toFloat: Float {
        Float(self)
    }

    /// Convert degrees to radians
    var degreesToRadians: Double {
        self * .pi / 180.0
    }

    /// Convert radians to degrees
    var radiansToDegrees: Double {
        self * 180.0 / .pi
    }
}

// MARK: - Float Extensions

extension Float {
    /// Format as percentage with 1 decimal place
    var percentageString: String {
        String(format: "%.1f%%", self)
    }

    /// Format with 2 decimal places
    var formatted2: String {
        String(format: "%.2f", self)
    }

    /// Clamp value between minimum and maximum
    func clamped(to range: ClosedRange<Float>) -> Float {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
