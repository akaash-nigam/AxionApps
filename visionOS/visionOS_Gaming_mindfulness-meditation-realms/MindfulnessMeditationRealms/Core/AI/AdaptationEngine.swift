import Foundation
import Combine

/// AI-driven engine that adapts meditation environments based on biometric feedback
@MainActor
class AdaptationEngine: ObservableObject {

    // MARK: - Types

    struct AdaptationDecision {
        let environmentAdjustments: EnvironmentAdjustments
        let audioAdjustments: AudioAdjustments
        let guidanceRecommendations: [GuidanceRecommendation]
        let confidence: Float
        let reasoning: String
    }

    struct EnvironmentAdjustments {
        var lightnessLevel: Float? // 0.0 (dark) to 1.0 (bright)
        var colorTemperature: Float? // 0.0 (cool) to 1.0 (warm)
        var particleDensity: Float? // 0.0 (minimal) to 1.0 (abundant)
        var animationSpeed: Float? // 0.0 (still) to 1.0 (dynamic)
        var weatherMood: WeatherMood?

        enum WeatherMood {
            case clear
            case mist
            case gentleRain
            case snow
        }
    }

    struct AudioAdjustments {
        var ambienceVolume: Float? // 0.0 to 1.0
        var natureVolume: Float? // 0.0 to 1.0
        var guidanceVolume: Float? // 0.0 to 1.0
        var binauralIntensity: Float? // 0.0 to 1.0
        var frequency: AudioFrequency?

        enum AudioFrequency {
            case delta // Deep sleep/meditation
            case theta // Deep meditation
            case alpha // Relaxed awareness
            case beta // Normal alertness
        }
    }

    struct GuidanceRecommendation {
        let type: GuidanceType
        let timing: TimingRecommendation
        let priority: Int

        enum GuidanceType {
            case breathingReminder
            case postureCheck
            case progressEncouragement
            case deepenPractice
            case gentleAwareness
        }

        enum TimingRecommendation {
            case immediate
            case within(seconds: TimeInterval)
            case onNextInterval
        }
    }

    // MARK: - Published Properties

    @Published private(set) var currentAdaptation: AdaptationDecision?
    @Published private(set) var adaptationHistory: [AdaptationRecord] = []

    struct AdaptationRecord {
        let timestamp: Date
        let biometricSnapshot: BiometricSnapshot
        let decision: AdaptationDecision
        let wasEffective: Bool?
    }

    // MARK: - Private Properties

    private let biometricMonitor: BiometricMonitor
    private var adaptationTimer: Timer?
    private var sessionStartBaseline: BiometricSnapshot?
    private var lastAdaptation: Date?

    // Adaptation thresholds
    private let highStressThreshold: Float = 0.7
    private let lowCalmThreshold: Float = 0.3
    private let adaptationCooldown: TimeInterval = 30.0 // Don't adapt too frequently

    // MARK: - Initialization

    init(biometricMonitor: BiometricMonitor) {
        self.biometricMonitor = biometricMonitor
    }

    // MARK: - Public Methods

