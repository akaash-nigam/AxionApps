//
//  DesignVolumeView.swift
//  IndustrialCADCAM
//
//  Primary 3D design workspace volume
//

import SwiftUI
import RealityKit

struct DesignVolumeView: View {
    @Environment(AppState.self) private var appState
    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            // Set up the 3D scene
            setupScene(content: content)
        } update: { content in
            // Update scene based on state changes
            updateScene(content: content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    handleDrag(value: value)
                }
        )
        .ornament(attachmentAnchor: .scene(.bottom)) {
            viewControlsOrnament
        }
        .ornament(attachmentAnchor: .scene(.topTrailing)) {
            viewModeOrnament
        }
    }

    // MARK: - Scene Setup

    private func setupScene(content: RealityViewContent) {
        // Add root entity
        content.add(rootEntity)

        // Set up lighting
        setupLighting()

        // Add grid floor
        addGridFloor()

        // Add axis indicator
        addAxisIndicator()

        // Add sample part (for demonstration)
        addSamplePart()
    }

    private func setupLighting() {
        // Key light (main)
        let keyLight = DirectionalLight()
        keyLight.light.intensity = 2000
        keyLight.position = SIMD3<Float>(2, 3, 2)
        keyLight.look(at: SIMD3<Float>(0, 0, 0), from: keyLight.position, relativeTo: nil)
        rootEntity.addChild(keyLight)

        // Fill light
        let fillLight = DirectionalLight()
        fillLight.light.intensity = 800
        fillLight.position = SIMD3<Float>(-2, 2, 1)
        fillLight.look(at: SIMD3<Float>(0, 0, 0), from: fillLight.position, relativeTo: nil)
        rootEntity.addChild(fillLight)

        // Rim light
        let rimLight = DirectionalLight()
        rimLight.light.intensity = 600
        rimLight.position = SIMD3<Float>(0, 2, -2)
        rimLight.look(at: SIMD3<Float>(0, 0, 0), from: rimLight.position, relativeTo: nil)
        rootEntity.addChild(rimLight)

        // Ambient light
        let ambient = PointLight()
        ambient.light.intensity = 400
        ambient.position = SIMD3<Float>(0, 2, 0)
        rootEntity.addChild(ambient)
    }

    private func addGridFloor() {
        // Create grid mesh
        var gridMesh = MeshResource.generatePlane(width: 2.0, depth: 2.0)

        // Grid material with transparency
        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.1))
        material.metallic = 0.0
        material.roughness = 1.0

        let gridEntity = ModelEntity(mesh: gridMesh, materials: [material])
        gridEntity.position = SIMD3<Float>(0, 0, 0)

        rootEntity.addChild(gridEntity)
    }

    private func addAxisIndicator() {
        // X axis (red)
        let xAxis = createAxisLine(
            from: SIMD3<Float>(0, 0, 0),
            to: SIMD3<Float>(0.2, 0, 0),
            color: .red
        )
        rootEntity.addChild(xAxis)

        // Y axis (green)
        let yAxis = createAxisLine(
            from: SIMD3<Float>(0, 0, 0),
            to: SIMD3<Float>(0, 0.2, 0),
            color: .green
        )
        rootEntity.addChild(yAxis)

        // Z axis (blue)
        let zAxis = createAxisLine(
            from: SIMD3<Float>(0, 0, 0),
            to: SIMD3<Float>(0, 0, 0.2),
            color: .blue
        )
        rootEntity.addChild(zAxis)
    }

    private func createAxisLine(from start: SIMD3<Float>, to end: SIMD3<Float>, color: UIColor) -> Entity {
        let length = simd_distance(start, end)
        let mesh = MeshResource.generateBox(width: 0.005, height: length, depth: 0.005)

        var material = SimpleMaterial()
        material.color = .init(tint: color)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position and orient the line
        entity.position = (start + end) / 2
        entity.look(at: end, from: start, relativeTo: nil)

        return entity
    }

    private func addSamplePart() {
        // Create a sample part (cube for now)
        let mesh = MeshResource.generateBox(size: 0.3)

        // Material
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .init(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0))
        material.metallic = 0.9
        material.roughness = 0.3

        let partEntity = ModelEntity(mesh: mesh, materials: [material])
        partEntity.position = SIMD3<Float>(0, 0.2, 0)

        // Add collision for interaction
        partEntity.generateCollisionShapes(recursive: false)

        // Add custom component for CAD data
        partEntity.components[CADPartComponent.self] = CADPartComponent(
            partId: UUID(),
            geometryVersion: 1,
            isEditable: true,
            highlightMode: .none
        )

        rootEntity.addChild(partEntity)
    }

    // MARK: - Scene Update

    private func updateScene(content: RealityViewContent) {
        // Update scene based on app state changes
        // This is called when @State variables change
    }

    // MARK: - Interaction Handlers

    private func handleTap(on entity: Entity) {
        // Handle tap on entity
        if let cadComponent = entity.components[CADPartComponent.self] {
            appState.selectedParts.insert(cadComponent.partId)

            // Highlight the entity
            highlightEntity(entity, highlighted: true)
        }
    }

    private func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
        // Handle dragging entity
        guard let entity = value.entity else { return }

        // Convert 2D drag to 3D movement
        let translation = value.convert(value.translation3D, from: .local, to: .scene)
        entity.position += SIMD3<Float>(
            Float(translation.x),
            Float(translation.y),
            Float(translation.z)
        )
    }

    private func highlightEntity(_ entity: Entity, highlighted: Bool) {
        guard var modelEntity = entity as? ModelEntity else { return }

        if highlighted {
            // Add blue highlight
            var material = PhysicallyBasedMaterial()
            material.emissiveColor = .init(color: .blue)
            material.emissiveIntensity = 0.3

            if let firstMaterial = modelEntity.model?.materials.first as? PhysicallyBasedMaterial {
                var highlightMaterial = firstMaterial
                highlightMaterial.emissiveColor = .init(color: .blue)
                highlightMaterial.emissiveIntensity = 0.3
                modelEntity.model?.materials = [highlightMaterial]
            }
        } else {
            // Remove highlight
            if let firstMaterial = modelEntity.model?.materials.first as? PhysicallyBasedMaterial {
                var normalMaterial = firstMaterial
                normalMaterial.emissiveIntensity = 0.0
                modelEntity.model?.materials = [normalMaterial]
            }
        }
    }

    // MARK: - Ornaments

    private var viewControlsOrnament: some View {
        HStack(spacing: 16) {
            Button(action: { resetCamera() }) {
                Label("Home", systemImage: "house.fill")
            }

            Button(action: { fitToView() }) {
                Label("Fit", systemImage: "viewfinder")
            }

            Button(action: { toggleGrid() }) {
                Label("Grid", systemImage: "grid")
            }
        }
        .padding()
        .glassBackgroundEffect()
    }

    private var viewModeOrnament: some View {
        Picker("View Mode", selection: Binding(
            get: { appState.viewMode },
            set: { appState.viewMode = $0 }
        )) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 350)
        .padding()
        .glassBackgroundEffect()
    }

    // MARK: - View Actions

    private func resetCamera() {
        // Reset camera to default position
    }

    private func fitToView() {
        // Fit all objects in view
    }

    private func toggleGrid() {
        // Toggle grid visibility
    }
}

// MARK: - CAD Part Component

struct CADPartComponent: Component {
    var partId: UUID
    var geometryVersion: Int
    var isEditable: Bool
    var highlightMode: HighlightMode

    enum HighlightMode {
        case none
        case selected
        case hovered
        case error
    }
}

#Preview {
    DesignVolumeView()
        .frame(width: 800, height: 600)
}
