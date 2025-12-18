import Foundation

/// Extensions for Double to support formatting and common operations
public extension Double {

    // MARK: - Formatting

    /// Format as string with specified decimal places
    /// - Parameter places: Number of decimal places
    /// - Returns: Formatted string
    func formatted(decimalPlaces places: Int = 2) -> String {
        return String(format: "%.\(places)f", self)
    }

    /// Format with thousands separator
    /// - Parameter places: Number of decimal places
    /// - Returns: Formatted string with separator
    func formattedWithSeparator(decimalPlaces places: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = places
        formatter.maximumFractionDigits = places
        return formatter.string(from: NSNumber(value: self)) ?? formatted(decimalPlaces: places)
    }

    /// Format as percentage
    /// - Parameter places: Number of decimal places
    /// - Returns: Formatted percentage string
    func formattedAsPercentage(decimalPlaces places: Int = 1) -> String {
        return String(format: "%.\(places)f%%", self)
    }

    /// Format with unit
    /// - Parameters:
    ///   - unit: Unit string (e.g., "mm", "kg")
    ///   - places: Number of decimal places
    /// - Returns: Formatted string with unit
    func formatted(withUnit unit: String, decimalPlaces places: Int = 2) -> String {
        return "\(formatted(decimalPlaces: places)) \(unit)"
    }

