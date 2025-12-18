//
//  SimulationTheaterView.swift
//  IndustrialCADCAM
//
//  Simulation theater for analysis visualization
//

import SwiftUI
import RealityKit

struct SimulationTheaterView: View {
    @Environment(AppState.self) private var appState

    @State private var rootEntity = Entity()
    @State private var simulationType: SimulationType = .structural
    @State private var showColorLegend = true
    @State private var deformationScale: Float = 10.0

    var body: some View {
        RealityView { content in
            setupSimulationScene(content: content)
        } update: { content in
            updateSimulation(content: content)
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            simulationControlsOrnament
        }
        .ornament(attachmentAnchor: .scene(.trailing)) {
            if showColorLegend {
                colorLegendOrnament
            }
        }
    }

    // MARK: - Scene Setup

    private func setupSimulationScene(content: RealityViewContent) {
        content.add(rootEntity)

        // Setup lighting for analysis
        setupAnalysisLighting()

        // Add simulation part with analysis visualization
        addSimulationPart()
    }

    private func setupAnalysisLighting() {
        // Neutral lighting for accurate color visualization
        let mainLight = DirectionalLight()
        mainLight.light.intensity = 1500
        mainLight.position = SIMD3<Float>(0, 3, 2)
        mainLight.look(at: .zero, from: mainLight.position, relativeTo: nil)
        rootEntity.addChild(mainLight)

        // Ambient light
        let ambient = PointLight()
        ambient.light.intensity = 500
        ambient.position = SIMD3<Float>(0, 2, 0)
        rootEntity.addChild(ambient)
    }

    private func addSimulationPart() {
        // Create sample part for simulation
        let mesh = MeshResource.generateBox(size: 0.4)

        // Apply stress analysis color map
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .init(red: 0.0, green: 0.4, blue: 1.0, alpha: 1.0))
        material.emissiveColor = .init(color: .blue.withAlphaComponent(0.3))
        material.emissiveIntensity = 0.5

        let partEntity = ModelEntity(mesh: mesh, materials: [material])
        partEntity.position = SIMD3<Float>(0, 0.3, 0)

        rootEntity.addChild(partEntity)

        // Add stress indicators (hot spots)
        addStressIndicators(to: partEntity)
    }

    private func addStressIndicators(to parent: Entity) {
        // Add red spheres at peak stress locations
        let hotSpotPositions: [SIMD3<Float>] = [
            SIMD3<Float>(0.15, 0.5, 0.15),
            SIMD3<Float>(-0.15, 0.5, -0.15)
        ]

        for position in hotSpotPositions {
            let mesh = MeshResource.generateSphere(radius: 0.03)

            var material = UnlitMaterial()
            material.color = .init(tint: .red)

            let indicator = ModelEntity(mesh: mesh, materials: [material])
            indicator.position = position

            parent.addChild(indicator)
        }
    }

    private func updateSimulation(content: RealityViewContent) {
        // Update visualization based on simulation type
    }

    // MARK: - Ornaments

    private var simulationControlsOrnament: some View {
        VStack(spacing: 16) {
            Text("🎭 Simulation Analysis")
                .font(.headline)

            // Simulation type picker
            Picker("Analysis Type", selection: $simulationType) {
                Text("Stress").tag(SimulationType.structural)
                Text("Thermal").tag(SimulationType.thermal)
                Text("Modal").tag(SimulationType.modal)
                Text("CFD").tag(SimulationType.cfd)
            }
            .pickerStyle(.segmented)

            Divider()

            // Deformation scale
            VStack(alignment: .leading, spacing: 8) {
                Text("Deformation Scale: \(Int(deformationScale))x")
                    .font(.caption)

                Slider(value: $deformationScale, in: 1...100, step: 1)
                    .frame(width: 200)
            }

            HStack(spacing: 12) {
                Toggle("Show Legend", isOn: $showColorLegend)
                    .toggleStyle(.switch)

                Button(action: {}) {
                    Label("Export Report", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 400)
        .glassBackgroundEffect()
    }

    private var colorLegendOrnament: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color Legend")
                .font(.headline)

            // Stress levels
            VStack(alignment: .leading, spacing: 6) {
                LegendItem(color: .red, label: "300 MPa", sublabel: "Max")
                LegendItem(color: .orange, label: "250 MPa")
                LegendItem(color: .yellow, label: "200 MPa")
                LegendItem(color: .green, label: "150 MPa")
                LegendItem(color: .cyan, label: "100 MPa")
                LegendItem(color: .blue, label: "0 MPa", sublabel: "Min")
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Max Stress: 287 MPa")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("@ Node 4521 (Top Corner)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text("Safety Factor: 2.3")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(width: 200)
        .glassBackgroundEffect()
    }
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let label: String
    var sublabel: String?

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.caption)

            if let sublabel = sublabel {
                Text(sublabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SimulationTheaterView()
}
