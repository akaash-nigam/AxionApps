//
//  SpatialAudioEngine.swift
//  Parkour Pathways
//
//  3D spatial audio engine for immersive sound positioning
//

import Foundation
import AVFoundation
import RealityKit
import CoreHaptics

/// Manages 3D spatial audio for immersive gameplay
class SpatialAudioEngine {

    // MARK: - Properties

    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode
    private var activeSounds: [SoundEffect: SpatialSound] = [:]
    private var ambientSounds: [AmbientSound: SpatialSound] = [:]
    private var listenerPosition: SIMD3<Float> = .zero
    private var listenerOrientation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    private var masterVolume: Float = 1.0

    // MARK: - Initialization

    init() {
        self.audioEngine = AVAudioEngine()
        self.environmentNode = audioEngine.environment

        setupEnvironmentNode()
        startEngine()
    }

    // MARK: - Setup

    private func setupEnvironmentNode() {
        // Configure spatial audio environment
        environmentNode.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environmentNode.distanceAttenuationParameters.referenceDistance = 1.0
        environmentNode.distanceAttenuationParameters.maximumDistance = 50.0
        environmentNode.distanceAttenuationParameters.rolloffFactor = 1.5

        // Configure reverb based on typical room size
        environmentNode.reverbParameters.enable = true
        environmentNode.reverbParameters.level = 0.3
        environmentNode.reverbParameters.loadFactoryReverbPreset(.mediumRoom)

        // Listener position (player)
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 1.7, z: 0) // Average eye height
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0,
            pitch: 0,
            roll: 0
        )
    }

    private func startEngine() {
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Public API - Sound Playback

    /// Play a sound effect at a specific 3D position
    func playSound(
        _ effect: SoundEffect,
        at position: SIMD3<Float>,
        volume: Float = 1.0,
        loop: Bool = false
    ) {
        // Stop existing sound if playing
        if let existing = activeSounds[effect] {
            existing.stop()
            activeSounds.removeValue(forKey: effect)
        }

        // Load audio file
        guard let audioFile = loadAudioFile(for: effect) else {
            print("Failed to load audio file for \(effect)")
            return
        }

        // Create player node
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        // Connect to environment node for 3D audio
        audioEngine.connect(
            playerNode,
            to: environmentNode,
            format: audioFile.processingFormat
        )

        // Set 3D position
        playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Configure rendering
        playerNode.renderingAlgorithm = .HRTFHQ // High-quality spatial audio

        // Schedule and play
        if loop {
            playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            playerNode.scheduleFile(audioFile, at: nil) // Pre-schedule for seamless loop
        } else {
            playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
                self?.cleanupSound(effect)
            }
        }

        playerNode.volume = volume * masterVolume
        playerNode.play()

        // Track active sound
        let spatialSound = SpatialSound(
            playerNode: playerNode,
            audioFile: audioFile,
            position: position,
            isLooping: loop
        )
        activeSounds[effect] = spatialSound
    }

    /// Stop a specific sound effect
    func stopSound(_ effect: SoundEffect, fadeOut: TimeInterval = 0.2) {
        guard let sound = activeSounds[effect] else { return }

        if fadeOut > 0 {
            // Fade out
            let steps = 20
            let stepDuration = fadeOut / Double(steps)
            let volumeDelta = sound.playerNode.volume / Float(steps)

            Task {
                for _ in 0..<steps {
                    sound.playerNode.volume -= volumeDelta
                    try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                }
                sound.stop()
                activeSounds.removeValue(forKey: effect)
            }
        } else {
            sound.stop()
            activeSounds.removeValue(forKey: effect)
        }
    }

    // MARK: - Public API - Ambient Sounds

    /// Play ambient sound with spherical falloff
    func playAmbient(
        _ ambient: AmbientSound,
        at position: SIMD3<Float>,
        radius: Float = 5.0,
        volume: Float = 0.5
    ) {
        // Stop existing ambient if playing
        if let existing = ambientSounds[ambient] {
            existing.stop()
            ambientSounds.removeValue(forKey: ambient)
        }

        guard let audioFile = loadAmbientFile(for: ambient) else {
            print("Failed to load ambient file for \(ambient)")
            return
        }

        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: environmentNode, format: audioFile.processingFormat)

        playerNode.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        playerNode.renderingAlgorithm = .HRTFHQ

        // Configure distance attenuation for ambient
        environmentNode.distanceAttenuationParameters.referenceDistance = radius / 2.0
        environmentNode.distanceAttenuationParameters.maximumDistance = radius

        // Schedule looping
        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.scheduleFile(audioFile, at: nil) // Pre-schedule for seamless loop
        playerNode.volume = volume * masterVolume
        playerNode.play()

        let spatialSound = SpatialSound(
            playerNode: playerNode,
            audioFile: audioFile,
            position: position,
            isLooping: true
        )
        ambientSounds[ambient] = spatialSound
    }

    /// Stop ambient sound
    func stopAmbient(_ ambient: AmbientSound, fadeOut: TimeInterval = 1.0) {
        guard let sound = ambientSounds[ambient] else { return }

        if fadeOut > 0 {
            let steps = 30
            let stepDuration = fadeOut / Double(steps)
            let volumeDelta = sound.playerNode.volume / Float(steps)

            Task {
                for _ in 0..<steps {
                    sound.playerNode.volume -= volumeDelta
                    try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                }
                sound.stop()
                ambientSounds.removeValue(forKey: ambient)
            }
        } else {
            sound.stop()
            ambientSounds.removeValue(forKey: ambient)
        }
    }

    // MARK: - Public API - Listener Management

    /// Update listener (player) position and orientation
    func updateListener(position: SIMD3<Float>, orientation: simd_quatf) {
        listenerPosition = position
        listenerOrientation = orientation

        // Convert quaternion to Euler angles for AVAudioEnvironmentNode
        let euler = quaternionToEuler(orientation)

        environmentNode.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: euler.yaw,
            pitch: euler.pitch,
            roll: euler.roll
        )
    }

    /// Update room acoustics based on scanned room
    func updateRoomAcoustics(size: SIMD3<Float>, materials: [RoomMaterial] = []) {
        let volume = size.x * size.y * size.z

        // Adjust reverb based on room size
        if volume < 20 { // Small room
            environmentNode.reverbParameters.loadFactoryReverbPreset(.smallRoom)
            environmentNode.reverbParameters.level = 0.2
        } else if volume < 50 { // Medium room
            environmentNode.reverbParameters.loadFactoryReverbPreset(.mediumRoom)
            environmentNode.reverbParameters.level = 0.3
        } else { // Large room
            environmentNode.reverbParameters.loadFactoryReverbPreset(.largeRoom)
            environmentNode.reverbParameters.level = 0.4
        }

        // Adjust based on materials (simplified)
        let avgAbsorption = materials.isEmpty ? 0.3 : materials.map { $0.absorption }.reduce(0, +) / Float(materials.count)
        environmentNode.reverbParameters.level *= (1.0 - avgAbsorption)
    }

    // MARK: - Public API - Volume & State

    /// Set master volume for all spatial audio
    func setVolume(_ volume: Float) {
        masterVolume = volume

        for sound in activeSounds.values {
            sound.playerNode.volume = volume
        }

        for sound in ambientSounds.values {
            sound.playerNode.volume = volume * 0.5 // Ambient sounds are quieter
        }
    }

    /// Pause all spatial audio
    func pauseAll() {
        for sound in activeSounds.values {
            sound.playerNode.pause()
        }
        for sound in ambientSounds.values {
            sound.playerNode.pause()
        }
    }

    /// Resume all spatial audio
    func resumeAll() {
        for sound in activeSounds.values {
            sound.playerNode.play()
        }
        for sound in ambientSounds.values {
            sound.playerNode.play()
        }
    }

    /// Stop all sounds
    func stopAll() {
        for (key, sound) in activeSounds {
            sound.stop()
            activeSounds.removeValue(forKey: key)
        }
        for (key, sound) in ambientSounds {
            sound.stop()
            ambientSounds.removeValue(forKey: key)
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        stopAll()
        audioEngine.stop()
    }

    // MARK: - Private Helpers

    private func cleanupSound(_ effect: SoundEffect) {
        if let sound = activeSounds[effect] {
            sound.stop()
            activeSounds.removeValue(forKey: effect)
        }
    }

    private func loadAudioFile(for effect: SoundEffect) -> AVAudioFile? {
        let filename = audioFilename(for: effect)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            return nil
        }

        return try? AVAudioFile(forReading: url)
    }

    private func loadAmbientFile(for ambient: AmbientSound) -> AVAudioFile? {
        let filename = ambientFilename(for: ambient)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            return nil
        }

        return try? AVAudioFile(forReading: url)
    }

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

    private func ambientFilename(for ambient: AmbientSound) -> String {
        switch ambient {
        case .courseEnvironment: return "amb_environment"
        case .wind: return "amb_wind"
        case .roomAmbience: return "amb_room"
        }
    }

    private func quaternionToEuler(_ quat: simd_quatf) -> (yaw: Float, pitch: Float, roll: Float) {
        // Convert quaternion to Euler angles (in degrees for AVFoundation)
        let w = quat.vector.w
        let x = quat.vector.x
        let y = quat.vector.y
        let z = quat.vector.z

        let yaw = atan2(2.0 * (w * y + x * z), 1.0 - 2.0 * (y * y + x * x))
        let pitch = asin(2.0 * (w * x - y * z))
        let roll = atan2(2.0 * (w * z + x * y), 1.0 - 2.0 * (x * x + z * z))

        return (
            yaw: yaw * 180.0 / .pi,
            pitch: pitch * 180.0 / .pi,
            roll: roll * 180.0 / .pi
        )
    }
}

// MARK: - Supporting Types

class SpatialSound {
    let playerNode: AVAudioPlayerNode
    let audioFile: AVAudioFile
    let position: SIMD3<Float>
    let isLooping: Bool

    init(playerNode: AVAudioPlayerNode, audioFile: AVAudioFile, position: SIMD3<Float>, isLooping: Bool) {
        self.playerNode = playerNode
        self.audioFile = audioFile
        self.position = position
        self.isLooping = isLooping
    }

    func stop() {
        playerNode.stop()
    }
}

struct RoomMaterial {
    let type: MaterialType
    let absorption: Float // 0.0 (reflective) to 1.0 (absorptive)

    enum MaterialType {
        case concrete
        case wood
        case carpet
        case drywall
        case glass
        case fabric
    }

    static func defaultMaterial() -> RoomMaterial {
        return RoomMaterial(type: .drywall, absorption: 0.3)
    }
}
