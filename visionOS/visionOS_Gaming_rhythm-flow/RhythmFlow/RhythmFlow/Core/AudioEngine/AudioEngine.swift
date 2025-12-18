//
//  AudioEngine.swift
//  RhythmFlow
//
//  Manages audio playback and spatial audio
//

import Foundation
import AVFoundation
import simd

@MainActor
class AudioEngine {
    // MARK: - Audio Engine
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let musicPlayer = AVAudioPlayerNode()

    // MARK: - Audio Sources
    private var currentSong: Song?
    private var currentAudioFile: AVAudioFile?

    // MARK: - Timing
    private var startTime: TimeInterval?
    private(set) var currentTime: TimeInterval = 0

    // MARK: - State
    private var isPlaying: Bool = false
    private var isPaused: Bool = false

    // MARK: - Initialization
    init() {
        setupAudioEngine()
    }

    // MARK: - Setup
    private func setupAudioEngine() {
        // Attach nodes
        engine.attach(environment)
        engine.attach(musicPlayer)

        // Configure spatial audio environment
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.renderingAlgorithm = .HRTF
        environment.distanceAttenuationParameters.maximumDistance = 10.0

        // Connect nodes
        engine.connect(musicPlayer, to: environment, format: nil)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)

        // Prepare and start engine
        engine.prepare()

        do {
            try engine.start()
            print("🔊 Audio engine started")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Song Management
    func loadSong(_ song: Song) async {
        print("🎵 Loading song: \(song.title)")

        currentSong = song

        do {
            let audioFile = try AVAudioFile(forReading: song.audioURL)
            currentAudioFile = audioFile

            // Schedule file for playback
            musicPlayer.scheduleFile(audioFile, at: nil) {
                self.handleSongComplete()
            }

            print("✅ Song loaded successfully")
        } catch {
            print("❌ Failed to load song: \(error)")
        }
    }

    // MARK: - Playback Control
    func play() {
        guard !isPlaying else { return }

        musicPlayer.play()
        startTime = CACurrentMediaTime()
        isPlaying = true
        isPaused = false

        // Start timing update
        startTimingUpdate()

        print("▶️ Playback started")
    }

    func pause() {
        guard isPlaying, !isPaused else { return }

        musicPlayer.pause()
        isPaused = true

        print("⏸️ Playback paused")
    }

    func resume() {
        guard isPlaying, isPaused else { return }

        musicPlayer.play()
        isPaused = false

        print("▶️ Playback resumed")
    }

    func stop() {
        musicPlayer.stop()
        isPlaying = false
        isPaused = false
        startTime = nil
        currentTime = 0

        print("⏹️ Playback stopped")
    }

    // MARK: - Timing
    private func startTimingUpdate() {
        Task {
            while isPlaying {
                if !isPaused, let start = startTime {
                    currentTime = CACurrentMediaTime() - start
                }

                // Update every 10ms for accurate timing
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
    }

    private func handleSongComplete() {
        print("✅ Song playback completed")
        isPlaying = false
        // TODO: Notify game engine of completion
    }

    // MARK: - Sound Effects
    func playHitSound(quality: HitQuality, at position: SIMD3<Float>) {
        // TODO: Play spatial hit sound based on quality
        // For now, just log
        print("🔊 Playing \(quality.displayName) sound at \(position)")
    }

    func playNoteSound(at position: SIMD3<Float>) {
        // TODO: Play note appearance sound
    }

    func playComboSound(combo: Int) {
        // TODO: Play combo milestone sound
    }

    // MARK: - Spatial Audio
    func updateListenerPosition(_ position: SIMD3<Float>, rotation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to Euler angles for listener orientation
        // TODO: Implement proper quaternion to Euler conversion
    }

    // MARK: - Cleanup
    func cleanup() {
        stop()
        engine.stop()
        print("🧹 Audio engine cleaned up")
    }
}
