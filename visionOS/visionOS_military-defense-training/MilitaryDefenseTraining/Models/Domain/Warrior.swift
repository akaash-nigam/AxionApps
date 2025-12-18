//
//  Warrior.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class Warrior {
    var id: UUID
    var rank: MilitaryRank
    var name: String
    var unit: String
    var specialization: Specialization
    var clearanceLevel: ClassificationLevel
    var createdDate: Date
    var totalTrainingHours: Double
    var sessionsCompleted: Int
    var averageScore: Double

    init(
        id: UUID = UUID(),
        rank: MilitaryRank = .private_,
        name: String,
        unit: String,
        specialization: Specialization = .infantry,
        clearanceLevel: ClassificationLevel = .confidential,
        createdDate: Date = Date(),
        totalTrainingHours: Double = 0,
        sessionsCompleted: Int = 0,
        averageScore: Double = 0
    ) {
        self.id = id
        self.rank = rank
        self.name = name
        self.unit = unit
        self.specialization = specialization
        self.clearanceLevel = clearanceLevel
        self.createdDate = createdDate
        self.totalTrainingHours = totalTrainingHours
        self.sessionsCompleted = sessionsCompleted
        self.averageScore = averageScore
    }
}

// MARK: - Military Rank
enum MilitaryRank: String, Codable, CaseIterable {
    // Enlisted
    case private_ = "PVT"
    case privateFirstClass = "PFC"
    case specialist = "SPC"
    case corporal = "CPL"
    case sergeant = "SGT"
    case staffSergeant = "SSG"
    case sergeantFirstClass = "SFC"
    case masterSergeant = "MSG"
    case firstSergeant = "1SG"
    case sergeantMajor = "SGM"

    // Officers
    case secondLieutenant = "2LT"
    case firstLieutenant = "1LT"
    case captain = "CPT"
    case major = "MAJ"
    case lieutenantColonel = "LTC"
    case colonel = "COL"

    var displayName: String {
        switch self {
        case .private_: return "Private"
        case .privateFirstClass: return "Private First Class"
        case .specialist: return "Specialist"
        case .corporal: return "Corporal"
        case .sergeant: return "Sergeant"
        case .staffSergeant: return "Staff Sergeant"
        case .sergeantFirstClass: return "Sergeant First Class"
        case .masterSergeant: return "Master Sergeant"
        case .firstSergeant: return "First Sergeant"
        case .sergeantMajor: return "Sergeant Major"
        case .secondLieutenant: return "Second Lieutenant"
        case .firstLieutenant: return "First Lieutenant"
        case .captain: return "Captain"
        case .major: return "Major"
        case .lieutenantColonel: return "Lieutenant Colonel"
        case .colonel: return "Colonel"
        }
    }
}

// MARK: - Specialization
enum Specialization: String, Codable, CaseIterable {
    case infantry = "Infantry"
    case armor = "Armor"
    case artillery = "Artillery"
    case aviation = "Aviation"
    case specialForces = "Special Forces"
    case engineer = "Engineer"
    case medic = "Medic"
    case signalCorps = "Signal Corps"
    case intelligence = "Intelligence"

    var iconName: String {
        switch self {
        case .infantry: return "figure.walk"
        case .armor: return "car.fill"
        case .artillery: return "scope"
        case .aviation: return "airplane"
        case .specialForces: return "star.fill"
        case .engineer: return "wrench.fill"
        case .medic: return "cross.fill"
        case .signalCorps: return "antenna.radiowaves.left.and.right"
        case .intelligence: return "eye.fill"
        }
    }
}
