//
//  SpatialAudioManager.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import AVFoundation
import RealityKit

// MARK: - Spatial Audio Manager

/// Manages spatial audio cues for visionOS interactions
/// Provides 3D positioned audio feedback for UI interactions and data events
@MainActor
@Observable
final class SpatialAudioManager {
    // MARK: - Singleton

    static let shared = SpatialAudioManager()

    // MARK: - Properties

    /// Whether spatial audio is enabled
    var isEnabled: Bool = true

    /// Master volume (0.0 to 1.0)
    var masterVolume: Float = 0.8 {
        didSet {
            updateAllVolumes()
        }
    }

    /// Whether haptic feedback is enabled alongside audio
    var hapticsEnabled: Bool = true

    // MARK: - Audio Categories

    enum AudioCategory: String, CaseIterable {
        case interaction  // UI interaction sounds
        case notification // Alerts and notifications
        case ambient      // Background atmosphere
        case data         // Data update sounds

        var defaultVolume: Float {
            switch self {
            case .interaction: return 0.6
            case .notification: return 0.8
            case .ambient: return 0.3
            case .data: return 0.4
            }
        }
    }

    // MARK: - Sound Effects

    enum SoundEffect: String {
        // Interaction sounds
        case tap = "tap"
        case select = "select"
        case drag = "drag"
        case drop = "drop"
        case pinch = "pinch"
        case release = "release"

        // Navigation sounds
        case windowOpen = "window_open"
        case windowClose = "window_close"
        case immersiveEnter = "immersive_enter"
        case immersiveExit = "immersive_exit"

        // Data sounds
        case dataUpdate = "data_update"
        case dataSync = "data_sync"
        case kpiAlert = "kpi_alert"
        case reportReady = "report_ready"

        // Notification sounds
        case success = "success"
        case warning = "warning"
        case error = "error"
        case info = "info"

        // Ambient sounds
        case ambientHum = "ambient_hum"
        case dataFlow = "data_flow"

        var category: AudioCategory {
            switch self {
            case .tap, .select, .drag, .drop, .pinch, .release:
                return .interaction
            case .windowOpen, .windowClose, .immersiveEnter, .immersiveExit:
                return .interaction
            case .dataUpdate, .dataSync, .kpiAlert, .reportReady:
                return .data
            case .success, .warning, .error, .info:
                return .notification
            case .ambientHum, .dataFlow:
                return .ambient
            }
        }

        var duration: TimeInterval {
            switch self {
            case .tap, .pinch: return 0.1
            case .select, .release: return 0.15
            case .drag: return 0.05
            case .drop: return 0.2
            case .windowOpen, .windowClose: return 0.3
            case .immersiveEnter, .immersiveExit: return 0.5
            case .dataUpdate, .dataSync: return 0.25
            case .kpiAlert, .reportReady: return 0.4
            case .success, .info: return 0.3
            case .warning: return 0.35
            case .error: return 0.4
            case .ambientHum, .dataFlow: return 2.0  // Looping
            }
        }
    }

    // MARK: - Private Properties

    private var categoryVolumes: [AudioCategory: Float] = [:]
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var spatialEntities: [String: Entity] = [:]
    private var ambientLoops: [SoundEffect: Bool] = [:]

    // MARK: - Initialization

