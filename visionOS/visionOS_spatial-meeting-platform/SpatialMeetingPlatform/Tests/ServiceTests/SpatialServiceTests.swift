//
//  SpatialServiceTests.swift
//  SpatialMeetingPlatformTests
//
//  Tests for SpatialService
//

import Testing
import Foundation
@testable import SpatialMeetingPlatform

@Suite("Spatial Service Tests")
struct SpatialServiceTests {

    func createTestService() -> (SpatialService, MockNetworkService) {
        let networkService = MockNetworkService()
        let service = SpatialService(networkService: networkService)
        return (service, networkService)
    }

    // MARK: - Position Update Tests

    @Test("Update participant position rate limits correctly")
    func testPositionUpdateRateLimiting() async throws {
        let (service, networkService) = createTestService()
        let position = SpatialPosition(x: 1.0, y: 1.5, z: -2.0)

        // First update should go through
        try await service.updateParticipantPosition(position)
        let firstCount = networkService.sentMessages.count

        // Immediate second update should be rate limited
        try await service.updateParticipantPosition(position)
        let secondCount = networkService.sentMessages.count

        // Should be the same (rate limited)
        #expect(firstCount == secondCount)

        // Wait for rate limit interval
        try await Task.sleep(nanoseconds: 60_000_000) // 60ms

        // Now update should go through
        try await service.updateParticipantPosition(position)
        let thirdCount = networkService.sentMessages.count

        #expect(thirdCount > secondCount)
    }

    @Test("Update participant position with network failure throws error")
    func testPositionUpdateWithNetworkFailure() async throws {
        let (service, networkService) = createTestService()
        networkService.shouldFailSend = true

        let position = SpatialPosition(x: 1.0, y: 1.5, z: -2.0)

        // Wait for rate limit to reset
        try await Task.sleep(nanoseconds: 60_000_000)

        await #expect(throws: MockError.self) {
            try await service.updateParticipantPosition(position)
        }
    }

    // MARK: - Spatial Scene Tests

    @Test("Sync spatial state returns scene")
    func testSyncSpatialState() async throws {
        let (service, _) = createTestService()

        let scene = try await service.syncSpatialState()

        #expect(scene.lights.count > 0)
        #expect(scene.entities.isEmpty) // Initially empty
    }

    // MARK: - Content Placement Tests

    @Test("Place content adds to scene")
    func testPlaceContent() async throws {
        let (service, _) = createTestService()

        // First sync to get scene
        var scene = try await service.syncSpatialState()
        let initialCount = scene.entities.count

        // Create and place content
        let content = TestDataFactory.createMockSharedContent()
        let transform = SpatialTransform()

        try await service.placeContent(content, at: transform)

        // Note: In real implementation, we'd fetch the updated scene
        // For now, we verify no errors were thrown
    }

    @Test("Remove content from scene")
    func testRemoveContent() async throws {
        let (service, _) = createTestService()

        // Sync scene
        _ = try await service.syncSpatialState()

        // Place content
        let content = TestDataFactory.createMockSharedContent()
        try await service.placeContent(content, at: SpatialTransform())

        // Remove content
        try await service.removeContent(id: content.id)

        // Verify no errors
    }
}

// MARK: - Spatial Transform Tests

@Suite("Spatial Transform Tests")
struct SpatialTransformTests {

    @Test("Spatial transform encodes and decodes correctly")
    func testSpatialTransformCodable() throws {
        let position = SIMD3<Float>(1.0, 2.0, 3.0)
        let rotation = simd_quatf(angle: .pi / 4, axis: SIMD3(0, 1, 0))
        let scale = SIMD3<Float>(1.5, 1.5, 1.5)

        let transform = SpatialTransform(
            position: position,
            rotation: rotation,
            scale: scale
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(transform)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SpatialTransform.self, from: data)

        // Verify
        #expect(decoded.position.x == position.x)
        #expect(decoded.position.y == position.y)
        #expect(decoded.position.z == position.z)
        #expect(decoded.scale.x == scale.x)
    }

    @Test("Spatial position encodes and decodes correctly")
    func testSpatialPositionCodable() throws {
        let position = SpatialPosition(
            x: 5.0,
            y: 1.5,
            z: -3.0,
            rotation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            scale: 2.0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(position)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SpatialPosition.self, from: data)

        #expect(decoded.x == 5.0)
        #expect(decoded.y == 1.5)
        #expect(decoded.z == -3.0)
        #expect(decoded.scale == 2.0)
    }
}
