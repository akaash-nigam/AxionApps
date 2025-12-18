//
//  AudioManager.swift
//  Parkour Pathways
//
//  Central audio management system coordinating spatial audio, sound effects, and music
//

import Foundation
import AVFoundation
import RealityKit
import Combine

/// Central audio management system for the game
@MainActor
class AudioManager: ObservableObject {

    // MARK: - Published Properties

    @Published var isMusicEnabled: Bool = true {
        didSet {
            if isMusicEnabled {
                musicPlayer.resume()
            } else {
                musicPlayer.pause()
            }
        }
    }

    @Published var areSoundEffectsEnabled: Bool = true
    @Published var masterVolume: Float = 1.0 {
        didSet {
            updateMasterVolume()
        }
    }
    @Published var musicVolume: Float = 0.7 {
        didSet {
            musicPlayer.setVolume(musicVolume * masterVolume)
        }
    }
    @Published var sfxVolume: Float = 1.0 {
        didSet {
            soundEffectPlayer.setVolume(sfxVolume * masterVolume)
        }
    }

    // MARK: - Dependencies

    private let spatialAudioEngine: SpatialAudioEngine
    private let soundEffectPlayer: SoundEffectPlayer
    private let musicPlayer: MusicPlayer
    private let hapticsManager: HapticsManager

    // MARK: - State

    private var cancellables = Set<AnyCancellable>()
    private var currentGameState: GameState = .initializing

    // MARK: - Initialization

    init() {
        self.spatialAudioEngine = SpatialAudioEngine()
        self.soundEffectPlayer = SoundEffectPlayer()
        self.musicPlayer = MusicPlayer()
        self.hapticsManager = HapticsManager()

        setupAudioSession()
        preloadCommonSounds()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .spatialAudio)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func preloadCommonSounds() {
        Task {
            await soundEffectPlayer.preloadSounds([
                .jump,
                .land,
                .vault,
                .wallRun,
                .checkpointReached,
                .courseComplete,
                .achievementUnlocked,
                .countdown,
                .menuClick,
                .menuHover
            ])
        }
    }

    // MARK: - Public API - Game Events

    /// Play sound for player jump
    func playJumpSound(intensity: Float, position: SIMD3<Float>) {
        guard areSoundEffectsEnabled else { return }

        let volume = mix(0.6, 1.0, intensity)
        soundEffectPlayer.play(.jump, volume: volume)
        spatialAudioEngine.playSound(.jump, at: position, volume: volume)
        hapticsManager.playJumpHaptic(intensity: intensity)
    }

    /// Play sound for player landing
    func playLandSound(impact: Float, position: SIMD3<Float>) {
        guard areSoundEffectsEnabled else { return }

        let volume = mix(0.4, 1.0, impact)
        soundEffectPlayer.play(.land, volume: volume)
        spatialAudioEngine.playSound(.land, at: position, volume: volume)
        hapticsManager.playLandHaptic(impact: impact)
    }

    /// Play sound for vault movement
    func playVaultSound(type: VaultMechanic.VaultType, position: SIMD3<Float>) {
        guard areSoundEffectsEnabled else { return }

        soundEffectPlayer.play(.vault, volume: 0.8)
        spatialAudioEngine.playSound(.vault, at: position, volume: 0.8)
        hapticsManager.playVaultHaptic(type: type)
    }

    /// Play sound for wall run
    func playWallRunSound(position: SIMD3<Float>) {
        guard areSoundEffectsEnabled else { return }

        soundEffectPlayer.play(.wallRun, volume: 0.7)
        spatialAudioEngine.playSound(.wallRun, at: position, volume: 0.7, loop: true)
        hapticsManager.playWallRunHaptic()
    }

    /// Stop wall run sound (looping sound)
    func stopWallRunSound() {
        soundEffectPlayer.stop(.wallRun)
        spatialAudioEngine.stopSound(.wallRun)
        hapticsManager.stopWallRunHaptic()
    }

    /// Play checkpoint reached sound
    func playCheckpointSound(position: SIMD3<Float>) {
        guard areSoundEffectsEnabled else { return }

        soundEffectPlayer.play(.checkpointReached, volume: 1.0)
        spatialAudioEngine.playSound(.checkpointReached, at: position, volume: 1.0)
        hapticsManager.playCheckpointHaptic()
    }

