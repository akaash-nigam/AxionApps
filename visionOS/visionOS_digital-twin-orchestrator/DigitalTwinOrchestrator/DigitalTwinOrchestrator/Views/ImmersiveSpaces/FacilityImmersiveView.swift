import SwiftUI
import RealityKit
import SwiftData

struct FacilityImmersiveView: View {
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.modelContext) private var modelContext

    @Query private var twins: [DigitalTwin]

    @State private var facilityEntity: Entity?
    @State private var isExiting = false

    var body: some View {
        RealityView { content in
            let facility = await setupFacilityScene()
            facilityEntity = facility
            content.add(facility)
        } update: { content in
            updateFacilityVisualization()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTwinTap(value.entity)
                }
        )
        .overlay(alignment: .topTrailing) {
            controlPanel
        }
        .overlay(alignment: .bottom) {
            facilityLegend
        }
        .onChange(of: navigationState.isImmersiveSpaceActive) { _, isActive in
            if !isActive {
                Task { await exitImmersiveSpace() }
            }
        }
    }

    private var controlPanel: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text("Facility View")
                .font(.headline)

            Text("\(twins.count) Digital Twins")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Button {
                Task { await exitImmersiveSpace() }
            } label: {
                if isExiting {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Exit Immersive", systemImage: "xmark.circle")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isExiting)
        }
        .padding()
        .glassBackgroundEffect()
    }

    private var facilityLegend: some View {
        HStack(spacing: 24) {
            legendItem(color: .green, label: "Healthy (90%+)")
            legendItem(color: .yellow, label: "Warning (70-90%)")
            legendItem(color: .orange, label: "Fair (50-70%)")
            legendItem(color: .red, label: "Critical (<50%)")
        }
        .padding()
        .glassBackgroundEffect()
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption)
        }
    }

    // MARK: - Methods

    private func exitImmersiveSpace() async {
        isExiting = true
        navigationState.isImmersiveSpaceActive = false
        await dismissImmersiveSpace()
        isExiting = false
    }

    @MainActor
    private func setupFacilityScene() async -> Entity {
        let root = Entity()
        root.name = "FacilityRoot"

        // Create floor grid
        let floor = createFloorGrid()
        root.addChild(floor)

        // Position twins in a grid layout
        let gridSize = Int(ceil(sqrt(Double(twins.count))))
        let spacing: Float = 2.0

        for (index, twin) in twins.enumerated() {
            let row = index / gridSize
            let col = index % gridSize

            let twinEntity = await createTwinEntity(for: twin)
            twinEntity.position = SIMD3<Float>(
                Float(col) * spacing - Float(gridSize - 1) * spacing / 2,
                0.5,
                Float(row) * spacing - Float(gridSize - 1) * spacing / 2
            )

            root.addChild(twinEntity)
        }

        // Add ambient lighting
        addAmbientLighting(to: root)

        return root
    }

    private func createFloorGrid() -> Entity {
        let floor = ModelEntity(
            mesh: .generatePlane(width: 20, depth: 20),
            materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.2), isMetallic: false)]
        )
        floor.name = "Floor"

        // Add grid lines
        let gridEntity = Entity()
        gridEntity.name = "Grid"

        for i in -10...10 {
            // Horizontal lines
            let hLine = ModelEntity(
                mesh: .generateBox(width: 20, height: 0.005, depth: 0.01),
                materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.3), isMetallic: false)]
            )
            hLine.position = SIMD3<Float>(0, 0.001, Float(i))
            gridEntity.addChild(hLine)

            // Vertical lines
            let vLine = ModelEntity(
                mesh: .generateBox(width: 0.01, height: 0.005, depth: 20),
                materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.3), isMetallic: false)]
            )
            vLine.position = SIMD3<Float>(Float(i), 0.001, 0)
            gridEntity.addChild(vLine)
        }

        let parent = Entity()
        parent.addChild(floor)
        parent.addChild(gridEntity)
        return parent
    }

    @MainActor
    private func createTwinEntity(for twin: DigitalTwin) async -> Entity {
        let container = Entity()
        container.name = "Twin_\(twin.id)"

        // Create 3D representation based on asset type
        let mesh: MeshResource
        let size: Float = 0.4

        switch twin.assetType {
        case .turbine, .generator, .motor:
            mesh = .generateCylinder(height: size, radius: size / 2)
        case .tank, .reactor, .boiler:
            mesh = .generateCylinder(height: size * 1.5, radius: size / 2)
        case .pipeline, .conveyor:
            mesh = .generateBox(width: size * 1.5, height: size / 3, depth: size / 3)
        default:
            mesh = .generateBox(size: size)
        }

        let color = UIColor(HealthThresholds.color(for: twin.healthScore))
        let material = SimpleMaterial(color: color, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.name = "Model"

        // Enable interaction
        model.components.set(InputTargetComponent())
        model.generateCollisionShapes(recursive: true)

        container.addChild(model)

        // Add label
        let labelEntity = createLabelEntity(text: twin.name)
        labelEntity.position = SIMD3<Float>(0, size + 0.15, 0)
        container.addChild(labelEntity)

        // Add health indicator ring
        let healthRing = createHealthRing(healthScore: twin.healthScore)
        healthRing.position = SIMD3<Float>(0, 0.01, 0)
        container.addChild(healthRing)

        return container
    }

    private func createLabelEntity(text: String) -> Entity {
        // Create a simple text billboard
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.08),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )

        let material = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        textEntity.name = "Label"

        // Center the text
        if let bounds = textEntity.model?.mesh.bounds {
            textEntity.position.x = -bounds.center.x
        }

        return textEntity
    }

    private func createHealthRing(healthScore: Double) -> Entity {
        let radius: Float = 0.35
        let ringMesh = MeshResource.generateCylinder(height: 0.02, radius: radius)

        let color = UIColor(HealthThresholds.color(for: healthScore)).withAlphaComponent(0.5)
        let material = SimpleMaterial(color: color, isMetallic: false)

        let ring = ModelEntity(mesh: ringMesh, materials: [material])
        ring.name = "HealthRing"

        return ring
    }

    private func addAmbientLighting(to entity: Entity) {
        // Main light from above
        let mainLight = Entity()
        var pointLight = PointLightComponent()
        pointLight.intensity = 5000
        pointLight.attenuationRadius = 30
        mainLight.components.set(pointLight)
        mainLight.position = SIMD3<Float>(0, 10, 0)
        entity.addChild(mainLight)

        // Fill lights from corners
        let cornerPositions: [SIMD3<Float>] = [
            SIMD3<Float>(-8, 5, -8),
            SIMD3<Float>(8, 5, -8),
            SIMD3<Float>(-8, 5, 8),
            SIMD3<Float>(8, 5, 8)
        ]

        for position in cornerPositions {
            let fillLight = Entity()
            var light = PointLightComponent()
            light.intensity = 1000
            light.attenuationRadius = 15
            fillLight.components.set(light)
            fillLight.position = position
            entity.addChild(fillLight)
        }
    }

    private func handleTwinTap(_ entity: Entity) {
        // Find the twin container
        var current: Entity? = entity
        while let parent = current?.parent {
            if parent.name?.hasPrefix("Twin_") == true {
                // Extract twin ID and select it
                if let twinIdString = parent.name?.replacingOccurrences(of: "Twin_", with: ""),
                   let twinId = UUID(uuidString: twinIdString) {
                    selectTwin(withId: twinId)
                }
                return
            }
            current = parent
        }
    }

    private func selectTwin(withId id: UUID) {
        if let twin = twins.first(where: { $0.id == id }) {
            navigationState.selectedTwin = twin

            // Visual feedback - pulse the entity
            if let facilityRoot = facilityEntity,
               let twinEntity = facilityRoot.findEntity(named: "Twin_\(id)") {
                pulseEntity(twinEntity)
            }
        }
    }

    private func pulseEntity(_ entity: Entity) {
        // Simple scale animation for feedback
        let originalScale = entity.scale

        Task {
            entity.scale = originalScale * 1.2
            try? await Task.sleep(for: .milliseconds(150))
            entity.scale = originalScale
        }
    }

    private func updateFacilityVisualization() {
        guard let root = facilityEntity else { return }

        // Update each twin's visual based on current health
        for twin in twins {
            if let twinEntity = root.findEntity(named: "Twin_\(twin.id)"),
               let modelEntity = twinEntity.findEntity(named: "Model") as? ModelEntity {

                let color = UIColor(HealthThresholds.color(for: twin.healthScore))
                let material = SimpleMaterial(color: color, isMetallic: true)

                if var modelComponent = modelEntity.components[ModelComponent.self] {
                    modelComponent.materials = [material]
                    modelEntity.components[ModelComponent.self] = modelComponent
                }
            }
        }
    }
}
