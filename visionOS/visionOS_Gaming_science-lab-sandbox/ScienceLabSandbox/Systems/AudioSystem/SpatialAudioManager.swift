//
//  SpatialAudioManager.swift
//  Science Lab Sandbox
//
//  Manages spatial audio playback and music
//

import Foundation
import AVFoundation
import RealityKit

@MainActor
class SpatialAudioManager: ObservableObject {

    // MARK: - Properties

    private var audioEngine = AVAudioEngine()
    private var environment = AVAudioEnvironmentNode()
    private var musicPlayer: AVAudioPlayerNode?
    private var ambiencePlayer: AVAudioPlayerNode?

    private var activeSounds: [UUID: AVAudioPlayerNode] = [:]
    private var audioCache: [String: AVAudioFile] = [:]

    @Published var isMusicEnabled: Bool = true
    @Published var isSoundEnabled: Bool = true
    @Published var masterVolume: Float = 1.0

    // MARK: - Initialization

    init() {
        setupAudioEngine()
    }

    // MARK: - Setup

    private func setupAudioEngine() {
        // Attach environment node
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Configure spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)

        // Start engine
        do {
            try audioEngine.start()
            print("🔊 Audio engine started")
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    // MARK: - Sound Playback

    func playSound(_ sound: GameSound, at position: SIMD3<Float> = .zero, volume: Float = 1.0) {
        guard isSoundEnabled else { return }

        // In real implementation, load audio file and play
        print("🔊 Playing sound: \(sound.rawValue)")
    }

    func playSoundAtEntity(_ sound: GameSound, entity: Entity, volume: Float = 1.0) {
        let position = entity.position(relativeTo: nil)
        playSound(sound, at: position, volume: volume)
    }

    func stopSound(_ id: UUID) {
        if let player = activeSounds[id] {
            player.stop()
            activeSounds.removeValue(forKey: id)
        }
    }

    func stopAllSounds() {
        for (_, player) in activeSounds {
            player.stop()
        }
        activeSounds.removeAll()
    }

    // MARK: - Music Playback

    func playMusic(_ music: BackgroundMusic) {
        guard isMusicEnabled else { return }

        print("🎵 Playing music: \(music.rawValue)")
        // In real implementation, load and play music file
    }

    func stopMusic() {
        musicPlayer?.stop()
        print("🎵 Music stopped")
    }

    func setMusicVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }

    // MARK: - Ambience

    func playAmbience(_ ambience: AmbienceSound) {
        print("🌊 Playing ambience: \(ambience.rawValue)")
        // In real implementation, load and loop ambience file
    }

    func stopAmbience() {
        ambiencePlayer?.stop()
    }

    // MARK: - Control

    func pauseAll() {
        musicPlayer?.pause()
        ambiencePlayer?.pause()

        for (_, player) in activeSounds {
            player.pause()
        }
    }

    func resumeAll() {
        musicPlayer?.play()
        ambiencePlayer?.play()

        for (_, player) in activeSounds {
            player.play()
        }
    }

    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0, min(1, volume))
        audioEngine.mainMixerNode.volume = masterVolume
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        // Update spatial positions if needed
    }
}

// MARK: - Game Sounds

enum GameSound: String {
    case menuSelect
    case menuOpen
    case menuClose
    case buttonClick

    case experimentStart
    case experimentComplete
    case stepComplete

    case measurementRecorded
    case observationRecorded

    case chemicalPour
    case chemicalMix
    case bubbling
    case boiling
    case explosion

    case burnerIgnite
    case burnerFlame

    case safetyAlert
    case safetyWarning

    case achievementUnlocked
    case levelUp
}

// MARK: - Background Music

enum BackgroundMusic: String {
    case menu
    case laboratory
    case discovery
    case analysis
}

// MARK: - Ambience Sounds

enum AmbienceSound: String {
    case laboratory
    case natureOutdoor
    case space
    case silence
}