    /// Play course complete sound
    func playCourseCompleteSound(score: Float) {
        guard areSoundEffectsEnabled else { return }

        soundEffectPlayer.play(.courseComplete, volume: 1.0)
        hapticsManager.playCourseCompleteHaptic(score: score)

        // Trigger celebration audio
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            soundEffectPlayer.play(.celebration, volume: 0.8)
        }
    }

    /// Play achievement unlocked sound
    func playAchievementSound() {
        guard areSoundEffectsEnabled else { return }

        soundEffectPlayer.play(.achievementUnlocked, volume: 1.0)
        hapticsManager.playAchievementHaptic()
    }

    /// Play countdown sound
    func playCountdownSound(count: Int) {
        guard areSoundEffectsEnabled else { return }

        let pitch = count == 1 ? 1.2 : 1.0 // Higher pitch on final count
        soundEffectPlayer.play(.countdown, volume: 1.0, pitch: pitch)
        hapticsManager.playCountdownHaptic(count: count)
    }

    // MARK: - Public API - UI Events

    /// Play menu click sound
    func playMenuClick() {
        guard areSoundEffectsEnabled else { return }
        soundEffectPlayer.play(.menuClick, volume: 0.5)
        hapticsManager.playLightTap()
    }

    /// Play menu hover sound
    func playMenuHover() {
        guard areSoundEffectsEnabled else { return }
        soundEffectPlayer.play(.menuHover, volume: 0.3)
    }

    /// Play error/warning sound
    func playErrorSound() {
        guard areSoundEffectsEnabled else { return }
        soundEffectPlayer.play(.error, volume: 0.7)
        hapticsManager.playErrorHaptic()
    }

    /// Play success/confirmation sound
    func playSuccessSound() {
        guard areSoundEffectsEnabled else { return }
        soundEffectPlayer.play(.success, volume: 0.7)
        hapticsManager.playSuccessHaptic()
    }

    // MARK: - Public API - Music

    /// Start playing menu music
    func playMenuMusic() {
        guard isMusicEnabled else { return }
        musicPlayer.playTrack(.menu, fadeIn: 2.0)
    }

    /// Start playing gameplay music
    func playGameplayMusic(intensity: MusicIntensity = .medium) {
        guard isMusicEnabled else { return }

        let track: MusicTrack = switch intensity {
        case .low: .gameplayCalm
        case .medium: .gameplayMedium
        case .high: .gameplayIntense
        }

        musicPlayer.playTrack(track, fadeIn: 1.5)
    }

    /// Transition music intensity based on gameplay
    func updateMusicIntensity(_ intensity: MusicIntensity) {
        guard isMusicEnabled else { return }
        musicPlayer.transitionToIntensity(intensity, duration: 3.0)
    }

    /// Stop all music
    func stopMusic(fadeOut: TimeInterval = 1.0) {
        musicPlayer.stop(fadeOut: fadeOut)
    }

    // MARK: - Public API - Spatial Audio

    /// Update listener position (player position in 3D space)
    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        spatialAudioEngine.updateListener(position: position, orientation: orientation)
    }

    /// Play ambient sound at position
    func playAmbientSound(_ type: AmbientSound, at position: SIMD3<Float>, radius: Float = 5.0) {
        guard areSoundEffectsEnabled else { return }
        spatialAudioEngine.playAmbient(type, at: position, radius: radius)
    }

    /// Stop ambient sound
    func stopAmbientSound(_ type: AmbientSound) {
        spatialAudioEngine.stopAmbient(type)
    }

    // MARK: - Public API - State Management

    /// Update audio based on game state
    func updateGameState(_ state: GameState) {
        currentGameState = state

        switch state {
        case .menu:
            playMenuMusic()
            stopAmbientSound(.courseEnvironment)

        case .playing:
            playGameplayMusic(intensity: .medium)
            playAmbientSound(.courseEnvironment, at: .zero, radius: 10.0)

        case .paused:
            musicPlayer.pause()
            spatialAudioEngine.pauseAll()

        case .courseComplete:
            stopAmbientSound(.courseEnvironment)
            updateMusicIntensity(.low)

        default:
            break
        }
    }

    /// Resume audio after pause
    func resume() {
        if isMusicEnabled {
            musicPlayer.resume()
        }
        spatialAudioEngine.resumeAll()
    }

    // MARK: - Private Helpers

    private func updateMasterVolume() {
        musicPlayer.setVolume(musicVolume * masterVolume)
        soundEffectPlayer.setVolume(sfxVolume * masterVolume)
        spatialAudioEngine.setVolume(masterVolume)
    }

    private func mix(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + (b - a) * t
    }

    // MARK: - Cleanup

    func cleanup() {
        musicPlayer.stop(fadeOut: 0.5)
        soundEffectPlayer.stopAll()
        spatialAudioEngine.cleanup()
        hapticsManager.cleanup()
    }
}

// MARK: - Supporting Types

enum MusicIntensity {
    case low
    case medium
    case high
}

enum MusicTrack {
    case menu
    case gameplayCalm
    case gameplayMedium
    case gameplayIntense
    case victory
    case defeat
}

enum SoundEffect {
    case jump
    case land
    case vault
    case wallRun
    case checkpointReached
    case courseComplete
    case achievementUnlocked
    case countdown
    case celebration
    case menuClick
    case menuHover
    case error
    case success
}

enum AmbientSound {
    case courseEnvironment
    case wind
    case roomAmbience
}
