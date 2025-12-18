import SwiftUI
import RealityKit
import SwiftData

struct InnovationUniverseView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \\InnovationIdea.createdDate, order: .reverse)
    private var ideas: [InnovationIdea]

    @State private var selectedZone: UniverseZone = .ideaGalaxy
    @State private var selectedIdea: InnovationIdea?

    var body: some View {
        RealityView { content in
            await setupInnovationUniverse(content: content)
        } update: { content in
            updateUniverse(content: content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            zoneSelector
        }
        .overlay(alignment: .bottomTrailing) {
            controlPanel
        }
    }

    // MARK: - Zone Selector
    private var zoneSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Innovation Universe")
                .font(.title)
                .fontWeight(.bold)

            Picker("Zone", selection: $selectedZone) {
                ForEach(UniverseZone.allCases) { zone in
                    Label(zone.title, systemImage: zone.icon)
                        .tag(zone)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    // MARK: - Control Panel
    private var controlPanel: some View {
        VStack(spacing: 12) {
            Button {
                createNewIdeaNode()
            } label: {
                Label("New Idea", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.bordered)

            Button {
                togglePrototypeWorkshop()
            } label: {
                Label("Workshop", systemImage: "hammer.fill")
            }
            .buttonStyle(.bordered)

            Button {
                showAnalytics()
            } label: {
                Label("Analytics", systemImage: "chart.bar.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    // MARK: - Setup Innovation Universe
    @MainActor
    private func setupInnovationUniverse(content: RealityViewContent) async {
        // Create root entity
        let rootEntity = Entity()
        content.add(rootEntity)

        // Setup Idea Galaxy
        await setupIdeaGalaxy(parent: rootEntity)

        // Setup Prototype Workshop
        await setupPrototypeWorkshop(parent: rootEntity, position: [2, 0, -1])

        // Setup Analytics Observatory
        await setupAnalyticsObservatory(parent: rootEntity, position: [-2, 0, -1])

        // Setup Collaboration Zone
        await setupCollaborationZone(parent: rootEntity, position: [0, 0, -3])

        // Add ambient lighting
        addAmbientLighting(to: rootEntity)
    }

    @MainActor
    private func setupIdeaGalaxy(parent: Entity) async {
        // Create idea nodes for each idea
        for (index, idea) in ideas.prefix(20).enumerated() {
            let nodeEntity = await createIdeaNode(for: idea, index: index)
            parent.addChild(nodeEntity)
        }
    }

    @MainActor
    private func createIdeaNode(for idea: InnovationIdea, index: Int) async -> Entity {
        let entity = Entity()

        // Create sphere mesh
        let radius: Float = 0.05 + Float(idea.priority) * 0.01
        let mesh = MeshResource.generateSphere(radius: radius)

        // Create material with category color
        var material = UnlitMaterial()
        material.color = .init(tint: categoryColor(for: idea.category))

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Add collision for interaction
        entity.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: radius)],
            isStatic: true
        ))

        // Position in galaxy pattern (spiral)
        let angle = Float(index) * 0.5
        let distance: Float = 1.0 + Float(index) * 0.1
        let x = cos(angle) * distance
        let z = sin(angle) * distance
        let y = Float.random(in: -0.3...0.3)

        entity.position = [x, y, -2 + z]

        // Add gentle floating animation
        entity.components.set(HoverComponent())

        // Store idea ID in custom component
        entity.components.set(IdeaNodeComponent(
            ideaID: idea.id,
            glowIntensity: Float(idea.estimatedImpact),
            connectionCount: idea.prototypes.count
        ))

        return entity
    }

    @MainActor
    private func setupPrototypeWorkshop(parent: Entity, position: SIMD3<Float>) async {
        let workshop = Entity()
        workshop.position = position

        // Create workbench platform
        let platformMesh = MeshResource.generateBox(size: [0.8, 0.05, 0.8])
        var platformMaterial = SimpleMaterial()
        platformMaterial.color = .init(tint: .gray.withAlphaComponent(0.3))

        let platform = Entity()
        platform.components.set(ModelComponent(mesh: platformMesh, materials: [platformMaterial]))
        platform.position = [0, -0.5, 0]

        workshop.addChild(platform)
        parent.addChild(workshop)
    }

    @MainActor
    private func setupAnalyticsObservatory(parent: Entity, position: SIMD3<Float>) async {
        let observatory = Entity()
        observatory.position = position

        // Create 3D bar chart visualization
        let totalIdeas = ideas.count
        if totalIdeas > 0 {
            let barHeight = Float(totalIdeas) * 0.02
            let barMesh = MeshResource.generateBox(size: [0.1, barHeight, 0.1])
            var barMaterial = UnlitMaterial()
            barMaterial.color = .init(tint: .blue.withAlphaComponent(0.8))

            let bar = Entity()
            bar.components.set(ModelComponent(mesh: barMesh, materials: [barMaterial]))
            bar.position = [0, barHeight / 2, 0]

            observatory.addChild(bar)
        }

        parent.addChild(observatory)
    }

    @MainActor
    private func setupCollaborationZone(parent: Entity, position: SIMD3<Float>) async {
        let zone = Entity()
        zone.position = position

        // Create collaboration platform
        let platformMesh = MeshResource.generateBox(size: [1.5, 0.05, 1.5])
        var platformMaterial = SimpleMaterial()
        platformMaterial.color = .init(tint: .purple.withAlphaComponent(0.2))

        let platform = Entity()
        platform.components.set(ModelComponent(mesh: platformMesh, materials: [platformMaterial]))

        zone.addChild(platform)
        parent.addChild(zone)
    }

    @MainActor
    private func addAmbientLighting(to entity: Entity) {
        // Add point light for ambient illumination
        var pointLight = PointLightComponent(color: .white, intensity: 1000, attenuationRadius: 10)
        let lightEntity = Entity()
        lightEntity.components.set(pointLight)
        lightEntity.position = [0, 2, 0]

        entity.addChild(lightEntity)
    }

    private func updateUniverse(content: RealityViewContent) {
        // Update universe based on selected zone
        // In production, animate transitions between zones
    }

    // MARK: - Interaction Handlers
    private func handleEntityTap(_ entity: Entity) {
        // Check if entity has IdeaNodeComponent
        if let ideaNode = entity.components[IdeaNodeComponent.self] {
            // Find and select the idea
            if let idea = ideas.first(where: { $0.id == ideaNode.ideaID }) {
                selectedIdea = idea
                // Animate entity
                animateSelection(entity)
            }
        }
    }

    private func animateSelection(_ entity: Entity) {
        // Scale up animation
        var transform = entity.transform
        transform.scale = SIMD3<Float>(repeating: 1.2)

        entity.move(to: transform, relativeTo: entity.parent, duration: 0.2)
    }

    private func createNewIdeaNode() {
        // Open idea capture
        appState.showingIdeaCapture = true
    }

    private func togglePrototypeWorkshop() {
        appState.showingPrototypeWorkshop.toggle()
    }

    private func showAnalytics() {
        appState.showingAnalytics = true
    }

    // MARK: - Helper Methods
    private func categoryColor(for category: IdeaCategory) -> UIColor {
        switch category {
        case .product: return .systemBlue
        case .service: return .systemPurple
        case .process: return .systemGreen
        case .technology: return .systemOrange
        case .businessModel: return .systemPink
        }
    }
}

// MARK: - Universe Zone
enum UniverseZone: String, CaseIterable, Identifiable {
    case ideaGalaxy
    case prototypeWorkshop
    case analyticsObservatory
    case collaborationZone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ideaGalaxy: return "Idea Galaxy"
        case .prototypeWorkshop: return "Prototype Workshop"
        case .analyticsObservatory: return "Analytics Observatory"
        case .collaborationZone: return "Collaboration Zone"
        }
    }

    var icon: String {
        switch self {
        case .ideaGalaxy: return "sparkles"
        case .prototypeWorkshop: return "hammer.fill"
        case .analyticsObservatory: return "chart.bar.3d"
        case .collaborationZone: return "person.3.fill"
        }
    }
}

// MARK: - Custom RealityKit Components
struct IdeaNodeComponent: Component {
    let ideaID: UUID
    var glowIntensity: Float
    var connectionCount: Int
}

struct HoverComponent: Component {
    // Component for hover animation
}

#Preview(immersionStyle: .progressive) {
    InnovationUniverseView()
        .environment(AppState())
}
