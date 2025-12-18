import SwiftUI
import RealityKit

struct OperationsVolumeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OperationsVolumeViewModel()

    var body: some View {
        RealityView { content in
            // Create the operations scene
            let rootEntity = await viewModel.createOperationsScene()
            content.add(rootEntity)
        } update: { content in
            // Update scene with new data
            Task {
                await viewModel.updateScene(content: content)
            }
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    viewModel.handleDrag(value: value)
                }
        )
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    viewModel.handleTap(entity: value.entity)
                }
        )
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Operations Volume ViewModel
@Observable
class OperationsVolumeViewModel {
    var productionOrders: [ProductionOrder] = []
    var workCenters: [WorkCenter] = []
    var equipment: [Equipment] = []

    private var rootEntity: Entity?
    private var selectedEntity: Entity?

    func loadData() async {
        // Load production data
        // This would typically come from services
        try? await Task.sleep(for: .milliseconds(100))

        // Mock data
        productionOrders = [ProductionOrder.mock()]
        workCenters = [WorkCenter.mock()]
        equipment = [Equipment.mock()]
    }

    func createOperationsScene() async -> Entity {
        let root = Entity()

        // Create factory floor base
        let floor = createFactoryFloor()
        root.addChild(floor)

        // Create work centers
        let workCenterEntities = createWorkCenters()
        workCenterEntities.forEach { root.addChild($0) }

        // Create production lines
        let productionLines = createProductionLines()
        productionLines.forEach { root.addChild($0) }

        // Create equipment indicators
        let equipmentEntities = createEquipmentIndicators()
        equipmentEntities.forEach { root.addChild($0) }

        // Add particle systems for material flows
        let flowParticles = createMaterialFlows()
        flowParticles.forEach { root.addChild($0) }

        rootEntity = root
        return root
    }

    func updateScene(content: RealityViewContent) async {
        // Update visualizations based on real-time data
        // This would be called when data changes
    }

