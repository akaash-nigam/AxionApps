import Foundation
import AVFoundation
import RealityKit

/// Spatial audio engine for 3D positioned dialogue and environmental sounds
@MainActor
class SpatialAudioEngine {

    // MARK: - Properties
    private let audioEngine: AVAudioEngine
    private let environment: AVAudioEnvironmentNode
    private var activeAudioPlayers: [UUID: AVAudioPlayerNode] = [:]
    private var musicPlayer: AVAudioPlayerNode?

    // MARK: - Initialization
    init() {
        self.audioEngine = AVAudioEngine()
        self.environment = audioEngine.environment

        setupAudioEngine()
    }

    // MARK: - Setup
    private func setupAudioEngine() {
        // Attach environment node
        audioEngine.attach(environment)

        // Configure environment
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: 0, y: 0, z: -1),
            up: AVAudio3DVector(x: 0, y: 1, z: 0)
        )

        // Start engine
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Dialogue Audio

    /// Play character dialogue at their spatial position
    func playCharacterDialogue(
        characterID: UUID,
        audioClipName: String,
        position: SIMD3<Float>
    ) async {
        guard let audioFile = try? await loadAudioFile(named: audioClipName) else {
            print("Could not load audio file: \(audioClipName)")
            return
        }

        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        // Connect to environment
        audioEngine.connect(player, to: environment, format: audioFile.processingFormat)

        // Set 3D position
        player.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Store player
        activeAudioPlayers[characterID] = player

        // Schedule and play
        player.scheduleFile(audioFile, at: nil)
        player.play()

        // Clean up when done
        let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            await stopCharacterDialogue(characterID: characterID)
        }
    }

    /// Stop character dialogue
    func stopCharacterDialogue(characterID: UUID) {
        if let player = activeAudioPlayers[characterID] {
            player.stop()
            audioEngine.detach(player)
            activeAudioPlayers.removeValue(forKey: characterID)
        }
    }

    /// Update character audio position as they move
    func updateCharacterPosition(characterID: UUID, position: SIMD3<Float>) {
        if let player = activeAudioPlayers[characterID] {
            player.position = AVAudio3DPoint(
                x: position.x,
                y: position.y,
                z: position.z
            )
        }
    }

    // MARK: - Environmental Audio

    /// Set ambient environmental sound
    func setAmbientSound(type: AmbientType, volume: Float = 0.3) {
        // Implementation would load and play ambient audio loop
        // positioned around the player
    }

    /// Play positioned environmental sound effect
    func playEnvironmentalSound(
        type: EnvironmentalSound,
        position: SIMD3<Float>,
        volume: Float = 1.0
    ) {
        // Play one-shot sound at position
    }

    // MARK: - Music

    /// Play adaptive background music
    func playMusic(track: MusicTrack, volume: Float = 0.5) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)

        // Music is non-spatial (surrounds player)
        audioEngine.connect(player, to: audioEngine.mainMixerNode, format: nil)

        musicPlayer = player

        // In production, load actual music file
        // player.scheduleFile(musicFile, at: nil)
        player.play()
    }

    /// Adjust music volume for dialogue clarity
    func ducktMusicForDialogue(enabled: Bool) {
        guard let musicPlayer = musicPlayer else { return }

        if enabled {
            musicPlayer.volume = 0.2 // Duck to 20%
        } else {
            musicPlayer.volume = 0.5 // Return to 50%
        }
    }

    /// Stop music
    func stopMusic(fadeOut: Bool = true) {
        guard let player = musicPlayer else { return }

        if fadeOut {
            // Gradual fade out
            Task {
                for i in 0...10 {
                    await Task.yield()
                    player.volume = 0.5 * (1.0 - Float(i) / 10.0)
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                }
                player.stop()
            }
        } else {
            player.stop()
        }

        audioEngine.detach(player)
        musicPlayer = nil
    }

    // MARK: - Emotional Audio

    /// Play emotional audio cue
    func playEmotionalCue(emotion: Emotion, intensity: Float) {
        switch emotion {
        case .fearful:
            playHeartbeat(rate: 90 + Int(intensity * 40))
        case .happy:
            playMusicalSwell(positive: true)
        case .sad:
            playMusicalSwell(positive: false)
        default:
            break
        }
    }

    private func playHeartbeat(rate: Int) {
        // Play rhythmic heartbeat sound
        // Rate in BPM
    }

    private func playMusicalSwell(positive: Bool) {
        // Play emotional musical moment
    }

    // MARK: - Helper Methods

    private func loadAudioFile(named name: String) async throws -> AVAudioFile {
        // In production, load from bundle
        // For now, create a mock
        throw NSError(domain: "Audio", code: 404, userInfo: [NSLocalizedDescriptionKey: "Audio file not found: \(name)"])
    }

    /// Update listener (player) position and orientation
    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to forward/up vectors
        let forward = orientation.act(SIMD3<Float>(0, 0, -1))
        let up = orientation.act(SIMD3<Float>(0, 1, 0))

        environment.listenerAngularOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z),
            up: AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        )
    }
}

// MARK: - Supporting Types

enum AmbientType {
    case roomTone
    case outdoorNight
    case outdoorDay
    case rain
    case wind
}

enum EnvironmentalSound {
    case doorOpen
    case doorClose
    case footstep
    case thunder
    case clock
}

enum MusicTrack: String {
    case mainTheme
    case tension
    case intimate
    case revelation
    case resolution
}
