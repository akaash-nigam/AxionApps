import Foundation
import ARKit

/// AI system for detecting player emotions through facial expressions and gaze patterns
@MainActor
class EmotionRecognitionAI {

    // MARK: - Properties
    private var recentEmotions: [TimedEmotion] = []
    private var gazeHistory: [GazePoint] = []
    private var baselineEstablished = false
    private var emotionBaseline: EmotionBaseline?

    // MARK: - Emotion Detection

    /// Detect player emotion from facial tracking data
    func detectEmotion(faceAnchor: ARFaceAnchor) async -> Emotion {
        let blendShapes = faceAnchor.blendShapes

        // Extract blend shape values
        let smileAmount = getBlendShapeValue(blendShapes, .mouthSmileLeft) +
                         getBlendShapeValue(blendShapes, .mouthSmileRight)

        let frownAmount = getBlendShapeValue(blendShapes, .mouthFrownLeft) +
                         getBlendShapeValue(blendShapes, .mouthFrownRight)

        let eyebrowRaise = getBlendShapeValue(blendShapes, .browInnerUp) +
                          getBlendShapeValue(blendShapes, .browOuterUpLeft) +
                          getBlendShapeValue(blendShapes, .browOuterUpRight)

        let eyebrowFurrow = getBlendShapeValue(blendShapes, .browDownLeft) +
                           getBlendShapeValue(blendShapes, .browDownRight)

        let jawOpen = getBlendShapeValue(blendShapes, .jawOpen)

        // Determine dominant emotion
        let detectedEmotion: Emotion
        if smileAmount > 0.5 {
            detectedEmotion = .happy
        } else if frownAmount > 0.4 {
            detectedEmotion = .sad
        } else if eyebrowFurrow > 0.6 {
            detectedEmotion = .angry
        } else if eyebrowRaise > 0.7 && jawOpen > 0.3 {
            detectedEmotion = .surprised
        } else if eyebrowRaise > 0.6 && frownAmount > 0.2 {
            detectedEmotion = .fearful
        } else {
            detectedEmotion = .neutral
        }

        // Record emotion with timestamp
        recordEmotion(detectedEmotion)

        return detectedEmotion
    }

    /// Measure player engagement through gaze and attention patterns
    func measureEngagement(gazeHistory: [GazePoint]) -> Float {
        self.gazeHistory = gazeHistory

        guard gazeHistory.count > 10 else { return 0.5 } // Default mid-level

        var engagementScore: Float = 0

        // Looking at characters/story elements → high engagement
        let focusedGazes = gazeHistory.filter { $0.target != nil }.count
        let focusRatio = Float(focusedGazes) / Float(gazeHistory.count)
        engagementScore += focusRatio * 0.5

        // Rapid eye movements → confusion or overwhelm
        let rapidMovements = calculateRapidMovements(gazeHistory)
        if rapidMovements > 0.3 {
            engagementScore -= 0.2 // Overwhelmed
        }

        // Looking away frequently → disengagement
        let lookAwayCount = gazeHistory.filter { $0.lookingAway }.count
        let lookAwayRatio = Float(lookAwayCount) / Float(gazeHistory.count)
        engagementScore -= lookAwayRatio * 0.3

        // Sustained focus → high engagement
        let longestFocus = calculateLongestFocusDuration(gazeHistory)
        if longestFocus > 10.0 {
            engagementScore += 0.3
        }

        return max(0, min(1.0, 0.5 + engagementScore))
    }

    /// Adapt story based on detected emotion
    func adaptStoryToEmotion(detectedEmotion: Emotion) -> EmotionAdaptation {
        var adaptation = EmotionAdaptation()

        switch detectedEmotion {
        case .fearful, .sad:
            // Player seems uncomfortable
            adaptation.easeTension = true
            adaptation.insertComfortMoment = true

        case .happy:
            // Player enjoying experience
            adaptation.maintainPace = true

        case .angry:
            // Player frustrated
            adaptation.offerHelp = true
            adaptation.easeTension = true

        case .neutral:
            // Player seems disengaged
            adaptation.increaseIntensity = true

        case .surprised:
            // Good surprise, maintain momentum
            adaptation.maintainPace = true

        default:
            adaptation.maintainPace = true
        }

        return adaptation
    }

    /// Establish baseline emotional state
    func establishBaseline(samples: [ARFaceAnchor]) async {
        var neutralCount = 0
        var sampleEmotions: [Emotion] = []

        for anchor in samples {
            let emotion = await detectEmotion(faceAnchor: anchor)
            sampleEmotions.append(emotion)
            if emotion == .neutral {
                neutralCount += 1
            }
        }

        emotionBaseline = EmotionBaseline(
            dominantEmotion: .neutral,
            neutralPercentage: Float(neutralCount) / Float(samples.count)
        )
        baselineEstablished = true
    }

    // MARK: - Private Methods

    private func getBlendShapeValue(
        _ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber],
        _ location: ARFaceAnchor.BlendShapeLocation
    ) -> Float {
        return blendShapes[location]?.floatValue ?? 0
    }

    private func recordEmotion(_ emotion: Emotion) {
        let timedEmotion = TimedEmotion(emotion: emotion, timestamp: Date())
        recentEmotions.append(timedEmotion)

        // Keep only last 50 emotions
        if recentEmotions.count > 50 {
            recentEmotions.removeFirst()
        }
    }

    private func calculateRapidMovements(_ gazes: [GazePoint]) -> Float {
        var rapidCount = 0
        for i in 1..<gazes.count {
            let timeDelta = gazes[i].timestamp.timeIntervalSince(gazes[i-1].timestamp)
            if timeDelta < 0.1 { // Less than 100ms between gazes
                rapidCount += 1
            }
        }
        return Float(rapidCount) / Float(max(gazes.count - 1, 1))
    }

    private func calculateLongestFocusDuration(_ gazes: [GazePoint]) -> TimeInterval {
        var longestDuration: TimeInterval = 0
        var currentStart: Date?
        var currentTarget: String?

        for gaze in gazes {
            if gaze.target == currentTarget && currentTarget != nil {
                // Continuing to focus on same target
                continue
            } else {
                // Changed target or started new focus
                if let start = currentStart, let target = currentTarget, target == gaze.target {
                    let duration = gaze.timestamp.timeIntervalSince(start)
                    longestDuration = max(longestDuration, duration)
                }
                currentStart = gaze.timestamp
                currentTarget = gaze.target
            }
        }

        return longestDuration
    }
}

// MARK: - Supporting Types

struct TimedEmotion {
    let emotion: Emotion
    let timestamp: Date
}

struct GazePoint {
    let timestamp: Date
    let target: String? // Entity ID being looked at
    let lookingAway: Bool
    let position: SIMD3<Float>
}

struct EmotionBaseline {
    let dominantEmotion: Emotion
    let neutralPercentage: Float
}

struct EmotionAdaptation {
    var easeTension = false
    var insertComfortMoment = false
    var maintainPace = false
    var offerHelp = false
    var increaseIntensity = false
}
