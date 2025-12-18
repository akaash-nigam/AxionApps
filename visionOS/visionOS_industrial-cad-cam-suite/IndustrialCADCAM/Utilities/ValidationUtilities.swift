import Foundation

/// Utilities for data validation across the application
public enum ValidationUtilities {

    // MARK: - String Validation

    /// Validate project name
    /// - Parameter name: Project name to validate
    /// - Returns: Validation result
    public static func validateProjectName(_ name: String) -> ValidationResult {
        // Check if empty
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .invalid("Project name cannot be empty")
        }

        // Check length
        guard name.count <= 100 else {
            return .invalid("Project name must be 100 characters or less")
        }

        // Check for valid characters
        let allowedCharacters = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-_()[]"))

        guard name.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            return .invalid("Project name contains invalid characters")
        }

        return .valid
    }

    /// Validate part name
    /// - Parameter name: Part name to validate
    /// - Returns: Validation result
    public static func validatePartName(_ name: String) -> ValidationResult {
        // Check if empty
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .invalid("Part name cannot be empty")
        }

        // Check length
        guard name.count <= 100 else {
            return .invalid("Part name must be 100 characters or less")
        }

        return .valid
    }

    /// Validate description
    /// - Parameter description: Description to validate
    /// - Returns: Validation result
    public static func validateDescription(_ description: String) -> ValidationResult {
        // Description is optional, so empty is valid
        guard !description.isEmpty else {
            return .valid
        }

        // Check maximum length
        guard description.count <= 500 else {
            return .invalid("Description must be 500 characters or less")
        }

        return .valid
    }

    /// Validate email address
    /// - Parameter email: Email to validate
    /// - Returns: Validation result
    public static func validateEmail(_ email: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard emailPredicate.evaluate(with: email) else {
            return .invalid("Invalid email address format")
        }

        return .valid
    }

    // MARK: - Numeric Validation

    /// Validate dimension (must be positive)
    /// - Parameter dimension: Dimension value in millimeters
    /// - Returns: Validation result
    public static func validateDimension(_ dimension: Double) -> ValidationResult {
        guard dimension > 0 else {
            return .invalid("Dimension must be greater than zero")
        }

        // Check for reasonable maximum (100 meters)
        guard dimension <= 100_000 else {
            return .invalid("Dimension exceeds maximum allowed (100m)")
        }

        return .valid
    }

    /// Validate tolerance value
    /// - Parameter tolerance: Tolerance value
    /// - Returns: Validation result
    public static func validateTolerance(_ tolerance: Double) -> ValidationResult {
        guard tolerance >= 0 else {
            return .invalid("Tolerance cannot be negative")
        }

        // Reasonable maximum tolerance (10mm)
        guard tolerance <= 10.0 else {
            return .invalid("Tolerance exceeds reasonable maximum (10mm)")
        }

        return .valid
    }

    /// Validate density value
    /// - Parameter density: Density in g/cm³
    /// - Returns: Validation result
    public static func validateDensity(_ density: Double) -> ValidationResult {
        // Density must be positive
        guard density > 0 else {
            return .invalid("Density must be greater than zero")
        }

        // Reasonable range: 0.1 (foam) to 25 (tungsten) g/cm³
        guard density >= 0.1 && density <= 25.0 else {
            return .invalid("Density outside reasonable range (0.1 - 25 g/cm³)")
        }

        return .valid
    }

    /// Validate mass value
    /// - Parameter mass: Mass in grams
    /// - Returns: Validation result
    public static func validateMass(_ mass: Double) -> ValidationResult {
        guard mass >= 0 else {
            return .invalid("Mass cannot be negative")
        }

        // Maximum 10 tons
        guard mass <= 10_000_000 else {
            return .invalid("Mass exceeds maximum (10 tons)")
        }

        return .valid
    }

    /// Validate angle in radians
    /// - Parameter angle: Angle in radians
    /// - Returns: Validation result
    public static func validateAngle(_ angle: Double) -> ValidationResult {
        // Angles can be any value, but warn for very large values
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 2 * .pi)

        if abs(normalizedAngle) > 2 * .pi {
            return .warning("Angle is very large, consider normalizing")
        }

        return .valid
    }

    /// Validate percentage (0-100)
    /// - Parameter percentage: Percentage value
    /// - Returns: Validation result
    public static func validatePercentage(_ percentage: Double) -> ValidationResult {
        guard percentage >= 0 && percentage <= 100 else {
            return .invalid("Percentage must be between 0 and 100")
        }

        return .valid
    }

    // MARK: - Manufacturing Validation

    /// Validate feed rate
    /// - Parameter feedRate: Feed rate in mm/min
    /// - Returns: Validation result
    public static func validateFeedRate(_ feedRate: Double) -> ValidationResult {
        guard feedRate > 0 else {
            return .invalid("Feed rate must be greater than zero")
        }

        // Typical CNC range: 1-10000 mm/min
        guard feedRate >= 1 && feedRate <= 10_000 else {
            return .invalid("Feed rate outside typical range (1-10000 mm/min)")
        }

        return .valid
    }

    /// Validate spindle speed
    /// - Parameter spindleSpeed: Spindle speed in RPM
    /// - Returns: Validation result
    public static func validateSpindleSpeed(_ spindleSpeed: Double) -> ValidationResult {
        guard spindleSpeed > 0 else {
            return .invalid("Spindle speed must be greater than zero")
        }

        // Typical CNC range: 100-30000 RPM
        guard spindleSpeed >= 100 && spindleSpeed <= 30_000 else {
            return .invalid("Spindle speed outside typical range (100-30000 RPM)")
        }

        return .valid
    }

    /// Validate tool diameter
    /// - Parameter diameter: Tool diameter in millimeters
    /// - Returns: Validation result
    public static func validateToolDiameter(_ diameter: Double) -> ValidationResult {
        guard diameter > 0 else {
            return .invalid("Tool diameter must be greater than zero")
        }

        // Typical range: 0.1mm - 100mm
        guard diameter >= 0.1 && diameter <= 100 else {
            return .invalid("Tool diameter outside typical range (0.1-100mm)")
        }

        return .valid
    }

    /// Validate depth of cut
    /// - Parameter depth: Depth of cut in millimeters
    /// - Returns: Validation result
    public static func validateDepthOfCut(_ depth: Double) -> ValidationResult {
        guard depth > 0 else {
            return .invalid("Depth of cut must be greater than zero")
        }

        // Typical maximum: 20mm
        guard depth <= 20 else {
            return .invalid("Depth of cut exceeds typical maximum (20mm)")
        }

        return .valid
    }

    // MARK: - Material Validation

    /// Validate material name
    /// - Parameter materialName: Material name
    /// - Returns: Validation result
    public static func validateMaterialName(_ materialName: String) -> ValidationResult {
        guard !materialName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .invalid("Material name cannot be empty")
        }

        guard materialName.count <= 50 else {
            return .invalid("Material name must be 50 characters or less")
        }

        return .valid
    }

    // MARK: - Simulation Validation

    /// Validate load force
    /// - Parameter force: Force in Newtons
    /// - Returns: Validation result
    public static func validateForce(_ force: Double) -> ValidationResult {
        guard force >= 0 else {
            return .invalid("Force cannot be negative")
        }

        // Maximum 1 million Newtons (about 100 tons force)
        guard force <= 1_000_000 else {
            return .invalid("Force exceeds maximum (1,000,000 N)")
        }

        return .valid
    }

    /// Validate stress value
    /// - Parameter stress: Stress in MPa
    /// - Returns: Validation result
    public static func validateStress(_ stress: Double) -> ValidationResult {
        guard stress >= 0 else {
            return .invalid("Stress cannot be negative")
        }

        // Typical material strength up to 10000 MPa
        guard stress <= 10_000 else {
            return .invalid("Stress exceeds typical material limits (10000 MPa)")
        }

        return .valid
    }

    /// Validate factor of safety
    /// - Parameter fos: Factor of safety
    /// - Returns: Validation result
    public static func validateFactorOfSafety(_ fos: Double) -> ValidationResult {
        guard fos > 0 else {
            return .invalid("Factor of safety must be greater than zero")
        }

        if fos < 1.0 {
            return .warning("Factor of safety is less than 1 (design may fail)")
        } else if fos < 1.5 {
            return .warning("Factor of safety is low (< 1.5)")
        }

        return .valid
    }

    // MARK: - Date Validation

    /// Validate date is not in the far future
    /// - Parameter date: Date to validate
    /// - Returns: Validation result
    public static func validateDate(_ date: Date) -> ValidationResult {
        let currentDate = Date()
        let tenYearsFromNow = Calendar.current.date(byAdding: .year, value: 10, to: currentDate)!

        if date > tenYearsFromNow {
            return .warning("Date is more than 10 years in the future")
        }

        return .valid
    }

    // MARK: - Collection Validation

    /// Validate array is not empty
    /// - Parameter array: Array to validate
    /// - Returns: Validation result
    public static func validateNotEmpty<T>(_ array: [T], itemName: String = "items") -> ValidationResult {
        guard !array.isEmpty else {
            return .invalid("Array of \(itemName) cannot be empty")
        }

        return .valid
    }

    /// Validate collection size
    /// - Parameters:
    ///   - count: Collection count
    ///   - minimum: Minimum allowed count
    ///   - maximum: Maximum allowed count
    ///   - itemName: Name of items for error message
    /// - Returns: Validation result
    public static func validateCollectionSize(
        _ count: Int,
        minimum: Int? = nil,
        maximum: Int? = nil,
        itemName: String = "items"
    ) -> ValidationResult {
        if let min = minimum, count < min {
            return .invalid("Must have at least \(min) \(itemName)")
        }

        if let max = maximum, count > max {
            return .invalid("Cannot exceed \(max) \(itemName)")
        }

        return .valid
    }

    // MARK: - UUID Validation

    /// Validate UUID string
    /// - Parameter uuidString: UUID string to validate
    /// - Returns: Validation result
    public static func validateUUID(_ uuidString: String) -> ValidationResult {
        guard UUID(uuidString: uuidString) != nil else {
            return .invalid("Invalid UUID format")
        }

        return .valid
    }

    // MARK: - Validation Result

    /// Result of a validation operation
    public enum ValidationResult {
        case valid
        case invalid(String)
        case warning(String)

        public var isValid: Bool {
            switch self {
            case .valid, .warning:
                return true
            case .invalid:
                return false
            }
        }

        public var message: String? {
            switch self {
            case .valid:
                return nil
            case .invalid(let message), .warning(let message):
                return message
            }
        }

        public var isWarning: Bool {
            if case .warning = self {
                return true
            }
            return false
        }
    }

    // MARK: - Batch Validation

    /// Validate multiple values and combine results
    /// - Parameter validations: Array of validation results
    /// - Returns: Combined validation result
    public static func combineValidations(_ validations: [ValidationResult]) -> ValidationResult {
        var hasWarning = false
        var warningMessage = ""

        for validation in validations {
            switch validation {
            case .invalid(let message):
                return .invalid(message)
            case .warning(let message):
                hasWarning = true
                if !warningMessage.isEmpty {
                    warningMessage += "; "
                }
                warningMessage += message
            case .valid:
                continue
            }
        }

        if hasWarning {
            return .warning(warningMessage)
        }

        return .valid
    }
}
