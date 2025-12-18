//
//  MusicPlayer.swift
//  Parkour Pathways
//
//  Background music playback with crossfading and dynamic intensity
//

import Foundation
import AVFoundation

/// Manages background music with crossfading and intensity transitions
class MusicPlayer {

    // MARK: - Properties

    private var primaryPlayer: AVAudioPlayer?
    private var secondaryPlayer: AVAudioPlayer?
    private var currentTrack: MusicTrack?
    private var currentIntensity: MusicIntensity = .medium
    private var volume: Float = 0.7
    private var isFading = false

    // MARK: - Initialization

    init() {
        // Setup will happen on first play
    }

    // MARK: - Public API - Track Playback

    /// Play a music track with optional fade-in
    func playTrack(_ track: MusicTrack, fadeIn: TimeInterval = 0) {
        // If same track is playing, just resume
        if currentTrack == track, let player = primaryPlayer {
            if !player.isPlaying {
                resume()
            }
            return
        }

        // Load new track
        guard let player = createPlayer(for: track) else {
            print("Failed to create player for track: \(track)")
            return
        }

        // Handle crossfade if something is already playing
        if let existing = primaryPlayer, existing.isPlaying {
            crossfade(from: existing, to: player, duration: fadeIn)
        } else {
            // Just start playing
            primaryPlayer = player

            if fadeIn > 0 {
                player.volume = 0
                player.play()
                fadeVolume(player: player, to: volume, duration: fadeIn)
            } else {
                player.volume = volume
                player.play()
            }
        }

        currentTrack = track
    }

    /// Stop music playback with optional fade-out
    func stop(fadeOut: TimeInterval = 0) {
        guard let player = primaryPlayer else { return }

        if fadeOut > 0 {
            fadeVolume(player: player, to: 0, duration: fadeOut) {
                player.stop()
            }
        } else {
            player.stop()
        }

        currentTrack = nil
    }

    /// Pause music playback
    func pause() {
        primaryPlayer?.pause()
        secondaryPlayer?.pause()
    }

    /// Resume music playback
    func resume() {
        primaryPlayer?.play()
        secondaryPlayer?.play()
    }

    // MARK: - Public API - Dynamic Intensity

    /// Transition to different intensity level
    func transitionToIntensity(_ intensity: MusicIntensity, duration: TimeInterval = 2.0) {
        guard intensity != currentIntensity else { return }

        let targetTrack: MusicTrack = switch intensity {
        case .low: .gameplayCalm
        case .medium: .gameplayMedium
        case .high: .gameplayIntense
        }

        // Crossfade to new intensity
        playTrack(targetTrack, fadeIn: duration)
        currentIntensity = intensity
    }

    // MARK: - Public API - Volume

    /// Set music volume
    func setVolume(_ volume: Float) {
        self.volume = volume
        primaryPlayer?.volume = volume
        secondaryPlayer?.volume = volume
    }

    // MARK: - Private Helpers - Player Creation

    private func createPlayer(for track: MusicTrack) -> AVAudioPlayer? {
        let filename = musicFilename(for: track)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Failed to find music file: \(filename)")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Loop indefinitely
            player.prepareToPlay()
            return player
        } catch {
            print("Failed to create music player: \(error)")
            return nil
        }
    }

    private func musicFilename(for track: MusicTrack) -> String {
        switch track {
        case .menu: return "music_menu"
        case .gameplayCalm: return "music_gameplay_calm"
        case .gameplayMedium: return "music_gameplay_medium"
        case .gameplayIntense: return "music_gameplay_intense"
        case .victory: return "music_victory"
        case .defeat: return "music_defeat"
        }
    }

    // MARK: - Private Helpers - Crossfading

    private func crossfade(
        from oldPlayer: AVAudioPlayer,
        to newPlayer: AVAudioPlayer,
        duration: TimeInterval
    ) {
        guard !isFading else { return }
        isFading = true

        // Start new track at zero volume
        newPlayer.volume = 0
        newPlayer.play()

        // Store old volume
        let oldVolume = oldPlayer.volume

        // Crossfade
        Task {
            let steps = 50
            let stepDuration = duration / Double(steps)
            let volumeDelta = oldVolume / Float(steps)

            for step in 0..<steps {
                let progress = Float(step) / Float(steps)

                oldPlayer.volume = oldVolume * (1.0 - progress)
                newPlayer.volume = volume * progress

                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            }

            // Finalize
            oldPlayer.stop()
            newPlayer.volume = volume

            // Swap players
            if oldPlayer === primaryPlayer {
                secondaryPlayer = oldPlayer
            }
            primaryPlayer = newPlayer

            isFading = false
        }
    }

    private func fadeVolume(
        player: AVAudioPlayer,
        to targetVolume: Float,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        let startVolume = player.volume
        let delta = targetVolume - startVolume

        Task {
            let steps = 50
            let stepDuration = duration / Double(steps)

            for step in 0...steps {
                let progress = Float(step) / Float(steps)
                player.volume = startVolume + delta * progress
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            }

            completion?()
        }
    }
}
