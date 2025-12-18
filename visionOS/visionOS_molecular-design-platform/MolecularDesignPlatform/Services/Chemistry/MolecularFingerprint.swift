//
//  MolecularFingerprint.swift
//  Molecular Design Platform
//
//  Molecular fingerprint generation (ECFP, MACCS keys)
//  Used for similarity searching and machine learning
//

import Foundation

// MARK: - Molecular Fingerprint

/// Molecular fingerprint generator for similarity calculations
class MolecularFingerprint {

    // MARK: - ECFP (Extended Connectivity Fingerprint)

    /// Generate ECFP fingerprint (Morgan/Circular fingerprint)
    /// - Parameters:
    ///   - molecule: The molecule to fingerprint
    ///   - radius: The radius/diameter (typically 2 or 3)
    ///   - nBits: Number of bits in fingerprint (typically 1024 or 2048)
    /// - Returns: Bit vector as array of UInt64
    func generateECFP(_ molecule: Molecule, radius: Int = 2, nBits: Int = 2048) -> [UInt64] {
        var fingerprint = [UInt64](repeating: 0, count: nBits / 64)

        // For each atom, generate circular substructure identifiers
        for atom in molecule.atoms {
            var identifiers = Set<Int>()

            // Layer 0: Just the atom itself
            identifiers.insert(hashAtom(atom))

            // Layers 1 to radius: Expand neighborhood
            for layer in 1...radius {
                let neighbors = getNeighborsAtDistance(atom.id, in: molecule, distance: layer)
                for neighbor in neighbors {
                    let envHash = hashEnvironment(atom, neighbors: neighbor, layer: layer)
                    identifiers.insert(envHash)
                }
            }

            // Set bits in fingerprint
            for id in identifiers {
                let bitIndex = abs(id) % nBits
                let wordIndex = bitIndex / 64
                let bitPosition = bitIndex % 64
                fingerprint[wordIndex] |= (1 << bitPosition)
            }
        }

        return fingerprint
    }

    /// Generate ECFP4 (radius 2) fingerprint - most common variant
    func generateECFP4(_ molecule: Molecule, nBits: Int = 2048) -> [UInt64] {
        generateECFP(molecule, radius: 2, nBits: nBits)
    }

    /// Generate ECFP6 (radius 3) fingerprint
    func generateECFP6(_ molecule: Molecule, nBits: Int = 2048) -> [UInt64] {
        generateECFP(molecule, radius: 3, nBits: nBits)
    }

    // MARK: - MACCS Keys

    /// Generate MACCS (Molecular ACCess System) structural keys
    /// Standard 166-bit fingerprint with predefined structural features
    /// - Parameter molecule: The molecule to fingerprint
    /// - Returns: 166-bit fingerprint as array of UInt64
    func generateMACCSKeys(_ molecule: Molecule) -> [UInt64] {
        var fingerprint = [UInt64](repeating: 0, count: 3) // 166 bits = 3 * 64

        // MACCS key definitions (abbreviated - full set is 166 keys)
        // Each key represents presence of a specific structural feature

        // Key 1: Isotope (not implemented in our simplified model)
        // Key 2: Number of rings > 1
        if countRings(molecule) > 1 {
            setBit(&fingerprint, bit: 2)
        }

        // Key 3: Number of oxygen atoms > 3
        if molecule.atoms.filter({ $0.element == .oxygen }).count > 3 {
            setBit(&fingerprint, bit: 3)
        }

        // Key 4: Number of nitrogen atoms > 1
        if molecule.atoms.filter({ $0.element == .nitrogen }).count > 1 {
            setBit(&fingerprint, bit: 4)
        }

        // Key 5-10: Halogen presence
        if molecule.atoms.contains(where: { $0.element == .fluorine }) {
            setBit(&fingerprint, bit: 5)
        }
        if molecule.atoms.contains(where: { $0.element == .chlorine }) {
            setBit(&fingerprint, bit: 6)
        }
        if molecule.atoms.contains(where: { $0.element == .bromine }) {
            setBit(&fingerprint, bit: 7)
        }
        if molecule.atoms.contains(where: { $0.element == .iodine }) {
            setBit(&fingerprint, bit: 8)
        }

        // Key 11: Carbon atoms > 2
        if molecule.atoms.filter({ $0.element == .carbon }).count > 2 {
            setBit(&fingerprint, bit: 11)
        }

        // Key 12-20: Functional group presence
        if hasCarboxylGroup(molecule) {
            setBit(&fingerprint, bit: 12)
        }
        if hasHydroxylGroup(molecule) {
            setBit(&fingerprint, bit: 13)
        }
        if hasAminoGroup(molecule) {
            setBit(&fingerprint, bit: 14)
        }
        if hasCarbonylGroup(molecule) {
            setBit(&fingerprint, bit: 15)
        }

        // Key 21-30: Bond types
        if molecule.bonds.contains(where: { $0.order == .double }) {
            setBit(&fingerprint, bit: 21)
        }
        if molecule.bonds.contains(where: { $0.order == .triple }) {
            setBit(&fingerprint, bit: 22)
        }
        if molecule.bonds.contains(where: { $0.order == .aromatic }) {
            setBit(&fingerprint, bit: 23)
        }

        // Key 31-50: Ring features
        if hasAromaticRing(molecule) {
            setBit(&fingerprint, bit: 31)
        }
        if has6MemberedRing(molecule) {
            setBit(&fingerprint, bit: 32)
        }
        if has5MemberedRing(molecule) {
            setBit(&fingerprint, bit: 33)
        }

        // Additional keys 51-166 would be implemented similarly
        // This is a simplified version showing the pattern

        return fingerprint
    }

