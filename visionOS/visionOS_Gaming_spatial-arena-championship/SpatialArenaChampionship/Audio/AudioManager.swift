//
//  AudioManager.swift
//  Spatial Arena Championship
//
//  Spatial audio and sound effect manager
//

import Foundation
import AVFoundation
import RealityKit
import Observation

// MARK: - Audio Manager

@Observable
@MainActor
class AudioManager {
    // MARK: - Properties

    private var audioEngine: AVAudioEngine
    private var environmentNode: AVAudioEnvironmentNode
    private var musicPlayer: AVAudioPlayerNode
    private var ambientPlayer: AVAudioPlayerNode

    // Sound effect pools
    private var sfxPlayers: [SoundEffect: [AVAudioPlayerNode]] = [:]
    private var activeSpatialSounds: [UUID: SpatialSound] = [:]

    // Audio files
    private var soundBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var musicBuffers: [String: AVAudioPCMBuffer] = [:]

    // State
    private var isInitialized: Bool = false
    var isMusicPlaying: Bool = false
    var currentMusicTrack: String?

    // Volume settings
    var masterVolume: Float = 1.0 {
        didSet { updateVolumes() }
    }
    var musicVolume: Float = 0.7 {
        didSet { updateMusicVolume() }
    }
    var sfxVolume: Float = 1.0 {
        didSet { updateSFXVolume() }
    }
    var voiceVolume: Float = 1.0
    var spatialAudioEnabled: Bool = true

    // MARK: - Initialization

    init() {
        self.audioEngine = AVAudioEngine()
        self.environmentNode = AVAudioEnvironmentNode()
        self.musicPlayer = AVAudioPlayerNode()
        self.ambientPlayer = AVAudioPlayerNode()

        setupAudioEngine()
    }

    private func setupAudioEngine() {
        // Configure audio session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }

        // Attach nodes
        audioEngine.attach(environmentNode)
        audioEngine.attach(musicPlayer)
        audioEngine.attach(ambientPlayer)

        // Configure environment node for spatial audio
        environmentNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0,
            pitch: 0,
            roll: 0
        )
        environmentNode.renderingAlgorithm = .HRTFHQ
        environmentNode.distanceAttenuationParameters.distanceAttenuationModel = .inverse
        environmentNode.distanceAttenuationParameters.referenceDistance = 1.0
        environmentNode.distanceAttenuationParameters.maximumDistance = 50.0
        environmentNode.distanceAttenuationParameters.rolloffFactor = 1.0

        // Connect nodes
        let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        audioEngine.connect(environmentNode, to: audioEngine.mainMixerNode, format: format)
        audioEngine.connect(musicPlayer, to: audioEngine.mainMixerNode, format: format)
        audioEngine.connect(ambientPlayer, to: audioEngine.mainMixerNode, format: format)

