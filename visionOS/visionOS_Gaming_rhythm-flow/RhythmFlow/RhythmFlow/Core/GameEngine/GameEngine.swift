//
//  GameEngine.swift
//  RhythmFlow
//
//  Core game engine managing gameplay loop
//

import Foundation
import RealityKit
import Observation

@Observable
@MainActor
class GameEngine {
    // MARK: - Dependencies
    private let audioEngine: AudioEngine
    private let inputManager: InputManager
    private let scoreManager: ScoreManager

    // MARK: - State
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var currentSession: GameSession?
    private(set) var currentBeatMap: BeatMap?

    // MARK: - Gameplay
    private var activeNotes: [UUID: NoteEntity] = [:]
    private var notePool: NoteEntityPool
    private var spawnQueue: [NoteEvent] = []
    private var nextSpawnIndex: Int = 0

    // MARK: - Timing
    private var gameStartTime: TimeInterval = 0
    private var currentMusicTime: TimeInterval = 0
    private let spawnLeadTime: TimeInterval = 2.0  // Spawn notes 2 seconds ahead

    // MARK: - Performance
    private var frameCount: Int = 0
    private var lastFrameTime: TimeInterval = 0
    private var averageFPS: Double = 90.0

    // MARK: - Initialization
    init(
        audioEngine: AudioEngine,
        inputManager: InputManager,
        scoreManager: ScoreManager
    ) {
        self.audioEngine = audioEngine
        self.inputManager = inputManager
        self.scoreManager = scoreManager
        self.notePool = NoteEntityPool()
    }

    // MARK: - Game Control
    func startSong(_ song: Song, difficulty: Difficulty) async {
        print("🎮 Starting song: \(song.title) on \(difficulty.rawValue)")

        // Create game session
        currentSession = GameSession(songID: song.id, difficulty: difficulty)

        // Load beat map
        currentBeatMap = loadBeatMap(for: song, difficulty: difficulty)
        guard let beatMap = currentBeatMap else {
            print("❌ Failed to load beat map")
            return
        }

        // Prepare spawn queue
        spawnQueue = beatMap.loadNoteEvents()
        nextSpawnIndex = 0

        // Initialize audio
        await audioEngine.loadSong(song)

        // Start countdown
        await countdown()

        // Start game loop
        isRunning = true
        gameStartTime = CACurrentMediaTime()

        // Start audio
        audioEngine.play()

        // Begin update loop
        startGameLoop()
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        audioEngine.pause()
        print("⏸️ Game paused")
    }

    func resume() {
        guard isRunning, isPaused else { return }
        isPaused = false
        audioEngine.resume()
        print("▶️ Game resumed")
    }

    func stop() {
        isRunning = false
        isPaused = false
        audioEngine.stop()

        // Cleanup
        currentSession?.end()
        clearAllNotes()

        print("⏹️ Game stopped")
    }

    func cleanup() {
        stop()
        activeNotes.removeAll()
        spawnQueue.removeAll()
        currentSession = nil
        currentBeatMap = nil
    }

    // MARK: - Game Loop
    private func startGameLoop() {
        Task {
            while isRunning {
                let frameStart = CACurrentMediaTime()

                if !isPaused {
                    await updateGameState(deltaTime: frameStart - lastFrameTime)
                }

                lastFrameTime = frameStart

                // Target 90 FPS = 11.1ms per frame
                try? await Task.sleep(for: .milliseconds(11))
            }
        }
    }

    private func updateGameState(deltaTime: TimeInterval) async {
        // Get current music time
        currentMusicTime = audioEngine.currentTime

        // 1. Spawn new notes
        spawnNotes()

        // 2. Update existing notes
        updateNotes(deltaTime: deltaTime)

        // 3. Check for hits
        await checkNoteHits()

        // 4. Remove missed/offscreen notes
        cleanupNotes()

        // 5. Check for song end
        checkSongEnd()

        // 6. Update performance metrics
        updatePerformanceMetrics()
    }

    // MARK: - Note Management
    private func spawnNotes() {
        guard nextSpawnIndex < spawnQueue.count else { return }

        while nextSpawnIndex < spawnQueue.count {
            let noteEvent = spawnQueue[nextSpawnIndex]

            // Check if it's time to spawn this note
            let spawnTime = noteEvent.timestamp - spawnLeadTime
            guard currentMusicTime >= spawnTime else { break }

            // Spawn the note
            let noteEntity = notePool.acquire(type: noteEvent.type)
            noteEntity.configure(from: noteEvent)
            activeNotes[noteEvent.id] = noteEntity

            nextSpawnIndex += 1

            print("📝 Spawned note #\(nextSpawnIndex) at time \(currentMusicTime)")
        }
    }

