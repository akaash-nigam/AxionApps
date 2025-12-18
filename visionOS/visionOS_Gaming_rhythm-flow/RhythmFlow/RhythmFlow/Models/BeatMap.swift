//
//  BeatMap.swift
//  RhythmFlow
//
//  Beat map data structure
//

import Foundation
import simd

struct BeatMap: Codable {
    let difficulty: Difficulty
    let noteCount: Int
    let maxScore: Int
    let creator: String
    let createdDate: Date

    // Note sequences
    let noteEvents: [NoteEvent]
    let obstacleEvents: [ObstacleEvent]

    // Metadata
    let generatedByAI: Bool
    let aiVersion: String?

    init(
        difficulty: Difficulty,
        creator: String = "AI Generator",
        noteEvents: [NoteEvent],
        obstacleEvents: [ObstacleEvent] = [],
        generatedByAI: Bool = true,
        aiVersion: String? = "1.0"
    ) {
        self.difficulty = difficulty
        self.noteCount = noteEvents.count
        self.maxScore = noteEvents.reduce(0) { $0 + $1.points }
        self.creator = creator
        self.createdDate = Date()
        self.noteEvents = noteEvents
        self.obstacleEvents = obstacleEvents
        self.generatedByAI = generatedByAI
        self.aiVersion = aiVersion
    }

    func loadNoteEvents() -> [NoteEvent] {
        return noteEvents.sorted { $0.timestamp < $1.timestamp }
    }
}

// MARK: - Note Event

struct NoteEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval      // Seconds from song start
    let type: NoteType
    let position: SIMD3<Float>       // 3D spawn position
    let direction: SIMD3<Float>      // Movement direction
    let speed: Float
    let hand: Hand
    let gesture: GestureType
    let duration: TimeInterval?      // For hold notes
    let color: NoteColor
    let points: Int

    init(
        id: UUID = UUID(),
        timestamp: TimeInterval,
        type: NoteType,
        position: SIMD3<Float>,
        direction: SIMD3<Float> = SIMD3<Float>(0, 0, 1),
        speed: Float = 2.0,
        hand: Hand,
        gesture: GestureType,
        duration: TimeInterval? = nil,
        color: NoteColor? = nil,
        points: Int = 100
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.position = position
        self.direction = direction
        self.speed = speed
        self.hand = hand
        self.gesture = gesture
        self.duration = duration
        self.color = color ?? hand.defaultColor
        self.points = points
    }
}

// MARK: - Obstacle Event

struct ObstacleEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval
    let position: SIMD3<Float>
    let size: SIMD3<Float>
    let duration: TimeInterval

    init(
        id: UUID = UUID(),
        timestamp: TimeInterval,
        position: SIMD3<Float>,
        size: SIMD3<Float>,
        duration: TimeInterval
    ) {
        self.id = id
        self.timestamp = timestamp
        self.position = position
        self.size = size
        self.duration = duration
    }
}

// MARK: - Supporting Types

enum NoteType: String, Codable {
    case punch
    case swipe
    case hold
    case special
}

enum Hand: String, Codable {
    case left
    case right
    case both

    var defaultColor: NoteColor {
        switch self {
        case .left: return .blue
        case .right: return .red
        case .both: return .green
        }
    }
}

enum GestureType: String, Codable {
    case punch
    case swipeUp
    case swipeDown
    case swipeLeft
    case swipeRight
    case hold
    case clap
}

enum NoteColor: String, Codable {
    case blue
    case red
    case green
    case yellow
    case purple
    case orange

    var rgbValues: SIMD3<Float> {
        switch self {
        case .blue: return SIMD3<Float>(0.0, 0.85, 1.0)
        case .red: return SIMD3<Float>(1.0, 0.0, 0.33)
        case .green: return SIMD3<Float>(0.0, 1.0, 0.53)
        case .yellow: return SIMD3<Float>(1.0, 0.84, 0.0)
        case .purple: return SIMD3<Float>(0.72, 0.0, 1.0)
        case .orange: return SIMD3<Float>(1.0, 0.6, 0.0)
        }
    }
}

// MARK: - Sample Beat Map

extension BeatMap {
    static func generateSample(difficulty: Difficulty, songDuration: TimeInterval, bpm: Double) -> BeatMap {
        var noteEvents: [NoteEvent] = []
        let beatDuration = 60.0 / bpm
        let noteDensity = difficulty.multiplier

        // Generate notes based on beats
        var currentTime: TimeInterval = 2.0 // Start after 2 seconds

        while currentTime < songDuration - 2.0 {
            // Determine if note should spawn based on difficulty
            let shouldSpawn = Double.random(in: 0...1) < Double(noteDensity)

            if shouldSpawn {
                let hand: Hand = Bool.random() ? .left : .right
                let gesture: GestureType = [.punch, .swipeUp, .swipeDown].randomElement()!

                let note = NoteEvent(
                    timestamp: currentTime,
                    type: .punch,
                    position: SIMD3<Float>(
                        Float.random(in: -0.5...0.5),
                        Float.random(in: 1.0...1.6),
                        0.8
                    ),
                    hand: hand,
                    gesture: gesture
                )
                noteEvents.append(note)
            }

            currentTime += beatDuration
        }

        return BeatMap(
            difficulty: difficulty,
            noteEvents: noteEvents
        )
    }
}
