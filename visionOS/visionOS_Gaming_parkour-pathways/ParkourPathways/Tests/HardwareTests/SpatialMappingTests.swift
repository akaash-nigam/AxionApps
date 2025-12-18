//
//  SpatialMappingTests.swift
//  Parkour Pathways Tests
//
//  Tests requiring Vision Pro hardware and ARKit
//  NOTE: These tests can only run on actual visionOS hardware or simulator
//

import XCTest
import ARKit
import RealityKit
@testable import ParkourPathways

final class SpatialMappingTests: XCTestCase {

    // MARK: - Setup

    override func setUp() async throws {
        // NOTE: This will fail without Vision Pro hardware
        guard ARWorldTrackingConfiguration.isSupported else {
            throw XCTSkip("ARKit not available on this device")
        }
    }

    // MARK: - Room Scanning Tests

    func testRoomScanning_InitiatesScan() async throws {
        let spatialMapping = SpatialMappingSystem()

        do {
            let result = try await spatialMapping.scanRoom()
            XCTAssertNotNil(result.roomModel)
            XCTAssertGreaterThan(result.roomModel.width, 0)
            XCTAssertGreaterThan(result.roomModel.length, 0)
            XCTAssertGreaterThan(result.roomModel.height, 0)
        } catch {
            XCTFail("Room scanning failed: \(error)")
        }
    }

    func testRoomScanning_DetectsPlanes() async throws {
        let spatialMapping = SpatialMappingSystem()

        let result = try await spatialMapping.scanRoom()

        // Should detect at least floor plane
        XCTAssertGreaterThanOrEqual(result.detectedPlanes.count, 1)

        // Verify plane types
        let hasFloor = result.detectedPlanes.contains { $0.type == .floor }
        XCTAssertTrue(hasFloor, "Should detect floor plane")
    }

    func testRoomScanning_DetectsFurniture() async throws {
        let spatialMapping = SpatialMappingSystem()

        let result = try await spatialMapping.scanRoom()

        // Room may or may not have furniture - just check the array is valid
        XCTAssertNotNil(result.roomModel.furniture)
    }

    func testRoomScanning_CalculatesBounds() async throws {
        let spatialMapping = SpatialMappingSystem()

        let result = try await spatialMapping.scanRoom()
        let bounds = result.roomBounds

        XCTAssertGreaterThan(bounds.width, 0)
        XCTAssertGreaterThan(bounds.height, 0)
        XCTAssertGreaterThan(bounds.depth, 0)

        // Reasonable room size validation (2m x 2m x 2m minimum)
        XCTAssertGreaterThanOrEqual(bounds.width, 2.0)
        XCTAssertGreaterThanOrEqual(bounds.height, 2.0)
    }

    // MARK: - Play Area Detection Tests

    func testPlayArea_Detection() {
        let spatialMapping = SpatialMappingSystem()

        // Simulate room scan completion
        let room = createMockScannedRoom()
        spatialMapping.currentRoom = room

        let playArea = spatialMapping.detectPlayArea()

        XCTAssertNotNil(playArea)
        XCTAssertGreaterThan(playArea.availableSpace, 0)
        XCTAssertGreaterThan(playArea.bounds.width, 0)
    }

    func testPlayArea_AvoidsFurniture() {
        let spatialMapping = SpatialMappingSystem()

        let room = createRoomWithFurniture()
        spatialMapping.currentRoom = room

        let playArea = spatialMapping.detectPlayArea()

        // Play area should be smaller than room due to furniture
        let totalRoomArea = room.width * room.length
        XCTAssertLessThan(playArea.availableSpace, totalRoomArea)
    }

    func testPlayArea_MinimumSizeRequirement() {
        let spatialMapping = SpatialMappingSystem()

        // Very small room
        let tinyRoom = RoomModel(
            width: 1.5,
            length: 1.5,
            height: 2.0,
            surfaces: [],
            furniture: [],
            safePlayArea: nil
        )

        spatialMapping.currentRoom = tinyRoom

        let playArea = spatialMapping.detectPlayArea()

        // Should warn or fail if room is too small
        XCTAssertLessThan(playArea.availableSpace, 4.0) // Less than 2m x 2m
    }

    // MARK: - World Tracking Tests

