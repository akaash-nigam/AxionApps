import Foundation

/// Generates personalized meditation guidance based on user state and preferences
actor GuidanceGenerator {

    // MARK: - Types

    struct GuidanceContent {
        let text: String
        let audioScript: String
        let displayDuration: TimeInterval
        let voiceCharacteristics: VoiceCharacteristics
        let category: GuidanceCategory
    }

    enum GuidanceCategory {
        case welcome
        case breathingInstruction
        case bodyAwareness
        case mindWandering
        case encouragement
        case deepening
        case transition
        case closing
    }

    struct VoiceCharacteristics {
        let tone: Tone
        let pace: Pace
        let volume: Volume

        enum Tone {
            case warm
            case neutral
            case gentle
            case encouraging
        }

        enum Pace {
            case slow
            case moderate
            case natural
        }

        enum Volume {
            case soft
            case normal
            case clear
        }
    }

    // MARK: - Private Properties

    private var userPreferences: UserGuidancePreferences
    private var sessionContext: SessionContext?

    struct UserGuidancePreferences {
        var verbosity: Verbosity
        var voiceTone: VoiceCharacteristics.Tone
        var guidanceFrequency: GuidanceFrequency

        enum Verbosity {
            case minimal
            case moderate
            case detailed
        }

        enum GuidanceFrequency {
            case rare // Every 5-10 minutes
            case occasional // Every 3-5 minutes
            case frequent // Every 1-2 minutes
        }
    }

    struct SessionContext {
        let technique: MeditationTechnique
        let environmentID: String
        let sessionDuration: TimeInterval
        let userExperience: ExperienceLevel
    }

    // MARK: - Initialization

    init(preferences: UserGuidancePreferences = UserGuidancePreferences(
        verbosity: .moderate,
        voiceTone: .warm,
        guidanceFrequency: .occasional
    )) {
        self.userPreferences = preferences
    }

    // MARK: - Public Methods

    func setSessionContext(_ context: SessionContext) {
        self.sessionContext = context
    }

    func generateWelcome() async -> GuidanceContent {
        guard let context = sessionContext else {
            return defaultWelcome()
        }

        let text: String
        let script: String

        switch context.userExperience {
        case .beginner:
            text = "Welcome. Find a comfortable position and allow yourself to settle."
            script = "Welcome to your meditation practice. Take a moment to find a comfortable position. You can close your eyes, or keep them gently open. There's no rush. Just allow yourself to settle into this moment."

        case .intermediate:
            text = "Welcome. Take a moment to arrive and settle in."
            script = "Welcome. Take a moment to arrive fully in this space. Notice your body, your breath, and begin to settle in."

        case .advanced, .expert:
            text = "Welcome to your practice."
            script = "Welcome to your practice. Allow yourself to settle."
        }

        return GuidanceContent(
            text: text,
            audioScript: script,
            displayDuration: 5.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: userPreferences.voiceTone,
                pace: .slow,
                volume: .normal
            ),
            category: .welcome
        )
    }

    func generateBreathingGuidance(currentState: BiometricSnapshot) async -> GuidanceContent {
        let breathingRate = currentState.breathingRate ?? 16.0

        let text: String
        let script: String

        if breathingRate > 18 {
            // Rapid breathing - guide to slow down
            text = "Notice your breath. No need to change it, just observe."
            script = "Bring your attention to your breath. Notice each inhale, and each exhale. There's no need to change anything. Just observe with gentle curiosity."

        } else if breathingRate < 10 {
            // Very slow - reinforce
            text = "Beautiful, steady breathing. Stay with this rhythm."
            script = "Your breathing has found a beautiful, steady rhythm. Stay with this. Notice the peace that comes with each slow breath."

        } else {
            // Normal range
            text = "Follow the natural rhythm of your breath."
            script = "Simply follow the natural rhythm of your breathing. In, and out. Each breath anchoring you more deeply in this moment."
        }

        return GuidanceContent(
            text: text,
            audioScript: script,
            displayDuration: 4.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: .gentle,
                pace: .slow,
                volume: .soft
            ),
            category: .breathingInstruction
        )
    }

    func generateMindWanderingGuidance() async -> GuidanceContent {
        let variations = [
            ("Mind wandering is natural. Gently return to your breath.",
             "If you notice your mind has wandered, that's perfectly natural. Simply acknowledge it with kindness, and gently guide your attention back to your breath."),

            ("Notice where your mind has gone, then come back to the present.",
             "When you notice thoughts arising, acknowledge them without judgment. Then, kindly return your awareness to this present moment."),

            ("Thoughts will come and go. Let them pass like clouds.",
             "Thoughts will naturally arise and pass away, like clouds moving across the sky. You don't need to engage with them. Simply notice, and return to your anchor.")
        ]

        let selected = variations.randomElement()!

        return GuidanceContent(
            text: selected.0,
            audioScript: selected.1,
            displayDuration: 6.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: .warm,
                pace: .moderate,
                volume: .normal
            ),
            category: .mindWandering
        )
    }

    func generateEncouragement(progress: Float) async -> GuidanceContent {
        let text: String
        let script: String

        if progress > 0.8 {
            text = "You're doing wonderfully. Maintain this depth."
            script = "You're doing wonderfully. Your practice is deepening beautifully. Simply maintain this quality of awareness."

        } else if progress > 0.5 {
            text = "You're settling in nicely. Keep going."
            script = "You're settling in nicely. Each moment of practice strengthens your capacity for awareness. Keep going just as you are."

        } else {
            text = "Be patient with yourself. Every moment of practice counts."
            script = "Remember to be patient and kind with yourself. Every moment you spend in practice is valuable, regardless of how it feels. You're doing exactly what you need to be doing."
        }

        return GuidanceContent(
            text: text,
            audioScript: script,
            displayDuration: 5.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: .encouraging,
                pace: .natural,
                volume: .normal
            ),
            category: .encouragement
        )
    }

    func generateDeepeningGuidance(meditationDepth: MeditationDepth) async -> GuidanceContent {
        let text: String
        let script: String

        switch meditationDepth {
        case .settling:
            text = "Gradually allow yourself to settle more deeply."
            script = "With each breath, allow yourself to settle more deeply. Release any tension you notice. Let your awareness expand."

        case .light:
            text = "Notice the space between thoughts. Rest there."
            script = "As your mind quiets, you may notice spaces between thoughts. Rest in that spaciousness. That's the nature of awareness itself."

        case .moderate:
            text = "Beautiful depth. Let awareness itself be the meditation."
            script = "You've found a beautiful depth. Now, let pure awareness itself become the meditation. Nothing to do, nowhere to go. Just this."

        case .deep:
            text = "Rest in this depth."
            script = "Rest in this profound depth. Simply be."
        }

        return GuidanceContent(
            text: text,
            audioScript: script,
            displayDuration: 5.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: .gentle,
                pace: .slow,
                volume: .soft
            ),
            category: .deepening
        )
    }

    func generateBodyScanGuidance(phase: BodyScanPhase) async -> GuidanceContent {
        let text: String
        let script: String

        switch phase {
        case .feet:
            text = "Bring awareness to your feet."
            script = "Bring your awareness to your feet. Notice any sensations there. Warmth, coolness, tingling, or perhaps nothing at all. Whatever you find is perfectly fine."

        case .legs:
            text = "Scan your awareness up through your legs."
            script = "Gently scan your awareness up through your legs. Your calves, knees, thighs. Simply noticing sensations without judgment."

        case .torso:
            text = "Notice your torso, your breath moving in this area."
            script = "Bring awareness to your torso. Feel your breath moving through this area. Your belly rising and falling. Your chest expanding and releasing."

        case .arms:
            text = "Become aware of your arms and hands."
            script = "Shift your attention to your arms and hands. Notice any sensations. The weight of your hands. Any areas of contact or tension."

        case .head:
            text = "Bring gentle awareness to your head and face."
            script = "Finally, bring gentle awareness to your head and face. Notice your jaw, your forehead, the space between your eyebrows. Let any tension soften."

        case .whole:
            text = "Now, sense your body as a whole."
            script = "Now, expand your awareness to sense your body as a whole. Breathing, alive, present. Rest in this full-body awareness."
        }

        return GuidanceContent(
            text: text,
            audioScript: script,
            displayDuration: 6.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: .gentle,
                pace: .slow,
                volume: .soft
            ),
            category: .bodyAwareness
        )
    }

    enum BodyScanPhase {
        case feet, legs, torso, arms, head, whole
    }

    func generateClosing(sessionQuality: Float) async -> GuidanceContent {
        let text: String
        let script: String

        if sessionQuality > 0.7 {
            text = "Wonderful practice. Slowly begin to return."
            script = "That was a wonderful practice. Take a moment to appreciate what you've cultivated here. When you're ready, slowly begin to return. Gently move your fingers and toes. Take your time."

        } else {
            text = "Thank you for your practice. Gently return when ready."
            script = "Thank you for dedicating this time to your practice. However it went, it was exactly what you needed. When you're ready, gently begin to return to your surroundings. There's no rush."
        }

        return GuidanceContent(
            text: text,
            audioScript: script,
            displayDuration: 8.0,
            voiceCharacteristics: VoiceCharacteristics(
                tone: .warm,
                pace: .slow,
                volume: .normal
            ),
            category: .closing
        )
    }

    // MARK: - Technique-Specific Guidance

    func generateTechniqueGuidance(technique: MeditationTechnique, phase: TechniquePhase) async -> GuidanceContent {
        switch technique {
        case .breathAwareness:
            return await generateBreathAwarenessGuidance(phase: phase)
        case .bodyScan:
            return await generateBodyScanInstruction(phase: phase)
        case .lovingKindness:
            return await generateLovingKindnessGuidance(phase: phase)
        case .mindfulObservation:
            return await generateObservationGuidance(phase: phase)
        case .mantraRepetition:
            return await generateMantraGuidance(phase: phase)
        case .visualization:
            return await generateVisualizationGuidance(phase: phase)
        case .walkingMeditation:
            return await generateWalkingGuidance(phase: phase)
        case .soundMeditation:
            return await generateSoundGuidance(phase: phase)
        }
    }

    enum TechniquePhase {
        case introduction
        case practice
        case deepening
        case completion
    }

    // MARK: - Private Helper Methods

    private func defaultWelcome() -> GuidanceContent {
        GuidanceContent(
            text: "Welcome to your practice.",
            audioScript: "Welcome to your meditation practice. Take a moment to arrive and settle in.",
            displayDuration: 4.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .warm, pace: .moderate, volume: .normal),
            category: .welcome
        )
    }

    private func generateBreathAwarenessGuidance(phase: TechniquePhase) async -> GuidanceContent {
        switch phase {
        case .introduction:
            return GuidanceContent(
                text: "We'll focus on the breath as our anchor.",
                audioScript: "In this practice, we'll use the breath as our anchor. Simply observe each inhale and exhale, without trying to control it.",
                displayDuration: 6.0,
                voiceCharacteristics: VoiceCharacteristics(tone: .warm, pace: .moderate, volume: .normal),
                category: .breathingInstruction
            )
        case .practice:
            return await generateBreathingGuidance(currentState: BiometricSnapshot.neutral())
        case .deepening:
            return GuidanceContent(
                text: "Notice the subtle sensations of breathing.",
                audioScript: "Begin to notice the subtle sensations. The coolness of the in-breath. The warmth of the out-breath. The pause between breaths.",
                displayDuration: 6.0,
                voiceCharacteristics: VoiceCharacteristics(tone: .gentle, pace: .slow, volume: .soft),
                category: .deepening
            )
        case .completion:
            return await generateClosing(sessionQuality: 0.7)
        }
    }

    private func generateBodyScanInstruction(phase: TechniquePhase) async -> GuidanceContent {
        // Simplified - would have more detailed implementation
        return await generateBodyScanGuidance(phase: .feet)
    }

    private func generateLovingKindnessGuidance(phase: TechniquePhase) async -> GuidanceContent {
        GuidanceContent(
            text: "May I be happy, may I be peaceful.",
            audioScript: "Silently repeat: May I be happy. May I be healthy. May I be safe. May I live with ease.",
            displayDuration: 8.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .warm, pace: .slow, volume: .soft),
            category: .deepening
        )
    }

    private func generateObservationGuidance(phase: TechniquePhase) async -> GuidanceContent {
        GuidanceContent(
            text: "Simply observe without judgment.",
            audioScript: "Notice whatever arises in your experience. Thoughts, sensations, sounds. Simply observe without engaging or judging.",
            displayDuration: 6.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .neutral, pace: .natural, volume: .normal),
            category: .deepening
        )
    }

    private func generateMantraGuidance(phase: TechniquePhase) async -> GuidanceContent {
        GuidanceContent(
            text: "Repeat your chosen mantra gently.",
            audioScript: "Silently repeat your mantra. When your mind wanders, gently return to the repetition.",
            displayDuration: 5.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .neutral, pace: .moderate, volume: .soft),
            category: .deepening
        )
    }

    private func generateVisualizationGuidance(phase: TechniquePhase) async -> GuidanceContent {
        GuidanceContent(
            text: "Visualize a peaceful scene.",
            audioScript: "Imagine a place of complete peace and safety. See it clearly in your mind's eye. Notice the details.",
            displayDuration: 7.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .gentle, pace: .slow, volume: .soft),
            category: .deepening
        )
    }

    private func generateWalkingGuidance(phase: TechniquePhase) async -> GuidanceContent {
        GuidanceContent(
            text: "Feel each step mindfully.",
            audioScript: "Walk slowly. Feel each foot lift, move through space, and make contact with the ground. Fully present with each step.",
            displayDuration: 6.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .neutral, pace: .moderate, volume: .normal),
            category: .bodyAwareness
        )
    }

    private func generateSoundGuidance(phase: TechniquePhase) async -> GuidanceContent {
        GuidanceContent(
            text: "Listen to sounds as they arise and pass.",
            audioScript: "Simply listen. Notice sounds arising and passing away. Near and far. Loud and soft. Just listening, without labeling.",
            displayDuration: 6.0,
            voiceCharacteristics: VoiceCharacteristics(tone: .neutral, pace: .natural, volume: .normal),
            category: .deepening
        )
    }
}
