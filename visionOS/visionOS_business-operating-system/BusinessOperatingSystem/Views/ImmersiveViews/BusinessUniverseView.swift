//
//  BusinessUniverseView.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import RealityKit

struct BusinessUniverseView: View {
    @Environment(\.appState) private var appState
    @Environment(\.services) private var services
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow

    @State private var departments: [Department] = []
    @State private var loadError: Error?
    @State private var isLoading = true
    @State private var selectedDepartmentID: UUID?
    @State private var showingDepartmentInfo = false

    var body: some View {
        RealityView { content in
            // Create full immersive business universe
            await createBusinessUniverse(content: content)
        }
        // Tap gesture for entity selection
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
        // Drag gesture for entity manipulation
        .gesture(
            DragGesture(minimumDistance: 0.01)
                .targetedToAnyEntity()
                .onChanged { value in
                    handleEntityDrag(value)
                }
        )
        // Long press for context actions
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityLongPress(value.entity)
                }
        )
        .overlay {
            // Show loading or error state
            if isLoading {
                ProgressView("Loading Business Universe...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let error = loadError {
                errorOverlay(for: error)
            }
        }
        .task {
            await loadBusinessData()
        }
    }

    // MARK: - Gesture Handlers

    private func handleEntityTap(_ entity: Entity) {
        // Find the root entity with a department or kpi name
        let targetEntity = findInteractiveParent(of: entity)
        guard let name = targetEntity?.name else { return }

        // Apply selection feedback
        applyTapFeedback(to: targetEntity!)

        // Handle department tap
        if name.hasPrefix("department-") {
            let idString = String(name.dropFirst("department-".count))
            if let uuid = UUID(uuidString: idString) {
                selectedDepartmentID = uuid
                openWindow(id: "department", value: uuid)

                // Track analytics
                Task {
                    await services.analytics.trackEvent(.departmentSelected(uuid))
                }
            }
        } else if name == "central-hub" {
            // Tap on central hub shows organization overview
            showingDepartmentInfo = true
        }
    }

    private func handleEntityDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        let targetEntity = findInteractiveParent(of: value.entity)
        guard let entity = targetEntity else { return }

        // Only allow dragging of departments
        guard entity.name.hasPrefix("department-") else { return }

        // Convert 2D drag to 3D movement
        let translation = value.translation3D
        let movement = SIMD3<Float>(
            Float(translation.x) * 0.0005,
            Float(translation.y) * 0.0005,
            Float(translation.z) * 0.0005
        )

        entity.position += movement
    }

    private func handleEntityLongPress(_ entity: Entity) {
        let targetEntity = findInteractiveParent(of: entity)
        guard let name = targetEntity?.name else { return }

        // Long press opens volumetric detail view
        if name.hasPrefix("department-") {
            let idString = String(name.dropFirst("department-".count))
            if let uuid = UUID(uuidString: idString) {
                openWindow(id: "department-volume", value: uuid)
            }
        }
    }

    private func findInteractiveParent(of entity: Entity) -> Entity? {
        var current: Entity? = entity

        while let candidate = current {
            let name = candidate.name
            if name.hasPrefix("department-") || name.hasPrefix("kpi-") || name == "central-hub" {
                return candidate
            }
            current = candidate.parent
        }

        return nil
    }

    private func applyTapFeedback(to entity: Entity) {
        let originalScale = entity.scale

        Task { @MainActor in
            // Scale up
            entity.scale = originalScale * 1.15

            try? await Task.sleep(for: .milliseconds(100))

            // Scale back down
            entity.scale = originalScale
        }
    }

    private func errorOverlay(for error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)

            Text("Failed to Load")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Retry") {
                    Task {
                        await loadBusinessData()
                    }
                }

                Button("Exit") {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func loadBusinessData() async {
        isLoading = true
        loadError = nil

        do {
            let depts = try await services.repository.fetchDepartments()
            departments = depts
            isLoading = false

            // Track immersive space entry
            await services.analytics.trackEvent(.immersiveSpaceEntered)
        } catch is CancellationError {
            // Task cancelled, don't update state
            return
        } catch {
            loadError = error
            isLoading = false

            // Track error
            await services.analytics.trackEvent(.errorOccurred(error))
        }
    }

    private func createBusinessUniverse(content: RealityViewContent) async {
        // Only create content if we have data
        guard !departments.isEmpty else { return }

        // Add environment lighting
        await addEnvironment(content: content)

        // Add department entities using the new 3D builder
        await addDepartments(content: content)

        // Add data flow connections between departments
        await addDataFlows(content: content)

        // Add central hub
        await addCentralHub(content: content)
    }

    private func addEnvironment(content: RealityViewContent) async {
        // Note: visionOS provides automatic ambient lighting
        // Only add directional light for enhanced shadows

        // Add directional light for shadows
        let directionalLight = Entity()
        var directionalComponent = DirectionalLightComponent()
        directionalComponent.color = .white
        directionalComponent.intensity = 1500
        directionalLight.components.set(directionalComponent)
        directionalLight.position = [2, 3, 0]
        directionalLight.look(at: [0, 0, -2], from: directionalLight.position, relativeTo: nil)
        content.add(directionalLight)

        // Add ground plane with grid
        let groundPlane = await createGroundPlane()
        groundPlane.position = [0, -0.5, -2]
        content.add(groundPlane)
    }

    private func createGroundPlane() async -> Entity {
        let ground = Entity()

        // Main ground surface
        let groundMesh = MeshResource.generatePlane(width: 6, depth: 6)
        var groundMaterial = PhysicallyBasedMaterial()
        groundMaterial.baseColor = .init(tint: .black.withAlphaComponent(0.3))
        groundMaterial.metallic = .init(floatLiteral: 0.1)
        groundMaterial.roughness = .init(floatLiteral: 0.9)

        let groundEntity = ModelEntity(mesh: groundMesh, materials: [groundMaterial])
        ground.addChild(groundEntity)

        // Add grid lines
        let gridSize: Float = 6.0
        let gridSpacing: Float = 0.5

        for i in stride(from: -gridSize/2, through: gridSize/2, by: gridSpacing) {
            // Horizontal lines
            let hLine = createGridLine(length: gridSize)
            hLine.position = [0, 0.001, i]
            ground.addChild(hLine)

            // Vertical lines
            let vLine = createGridLine(length: gridSize)
            vLine.position = [i, 0.001, 0]
            vLine.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            ground.addChild(vLine)
        }

        return ground
    }

    private func createGridLine(length: Float) -> Entity {
        let mesh = MeshResource.generateBox(size: [length, 0.001, 0.005])
        var material = UnlitMaterial(color: .systemBlue.withAlphaComponent(0.2))

        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func addDepartments(content: RealityViewContent) async {
        // Use the spatial layout engine for positioning
        let layoutEngine = SpatialLayoutEngine()
        let departmentIDs = departments.map { $0.id }
        let positions = layoutEngine.calculateRadialLayout(
            for: departmentIDs,
            radius: 2.0,
            centerPosition: [0, 0, -2.0],
            elevationAngle: 0
        )

        for department in departments {
            guard let position = positions[department.id] else { continue }

            // Create rich 3D department entity
            let builder = DepartmentEntityBuilder(department: department)
            let departmentEntity = await builder.build(configuration: .init(
                baseSize: 0.3,
                heightPerEmployee: 0.004,
                maxHeight: 0.6,
                showLabels: true,
                animationEnabled: true
            ))

            departmentEntity.position = position

            // Store department ID for interaction handling
            departmentEntity.name = "department-\(department.id)"

            content.add(departmentEntity)
        }
    }

    private func addDataFlows(content: RealityViewContent) async {
        // Create connections between related departments
        guard departments.count >= 2 else { return }

        let layoutEngine = SpatialLayoutEngine()
        let departmentIDs = departments.map { $0.id }
        let positions = layoutEngine.calculateRadialLayout(
            for: departmentIDs,
            radius: 2.0,
            centerPosition: [0, 0, -2.0]
        )

        // Create flow visualizer instance
        let visualizer = DataFlowVisualizer()

        // Connect adjacent departments in the radial layout
        for i in 0..<departments.count {
            let nextIndex = (i + 1) % departments.count
            guard let startPos = positions[departments[i].id],
                  let endPos = positions[departments[nextIndex].id] else { continue }

            // Only show some connections to avoid visual clutter
            if i % 2 == 0 {
                let flow = await visualizer.createFlowPath(
                    from: startPos + [0, 0.2, 0],
                    to: endPos + [0, 0.2, 0],
                    color: .systemBlue.withAlphaComponent(0.5),
                    configuration: DataFlowVisualizer.Configuration(particleCount: 5)
                )
                content.add(flow)
            }
        }
    }

    private func addCentralHub(content: RealityViewContent) async {
        let hub = Entity()
        hub.name = "central-hub"

        // Central sphere representing the organization
        let sphereMesh = MeshResource.generateSphere(radius: 0.15)
        var sphereMaterial = PhysicallyBasedMaterial()
        sphereMaterial.baseColor = .init(tint: .systemBlue)
        sphereMaterial.metallic = .init(floatLiteral: 0.9)
        sphereMaterial.roughness = .init(floatLiteral: 0.1)
        sphereMaterial.emissiveColor = .init(color: .systemBlue)
        sphereMaterial.emissiveIntensity = 0.3

        let sphere = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])
        hub.addChild(sphere)

        // Orbiting rings
        for i in 0..<3 {
            let ring = await createOrbitingRing(radius: 0.2 + Float(i) * 0.08, index: i)
            hub.addChild(ring)
        }

        // Point light at center
        var lightComponent = PointLightComponent()
        lightComponent.color = .systemBlue
        lightComponent.intensity = 2000
        lightComponent.attenuationRadius = 1.5
        hub.components.set(lightComponent)

        hub.position = [0, 0.3, -2.0]
        hub.components.set(InputTargetComponent())
        hub.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.3)]))

        content.add(hub)
    }

    private func createOrbitingRing(radius: Float, index: Int) async -> Entity {
        let ring = Entity()

        let torusMesh = MeshResource.generateBox(size: [radius * 2, 0.005, 0.01])
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .white.withAlphaComponent(0.3))

        // Create ring from multiple segments
        let segments = 32
        for i in 0..<segments {
            let angle = Float(i) * (2 * .pi / Float(segments))
            let segment = ModelEntity(mesh: MeshResource.generateBox(size: [0.01, 0.003, 0.02]), materials: [material])
            segment.position = [radius * cos(angle), 0, radius * sin(angle)]
            segment.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
            ring.addChild(segment)
        }

        // Tilt each ring differently
        ring.orientation = simd_quatf(angle: Float(index) * 0.4, axis: SIMD3<Float>(1, 0, 0.5).normalized)

        return ring
    }
}