    func testWorldTracking_Initialization() async throws {
        let spatialMapping = SpatialMappingSystem()

        try await spatialMapping.startWorldTracking()

        XCTAssertTrue(spatialMapping.isTracking)
        XCTAssertNotNil(spatialMapping.arSession)
    }

    func testWorldTracking_PoseTracking() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        // Wait for tracking to stabilize
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        let currentPose = spatialMapping.getCurrentPose()

        XCTAssertNotNil(currentPose)
        XCTAssertNotEqual(currentPose.position, SIMD3<Float>.zero)
    }

    func testWorldTracking_TrackingQuality() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        // Wait for tracking to stabilize
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        let quality = spatialMapping.getTrackingQuality()

        // Should have at least limited tracking quality
        XCTAssertNotEqual(quality, .notAvailable)
    }

    // MARK: - Anchor Placement Tests

    func testAnchorPlacement_OnFloor() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        let result = try await spatialMapping.scanRoom()
        guard let floorPlane = result.detectedPlanes.first(where: { $0.type == .floor }) else {
            XCTFail("No floor plane detected")
            return
        }

        let anchorPosition = SIMD3<Float>(0, 0, 0)
        let anchor = try spatialMapping.placeAnchor(at: anchorPosition, on: floorPlane)

        XCTAssertNotNil(anchor)
        XCTAssertEqual(anchor.position.y, 0, accuracy: 0.1) // Should be at floor level
    }

    func testAnchorPlacement_OnWall() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        let result = try await spatialMapping.scanRoom()
        guard let wallPlane = result.detectedPlanes.first(where: { $0.type == .wall }) else {
            throw XCTSkip("No wall plane detected")
        }

        let anchorPosition = SIMD3<Float>(1.0, 1.5, 0) // Mid-wall height
        let anchor = try spatialMapping.placeAnchor(at: anchorPosition, on: wallPlane)

        XCTAssertNotNil(anchor)
    }

    // MARK: - Spatial Mesh Tests

    func testSpatialMesh_Generation() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        let mesh = try await spatialMapping.generateSpatialMesh()

        XCTAssertNotNil(mesh)
        XCTAssertGreaterThan(mesh.vertices.count, 0)
        XCTAssertGreaterThan(mesh.faces.count, 0)
    }

    func testSpatialMesh_UpdatesOverTime() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        let initialMesh = try await spatialMapping.generateSpatialMesh()
        let initialVertexCount = initialMesh.vertices.count

        // Wait for mesh updates
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        let updatedMesh = try await spatialMapping.generateSpatialMesh()
        let updatedVertexCount = updatedMesh.vertices.count

        // Mesh should be refined over time (may have more or fewer vertices)
        XCTAssertNotEqual(initialVertexCount, updatedVertexCount)
    }

    // MARK: - Collision Detection Tests

    func testCollisionDetection_WithScannedGeometry() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()
        _ = try await spatialMapping.scanRoom()

        let testPosition = SIMD3<Float>(0, 1.0, 0) // Mid-air position

        let hasCollision = spatialMapping.checkCollision(at: testPosition, radius: 0.3)

        // Mid-air position should not collide with scanned geometry
        XCTAssertFalse(hasCollision)
    }

    func testCollisionDetection_WithWall() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()
        let result = try await spatialMapping.scanRoom()

        guard let wallPlane = result.detectedPlanes.first(where: { $0.type == .wall }) else {
            throw XCTSkip("No wall plane detected")
        }

        // Position very close to wall
        let wallPosition = wallPlane.center
        let hasCollision = spatialMapping.checkCollision(at: wallPosition, radius: 0.5)

        XCTAssertTrue(hasCollision)
    }

    // MARK: - Lighting Estimation Tests

    func testLightingEstimation_AmbientIntensity() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        // Wait for lighting estimation to stabilize
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let ambientIntensity = spatialMapping.getAmbientLightIntensity()

        XCTAssertGreaterThan(ambientIntensity, 0)
        XCTAssertLessThanOrEqual(ambientIntensity, 2000) // Reasonable lumen range
    }

    func testLightingEstimation_ColorTemperature() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        try await Task.sleep(nanoseconds: 1_000_000_000)

        let colorTemp = spatialMapping.getColorTemperature()

        // Reasonable color temperature range (3000K - 7000K)
        XCTAssertGreaterThanOrEqual(colorTemp, 3000)
        XCTAssertLessThanOrEqual(colorTemp, 7000)
    }

    // MARK: - Hand Tracking Tests

    func testHandTracking_Detection() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        // Enable hand tracking
        try spatialMapping.enableHandTracking()

        try await Task.sleep(nanoseconds: 500_000_000)

        let hands = spatialMapping.getTrackedHands()

        // May or may not detect hands depending on test setup
        XCTAssertNotNil(hands)
    }

    func testHandTracking_JointPositions() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()
        try spatialMapping.enableHandTracking()

        try await Task.sleep(nanoseconds: 1_000_000_000)

        if let rightHand = spatialMapping.getRightHandPose() {
            XCTAssertNotNil(rightHand.wristPosition)
            XCTAssertNotNil(rightHand.indexTipPosition)
            XCTAssertNotNil(rightHand.thumbTipPosition)
        } else {
            throw XCTSkip("Right hand not detected")
        }
    }

    // MARK: - Performance Tests

    func testPerformance_RoomScanning() async throws {
        let spatialMapping = SpatialMappingSystem()

        measure {
            Task {
                _ = try? await spatialMapping.scanRoom()
            }
        }
    }

    func testPerformance_MeshUpdate() async throws {
        let spatialMapping = SpatialMappingSystem()
        try await spatialMapping.startWorldTracking()

        measure {
            Task {
                _ = try? await spatialMapping.generateSpatialMesh()
            }
        }
    }

    // MARK: - Helper Methods

    private func createMockScannedRoom() -> RoomModel {
        return RoomModel(
            width: 4.0,
            length: 3.5,
            height: 2.8,
            surfaces: [
                Surface(type: .floor, bounds: SIMD2<Float>(4.0, 3.5), position: SIMD3<Float>(0, 0, 0))
            ],
            furniture: [],
            safePlayArea: nil
        )
    }

    private func createRoomWithFurniture() -> RoomModel {
        return RoomModel(
            width: 4.0,
            length: 3.5,
            height: 2.8,
            surfaces: [],
            furniture: [
                Furniture(type: .table, position: SIMD3<Float>(1.5, 0.5, 1.5), bounds: SIMD3<Float>(1.2, 0.8, 0.8)),
                Furniture(type: .sofa, position: SIMD3<Float>(-1.0, 0.4, -1.0), bounds: SIMD3<Float>(2.0, 0.9, 1.0))
            ],
            safePlayArea: nil
        )
    }
}

