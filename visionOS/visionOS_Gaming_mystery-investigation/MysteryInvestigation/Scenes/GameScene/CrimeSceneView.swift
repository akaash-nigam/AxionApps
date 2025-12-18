import SwiftUI
import RealityKit
import ARKit

struct CrimeSceneView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gameCoordinator: GameCoordinator

    @StateObject private var spatialSceneManager = SpatialSceneManager()
    @StateObject private var handTracker = HandInteractionManager()

    @State private var showHUD = true
    @State private var selectedEvidence: Evidence?
    @State private var activeTool: ForensicToolType = .magnifyingGlass

    var body: some View {
        ZStack {
            // RealityKit 3D Scene
            RealityView { content in
                await setupScene(content)
            } update: { content in
                updateScene(content)
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        handleTap(on: value.entity)
                    }
            )

            // HUD Overlay
            if showHUD {
                CrimeSceneHUD(
                    evidenceCount: gameCoordinator.collectedEvidence.count,
                    totalEvidence: gameCoordinator.currentCase?.evidence.count ?? 0,
                    progress: gameCoordinator.investigationProgress,
                    activeTool: $activeTool
                )
            }
        }
        .task {
            await spatialSceneManager.setupARSession()
            await handTracker.startTracking()
        }
        .onDisappear {
            Task {
                await gameCoordinator.pauseCase()
            }
        }
    }

    // MARK: - Scene Setup

    @MainActor
    private func setupScene(_ content: RealityViewContent) async {
        guard let currentCase = gameCoordinator.currentCase else { return }

        // Create scene root
        let sceneAnchor = AnchorEntity(.head)
        content.add(sceneAnchor)

        // Place evidence in scene
        for evidence in currentCase.evidence {
            let evidenceEntity = createEvidenceEntity(evidence)
            sceneAnchor.addChild(evidenceEntity)
        }

        // Add environmental lighting
        setupLighting(in: sceneAnchor)
    }

    @MainActor
    private func updateScene(_ content: RealityViewContent) {
        // Update scene based on state changes
    }

    // MARK: - Evidence Entities

    private func createEvidenceEntity(_ evidence: Evidence) -> Entity {
        let entity = Entity()

        // Add model component
        if let mesh = createEvidenceMesh(for: evidence.type) {
            var modelComponent = ModelComponent(
                mesh: mesh,
                materials: [createEvidenceMaterial(for: evidence)]
            )
            entity.components[ModelComponent.self] = modelComponent
        }

        // Add collision for interaction
        let collisionShape = ShapeResource.generateBox(size: [0.1, 0.1, 0.1])
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [collisionShape],
            mode: .trigger
        )

        // Add custom evidence component
        entity.components[EvidenceComponent.self] = EvidenceComponent(
            evidenceData: evidence,
            interactionState: .undiscovered,
            highlightEnabled: false,
            collectionProgress: 0.0
        )

        // Set position
        entity.transform.translation = evidence.discoveryLocation.toSIMD()
        entity.transform.scale = SIMD3(repeating: evidence.scale)

        // Add name for identification
        entity.name = evidence.id.uuidString

        return entity
    }

    private func createEvidenceMesh(for type: Evidence.EvidenceType) -> MeshResource? {
        switch type {
        case .weapon:
            return MeshResource.generateBox(size: [0.05, 0.01, 0.2])
        case .document:
            return MeshResource.generatePlane(width: 0.15, depth: 0.2)
        case .biological, .trace:
            return MeshResource.generateSphere(radius: 0.02)
        case .fingerprint:
            return MeshResource.generatePlane(width: 0.05, depth: 0.05)
        case .personal:
            return MeshResource.generateBox(size: [0.08, 0.08, 0.08])
        default:
            return MeshResource.generateBox(size: [0.1, 0.1, 0.1])
        }
    }

    private func createEvidenceMaterial(for evidence: Evidence) -> Material {
        var material = SimpleMaterial()

        switch evidence.type {
        case .biological:
            material.color = .init(tint: .init(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0))
        case .weapon:
            material.color = .init(tint: .gray)
            material.metallic = .init(floatLiteral: 0.8)
        case .document:
            material.color = .init(tint: .init(white: 0.9, alpha: 1.0))
        default:
            material.color = .init(tint: .white)
        }

        material.roughness = .init(floatLiteral: 0.5)

        return material
    }

    // MARK: - Lighting

    private func setupLighting(in anchor: AnchorEntity) {
        // Directional light (like sunlight)
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1000
        directionalLight.light.color = .white
        directionalLight.transform.rotation = simd_quatf(
            angle: .pi / 4,
            axis: [1, -1, 0]
        )

        anchor.addChild(directionalLight)

        // Ambient light
        // Note: RealityKit uses image-based lighting via environment
    }

    // MARK: - Interaction

    private func handleTap(on entity: Entity) {
        guard let evidenceComponent = entity.components[EvidenceComponent.self] else {
            return
        }

        let evidence = evidenceComponent.evidenceData

        // Discover evidence if not already discovered
        if evidenceComponent.interactionState == .undiscovered {
            gameCoordinator.discoverEvidence(evidence)
            updateEvidenceState(entity, to: .discovered)
        }

        // Collect evidence
        if evidenceComponent.interactionState == .discovered {
            gameCoordinator.collectEvidence(evidence)
            updateEvidenceState(entity, to: .collected)
        }

        // Select for examination
        selectedEvidence = evidence
    }

    private func updateEvidenceState(_ entity: Entity, to state: EvidenceComponent.InteractionState) {
        guard var evidenceComponent = entity.components[EvidenceComponent.self] else {
            return
        }

        evidenceComponent.interactionState = state

        // Update visuals based on state
        switch state {
        case .discovered:
            evidenceComponent.highlightEnabled = true
            // Add glow effect
            if var modelComponent = entity.components[ModelComponent.self] {
                modelComponent.materials = modelComponent.materials.map { material in
                    var modified = material
                    if var simple = modified as? SimpleMaterial {
                        simple.emissiveColor = .init(color: .yellow, intensity: 0.3)
                        return simple
                    }
                    return modified
                }
                entity.components[ModelComponent.self] = modelComponent
            }

        case .collected:
            // Fade out or mark as collected
            evidenceComponent.highlightEnabled = false

        default:
            break
        }

        entity.components[EvidenceComponent.self] = evidenceComponent
    }
}

