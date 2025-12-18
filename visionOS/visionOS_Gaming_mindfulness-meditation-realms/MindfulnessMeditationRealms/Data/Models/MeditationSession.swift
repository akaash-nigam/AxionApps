import Foundation

/// Represents a single meditation session with all associated data
struct MeditationSession: Codable, Identifiable {

    // MARK: - Properties

    let id: UUID
    let userID: UUID
    let environmentID: String
    let technique: MeditationTechnique
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var targetDuration: TimeInterval
    var completionPercentage: Double

    // Biometric data
    var biometricSnapshots: [BiometricSnapshot]
    var initialBiometrics: BiometricSnapshot?
    var finalBiometrics: BiometricSnapshot?

    // Session quality metrics
    var focusScore: Double?
    var calmScore: Double?
    var overallRating: Int?
    var notes: String?

    // Computed properties
    var isCompleted: Bool {
        return completionPercentage >= 0.9
    }

    var stressReduction: Double? {
        guard let initial = initialBiometrics,
              let final = finalBiometrics else {
            return nil
        }
        return Double(initial.estimatedStressLevel - final.estimatedStressLevel)
    }

    var calmIncrease: Double? {
        guard let initial = initialBiometrics,
              let final = finalBiometrics else {
            return nil
        }
        return Double(final.estimatedCalmLevel - initial.estimatedCalmLevel)
    }

    var qualityScore: Double {
        calculateQualityScore()
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userID: UUID,
        environmentID: String,
        technique: MeditationTechnique,
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = 0,
        targetDuration: TimeInterval,
        completionPercentage: Double = 0,
        biometricSnapshots: [BiometricSnapshot] = [],
        initialBiometrics: BiometricSnapshot? = nil,
        finalBiometrics: BiometricSnapshot? = nil,
        focusScore: Double? = nil,
        calmScore: Double? = nil,
        overallRating: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.environmentID = environmentID
        self.technique = technique
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.targetDuration = targetDuration
        self.completionPercentage = completionPercentage
        self.biometricSnapshots = biometricSnapshots
        self.initialBiometrics = initialBiometrics
        self.finalBiometrics = finalBiometrics
        self.focusScore = focusScore
        self.calmScore = calmScore
        self.overallRating = overallRating
        self.notes = notes
    }

    // MARK: - Methods

    mutating func addBiometricSnapshot(_ snapshot: BiometricSnapshot) {
        biometricSnapshots.append(snapshot)

        if initialBiometrics == nil {
            initialBiometrics = snapshot
        }
        finalBiometrics = snapshot
    }

    mutating func updateDuration(_ newDuration: TimeInterval) {
        duration = newDuration
        completionPercentage = min(duration / targetDuration, 1.0)
    }

    mutating func complete(with endTime: Date) {
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.completionPercentage = min(duration / targetDuration, 1.0)
    }

    private func calculateQualityScore() -> Double {
        let completionWeight = completionPercentage * 0.3
        let focusWeight = (focusScore ?? 0.5) * 0.3
        let stressReductionWeight = max(0, stressReduction ?? 0) * 0.2
        let calmIncreaseWeight = max(0, calmIncrease ?? 0) * 0.2

        return completionWeight + focusWeight + stressReductionWeight + calmIncreaseWeight
    }
}

// MARK: - Meditation Technique

enum MeditationTechnique: String, Codable, CaseIterable {
    case breathAwareness = "Breath Awareness"
    case bodyScan = "Body Scan"
    case lovingKindness = "Loving-Kindness"
    case mindfulObservation = "Mindful Observation"
    case soundMeditation = "Sound Meditation"
    case mantraRepetition = "Mantra Repetition"
    case walkingMeditation = "Walking Meditation"
    case visualizationJourney = "Visualization Journey"

    var description: String {
        switch self {
        case .breathAwareness:
            return "Focus on the natural rhythm of your breathing"
        case .bodyScan:
            return "Progressive awareness through the body"
        case .lovingKindness:
            return "Cultivate compassion for self and others"
        case .mindfulObservation:
            return "Notice thoughts and sensations without judgment"
        case .soundMeditation:
            return "Focus awareness on ambient sounds"
        case .mantraRepetition:
            return "Repeat a meaningful word or phrase"
        case .walkingMeditation:
            return "Mindful movement and awareness"
        case .visualizationJourney:
            return "Guided imagery and mental exploration"
        }
    }

    var defaultDuration: TimeInterval {
        switch self {
        case .breathAwareness: return 300  // 5 min
        case .bodyScan: return 600        // 10 min
        case .lovingKindness: return 900  // 15 min
        case .mindfulObservation: return 1200  // 20 min
        case .soundMeditation: return 600
        case .mantraRepetition: return 900
        case .walkingMeditation: return 900
        case .visualizationJourney: return 1800  // 30 min
        }
    }

    var difficultyLevel: Int {
        switch self {
        case .breathAwareness: return 1
        case .bodyScan: return 2
        case .lovingKindness: return 3
        case .mindfulObservation: return 2
        case .soundMeditation: return 1
        case .mantraRepetition: return 2
        case .walkingMeditation: return 3
        case .visualizationJourney: return 4
        }
    }

    var experienceRequired: Int {
        return difficultyLevel * 100
    }
}

// MARK: - Session State

enum SessionState: String, Codable {
    case idle = "Idle"
    case preparing = "Preparing"
    case calibrating = "Calibrating"
    case active = "Active"
    case paused = "Paused"
    case completing = "Completing"
    case ended = "Ended"

    var canTransitionTo: [SessionState] {
        switch self {
        case .idle:
            return [.preparing]
        case .preparing:
            return [.calibrating, .active, .idle]
        case .calibrating:
            return [.active, .idle]
        case .active:
            return [.paused, .completing]
        case .paused:
            return [.active, .completing]
        case .completing:
            return [.ended]
        case .ended:
            return [.idle]
        }
    }
}