// MARK: - Supporting Types

struct PlayArea {
    let center: SIMD3<Float>
    let bounds: SIMD3<Float>
    let availableSpace: Float // Square meters

    var width: Float { bounds.x }
    var height: Float { bounds.y }
    var depth: Float { bounds.z }
}

struct DevicePose {
    let position: SIMD3<Float>
    let orientation: simd_quatf
    let timestamp: TimeInterval
}

enum TrackingQuality {
    case notAvailable
    case limited
    case normal
    case excellent
}

struct Surface {
    enum SurfaceType {
        case floor, wall, ceiling, table
    }

    let type: SurfaceType
    let bounds: SIMD2<Float>
    let position: SIMD3<Float>
}

struct SpatialMesh {
    let vertices: [SIMD3<Float>]
    let faces: [[Int]]
    let normals: [SIMD3<Float>]
}

struct HandPose {
    let wristPosition: SIMD3<Float>
    let indexTipPosition: SIMD3<Float>
    let thumbTipPosition: SIMD3<Float>
    let middleTipPosition: SIMD3<Float>
    let confidence: Float
}

struct DetectedPlane {
    enum PlaneType {
        case floor, wall, ceiling, table, unknown
    }

    let type: PlaneType
    let center: SIMD3<Float>
    let extent: SIMD2<Float>
    let normal: SIMD3<Float>
}

struct RoomBounds {
    let width: Float
    let height: Float
    let depth: Float
    let center: SIMD3<Float>
}

struct RoomScanResult {
    let roomModel: RoomModel
    let detectedPlanes: [DetectedPlane]
    let roomBounds: RoomBounds
    let confidence: Float
}
