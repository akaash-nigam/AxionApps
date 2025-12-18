//
//  PropertyCalculator.swift
//  Molecular Design Platform
//
//  Advanced molecular property calculations
//

import Foundation

// MARK: - Property Calculator

class PropertyCalculator {
    private let engine: ChemistryEngine

    init(engine: ChemistryEngine) {
        self.engine = engine
    }

    /// Calculate all basic properties for a molecule
    func calculateAllProperties(_ molecule: Molecule) async throws -> MolecularProperties {
        var properties = MolecularProperties()

        // Calculated properties
        properties.logP = try engine.calculateLogP(molecule)
        properties.tpsa = try engine.calculateTPSA(molecule)
        properties.hbd = engine.countHydrogenBondDonors(molecule)
        properties.hba = engine.countHydrogenBondAcceptors(molecule)

        return properties
    }

    /// Calculate Lipinski's Rule of Five compliance
    func checkLipinskiRuleOfFive(_ molecule: Molecule) -> LipinskiResult {
        guard let properties = molecule.properties else {
            return LipinskiResult(passes: false, violations: [])
        }

        var violations: [String] = []

        // Rule 1: Molecular weight <= 500 Da
        if molecule.molecularWeight > 500 {
            violations.append("Molecular weight > 500 Da (\(String(format: "%.1f", molecule.molecularWeight)))")
        }

        // Rule 2: LogP <= 5
        if let logP = properties.logP, logP > 5 {
            violations.append("LogP > 5 (\(String(format: "%.2f", logP)))")
        }

        // Rule 3: Hydrogen bond donors <= 5
        if let hbd = properties.hbd, hbd > 5 {
            violations.append("H-bond donors > 5 (\(hbd))")
        }

        // Rule 4: Hydrogen bond acceptors <= 10
        if let hba = properties.hba, hba > 10 {
            violations.append("H-bond acceptors > 10 (\(hba))")
        }

        return LipinskiResult(passes: violations.isEmpty, violations: violations)
    }

    /// Calculate drug-likeness score
    func calculateDrugLikenessScore(_ molecule: Molecule) -> Double {
        guard let properties = molecule.properties else { return 0.0 }

        var score: Double = 0.0

        // Molecular weight contribution (optimal: 200-500)
        let mw = molecule.molecularWeight
        if mw >= 200 && mw <= 500 {
            score += 25.0
        } else {
            score += max(0, 25.0 - abs(mw - 350.0) / 10.0)
        }

        // LogP contribution (optimal: 0-3)
        if let logP = properties.logP {
            if logP >= 0 && logP <= 3 {
                score += 25.0
            } else {
                score += max(0, 25.0 - abs(logP - 1.5) * 5.0)
            }
        }

        // TPSA contribution (optimal: 20-140)
        if let tpsa = properties.tpsa {
            if tpsa >= 20 && tpsa <= 140 {
                score += 25.0
            } else {
                score += max(0, 25.0 - abs(tpsa - 80.0) / 5.0)
            }
        }

        // H-bond donor/acceptor contribution
        if let hbd = properties.hbd, let hba = properties.hba {
            if hbd <= 5 && hba <= 10 {
                score += 25.0
            }
        }

        return min(100.0, max(0.0, score))
    }
}

// MARK: - Lipinski Result

struct LipinskiResult {
    let passes: Bool
    let violations: [String]

    var isD rugLike: Bool { passes }

    var summary: String {
        if passes {
            return "Passes Lipinski's Rule of Five"
        } else {
            return "Violations: \(violations.joined(separator: ", "))"
        }
    }
}