// MARK: - Evidence Component

struct EvidenceComponent: Component {
    var evidenceData: Evidence
    var interactionState: InteractionState
    var highlightEnabled: Bool
    var collectionProgress: Float

    enum InteractionState {
        case undiscovered
        case discovered
        case examining
        case collected
    }
}

// MARK: - Spatial Scene Manager

@MainActor
class SpatialSceneManager: ObservableObject {
    private var arSession = ARKitSession()
    private var worldTracking = WorldTrackingProvider()

    func setupARSession() async {
        // Request authorization
        let _ = await arSession.requestAuthorization(for: [.worldSensing])

        // Start session
        do {
            try await arSession.run([worldTracking])
            print("AR session started successfully")
        } catch {
            print("Failed to start AR session: \(error)")
        }
    }
}

// MARK: - Hand Interaction Manager

@MainActor
class HandInteractionManager: ObservableObject {
    @Published var leftHand: HandAnchor?
    @Published var rightHand: HandAnchor?
    @Published var currentGesture: HandGesture?

    private var handTracking = HandTrackingProvider()

    func startTracking() async {
        // Start hand tracking
        do {
            try await handTracking.run()

            // Monitor hand updates
            for await update in handTracking.anchorUpdates {
                switch update.anchor.chirality {
                case .left:
                    leftHand = update.anchor
                case .right:
                    rightHand = update.anchor
                }

                // Detect gestures
                detectGestures(update.anchor)
            }
        } catch {
            print("Failed to start hand tracking: \(error)")
        }
    }

    private func detectGestures(_ hand: HandAnchor) {
        // Implement gesture detection
        if isPinching(hand) {
            currentGesture = .pinch
        } else if isPointing(hand) {
            currentGesture = .point
        } else {
            currentGesture = nil
        }
    }

    private func isPinching(_ hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        let thumbTip = skeleton.joint(.thumbTip).anchorFromJointTransform.translation
        let indexTip = skeleton.joint(.indexFingerTip).anchorFromJointTransform.translation

        let distance = simd_distance(thumbTip, indexTip)
        return distance < 0.02  // 2cm threshold
    }

    private func isPointing(_ hand: HandAnchor) -> Bool {
        // Simplified pointing detection
        return false  // Implement full logic
    }
}

enum HandGesture {
    case pinch, point, grab, spread
}

// MARK: - Preview

#Preview {
    CrimeSceneView()
        .environmentObject(AppState())
        .environmentObject(GameCoordinator())
}
