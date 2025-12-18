//
//  Molecule.swift
//  Molecular Design Platform
//
//  SwiftData model for molecular structures
//

import Foundation
import SwiftData
import RealityKit

// MARK: - Molecule Model

@Model
class Molecule {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var formula: String
    var molecularWeight: Double
    var createdDate: Date
    var modifiedDate: Date

    // Chemical structure
    var atoms: [Atom]
    var bonds: [Bond]

    // Computed properties
    var properties: MolecularProperties?

    // 3D representation
    var conformations: [Conformation]
    @Attribute(.externalStorage) var meshData: Data?

    // Metadata
    var tags: [String]

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Simulation.molecule)
    var simulations: [Simulation]

    @Relationship(inverse: \Project.molecules)
    var project: Project?

    @Relationship var derivedFrom: Molecule?
    @Relationship var derivatives: [Molecule]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        formula: String = "",
        atoms: [Atom] = [],
        bonds: [Bond] = []
    ) {
        self.id = id
        self.name = name
        self.formula = formula
        self.atoms = atoms
        self.bonds = bonds
        self.molecularWeight = 0.0
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.conformations = []
        self.tags = []
        self.simulations = []
        self.derivatives = []

        // Calculate initial properties
        self.updateFormula()
        self.updateMolecularWeight()
    }

    // MARK: - Methods

    func updateFormula() {
        // Count atoms by element
        var elementCounts: [Element: Int] = [:]
        for atom in atoms {
            elementCounts[atom.element, default: 0] += 1
        }

        // Build formula string (Hill system: C, H, then alphabetical)
        var formulaComponents: [String] = []

        // Carbon first
        if let carbonCount = elementCounts[.carbon] {
            formulaComponents.append(carbonCount > 1 ? "C\(carbonCount)" : "C")
        }

        // Hydrogen second
        if let hydrogenCount = elementCounts[.hydrogen] {
            formulaComponents.append(hydrogenCount > 1 ? "H\(hydrogenCount)" : "H")
        }

        // Rest alphabetically
        let remainingElements = elementCounts.keys
            .filter { $0 != .carbon && $0 != .hydrogen }
            .sorted { $0.symbol < $1.symbol }

        for element in remainingElements {
            let count = elementCounts[element]!
            formulaComponents.append(count > 1 ? "\(element.symbol)\(count)" : element.symbol)
        }

        self.formula = formulaComponents.joined()
    }

    func updateMolecularWeight() {
        self.molecularWeight = atoms.reduce(0.0) { $0 + $1.element.atomicWeight }
    }

    func addAtom(_ atom: Atom) {
        atoms.append(atom)
        updateFormula()
        updateMolecularWeight()
        modifiedDate = Date()
    }

    func removeAtom(_ atomID: UUID) {
        atoms.removeAll { $0.id == atomID }
        bonds.removeAll { $0.atom1 == atomID || $0.atom2 == atomID }
        updateFormula()
        updateMolecularWeight()
        modifiedDate = Date()
    }

    func addBond(_ bond: Bond) {
        bonds.append(bond)
        modifiedDate = Date()
    }

    func removeBond(_ bondID: UUID) {
        bonds.removeAll { $0.id == bondID }
        modifiedDate = Date()
    }
}

// MARK: - Atom Structure

struct Atom: Codable, Identifiable, Equatable {
    let id: UUID
    let element: Element
    var position: SIMD3<Float>
    var charge: Float
    var hybridization: Hybridization

    init(
        id: UUID = UUID(),
        element: Element,
        position: SIMD3<Float> = .zero,
        charge: Float = 0,
        hybridization: Hybridization = .sp3
    ) {
        self.id = id
        self.element = element
        self.position = position
        self.charge = charge
        self.hybridization = hybridization
    }

    static func == (lhs: Atom, rhs: Atom) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bond Structure

struct Bond: Codable, Identifiable, Equatable {
    let id: UUID
    let atom1: UUID
    let atom2: UUID
    var order: BondOrder
    var length: Float?

    init(
        id: UUID = UUID(),
        atom1: UUID,
        atom2: UUID,
        order: BondOrder = .single
    ) {
        self.id = id
        self.atom1 = atom1
        self.atom2 = atom2
        self.order = order
    }

    static func == (lhs: Bond, rhs: Bond) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bond Order

enum BondOrder: Int, Codable {
    case single = 1
    case double = 2
    case triple = 3
    case aromatic = 4

    var displayName: String {
        switch self {
        case .single: return "Single"
        case .double: return "Double"
        case .triple: return "Triple"
        case .aromatic: return "Aromatic"
        }
    }
}

// MARK: - Hybridization

enum Hybridization: String, Codable {
    case sp
    case sp2
    case sp3
    case sp3d
    case sp3d2

    var displayName: String { rawValue.uppercased() }
}

// MARK: - Conformation

struct Conformation: Codable, Identifiable {
    let id: UUID
    var atomPositions: [UUID: SIMD3<Float>]
    var energy: Double?
    var isOptimized: Bool

    init(
        id: UUID = UUID(),
        atomPositions: [UUID: SIMD3<Float>] = [:],
        energy: Double? = nil,
        isOptimized: Bool = false
    ) {
        self.id = id
        self.atomPositions = atomPositions
        self.energy = energy
        self.isOptimized = isOptimized
    }
}

// MARK: - Molecular Properties

struct MolecularProperties: Codable {
    // Calculated properties
    var logP: Double?
    var tpsa: Double?
    var hbd: Int?
    var hba: Int?

    // Predicted properties (AI/ML)
    var solubility: Prediction?
    var bioavailability: Prediction?
    var toxicity: Prediction?
    var bindingAffinity: [String: Prediction]?

    // Quantum properties
    var homo: Double?
    var lumo: Double?
    var dipole: SIMD3<Double>?

    init() {
        self.logP = nil
        self.tpsa = nil
        self.hbd = nil
        self.hba = nil
    }
}

// MARK: - Prediction

struct Prediction: Codable {
    let value: Double
    let confidence: Double
    let modelVersion: String
    let timestamp: Date

    var confidencePercentage: Int {
        Int(confidence * 100)
    }
}