    func startAdaptation() {
        // Capture baseline
        sessionStartBaseline = biometricMonitor.currentSnapshot

        // Monitor every 10 seconds
        adaptationTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.evaluateAndAdapt()
            }
        }
    }

    func stopAdaptation() {
        adaptationTimer?.invalidate()
        adaptationTimer = nil
    }

    func evaluateAndAdapt() async {
        let currentSnapshot = biometricMonitor.currentSnapshot

        // Check cooldown
        if let lastAdaptation = lastAdaptation,
           Date().timeIntervalSince(lastAdaptation) < adaptationCooldown {
            return // Too soon to adapt again
        }

        let decision = await makeAdaptationDecision(for: currentSnapshot)

        // Only apply if confidence is high enough and changes are needed
        if decision.confidence > 0.6 && requiresAdaptation(decision) {
            currentAdaptation = decision
            lastAdaptation = Date()

            let record = AdaptationRecord(
                timestamp: Date(),
                biometricSnapshot: currentSnapshot,
                decision: decision,
                wasEffective: nil // Will be evaluated later
            )
            adaptationHistory.append(record)

            // Limit history size
            if adaptationHistory.count > 50 {
                adaptationHistory.removeFirst(adaptationHistory.count - 50)
            }
        }
    }

    // MARK: - Decision Making

    private func makeAdaptationDecision(for snapshot: BiometricSnapshot) async -> AdaptationDecision {
        var environmentAdj = EnvironmentAdjustments()
        var audioAdj = AudioAdjustments()
        var guidanceRecs: [GuidanceRecommendation] = []
        var reasoning = ""

        // High stress detected
        if snapshot.estimatedStressLevel > highStressThreshold {
            reasoning += "High stress detected. "

            // Calm the environment
            environmentAdj.lightnessLevel = 0.4 // Dimmer
            environmentAdj.colorTemperature = 0.3 // Cooler
            environmentAdj.animationSpeed = 0.3 // Slower
            environmentAdj.weatherMood = .mist // Soothing mist

            // Calming audio
            audioAdj.ambienceVolume = 0.7
            audioAdj.natureVolume = 0.5
            audioAdj.binauralIntensity = 0.8
            audioAdj.frequency = .theta // Deep relaxation

            // Guidance
            guidanceRecs.append(GuidanceRecommendation(
                type: .breathingReminder,
                timing: .immediate,
                priority: 10
            ))

            reasoning += "Applying calming adjustments. "
        }

        // Low calm/focus - user struggling to settle
        if snapshot.estimatedCalmLevel < lowCalmThreshold && snapshot.focusLevel < 0.5 {
            reasoning += "Difficulty settling. "

            // More structured environment
            environmentAdj.particleDensity = 0.6 // More visual anchor points
            environmentAdj.animationSpeed = 0.5 // Gentle rhythm

            guidanceRecs.append(GuidanceRecommendation(
                type: .gentleAwareness,
                timing: .within(seconds: 15),
                priority: 8
            ))

            reasoning += "Adding gentle structure. "
        }

        // Deep meditation detected - enhance
        if snapshot.meditationDepth == .deep {
            reasoning += "Deep meditation state. "

            // Minimal distractions
            environmentAdj.lightnessLevel = 0.3
            environmentAdj.particleDensity = 0.2 // Minimal
            environmentAdj.animationSpeed = 0.1 // Very still

            // Reduce audio
            audioAdj.ambienceVolume = 0.5
            audioAdj.natureVolume = 0.3
            audioAdj.binauralIntensity = 0.9
            audioAdj.frequency = .delta // Deepest state

            reasoning += "Minimizing distractions to maintain depth. "
        }

        // Restlessness - movement too high
        if snapshot.movementStillness < 0.4 {
            reasoning += "Physical restlessness detected. "

            guidanceRecs.append(GuidanceRecommendation(
                type: .postureCheck,
                timing: .within(seconds: 30),
                priority: 7
            ))

            // More engaging environment to redirect attention
            environmentAdj.particleDensity = 0.7
            environmentAdj.weatherMood = .gentleRain // Engaging but calming

            reasoning += "Redirecting attention through environment. "
        }

        // Breathing issues
        if let breathingRate = snapshot.breathingRate, breathingRate > 18 {
            reasoning += "Rapid breathing detected. "

            guidanceRecs.append(GuidanceRecommendation(
                type: .breathingReminder,
                timing: .immediate,
                priority: 9
            ))

            audioAdj.binauralIntensity = 0.6
            audioAdj.frequency = .alpha // Relaxed awareness

            reasoning += "Guiding breathing normalization. "
        }

        // Calculate confidence based on biometric quality and history
        let confidence = calculateConfidence(for: snapshot)

        return AdaptationDecision(
            environmentAdjustments: environmentAdj,
            audioAdjustments: audioAdj,
            guidanceRecommendations: guidanceRecs.sorted { $0.priority > $1.priority },
            confidence: confidence,
            reasoning: reasoning.isEmpty ? "No adaptation needed" : reasoning
        )
    }

    private func calculateConfidence(for snapshot: BiometricSnapshot) -> Float {
        // Confidence based on:
        // - Biometric quality/consistency
        // - Time in session (more data = higher confidence)
        // - Historical effectiveness of adaptations

        var confidence: Float = 0.7 // Base confidence

        // Higher wellness score = more reliable biometrics
        confidence += (snapshot.wellnessScore - 0.5) * 0.2

        // More history = higher confidence
        if adaptationHistory.count > 5 {
            confidence += 0.1
        }

        // Cap confidence
        return min(0.95, max(0.3, confidence))
    }

    private func requiresAdaptation(_ decision: AdaptationDecision) -> Bool {
        // Check if decision actually contains changes

        let envChanges = decision.environmentAdjustments
        let audioChanges = decision.audioAdjustments

        let hasEnvChanges = envChanges.lightnessLevel != nil ||
                           envChanges.colorTemperature != nil ||
                           envChanges.particleDensity != nil ||
                           envChanges.animationSpeed != nil ||
                           envChanges.weatherMood != nil

        let hasAudioChanges = audioChanges.ambienceVolume != nil ||
                             audioChanges.natureVolume != nil ||
                             audioChanges.guidanceVolume != nil ||
                             audioChanges.binauralIntensity != nil ||
                             audioChanges.frequency != nil

        let hasGuidance = !decision.guidanceRecommendations.isEmpty

        return hasEnvChanges || hasAudioChanges || hasGuidance
    }

    // MARK: - Learning

    func recordAdaptationEffectiveness(wasEffective: Bool) {
        // Update last adaptation record with effectiveness
        if var lastRecord = adaptationHistory.last {
            lastRecord.wasEffective = wasEffective
            adaptationHistory[adaptationHistory.count - 1] = lastRecord
        }
    }

    func getAdaptationEffectiveness() -> Float {
        // Calculate overall effectiveness of adaptations
        let evaluatedAdaptations = adaptationHistory.filter { $0.wasEffective != nil }

        guard !evaluatedAdaptations.isEmpty else { return 0.5 }

        let successCount = evaluatedAdaptations.filter { $0.wasEffective == true }.count
        return Float(successCount) / Float(evaluatedAdaptations.count)
    }

    // MARK: - Personalization

    func getPersonalizedRecommendations() -> [String] {
        // Analyze history to provide personalized insights
        var recommendations: [String] = []

        guard adaptationHistory.count > 10 else {
            return ["Continue practicing to receive personalized insights"]
        }

        // Analyze stress patterns
        let highStressAdaptations = adaptationHistory.filter {
            $0.biometricSnapshot.estimatedStressLevel > highStressThreshold
        }

        if Float(highStressAdaptations.count) / Float(adaptationHistory.count) > 0.5 {
            recommendations.append("You often start sessions with elevated stress. Consider 2-3 deep breaths before beginning.")
        }

        // Analyze meditation depth
        let deepSessions = adaptationHistory.filter {
            $0.biometricSnapshot.meditationDepth == .deep
        }

        if deepSessions.count > 5 {
            recommendations.append("You've achieved deep meditation \(deepSessions.count) times. Consider longer sessions to explore this state further.")
        }

        return recommendations
    }
}
