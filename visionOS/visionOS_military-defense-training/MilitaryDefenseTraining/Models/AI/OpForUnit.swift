//
//  OpForUnit.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import Observation
import simd

@Observable
class OpForUnit {
    var id: UUID
    var unitType: OpForType
    var doctrine: TacticalDoctrine
    var aiDifficulty: AIDifficulty
    var combatEntity: CombatEntity?
    var currentObjective: TacticalObjective?
    var morale: Float // 0-100
    var combatEffectiveness: Float // 0-100
    var awarenessLevel: Float // 0-100
    var lastKnownPlayerPosition: SIMD3<Float>?
    var isEngaged: Bool
    var squadID: UUID?

    init(
        id: UUID = UUID(),
        unitType: OpForType,
        doctrine: TacticalDoctrine = .conventional,
        aiDifficulty: AIDifficulty = .medium,
        morale: Float = 75,
        combatEffectiveness: Float = 70,
        awarenessLevel: Float = 0
    ) {
        self.id = id
        self.unitType = unitType
        self.doctrine = doctrine
        self.aiDifficulty = aiDifficulty
        self.morale = morale
        self.combatEffectiveness = combatEffectiveness
        self.awarenessLevel = awarenessLevel
        self.isEngaged = false
    }

    func updateAwareness(playerVisible: Bool, distance: Float) {
        if playerVisible {
            let detectionFactor = aiDifficulty.detectionMultiplier
            let distanceFactor = 1.0 - min(distance / 100.0, 1.0)
            let awarenessIncrease = distanceFactor * detectionFactor * 10.0
            awarenessLevel = min(100, awarenessLevel + awarenessIncrease)
        } else {
            // Awareness decays over time
            awarenessLevel = max(0, awarenessLevel - 1.0)
        }
    }

    func takeDamage(amount: Float, from attacker: CombatEntity) {
        combatEntity?.takeDamage(amount)

        // Damage affects morale
        morale = max(0, morale - amount * 0.5)

        // Set to fully aware and engaged
        awarenessLevel = 100
        isEngaged = true
        lastKnownPlayerPosition = attacker.position
    }

    var alertState: AlertState {
        switch awarenessLevel {
        case 0..<25: return .unaware
        case 25..<50: return .suspicious
        case 50..<75: return .alert
        default: return .combat
        }
    }
}

// MARK: - OpFor Type
enum OpForType: String, Codable {
    case infantry = "Infantry"
    case heavyInfantry = "Heavy Infantry"
    case sniper = "Sniper"
    case vehicle = "Vehicle"
    case aircraft = "Aircraft"
    case specialist = "Specialist"
}

// MARK: - Tactical Doctrine
enum TacticalDoctrine: String, Codable {
    case conventional = "Conventional"
    case insurgent = "Insurgent"
    case terrorist = "Terrorist"
    case hybridWarfare = "Hybrid Warfare"

    var description: String {
        switch self {
        case .conventional:
            return "Standard military tactics with coordinated attacks"
        case .insurgent:
            return "Hit-and-run tactics, ambushes, and guerrilla warfare"
        case .terrorist:
            return "Unpredictable attacks, suicide tactics, civilian blending"
        case .hybridWarfare:
            return "Mix of conventional and unconventional tactics"
        }
    }
}

// MARK: - AI Difficulty
enum AIDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"

    var detectionMultiplier: Float {
        switch self {
        case .easy: return 0.5
        case .medium: return 1.0
        case .hard: return 1.5
        case .expert: return 2.0
        }
    }

    var accuracyMultiplier: Float {
        switch self {
        case .easy: return 0.4
        case .medium: return 0.7
        case .hard: return 0.9
        case .expert: return 0.95
        }
    }

    var reactionTime: TimeInterval {
        switch self {
        case .easy: return 2.0
        case .medium: return 1.0
        case .hard: return 0.5
        case .expert: return 0.25
        }
    }
}

// MARK: - Alert State
enum AlertState: String {
    case unaware = "Unaware"
    case suspicious = "Suspicious"
    case alert = "Alert"
    case combat = "Combat"

    var color: String {
        switch self {
        case .unaware: return "gray"
        case .suspicious: return "yellow"
        case .alert: return "orange"
        case .combat: return "red"
        }
    }
}

// MARK: - Tactical Objective
enum TacticalObjective {
    case patrol(waypoints: [SIMD3<Float>])
    case defend(position: SIMD3<Float>, radius: Float)
    case attack(target: SIMD3<Float>)
    case flank(target: SIMD3<Float>, direction: FlankDirection)
    case retreat(to: SIMD3<Float>)
    case takecover(near: SIMD3<Float>)
    case suppress(target: SIMD3<Float>)

    enum FlankDirection {
        case left
        case right
    }
}
