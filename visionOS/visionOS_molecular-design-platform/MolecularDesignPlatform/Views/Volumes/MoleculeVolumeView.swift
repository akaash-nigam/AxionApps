//
//  MoleculeVolumeView.swift
//  Molecular Design Platform
//
//  3D volumetric view of molecules
//

import SwiftUI
import RealityKit

struct MoleculeVolumeView: View {
    @Environment(\.appState) private var appState

    @State private var selectedStyle: VisualizationStyle = .ballAndStick
    @State private var rotationAngle: Angle = .zero

    var body: some View {
        ZStack {
            // RealityView for 3D content
            RealityView { content in
                setupMolecularScene(content)
            } update: { content in
                updateMolecularScene(content)
            }

            // Ornament toolbar
            VStack {
                Spacer()

                HStack(spacing: 20) {
                    // Visualization style picker
                    Picker("Style", selection: $selectedStyle) {
                        ForEach(VisualizationStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()

                    Divider()
                        .frame(height: 30)

                    // Rotation reset
                    Button(action: resetRotation) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }

                    // Auto-fit
                    Button(action: autoFit) {
                        Label("Fit", systemImage: "square.resize")
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 40)
            }
        }
    }

    private func setupMolecularScene(_ content: RealityViewContent) {
        // Create sample molecule (water for demo)
        let molecule = createSampleMolecule()

        guard let renderer = appState?.services.molecularRenderer else { return }
        let entity = renderer.createEntity(for: molecule, style: selectedStyle)

        content.add(entity)

        // Add lighting
        let light = DirectionalLight()
        light.light.intensity = 1000
        light.position = [0, 1, 1]
        content.add(light)
    }

    private func updateMolecularScene(_ content: RealityViewContent) {
        // Update visualization when style changes
        // In production, update the existing entity
    }

    private func createSampleMolecule() -> Molecule {
        // Create water molecule (H2O) for demo
        let oxygen = Atom(element: .oxygen, position: SIMD3<Float>(0, 0, 0))
        let hydrogen1 = Atom(element: .hydrogen, position: SIMD3<Float>(-0.96, 0, 0))
        let hydrogen2 = Atom(element: .hydrogen, position: SIMD3<Float>(0.24, 0.93, 0))

        let bond1 = Bond(atom1: oxygen.id, atom2: hydrogen1.id)
        let bond2 = Bond(atom1: oxygen.id, atom2: hydrogen2.id)

        return Molecule(
            name: "Water",
            formula: "H2O",
            atoms: [oxygen, hydrogen1, hydrogen2],
            bonds: [bond1, bond2]
        )
    }

    private func resetRotation() {
        rotationAngle = .zero
    }

    private func autoFit() {
        // Auto-fit molecule to view
    }
}

#Preview {
    MoleculeVolumeView()
}
