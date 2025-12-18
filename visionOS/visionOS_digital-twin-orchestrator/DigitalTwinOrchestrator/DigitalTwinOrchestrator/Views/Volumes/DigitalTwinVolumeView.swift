import SwiftUI
import RealityKit
import SwiftData

struct DigitalTwinVolumeView: View {
    let twinId: UUID

    // Environment
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissWindow) private var dismissWindow

    // State
    @State private var twin: DigitalTwin?
    @State private var showSensors = true
    @State private var showHealthView = true
    @State private var explodedView = false
    @State private var loadingState: ViewState<DigitalTwin> = .loading

    // Gesture state
    @State private var modelRotation: Rotation3D = .identity
    @State private var modelScale: Double = 1.0
    @State private var initialRotation: Rotation3D = .identity
    @State private var initialScale: Double = 1.0

    // Entity reference for updates
    @State private var rootEntity: Entity?

    private let defaultScale: Double = 1.0
    private let minScale: Double = 0.5
    private let maxScale: Double = 2.0

    var body: some View {
        Group {
            switch loadingState {
            case .loading:
                LoadingView("Loading Digital Twin...")

            case .error(let error):
                ErrorView(error: error)

            case .loaded(let loadedTwin):
                twinContentView(loadedTwin)

            case .idle:
                if let displayTwin = twin {
                    twinContentView(displayTwin)
                } else {
                    LoadingView("Loading...")
                }
            }
        }
        .task {
            await loadTwin()
        }
    }

    @ViewBuilder
    private func twinContentView(_ twin: DigitalTwin) -> some View {
        RealityView { content in
            let entity = await setupTwinScene(twin)
            rootEntity = entity
            content.add(entity)
        } update: { content in
            updateTwinVisualization(twin, in: content)
        }
        .gesture(rotationGesture)
        .gesture(magnifyGesture)
        .gesture(tapGesture)
        .overlay(alignment: .bottom) {
            controlPanel
        }
        .ornament(attachmentAnchor: .scene(.trailing)) {
            twinInfoPanel(twin)
        }
    }

    // MARK: - Gestures

    private var rotationGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let entity = rootEntity else { return }

                let translation = value.translation3D
                let rotationX = Angle.degrees(Double(translation.y) * 0.5)
                let rotationY = Angle.degrees(Double(translation.x) * 0.5)

                let newRotation = Rotation3D(
                    angle: rotationY,
                    axis: .y
                ).rotated(by: Rotation3D(angle: rotationX, axis: .x))

                entity.transform.rotation = simd_quatf(initialRotation.rotated(by: newRotation))
            }
            .onEnded { _ in
                if let entity = rootEntity {
                    initialRotation = Rotation3D(entity.transform.rotation)
                }
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let entity = rootEntity else { return }

                let newScale = initialScale * value.magnification
                let clampedScale = min(maxScale, max(minScale, newScale))
                modelScale = clampedScale

                entity.transform.scale = SIMD3<Float>(repeating: Float(clampedScale))
            }
            .onEnded { value in
                initialScale = modelScale
            }
    }

    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                // Handle tap on entity - could select component
                if let tappedEntity = value.entity.parent {
                    handleEntityTap(tappedEntity)
                }
            }
    }

    private func handleEntityTap(_ entity: Entity) {
        // Flash highlight effect on tapped entity
        if var modelComponent = entity.components[ModelComponent.self] {
            let originalMaterials = modelComponent.materials

            // Apply highlight
            modelComponent.materials = [SimpleMaterial(color: .white, isMetallic: true)]
            entity.components[ModelComponent.self] = modelComponent

            // Reset after delay
            Task {
                try? await Task.sleep(for: .milliseconds(200))
                modelComponent.materials = originalMaterials
                entity.components[ModelComponent.self] = modelComponent
            }
        }
    }

    // MARK: - Control Panel

    private var controlPanel: some View {
        HStack(spacing: 16) {
            Toggle("Sensors", isOn: $showSensors)
                .toggleStyle(.button)

            Toggle("Health View", isOn: $showHealthView)
                .toggleStyle(.button)

            Toggle("Exploded", isOn: $explodedView)
                .toggleStyle(.button)

            Divider()
                .frame(height: 24)

            Button {
                resetView()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }

            Button {
                dismissWindow(id: "twin-volume")
            } label: {
                Label("Close", systemImage: "xmark")
            }
        }
        .padding()
        .glassBackgroundEffect()
    }

    private func twinInfoPanel(_ twin: DigitalTwin) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(twin.name)
                .font(.headline)

            Text(twin.assetType.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Text("Health:")
                Spacer()
                Text("\(Int(twin.healthScore))%")
                    .foregroundStyle(HealthThresholds.color(for: twin.healthScore))
            }
            .font(.subheadline)

            HStack {
                Text("Status:")
                Spacer()
                Text(twin.operationalStatus.displayName)
                    .foregroundStyle(HealthThresholds.color(for: twin.healthScore))
            }
            .font(.subheadline)

            Divider()

            Text("Sensors: \(twin.activeSensorCount)/\(twin.sensors.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if twin.criticalPredictionsCount > 0 {
                Label("\(twin.criticalPredictionsCount) Critical Alerts", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Divider()

            // Gesture instructions
            VStack(alignment: .leading, spacing: 4) {
                Label("Drag to rotate", systemImage: "arrow.triangle.2.circlepath")
                Label("Pinch to scale", systemImage: "arrow.up.left.and.arrow.down.right")
                Label("Tap to select", systemImage: "hand.tap")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(width: 250)
        .glassBackgroundEffect()
    }

    // MARK: - Methods

    private func loadTwin() async {
        loadingState = .loading

        let descriptor = FetchDescriptor<DigitalTwin>(
            predicate: #Predicate { $0.id == twinId }
        )

        do {
            if let loadedTwin = try modelContext.fetch(descriptor).first {
                twin = loadedTwin
                loadingState = .loaded(loadedTwin)
            } else {
                loadingState = .error(.notFound(itemType: "Digital Twin"))
            }
        } catch {
            loadingState = .error(.loading(error) {
                await loadTwin()
            })
        }
    }

    private func resetView() {
        withAnimation(.spring(duration: 0.5)) {
            modelRotation = .identity
            modelScale = defaultScale
            initialRotation = .identity
            initialScale = defaultScale

            if let entity = rootEntity {
                entity.transform.rotation = simd_quatf(.identity)
                entity.transform.scale = SIMD3<Float>(repeating: Float(defaultScale))
            }
        }
    }

    @MainActor
    private func setupTwinScene(_ twin: DigitalTwin) async -> Entity {
        let rootEntity = Entity()
        rootEntity.name = "TwinRoot_\(twin.id)"

        // Try to load USDZ model if available
        if let modelURL = twin.modelURL {
            do {
                let modelEntity = try await ModelEntity(contentsOf: modelURL)
                modelEntity.name = "TwinModel"

                // Enable gestures on the model
                modelEntity.components.set(InputTargetComponent())
                modelEntity.generateCollisionShapes(recursive: true)

                // Apply health-based material tint
                applyHealthTint(to: modelEntity, healthScore: twin.healthScore)

                rootEntity.addChild(modelEntity)
            } catch {
                // Fallback to placeholder if model loading fails
                let placeholder = createPlaceholderModel(for: twin)
                rootEntity.addChild(placeholder)
            }
        } else {
            // No model URL - use placeholder
            let placeholder = createPlaceholderModel(for: twin)
            rootEntity.addChild(placeholder)
        }

        // Add sensor visualizations if enabled
        if showSensors {
            addSensorVisualizations(to: rootEntity, sensors: twin.sensors)
        }

        // Add lighting
        addLighting(to: rootEntity)

        return rootEntity
    }

    private func createPlaceholderModel(for twin: DigitalTwin) -> ModelEntity {
        let mesh: MeshResource
        let size: Float = 0.3

        // Different shapes based on asset type
        switch twin.assetType {
        case .turbine, .generator, .motor:
            mesh = .generateCylinder(height: size, radius: size / 2)
        case .tank, .reactor, .boiler:
            mesh = .generateCylinder(height: size * 1.2, radius: size / 2)
        case .pipeline, .conveyor:
            mesh = .generateBox(width: size * 2, height: size / 4, depth: size / 4)
        default:
            mesh = .generateBox(size: size)
        }

        let color = UIColor(HealthThresholds.color(for: twin.healthScore))
        let material = SimpleMaterial(color: color, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])

        entity.name = "PlaceholderModel"
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)

        return entity
    }

    private func applyHealthTint(to entity: ModelEntity, healthScore: Double) {
        let tintColor = UIColor(HealthThresholds.color(for: healthScore))

        if var modelComponent = entity.components[ModelComponent.self] {
            // Create tinted materials
            let tintedMaterials = modelComponent.materials.map { _ in
                SimpleMaterial(color: tintColor, isMetallic: true)
            }
            modelComponent.materials = tintedMaterials
            entity.components[ModelComponent.self] = modelComponent
        }
    }

    private func addSensorVisualizations(to parent: Entity, sensors: [Sensor]) {
        let sensorContainer = Entity()
        sensorContainer.name = "SensorContainer"

        for (index, sensor) in sensors.prefix(8).enumerated() {
            let angle = Double(index) * (2 * .pi / Double(min(8, sensors.count)))
            let radius: Float = 0.4

            let sensorEntity = createSensorIndicator(for: sensor)
            sensorEntity.position = SIMD3<Float>(
                Float(cos(angle)) * radius,
                0.2,
                Float(sin(angle)) * radius
            )

            sensorContainer.addChild(sensorEntity)
        }

        parent.addChild(sensorContainer)
    }

    private func createSensorIndicator(for sensor: Sensor) -> Entity {
        let size: Float = 0.03
        let mesh = MeshResource.generateSphere(radius: size)

        let color: UIColor
        if sensor.isWithinNormalRange() {
            color = .green
        } else if sensor.currentValue > (sensor.criticalThreshold ?? .infinity) {
            color = .red
        } else {
            color = .yellow
        }

        let material = SimpleMaterial(color: color, isMetallic: false)
        material.color.tint = color.withAlphaComponent(0.8)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "Sensor_\(sensor.id)"

        return entity
    }

    private func addLighting(to parent: Entity) {
        // Add ambient lighting for better visibility
        let lightEntity = Entity()
        lightEntity.name = "SceneLight"

        // Point light above the model
        var lightComponent = PointLightComponent()
        lightComponent.intensity = 1000
        lightComponent.attenuationRadius = 2.0
        lightEntity.components.set(lightComponent)
        lightEntity.position = SIMD3<Float>(0, 1, 0)

        parent.addChild(lightEntity)
    }

    @MainActor
    private func updateTwinVisualization(_ twin: DigitalTwin, in content: RealityViewContent) {
        guard let root = rootEntity else { return }

        // Update health-based coloring
        if let modelEntity = root.findEntity(named: "TwinModel") as? ModelEntity {
            applyHealthTint(to: modelEntity, healthScore: twin.healthScore)
        } else if let placeholder = root.findEntity(named: "PlaceholderModel") as? ModelEntity {
            applyHealthTint(to: placeholder, healthScore: twin.healthScore)
        }

        // Update sensor indicators
        if let sensorContainer = root.findEntity(named: "SensorContainer") {
            sensorContainer.isEnabled = showSensors
        }

        // Handle exploded view animation
        if explodedView {
            applyExplodedView(to: root)
        } else {
            resetExplodedView(on: root)
        }
    }

    private func applyExplodedView(to entity: Entity) {
        // Spread child entities outward
        for (index, child) in entity.children.enumerated() {
            let direction = SIMD3<Float>(
                cos(Float(index) * 0.5),
                0.1,
                sin(Float(index) * 0.5)
            )
            child.position = child.position + direction * 0.2
        }
    }

    private func resetExplodedView(on entity: Entity) {
        for child in entity.children {
            // Reset to original position (simplified)
            if child.name != "SceneLight" && child.name != "SensorContainer" {
                child.position = .zero
            }
        }
    }
}

#Preview {
    DigitalTwinVolumeView(twinId: UUID())
}