    /// Format in scientific notation
    /// - Returns: Scientific notation string
    func formattedScientific() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }

    // MARK: - Rounding

    /// Round to specified decimal places
    /// - Parameter places: Number of decimal places
    /// - Returns: Rounded value
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }

    /// Round up to specified decimal places
    /// - Parameter places: Number of decimal places
    /// - Returns: Rounded up value
    func roundedUp(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return ceil(self * multiplier) / multiplier
    }

    /// Round down to specified decimal places
    /// - Parameter places: Number of decimal places
    /// - Returns: Rounded down value
    func roundedDown(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return floor(self * multiplier) / multiplier
    }

    /// Round to nearest multiple
    /// - Parameter multiple: Multiple to round to
    /// - Returns: Rounded value
    func rounded(toNearest multiple: Double) -> Double {
        return (self / multiple).rounded() * multiple
    }

    // MARK: - Clamping

    /// Clamp value between minimum and maximum
    /// - Parameters:
    ///   - minValue: Minimum value
    ///   - maxValue: Maximum value
    /// - Returns: Clamped value
    func clamped(min minValue: Double, max maxValue: Double) -> Double {
        return Swift.min(Swift.max(self, minValue), maxValue)
    }

    /// Clamp to 0...1 range
    /// - Returns: Clamped value
    func clamped01() -> Double {
        return clamped(min: 0, max: 1)
    }

    // MARK: - Comparison with Tolerance

    /// Check if approximately equal to another value
    /// - Parameters:
    ///   - other: Value to compare with
    ///   - tolerance: Tolerance for comparison (default: 0.0001)
    /// - Returns: True if values are approximately equal
    func isApproximatelyEqual(to other: Double, tolerance: Double = 0.0001) -> Bool {
        return abs(self - other) < tolerance
    }

    /// Check if value is within range
    /// - Parameters:
    ///   - range: Range to check
    /// - Returns: True if within range
    func isWithin(_ range: ClosedRange<Double>) -> Bool {
        return range.contains(self)
    }

    // MARK: - Validation

    /// Check if value is positive
    var isPositive: Bool {
        return self > 0
    }

    /// Check if value is negative
    var isNegative: Bool {
        return self < 0
    }

    /// Check if value is zero (within tolerance)
    /// - Parameter tolerance: Tolerance (default: 0.0001)
    /// - Returns: True if approximately zero
    func isZero(tolerance: Double = 0.0001) -> Bool {
        return abs(self) < tolerance
    }

    /// Check if value is finite (not infinity or NaN)
    var isFiniteNumber: Bool {
        return self.isFinite && !self.isNaN
    }

    // MARK: - Conversion Helpers

    /// Convert to Int, rounding
    var toInt: Int {
        return Int(rounded())
    }

    /// Convert to Float
    var toFloat: Float {
        return Float(self)
    }

    // MARK: - Engineering Notation

    /// Get order of magnitude
    var orderOfMagnitude: Int {
        guard self != 0 else { return 0 }
        return Int(floor(log10(abs(self))))
    }

    /// Format in engineering notation (multiples of 3)
    /// - Returns: Engineering notation string
    func formattedEngineering() -> String {
        guard self != 0 else { return "0" }

        let exponent = orderOfMagnitude
        let engineeringExponent = (exponent / 3) * 3
        let mantissa = self / pow(10, Double(engineeringExponent))

        if engineeringExponent == 0 {
            return mantissa.formatted(decimalPlaces: 3)
        } else {
            return "\(mantissa.formatted(decimalPlaces: 3))e\(engineeringExponent)"
        }
    }

    // MARK: - Interpolation

    /// Linear interpolation between this value and another
    /// - Parameters:
    ///   - other: Target value
    ///   - t: Interpolation factor (0...1)
    /// - Returns: Interpolated value
    func lerp(to other: Double, t: Double) -> Double {
        return self + (other - self) * t.clamped01()
    }

    /// Inverse lerp - find t for a value between this and other
    /// - Parameters:
    ///   - other: End value
    ///   - value: Value to find t for
    /// - Returns: Interpolation factor
    func inverseLerp(to other: Double, value: Double) -> Double {
        guard abs(other - self) > 0.0001 else { return 0 }
        return ((value - self) / (other - self)).clamped01()
    }

    // MARK: - Percentage Calculations

    /// Calculate what percentage this value is of another
    /// - Parameter total: Total value
    /// - Returns: Percentage
    func asPercentageOf(_ total: Double) -> Double {
        guard total != 0 else { return 0 }
        return (self / total) * 100
    }

    /// Calculate percentage increase/decrease
    /// - Parameter original: Original value
    /// - Returns: Percentage change (positive for increase, negative for decrease)
    func percentageChange(from original: Double) -> Double {
        guard original != 0 else { return 0 }
        return ((self - original) / original) * 100
    }

    // MARK: - Sign

    /// Get sign of the value (-1, 0, or 1)
    var sign: Double {
        if self > 0 { return 1 }
        if self < 0 { return -1 }
        return 0
    }

    // MARK: - Statistical

    /// Square the value
    var squared: Double {
        return self * self
    }

    /// Cube the value
    var cubed: Double {
        return self * self * self
    }

    /// Square root (returns 0 for negative numbers)
    var squareRoot: Double {
        return self >= 0 ? sqrt(self) : 0
    }

    // MARK: - Degrees/Radians

    /// Convert degrees to radians
    var degreesToRadians: Double {
        return self * .pi / 180.0
    }

    /// Convert radians to degrees
    var radiansToDegrees: Double {
        return self * 180.0 / .pi
    }

    // MARK: - Optional Safety

    /// Return nil if value is NaN or infinite
    var safeValue: Double? {
        return isFiniteNumber ? self : nil
    }
}

// MARK: - Array Extensions for Double

public extension Array where Element == Double {

    /// Calculate sum of all elements
    var sum: Double {
        return reduce(0, +)
    }

    /// Calculate average of all elements
    var average: Double {
        guard !isEmpty else { return 0 }
        return sum / Double(count)
    }

    /// Find minimum value
    var minimum: Double? {
        return self.min()
    }

    /// Find maximum value
    var maximum: Double? {
        return self.max()
    }

    /// Calculate range (max - min)
    var range: Double? {
        guard let min = minimum, let max = maximum else { return nil }
        return max - min
    }

    /// Calculate median value
    var median: Double? {
        guard !isEmpty else { return nil }
        let sorted = self.sorted()
        let mid = count / 2

        if count.isMultiple(of: 2) {
            return (sorted[mid - 1] + sorted[mid]) / 2
        } else {
            return sorted[mid]
        }
    }

    /// Calculate standard deviation
    var standardDeviation: Double {
        guard count > 1 else { return 0 }
        let avg = average
        let variance = map { ($0 - avg).squared }.average
        return sqrt(variance)
    }

    /// Filter out non-finite values
    var finiteValues: [Double] {
        return filter { $0.isFiniteNumber }
    }
}