    // MARK: - Similarity Calculations

    /// Calculate Tanimoto coefficient between two fingerprints
    /// - Parameters:
    ///   - fp1: First fingerprint
    ///   - fp2: Second fingerprint
    /// - Returns: Tanimoto similarity (0.0 to 1.0)
    func tanimotoSimilarity(fp1: [UInt64], fp2: [UInt64]) -> Double {
        guard fp1.count == fp2.count else { return 0.0 }

        var intersection: UInt64 = 0
        var union: UInt64 = 0

        for i in 0..<fp1.count {
            let commonBits = fp1[i] & fp2[i]
            let allBits = fp1[i] | fp2[i]

            intersection += UInt64(commonBits.nonzeroBitCount)
            union += UInt64(allBits.nonzeroBitCount)
        }

        return union > 0 ? Double(intersection) / Double(union) : 0.0
    }

    /// Calculate Dice coefficient between two fingerprints
    /// - Parameters:
    ///   - fp1: First fingerprint
    ///   - fp2: Second fingerprint
    /// - Returns: Dice similarity (0.0 to 1.0)
    func diceSimilarity(fp1: [UInt64], fp2: [UInt64]) -> Double {
        guard fp1.count == fp2.count else { return 0.0 }

        var intersection: UInt64 = 0
        var sum: UInt64 = 0

        for i in 0..<fp1.count {
            let commonBits = fp1[i] & fp2[i]
            intersection += UInt64(commonBits.nonzeroBitCount)

            sum += UInt64(fp1[i].nonzeroBitCount)
            sum += UInt64(fp2[i].nonzeroBitCount)
        }

        return sum > 0 ? (2.0 * Double(intersection)) / Double(sum) : 0.0
    }

    // MARK: - Helper Methods

    private func hashAtom(_ atom: Atom) -> Int {
        var hash = atom.element.atomicNumber
        hash = hash &* 31 &+ Int(atom.charge * 100)
        return hash
    }

    private func hashEnvironment(_ atom: Atom, neighbors: Set<UUID>, layer: Int) -> Int {
        var hash = hashAtom(atom)
        hash = hash &* 31 &+ layer
        hash = hash &* 31 &+ neighbors.count
        return hash
    }

    private func getNeighborsAtDistance(_ atomID: UUID, in molecule: Molecule, distance: Int) -> Set<UUID> {
        if distance == 0 {
            return [atomID]
        }

        var currentLevel = Set([atomID])
        var visited = Set([atomID])

        for _ in 1...distance {
            var nextLevel = Set<UUID>()

            for currentAtom in currentLevel {
                let bonds = molecule.bonds.filter { $0.atom1 == currentAtom || $0.atom2 == currentAtom }

                for bond in bonds {
                    let neighbor = bond.atom1 == currentAtom ? bond.atom2 : bond.atom1
                    if !visited.contains(neighbor) {
                        nextLevel.insert(neighbor)
                        visited.insert(neighbor)
                    }
                }
            }

            currentLevel = nextLevel
        }

        return currentLevel
    }

    private func setBit(_ fingerprint: inout [UInt64], bit: Int) {
        let wordIndex = bit / 64
        let bitPosition = bit % 64
        if wordIndex < fingerprint.count {
            fingerprint[wordIndex] |= (1 << bitPosition)
        }
    }

    // MARK: - Structural Feature Detection

