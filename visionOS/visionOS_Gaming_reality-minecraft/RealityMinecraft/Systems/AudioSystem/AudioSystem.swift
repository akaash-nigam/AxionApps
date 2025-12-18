//
//  AudioSystem.swift
//  Reality Minecraft
//
//  Spatial audio system
//

import Foundation
import AVFoundation
import simd

/// Audio system for spatial audio
class AudioSystem {
    private var audioEngine: AVAudioEngine
    private var environment: AVAudioEnvironmentNode
    private var activeSounds: [UUID: AudioSource] = [:]

    init() {
        audioEngine = AVAudioEngine()
        environment = AVAudioEnvironmentNode()

        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        do {
            try audioEngine.start()
            print("✅ Audio system initialized")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }

    /// Update audio system
    func update(deltaTime: TimeInterval) {
        // Update listener position (from player/camera)
        // This would be called from the game loop with actual player position
    }

    /// Play a sound at a 3D position
    func playSound(_ soundName: String, at position: SIMD3<Float>, volume: Float = 1.0) -> UUID {
        // In production, this would load and play actual audio files
        let id = UUID()
        activeSounds[id] = AudioSource(position: position, volume: volume)

        print("🔊 Playing sound: \(soundName) at \(position)")
        return id
    }

    /// Stop a sound
    func stopSound(_ id: UUID) {
        activeSounds.removeValue(forKey: id)
    }

    /// Update listener position and orientation
    func updateListener(position: SIMD3<Float>, orientation: simd_quatf) {
        environment.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        let forward = orientation.act(SIMD3<Float>(0, 0, -1))
        let up = orientation.act(SIMD3<Float>(0, 1, 0))

        environment.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z),
            up: AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        )
    }
}

/// Represents an active audio source
struct AudioSource {
    var position: SIMD3<Float>
    var volume: Float
    var isLooping: Bool = false
}
