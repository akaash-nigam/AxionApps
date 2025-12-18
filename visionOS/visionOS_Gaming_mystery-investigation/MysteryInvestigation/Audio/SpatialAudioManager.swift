//
//  SpatialAudioManager.swift
//  Mystery Investigation
//
//  Manages spatial audio, music, and sound effects
//

import AVFoundation
import RealityKit

@Observable
class SpatialAudioManager {
    // MARK: - Audio Engine
    private let audioEngine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()

    // MARK: - Audio Players
    private var musicPlayer: AVAudioPlayerNode?
    private var sfxPlayers: [String: AVAudioPlayerNode] = [:]

    // MARK: - Audio State
    private(set) var currentMusic: String?
    private(set) var isMusicPlaying: Bool = false

    // MARK: - Volume Settings
    var masterVolume: Float = 0.75 {
        didSet { updateVolumes() }
    }

    var musicVolume: Float = 0.6 {
        didSet { updateMusicVolume() }
    }

    var sfxVolume: Float = 0.8 {
        didSet { updateSFXVolume() }
    }

    // MARK: - Initialization
    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        // Attach and configure environment node
        audioEngine.attach(environment)
        audioEngine.connect(environment, to: audioEngine.mainMixerNode, format: nil)

        // Configure spatial audio
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0, pitch: 0, roll: 0
        )

        do {
            try audioEngine.start()
            print("Audio engine started")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Music Control
    func playInvestigationMusic() {
        playMusic(named: "investigation_theme", loop: true)
    }

    func playInterrogationMusic() {
        playMusic(named: "interrogation_theme", loop: true)
    }

    func playMenuMusic() {
        playMusic(named: "menu_theme", loop: true)
    }

    func playCaseCompleteMusic() {
        playMusic(named: "case_complete", loop: false)
    }

    private func playMusic(named filename: String, loop: Bool) {
        // Stop current music
        stopMusic()

        // Load and play new music
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Music file not found: \(filename)")
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            )!

            try audioFile.read(into: buffer)

            musicPlayer = AVAudioPlayerNode()
            guard let player = musicPlayer else { return }

            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: buffer.format)

            if loop {
                player.scheduleBuffer(buffer, at: nil, options: .loops)
            } else {
                player.scheduleBuffer(buffer, at: nil, options: [])
            }

            player.play()
            currentMusic = filename
            isMusicPlaying = true

            updateMusicVolume()
        } catch {
            print("Failed to play music: \(error)")
        }
    }

    func pauseMusic() {
        musicPlayer?.pause()
        isMusicPlaying = false
    }

    func resumeMusic() {
        musicPlayer?.play()
        isMusicPlaying = true
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        currentMusic = nil
        isMusicPlaying = false
    }

    // MARK: - Sound Effects
    func playEvidenceDiscovery() {
        playSFX(named: "evidence_discovered", at: SIMD3<Float>(0, 0, 0))
    }

    func playSuspectStressed() {
        playSFX(named: "suspect_stressed", at: SIMD3<Float>(0, 0, 0))
    }

    func playToolUse(tool: String) {
        playSFX(named: "tool_\(tool)", at: SIMD3<Float>(0, 0, 0))
    }

    func playSpatialSFX(named filename: String, at position: SIMD3<Float>) {
        playSFX(named: filename, at: position)
    }

    private func playSFX(named filename: String, at position: SIMD3<Float>) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            print("SFX file not found: \(filename)")
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            )!

            try audioFile.read(into: buffer)

            let player = AVAudioPlayerNode()
            audioEngine.attach(player)
            audioEngine.connect(player, to: environment, format: buffer.format)

            // Set 3D position
            player.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)

            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: { [weak self] in
                // Cleanup after playback
                self?.audioEngine.detach(player)
            })

            player.play()

            // Store reference temporarily
            sfxPlayers[filename] = player

        } catch {
            print("Failed to play SFX: \(error)")
        }
    }

    // MARK: - Volume Management
    private func updateVolumes() {
        updateMusicVolume()
        updateSFXVolume()
    }

    private func updateMusicVolume() {
        musicPlayer?.volume = musicVolume * masterVolume
    }

    private func updateSFXVolume() {
        for player in sfxPlayers.values {
            player.volume = sfxVolume * masterVolume
        }
    }

    // MARK: - Cleanup
    deinit {
        audioEngine.stop()
    }
}
