//
//  HapticsManager.swift
//  Parkour Pathways
//
//  Haptic feedback system for immersive tactile responses
//

import Foundation
import CoreHaptics

/// Manages haptic feedback for gameplay events
class HapticsManager {

    // MARK: - Properties

    private var engine: CHHapticEngine?
    private var isHapticsAvailable: Bool = false
    private var currentLoopingPattern: CHHapticPatternPlayer?

    // MARK: - Initialization

    init() {
        setupHaptics()
    }

    // MARK: - Setup

    private func setupHaptics() {
        // Check if haptics are available
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Haptics not available on this device")
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
            isHapticsAvailable = true

            // Setup handlers
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.restartEngine()
            }

            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                self?.restartEngine()
            }

        } catch {
            print("Failed to setup haptics: \(error)")
        }
    }

    private func restartEngine() {
        do {
            try engine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }

    // MARK: - Public API - Movement Haptics

    /// Play jump haptic feedback
    func playJumpHaptic(intensity: Float) {
        guard isHapticsAvailable else { return }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            )
        ]

        playPattern(events: events)
    }

    /// Play landing haptic feedback
    func playLandHaptic(impact: Float) {
        guard isHapticsAvailable else { return }

        // Create impact pattern with decay
        let events = [
            // Initial impact
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: impact),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            ),
            // Slight rumble after impact
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: impact * 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.05,
                duration: 0.15
            )
        ]

        playPattern(events: events)
    }

    /// Play vault haptic feedback
    func playVaultHaptic(type: VaultMechanic.VaultType) {
        guard isHapticsAvailable else { return }

        // Different patterns for different vault types
        let intensity: Float = switch type {
        case .stepVault: 0.6
        case .speedVault: 0.8
        case .kongVault: 1.0
        case .lazyVault: 0.5
        }

        let events = [
            // Hand contact
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0
            ),
            // Push off
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0.1
            )
        ]

        playPattern(events: events)
    }

    /// Start wall run haptic feedback (looping)
    func playWallRunHaptic() {
        guard isHapticsAvailable else { return }

        // Create rhythmic pattern for wall contact
        var events: [CHHapticEvent] = []
        let steps = 10
        for i in 0..<steps {
            let time = TimeInterval(i) * 0.15
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                    ],
                    relativeTime: time
                )
            )
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            player?.start(atTime: 0)
            currentLoopingPattern = player
        } catch {
            print("Failed to play wall run haptic: \(error)")
        }
    }

    /// Stop wall run haptic feedback
    func stopWallRunHaptic() {
        guard isHapticsAvailable else { return }
        try? currentLoopingPattern?.stop(atTime: 0)
        currentLoopingPattern = nil
    }

    // MARK: - Public API - Game Event Haptics

    /// Play checkpoint reached haptic
    func playCheckpointHaptic() {
        guard isHapticsAvailable else { return }

        // Success pattern
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.2
            )
        ]

        playPattern(events: events)
    }

    /// Play course complete haptic
    func playCourseCompleteHaptic(score: Float) {
        guard isHapticsAvailable else { return }

        // Celebratory pattern
        var events: [CHHapticEvent] = []

        // Build crescendo based on score
        let pulseCount = Int(score * 5) + 3 // 3-8 pulses

        for i in 0..<pulseCount {
            let time = TimeInterval(i) * 0.08
            let intensity = 0.5 + (Float(i) / Float(pulseCount)) * 0.5

            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: time
                )
            )
        }

        playPattern(events: events)
    }

    /// Play achievement unlocked haptic
    func playAchievementHaptic() {
        guard isHapticsAvailable else { return }

        // Special achievement pattern
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0,
                duration: 0.2
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.25
            )
        ]

        playPattern(events: events)
    }

    /// Play countdown haptic
    func playCountdownHaptic(count: Int) {
        guard isHapticsAvailable else { return }

        let intensity: Float = count == 1 ? 1.0 : 0.7
        let sharpness: Float = count == 1 ? 1.0 : 0.5

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
        ]

        playPattern(events: events)
    }

    // MARK: - Public API - UI Haptics

    /// Light tap for UI interactions
    func playLightTap() {
        guard isHapticsAvailable else { return }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
        ]

        playPattern(events: events)
    }

    /// Error haptic feedback
    func playErrorHaptic() {
        guard isHapticsAvailable else { return }

        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0,
                duration: 0.3
            )
        ]

        playPattern(events: events)
    }

    /// Success haptic feedback
    func playSuccessHaptic() {
        guard isHapticsAvailable else { return }

        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.1
            )
        ]

        playPattern(events: events)
    }

    // MARK: - Private Helpers

    private func playPattern(events: [CHHapticEvent]) {
        guard isHapticsAvailable else { return }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        currentLoopingPattern = nil
        engine?.stop()
    }
}
