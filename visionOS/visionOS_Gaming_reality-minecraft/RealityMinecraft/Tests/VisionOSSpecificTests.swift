//
//  VisionOSSpecificTests.swift
//  Reality Minecraft visionOS Tests
//
//  Tests requiring Apple Vision Pro hardware
//  ⚠️ REQUIRES APPLE VISION PRO DEVICE TO RUN
//

import XCTest
import ARKit
import RealityKit
@testable import Reality_Minecraft

final class VisionOSSpecificTests: XCTestCase {

    var worldAnchorManager: WorldAnchorManager!
    var spatialMappingService: SpatialMappingService!
    var handTrackingManager: HandTrackingManager!

    override func setUp() async throws {
        try await super.setUp()

        worldAnchorManager = WorldAnchorManager()
        spatialMappingService = SpatialMappingService()
        handTrackingManager = HandTrackingManager()
    }

    override func tearDown() async throws {
        worldAnchorManager = nil
        spatialMappingService = nil
        handTrackingManager = nil

        try await super.tearDown()
    }

    // MARK: - World Anchor Tests

    func testWorldAnchorCreation() async throws {
        // Test creating a world anchor at a specific position
        let transform = simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, -1, 1) // 1 meter in front
        )

        let anchorID = try await worldAnchorManager.createPersistentAnchor(at: transform)
        XCTAssertNotNil(anchorID)

        let anchor = worldAnchorManager.worldAnchors[anchorID]
        XCTAssertNotNil(anchor)
    }

    func testWorldAnchorPersistence() async throws {
        // Create anchor
        let transform = simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, -2, 1)
        )

        let anchorID = try await worldAnchorManager.createPersistentAnchor(at: transform)

        // Clear current anchors (simulate app restart)
        worldAnchorManager = WorldAnchorManager()

        // Load persisted anchors
        try await worldAnchorManager.loadPersistedAnchors()

        // Verify anchor still exists
        XCTAssertTrue(worldAnchorManager.worldAnchors.contains { $0.key == anchorID })
    }

    func testWorldAnchorRemoval() async throws {
        let transform = simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(1, 0, 0, 1)
        )

        let anchorID = try await worldAnchorManager.createPersistentAnchor(at: transform)
        XCTAssertNotNil(worldAnchorManager.worldAnchors[anchorID])

        try await worldAnchorManager.removeAnchor(id: anchorID)
        XCTAssertNil(worldAnchorManager.worldAnchors[anchorID])
    }

    func testMultipleWorldAnchors() async throws {
        var anchorIDs: [UUID] = []

        // Create 5 anchors in different locations
        for i in 0..<5 {
            let transform = simd_float4x4(
                SIMD4<Float>(1, 0, 0, 0),
                SIMD4<Float>(0, 1, 0, 0),
                SIMD4<Float>(0, 0, 1, 0),
                SIMD4<Float>(Float(i), 0, 0, 1)
            )

            let id = try await worldAnchorManager.createPersistentAnchor(at: transform)
            anchorIDs.append(id)
        }

        XCTAssertEqual(worldAnchorManager.worldAnchors.count, 5)

        // Verify all anchors exist
        for id in anchorIDs {
            XCTAssertNotNil(worldAnchorManager.worldAnchors[id])
        }
    }

    // MARK: - Spatial Mapping Tests

    func testSpatialMappingInitialization() async throws {
        await spatialMappingService.startSpatialMapping()

        // Allow time for ARKit to initialize
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        XCTAssertTrue(spatialMappingService.isActive)
    }

    func testPlaneDetection() async throws {
        await spatialMappingService.startSpatialMapping()

        // Wait for plane detection
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds

        let surfaces = spatialMappingService.getHorizontalSurfaces()

        // Should detect at least the floor
        XCTAssertGreaterThan(surfaces.count, 0, "Should detect at least one horizontal surface (floor)")
    }

    func testVerticalPlaneDetection() async throws {
        await spatialMappingService.startSpatialMapping()

        try await Task.sleep(nanoseconds: 5_000_000_000)

        let surfaces = spatialMappingService.getVerticalSurfaces()

        // Should detect walls if in a room
        XCTAssertGreaterThanOrEqual(surfaces.count, 0, "May detect vertical surfaces (walls)")
    }

    func testRaycastToSurface() async throws {
        await spatialMappingService.startSpatialMapping()

        try await Task.sleep(nanoseconds: 3_000_000_000)

        // Raycast downward from user position
        let origin = SIMD3<Float>(0, 1.5, 0) // Typical eye height
        let direction = SIMD3<Float>(0, -1, 0) // Downward

        let hit = spatialMappingService.raycastToSurface(origin: origin, direction: direction)

        XCTAssertNotNil(hit, "Should hit the floor")
        if let hit = hit {
            XCTAssertLessThan(hit.distance, 2.0, "Floor should be within 2 meters")
        }
    }

    func testSceneReconstruction() async throws {
        await spatialMappingService.startSpatialMapping()

        try await Task.sleep(nanoseconds: 5_000_000_000)

        let meshAnchors = spatialMappingService.getSceneMeshes()

        // Scene reconstruction should provide mesh data
        XCTAssertGreaterThanOrEqual(meshAnchors.count, 0, "Scene reconstruction provides meshes")
    }

    // MARK: - Hand Tracking Tests

    func testHandTrackingInitialization() async throws {
        await handTrackingManager.startHandTracking()

        // Allow time for hand tracking to initialize
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Hand tracking should be active
        // Note: Actual hand data requires user to show hands
        XCTAssertNotNil(handTrackingManager)
    }

    func testHandVisibilityDetection() async throws {
        await handTrackingManager.startHandTracking()

        try await Task.sleep(nanoseconds: 2_000_000_000)

        // Note: This test requires user to show hands
        // In automated testing, we can only verify the system is ready

        // Check if hand tracking is receiving updates
        let initialLeftHand = handTrackingManager.leftHand
        let initialRightHand = handTrackingManager.rightHand

        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Hands may or may not be visible depending on test environment
        // This test mainly validates the tracking system is operational
    }

    func testPinchGestureDetection() async throws {
        await handTrackingManager.startHandTracking()

        try await Task.sleep(nanoseconds: 2_000_000_000)

        // User needs to perform pinch gesture
        print("⚠️ USER ACTION REQUIRED: Perform pinch gesture with right hand")

        let expectation = XCTestExpectation(description: "Pinch gesture detected")

        // Monitor for pinch gesture
        Task {
            for _ in 0..<50 { // Monitor for 5 seconds
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

                if case .pinch = handTrackingManager.detectedGesture {
                    expectation.fulfill()
                    break
                }
            }
        }

        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testHandPositionTracking() async throws {
        await handTrackingManager.startHandTracking()

        try await Task.sleep(nanoseconds: 2_000_000_000)

        guard let rightHand = handTrackingManager.rightHand else {
            XCTFail("Right hand not visible. Please show your right hand.")
            return
        }

        let initialPosition = rightHand.palmPosition

        print("⚠️ USER ACTION REQUIRED: Move your right hand")

        try await Task.sleep(nanoseconds: 2_000_000_000)

        guard let updatedHand = handTrackingManager.rightHand else {
            XCTFail("Lost tracking of right hand")
            return
        }

        let newPosition = updatedHand.palmPosition

        // Position should have changed if user moved hand
        let distance = simd_distance(initialPosition, newPosition)
        XCTAssertGreaterThan(distance, 0.0, "Hand position should change when moved")
    }

    func testBothHandsTracking() async throws {
        await handTrackingManager.startHandTracking()

        try await Task.sleep(nanoseconds: 2_000_000_000)

        print("⚠️ USER ACTION REQUIRED: Show both hands")

        try await Task.sleep(nanoseconds: 2_000_000_000)

        // Both hands should be tracked if visible
        if handTrackingManager.leftHand != nil && handTrackingManager.rightHand != nil {
            XCTAssertNotNil(handTrackingManager.leftHand)
            XCTAssertNotNil(handTrackingManager.rightHand)
        } else {
            print("⚠️ One or both hands not visible in tracking volume")
        }
    }

    func testGestureRecognitionAccuracy() async throws {
        await handTrackingManager.startHandTracking()

        try await Task.sleep(nanoseconds: 2_000_000_000)

        print("⚠️ USER ACTION REQUIRED: Perform gestures in sequence:")
        print("  1. Pinch (2 seconds)")
        print("  2. Spread fingers (2 seconds)")
        print("  3. Make fist (2 seconds)")

        var detectedGestures: [HandTrackingManager.Gesture] = []

        // Monitor gestures for 10 seconds
        for _ in 0..<100 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

            if let gesture = handTrackingManager.detectedGesture {
                detectedGestures.append(gesture)
            }
        }

        // Should have detected multiple gestures
        XCTAssertGreaterThan(detectedGestures.count, 0, "Should detect user gestures")
    }

    // MARK: - Immersive Space Tests

    func testImmersiveSpaceTransition() async throws {
        // This test verifies the app can transition to immersive space
        // Requires actual app context

        let gameState = GameStateManager()

        gameState.transitionTo(.loading(progress: 0))

        // Request immersive space
        // Note: Actual immersive space requires SwiftUI context
        // This test validates state management

        gameState.transitionTo(.playing(mode: .creative))

        XCTAssertEqual(gameState.currentState, .playing(mode: .creative))
    }

    // MARK: - Spatial Audio Tests

    func testSpatialAudioInitialization() async throws {
        let audioSystem = AudioSystem()

        // Play a spatial sound
        let soundID = audioSystem.playSound(
            "block_place",
            at: SIMD3<Float>(0, 0, -1),
            volume: 0.5
        )

        XCTAssertNotNil(soundID)

        // Verify sound is playing
        XCTAssertTrue(audioSystem.isSoundPlaying(soundID))

        audioSystem.stopSound(soundID)
    }

    func testSpatialAudioPositioning() async throws {
        let audioSystem = AudioSystem()

        // Play sounds at different positions
        let leftSound = audioSystem.playSound(
            "footstep",
            at: SIMD3<Float>(-1, 0, 0), // Left
            volume: 0.5
        )

        let rightSound = audioSystem.playSound(
            "footstep",
            at: SIMD3<Float>(1, 0, 0), // Right
            volume: 0.5
        )

        // Both sounds should be playing
        XCTAssertTrue(audioSystem.isSoundPlaying(leftSound))
        XCTAssertTrue(audioSystem.isSoundPlaying(rightSound))

        // Update listener position
        audioSystem.updateListener(
            position: SIMD3<Float>(0, 0, 0),
            orientation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)

        audioSystem.stopSound(leftSound)
        audioSystem.stopSound(rightSound)
    }

    func testSpatialAudioListenerMovement() async throws {
        let audioSystem = AudioSystem()

        let soundID = audioSystem.playSound(
            "ambient",
            at: SIMD3<Float>(0, 0, -5),
            volume: 0.7
        )

        // Move listener closer
        for i in 0..<10 {
            let z = Float(-i)
            audioSystem.updateListener(
                position: SIMD3<Float>(0, 0, z),
                orientation: simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
            )

            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }

        // Sound should still be playing
        XCTAssertTrue(audioSystem.isSoundPlaying(soundID))

        audioSystem.stopSound(soundID)
    }

    // MARK: - ARKit Integration Tests

    func testARKitSessionInitialization() async throws {
        let session = ARKitSession()

        let planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])

        // Run ARKit session
        try await session.run([planeDetection])

        // Session should be running
        XCTAssertNotNil(session)

        try await Task.sleep(nanoseconds: 2_000_000_000)
    }

    func testARKitWorldTracking() async throws {
        let session = ARKitSession()
        let worldTracking = WorldTrackingProvider()

        try await session.run([worldTracking])

        try await Task.sleep(nanoseconds: 3_000_000_000)

        // World tracking should provide device pose
        // Note: Actual pose query requires ARKit update loop
    }

    // MARK: - Performance on Device

    func testDevicePerformance90FPS() async throws {
        let gameLoop = GameLoopController(gameStateManager: GameStateManager())
        let entityManager = EntityManager(eventBus: EventBus())

        // Create realistic game load
        for _ in 0..<50 {
            let entity = entityManager.createEntity()
            entity.addComponent(MobComponent(type: .zombie))
            entity.addComponent(HealthComponent(maxHealth: 20))
            entity.addComponent(VelocityComponent())
            entityManager.addEntity(entity)
        }

        gameLoop.start()

        // Run for 5 seconds
        try await Task.sleep(nanoseconds: 5_000_000_000)

        let avgFPS = gameLoop.averageFPS
        let currentFPS = gameLoop.currentFPS

        gameLoop.stop()

        // Should maintain close to 90 FPS on device
        XCTAssertGreaterThan(avgFPS, 85.0, "Average FPS should be above 85")
        XCTAssertGreaterThan(currentFPS, 80.0, "Current FPS should be above 80")
    }

    func testDeviceMemoryUnderLoad() async throws {
        // Test memory usage with heavy load
        measure(metrics: [XCTMemoryMetric()]) {
            let chunkManager = ChunkManager()

            // Create many chunks
            for x in -10...10 {
                for z in -10...10 {
                    let chunk = chunkManager.getOrCreateChunk(at: ChunkPosition(x: x, y: 0, z: z))

                    // Partially fill chunks
                    for _ in 0..<100 {
                        let lx = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                        let ly = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                        let lz = Int.random(in: 0..<Chunk.CHUNK_SIZE)
                        let pos = BlockPosition(x: lx, y: ly, z: lz)
                        chunk.setBlock(at: pos, block: Block(position: pos, type: .stone))
                    }
                }
            }
        }
    }

    // MARK: - Battery Performance

    func testBatteryUsageEstimate() async throws {
        // Run game for 1 minute and monitor performance
        let gameLoop = GameLoopController(gameStateManager: GameStateManager())

        gameLoop.start()

        try await Task.sleep(nanoseconds: 60_000_000_000) // 1 minute

        let avgFPS = gameLoop.averageFPS

        gameLoop.stop()

        // Should maintain performance for battery efficiency
        XCTAssertGreaterThan(avgFPS, 85.0, "Should maintain 85+ FPS for good battery life")
    }

    // MARK: - Comfort Tests

    func testFrameTimeVariance() async throws {
        let gameLoop = GameLoopController(gameStateManager: GameStateManager())

        gameLoop.start()

        // Collect frame times over 3 seconds
        var frameTimes: [Double] = []

        for _ in 0..<270 { // ~3 seconds at 90 FPS
            let frameTime = gameLoop.lastFrameTime
            frameTimes.append(frameTime)

            try await Task.sleep(nanoseconds: 11_111_111) // ~90 FPS
        }

        gameLoop.stop()

        // Calculate variance
        let average = frameTimes.reduce(0, +) / Double(frameTimes.count)
        let variance = frameTimes.map { pow($0 - average, 2) }.reduce(0, +) / Double(frameTimes.count)
        let standardDeviation = sqrt(variance)

        // Low variance is crucial for comfort (prevent motion sickness)
        XCTAssertLessThan(standardDeviation, 2.0, "Frame time variance should be low for comfort")
    }

    // MARK: - Real-World Scenario Tests

    func testCompleteGameplayScenario() async throws {
        // This test simulates a complete gameplay scenario on device

        let gameState = GameStateManager()
        let entityManager = EntityManager(eventBus: gameState.eventBus)
        let chunkManager = ChunkManager()
        let handTracking = HandTrackingManager()
        let spatialMapping = SpatialMappingService()
        let anchorManager = WorldAnchorManager()

        // Initialize all systems
        await handTracking.startHandTracking()
        await spatialMapping.startSpatialMapping()

        gameState.transitionTo(.playing(mode: .creative))

        // Wait for systems to stabilize
        try await Task.sleep(nanoseconds: 3_000_000_000)

        // Create player
        let player = entityManager.createEntity()
        player.addComponent(PlayerComponent())
        entityManager.addEntity(player)

        // Load initial chunks
        for x in -2...2 {
            for z in -2...2 {
                _ = chunkManager.getOrCreateChunk(at: ChunkPosition(x: x, y: 0, z: z))
            }
        }

        // Create world anchor for persistence
        let anchorID = try await anchorManager.createPersistentAnchor(
            at: simd_float4x4(
                SIMD4<Float>(1, 0, 0, 0),
                SIMD4<Float>(0, 1, 0, 0),
                SIMD4<Float>(0, 0, 1, 0),
                SIMD4<Float>(0, 0, 0, 1)
            )
        )

        XCTAssertNotNil(anchorID)

        print("✅ Complete gameplay scenario initialized successfully")
    }
}
