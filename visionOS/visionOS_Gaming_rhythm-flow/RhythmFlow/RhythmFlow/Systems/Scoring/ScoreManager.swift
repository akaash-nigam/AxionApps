//
//  ScoreManager.swift
//  RhythmFlow
//
//  Manages scoring, combos, and performance tracking
//

import Foundation
import Observation

@Observable
class ScoreManager {
    // MARK: - Score State
    private(set) var currentScore: Int = 0
    private(set) var currentCombo: Int = 0
    private(set) var maxCombo: Int = 0
    private(set) var multiplier: Float = 1.0

    // MARK: - Statistics
    private(set) var perfectHits: Int = 0
    private(set) var greatHits: Int = 0
    private(set) var goodHits: Int = 0
    private(set) var missedNotes: Int = 0

    // MARK: - Combo Multipliers
    private let comboMultipliers: [Int: Float] = [
        10: 1.1,
        25: 1.25,
        50: 1.5,
        100: 2.0,
        200: 2.5
    ]

    // MARK: - Base Score Values
    private let perfectBonus: Int = 15
    private let greatBonus: Int = 0
    private let goodPenalty: Float = 0.75

    // MARK: - Computed Properties
    var totalHits: Int {
        perfectHits + greatHits + goodHits
    }

    var totalNotes: Int {
        totalHits + missedNotes
    }

    var accuracy: Double {
        guard totalNotes > 0 else { return 0 }

        let weightedScore = Double(
            perfectHits * 100 +
            greatHits * 85 +
            goodHits * 70
        )

        return weightedScore / (Double(totalNotes) * 100.0)
    }

    // MARK: - Hit Registration
    func registerHit(_ quality: HitQuality, noteValue: Int) {
        switch quality {
        case .perfect:
            perfectHits += 1
            currentCombo += 1
            addScore(noteValue + perfectBonus, withMultiplier: true)

        case .great:
            greatHits += 1
            currentCombo += 1
            addScore(noteValue + greatBonus, withMultiplier: true)

        case .good:
            goodHits += 1
            currentCombo += 1
            let penalizedScore = Int(Float(noteValue) * goodPenalty)
            addScore(penalizedScore, withMultiplier: true)

        case .miss:
            missedNotes += 1
            breakCombo()
        }

        // Update max combo
        maxCombo = max(maxCombo, currentCombo)

        // Update multiplier
        updateMultiplier()
    }

    // MARK: - Score Calculation
    private func addScore(_ points: Int, withMultiplier: Bool) {
        let finalPoints = withMultiplier ? Int(Float(points) * multiplier) : points
        currentScore += finalPoints

        print("💰 +\(finalPoints) points (combo: \(currentCombo)x, multiplier: \(multiplier)x)")
    }

    private func updateMultiplier() {
        // Find the highest applicable combo multiplier
        let applicableMultipliers = comboMultipliers.filter { currentCombo >= $0.key }
        multiplier = applicableMultipliers.values.max() ?? 1.0
    }

    private func breakCombo() {
        if currentCombo > 0 {
            print("💔 Combo broken at \(currentCombo)x")
        }

        currentCombo = 0
        multiplier = 1.0
    }

    // MARK: - Grade Calculation
    func calculateGrade() -> Grade {
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

    // MARK: - Reset
    func reset() {
        currentScore = 0
        currentCombo = 0
        maxCombo = 0
        multiplier = 1.0
        perfectHits = 0
        greatHits = 0
        goodHits = 0
        missedNotes = 0

        print("🔄 Score manager reset")
    }

    // MARK: - Statistics Export
    func exportStatistics() -> ScoreStatistics {
        ScoreStatistics(
            finalScore: currentScore,
            maxCombo: maxCombo,
            accuracy: accuracy,
            perfectHits: perfectHits,
            greatHits: greatHits,
            goodHits: goodHits,
            missedNotes: missedNotes,
            grade: calculateGrade()
        )
    }
}

// MARK: - Score Statistics

struct ScoreStatistics {
    let finalScore: Int
    let maxCombo: Int
    let accuracy: Double
    let perfectHits: Int
    let greatHits: Int
    let goodHits: Int
    let missedNotes: Int
    let grade: Grade

    var totalHits: Int {
        perfectHits + greatHits + goodHits
    }

    var totalNotes: Int {
        totalHits + missedNotes
    }

    var formattedAccuracy: String {
        String(format: "%.1f%%", accuracy * 100)
    }
}
