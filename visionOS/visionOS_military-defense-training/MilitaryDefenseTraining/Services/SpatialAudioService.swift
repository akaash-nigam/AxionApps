//
//  SpatialAudioService.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import AVFoundation
import simd

@Observable
class SpatialAudioService {
    private var audioEngine = AVAudioEngine()
    private var environmentNode = AVAudioEnvironmentNode()
    private var activeSounds: [UUID: AVAudioPlayerNode] = [:]
    private var soundCache: [String: AVAudioFile] = [:]

    // Audio configuration
    private let maxDistance: Float = 500.0
    private let referenceDistance: Float = 1.0
    private let rolloffFactor: Float = 1.0

    init() {
        setup()
    }

    // MARK: - Setup

    private func setup() {
        // Attach environment node
        audioEngine.attach(environmentNode)
        audioEngine.connect(
            environmentNode,
            to: audioEngine.mainMixerNode,
            format: nil
        )

        // Configure environment
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 1.7, z: 0)
        environmentNode.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environmentNode.distanceAttenuationParameters.referenceDistance = referenceDistance
        environmentNode.distanceAttenuationParameters.maximumDistance = maxDistance
        environmentNode.distanceAttenuationParameters.rolloffFactor = rolloffFactor

        // Start engine
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    // MARK: - 3D Sound Playback

    func play3DSound(
        _ soundName: String,
        at position: SIMD3<Float>,
        category: AudioCategory = .sfx,
        volume: Float = 1.0,
        loop: Bool = false
    ) -> UUID? {
        guard let audioFile = loadAudioFile(soundName) else {
            return nil
        }

        let playerNode = AVAudioPlayerNode()
        let soundID = UUID()

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: environmentNode, format: audioFile.processingFormat)

        // Set 3D position
        playerNode.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        playerNode.volume = volume * getCategoryVolume(category)

        // Schedule playback
        if loop {
            playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        } else {
            playerNode.scheduleFile(audioFile, at: nil) {
                self.removeSound(soundID)
            }
        }

        playerNode.play()

        activeSounds[soundID] = playerNode
        return soundID
    }

    func stopSound(_ id: UUID) {
        guard let playerNode = activeSounds[id] else { return }
        playerNode.stop()
        removeSound(id)
    }

    private func removeSound(_ id: UUID) {
        if let playerNode = activeSounds.removeValue(forKey: id) {
            audioEngine.detach(playerNode)
        }
    }

    // MARK: - Weapon Sounds

    func playWeaponFire(_ weapon: WeaponType, at position: SIMD3<Float>) {
        let soundName: String
        let volume: Float

        switch weapon {
        case .rifle:
            soundName = "rifle_fire"
            volume = 1.0
        case .pistol:
            soundName = "pistol_fire"
            volume = 0.8
        case .lmg:
            soundName = "lmg_fire"
            volume = 1.2
        case .sniper:
            soundName = "sniper_fire"
            volume = 1.3
        default:
            soundName = "generic_fire"
            volume = 1.0
        }

        _ = play3DSound(soundName, at: position, category: .weaponFire, volume: volume)
    }

    func playExplosion(at position: SIMD3<Float>, intensity: Float = 1.0) {
        _ = play3DSound("explosion", at: position, category: .explosion, volume: intensity)
    }

    func playReload(_ weapon: WeaponType, at position: SIMD3<Float>) {
        _ = play3DSound("reload", at: position, category: .sfx, volume: 0.6)
    }

    // MARK: - Environmental Sounds

    func playFootsteps(at position: SIMD3<Float>, surface: SurfaceType = .concrete) {
        let soundName = "footsteps_\(surface.rawValue)"
        _ = play3DSound(soundName, at: position, category: .ambient, volume: 0.4)
    }

    func playAmbientEnvironment(_ environment: EnvironmentType) -> UUID? {
        let soundName: String

        switch environment {
        case .urban:
            soundName = "ambient_urban"
        case .desert:
            soundName = "ambient_desert"
        case .mountain:
            soundName = "ambient_mountain"
        case .forest:
            soundName = "ambient_forest"
        default:
            soundName = "ambient_generic"
        }

        return play3DSound(soundName, at: SIMD3<Float>(0, 0, 0), category: .ambient, volume: 0.3, loop: true)
    }

    // MARK: - Radio Communications

    func playRadioMessage(_ message: String, priority: RadioPriority = .normal) {
        // In real implementation, would use text-to-speech or pre-recorded audio
        let soundName = "radio_\(priority.rawValue)"
        _ = play3DSound(soundName, at: SIMD3<Float>(0, 0, 0), category: .voice, volume: 0.8)
    }

    // MARK: - Listener Position

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        environmentNode.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to forward/up vectors
        let forward = orientation.act(SIMD3<Float>(0, 0, -1))
        let up = orientation.act(SIMD3<Float>(0, 1, 0))

        environmentNode.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z),
            up: AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        )
    }

    // MARK: - Volume Control

    private func getCategoryVolume(_ category: AudioCategory) -> Float {
        switch category {
        case .weaponFire: return 1.0
        case .explosion: return 1.0
        case .sfx: return 0.7
        case .ambient: return 0.3
        case .voice: return 0.8
        }
    }

    func setMasterVolume(_ volume: Float) {
        audioEngine.mainMixerNode.volume = volume
    }

    // MARK: - Audio File Management

    private func loadAudioFile(_ name: String) -> AVAudioFile? {
        if let cached = soundCache[name] {
            return cached
        }

        // In real implementation, would load from bundle
        // For now, return nil (would need actual audio files)
        return nil
    }

    func preloadSounds(_ sounds: [String]) {
        for sound in sounds {
            _ = loadAudioFile(sound)
        }
    }

    // MARK: - Cleanup

    func stopAllSounds() {
        for id in activeSounds.keys {
            stopSound(id)
        }
    }

    deinit {
        audioEngine.stop()
    }
}

// MARK: - Supporting Types

enum AudioCategory {
    case weaponFire
    case explosion
    case sfx
    case ambient
    case voice
}

enum SurfaceType: String {
    case concrete
    case metal
    case dirt
    case grass
    case wood
    case water
}

enum RadioPriority: String {
    case urgent
    case normal
    case low
}
