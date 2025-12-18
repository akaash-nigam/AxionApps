//
//  Experiment.swift
//  Science Lab Sandbox
//
//  Core experiment data model
//

import Foundation

// MARK: - Experiment

struct Experiment: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let discipline: ScientificDiscipline
    let difficulty: DifficultyLevel
    let description: String
    let learningObjectives: [String]
    let requiredEquipment: [EquipmentType]
    let safetyLevel: SafetyLevel
    let estimatedDuration: TimeInterval
    let prerequisites: [UUID]

    // Scientific parameters
    let variables: [ExperimentVariable]
    let expectedOutcomes: [OutcomeRange]
    let assessmentCriteria: [AssessmentCriterion]

    // Tutorial content
    let instructions: [ExperimentStep]
    let hints: [String]

    init(
        id: UUID = UUID(),
        name: String,
        discipline: ScientificDiscipline,
        difficulty: DifficultyLevel,
        description: String,
        learningObjectives: [String],
        requiredEquipment: [EquipmentType],
        safetyLevel: SafetyLevel,
        estimatedDuration: TimeInterval,
        prerequisites: [UUID] = [],
        variables: [ExperimentVariable] = [],
        expectedOutcomes: [OutcomeRange] = [],
        assessmentCriteria: [AssessmentCriterion] = [],
        instructions: [ExperimentStep] = [],
        hints: [String] = []
    ) {
        self.id = id
        self.name = name
        self.discipline = discipline
        self.difficulty = difficulty
        self.description = description
        self.learningObjectives = learningObjectives
        self.requiredEquipment = requiredEquipment
        self.safetyLevel = safetyLevel
        self.estimatedDuration = estimatedDuration
        self.prerequisites = prerequisites
        self.variables = variables
        self.expectedOutcomes = expectedOutcomes
        self.assessmentCriteria = assessmentCriteria
        self.instructions = instructions
        self.hints = hints
    }
}

// MARK: - Experiment Variable

struct ExperimentVariable: Codable, Hashable {
    let name: String
    let type: VariableType
    let defaultValue: Double
    let range: ClosedRange<Double>
    let unit: String

    enum VariableType: String, Codable {
        case temperature
        case pressure
        case volume
        case concentration
        case time
        case mass
        case force
        case custom
    }
}

// MARK: - Outcome Range

struct OutcomeRange: Codable, Hashable {
    let parameter: String
    let expectedRange: ClosedRange<Double>
    let unit: String
}

// MARK: - Assessment Criterion

struct AssessmentCriterion: Codable, Hashable {
    let criterion: String
    let weight: Double  // 0.0 to 1.0
    let description: String
}

// MARK: - Experiment Step

struct ExperimentStep: Codable, Hashable, Identifiable {
    let id: UUID
    let stepNumber: Int
    let title: String
    let instruction: String
    let visualAid: String?  // Asset name
    let expectedDuration: TimeInterval
    let safetyWarnings: [String]

    init(
        id: UUID = UUID(),
        stepNumber: Int,
        title: String,
        instruction: String,
        visualAid: String? = nil,
        expectedDuration: TimeInterval,
        safetyWarnings: [String] = []
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.instruction = instruction
        self.visualAid = visualAid
        self.expectedDuration = expectedDuration
        self.safetyWarnings = safetyWarnings
    }
}

// MARK: - Scientific Discipline

enum ScientificDiscipline: String, Codable, CaseIterable, Identifiable {
    case chemistry
    case physics
    case biology
    case astronomy
    case earthScience

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chemistry: return "Chemistry"
        case .physics: return "Physics"
        case .biology: return "Biology"
        case .astronomy: return "Astronomy"
        case .earthScience: return "Earth Science"
        }
    }

    var icon: String {
        switch self {
        case .chemistry: return "flask"
        case .physics: return "atom"
        case .biology: return "leaf"
        case .astronomy: return "sparkles"
        case .earthScience: return "globe"
        }
    }

    var color: String {
        switch self {
        case .chemistry: return "blue"
        case .physics: return "green"
        case .biology: return "pink"
        case .astronomy: return "purple"
        case .earthScience: return "brown"
        }
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: Int, Codable, CaseIterable, Identifiable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    case expert = 4
    case master = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        case .master: return "Master"
        }
    }

    var stars: Int { rawValue }
}

// MARK: - Safety Level

enum SafetyLevel: Int, Codable, Comparable {
    case safe = 0
    case caution = 1
    case dangerous = 2
    case extreme = 3

    static func < (lhs: SafetyLevel, rhs: SafetyLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .safe: return "Safe"
        case .caution: return "Caution"
        case .dangerous: return "Dangerous"
        case .extreme: return "Extreme Danger"
        }
    }

    var color: String {
        switch self {
        case .safe: return "green"
        case .caution: return "yellow"
        case .dangerous: return "orange"
        case .extreme: return "red"
        }
    }

    var systemImage: String {
        switch self {
        case .safe: return "checkmark.shield"
        case .caution: return "exclamationmark.triangle"
        case .dangerous: return "exclamationmark.octagon"
        case .extreme: return "xmark.octagon"
        }
    }
}
