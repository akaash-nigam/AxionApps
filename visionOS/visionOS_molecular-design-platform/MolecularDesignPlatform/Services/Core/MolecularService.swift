//
//  MolecularService.swift
//  Molecular Design Platform
//
//  Core service for molecule CRUD operations
//

import Foundation
import SwiftData

// MARK: - Molecular Service

@Observable
class MolecularService {
    // MARK: - Properties

    private let modelContext: ModelContext
    private let chemistryEngine: ChemistryEngine

    // MARK: - Initialization

    init(modelContext: ModelContext, chemistryEngine: ChemistryEngine) {
        self.modelContext = modelContext
        self.chemistryEngine = chemistryEngine
    }

    // MARK: - CRUD Operations

    /// Create a new molecule from SMILES notation
    func createMolecule(from smiles: String) async throws -> Molecule {
        // Parse SMILES to create atoms and bonds
        let (atoms, bonds) = try parseSMILES(smiles)

        // Create molecule
        let molecule = Molecule(
            name: "Untitled Molecule",
            atoms: atoms,
            bonds: bonds
        )

        // Generate 3D conformation
        try await generateInitialConformation(for: molecule)

        // Insert into database
        modelContext.insert(molecule)
        try modelContext.save()

        return molecule
    }

    /// Fetch a specific molecule by ID
    func fetchMolecule(id: UUID) async throws -> Molecule? {
        let predicate = #Predicate<Molecule> { molecule in
            molecule.id == id
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        let molecules = try modelContext.fetch(descriptor)

        return molecules.first
    }

    /// Fetch all molecules
    func fetchAllMolecules() async throws -> [Molecule] {
        let descriptor = FetchDescriptor<Molecule>(
            sortBy: [SortDescriptor(\.modifiedDate, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    /// Search molecules by name or formula
    func search(query: String) async throws -> [Molecule] {
        let predicate = #Predicate<Molecule> { molecule in
            molecule.name.contains(query) || molecule.formula.contains(query)
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    /// Update an existing molecule
    func updateMolecule(_ molecule: Molecule) async throws {
        molecule.modifiedDate = Date()
        molecule.updateFormula()
        molecule.updateMolecularWeight()

        try modelContext.save()
    }

    /// Delete a molecule
    func deleteMolecule(id: UUID) async throws {
        guard let molecule = try await fetchMolecule(id: id) else {
            throw MolecularServiceError.moleculeNotFound
        }

        modelContext.delete(molecule)
        try modelContext.save()
    }

    // MARK: - Advanced Operations

    /// Calculate molecular properties
    func calculateProperties(for molecule: Molecule) async throws -> MolecularProperties {
        var properties = MolecularProperties()

        // Basic calculations
        properties.logP = try chemistryEngine.calculateLogP(molecule)
        properties.tpsa = try chemistryEngine.calculateTPSA(molecule)
        properties.hbd = chemistryEngine.countHydrogenBondDonors(molecule)
        properties.hba = chemistryEngine.countHydrogenBondAcceptors(molecule)

        // Save properties
        molecule.properties = properties
        try modelContext.save()

        return properties
    }

    /// Generate multiple conformations
    func generateConformations(for molecule: Molecule, count: Int) async throws -> [Conformation] {
        var conformations: [Conformation] = []

        for _ in 0..<count {
            let conformation = try await chemistryEngine.generateConformation(molecule)
            conformations.append(conformation)
        }

        molecule.conformations = conformations
        try modelContext.save()

        return conformations
    }

    /// Find similar molecules (based on structure similarity)
    func searchSimilar(to molecule: Molecule, threshold: Double) async throws -> [Molecule] {
        let allMolecules = try await fetchAllMolecules()

        // Filter molecules by Tanimoto similarity
        let similar = allMolecules.filter { otherMolecule in
            guard otherMolecule.id != molecule.id else { return false }

            let similarity = chemistryEngine.calculateSimilarity(molecule, otherMolecule)
            return similarity >= threshold
        }

        return similar
    }

    // MARK: - Private Methods

    private func parseSMILES(_ smiles: String) throws -> ([Atom], [Bond]) {
        // Simplified SMILES parser - in production, use a proper chemistry library
        var atoms: [Atom] = []
        var bonds: [Bond] = []

        // Basic SMILES parsing for common molecules
        switch smiles {
        case "C":
            // Methane: CH4
            let carbon = Atom(element: .carbon, position: SIMD3<Float>(0, 0, 0))
            atoms.append(carbon)
            for i in 0..<4 {
                let angle = Float(i) * 2.0 * .pi / 4.0
                let hydrogen = Atom(
                    element: .hydrogen,
                    position: SIMD3<Float>(cos(angle), sin(angle), 0.0)
                )
                atoms.append(hydrogen)
                bonds.append(Bond(atom1: carbon.id, atom2: hydrogen.id))
            }

        case "CC":
            // Ethane: C2H6
            let carbon1 = Atom(element: .carbon, position: SIMD3<Float>(-0.75, 0, 0))
            let carbon2 = Atom(element: .carbon, position: SIMD3<Float>(0.75, 0, 0))
            atoms.append(carbon1)
            atoms.append(carbon2)
            bonds.append(Bond(atom1: carbon1.id, atom2: carbon2.id))

        case "CCO":
            // Ethanol: C2H6O
            let carbon1 = Atom(element: .carbon, position: SIMD3<Float>(-1.5, 0, 0))
            let carbon2 = Atom(element: .carbon, position: SIMD3<Float>(0, 0, 0))
            let oxygen = Atom(element: .oxygen, position: SIMD3<Float>(1.5, 0, 0))
            atoms.append(carbon1)
            atoms.append(carbon2)
            atoms.append(oxygen)
            bonds.append(Bond(atom1: carbon1.id, atom2: carbon2.id))
            bonds.append(Bond(atom1: carbon2.id, atom2: oxygen.id))

        case "O=C=O":
            // Carbon dioxide: CO2
            let carbon = Atom(element: .carbon, position: SIMD3<Float>(0, 0, 0))
            let oxygen1 = Atom(element: .oxygen, position: SIMD3<Float>(-1.2, 0, 0))
            let oxygen2 = Atom(element: .oxygen, position: SIMD3<Float>(1.2, 0, 0))
            atoms.append(oxygen1)
            atoms.append(carbon)
            atoms.append(oxygen2)
            bonds.append(Bond(atom1: oxygen1.id, atom2: carbon.id, order: .double))
            bonds.append(Bond(atom1: carbon.id, atom2: oxygen2.id, order: .double))

        default:
            throw MolecularServiceError.invalidSMILES
        }

        return (atoms, bonds)
    }

    private func generateInitialConformation(for molecule: Molecule) async throws {
        // Generate a simple 3D conformation
        // In production, use a proper conformer generation algorithm
        let conformation = Conformation(
            atomPositions: molecule.atoms.reduce(into: [:]) { result, atom in
                result[atom.id] = atom.position
            },
            isOptimized: false
        )

        molecule.conformations.append(conformation)
    }
}

// MARK: - Molecular Service Errors

enum MolecularServiceError: LocalizedError {
    case moleculeNotFound
    case invalidSMILES
    case invalidFileFormat
    case calculationFailed

    var errorDescription: String? {
        switch self {
        case .moleculeNotFound:
            return "Molecule not found in database"
        case .invalidSMILES:
            return "Invalid SMILES notation"
        case .invalidFileFormat:
            return "Unsupported file format"
        case .calculationFailed:
            return "Property calculation failed"
        }
    }
}
