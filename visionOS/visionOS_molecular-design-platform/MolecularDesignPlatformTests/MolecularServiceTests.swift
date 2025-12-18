//
//  MolecularServiceTests.swift
//  Molecular Design Platform Tests
//
//  Unit tests for MolecularService
//

import XCTest
import SwiftData
@testable import MolecularDesignPlatform

final class MolecularServiceTests: XCTestCase {
    var service: MolecularService!
    var modelContext: ModelContext!
    var chemistryEngine: ChemistryEngine!

    override func setUp() async throws {
        // Create in-memory model container for testing
        let schema = Schema([Molecule.self, Project.self, Simulation.self, Experiment.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        chemistryEngine = ChemistryEngine()
        service = MolecularService(modelContext: modelContext, chemistryEngine: chemistryEngine)
    }

    override func tearDown() {
        service = nil
        modelContext = nil
        chemistryEngine = nil
    }

    // MARK: - Tests

    func testCreateMoleculeFromSMILES() async throws {
        // Test creating ethanol from SMILES
        let smiles = "CCO"
        let molecule = try await service.createMolecule(from: smiles)

        XCTAssertEqual(molecule.formula, "C2H6O", "Formula should be C2H6O for ethanol")
        XCTAssertEqual(molecule.atoms.count, 3, "Should have 3 heavy atoms")
        XCTAssertEqual(molecule.bonds.count, 2, "Should have 2 bonds")
    }

    func testCalculateProperties() async throws {
        // Create a test molecule
        let carbon = Atom(element: .carbon, position: .zero)
        let oxygen = Atom(element: .oxygen, position: SIMD3<Float>(1.5, 0, 0))
        let molecule = Molecule(name: "Test", atoms: [carbon, oxygen], bonds: [])

        modelContext.insert(molecule)

        // Calculate properties
        let properties = try await service.calculateProperties(for: molecule)

        XCTAssertNotNil(properties.logP, "LogP should be calculated")
        XCTAssertNotNil(properties.tpsa, "TPSA should be calculated")
        XCTAssertNotNil(properties.hbd, "Hydrogen bond donors should be counted")
        XCTAssertNotNil(properties.hba, "Hydrogen bond acceptors should be counted")
    }

    func testFetchMolecule() async throws {
        // Create and save a molecule
        let molecule = Molecule(name: "Test Molecule")
        modelContext.insert(molecule)
        try modelContext.save()

        // Fetch it back
        let fetchedMolecule = try await service.fetchMolecule(id: molecule.id)

        XCTAssertNotNil(fetchedMolecule, "Should fetch the molecule")
        XCTAssertEqual(fetchedMolecule?.name, "Test Molecule")
    }

    func testDeleteMolecule() async throws {
        // Create molecule
        let molecule = Molecule(name: "To Delete")
        modelContext.insert(molecule)
        try modelContext.save()

        let moleculeID = molecule.id

        // Delete it
        try await service.deleteMolecule(id: moleculeID)

        // Verify deletion
        let fetched = try await service.fetchMolecule(id: moleculeID)
        XCTAssertNil(fetched, "Molecule should be deleted")
    }

    func testSearchMolecules() async throws {
        // Create test molecules
        let mol1 = Molecule(name: "Ethanol", formula: "C2H6O")
        let mol2 = Molecule(name: "Methanol", formula: "CH4O")
        let mol3 = Molecule(name: "Benzene", formula: "C6H6")

        modelContext.insert(mol1)
        modelContext.insert(mol2)
        modelContext.insert(mol3)
        try modelContext.save()

        // Search for molecules containing "eth"
        let results = try await service.search(query: "eth")

        XCTAssertEqual(results.count, 2, "Should find Ethanol and Methanol")
        XCTAssertTrue(results.contains { $0.name == "Ethanol" })
        XCTAssertTrue(results.contains { $0.name == "Methanol" })
    }

    func testMolecularWeightCalculation() {
        // Test water: H2O = 2*1.008 + 15.999 = 18.015
        let hydrogen1 = Atom(element: .hydrogen)
        let hydrogen2 = Atom(element: .hydrogen)
        let oxygen = Atom(element: .oxygen)

        let molecule = Molecule(
            name: "Water",
            atoms: [hydrogen1, hydrogen2, oxygen],
            bonds: []
        )

        XCTAssertEqual(molecule.molecularWeight, 18.015, accuracy: 0.01)
    }

    func testFormulaGeneration() {
        // Test formula generation for ethanol (C2H6O)
        let carbon1 = Atom(element: .carbon)
        let carbon2 = Atom(element: .carbon)
        let oxygen = Atom(element: .oxygen)
        let h1 = Atom(element: .hydrogen)
        let h2 = Atom(element: .hydrogen)
        let h3 = Atom(element: .hydrogen)
        let h4 = Atom(element: .hydrogen)
        let h5 = Atom(element: .hydrogen)
        let h6 = Atom(element: .hydrogen)

        let molecule = Molecule(
            name: "Ethanol",
            atoms: [carbon1, carbon2, oxygen, h1, h2, h3, h4, h5, h6],
            bonds: []
        )

        XCTAssertEqual(molecule.formula, "C2H6O", "Formula should follow Hill system")
    }
}

// MARK: - Chemistry Engine Tests

final class ChemistryEngineTests: XCTestCase {
    var engine: ChemistryEngine!

    override func setUp() {
        engine = ChemistryEngine()
    }

    func testBondLengthCalculation() {
        let carbon = Atom(element: .carbon, position: .zero)
        let hydrogen = Atom(element: .hydrogen, position: SIMD3<Float>(1, 0, 0))

        let bondLength = engine.calculateBondLength(atom1: carbon, atom2: hydrogen, order: .single)

        // C-H bond should be around 1.07 Angstroms
        XCTAssertEqual(bondLength, 1.07, accuracy: 0.1)
    }

    func testLogPCalculation() throws {
        // Test LogP calculation for a simple molecule
        let carbon = Atom(element: .carbon)
        let oxygen = Atom(element: .oxygen)
        let molecule = Molecule(name: "Test", atoms: [carbon, oxygen], bonds: [])

        let logP = try engine.calculateLogP(molecule)

        // LogP should be a reasonable value (not infinity or NaN)
        XCTAssertTrue(logP.isFinite)
        XCTAssertTrue(logP >= -5 && logP <= 10)
    }

    func testHydrogenBondCounting() {
        // Create water molecule
        let oxygen = Atom(element: .oxygen, position: .zero)
        let h1 = Atom(element: .hydrogen, position: SIMD3<Float>(-1, 0, 0))
        let h2 = Atom(element: .hydrogen, position: SIMD3<Float>(1, 0, 0))

        let bond1 = Bond(atom1: oxygen.id, atom2: h1.id)
        let bond2 = Bond(atom1: oxygen.id, atom2: h2.id)

        let molecule = Molecule(
            name: "Water",
            atoms: [oxygen, h1, h2],
            bonds: [bond1, bond2]
        )

        let hbd = engine.countHydrogenBondDonors(molecule)
        let hba = engine.countHydrogenBondAcceptors(molecule)

        XCTAssertEqual(hbd, 2, "Water should have 2 H-bond donors")
        XCTAssertEqual(hba, 1, "Water should have 1 H-bond acceptor")
    }
}
