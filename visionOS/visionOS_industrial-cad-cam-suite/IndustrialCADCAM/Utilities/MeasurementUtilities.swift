import Foundation

/// Utilities for measurement conversions and formatting
public enum MeasurementUtilities {

    // MARK: - Unit System

    /// Supported measurement systems
    public enum UnitSystem: String, Codable {
        case metric
        case imperial
    }

    /// Length units
    public enum LengthUnit: String, Codable, CaseIterable {
        case millimeters = "mm"
        case centimeters = "cm"
        case meters = "m"
        case inches = "in"
        case feet = "ft"

        var displayName: String {
            switch self {
            case .millimeters: return "Millimeters"
            case .centimeters: return "Centimeters"
            case .meters: return "Meters"
            case .inches: return "Inches"
            case .feet: return "Feet"
            }
        }

        var system: UnitSystem {
            switch self {
            case .millimeters, .centimeters, .meters: return .metric
            case .inches, .feet: return .imperial
            }
        }
    }

    // MARK: - Length Conversions

    /// Convert millimeters to inches
    /// - Parameter millimeters: Value in millimeters
    /// - Returns: Value in inches
    public static func millimetersToInches(_ millimeters: Double) -> Double {
        return millimeters / 25.4
    }

    /// Convert inches to millimeters
    /// - Parameter inches: Value in inches
    /// - Returns: Value in millimeters
    public static func inchesToMillimeters(_ inches: Double) -> Double {
        return inches * 25.4
    }

    /// Convert millimeters to centimeters
    /// - Parameter millimeters: Value in millimeters
    /// - Returns: Value in centimeters
    public static func millimetersToCentimeters(_ millimeters: Double) -> Double {
        return millimeters / 10.0
    }

    /// Convert centimeters to millimeters
    /// - Parameter centimeters: Value in centimeters
    /// - Returns: Value in millimeters
    public static func centimetersToMillimeters(_ centimeters: Double) -> Double {
        return centimeters * 10.0
    }

    /// Convert millimeters to meters
    /// - Parameter millimeters: Value in millimeters
    /// - Returns: Value in meters
    public static func millimetersToMeters(_ millimeters: Double) -> Double {
        return millimeters / 1000.0
    }

    /// Convert meters to millimeters
    /// - Parameter meters: Value in meters
    /// - Returns: Value in millimeters
    public static func metersToMillimeters(_ meters: Double) -> Double {
        return meters * 1000.0
    }

    /// Convert inches to feet
    /// - Parameter inches: Value in inches
    /// - Returns: Value in feet
    public static func inchesToFeet(_ inches: Double) -> Double {
        return inches / 12.0
    }

    /// Convert feet to inches
    /// - Parameter feet: Value in feet
    /// - Returns: Value in inches
    public static func feetToInches(_ feet: Double) -> Double {
        return feet * 12.0
    }

    /// Convert between any two length units
    /// - Parameters:
    ///   - value: Value to convert
    ///   - from: Source unit
    ///   - to: Target unit
    /// - Returns: Converted value
    public static func convertLength(_ value: Double, from: LengthUnit, to: LengthUnit) -> Double {
        // Convert to millimeters first (base unit)
        let millimeters: Double
        switch from {
        case .millimeters:
            millimeters = value
        case .centimeters:
            millimeters = centimetersToMillimeters(value)
        case .meters:
            millimeters = metersToMillimeters(value)
        case .inches:
            millimeters = inchesToMillimeters(value)
        case .feet:
            millimeters = inchesToMillimeters(feetToInches(value))
        }

        // Convert from millimeters to target unit
        switch to {
        case .millimeters:
            return millimeters
        case .centimeters:
            return millimetersToCentimeters(millimeters)
        case .meters:
            return millimetersToMeters(millimeters)
        case .inches:
            return millimetersToInches(millimeters)
        case .feet:
            return inchesToFeet(millimetersToInches(millimeters))
        }
    }

