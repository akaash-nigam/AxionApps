//
//  SoundEffectPlayer.swift
//  Parkour Pathways
//
//  Non-spatial sound effect playback system
//

import Foundation
import AVFoundation

/// Manages non-spatial sound effects (UI sounds, etc.)
class SoundEffectPlayer {

    // MARK: - Properties

    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var preloadedSounds: Set<SoundEffect> = []
    private var volume: Float = 1.0

    // MARK: - Initialization

    init() {
        // Setup will happen on preload
    }

    // MARK: - Public API - Preloading

    /// Preload sounds into memory for instant playback
    func preloadSounds(_ effects: [SoundEffect]) async {
        for effect in effects {
            await preloadSound(effect)
        }
    }

    private func preloadSound(_ effect: SoundEffect) async {
        guard !preloadedSounds.contains(effect) else { return }

        let filename = audioFilename(for: effect)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            print("Failed to find audio file: \(filename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = volume
            audioPlayers[effect] = player
            preloadedSounds.insert(effect)
        } catch {
            print("Failed to preload sound \(effect): \(error)")
        }
    }

    // MARK: - Public API - Playback

    /// Play a sound effect
    func play(
        _ effect: SoundEffect,
        volume: Float = 1.0,
        pitch: Float = 1.0,
        delay: TimeInterval = 0
    ) {
        Task {
            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            await playImmediate(effect, volume: volume, pitch: pitch)
        }
    }

    private func playImmediate(
        _ effect: SoundEffect,
        volume: Float,
        pitch: Float
    ) async {
        // Ensure sound is preloaded
        if !preloadedSounds.contains(effect) {
            await preloadSound(effect)
        }

        guard let player = audioPlayers[effect] else {
            print("Failed to get player for \(effect)")
            return
        }

        // Stop if already playing
        if player.isPlaying {
            player.stop()
        }

        // Reset to beginning
        player.currentTime = 0

        // Apply volume
        player.volume = volume * self.volume

        // Apply pitch (rate)
        player.enableRate = true
        player.rate = pitch

        // Play
        player.play()
    }

    /// Stop a specific sound effect
    func stop(_ effect: SoundEffect) {
        audioPlayers[effect]?.stop()
    }

    /// Stop all sound effects
    func stopAll() {
        for player in audioPlayers.values {
            player.stop()
        }
    }

    // MARK: - Public API - Volume

    /// Set master volume for all sound effects
    func setVolume(_ volume: Float) {
        self.volume = volume
        for player in audioPlayers.values {
            player.volume = volume
        }
    }

    // MARK: - Private Helpers

    private func audioFilename(for effect: SoundEffect) -> String {
        switch effect {
        case .jump: return "sfx_jump"
        case .land: return "sfx_land"
        case .vault: return "sfx_vault"
        case .wallRun: return "sfx_wallrun"
        case .checkpointReached: return "sfx_checkpoint"
        case .courseComplete: return "sfx_complete"
        case .achievementUnlocked: return "sfx_achievement"
        case .countdown: return "sfx_countdown"
        case .celebration: return "sfx_celebration"
        case .menuClick: return "sfx_click"
        case .menuHover: return "sfx_hover"
        case .error: return "sfx_error"
        case .success: return "sfx_success"
        }
    }
}