        // Create sound effect player pools
        createSFXPools()
    }

    func start() throws {
        guard !isInitialized else { return }

        // Load audio files
        loadSoundEffects()
        loadMusicTracks()

        // Start engine
        if !audioEngine.isRunning {
            try audioEngine.start()
        }

        isInitialized = true
    }

    func stop() {
        audioEngine.stop()
        stopAllSounds()
        isInitialized = false
    }

    // MARK: - Sound Effect Pools

    private func createSFXPools() {
        // Create pools for frequently used sounds
        let pooledSounds: [SoundEffect] = [
            .projectileShoot,
            .projectileHit,
            .projectileExplode,
            .shieldDeploy,
            .shieldHit,
            .playerDamage,
            .playerEliminated,
            .footstep
        ]

        for sound in pooledSounds {
            let poolSize = sound.requiresPool ? 8 : 2
            var players: [AVAudioPlayerNode] = []

            for _ in 0..<poolSize {
                let player = AVAudioPlayerNode()
                audioEngine.attach(player)

                if sound.isSpatial && spatialAudioEnabled {
                    audioEngine.connect(player, to: environmentNode, format: nil)
                } else {
                    audioEngine.connect(player, to: audioEngine.mainMixerNode, format: nil)
                }

                players.append(player)
            }

            sfxPlayers[sound] = players
        }
    }

    private func getAvailableSFXPlayer(for sound: SoundEffect) -> AVAudioPlayerNode? {
        guard let pool = sfxPlayers[sound] else { return nil }

        // Find first non-playing player
        return pool.first { !$0.isPlaying }
    }

    // MARK: - Load Audio Files

    private func loadSoundEffects() {
        let sounds: [SoundEffect] = [
            .projectileShoot, .projectileHit, .projectileExplode,
            .shieldDeploy, .shieldHit, .shieldBreak,
            .dashActivate, .ultimateCharge, .ultimateRelease,
            .playerDamage, .playerEliminated, .playerRespawn,
            .powerUpSpawn, .powerUpCollect,
            .territoryCapture, .territoryLost, .territoryContested,
            .artifactPickup, .artifactDrop, .artifactBanked,
            .matchStart, .matchEnd, .victoryFanfare,
            .uiSelect, .uiConfirm, .uiCancel, .uiError,
            .footstep, .landing
        ]

        for sound in sounds {
            if let buffer = loadAudioFile(named: sound.fileName) {
                soundBuffers[sound] = buffer
            }
        }
    }

    private func loadMusicTracks() {
        let tracks = ["menu_theme", "arena_battle", "victory_theme", "defeat_theme"]

        for track in tracks {
            if let buffer = loadAudioFile(named: track) {
                musicBuffers[track] = buffer
            }
        }
    }

    private func loadAudioFile(named name: String) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            // File not found - in production, this would load from assets
            print("Audio file not found: \(name).wav")
            return nil
        }

        do {
            let file = try AVAudioFile(forReading: url)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: file.processingFormat,
                frameCapacity: AVAudioFrameCount(file.length)
            ) else {
                return nil
            }

            try file.read(into: buffer)
            return buffer
        } catch {
            print("Failed to load audio file \(name): \(error)")
            return nil
        }
    }

    // MARK: - Play Sound Effects

    func playSound(_ sound: SoundEffect, volume: Float = 1.0) {
        guard isInitialized else { return }
        guard let buffer = soundBuffers[sound] else { return }
        guard let player = getAvailableSFXPlayer(for: sound) else { return }

        let finalVolume = volume * sfxVolume * masterVolume
        player.volume = finalVolume

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    func playSpatialSound(
        _ sound: SoundEffect,
        at position: SIMD3<Float>,
        volume: Float = 1.0,
        pitch: Float = 1.0
    ) -> UUID? {
        guard isInitialized else { return nil }
        guard spatialAudioEnabled else {
            playSound(sound, volume: volume)
            return nil
        }
        guard let buffer = soundBuffers[sound] else { return nil }
        guard let player = getAvailableSFXPlayer(for: sound) else { return nil }

        // Set spatial position
        player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)

        // Set volume and pitch
        let finalVolume = volume * sfxVolume * masterVolume
        player.volume = finalVolume
        player.rate = pitch

        // Play
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()

        // Track spatial sound
        let soundID = UUID()
        let spatialSound = SpatialSound(
            id: soundID,
            player: player,
            position: position,
            sound: sound
        )
        activeSpatialSounds[soundID] = spatialSound

        return soundID
    }

    func updateSpatialSoundPosition(_ soundID: UUID, position: SIMD3<Float>) {
        guard let sound = activeSpatialSounds[soundID] else { return }
        sound.player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
        sound.position = position
    }

    func stopSpatialSound(_ soundID: UUID) {
        guard let sound = activeSpatialSounds[soundID] else { return }
        sound.player.stop()
        activeSpatialSounds.removeValue(forKey: soundID)
    }

    // MARK: - Music

    func playMusic(_ track: String, loop: Bool = true, fadeIn: TimeInterval = 1.0) {
        guard isInitialized else { return }
        guard let buffer = musicBuffers[track] else { return }

        // Stop current music
        if musicPlayer.isPlaying {
            stopMusic(fadeOut: 0.5)
        }

        // Schedule buffer
        if loop {
            musicPlayer.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        } else {
            musicPlayer.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        }

        // Fade in
        musicPlayer.volume = 0.0
        musicPlayer.play()

        Task {
            await fadeVolume(player: musicPlayer, to: musicVolume * masterVolume, duration: fadeIn)
        }

        isMusicPlaying = true
        currentMusicTrack = track
    }

    func stopMusic(fadeOut: TimeInterval = 1.0) {
        guard musicPlayer.isPlaying else { return }

        Task {
            await fadeVolume(player: musicPlayer, to: 0.0, duration: fadeOut)
            musicPlayer.stop()
            isMusicPlaying = false
            currentMusicTrack = nil
        }
    }

    func pauseMusic() {
        musicPlayer.pause()
        isMusicPlaying = false
    }

    func resumeMusic() {
        musicPlayer.play()
        isMusicPlaying = true
    }

    private func fadeVolume(player: AVAudioPlayerNode, to targetVolume: Float, duration: TimeInterval) async {
        let startVolume = player.volume
        let steps = 20
        let stepDuration = duration / TimeInterval(steps)
        let volumeStep = (targetVolume - startVolume) / Float(steps)

        for i in 0..<steps {
            let newVolume = startVolume + volumeStep * Float(i + 1)
            player.volume = newVolume
            try? await Task.sleep(for: .milliseconds(Int(stepDuration * 1000)))
        }

        player.volume = targetVolume
    }

    // MARK: - Listener Position

    func updateListenerPosition(_ position: SIMD3<Float>, orientation: simd_quatf) {
        guard spatialAudioEnabled else { return }

        // Update listener position
        environmentNode.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Convert quaternion to Euler angles for audio orientation
        let euler = simd_quatf_to_euler(orientation)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: euler.y * 180 / .pi,
            pitch: euler.x * 180 / .pi,
            roll: euler.z * 180 / .pi
        )
    }

    private func simd_quatf_to_euler(_ q: simd_quatf) -> SIMD3<Float> {
        let vector = q.vector
        let w = vector.w
        let x = vector.x
        let y = vector.y
        let z = vector.z

        // Roll (x-axis rotation)
        let sinr_cosp = 2 * (w * x + y * z)
        let cosr_cosp = 1 - 2 * (x * x + y * y)
        let roll = atan2(sinr_cosp, cosr_cosp)

        // Pitch (y-axis rotation)
        let sinp = 2 * (w * y - z * x)
        let pitch = abs(sinp) >= 1 ? copysign(.pi / 2, sinp) : asin(sinp)

        // Yaw (z-axis rotation)
        let siny_cosp = 2 * (w * z + x * y)
        let cosy_cosp = 1 - 2 * (y * y + z * z)
        let yaw = atan2(siny_cosp, cosy_cosp)

        return SIMD3<Float>(pitch, yaw, roll)
    }

    // MARK: - Volume Control

    private func updateVolumes() {
        updateMusicVolume()
        updateSFXVolume()
    }

    private func updateMusicVolume() {
        musicPlayer.volume = musicVolume * masterVolume
        ambientPlayer.volume = musicVolume * masterVolume * 0.5
    }

    private func updateSFXVolume() {
        // SFX volumes are applied per-sound at playback time
        // This would update any currently playing looped sounds
        for (_, players) in sfxPlayers {
            for player in players where player.isPlaying {
                player.volume = sfxVolume * masterVolume
            }
        }
    }

    // MARK: - Cleanup

    func stopAllSounds() {
        // Stop music
        musicPlayer.stop()
        ambientPlayer.stop()

        // Stop all SFX
        for (_, players) in sfxPlayers {
            for player in players {
                player.stop()
            }
        }

        // Clear spatial sounds
        activeSpatialSounds.removeAll()
    }

    // MARK: - Preset Audio Scenarios

    func playMatchStartAudio() {
        playSound(.matchStart, volume: 1.0)
        playMusic("arena_battle", loop: true, fadeIn: 2.0)
    }

    func playMatchEndAudio(victory: Bool) {
        stopMusic(fadeOut: 1.0)

        Task {
            try? await Task.sleep(for: .seconds(1))
            if victory {
                playSound(.victoryFanfare, volume: 1.2)
                playMusic("victory_theme", loop: false, fadeIn: 0.5)
            } else {
                playMusic("defeat_theme", loop: false, fadeIn: 0.5)
            }
        }
    }

    func playEliminationAudio(isLocalPlayer: Bool) {
        if isLocalPlayer {
            playSound(.playerEliminated, volume: 1.0)
        }
    }

    func playObjectiveCapturedAudio() {
        playSound(.territoryCapture, volume: 0.9)
    }

    func playUltimateSequence() {
        playSound(.ultimateCharge, volume: 1.0)

        Task {
            try? await Task.sleep(for: .milliseconds(500))
            playSound(.ultimateRelease, volume: 1.2)
        }
    }
}