    // MARK: - Volume Conversions

    /// Convert cubic millimeters to cubic inches
    /// - Parameter cubicMillimeters: Value in mm³
    /// - Returns: Value in in³
    public static func cubicMillimetersToCubicInches(_ cubicMillimeters: Double) -> Double {
        return cubicMillimeters / 16387.064
    }

    /// Convert cubic inches to cubic millimeters
    /// - Parameter cubicInches: Value in in³
    /// - Returns: Value in mm³
    public static func cubicInchesToCubicMillimeters(_ cubicInches: Double) -> Double {
        return cubicInches * 16387.064
    }

    /// Convert cubic millimeters to cubic centimeters
    /// - Parameter cubicMillimeters: Value in mm³
    /// - Returns: Value in cm³
    public static func cubicMillimetersToCubicCentimeters(_ cubicMillimeters: Double) -> Double {
        return cubicMillimeters / 1000.0
    }

    /// Convert cubic millimeters to liters
    /// - Parameter cubicMillimeters: Value in mm³
    /// - Returns: Value in liters
    public static func cubicMillimetersToLiters(_ cubicMillimeters: Double) -> Double {
        return cubicMillimeters / 1_000_000.0
    }

    // MARK: - Mass Conversions

    /// Convert grams to kilograms
    /// - Parameter grams: Value in grams
    /// - Returns: Value in kilograms
    public static func gramsToKilograms(_ grams: Double) -> Double {
        return grams / 1000.0
    }

    /// Convert kilograms to grams
    /// - Parameter kilograms: Value in kilograms
    /// - Returns: Value in grams
    public static func kilogramsToGrams(_ kilograms: Double) -> Double {
        return kilograms * 1000.0
    }

    /// Convert grams to pounds
    /// - Parameter grams: Value in grams
    /// - Returns: Value in pounds
    public static func gramsToPounds(_ grams: Double) -> Double {
        return grams / 453.592
    }

    /// Convert pounds to grams
    /// - Parameter pounds: Value in pounds
    /// - Returns: Value in grams
    public static func poundsToGrams(_ pounds: Double) -> Double {
        return pounds * 453.592
    }

    /// Convert kilograms to pounds
    /// - Parameter kilograms: Value in kilograms
    /// - Returns: Value in pounds
    public static func kilogramsToPounds(_ kilograms: Double) -> Double {
        return gramsToPounds(kilogramsToGrams(kilograms))
    }

    /// Convert pounds to kilograms
    /// - Parameter pounds: Value in pounds
    /// - Returns: Value in kilograms
    public static func poundsToKilograms(_ pounds: Double) -> Double {
        return gramsToKilograms(poundsToGrams(pounds))
    }

    // MARK: - Density Conversions

    /// Convert g/cm³ to kg/m³
    /// - Parameter gramsPerCubicCm: Density in g/cm³
    /// - Returns: Density in kg/m³
    public static func gramsPerCubicCmToKgPerCubicM(_ gramsPerCubicCm: Double) -> Double {
        return gramsPerCubicCm * 1000.0
    }

    /// Convert kg/m³ to g/cm³
    /// - Parameter kgPerCubicM: Density in kg/m³
    /// - Returns: Density in g/cm³
    public static func kgPerCubicMToGramsPerCubicCm(_ kgPerCubicM: Double) -> Double {
        return kgPerCubicM / 1000.0
    }

    // MARK: - Angle Conversions

