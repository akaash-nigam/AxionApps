//
//  FileService.swift
//  Molecular Design Platform
//
//  Import and export molecular file formats (MDL, SDF, PDB, XYZ)
//

import Foundation

// MARK: - File Service

class FileService {
    private let molecularService: MolecularService

    init(molecularService: MolecularService) {
        self.molecularService = molecularService
    }

    /// Import molecule from file
    func importMolecule(from url: URL) async throws -> Molecule {
        let fileExtension = url.pathExtension.lowercased()

        switch fileExtension {
        case "mol":
            return try await importMDLMolfile(url)
        case "sdf":
            return try await importSDFile(url)
        case "pdb":
            return try await importPDBFile(url)
        case "xyz":
            return try await importXYZFile(url)
        default:
            throw FileServiceError.unsupportedFormat(fileExtension)
        }
    }

    /// Import multiple molecules from SDF file
    func importMolecules(from url: URL) async throws -> [Molecule] {
        let fileExtension = url.pathExtension.lowercased()

        switch fileExtension {
        case "sdf":
            return try await importMultipleFromSDF(url)
        default:
            let molecule = try await importMolecule(from: url)
            return [molecule]
        }
    }

    /// Export molecule to file
    func exportMolecule(_ molecule: Molecule, to url: URL, format: FileFormat) async throws {
        let data: Data

        switch format {
        case .mdl:
            data = try generateMDLMolfile(molecule)
        case .sdf:
            data = try generateSDFile(molecule)
        case .pdb:
            data = try generatePDBFile(molecule)
        case .xyz:
            data = try generateXYZFile(molecule)
        }

        try data.write(to: url)
    }

    // MARK: - MDL Molfile Parser (V2000 and V3000)

    private func importMDLMolfile(_ url: URL) async throws -> Molecule {
        let content = try String(contentsOf: url, encoding: .utf8)
        return try parseMDLMolfile(content, name: url.deletingPathExtension().lastPathComponent)
    }

    /// Parse MDL Molfile V2000 format
    private func parseMDLMolfile(_ content: String, name: String) throws -> Molecule {
        let lines = content.components(separatedBy: .newlines)

        guard lines.count >= 4 else {
            throw FileServiceError.invalidFile
        }

        // Line 1: Molecule name
        let moleculeName = lines[0].trimmingCharacters(in: .whitespaces)

        // Line 2: User/program/date info (skip)
        // Line 3: Comment line (skip)

        // Line 4: Counts line
        let countsLine = lines[3]
        guard countsLine.count >= 6 else {
            throw FileServiceError.invalidFile
        }

        let atomCountStr = String(countsLine.prefix(3)).trimmingCharacters(in: .whitespaces)
        let bondCountStr = String(countsLine.dropFirst(3).prefix(3)).trimmingCharacters(in: .whitespaces)

        guard let atomCount = Int(atomCountStr),
              let bondCount = Int(bondCountStr) else {
            throw FileServiceError.invalidFile
        }

        // Parse atoms
        var atoms: [Atom] = []
        var atomIDMap: [Int: UUID] = [:] // Map file index to UUID

        for i in 0..<atomCount {
            let lineIndex = 4 + i
            guard lineIndex < lines.count else { throw FileServiceError.invalidFile }

            let atomLine = lines[lineIndex]
            guard atomLine.count >= 31 else { continue }

            // Parse coordinates
            let xStr = String(atomLine.prefix(10)).trimmingCharacters(in: .whitespaces)
            let yStr = String(atomLine.dropFirst(10).prefix(10)).trimmingCharacters(in: .whitespaces)
            let zStr = String(atomLine.dropFirst(20).prefix(10)).trimmingCharacters(in: .whitespaces)

            guard let x = Float(xStr),
                  let y = Float(yStr),
                  let z = Float(zStr) else {
                continue
            }

            // Parse element symbol
            let symbolStr = String(atomLine.dropFirst(31).prefix(3)).trimmingCharacters(in: .whitespaces)

            guard let element = Element.from(symbol: symbolStr) else {
                throw FileServiceError.invalidFile
            }

            let atom = Atom(
                element: element,
                position: SIMD3<Float>(x, y, z)
            )

            atoms.append(atom)
            atomIDMap[i + 1] = atom.id
        }

        // Parse bonds
        var bonds: [Bond] = []
        let bondStartLine = 4 + atomCount

        for i in 0..<bondCount {
            let lineIndex = bondStartLine + i
            guard lineIndex < lines.count else { break }

            let bondLine = lines[lineIndex]
            guard bondLine.count >= 9 else { continue }

            let atom1Str = String(bondLine.prefix(3)).trimmingCharacters(in: .whitespaces)
            let atom2Str = String(bondLine.dropFirst(3).prefix(3)).trimmingCharacters(in: .whitespaces)
            let orderStr = String(bondLine.dropFirst(6).prefix(3)).trimmingCharacters(in: .whitespaces)

            guard let atom1Idx = Int(atom1Str),
                  let atom2Idx = Int(atom2Str),
                  let orderInt = Int(orderStr),
                  let atom1ID = atomIDMap[atom1Idx],
                  let atom2ID = atomIDMap[atom2Idx],
                  let bondOrder = BondOrder(rawValue: orderInt) else {
                continue
            }

            let bond = Bond(atom1: atom1ID, atom2: atom2ID, order: bondOrder)
            bonds.append(bond)
        }

        let molecule = Molecule(
            name: moleculeName.isEmpty ? name : moleculeName,
            atoms: atoms,
            bonds: bonds
        )

        return molecule
    }

