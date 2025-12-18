//
//  Simulation.swift
//  Molecular Design Platform
//
//  Molecular simulation models (MD, docking, quantum)
//

import Foundation
import SwiftData
import RealityKit

// MARK: - Simulation Model

@Model
class Simulation {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: SimulationType
    var status: SimulationStatus
    var progress: Double

    // Parameters
    var parameters: SimulationParameters

    // Results
    var frames: [SimulationFrame]
    @Attribute(.externalStorage) var trajectoryData: Data?

    // Metadata
    var startTime: Date?
    var endTime: Date?
    var computeTime: TimeInterval?

    // Relationships
    @Relationship var molecule: Molecule?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        type: SimulationType,
        molecule: Molecule? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.status = .queued
        self.progress = 0.0
        self.parameters = SimulationParameters(type: type)
        self.frames = []
        self.molecule = molecule
    }
}

// MARK: - Simulation Type

enum SimulationType: String, Codable {
    case molecularDynamics
    case docking
    case quantumChemistry
    case conformationalSearch
    case monteCarlo

    var displayName: String {
        switch self {
        case .molecularDynamics: return "Molecular Dynamics"
        case .docking: return "Molecular Docking"
        case .quantumChemistry: return "Quantum Chemistry"
        case .conformationalSearch: return "Conformational Search"
        case .monteCarlo: return "Monte Carlo"
        }
    }

    var description: String {
        switch self {
        case .molecularDynamics:
            return "Simulate atomic motion over time"
        case .docking:
            return "Predict binding poses and affinity"
        case .quantumChemistry:
            return "Calculate electronic structure"
        case .conformationalSearch:
            return "Find low-energy conformations"
        case .monteCarlo:
            return "Sample configuration space"
        }
    }
}

// MARK: - Simulation Status

enum SimulationStatus: String, Codable {
    case queued
    case running
    case paused
    case completed
    case failed
    case cancelled

    var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .running: return "Running"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }

    var isActive: Bool {
        self == .running || self == .queued
    }

    var isFinished: Bool {
        self == .completed || self == .failed || self == .cancelled
    }
}

// MARK: - Simulation Parameters

struct SimulationParameters: Codable {
    var type: SimulationType

    // Molecular Dynamics parameters
    var temperature: Double // Kelvin
    var pressure: Double? // Atmospheres
    var timeStep: Double // Femtoseconds
    var duration: Double // Picoseconds
    var frameCount: Int

    // Force field
    var forceField: ForceField

    // Docking parameters
    var gridSize: SIMD3<Float>?
    var gridCenter: SIMD3<Float>?
    var exhaustiveness: Int?

    // Quantum chemistry parameters
    var basisSet: String?
    var method: String?

    init(type: SimulationType) {
        self.type = type

        // Default MD parameters
        self.temperature = 298.0 // Room temperature
        self.pressure = 1.0 // 1 atm
        self.timeStep = 1.0 // 1 fs
        self.duration = 10.0 // 10 ps
        self.frameCount = 1000
        self.forceField = .amber

        // Docking defaults
        if type == .docking {
            self.exhaustiveness = 8
        }

        // Quantum defaults
        if type == .quantumChemistry {
            self.basisSet = "6-31G*"
            self.method = "B3LYP"
        }
    }
}

// MARK: - Force Field

enum ForceField: String, Codable {
    case amber = "AMBER"
    case charmm = "CHARMM"
    case opls = "OPLS"
    case gaff = "GAFF"

    var displayName: String { rawValue }
}

// MARK: - Simulation Frame

struct SimulationFrame: Codable, Identifiable {
    let id: UUID
    let frameNumber: Int
    let timestamp: Double // Picoseconds
    var atomPositions: [SIMD3<Float>]
    var energy: Double
    var temperature: Double?
    var pressure: Double?
    var volume: Double?

    init(
        id: UUID = UUID(),
        frameNumber: Int,
        timestamp: Double,
        atomPositions: [SIMD3<Float>],
        energy: Double
    ) {
        self.id = id
        self.frameNumber = frameNumber
        self.timestamp = timestamp
        self.atomPositions = atomPositions
        self.energy = energy
    }
}

// MARK: - Simulation Progress

struct SimulationProgress {
    let simulationID: UUID
    let progress: Double // 0.0 to 1.0
    let currentFrame: Int
    let totalFrames: Int
    let currentEnergy: Double
    let estimatedTimeRemaining: TimeInterval?

    var progressPercentage: Int {
        Int(progress * 100)
    }
}

// MARK: - Docking Result

struct DockingResult: Codable {
    let pose: Conformation
    let bindingEnergy: Double // kcal/mol
    let ligandEfficiency: Double
    let interactions: [Interaction]

    struct Interaction: Codable {
        let type: InteractionType
        let residue: String?
        let distance: Float
        let energy: Double

        enum InteractionType: String, Codable {
            case hydrogenBond
            case hydrophobic
            case piStacking
            case saltBridge
            case metalCoordination
        }
    }
}

// MARK: - Quantum Result

struct QuantumResult: Codable {
    let energy: Double // Hartrees
    let homo: Double // eV
    let lumo: Double // eV
    let dipole: SIMD3<Double> // Debye
    let charges: [Double] // Mulliken or ESP charges
    let orbitals: [MolecularOrbital]?

    var bandGap: Double {
        lumo - homo
    }

    struct MolecularOrbital: Codable {
        let energy: Double
        let occupancy: Double
        let type: OrbitalType

        enum OrbitalType: String, Codable {
            case sigma
            case pi
            case nonbonding
        }
    }
}
