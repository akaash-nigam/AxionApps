//
//  ChemistryEngine.swift
//  Molecular Design Platform
//
//  Core chemistry calculations and validations
//

import Foundation
import RealityKit

// MARK: - Chemistry Engine

class ChemistryEngine {
    // MARK: - Bond Length Calculations

    /// Calculate expected bond length between two atoms
    func calculateBondLength(atom1: Atom, atom2: Atom, order: BondOrder) -> Float {
        // Get covalent radii
        let r1 = atom1.element.covalentRadius
        let r2 = atom2.element.covalentRadius

        // Base bond length is sum of covalent radii
        var bondLength = r1 + r2

        // Adjust for bond order
        switch order {
        case .single:
            break // No adjustment
        case .double:
            bondLength *= 0.87 // Double bonds are ~13% shorter
        case .triple:
            bondLength *= 0.78 // Triple bonds are ~22% shorter
        case .aromatic:
            bondLength *= 0.93 // Aromatic bonds are intermediate
        }

        return bondLength
    }

    /// Calculate bond angle between three atoms
    func calculateBondAngle(atom1: Atom, atom2: Atom, atom3: Atom) -> Float {
        let v1 = atom1.position - atom2.position
        let v2 = atom3.position - atom2.position

        let dotProduct = simd_dot(v1, v2)
        let magnitudes = simd_length(v1) * simd_length(v2)

        let cosAngle = dotProduct / magnitudes
        return acos(cosAngle) * (180.0 / .pi) // Convert to degrees
    }

    // MARK: - Property Calculations

    /// Calculate LogP (octanol-water partition coefficient)
    func calculateLogP(_ molecule: Molecule) throws -> Double {
        // Simplified LogP calculation using Wildman-Crippen method
        var logP: Double = 0.0

        for atom in molecule.atoms {
            logP += atom.element.logPContribution
        }

        // Adjust for hydrogen bonding
        let hbdCount = Double(countHydrogenBondDonors(molecule))
        let hbaCount = Double(countHydrogenBondAcceptors(molecule))

        logP -= (hbdCount * 0.3) // Donors decrease lipophilicity
        logP -= (hbaCount * 0.2) // Acceptors decrease lipophilicity

        return logP
    }

    /// Calculate TPSA (topological polar surface area)
    func calculateTPSA(_ molecule: Molecule) throws -> Double {
        var tpsa: Double = 0.0

        for atom in molecule.atoms {
            // Add polar surface area for O and N atoms
            switch atom.element {
            case .oxygen:
                tpsa += 20.23 // Oxygen PSA
            case .nitrogen:
                tpsa += 23.79 // Nitrogen PSA (assuming NH)
            default:
                break
            }
        }

        return tpsa
    }

    /// Count hydrogen bond donors (OH, NH)
    func countHydrogenBondDonors(_ molecule: Molecule) -> Int {
        var count = 0

        for bond in molecule.bonds {
            guard let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
                  let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
                continue
            }

            // Check if bond is between H and O/N
            if (atom1.element == .hydrogen && (atom2.element == .oxygen || atom2.element == .nitrogen)) ||
               (atom2.element == .hydrogen && (atom1.element == .oxygen || atom1.element == .nitrogen)) {
                count += 1
            }
        }

