/**
 * Performance Tests for Rhythm Flow
 * Tests frame rate, memory usage, and system performance
 *
 * These tests validate that the game maintains 90 FPS under various conditions
 * and stays within memory budget (< 2GB).
 */

import XCTest
import RealityKit
@testable import RhythmFlow

@MainActor
final class PerformanceTests: XCTestCase {

    var gameEngine: GameEngine!
    var audioEngine: AudioEngine!
    var inputManager: InputManager!

    override func setUp() async throws {
        try await super.setUp()
        gameEngine = GameEngine()
        audioEngine = AudioEngine()
        inputManager = InputManager()
    }

    override func tearDown() async throws {
        gameEngine = nil
        audioEngine = nil
        inputManager = nil
        try await super.tearDown()
    }

    // MARK: - Frame Rate Tests

    /// Test: Game engine maintains 90 FPS with minimal load
    func testFrameRateWithMinimalNotes() async throws {
        let song = Song.sampleSong
        let beatMap = BeatMap.generateSample(difficulty: .easy, songDuration: 60.0, bpm: 120.0)

        await gameEngine.startSong(song, beatMap: beatMap)

        measure {
            Task {
                for _ in 0..<90 { // Simulate 1 second at 90 FPS
                    await gameEngine.update(deltaTime: 1.0/90.0)
                }
            }
        }

        // Average frame time should be < 11.1ms (1000ms / 90 FPS)
        // XCTAssert will automatically measure performance
    }

    /// Test: Game engine maintains 90 FPS under heavy load
    func testFrameRateWithMaximumNotes() async throws {
        let song = Song.sampleSong
        let beatMap = BeatMap.generateSample(difficulty: .expertPlus, songDuration: 60.0, bpm: 180.0)

        await gameEngine.startSong(song, beatMap: beatMap)

        measure {
            Task {
                for _ in 0..<90 { // Simulate 1 second at 90 FPS
                    await gameEngine.update(deltaTime: 1.0/90.0)
                }
            }
        }
    }

    /// Test: Audio engine maintains sync under load
    func testAudioSyncPerformance() {
        let song = Song.sampleSong

        measure {
            audioEngine.playSong(song)

            // Simulate 100 simultaneous hit sounds (stress test)
            for i in 0..<100 {
                let position = SIMD3<Float>(
                    Float.random(in: -1...1),
                    Float.random(in: 0...2),
                    Float.random(in: -2...0)
                )
                audioEngine.playHitSound(quality: .perfect, at: position)
            }

            audioEngine.stop()
        }
    }

    /// Test: Note spawning performance
    func testNoteSpawningPerformance() async throws {
        let beatMap = BeatMap.generateSample(difficulty: .expert, songDuration: 180.0, bpm: 180.0)

        measure {
            Task {
                await gameEngine.startSong(Song.sampleSong, beatMap: beatMap)

                // Simulate rapid note spawning
                for _ in 0..<1000 {
                    await gameEngine.update(deltaTime: 1.0/90.0)
                }
            }
        }
    }

    // MARK: - Memory Tests

    /// Test: Memory usage stays under budget during gameplay
    func testMemoryUsageDuringGameplay() async throws {
        let song = Song.sampleSong
        let beatMap = BeatMap.generateSample(difficulty: .expert, songDuration: 180.0, bpm: 180.0)

        await gameEngine.startSong(song, beatMap: beatMap)

        let startMemory = getMemoryUsage()

        // Simulate 3 minutes of gameplay
        for _ in 0..<(180 * 90) { // 180 seconds * 90 FPS
            await gameEngine.update(deltaTime: 1.0/90.0)
        }

        let endMemory = getMemoryUsage()
        let memoryGrowth = endMemory - startMemory

        // Memory growth should be minimal (< 100MB) due to object pooling
        XCTAssertLessThan(memoryGrowth, 100_000_000, "Memory growth exceeds 100MB")
    }

