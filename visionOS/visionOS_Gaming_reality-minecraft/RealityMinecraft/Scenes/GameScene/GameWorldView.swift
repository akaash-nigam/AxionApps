//
//  GameWorldView.swift
//  Reality Minecraft
//
//  Main immersive game world view
//

import SwiftUI
import RealityKit

struct GameWorldView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var gameStateManager: GameStateManager

    @StateObject private var gameCoordinator = GameCoordinator()

    var body: some View {
        RealityView { content in
            // Setup RealityKit content
            await setupGameWorld(content: content)
        } update: { content in
            // Update content when state changes
        }
        .task {
            // Initialize game systems
            await gameCoordinator.initialize(
                appModel: appModel,
                gameStateManager: gameStateManager
            )
        }
        .onDisappear {
            // Cleanup
            Task {
                await gameCoordinator.shutdown()
            }
        }
        .overlay(alignment: .bottom) {
            // HUD Overlay
            if case .playing = gameStateManager.currentState {
                GameHUDView()
                    .environmentObject(gameCoordinator)
            }
        }
    }

    private func setupGameWorld(content: RealityViewContent) async {
        // Create root entity
        let rootEntity = Entity()
        content.add(rootEntity)

        // Setup world anchors
        await gameCoordinator.setupWorldAnchors(rootEntity: rootEntity)

        // Setup lighting
        setupLighting(rootEntity: rootEntity)

        // Load chunks
        await gameCoordinator.loadInitialChunks()
    }

    private func setupLighting(rootEntity: Entity) {
        // Add directional light (sun)
        let sunLight = DirectionalLight()
        sunLight.light.color = .white
        sunLight.light.intensity = 1000

        let lightEntity = Entity()
        lightEntity.components[DirectionalLightComponent.self] = sunLight.light
        lightEntity.position = SIMD3<Float>(0, 10, 0)
        lightEntity.look(at: SIMD3<Float>(0, 0, 0), from: lightEntity.position, relativeTo: nil)

        rootEntity.addChild(lightEntity)
    }
}

// MARK: - Game Coordinator

/// Coordinates all game systems in the immersive space
@MainActor
class GameCoordinator: ObservableObject {
    // Core systems
    private var gameLoopController: GameLoopController?
    private var entityManager: EntityManager?
    private var chunkManager: ChunkManager?
    private var worldAnchorManager: WorldAnchorManager?
    private var spatialMappingService: SpatialMappingService?
    private var inputSystem: InputSystem?
    private var physicsSystem: PhysicsSystem?
    private var audioSystem: AudioSystem?

    // Published state
    @Published var isInitialized: Bool = false
    @Published var loadingProgress: Float = 0.0

    /// Initialize all game systems
    func initialize(appModel: AppModel, gameStateManager: GameStateManager) async {
        print("🎮 Initializing game coordinator...")

        loadingProgress = 0.1

        // Create event bus
        let eventBus = gameStateManager.eventBus

        // Initialize managers
        entityManager = EntityManager(eventBus: eventBus)
        chunkManager = ChunkManager()
        worldAnchorManager = WorldAnchorManager()
        spatialMappingService = SpatialMappingService()
        inputSystem = InputSystem(eventBus: eventBus)
        physicsSystem = PhysicsSystem()
        audioSystem = AudioSystem()

        loadingProgress = 0.3

        // Initialize game loop
        gameLoopController = GameLoopController(gameStateManager: gameStateManager)

        loadingProgress = 0.5

        // Register systems with game loop
        if let gameLoop = gameLoopController,
           let entityMgr = entityManager,
           let physics = physicsSystem,
           let input = inputSystem,
           let audio = audioSystem {

            gameLoop.registerSystems(
                entityManager: entityMgr,
                physicsSystem: physics,
                inputSystem: input,
                audioSystem: audio
            )
        }

        loadingProgress = 0.7

        // Start spatial mapping
        await spatialMappingService?.startSpatialMapping()

        // Start input system
        await inputSystem?.start()

        loadingProgress = 0.9

        // Start game loop
        gameLoopController?.start()

        loadingProgress = 1.0
        isInitialized = true

        print("✅ Game coordinator initialized")
    }

    /// Setup world anchors in the scene
    func setupWorldAnchors(rootEntity: Entity) async {
        guard let anchorManager = worldAnchorManager else { return }

        // Load persisted anchors
        try? await anchorManager.loadPersistedAnchors()

        // If no anchors exist, create a default one
        if anchorManager.getAllAnchorIDs().isEmpty {
            let playerPosition = SIMD3<Float>(0, 0, -2) // 2m in front
            try? await anchorManager.createAnchorAtPlayer(playerPosition: playerPosition)
        }

        // Add anchor entities to scene
        for anchorID in anchorManager.getAllAnchorIDs() {
            if let anchorEntity = anchorManager.getAnchorEntity(for: anchorID) {
                rootEntity.addChild(anchorEntity)
            }
        }
    }

    /// Load initial chunks around player
    func loadInitialChunks() async {
        guard let chunkMgr = chunkManager else { return }

        // Load chunks around origin
        for x in -2...2 {
            for z in -2...2 {
                let chunkPos = ChunkPosition(x: x, y: 0, z: z)
                let chunk = chunkMgr.getOrCreateChunk(at: chunkPos)

                // Fill with test pattern
                chunk.fillWithPattern()
            }
        }

        print("✅ Loaded initial chunks")
    }

    /// Shutdown and cleanup
    func shutdown() async {
        gameLoopController?.stop()
        await inputSystem?.stop()
        await spatialMappingService?.stopSpatialMapping()

        print("⏹ Game coordinator shutdown")
    }
}
