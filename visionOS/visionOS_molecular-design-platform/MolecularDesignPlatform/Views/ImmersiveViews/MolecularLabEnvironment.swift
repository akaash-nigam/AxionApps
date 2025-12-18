//
//  MolecularLabEnvironment.swift
//  Molecular Design Platform
//
//  Immersive molecular laboratory environment
//

import SwiftUI
import RealityKit

struct MolecularLabEnvironment: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var showingControls = true

    var body: some View {
        ZStack {
            // RealityView for immersive 3D content
            RealityView { content in
                setupImmersiveLab(content)
            } update: { content in
                updateImmersiveLab(content)
            }

            // UI overlay
            VStack {
                HStack {
                    Button(action: { showingControls.toggle() }) {
                        Label("Toggle Controls", systemImage: "sidebar.left")
                    }

                    Spacer()

                    Button("Exit Lab") {
                        Task {
                            await dismissImmersiveSpace()
                        }
                    }
                }
                .padding()

                Spacer()

                if showingControls {
                    LabControlPanel()
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }

    private func setupImmersiveLab(_ content: RealityViewContent) {
        // Create lab environment
        let floor = createFloor()
        content.add(floor)

        // Add ambient lighting
        let ambientLight = AmbientLight()
        ambientLight.light.intensity = 200
        content.add(ambientLight)

        // Add directional light
        let sunLight = DirectionalLight()
        sunLight.light.intensity = 1500
        sunLight.position = [2, 3, 2]
        sunLight.look(at: .zero, from: sunLight.position, relativeTo: nil)
        content.add(sunLight)

        // Add sample molecules in space
        addSampleMolecules(to: content)
    }

    private func updateImmersiveLab(_ content: RealityViewContent) {
        // Update lab content
    }

    private func createFloor() -> Entity {
        let floor = ModelEntity(
            mesh: .generatePlane(width: 10, depth: 10),
            materials: [SimpleMaterial(color: .init(white: 0.8, alpha: 0.3), isMetallic: false)]
        )
        floor.position = [0, -0.5, 0]
        return floor
    }

    private func addSampleMolecules(to content: RealityViewContent) {
        guard let renderer = appState?.services.molecularRenderer else { return }

        // Add a few sample molecules in the space
        let positions: [SIMD3<Float>] = [
            [-1.5, 0.5, -2],
            [0, 0.8, -2.5],
            [1.5, 0.5, -2]
        ]

        for (index, position) in positions.enumerated() {
            let molecule = createSampleMolecule(index: index)
            let entity = renderer.createEntity(for: molecule, style: .ballAndStick)
            entity.position = position
            content.add(entity)
        }
    }

    private func createSampleMolecule(index: Int) -> Molecule {
        // Create different sample molecules
        switch index {
        case 0:
            // Water
            let oxygen = Atom(element: .oxygen, position: .zero)
            let h1 = Atom(element: .hydrogen, position: SIMD3<Float>(-0.96, 0, 0))
            let h2 = Atom(element: .hydrogen, position: SIMD3<Float>(0.24, 0.93, 0))
            return Molecule(name: "Water", formula: "H2O", atoms: [oxygen, h1, h2], bonds: [])

        case 1:
            // Carbon dioxide
            let carbon = Atom(element: .carbon, position: .zero)
            let o1 = Atom(element: .oxygen, position: SIMD3<Float>(-1.2, 0, 0))
            let o2 = Atom(element: .oxygen, position: SIMD3<Float>(1.2, 0, 0))
            return Molecule(name: "Carbon Dioxide", formula: "CO2", atoms: [carbon, o1, o2], bonds: [])

        default:
            // Methane
            let carbon = Atom(element: .carbon, position: .zero)
            return Molecule(name: "Methane", formula: "CH4", atoms: [carbon], bonds: [])
        }
    }
}

// MARK: - Lab Control Panel

struct LabControlPanel: View {
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {}) {
                Label("Add Molecule", systemImage: "plus.circle")
            }

            Button(action: {}) {
                Label("Start Simulation", systemImage: "play.circle")
            }

            Button(action: {}) {
                Label("Measure", systemImage: "ruler")
            }

            Button(action: {}) {
                Label("Annotate", systemImage: "pencil.circle")
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 40)
    }
}

#Preview {
    MolecularLabEnvironment()
}