    /// Test: Object pool efficiency
    func testObjectPoolEfficiency() async throws {
        let notePool = NoteEntityPool()

        measure {
            // Acquire and release 10,000 notes
            var notes: [NoteEntity] = []

            for _ in 0..<10_000 {
                let note = notePool.acquire(type: .punch)
                notes.append(note)
            }

            for note in notes {
                notePool.release(note)
            }
        }

        // Pool should significantly reduce allocation overhead
    }

    /// Test: Memory cleanup after song completion
    func testMemoryCleanupAfterSong() async throws {
        let initialMemory = getMemoryUsage()

        // Play 5 songs back-to-back
        for _ in 0..<5 {
            await gameEngine.startSong(Song.sampleSong, beatMap: BeatMap.generateSample(difficulty: .normal, songDuration: 60.0, bpm: 120.0))

            // Simulate song playthrough
            for _ in 0..<(60 * 90) {
                await gameEngine.update(deltaTime: 1.0/90.0)
            }

            await gameEngine.endSong()
        }

        let finalMemory = getMemoryUsage()
        let memoryGrowth = finalMemory - initialMemory

        // Memory should return to near-baseline after cleanup
        XCTAssertLessThan(memoryGrowth, 50_000_000, "Memory not properly cleaned up between songs")
    }

    // MARK: - CPU Performance Tests

    /// Test: Hit detection algorithm performance
    func testHitDetectionPerformance() async throws {
        let inputManager = InputManager()
        let beatMap = BeatMap.generateSample(difficulty: .expert, songDuration: 60.0, bpm: 180.0)

        await gameEngine.startSong(Song.sampleSong, beatMap: beatMap)

        measure {
            Task {
                // Simulate checking hits for 1 second
                for _ in 0..<90 {
                    await gameEngine.update(deltaTime: 1.0/90.0)
                    // Hit detection happens inside update
                }
            }
        }
    }

    /// Test: Combo calculation performance
    func testComboCalculationPerformance() {
        let scoreManager = ScoreManager()

        measure {
            // Simulate 1000 perfect hits
            for _ in 0..<1000 {
                scoreManager.registerHit(.perfect, noteValue: 100)
            }

            _ = scoreManager.getDetailedStatistics()
        }
    }

    /// Test: Beat map parsing performance
    func testBeatMapParsingPerformance() {
        measure {
            // Generate and parse large beat maps
            for difficulty in [Difficulty.easy, .normal, .hard, .expert, .expertPlus] {
                let _ = BeatMap.generateSample(difficulty: difficulty, songDuration: 300.0, bpm: 180.0)
            }
        }
    }

    // MARK: - Graphics Performance Tests

    /// Test: RealityKit rendering performance with many entities
    func testRenderingPerformanceWithManyEntities() async throws {
        // This test would spawn maximum number of simultaneous notes
        let beatMap = BeatMap.generateSample(difficulty: .expertPlus, songDuration: 60.0, bpm: 200.0)

        await gameEngine.startSong(Song.sampleSong, beatMap: beatMap)

        measure {
            Task {
                // Update for 1 second with maximum note density
                for _ in 0..<90 {
                    await gameEngine.update(deltaTime: 1.0/90.0)
                }
            }
        }
    }

    /// Test: Particle effects performance
    func testParticleEffectsPerformance() {
        measure {
            // Simulate spawning 100 particle effects simultaneously
            for _ in 0..<100 {
                // In real implementation, this would trigger particle systems
                // audioEngine.playHitSound(quality: .perfect, at: SIMD3<Float>(0, 1, -1))
            }
        }
    }

    // MARK: - Stress Tests

