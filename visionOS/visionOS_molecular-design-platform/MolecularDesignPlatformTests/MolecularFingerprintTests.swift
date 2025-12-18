//
//  MolecularFingerprintTests.swift
//  Molecular Design Platform Tests
//
//  Unit tests for molecular fingerprints (ECFP, MACCS keys)
//

import XCTest
@testable import MolecularDesignPlatform

final class MolecularFingerprintTests: XCTestCase {
    var fingerprint: MolecularFingerprint!

    override func setUp() {
        fingerprint = MolecularFingerprint()
    }

    override func tearDown() {
        fingerprint = nil
    }

    // MARK: - ECFP Tests

    func testECFP4Generation() {
        // Create simple molecule (ethane: C-C)
        let carbon1 = Atom(element: .carbon, position: SIMD3<Float>(0, 0, 0))
        let carbon2 = Atom(element: .carbon, position: SIMD3<Float>(1.5, 0, 0))
        let bond = Bond(atom1: carbon1.id, atom2: carbon2.id)

        let molecule = Molecule(
            name: "Ethane",
            atoms: [carbon1, carbon2],
            bonds: [bond]
        )

        let fp = fingerprint.generateECFP4(molecule, nBits: 2048)

        // Fingerprint should be 2048 bits = 32 UInt64 words
        XCTAssertEqual(fp.count, 32)

        // At least some bits should be set
        let totalBits = fp.reduce(0) { $0 + $1.nonzeroBitCount }
        XCTAssertGreaterThan(totalBits, 0, "Fingerprint should have some bits set")
    }

    func testECFP6Generation() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule = Molecule(name: "Methane", atoms: [carbon], bonds: [])

        let fp = fingerprint.generateECFP6(molecule, nBits: 2048)