    // MARK: - SDF Parser

    private func importSDFile(_ url: URL) async throws -> Molecule {
        let content = try String(contentsOf: url, encoding: .utf8)
        let molecules = try parseSDFile(content)

        guard let firstMolecule = molecules.first else {
            throw FileServiceError.invalidFile
        }

        return firstMolecule
    }

    private func importMultipleFromSDF(_ url: URL) async throws -> [Molecule] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return try parseSDFile(content)
    }

    /// Parse SDF (Structure Data File) - multiple molecules
    private func parseSDFile(_ content: String) throws -> [Molecule] {
        var molecules: [Molecule] = []

        // Split by $$$$ delimiter
        let molBlocks = content.components(separatedBy: "$$$$")

        for (index, block) in molBlocks.enumerated() {
            let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Each block contains a molfile plus optional data
            let molecule = try parseMDLMolfile(trimmed, name: "Molecule_\(index + 1)")

            // Parse SDF data fields (lines starting with > <FIELDNAME>)
            let lines = trimmed.components(separatedBy: .newlines)
            var currentField: String?
            var properties: [String: String] = [:]

            for line in lines {
                if line.hasPrefix("> <") {
                    // Extract field name
                    if let endIndex = line.firstIndex(of: ">", offsetBy: 2) {
                        currentField = String(line[line.index(line.startIndex, offsetBy: 3)..<endIndex])
                    }
                } else if let field = currentField, !line.isEmpty {
                    properties[field] = line
                    currentField = nil
                }
            }

            // Store properties as tags or metadata
            molecule.tags = Array(properties.keys)

            molecules.append(molecule)
        }

        return molecules
    }

    // MARK: - PDB Parser

    private func importPDBFile(_ url: URL) async throws -> Molecule {
        let content = try String(contentsOf: url, encoding: .utf8)
        return try parsePDBFile(content, name: url.deletingPathExtension().lastPathComponent)
    }

    /// Parse PDB (Protein Data Bank) format
    private func parsePDBFile(_ content: String, name: String) throws -> Molecule {
        let lines = content.components(separatedBy: .newlines)

        var atoms: [Atom] = []
        var atomIDMap: [Int: UUID] = [:]
        var moleculeName = name

        for line in lines {
            let recordType = String(line.prefix(6)).trimmingCharacters(in: .whitespaces)

            switch recordType {
            case "HEADER":
                moleculeName = String(line.dropFirst(10)).trimmingCharacters(in: .whitespaces)

            case "ATOM", "HETATM":
                guard line.count >= 54 else { continue }

                // Parse serial number
                let serialStr = String(line.dropFirst(6).prefix(5)).trimmingCharacters(in: .whitespaces)
                guard let serial = Int(serialStr) else { continue }

                // Parse atom name and element
                let atomName = String(line.dropFirst(12).prefix(4)).trimmingCharacters(in: .whitespaces)
                let elementStr = String(line.dropFirst(76).prefix(2)).trimmingCharacters(in: .whitespaces)

                // Try to determine element from atom name if element field is empty
                var element: Element?
                if !elementStr.isEmpty {
                    element = Element.from(symbol: elementStr)
                } else {
                    // Extract element from atom name (usually first 1-2 chars)
                    let firstChar = String(atomName.prefix(1))
                    element = Element.from(symbol: firstChar)
                }

                guard let atomElement = element else { continue }

                // Parse coordinates
                let xStr = String(line.dropFirst(30).prefix(8)).trimmingCharacters(in: .whitespaces)
                let yStr = String(line.dropFirst(38).prefix(8)).trimmingCharacters(in: .whitespaces)
                let zStr = String(line.dropFirst(46).prefix(8)).trimmingCharacters(in: .whitespaces)

                guard let x = Float(xStr),
                      let y = Float(yStr),
                      let z = Float(zStr) else {
                    continue
                }

                let atom = Atom(
                    element: atomElement,
                    position: SIMD3<Float>(x, y, z)
                )

                atoms.append(atom)
                atomIDMap[serial] = atom.id

            case "END", "ENDMDL":
                break

            default:
                continue
            }
        }

        // PDB files don't include bond information
        // We'll need to infer bonds based on distance
        let bonds = inferBonds(atoms: atoms)

        let molecule = Molecule(
            name: moleculeName,
            atoms: atoms,
            bonds: bonds
        )

        return molecule
    }

    // MARK: - XYZ Parser

    private func importXYZFile(_ url: URL) async throws -> Molecule {
        let content = try String(contentsOf: url, encoding: .utf8)
        return try parseXYZFile(content, name: url.deletingPathExtension().lastPathComponent)
    }

    /// Parse XYZ coordinate file
    private func parseXYZFile(_ content: String, name: String) throws -> Molecule {
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard lines.count >= 2 else {
            throw FileServiceError.invalidFile
        }

        // Line 1: Number of atoms
        guard let atomCount = Int(lines[0]) else {
            throw FileServiceError.invalidFile
        }

        // Line 2: Comment (optional molecule name)
        let comment = lines[1]

        var atoms: [Atom] = []

        for i in 2..<min(2 + atomCount, lines.count) {
            let components = lines[i].components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }

            guard components.count >= 4 else { continue }

            let elementSymbol = components[0]
            guard let element = Element.from(symbol: elementSymbol),
                  let x = Float(components[1]),
                  let y = Float(components[2]),
                  let z = Float(components[3]) else {
                continue
            }

            let atom = Atom(
                element: element,
                position: SIMD3<Float>(x, y, z)
            )

            atoms.append(atom)
        }

        // Infer bonds from distances
        let bonds = inferBonds(atoms: atoms)

        let molecule = Molecule(
            name: comment.isEmpty ? name : comment,
            atoms: atoms,
            bonds: bonds
        )

        return molecule
    }

    // MARK: - Bond Inference

    /// Infer bonds based on atomic distances
    private func inferBonds(atoms: [Atom]) -> [Bond] {
        var bonds: [Bond] = []

        for i in 0..<atoms.count {
            for j in (i + 1)..<atoms.count {
                let atom1 = atoms[i]
                let atom2 = atoms[j]

                let distance = simd_distance(atom1.position, atom2.position)
                let expectedBondLength = atom1.element.covalentRadius + atom2.element.covalentRadius

                // Consider it a bond if within 1.3x the sum of covalent radii
                if distance < expectedBondLength * 1.3 {
                    let bond = Bond(atom1: atom1.id, atom2: atom2.id, order: .single)
                    bonds.append(bond)
                }
            }
        }

        return bonds
    }

    // MARK: - File Generation (Export)

    private func generateMDLMolfile(_ molecule: Molecule) throws -> Data {
        var molfile = ""

        // Header (3 lines)
        molfile += "\(molecule.name)\n"
        molfile += "  Generated by Molecular Design Platform\n"
        molfile += "\n"

        // Counts line
        let atomCount = String(format: "%3d", molecule.atoms.count)
        let bondCount = String(format: "%3d", molecule.bonds.count)
        molfile += "\(atomCount)\(bondCount)  0  0  0  0  0  0  0  0999 V2000\n"

        // Atom block
        for atom in molecule.atoms {
            let x = String(format: "%10.4f", atom.position.x)
            let y = String(format: "%10.4f", atom.position.y)
            let z = String(format: "%10.4f", atom.position.z)
            let symbol = String(format: " %-3s", atom.element.symbol)
            molfile += "\(x)\(y)\(z)\(symbol) 0  0  0  0  0  0  0  0  0  0  0  0\n"
        }

        // Bond block
        for bond in molecule.bonds {
            if let atom1Index = molecule.atoms.firstIndex(where: { $0.id == bond.atom1 }),
               let atom2Index = molecule.atoms.firstIndex(where: { $0.id == bond.atom2 }) {
                let idx1 = String(format: "%3d", atom1Index + 1)
                let idx2 = String(format: "%3d", atom2Index + 1)
                let order = String(format: "%3d", bond.order.rawValue)
                molfile += "\(idx1)\(idx2)\(order)  0  0  0  0\n"
            }
        }

        molfile += "M  END\n"

        guard let data = molfile.data(using: .utf8) else {
            throw FileServiceError.exportFailed
        }

        return data
    }

    private func generateSDFile(_ molecule: Molecule) throws -> Data {
        var sdf = try String(data: generateMDLMolfile(molecule), encoding: .utf8) ?? ""

        // Add SDF data fields
        if let properties = molecule.properties {
            if let logP = properties.logP {
                sdf += "> <LogP>\n\(String(format: "%.2f", logP))\n\n"
            }
            if let tpsa = properties.tpsa {
                sdf += "> <TPSA>\n\(String(format: "%.2f", tpsa))\n\n"
            }
            if let hbd = properties.hbd {
                sdf += "> <HBD>\n\(hbd)\n\n"
            }
            if let hba = properties.hba {
                sdf += "> <HBA>\n\(hba)\n\n"
            }
        }

        sdf += "$$$$\n"

        guard let data = sdf.data(using: .utf8) else {
            throw FileServiceError.exportFailed
        }

        return data
    }

    private func generatePDBFile(_ molecule: Molecule) throws -> Data {
        var pdb = ""

        pdb += "HEADER    \(molecule.name)\n"
        pdb += "COMPND    \(molecule.formula)\n"

        for (index, atom) in molecule.atoms.enumerated() {
            let serial = String(format: "%5d", index + 1)
            let atomName = String(format: " %-3s", atom.element.symbol)
            let x = String(format: "%8.3f", atom.position.x)
            let y = String(format: "%8.3f", atom.position.y)
            let z = String(format: "%8.3f", atom.position.z)
            let element = String(format: "%2s", atom.element.symbol)

            pdb += "ATOM  \(serial) \(atomName) MOL A   1    \(x)\(y)\(z)  1.00  0.00          \(element)\n"
        }

        pdb += "END\n"

        guard let data = pdb.data(using: .utf8) else {
            throw FileServiceError.exportFailed
        }

        return data
    }

    private func generateXYZFile(_ molecule: Molecule) throws -> Data {
        var xyz = ""

        // Number of atoms
        xyz += "\(molecule.atoms.count)\n"

        // Comment line (molecule name)
        xyz += "\(molecule.name)\n"

        // Atom lines
        for atom in molecule.atoms {
            let symbol = atom.element.symbol
            let x = String(format: "%.6f", atom.position.x)
            let y = String(format: "%.6f", atom.position.y)
            let z = String(format: "%.6f", atom.position.z)

            xyz += "\(symbol)  \(x)  \(y)  \(z)\n"
        }

        guard let data = xyz.data(using: .utf8) else {
            throw FileServiceError.exportFailed
        }

        return data
    }
}

// MARK: - Element Symbol Lookup

extension Element {
    /// Create element from symbol string
    static func from(symbol: String) -> Element? {
        let normalized = symbol.trimmingCharacters(in: .whitespaces).capitalized

        return Element.allCases.first { $0.symbol.uppercased() == normalized.uppercased() }
    }
}

extension String {
    func firstIndex(of character: Character, offsetBy offset: Int) -> Index? {
        guard let startIndex = self.firstIndex(of: character) else { return nil }
        let offsetIndex = self.index(startIndex, offsetBy: offset, limitedBy: self.endIndex)
        return offsetIndex
    }
}

// MARK: - File Format

enum FileFormat {
    case mdl
    case sdf
    case pdb
    case xyz

    var fileExtension: String {
        switch self {
        case .mdl: return "mol"
        case .sdf: return "sdf"
        case .pdb: return "pdb"
        case .xyz: return "xyz"
        }
    }
}

// MARK: - File Service Error

enum FileServiceError: LocalizedError {
    case unsupportedFormat(String)
    case invalidFile
    case exportFailed
    case parsingError(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let ext):
            return "Unsupported file format: .\(ext)"
        case .invalidFile:
            return "Invalid or corrupted file"
        case .exportFailed:
            return "Failed to export molecule"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}
