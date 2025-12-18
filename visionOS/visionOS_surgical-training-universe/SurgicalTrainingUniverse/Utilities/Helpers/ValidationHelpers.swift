//
//  ValidationHelpers.swift
//  SurgicalTrainingUniverse
//
//  Validation utilities for user input and data integrity
//

import Foundation

enum ValidationHelpers {

    // MARK: - Email Validation

    /// Validate email address format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Validate email with custom domain requirements
    static func isValidEmail(_ email: String, allowedDomains: [String]) -> Bool {
        guard isValidEmail(email) else { return false }

        let domain = email.components(separatedBy: "@").last?.lowercased() ?? ""
        return allowedDomains.contains { domain.hasSuffix($0.lowercased()) }
    }

    // MARK: - Name Validation

    /// Validate person name (2-50 characters, letters and spaces only)
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 && trimmed.count <= 50 else { return false }

        let nameRegex = "^[a-zA-Z][a-zA-Z\\s'-]*$"
        let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: trimmed)
    }

    // MARK: - Score Validation

    /// Validate score is within valid range (0-100)
    static func isValidScore(_ score: Double) -> Bool {
        score >= 0 && score <= 100
    }

    /// Validate all scores in collection
    static func areValidScores(_ scores: [Double]) -> Bool {
        scores.allSatisfy { isValidScore($0) }
    }

    // MARK: - Duration Validation

    /// Validate procedure duration (reasonable time: 1 minute to 24 hours)
    static func isValidProcedureDuration(_ duration: TimeInterval) -> Bool {
        let minDuration: TimeInterval = 60 // 1 minute
        let maxDuration: TimeInterval = 86400 // 24 hours
        return duration >= minDuration && duration <= maxDuration
    }

    // MARK: - Movement Validation

    /// Validate surgical movement position (within reasonable bounds)
    static func isValidPosition(_ position: SIMD3<Float>) -> Bool {
        let maxDistance: Float = 2.0 // 2 meters from origin
        let distance = sqrt(position.x * position.x + position.y * position.y + position.z * position.z)
        return distance <= maxDistance
    }

    /// Validate movement velocity (not too fast for surgical precision)
    static func isValidVelocity(_ velocity: Float) -> Bool {
        velocity >= 0 && velocity <= 1.0 // Max 1 m/s
    }

    /// Validate force application (0-1 normalized range)
    static func isValidForce(_ force: Float) -> Bool {
        force >= 0 && force <= 1.0
    }

    // MARK: - Text Validation

    /// Validate text is not empty and within length limits
    static func isValidText(_ text: String, minLength: Int = 1, maxLength: Int = 1000) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= minLength && trimmed.count <= maxLength
    }

    /// Validate description field (10-500 characters)
    static func isValidDescription(_ description: String) -> Bool {
        isValidText(description, minLength: 10, maxLength: 500)
    }

    // MARK: - Date Validation

    /// Validate date is not in the future
    static func isNotFutureDate(_ date: Date) -> Bool {
        date <= Date()
    }

    /// Validate date is within reasonable range (not too old)
    static func isRecentDate(_ date: Date, maxAge: TimeInterval = 31536000) -> Bool { // 1 year default
        let age = Date().timeIntervalSince(date)
        return age >= 0 && age <= maxAge
    }

    // MARK: - ID Validation

    /// Validate UUID string
    static func isValidUUID(_ string: String) -> Bool {
        UUID(uuidString: string) != nil
    }

    // MARK: - Institutional Validation

    /// Validate institution name
    static func isValidInstitutionName(_ name: String) -> Bool {
        isValidText(name, minLength: 3, maxLength: 100)
    }

    // MARK: - Composite Validation

    /// Validate surgeon profile is complete
    static func isValidSurgeonProfile(
        name: String,
        email: String,
        institution: String
    ) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []

        if !isValidName(name) {
            errors.append("Invalid name: Must be 2-50 characters, letters and spaces only")
        }

        if !isValidEmail(email) {
            errors.append("Invalid email address format")
        }

        if !isValidInstitutionName(institution) {
            errors.append("Invalid institution name: Must be 3-100 characters")
        }

        return (errors.isEmpty, errors)
    }

    /// Validate procedure session data
    static func isValidProcedureSession(
        duration: TimeInterval,
        accuracyScore: Double,
        efficiencyScore: Double,
        safetyScore: Double
    ) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []

        if !isValidProcedureDuration(duration) {
            errors.append("Invalid duration: Must be between 1 minute and 24 hours")
        }

        if !isValidScore(accuracyScore) {
            errors.append("Invalid accuracy score: Must be 0-100")
        }

        if !isValidScore(efficiencyScore) {
            errors.append("Invalid efficiency score: Must be 0-100")
        }

        if !isValidScore(safetyScore) {
            errors.append("Invalid safety score: Must be 0-100")
        }

        return (errors.isEmpty, errors)
    }

    /// Validate surgical movement data
    static func isValidSurgicalMovement(
        position: SIMD3<Float>,
        velocity: Float,
        force: Float,
        precisionScore: Double
    ) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []

        if !isValidPosition(position) {
            errors.append("Invalid position: Exceeds maximum distance from origin")
        }

        if !isValidVelocity(velocity) {
            errors.append("Invalid velocity: Must be 0-1 m/s")
        }

        if !isValidForce(force) {
            errors.append("Invalid force: Must be 0-1 normalized range")
        }

        if !isValidScore(precisionScore) {
            errors.append("Invalid precision score: Must be 0-100")
        }

        return (errors.isEmpty, errors)
    }
}

// MARK: - Validation Result

struct ValidationResult {
    let isValid: Bool
    let errors: [String]

    var errorMessage: String? {
        guard !errors.isEmpty else { return nil }
        return errors.joined(separator: "\n")
    }
}

extension ValidationResult {
    static let valid = ValidationResult(isValid: true, errors: [])

    static func invalid(_ errors: String...) -> ValidationResult {
        ValidationResult(isValid: false, errors: errors)
    }
}