    private func updateNotes(deltaTime: TimeInterval) {
        for (_, note) in activeNotes {
            note.update(deltaTime: deltaTime)
        }
    }

    private func checkNoteHits() async {
        guard let inputState = await inputManager.currentHandState else { return }

        for (id, note) in activeNotes {
            guard !note.isHit else { continue }

            // Check timing window
            let timingDelta = abs(note.targetTime - currentMusicTime)
            guard timingDelta <= 0.2 else { continue } // 200ms window

            // Check hand collision
            let hand = note.requiredHand == .left ? inputState.leftHand : inputState.rightHand
            let distance = simd_distance(note.position, hand.position)

            if distance < note.hitRadius {
                // Valid hit!
                let quality = calculateHitQuality(timing: timingDelta, distance: distance)
                handleNoteHit(note, id: id, quality: quality)
            } else if timingDelta > 0.15 && currentMusicTime > note.targetTime {
                // Note passed, register miss
                handleNoteMiss(note, id: id)
            }
        }
    }

    private func handleNoteHit(_ note: NoteEntity, id: UUID, quality: HitQuality) {
        note.markAsHit(quality: quality)

        // Update score
        currentSession?.registerHit(quality, points: note.points)

        // Visual/audio feedback
        triggerHitFeedback(at: note.position, quality: quality)

        // Play hit sound
        audioEngine.playHitSound(quality: quality, at: note.position)

        print("🎯 Hit! Quality: \(quality.displayName)")
    }

    private func handleNoteMiss(_ note: NoteEntity, id: UUID) {
        note.markAsHit(quality: .miss)

        // Update score
        currentSession?.registerHit(.miss, points: 0)

        print("❌ Miss!")
    }

    private func cleanupNotes() {
        var notesToRemove: [UUID] = []

        for (id, note) in activeNotes {
            // Remove if hit or too far past
            if note.isHit || currentMusicTime > note.targetTime + 1.0 {
                notesToRemove.append(id)
            }
        }

        for id in notesToRemove {
            if let note = activeNotes.removeValue(forKey: id) {
                notePool.release(note)
            }
        }
    }

    private func clearAllNotes() {
        for (_, note) in activeNotes {
            notePool.release(note)
        }
        activeNotes.removeAll()
    }

    // MARK: - Hit Quality Calculation
    private func calculateHitQuality(timing: TimeInterval, distance: Float) -> HitQuality {
        // Perfect: < 50ms timing, < 0.05m distance
        if timing < 0.05 && distance < 0.05 {
            return .perfect
        }
        // Great: < 100ms timing, < 0.10m distance
        else if timing < 0.10 && distance < 0.10 {
            return .great
        }
        // Good: < 150ms timing, < 0.15m distance
        else if timing < 0.15 && distance < 0.15 {
            return .good
        }
        else {
            return .miss
        }
    }

    // MARK: - Feedback
    private func triggerHitFeedback(at position: SIMD3<Float>, quality: HitQuality) {
        // TODO: Trigger particle effects
        // TODO: Trigger haptic feedback
    }

    // MARK: - Song Management
    private func loadBeatMap(for song: Song, difficulty: Difficulty) -> BeatMap? {
        // Try to load from file
        guard let beatMapFileName = song.beatMapFileNames[difficulty] else {
            // Generate on-the-fly for prototype
            print("⚙️ Generating beat map for \(song.title)")
            return BeatMap.generateSample(
                difficulty: difficulty,
                songDuration: song.duration,
                bpm: song.bpm
            )
        }

        // TODO: Load from JSON file
        return BeatMap.generateSample(
            difficulty: difficulty,
            songDuration: song.duration,
            bpm: song.bpm
        )
    }

    private func countdown() async {
        print("3...")
        try? await Task.sleep(for: .seconds(1))
        print("2...")
        try? await Task.sleep(for: .seconds(1))
        print("1...")
        try? await Task.sleep(for: .seconds(1))
        print("GO!")
    }

    private func checkSongEnd() {
        guard let beatMap = currentBeatMap else { return }

        // Check if all notes have been spawned and cleared
        if nextSpawnIndex >= spawnQueue.count && activeNotes.isEmpty {
            stop()
            print("✅ Song completed!")
            // TODO: Show results screen
        }
    }

    // MARK: - Performance Monitoring
    private func updatePerformanceMetrics() {
        frameCount += 1

        if frameCount % 90 == 0 {  // Every second at 90fps
            let currentTime = CACurrentMediaTime()
            let elapsed = currentTime - lastFrameTime
            averageFPS = 90.0 / elapsed

            if averageFPS < 85.0 {
                print("⚠️ Performance warning: \(Int(averageFPS)) FPS")
            }
        }
    }
}