// MARK: - Sound Effect Enum

enum SoundEffect: String, CaseIterable {
    // Combat
    case projectileShoot = "projectile_shoot"
    case projectileHit = "projectile_hit"
    case projectileExplode = "projectile_explode"
    case shieldDeploy = "shield_deploy"
    case shieldHit = "shield_hit"
    case shieldBreak = "shield_break"
    case dashActivate = "dash_activate"
    case ultimateCharge = "ultimate_charge"
    case ultimateRelease = "ultimate_release"

    // Player
    case playerDamage = "player_damage"
    case playerEliminated = "player_eliminated"
    case playerRespawn = "player_respawn"

    // Power-ups
    case powerUpSpawn = "powerup_spawn"
    case powerUpCollect = "powerup_collect"

    // Objectives
    case territoryCapture = "territory_capture"
    case territoryLost = "territory_lost"
    case territoryContested = "territory_contested"
    case artifactPickup = "artifact_pickup"
    case artifactDrop = "artifact_drop"
    case artifactBanked = "artifact_banked"

    // Match
    case matchStart = "match_start"
    case matchEnd = "match_end"
    case victoryFanfare = "victory_fanfare"

    // UI
    case uiSelect = "ui_select"
    case uiConfirm = "ui_confirm"
    case uiCancel = "ui_cancel"
    case uiError = "ui_error"

    // Movement
    case footstep = "footstep"
    case landing = "landing"

    var fileName: String {
        return rawValue
    }

    var isSpatial: Bool {
        switch self {
        case .uiSelect, .uiConfirm, .uiCancel, .uiError:
            return false
        default:
            return true
        }
    }

    var requiresPool: Bool {
        switch self {
        case .projectileShoot, .projectileHit, .footstep:
            return true
        default:
            return false
        }
    }
}

// MARK: - Spatial Sound

class SpatialSound {
    let id: UUID
    let player: AVAudioPlayerNode
    var position: SIMD3<Float>
    let sound: SoundEffect

    init(id: UUID, player: AVAudioPlayerNode, position: SIMD3<Float>, sound: SoundEffect) {
        self.id = id
        self.player = player
        self.position = position
        self.sound = sound
    }
}
