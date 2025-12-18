import Foundation
import CoreHaptics

/// Manager for haptic feedback to enhance emotional and interaction moments
@MainActor
class HapticFeedbackManager {

    // MARK: - Properties
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false

    // MARK: - Initialization
    init() {
        setupHaptics()
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            supportsHaptics = false
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
            supportsHaptics = true

            // Reset handler
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }

            // Stopped handler
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
            supportsHaptics = false
        }
    }

    // MARK: - Emotional Haptics

    /// Play haptic pattern matching an emotion
    func playEmotionalHaptic(emotion: Emotion, intensity: Float) {
        guard supportsHaptics else { return }

        switch emotion {
        case .fearful:
            playHeartbeatPattern(bpm: 90 + Int(intensity * 40))
        case .happy:
            playJoyfulTap()
        case .sad:
            playSomberPulse()
        case .angry:
            playSharpPulses(count: 3)
        case .surprised:
            playQuickShock()
        default:
            playSubtlePulse()
        }
    }

    /// Play heartbeat haptic pattern
    private func playHeartbeatPattern(bpm: Int) {
        let interval = 60.0 / Double(bpm)

        var events: [CHHapticEvent] = []
        let time: TimeInterval = 0

        for i in 0..<10 {
            let beatTime = time + Double(i) * interval

            // Lub
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: beatTime
            ))

            // Dub
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: beatTime + 0.15
            ))
        }

        playPattern(events: events)
    }

    private func playJoyfulTap() {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            )
        ]
        playPattern(events: events)
    }

    private func playSomberPulse() {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0,
                duration: 1.0
            )
        ]
        playPattern(events: events)
    }

    private func playSharpPulses(count: Int) {
        var events: [CHHapticEvent] = []
        for i in 0..<count {
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: Double(i) * 0.2
            ))
        }
        playPattern(events: events)
    }

    private func playQuickShock() {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            )
        ]
        playPattern(events: events)
    }

    private func playSubtlePulse() {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
        ]
        playPattern(events: events)
    }

    // MARK: - Interaction Haptics

    /// Play feedback for choice selection
    func playChoiceSelection() {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0
            )
        ]
        playPattern(events: events)
    }

    /// Play feedback for object interaction
    func playObjectInteraction(type: InteractionHaptic) {
        switch type {
        case .pickup:
            playPickupHaptic()
        case .place:
            playPlaceHaptic()
        case .rotate:
            playRotateHaptic()
        }
    }

    private func playPickupHaptic() {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.05,
                duration: 0.2
            )
        ]
        playPattern(events: events)
    }

    private func playPlaceHaptic() {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0
            )
        ]
        playPattern(events: events)
    }

    private func playRotateHaptic() {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0,
                duration: 0.1
            )
        ]
        playPattern(events: events)
    }

    // MARK: - Helper Methods

    private func playPattern(events: [CHHapticEvent]) {
        guard supportsHaptics, let engine = engine else { return }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}

// MARK: - Supporting Types

enum InteractionHaptic {
    case pickup
    case place
    case rotate
}