    /// Convert radians to degrees
    /// - Parameter radians: Angle in radians
    /// - Returns: Angle in degrees
    public static func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }

    /// Convert degrees to radians
    /// - Parameter degrees: Angle in degrees
    /// - Returns: Angle in radians
    public static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }

    // MARK: - Pressure Conversions

    /// Convert PSI to MPa
    /// - Parameter psi: Pressure in PSI
    /// - Returns: Pressure in MPa
    public static func psiToMPa(_ psi: Double) -> Double {
        return psi * 0.00689476
    }

    /// Convert MPa to PSI
    /// - Parameter mpa: Pressure in MPa
    /// - Returns: Pressure in PSI
    public static func mpaToPsi(_ mpa: Double) -> Double {
        return mpa / 0.00689476
    }

    // MARK: - Speed Conversions

    /// Convert mm/s to m/min
    /// - Parameter mmPerSecond: Speed in mm/s
    /// - Returns: Speed in m/min
    public static func mmPerSecondToMPerMin(_ mmPerSecond: Double) -> Double {
        return (mmPerSecond / 1000.0) * 60.0
    }

    /// Convert m/min to mm/s
    /// - Parameter mPerMin: Speed in m/min
    /// - Returns: Speed in mm/s
    public static func mPerMinToMmPerSecond(_ mPerMin: Double) -> Double {
        return (mPerMin * 1000.0) / 60.0
    }

    // MARK: - Formatting

    /// Format a length value with appropriate unit
    /// - Parameters:
    ///   - value: Value to format
    ///   - unit: Unit of measurement
    ///   - precision: Number of decimal places (default: 2)
    /// - Returns: Formatted string
    public static func formatLength(_ value: Double, unit: LengthUnit, precision: Int = 2) -> String {
        return String(format: "%.\(precision)f %@", value, unit.rawValue)
    }

    /// Format a volume value
    /// - Parameters:
    ///   - value: Value in cubic millimeters
    ///   - system: Unit system
    ///   - precision: Number of decimal places (default: 2)
    /// - Returns: Formatted string
    public static func formatVolume(_ value: Double, system: UnitSystem, precision: Int = 2) -> String {
        switch system {
        case .metric:
            let cm3 = cubicMillimetersToCubicCentimeters(value)
            return String(format: "%.\(precision)f cm³", cm3)
        case .imperial:
            let in3 = cubicMillimetersToCubicInches(value)
            return String(format: "%.\(precision)f in³", in3)
        }
    }

    /// Format a mass value
    /// - Parameters:
    ///   - value: Value in grams
    ///   - system: Unit system
    ///   - precision: Number of decimal places (default: 2)
    /// - Returns: Formatted string
    public static func formatMass(_ value: Double, system: UnitSystem, precision: Int = 2) -> String {
        switch system {
        case .metric:
            let kg = gramsToKilograms(value)
            return String(format: "%.\(precision)f kg", kg)
        case .imperial:
            let lb = gramsToPounds(value)
            return String(format: "%.\(precision)f lb", lb)
        }
    }

    /// Format an angle value
    /// - Parameters:
    ///   - radians: Angle in radians
    ///   - precision: Number of decimal places (default: 1)
    /// - Returns: Formatted string in degrees
    public static func formatAngle(_ radians: Double, precision: Int = 1) -> String {
        let degrees = radiansToDegrees(radians)
        return String(format: "%.\(precision)f°", degrees)
    }

    // MARK: - Precision Helpers

    /// Round value to specified decimal places
    /// - Parameters:
    ///   - value: Value to round
    ///   - places: Number of decimal places
    /// - Returns: Rounded value
    public static func round(_ value: Double, toDecimalPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (value * multiplier).rounded() / multiplier
    }

    /// Check if a value is within tolerance of a target
    /// - Parameters:
    ///   - value: Value to check
    ///   - target: Target value
    ///   - tolerance: Tolerance
    /// - Returns: True if within tolerance
    public static func isWithinTolerance(_ value: Double, of target: Double, tolerance: Double) -> Bool {
        return abs(value - target) <= tolerance
    }

    /// Calculate percentage difference between two values
    /// - Parameters:
    ///   - value1: First value
    ///   - value2: Second value
    /// - Returns: Percentage difference
    public static func percentageDifference(_ value1: Double, _ value2: Double) -> Double {
        guard value2 != 0 else { return 0 }
        return abs((value1 - value2) / value2) * 100.0
    }
}
