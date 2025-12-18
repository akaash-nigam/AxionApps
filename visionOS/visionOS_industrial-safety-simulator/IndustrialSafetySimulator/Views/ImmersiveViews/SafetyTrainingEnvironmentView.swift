import SwiftUI
import RealityKit

struct SafetyTrainingEnvironmentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var sceneState = SceneState()
    @State private var showExitPrompt = false
    @State private var sessionTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        RealityView { content in
            // Load and setup the training environment
            await setupTrainingEnvironment(content: content)
        } update: { content in
            // Update scene based on state changes
            updateScene(content: content)
        }
        .overlay(alignment: .top) {
            trainingOverlay
        }
        .overlay(alignment: .bottomTrailing) {
            controlsOverlay
        }
        .onReceive(timer) { _ in
            sessionTime += 1
        }
        .onAppear {
            startTrainingSession()
        }
        .alert("Exit Training?", isPresented: $showExitPrompt) {
            Button("Continue Training", role: .cancel) { }
            Button("Exit", role: .destructive) {
                exitTraining()
            }
        } message: {
            Text("Are you sure you want to exit? Your progress will be saved.")
        }
    }

    // MARK: - Overlay Views

    private var trainingOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(appState.currentSession?.module.title ?? "Training")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 16) {
                    Label("\(formatTime(sessionTime))", systemImage: "clock.fill")
                    Label("Score: \(Int(sceneState.currentScore))", systemImage: "star.fill")
                    Label("Hazards: \(sceneState.hazardsDetected)/\(sceneState.totalHazards)", systemImage: "exclamationmark.triangle.fill")
                }
                .font(.callout)
            }

            Spacer()
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(32)
    }

    private var controlsOverlay: some View {
        VStack(spacing: 12) {
            Button {
                // Pause scenario
                pauseTraining()
            } label: {
                Image(systemName: "pause.circle.fill")
                    .font(.title)
            }
            .buttonStyle(.borderless)

            Button {
                // Show hint
                showHint()
            } label: {
                Image(systemName: "lightbulb.fill")
                    .font(.title)
            }
            .buttonStyle(.borderless)

            Button {
                showExitPrompt = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(32)
    }

    // MARK: - RealityKit Setup

    @MainActor
    private func setupTrainingEnvironment(content: RealityViewContent) async {
        // Create root entity for the scene
        let rootEntity = Entity()
        content.add(rootEntity)

        // Load factory floor environment
        await loadEnvironment(root: rootEntity)

        // Setup hazards
        await setupHazards(root: rootEntity)

        // Setup safety zones
        await setupSafetyZones(root: rootEntity)

        // Initialize physics simulation
        setupPhysics(root: rootEntity)

        // Setup spatial audio
        setupAudio(root: rootEntity)

        // Store root entity in scene state
        sceneState.rootEntity = rootEntity
    }

    @MainActor
    private func loadEnvironment(root: Entity) async {
        // In a real implementation, this would load from Reality Composer Pro
        // For now, create a basic environment

        // Floor
        let floor = createFloor()
        root.addChild(floor)

        // Walls
        let walls = createWalls()
        walls.forEach { root.addChild($0) }

        // Equipment
        let equipment = await createEquipment()
        equipment.forEach { root.addChild($0) }

        // Lighting
        setupLighting(root: root)
    }

    @MainActor
    private func setupHazards(root: Entity) async {
        guard let session = appState.currentSession,
              let scenario = session.module.scenarios.first else {
            return
        }

        sceneState.totalHazards = scenario.hazards.count

        for hazard in scenario.hazards {
            let hazardEntity = createHazardEntity(for: hazard)
            root.addChild(hazardEntity)
            sceneState.hazardEntities.append(hazardEntity)
        }
    }

    @MainActor
    private func setupSafetyZones(root: Entity) async {
        // Create safe zones (green areas)
        let safeZone = createSafetyZone(at: SIMD3<Float>(0, 0, -3), radius: 2.0, type: .safe)
        root.addChild(safeZone)

        // Create danger zones (red areas)
        let dangerZone = createSafetyZone(at: SIMD3<Float>(5, 0, 0), radius: 3.0, type: .danger)
        root.addChild(dangerZone)
    }

    @MainActor
    private func setupPhysics(root: Entity) {
        // Enable physics simulation for realistic interactions
        // Gravity, collisions, etc.
    }

    @MainActor
    private func setupAudio(root: Entity) {
        // Setup spatial audio sources
        // Ambient factory sounds, warning beeps, etc.
    }

    @MainActor
    private func updateScene(content: RealityViewContent) {
        // Update scene based on user interactions and state changes
        updateHazardVisuals()
        updateScore()
    }

    // MARK: - Entity Creation Helpers

    @MainActor
    private func createFloor() -> Entity {
        let mesh = MeshResource.generatePlane(width: 20, depth: 20)
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0, 0)

        // Add physics collision
        entity.components.set(CollisionComponent(shapes: [.generateBox(size: [20, 0.1, 20])]))
        entity.components.set(PhysicsBodyComponent(mode: .static))

        return entity
    }

    @MainActor
    private func createWalls() -> [Entity] {
        var walls: [Entity] = []

        // Create 4 walls for factory floor
        let wallHeight: Float = 4.0
        let wallLength: Float = 20.0
        let wallThickness: Float = 0.5

        let mesh = MeshResource.generateBox(size: [wallLength, wallHeight, wallThickness])
        let material = SimpleMaterial(color: .lightGray, isMetallic: false)

        // Front wall
        let frontWall = ModelEntity(mesh: mesh, materials: [material])
        frontWall.position = SIMD3<Float>(0, wallHeight/2, -10)
        walls.append(frontWall)

        // Back wall
        let backWall = ModelEntity(mesh: mesh, materials: [material])
        backWall.position = SIMD3<Float>(0, wallHeight/2, 10)
        walls.append(backWall)

        return walls
    }

    @MainActor
    private func createEquipment() async -> [Entity] {
        var equipment: [Entity] = []

        // In production, load from Reality Composer Pro
        // For now, create simple placeholder equipment

        // Machinery placeholder
        let machineMesh = MeshResource.generateBox(size: [2, 1.5, 1])
        let machineMaterial = SimpleMaterial(color: .blue, isMetallic: true)
        let machine = ModelEntity(mesh: machineMesh, materials: [machineMaterial])
        machine.position = SIMD3<Float>(-5, 0.75, 0)
        equipment.append(machine)

        return equipment
    }

    @MainActor
    private func createHazardEntity(for hazard: Hazard) -> Entity {
        // Create visual representation of hazard
        let mesh = MeshResource.generateSphere(radius: hazard.radius)

        // Color based on severity
        let color: UIColor = {
            switch hazard.severity {
            case .low: return .yellow
            case .medium: return .orange
            case .high: return .red
            case .critical, .catastrophic: return .purple
            }
        }()

        var material = SimpleMaterial(color: color, isMetallic: false)
        material.color = .init(tint: color.withAlphaComponent(0.3))

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = hazard.location
        entity.name = "hazard_\(hazard.id)"

        // Add collision for detection
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: hazard.radius)]))

        // Add custom component
        entity.components.set(HazardComponent(
            hazardType: hazard.type,
            severity: hazard.severity,
            activationDistance: hazard.radius,
            isActive: true,
            visualEffect: .pulse
        ))

        return entity
    }

    @MainActor
    private func createSafetyZone(at position: SIMD3<Float>, radius: Float, type: ZoneType) -> Entity {
        let mesh = MeshResource.generateSphere(radius: radius)

        let color: UIColor = type == .safe ? .green : .red
        var material = SimpleMaterial(color: color, isMetallic: false)
        material.color = .init(tint: color.withAlphaComponent(0.2))

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = position

        return entity
    }

    @MainActor
    private func setupLighting(root: Entity) {
        // Add directional light
        let light = DirectionalLight()
        light.light.intensity = 1000
        light.look(at: [0, 0, 0], from: [5, 5, 5], relativeTo: nil)
        root.addChild(light)
    }

    // MARK: - Scene Updates

    private func updateHazardVisuals() {
        // Update hazard appearance based on proximity and detection
    }

    private func updateScore() {
        // Calculate and update current score
    }

    // MARK: - Actions

    private func startTrainingSession() {
        sceneState.sessionStartTime = Date()
    }

    private func pauseTraining() {
        // Pause the training session
        timer.upstream.connect().cancel()
    }

    private func showHint() {
        // Show hint to user
    }

    private func exitTraining() {
        Task {
            appState.endTrainingSession()
            await dismissImmersiveSpace()
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Scene State

@Observable
final class SceneState {
    var rootEntity: Entity?
    var hazardEntities: [Entity] = []
    var totalHazards: Int = 0
    var hazardsDetected: Int = 0
    var currentScore: Double = 0
    var sessionStartTime: Date?
}

// MARK: - Custom Components

struct HazardComponent: Component {
    var hazardType: HazardType
    var severity: SeverityLevel
    var activationDistance: Float
    var isActive: Bool
    var visualEffect: VisualEffectType
}

enum VisualEffectType {
    case pulse
    case glow
    case particles
}

enum ZoneType {
    case safe
    case danger
}

#Preview(immersionStyle: .progressive) {
    SafetyTrainingEnvironmentView()
        .environment(AppState())
}
