//
//  AnatomyVolumeView.swift
//  Surgical Training Universe
//
//  3D anatomical model explorer in volumetric window
//

import SwiftUI
import RealityKit

/// Volumetric view for exploring 3D anatomical models
struct AnatomyVolumeView: View {

    @Environment(AppState.self) private var appState
    @State private var selectedAnatomy: AnatomyType = .heart
    @State private var rotationAngle: Float = 0
    @State private var showLabels = true
    @State private var explodedView = false
    @State private var selectedLayer: AnatomicalLayer = .all

    var body: some View {
        ZStack {
            // Main 3D content
            RealityView { content in
                await setupAnatomyVolume(content: content)
            } update: { content in
                updateAnatomyVolume(content: content)
            }

            // Control overlay
            VStack {
                Spacer()

                controlPanel
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Control Panel

    private var controlPanel: some View {
        HStack(spacing: 16) {
            // Anatomy selector
            Menu {
                ForEach(AnatomyType.allCases, id: \.self) { anatomy in
                    Button(anatomy.rawValue) {
                        selectedAnatomy = anatomy
                    }
                }
            } label: {
                Label(selectedAnatomy.rawValue, systemImage: "square.stack.3d.up.fill")
            }
            .buttonStyle(.bordered)

            Divider()
                .frame(height: 30)

            // Layer controls
            Button {
                showLabels.toggle()
            } label: {
                Label("Labels", systemImage: showLabels ? "tag.fill" : "tag")
            }
            .buttonStyle(.bordered)

            Button {
                explodedView.toggle()
            } label: {
                Label("Explode", systemImage: "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.bordered)

            // Rotation control
            Button {
                rotationAngle += .pi / 4
            } label: {
                Label("Rotate", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)

            Button {
                resetView()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    // MARK: - RealityKit Setup

    @MainActor
    private func setupAnatomyVolume(content: RealityViewContent) async {
        // Create root entity
        let root = Entity()

        // Load anatomical model
        let anatomy = await createAnatomicalModel(type: selectedAnatomy)
        root.addChild(anatomy)

        // Add lighting
        let light = createLighting()
        root.addChild(light)

        content.add(root)
    }

    @MainActor
    private func updateAnatomyVolume(content: RealityViewContent) {
        // Update rotation, layers, etc.
    }

    @MainActor
    private func createAnatomicalModel(type: AnatomyType) async -> Entity {
        let model = Entity()

        // Create model based on type
        // In production, load actual 3D models
        let mesh: MeshResource
        let material = SimpleMaterial(color: .init(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0), isMetallic: false)

        switch type {
        case .heart:
            mesh = .generateSphere(radius: 0.15)
        case .brain:
            mesh = .generateSphere(radius: 0.2)
        case .liver:
            mesh = .generateBox(width: 0.3, height: 0.15, depth: 0.25)
        default:
            mesh = .generateSphere(radius: 0.15)
        }

        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        model.addChild(modelEntity)

        return model
    }

    @MainActor
    private func createLighting() -> Entity {
        let light = Entity()

        var pointLight = PointLightComponent(color: .white, intensity: 500, attenuationRadius: 2.0)
        pointLight.isEnabled = true
        light.components.set(pointLight)
        light.position = [0, 0.5, 0.5]

        return light
    }

    // MARK: - Methods

    private func resetView() {
        rotationAngle = 0
        explodedView = false
        selectedLayer = .all
    }
}

enum AnatomicalLayer: String {
    case all = "All Layers"
    case skin = "Skin"
    case muscle = "Muscle"
    case organs = "Organs"
    case skeleton = "Skeleton"
    case vascular = "Vascular"
    case nervous = "Nervous"
}

// MARK: - Instrument Preview Volume

struct InstrumentPreviewVolume: View {
    @State private var selectedInstrument: InstrumentType = .scalpel
    @State private var autoRotate = true

    var body: some View {
        ZStack {
            RealityView { content in
                await setupInstrumentPreview(content: content)
            }

            VStack {
                Spacer()

                instrumentControls
                    .padding(.bottom, 40)
            }
        }
    }

    private var instrumentControls: some View {
        HStack(spacing: 16) {
            Button {
                selectedInstrument = previousInstrument
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.bordered)

            Text(selectedInstrument.rawValue)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)

            Button {
                selectedInstrument = nextInstrument
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.bordered)

            Toggle(isOn: $autoRotate) {
                Label("Auto Rotate", systemImage: "arrow.clockwise")
            }
            .toggleStyle(.button)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    @MainActor
    private func setupInstrumentPreview(content: RealityViewContent) async {
        let root = Entity()

        // Create instrument model
        let instrument = await createInstrumentModel(type: selectedInstrument)
        root.addChild(instrument)

        // Add lighting
        let light = Entity()
        var pointLight = PointLightComponent(color: .white, intensity: 400, attenuationRadius: 1.5)
        pointLight.isEnabled = true
        light.components.set(pointLight)
        light.position = [0, 0.3, 0.3]
        root.addChild(light)

        content.add(root)
    }

    @MainActor
    private func createInstrumentModel(type: InstrumentType) async -> Entity {
        let instrument = Entity()

        // Create simplified instrument model
        // In production, load actual 3D models
        let material = SimpleMaterial(color: .gray, isMetallic: true)

        let mesh: MeshResource
        switch type {
        case .scalpel:
            mesh = .generateBox(width: 0.02, height: 0.15, depth: 0.005)
        case .forceps:
            mesh = .generateBox(width: 0.02, height: 0.12, depth: 0.01)
        default:
            mesh = .generateBox(width: 0.02, height: 0.1, depth: 0.01)
        }

        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        instrument.addChild(modelEntity)

        return instrument
    }

    private var previousInstrument: InstrumentType {
        let allCases = InstrumentType.allCases
        guard let currentIndex = allCases.firstIndex(of: selectedInstrument) else {
            return .scalpel
        }
        let previousIndex = (currentIndex - 1 + allCases.count) % allCases.count
        return allCases[previousIndex]
    }

    private var nextInstrument: InstrumentType {
        let allCases = InstrumentType.allCases
        guard let currentIndex = allCases.firstIndex(of: selectedInstrument) else {
            return .scalpel
        }
        let nextIndex = (currentIndex + 1) % allCases.count
        return allCases[nextIndex]
    }
}

#Preview("Anatomy Volume") {
    AnatomyVolumeView()
        .environment(AppState())
}

#Preview("Instrument Preview") {
    InstrumentPreviewVolume()
}
