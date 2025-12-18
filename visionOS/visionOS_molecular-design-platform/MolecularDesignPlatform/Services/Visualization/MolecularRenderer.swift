//
//  MolecularRenderer.swift
//  Molecular Design Platform
//
//  3D molecular rendering service
//

import Foundation
import RealityKit

// MARK: - Molecular Renderer

class MolecularRenderer {
    /// Create a RealityKit entity for a molecule
    func createEntity(for molecule: Molecule, style: VisualizationStyle) -> Entity {
        let rootEntity = Entity()

        if style.showAtoms {
            // Create atom entities
            for atom in molecule.atoms {
                let atomEntity = createAtomEntity(atom, style: style)
                rootEntity.addChild(atomEntity)
            }
        }

        if style.showBonds {
            // Create bond entities
            for bond in molecule.bonds {
                if let bond Entity = createBondEntity(bond, in: molecule, style: style) {
                    rootEntity.addChild(bondEntity)
                }
            }
        }

        return rootEntity
    }

    private func createAtomEntity(_ atom: Atom, style: VisualizationStyle) -> ModelEntity {
        let radius = atom.element.vdwRadius * style.scaleFactor * 0.01 // Scale to meters

        let mesh = MeshResource.generateSphere(radius: radius)
        var material = SimpleMaterial()
        material.color = .init(tint: atom.element.cpkColor.uiColor)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = atom.position * 0.01 // Scale to meters

        return entity
    }

    private func createBondEntity(_ bond: Bond, in molecule: Molecule, style: VisualizationStyle) -> ModelEntity? {
        guard let atom1 = molecule.atoms.first(where: { $0.id == bond.atom1 }),
              let atom2 = molecule.atoms.first(where: { $0.id == bond.atom2 }) else {
            return nil
        }

        let pos1 = atom1.position * 0.01
        let pos2 = atom2.position * 0.01

        let length = simd_distance(pos1, pos2)
        let radius: Float = 0.002 // 2mm radius

        let mesh = MeshResource.generateCylinder(height: length, radius: radius)
        var material = SimpleMaterial()
        material.color = .init(tint: .white)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position bond between atoms
        let midpoint = (pos1 + pos2) / 2
        entity.position = midpoint

        // Orient bond
        let direction = normalize(pos2 - pos1)
        let defaultDirection = SIMD3<Float>(0, 1, 0)
        let rotationAxis = cross(defaultDirection, direction)
        if simd_length(rotationAxis) > 0.001 {
            let angle = acos(dot(defaultDirection, direction))
            entity.orientation = simd_quatf(angle: angle, axis: normalize(rotationAxis))
        }

        return entity
    }
}

// MARK: - Color Extension

extension Color {
    var uiColor: UIColor {
        #if canImport(UIKit)
        return UIColor(self)
        #else
        return .white
        #endif
    }
}