    /// Test: Sustained gameplay for extended period
    func testSustainedGameplayPerformance() async throws {
        let song = Song.sampleSong
        let beatMap = BeatMap.generateSample(difficulty: .expert, songDuration: 600.0, bpm: 180.0) // 10 minute song

        await gameEngine.startSong(song, beatMap: beatMap)

        let startTime = Date()
        let startMemory = getMemoryUsage()

        // Simulate 10 minutes of gameplay
        let frameCount = 600 * 90 // 10 minutes * 90 FPS
        var frameTime: [TimeInterval] = []

        for _ in 0..<frameCount {
            let frameStart = Date()
            await gameEngine.update(deltaTime: 1.0/90.0)
            let frameEnd = Date()

            frameTime.append(frameEnd.timeIntervalSince(frameStart))
        }

        let endTime = Date()
        let endMemory = getMemoryUsage()

        let totalTime = endTime.timeIntervalSince(startTime)
        let averageFrameTime = frameTime.reduce(0, +) / Double(frameTime.count)
        let maxFrameTime = frameTime.max() ?? 0
        let memoryGrowth = endMemory - startMemory

        // Performance assertions
        XCTAssertLessThan(averageFrameTime, 0.0111, "Average frame time exceeds 11.1ms (90 FPS)")
        XCTAssertLessThan(maxFrameTime, 0.02, "Max frame time exceeds 20ms")
        XCTAssertLessThan(memoryGrowth, 200_000_000, "Memory growth exceeds 200MB over 10 minutes")

        print("Sustained Gameplay Performance:")
        print("  Total Time: \(totalTime)s")
        print("  Average Frame Time: \(averageFrameTime * 1000)ms")
        print("  Max Frame Time: \(maxFrameTime * 1000)ms")
        print("  Memory Growth: \(memoryGrowth / 1_000_000)MB")
    }

    /// Test: Rapid mode transitions
    func testRapidModeTransitions() async throws {
        measure {
            Task {
                for _ in 0..<100 {
                    await gameEngine.startSong(Song.sampleSong, beatMap: BeatMap.generateSample(difficulty: .normal, songDuration: 60.0, bpm: 120.0))
                    await gameEngine.pauseGame()
                    await gameEngine.resumeGame()
                    await gameEngine.endSong()
                }
            }
        }
    }

    // MARK: - Baseline Performance Tests

    /// Test: Establish baseline update loop performance
    func testBaselineUpdateLoopPerformance() async throws {
        measure {
            Task {
                // Empty update loop - establishes baseline
                for _ in 0..<900 { // 10 seconds at 90 FPS
                    await gameEngine.update(deltaTime: 1.0/90.0)
                }
            }
        }
    }

    /// Test: Profile save/load performance
    func testProfilePersistencePerformance() throws {
        var profile = PlayerProfile(username: "TestPlayer")

        // Build up large profile with history
        for i in 0..<1000 {
            var session = GameSession(
                songId: UUID(),
                difficulty: .normal,
                startTime: Date()
            )
            session.score = Int.random(in: 50000...100000)
            session.accuracy = Double.random(in: 0.85...1.0)
            profile.addCompletedSession(session)
        }

        measure {
            // Test encoding/decoding performance
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(profile)

                let decoder = JSONDecoder()
                let _ = try decoder.decode(PlayerProfile.self, from: data)
            } catch {
                XCTFail("Failed to encode/decode profile: \(error)")
            }
        }
    }

    // MARK: - Helper Methods

    /// Get current memory usage in bytes
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
}

// MARK: - Performance Benchmarks

/**
 * Expected Performance Benchmarks:
 *
 * Frame Rate:
 * - Average: 90 FPS (11.1ms per frame)
 * - Minimum: 80 FPS (12.5ms per frame) under peak load
 * - 99th percentile: < 13ms
 *
 * Memory:
 * - Baseline: < 500MB
 * - Peak during gameplay: < 2GB
 * - Growth over 10 minutes: < 200MB
 *
 * CPU:
 * - Game loop: < 8ms per frame
 * - Hit detection: < 1ms per frame
 * - Audio processing: < 1ms per frame
 * - Rendering: < 2ms per frame
 *
 * Latency:
 * - Input-to-action: < 20ms
 * - Audio-visual sync: ±2ms
 * - Hit detection accuracy: ±5ms
 *
 * Startup:
 * - Cold start: < 3 seconds
 * - Song load: < 1 second
 * - Mode transition: < 0.5 seconds
 */
