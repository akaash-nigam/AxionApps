//
//  GameSession.swift
//  RhythmFlow
//
//  Represents a single gameplay session
//

import Foundation

struct GameSession: Codable, Identifiable {
    let id: UUID
    let songID: UUID
    let difficulty: Difficulty
    let startTime: Date
    var endTime: Date?

    // Performance
    var score: Int = 0
    var maxCombo: Int = 0
    var currentCombo: Int = 0

    // Hit statistics
    var perfectHits: Int = 0
    var greatHits: Int = 0
    var goodHits: Int = 0
    var missedHits: Int = 0

    // Calculated properties
    var totalHits: Int {
        perfectHits + greatHits + goodHits + missedHits
    }

    var totalNotes: Int {
        totalHits + missedHits
    }

    init(
        songID: UUID,
        difficulty: Difficulty
    ) {
        self.id = UUID()
        self.songID = songID
        self.difficulty = difficulty
        self.startTime = Date()
    }

    mutating func registerHit(_ quality: HitQuality, points: Int) {
        switch quality {
        case .perfect:
            perfectHits += 1
            currentCombo += 1
            score += points + 15

        case .great:
            greatHits += 1
            currentCombo += 1
            score += points

        case .good:
            goodHits += 1
            currentCombo += 1
            score += Int(Double(points) * 0.75)

        case .miss:
            missedHits += 1
            currentCombo = 0
        }

        maxCombo = max(maxCombo, currentCombo)
    }

    func calculateAccuracy() -> Double {
        guard totalHits > 0 else { return 0 }

        let weightedScore = Double(
            perfectHits * 100 +
            greatHits * 85 +
            goodHits * 70
        )

        return weightedScore / (Double(totalHits) * 100.0)
    }

    func calculateGrade() -> Grade {
        let accuracy = calculateAccuracy()

        switch accuracy {
        case 0.95...1.0: return .sPlus
        case 0.90..<0.95: return .s
        case 0.85..<0.90: return .aPlus
        case 0.80..<0.85: return .a
        case 0.75..<0.80: return .b
        case 0.70..<0.75: return .c
        default: return .d
        }
    }

    mutating func end() {
        endTime = Date()
    }
}

// MARK: - Hit Quality

enum HitQuality: String, Codable {
    case perfect
    case great
    case good
    case miss

    var scoreMultiplier: Double {
        switch self {
        case .perfect: return 1.15
        case .great: return 1.0
        case .good: return 0.75
        case .miss: return 0.0
        }
    }

    var displayName: String {
        switch self {
        case .perfect: return "PERFECT!"
        case .great: return "Great"
        case .good: return "Good"
        case .miss: return "Miss"
        }
    }

    var color: String {
        switch self {
        case .perfect: return "gold"
        case .great: return "silver"
        case .good: return "bronze"
        case .miss: return "gray"
        }
    }
}

// MARK: - Grade

enum Grade: String, Codable {
    case sPlus = "S+"
    case s = "S"
    case aPlus = "A+"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case f = "F"

    var color: String {
        switch self {
        case .sPlus, .s: return "gold"
        case .aPlus, .a: return "silver"
        case .b: return "bronze"
        default: return "gray"
        }
    }
}
