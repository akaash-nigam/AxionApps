import Foundation

/// Snapshot of biometric data at a specific point in time
struct BiometricSnapshot: Codable {

    // MARK: - Properties

    let timestamp: Date
    let estimatedStressLevel: Float      // 0.0 = calm, 1.0 = stressed
    let estimatedCalmLevel: Float        // 0.0 = agitated, 1.0 = calm
    let breathingRate: Double?           // Breaths per minute
    let movementStillness: Float         // 0.0 = fidgety, 1.0 = still
    let focusLevel: Float                // 0.0 = distracted, 1.0 = focused

    // Optional raw measurements (Vision Pro doesn't have all sensors)
    let headMovementVariance: Float?     // Head stability
    let eyeMovementRate: Float?          // Eye movement frequency
    let gestureFrequency: Float?         // How often gestures occur

    // MARK: - Computed Properties

    /// Overall wellness score combining calm, stillness, and focus
    var wellnessScore: Float {
        (estimatedCalmLevel + movementStillness + focusLevel) / 3.0
    }

    /// Quality rating from 0-5 stars
    var qualityRating: Int {
        let score = wellnessScore
        if score >= 0.9 { return 5 }
        if score >= 0.75 { return 4 }
        if score >= 0.6 { return 3 }
        if score >= 0.4 { return 2 }
        if score >= 0.2 { return 1 }
        return 0
    }

    /// Meditation depth classification
    var meditationDepth: MeditationDepth {
        if wellnessScore >= 0.8 && focusLevel >= 0.8 {
            return .deep
        } else if wellnessScore >= 0.6 {
            return .moderate
        } else if wellnessScore >= 0.4 {
            return .light
        } else {
            return .settling
        }
    }

    // MARK: - Initialization

    init(
        timestamp: Date = Date(),
        estimatedStressLevel: Float,
        estimatedCalmLevel: Float,
        breathingRate: Double? = nil,
        movementStillness: Float,
        focusLevel: Float,
        headMovementVariance: Float? = nil,
        eyeMovementRate: Float? = nil,
        gestureFrequency: Float? = nil
    ) {
        self.timestamp = timestamp
        self.estimatedStressLevel = estimatedStressLevel
        self.estimatedCalmLevel = estimatedCalmLevel
        self.breathingRate = breathingRate
        self.movementStillness = movementStillness
        self.focusLevel = focusLevel
        self.headMovementVariance = headMovementVariance
        self.eyeMovementRate = eyeMovementRate
        self.gestureFrequency = gestureFrequency
    }

    // MARK: - Factory Methods

    /// Create a relaxed/calm snapshot
    static func calm() -> BiometricSnapshot {
        return BiometricSnapshot(
            estimatedStressLevel: 0.2,
            estimatedCalmLevel: 0.9,
            breathingRate: 12.0,
            movementStillness: 0.9,
            focusLevel: 0.8
        )
    }

    /// Create a stressed snapshot
    static func stressed() -> BiometricSnapshot {
        return BiometricSnapshot(
            estimatedStressLevel: 0.9,
            estimatedCalmLevel: 0.2,
            breathingRate: 22.0,
            movementStillness: 0.3,
            focusLevel: 0.4
        )
    }

    /// Create a neutral/baseline snapshot
    static func neutral() -> BiometricSnapshot {
        return BiometricSnapshot(
            estimatedStressLevel: 0.5,
            estimatedCalmLevel: 0.5,
            breathingRate: 16.0,
            movementStillness: 0.6,
            focusLevel: 0.6
        )
    }
}

// MARK: - Meditation Depth

enum MeditationDepth: String, Codable {
    case settling = "Settling In"
    case light = "Light Meditation"
    case moderate = "Moderate Depth"
    case deep = "Deep Meditation"

    var description: String {
        switch self {
        case .settling:
            return "Getting comfortable and beginning to focus"
        case .light:
            return "Relaxed awareness with some mind wandering"
        case .moderate:
            return "Sustained focus with good calm"
        case .deep:
            return "Profound stillness and clear awareness"
        }
    }

    var color: String {
        switch self {
        case .settling: return "yellow"
        case .light: return "green"
        case .moderate: return "blue"
        case .deep: return "purple"
        }
    }
}

// MARK: - Breathing Pattern

struct BreathingPattern: Codable {
    let averageRate: Double              // Breaths per minute
    let variability: Double              // Measure of consistency
    let regularity: Double               // 0.0 = irregular, 1.0 = very regular
    let quality: BreathingQuality

    enum BreathingQuality: String, Codable {
        case shallow = "Shallow"           // Fast, irregular
        case normal = "Normal"             // 12-20 bpm, regular
        case deep = "Deep"                 // Slow, regular
        case yogic = "Yogic"               // Very slow, very regular

        var description: String {
            switch self {
            case .shallow:
                return "Fast, shallow breathing - may indicate stress"
            case .normal:
                return "Normal, healthy breathing pattern"
            case .deep:
                return "Deep, calming breaths"
            case .yogic:
                return "Advanced breathing - very controlled"
            }
        }
    }

    static func analyze(breathingRate: Double, regularity: Double) -> BreathingPattern {
        let variability = 1.0 - regularity

        let quality: BreathingQuality
        if breathingRate > 20 || regularity < 0.5 {
            quality = .shallow
        } else if breathingRate < 8 && regularity > 0.9 {
            quality = .yogic
        } else if breathingRate < 12 && regularity > 0.7 {
            quality = .deep
        } else {
            quality = .normal
        }

        return BreathingPattern(
            averageRate: breathingRate,
            variability: variability,
            regularity: regularity,
            quality: quality
        )
    }
}
