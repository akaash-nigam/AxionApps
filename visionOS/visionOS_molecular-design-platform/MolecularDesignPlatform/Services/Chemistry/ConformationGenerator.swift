//
//  ConformationGenerator.swift
//  Molecular Design Platform
//
//  Generate 3D conformations of molecules
//

import Foundation
import RealityKit

// MARK: - Conformation Generator

class ConformationGenerator {
    /// Generate multiple conformations using random sampling
    func generateConformations(for molecule: Molecule, count: Int) async throws -> [Conformation] {
        var conformations: [Conformation] = []

        for i in 0..<count {
            let conformation = try await generateRandomConformation(molecule, seed: i)
            conformations.append(conformation)
        }

        // Sort by energy (lowest first)
        return conformations.sorted { ($0.energy ?? .infinity) < ($1.energy ?? .infinity) }
    }

    /// Generate a single random conformation
    private func generateRandomConformation(_ molecule: Molecule, seed: Int) async throws -> Conformation {
        // Set random seed for reproducibility
        srand48(seed)

        var atomPositions: [UUID: SIMD3<Float>] = [:]

        // Place first atom at origin
        if let firstAtom = molecule.atoms.first {
            atomPositions[firstAtom.id] = .zero
        }

        // Build molecule atom by atom
        for atom in molecule.atoms.dropFirst() {
            // Find bonded atoms that are already placed
            let bonds = molecule.bonds.filter { $0.atom1 == atom.id || $0.atom2 == atom.id }

            if let bond = bonds.first {
                let connectedAtomID = bond.atom1 == atom.id ? bond.atom2 : bond.atom1

                guard let connectedPos = atomPositions[connectedAtomID],
                      let connectedAtom = molecule.atoms.first(where: { $0.id == connectedAtomID }) else {
                    continue
                }

                // Calculate bond length
                let bondLength = calculateBondLength(atom1: atom, atom2: connectedAtom, order: bond.order)

                // Random angle
                let theta = Float(drand48() * 2.0 * .pi)
                let phi = Float(drand48() * .pi)

                // Position in spherical coordinates
                let offset = SIMD3<Float>(
                    bondLength * sin(phi) * cos(theta),
                    bondLength * sin(phi) * sin(theta),
                    bondLength * cos(phi)
                )

                atomPositions[atom.id] = connectedPos + offset
            } else {
                // No bonds yet, place randomly nearby
                atomPositions[atom.id] = SIMD3<Float>(
                    Float(drand48() - 0.5) * 2.0,
                    Float(drand48() - 0.5) * 2.0,
                    Float(drand48() - 0.5) * 2.0
                )
            }
        }

        // Calculate energy
        let energy = calculateEnergy(molecule: molecule, positions: atomPositions)

        return Conformation(
            atomPositions: atomPositions,
            energy: energy,
            isOptimized: false
        )
    }

    /// Calculate simple molecular energy
    private func calculateEnergy(molecule: Molecule, positions: [UUID: SIMD3<Float>]) -> Double {
        var energy: Double = 0.0

        // Bond stretch energy
        for bond in molecule.bonds {
            guard let pos1 = positions[bond.atom1],
                  let pos2 = positions[bond.atom2],
                  let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
                  let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
                continue
            }

            let idealLength = calculateBondLength(atom1: atom1, atom2: atom2, order: bond.order)
            let currentLength = simd_distance(pos1, pos2)
            let deviation = Double(currentLength - idealLength)

            // Harmonic potential: E = k * (r - r0)^2
            let k = 500.0 // Force constant
            energy += k * deviation * deviation
        }

        // Van der Waals energy (simplified)
        for i in 0..<molecule.atoms.count {
            for j in (i+1)..<molecule.atoms.count {
                let atom1 = molecule.atoms[i]
                let atom2 = molecule.atoms[j]

                guard let pos1 = positions[atom1.id],
                      let pos2 = positions[atom2.id] else {
                    continue
                }

                // Skip bonded atoms
                let isBonded = molecule.bonds.contains { bond in
                    (bond.atom1 == atom1.id && bond.atom2 == atom2.id) ||
                    (bond.atom1 == atom2.id && bond.atom2 == atom1.id)
                }
                if isBonded { continue }

                let distance = Double(simd_distance(pos1, pos2))
                let vdwRadius = Double(atom1.element.vdwRadius + atom2.element.vdwRadius)

                // Lennard-Jones potential: E = epsilon * [(sigma/r)^12 - 2*(sigma/r)^6]
                let epsilon = 0.1
                let sigma = vdwRadius * 0.891 // Convert to LJ sigma
                let ratio = sigma / distance

                energy += epsilon * (pow(ratio, 12) - 2.0 * pow(ratio, 6))
            }
        }

        return energy
    }

    private func calculateBondLength(atom1: Atom, atom2: Atom, order: BondOrder) -> Float {
        let r1 = atom1.element.covalentRadius
        let r2 = atom2.element.covalentRadius

        var bondLength = r1 + r2

        switch order {
        case .single: break
        case .double: bondLength *= 0.87
        case .triple: bondLength *= 0.78
        case .aromatic: bondLength *= 0.93
        }

        return bondLength
    }
}