    // MARK: - Factory Floor
    private func createFactoryFloor() -> Entity {
        let floor = ModelEntity(
            mesh: .generatePlane(width: 1.5, depth: 1.5),
            materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.3), isMetallic: false)]
        )
        floor.position = [0, -0.6, 0]

        // Add grid lines
        let gridEntity = createGridLines(size: 1.5, spacing: 0.15)
        floor.addChild(gridEntity)

        return floor
    }

    private func createGridLines(size: Float, spacing: Float) -> Entity {
        let gridEntity = Entity()

        let lineCount = Int(size / spacing)
        let halfSize = size / 2

        for i in 0...lineCount {
            let offset = -halfSize + Float(i) * spacing

            // Horizontal lines
            let hLine = ModelEntity(
                mesh: .generateBox(width: size, height: 0.001, depth: 0.005),
                materials: [SimpleMaterial(color: .white.withAlphaComponent(0.2), isMetallic: false)]
            )
            hLine.position = [0, 0.001, offset]
            gridEntity.addChild(hLine)

            // Vertical lines
            let vLine = ModelEntity(
                mesh: .generateBox(width: 0.005, height: 0.001, depth: size),
                materials: [SimpleMaterial(color: .white.withAlphaComponent(0.2), isMetallic: false)]
            )
            vLine.position = [offset, 0.001, 0]
            gridEntity.addChild(vLine)
        }

        return gridEntity
    }

    // MARK: - Work Centers
    private func createWorkCenters() -> [Entity] {
        var entities: [Entity] = []

        let positions: [SIMD3<Float>] = [
            [-0.4, -0.2, -0.4],  // Work Center 1
            [0.4, -0.2, -0.4],   // Work Center 2
            [0.0, -0.2, 0.4]     // Work Center 3
        ]

        for (index, position) in positions.enumerated() {
            let workCenter = createWorkCenterEntity(index: index + 1, position: position)
            entities.append(workCenter)
        }

        return entities
    }

    private func createWorkCenterEntity(index: Int, position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.position = position

        // Create machine representation (simple box)
        let machine = ModelEntity(
            mesh: .generateBox(width: 0.15, height: 0.15, depth: 0.15),
            materials: [createPBRMaterial(color: .systemBlue)]
        )
        entity.addChild(machine)

        // Status indicator (colored sphere)
        let statusColor: UIColor = index == 1 ? .systemGreen : .systemYellow
        let statusIndicator = ModelEntity(
            mesh: .generateSphere(radius: 0.025),
            materials: [createGlowMaterial(color: statusColor)]
        )
        statusIndicator.position = [0, 0.1, 0]
        entity.addChild(statusIndicator)

        // Add label (floating text)
        let label = createTextLabel(text: "WC-\(index)", position: [0, 0.15, 0])
        entity.addChild(label)

        // Add interaction component
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(shapes: [.generateBox(width: 0.15, height: 0.15, depth: 0.15)]))

        // Store work center data
        entity.name = "WorkCenter-\(index)"

        return entity
    }

    // MARK: - Production Lines
    private func createProductionLines() -> [Entity] {
        var entities: [Entity] = []

        // Create conveyor belts connecting work centers
        let conveyor1 = createConveyorBelt(
            from: [-0.4, -0.3, -0.4],
            to: [0.4, -0.3, -0.4]
        )
        entities.append(conveyor1)

        let conveyor2 = createConveyorBelt(
            from: [0.4, -0.3, -0.4],
            to: [0.0, -0.3, 0.4]
        )
        entities.append(conveyor2)

        return entities
    }

    private func createConveyorBelt(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Entity {
        let entity = Entity()

        let distance = simd_distance(start, end)
        let midpoint = (start + end) / 2

        let conveyor = ModelEntity(
            mesh: .generateBox(width: 0.05, height: 0.02, depth: distance),
            materials: [SimpleMaterial(color: .darkGray, isMetallic: true)]
        )

        // Calculate rotation to align with direction
        let direction = normalize(end - start)
        let angle = atan2(direction.x, direction.z)
        conveyor.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])

        conveyor.position = midpoint
        entity.addChild(conveyor)

        return entity
    }

    // MARK: - Equipment Indicators
    private func createEquipmentIndicators() -> [Entity] {
        var entities: [Entity] = []

        // Create health indicators for equipment
        let positions: [SIMD3<Float>] = [
            [-0.4, 0, -0.4],
            [0.4, 0, -0.4],
            [0.0, 0, 0.4]
        ]

        for (index, position) in positions.enumerated() {
            let indicator = createHealthIndicator(
                health: index == 0 ? 0.88 : (index == 1 ? 0.75 : 0.92),
                position: position
            )
            entities.append(indicator)
        }

        return entities
    }

    private func createHealthIndicator(health: Double, position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.position = position

        // Circular health bar
        let color: UIColor = health > 0.85 ? .systemGreen : (health > 0.7 ? .systemYellow : .systemRed)

        let healthBar = ModelEntity(
            mesh: .generateBox(width: 0.1, height: 0.02, depth: 0.01),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        healthBar.position = [0, 0.12, 0]

        // Health percentage text
        let healthText = createTextLabel(
            text: "\(Int(health * 100))%",
            position: [0, 0.18, 0]
        )

        entity.addChild(healthBar)
        entity.addChild(healthText)

        return entity
    }

    // MARK: - Material Flows
    private func createMaterialFlows() -> [Entity] {
        var entities: [Entity] = []

        // Create particle systems to show material flowing through production
        let flow1 = createFlowParticles(
            from: [-0.4, -0.25, -0.4],
            to: [0.4, -0.25, -0.4],
            color: .systemBlue
        )
        entities.append(flow1)

        return entities
    }

    private func createFlowParticles(from start: SIMD3<Float>, to end: SIMD3<Float>, color: UIColor) -> Entity {
        let entity = Entity()
        entity.position = start

        // Create simple particle system using small spheres
        for i in 0..<10 {
            let progress = Float(i) / 10.0
            let position = start + (end - start) * progress

            let particle = ModelEntity(
                mesh: .generateSphere(radius: 0.01),
                materials: [createGlowMaterial(color: color)]
            )
            particle.position = position

            entity.addChild(particle)

            // Animate particle movement
            var transform = particle.transform
            transform.translation = end
            particle.move(to: transform, relativeTo: nil, duration: 2.0)
        }

        return entity
    }

    // MARK: - Helper Functions
    private func createPBRMaterial(color: UIColor) -> Material {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color)
        material.metallic = 0.5
        material.roughness = 0.3
        return material
    }

    private func createGlowMaterial(color: UIColor) -> Material {
        var material = UnlitMaterial()
        material.color = .init(tint: color)
        material.blending = .transparent(opacity: 0.8)
        return material
    }

    private func createTextLabel(text: String, position: SIMD3<Float>) -> Entity {
        let entity = Entity()
        entity.position = position

        // Create text mesh (simplified - actual implementation would use TextRenderer)
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.02),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let textEntity = ModelEntity(
            mesh: textMesh,
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )

        // Billboard component to always face user
        textEntity.components.set(BillboardComponent())

        entity.addChild(textEntity)
        return entity
    }

    // MARK: - Interaction Handlers
    func handleTap(entity: Entity) {
        selectedEntity = entity

        // Highlight selected entity
        if let modelEntity = entity as? ModelEntity {
            var material = SimpleMaterial()
            material.color = .init(tint: .systemYellow)
            modelEntity.model?.materials = [material]
        }

        print("Tapped: \(entity.name)")
    }

    func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
        // Handle rotation of the entire volume
        let entity = value.entity

        // Rotate based on drag
        let translation = value.convert(value.translation3D, from: .local, to: .scene)
        entity.position += translation
    }
}

#Preview {
    OperationsVolumeView()
        .environment(AppState())
}