    private func countRings(_ molecule: Molecule) -> Int {
        // Simplified ring counting using cycle detection
        // In production, use proper SSSR (Smallest Set of Smallest Rings) algorithm
        var visited = Set<UUID>()
        var ringCount = 0

        func dfs(atom: UUID, parent: UUID?, path: Set<UUID>) {
            visited.insert(atom)
            var currentPath = path
            currentPath.insert(atom)

            let bonds = molecule.bonds.filter { $0.atom1 == atom || $0.atom2 == atom }

            for bond in bonds {
                let neighbor = bond.atom1 == atom ? bond.atom2 : bond.atom1

                if neighbor == parent { continue }

                if currentPath.contains(neighbor) {
                    ringCount += 1
                } else if !visited.contains(neighbor) {
                    dfs(atom: neighbor, parent: atom, path: currentPath)
                }
            }
        }

        for atom in molecule.atoms {
            if !visited.contains(atom.id) {
                dfs(atom: atom.id, parent: nil, path: Set())
            }
        }

        return ringCount / 2 // Each ring is counted twice
    }

    private func hasCarboxylGroup(_ molecule: Molecule) -> Bool {
        // Look for -COOH pattern: C=O and C-OH
        for carbon in molecule.atoms.filter({ $0.element == .carbon }) {
            let carbonBonds = molecule.bonds.filter { $0.atom1 == carbon.id || $0.atom2 == carbon.id }

            var hasDoubleO = false
            var hasSingleOH = false

            for bond in carbonBonds {
                let otherAtomID = bond.atom1 == carbon.id ? bond.atom2 : bond.atom1
                guard let otherAtom = molecule.atoms.first(where: { $0.id == otherAtomID }) else { continue }

                if otherAtom.element == .oxygen && bond.order == .double {
                    hasDoubleO = true
                }
                if otherAtom.element == .oxygen && bond.order == .single {
                    hasSingleOH = true
                }
            }

            if hasDoubleO && hasSingleOH {
                return true
            }
        }

        return false
    }

    private func hasHydroxylGroup(_ molecule: Molecule) -> Bool {
        // Look for -OH pattern
        for bond in molecule.bonds {
            guard let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
                  let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
                continue
            }

            if (atom1.element == .oxygen && atom2.element == .hydrogen) ||
               (atom1.element == .hydrogen && atom2.element == .oxygen) {
                return true
            }
        }

        return false
    }

    private func hasAminoGroup(_ molecule: Molecule) -> Bool {
        // Look for -NH2 pattern
        for nitrogen in molecule.atoms.filter({ $0.element == .nitrogen }) {
            let nitrogenBonds = molecule.bonds.filter { $0.atom1 == nitrogen.id || $0.atom2 == nitrogen.id }
            let hydrogenCount = nitrogenBonds.filter { bond in
                let otherAtomID = bond.atom1 == nitrogen.id ? bond.atom2 : bond.atom1
                guard let otherAtom = molecule.atoms.first(where: { $0.id == otherAtomID }) else { return false }
                return otherAtom.element == .hydrogen
            }.count

            if hydrogenCount >= 2 {
                return true
            }
        }

        return false
    }

    private func hasCarbonylGroup(_ molecule: Molecule) -> Bool {
        // Look for C=O pattern
        for bond in molecule.bonds where bond.order == .double {
            guard let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
                  let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
                continue
            }

            if (atom1.element == .carbon && atom2.element == .oxygen) ||
               (atom1.element == .oxygen && atom2.element == .carbon) {
                return true
            }
        }

        return false
    }

    private func hasAromaticRing(_ molecule: Molecule) -> Bool {
        return molecule.bonds.contains(where: { $0.order == .aromatic })
    }

    private func has6MemberedRing(_ molecule: Molecule) -> Bool {
        // Simplified - would need proper ring detection
        return countRings(molecule) > 0 // Placeholder
    }

    private func has5MemberedRing(_ molecule: Molecule) -> Bool {
        // Simplified - would need proper ring detection
        return countRings(molecule) > 0 // Placeholder
    }
}

// MARK: - Fingerprint Extensions

extension Molecule {
    /// Get ECFP4 fingerprint for this molecule
    var ecfp4: [UInt64] {
        let generator = MolecularFingerprint()
        return generator.generateECFP4(self)
    }

    /// Get MACCS keys fingerprint for this molecule
    var maccsKeys: [UInt64] {
        let generator = MolecularFingerprint()
        return generator.generateMACCSKeys(self)
    }

    /// Calculate similarity to another molecule using ECFP4
    func similarity(to other: Molecule) -> Double {
        let generator = MolecularFingerprint()
        let fp1 = self.ecfp4
        let fp2 = other.ecfp4
        return generator.tanimotoSimilarity(fp1: fp1, fp2: fp2)
    }
}