    private init() {
        setupAudioSession()
        setupCategoryVolumes()
        preloadSounds()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func setupCategoryVolumes() {
        for category in AudioCategory.allCases {
            categoryVolumes[category] = category.defaultVolume
        }
    }

    private func preloadSounds() {
        // In production, preload actual audio files
        // For now, we'll use system sounds as placeholders
    }

    // MARK: - Volume Control

    /// Set volume for a specific category
    func setVolume(_ volume: Float, for category: AudioCategory) {
        categoryVolumes[category] = max(0, min(1, volume))
    }

    /// Get volume for a specific category
    func getVolume(for category: AudioCategory) -> Float {
        return categoryVolumes[category] ?? category.defaultVolume
    }

    private func updateAllVolumes() {
        // Update all playing audio with new master volume
    }

    private func effectiveVolume(for effect: SoundEffect) -> Float {
        let categoryVolume = categoryVolumes[effect.category] ?? effect.category.defaultVolume
        return masterVolume * categoryVolume
    }

    // MARK: - Play Sounds

    /// Play a sound effect at a specific position
    func play(_ effect: SoundEffect, at position: SIMD3<Float>? = nil) {
        guard isEnabled else { return }

        let volume = effectiveVolume(for: effect)

        if let position = position {
            playSpatialSound(effect, at: position, volume: volume)
        } else {
            playSound(effect, volume: volume)
        }

        // Trigger haptic if enabled
        if hapticsEnabled {
            triggerHaptic(for: effect)
        }
    }

    /// Play a sound for a specific entity
    func play(_ effect: SoundEffect, for entity: Entity) {
        guard isEnabled else { return }

        let position = entity.position(relativeTo: nil)
        play(effect, at: position)
    }

    private func playSound(_ effect: SoundEffect, volume: Float) {
        // Use AudioServicesPlaySystemSound for simple sounds
        // In production, use AVAudioPlayer with actual audio files

        Task {
            // Placeholder: Use system sound IDs
            let soundID = systemSoundID(for: effect)
            if soundID > 0 {
                AudioServicesPlaySystemSoundWithCompletion(soundID, nil)
            }
        }
    }

    private func playSpatialSound(_ effect: SoundEffect, at position: SIMD3<Float>, volume: Float) {
        // For RealityKit spatial audio, we'd attach audio to an entity
        // This is a simplified implementation

        Task {
            // Create a temporary entity for spatial audio
            let audioEntity = Entity()
            audioEntity.position = position

            // In production, add AudioFileResource and SpatialAudioComponent
            // let audioResource = try? await AudioFileResource.load(named: effect.rawValue)
            // audioEntity.playAudio(audioResource)

            // For now, fall back to non-spatial
            playSound(effect, volume: volume)
        }
    }

    private func systemSoundID(for effect: SoundEffect) -> SystemSoundID {
        // Map effects to system sound IDs (these are iOS system sounds)
        switch effect {
        case .tap: return 1104
        case .select: return 1105
        case .success: return 1075
        case .warning: return 1073
        case .error: return 1053
        case .info: return 1117
        default: return 1104  // Default tap sound
        }
    }

    // MARK: - Haptic Feedback

    private func triggerHaptic(for effect: SoundEffect) {
        let intensity: Float
        let sharpness: Float

        switch effect {
        case .tap, .pinch:
            intensity = 0.5
            sharpness = 0.8
        case .select, .drop:
            intensity = 0.7
            sharpness = 0.6
        case .success:
            intensity = 0.8
            sharpness = 0.5
        case .warning:
            intensity = 0.9
            sharpness = 0.7
        case .error:
            intensity = 1.0
            sharpness = 0.9
        default:
            intensity = 0.4
            sharpness = 0.5
        }

        // Trigger haptic using UIImpactFeedbackGenerator equivalent
        // In visionOS, this would use the appropriate haptic API
        _ = intensity
        _ = sharpness
    }

    // MARK: - Ambient Audio

    /// Start ambient background audio
    func startAmbient(_ effect: SoundEffect, fadeIn: TimeInterval = 1.0) {
        guard isEnabled, effect.category == .ambient else { return }
        guard ambientLoops[effect] != true else { return }

        ambientLoops[effect] = true

        // In production, start looping audio with fade-in
        Task {
            // Fade in ambient sound
            for step in stride(from: 0.0, to: 1.0, by: 0.1) {
                try? await Task.sleep(nanoseconds: UInt64(fadeIn * 100_000_000))
                // Update volume gradually
                _ = Float(step) * effectiveVolume(for: effect)
            }
        }
    }

    /// Stop ambient background audio
    func stopAmbient(_ effect: SoundEffect, fadeOut: TimeInterval = 1.0) {
        guard effect.category == .ambient else { return }
        guard ambientLoops[effect] == true else { return }

        ambientLoops[effect] = false

        // In production, stop looping audio with fade-out
    }

    /// Stop all ambient audio
    func stopAllAmbient(fadeOut: TimeInterval = 1.0) {
        for effect in SoundEffect.allCases where effect.category == .ambient {
            stopAmbient(effect, fadeOut: fadeOut)
        }
    }

    // MARK: - Convenience Methods

    /// Play interaction feedback for common gestures
    func playGestureFeedback(_ gesture: GestureType) {
        switch gesture {
        case .tap:
            play(.tap)
        case .doubleTap:
            play(.select)
        case .longPress:
            play(.pinch)
        case .drag:
            play(.drag)
        case .pinch:
            play(.pinch)
        }
    }

    /// Play feedback for data events
    func playDataFeedback(_ event: DataEvent, at position: SIMD3<Float>? = nil) {
        switch event {
        case .updated:
            play(.dataUpdate, at: position)
        case .synced:
            play(.dataSync, at: position)
        case .alert:
            play(.kpiAlert, at: position)
        }
    }

    /// Play feedback for navigation events
    func playNavigationFeedback(_ event: NavigationEvent) {
        switch event {
        case .windowOpened:
            play(.windowOpen)
        case .windowClosed:
            play(.windowClose)
        case .enteredImmersive:
            play(.immersiveEnter)
        case .exitedImmersive:
            play(.immersiveExit)
        }
    }

    // MARK: - Types

    enum GestureType {
        case tap
        case doubleTap
        case longPress
        case drag
        case pinch
    }

    enum DataEvent {
        case updated
        case synced
        case alert
    }

    enum NavigationEvent {
        case windowOpened
        case windowClosed
        case enteredImmersive
        case exitedImmersive
    }
}

// MARK: - Sound Effect CaseIterable

extension SpatialAudioManager.SoundEffect: CaseIterable {
    static var allCases: [SpatialAudioManager.SoundEffect] {
        [
            .tap, .select, .drag, .drop, .pinch, .release,
            .windowOpen, .windowClose, .immersiveEnter, .immersiveExit,
            .dataUpdate, .dataSync, .kpiAlert, .reportReady,
            .success, .warning, .error, .info,
            .ambientHum, .dataFlow
        ]
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

/// View modifier for adding audio feedback to interactions
struct AudioFeedbackModifier: ViewModifier {
    let effect: SpatialAudioManager.SoundEffect

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                SpatialAudioManager.shared.play(effect)
            }
    }
}

extension View {
    /// Add audio feedback on tap
    func audioFeedback(_ effect: SpatialAudioManager.SoundEffect) -> some View {
        modifier(AudioFeedbackModifier(effect: effect))
    }

    /// Add standard tap audio feedback
    func tapAudioFeedback() -> some View {
        modifier(AudioFeedbackModifier(effect: .tap))
    }
}

// MARK: - RealityKit Integration

extension Entity {
    /// Play spatial audio at this entity's position
    @MainActor
    func playSpatialAudio(_ effect: SpatialAudioManager.SoundEffect) {
        SpatialAudioManager.shared.play(effect, for: self)
    }
}