        XCTAssertEqual(fp.count, 32)
    }

    func testECFPDifferentMolecules() {
        // Create two different molecules
        let carbon = Atom(element: .carbon, position: .zero)
        let nitrogen = Atom(element: .nitrogen, position: .zero)

        let mol1 = Molecule(name: "Carbon", atoms: [carbon], bonds: [])
        let mol2 = Molecule(name: "Nitrogen", atoms: [nitrogen], bonds: [])

        let fp1 = fingerprint.generateECFP4(mol1)
        let fp2 = fingerprint.generateECFP4(mol2)

        // Fingerprints should be different
        XCTAssertNotEqual(fp1, fp2)
    }

    // MARK: - MACCS Keys Tests

    func testMACCSKeysGeneration() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule = Molecule(name: "Test", atoms: [carbon], bonds: [])

        let maccs = fingerprint.generateMACCSKeys(molecule)

        // MACCS keys: 166 bits = 3 UInt64 words
        XCTAssertEqual(maccs.count, 3)
    }

    func testMACCSKeysOxygenDetection() {
        // Create molecule with 4 oxygens
        let oxygens = (0..<4).map { _ in Atom(element: .oxygen, position: .zero) }
        let molecule = Molecule(name: "Test", atoms: oxygens, bonds: [])

        let maccs = fingerprint.generateMACCSKeys(molecule)

        // Bit 3 should be set (more than 3 oxygens)
        let word = maccs[3 / 64]
        let bit = 3 % 64
        XCTAssertTrue((word & (1 << bit)) != 0, "Bit 3 should be set")
    }

    func testMACCSKeysHalogenDetection() {
        // Test fluorine detection
        let fluorine = Atom(element: .fluorine, position: .zero)
        let molecule = Molecule(name: "Test", atoms: [fluorine], bonds: [])

        let maccs = fingerprint.generateMACCSKeys(molecule)

        // Should have some bits set for halogen
        let totalBits = maccs.reduce(0) { $0 + $1.nonzeroBitCount }
        XCTAssertGreaterThan(totalBits, 0)
    }

    // MARK: - Similarity Tests

    func testTanimotoSimilarityIdentical() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule = Molecule(name: "Test", atoms: [carbon], bonds: [])

        let fp1 = fingerprint.generateECFP4(molecule)
        let fp2 = fingerprint.generateECFP4(molecule)

        let similarity = fingerprint.tanimotoSimilarity(fp1: fp1, fp2: fp2)

        // Identical fingerprints should have similarity 1.0
        XCTAssertEqual(similarity, 1.0, accuracy: 0.001)
    }

    func testTanimotoSimilarityDifferent() {
        let carbon = Atom(element: .carbon, position: .zero)
        let nitrogen = Atom(element: .nitrogen, position: .zero)

        let mol1 = Molecule(name: "C", atoms: [carbon], bonds: [])
        let mol2 = Molecule(name: "N", atoms: [nitrogen], bonds: [])

        let fp1 = fingerprint.generateECFP4(mol1)
        let fp2 = fingerprint.generateECFP4(mol2)

        let similarity = fingerprint.tanimotoSimilarity(fp1: fp1, fp2: fp2)

        // Different molecules should have similarity < 1.0
        XCTAssertLessThan(similarity, 1.0)
        XCTAssertGreaterThanOrEqual(similarity, 0.0)
    }

    func testDiceSimilarity() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule = Molecule(name: "Test", atoms: [carbon], bonds: [])

        let fp1 = fingerprint.generateECFP4(molecule)
        let fp2 = fingerprint.generateECFP4(molecule)

        let similarity = fingerprint.diceSimilarity(fp1: fp1, fp2: fp2)

        // Identical fingerprints should have Dice similarity 1.0
        XCTAssertEqual(similarity, 1.0, accuracy: 0.001)
    }

    func testTanimotoRange() {
        let carbon = Atom(element: .carbon, position: .zero)
        let oxygen = Atom(element: .oxygen, position: .zero)

        let mol1 = Molecule(name: "C", atoms: [carbon], bonds: [])
        let mol2 = Molecule(name: "O", atoms: [oxygen], bonds: [])

        let fp1 = fingerprint.generateECFP4(mol1)
        let fp2 = fingerprint.generateECFP4(mol2)

        let similarity = fingerprint.tanimotoSimilarity(fp1: fp1, fp2: fp2)

        // Similarity should always be in range [0, 1]
        XCTAssertGreaterThanOrEqual(similarity, 0.0)
        XCTAssertLessThanOrEqual(similarity, 1.0)
    }

    // MARK: - Molecule Extension Tests

    func testMoleculeECFP4Property() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule = Molecule(name: "Test", atoms: [carbon], bonds: [])

        let fp = molecule.ecfp4

        XCTAssertEqual(fp.count, 32)  // 2048 bits / 64
    }

    func testMoleculeMACCSKeysProperty() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule = Molecule(name: "Test", atoms: [carbon], bonds: [])

        let maccs = molecule.maccsKeys

        XCTAssertEqual(maccs.count, 3)  // 166 bits / 64
    }

    func testMoleculeSimilarityMethod() {
        let carbon = Atom(element: .carbon, position: .zero)
        let molecule1 = Molecule(name: "Test1", atoms: [carbon], bonds: [])
        let molecule2 = Molecule(name: "Test2", atoms: [carbon], bonds: [])

        let similarity = molecule1.similarity(to: molecule2)

        // Very similar molecules (both single carbon)
        XCTAssertGreaterThan(similarity, 0.5)
    }

    // MARK: - Functional Group Detection Tests

    func testCarboxylGroupDetection() {
        // Create simple carboxyl group (simplified)
        let carbon = Atom(element: .carbon, position: .zero)
        let oxygen1 = Atom(element: .oxygen, position: SIMD3<Float>(1, 0, 0))
        let oxygen2 = Atom(element: .oxygen, position: SIMD3<Float>(-1, 0, 0))

        let bond1 = Bond(atom1: carbon.id, atom2: oxygen1.id, order: .double)
        let bond2 = Bond(atom1: carbon.id, atom2: oxygen2.id, order: .single)

        let molecule = Molecule(
            name: "Carboxyl",
            atoms: [carbon, oxygen1, oxygen2],
            bonds: [bond1, bond2]
        )

        let maccs = fingerprint.generateMACCSKeys(molecule)

        // Should detect carboxyl group
        let totalBits = maccs.reduce(0) { $0 + $1.nonzeroBitCount }
        XCTAssertGreaterThan(totalBits, 0)
    }

    func testCarbonylGroupDetection() {
        let carbon = Atom(element: .carbon, position: .zero)
        let oxygen = Atom(element: .oxygen, position: SIMD3<Float>(1, 0, 0))
        let bond = Bond(atom1: carbon.id, atom2: oxygen.id, order: .double)

        let molecule = Molecule(
            name: "Carbonyl",
            atoms: [carbon, oxygen],
            bonds: [bond]
        )

        let maccs = fingerprint.generateMACCSKeys(molecule)

        // Should detect carbonyl
        let totalBits = maccs.reduce(0) { $0 + $1.nonzeroBitCount }
        XCTAssertGreaterThan(totalBits, 0)
    }
}