        return count
    }

    /// Count hydrogen bond acceptors (O, N)
    func countHydrogenBondAcceptors(_ molecule: Molecule) -> Int {
        molecule.atoms.filter { atom in
            atom.element == .oxygen || atom.element == .nitrogen
        }.count
    }

    // MARK: - Similarity Calculations

    /// Calculate Tanimoto similarity between two molecules
    func calculateSimilarity(_ molecule1: Molecule, _ molecule2: Molecule) -> Double {
        // Simplified fingerprint-based similarity
        let fp1 = generateFingerprint(molecule1)
        let fp2 = generateFingerprint(molecule2)

        let intersection = fp1.intersection(fp2).count
        let union = fp1.union(fp2).count

        return union > 0 ? Double(intersection) / Double(union) : 0.0
    }

    private func generateFingerprint(_ molecule: Molecule) -> Set<String> {
        var fingerprint = Set<String>()

        // Add atom types
        for atom in molecule.atoms {
            fingerprint.insert("ATOM_\(atom.element.symbol)")
        }

        // Add bond types
        for bond in molecule.bonds {
            guard let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
                  let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
                continue
            }

            let bondDesc = "\(atom1.element.symbol)-\(bond.order.rawValue)-\(atom2.element.symbol)"
            fingerprint.insert(bondDesc)
        }

        return fingerprint
    }

    // MARK: - Conformation Generation

    /// Generate a 3D conformation for a molecule
    func generateConformation(_ molecule: Molecule) async throws -> Conformation {
        // Simplified conformer generation
        // In production, use proper force field minimization

        var atomPositions: [UUID: SIMD3<Float>] = [:]

        // Generate random initial positions
        for atom in molecule.atoms {
            let randomOffset = SIMD3<Float>(
                Float.random(in: -0.5...0.5),
                Float.random(in: -0.5...0.5),
                Float.random(in: -0.5...0.5)
            )
            atomPositions[atom.id] = atom.position + randomOffset
        }

        // Simple energy minimization (steepest descent)
        for _ in 0..<100 {
            var forces: [UUID: SIMD3<Float>] = [:]

            // Calculate forces from bonds
            for bond in molecule.bonds {
                guard let pos1 = atomPositions[bond.atom1],
                      let pos2 = atomPositions[bond.atom2],
                      let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
                      let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
                    continue
                }

                let idealLength = calculateBondLength(atom1: atom1, atom2: atom2, order: bond.order)
                let currentVector = pos2 - pos1
                let currentLength = simd_length(currentVector)

                let force = (currentLength - idealLength) * simd_normalize(currentVector)

                forces[bond.atom1, default: .zero] += force
                forces[bond.atom2, default: .zero] -= force
            }

            // Update positions
            for (atomID, force) in forces {
                atomPositions[atomID]? -= force * 0.01 // Small step size
            }
        }

        return Conformation(atomPositions: atomPositions, isOptimized: true)
    }

    // MARK: - Structure Validation

    /// Validate molecular structure
    func validateStructure(_ molecule: Molecule) throws {
        // Check for valid valence
        for atom in molecule.atoms {
            let bondCount = molecule.bonds.filter { bond in
                bond.atom1 == atom.id || bond.atom2 == atom.id
            }.reduce(0) { count, bond in
                count + bond.order.rawValue
            }

            if bondCount > atom.element.typicalValence * 2 {
                throw ChemistryError.invalidValence(atom: atom.element.symbol)
            }
        }

        // Check for disconnected atoms
        if molecule.atoms.count > 1 && molecule.bonds.isEmpty {
            throw ChemistryError.disconnectedStructure
        }
    }
}

// MARK: - Element LogP Contributions

extension Element {
    var logPContribution: Double {
        switch self {
        case .hydrogen: return 0.0
        case .carbon: return 0.3
        case .nitrogen: return -0.5
        case .oxygen: return -0.4
        case .fluorine: return 0.2
        case .chlorine: return 0.6
        case .bromine: return 0.8
        case .iodine: return 1.0
        case .sulfur: return 0.3
        case .phosphorus: return 0.1
        default: return 0.0
        }
    }
}

// MARK: - Chemistry Errors

enum ChemistryError: LocalizedError {
    case invalidValence(atom: String)
    case disconnectedStructure
    case invalidGeometry

    var errorDescription: String? {
        switch self {
        case .invalidValence(let atom):
            return "Invalid valence for atom: \(atom)"
        case .disconnectedStructure:
            return "Molecule has disconnected fragments"
        case .invalidGeometry:
            return "Invalid molecular geometry"
        }
    }
}
