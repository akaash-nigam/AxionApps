//
//  SpatialService.swift
//  SpatialMeetingPlatform
//
//  Spatial positioning and synchronization service
//

import Foundation
import Observation

@Observable
class SpatialService: SpatialServiceProtocol {

    // MARK: - Properties

    private let networkService: NetworkServiceProtocol
    private var spatialScene: SpatialScene?

    // Rate limiting for position updates
    private var lastSyncTime: Date = .distantPast
    private let minSyncInterval: TimeInterval = 0.05 // 20 Hz max

    // MARK: - Initialization

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - SpatialServiceProtocol

    func updateParticipantPosition(_ position: SpatialPosition) async throws {
        // Rate limit updates
        let now = Date()
        guard now.timeIntervalSince(lastSyncTime) >= minSyncInterval else {
            return
        }
        lastSyncTime = now

        // In real implementation: Send position update via network
        print("Updating participant position: \(position.x), \(position.y), \(position.z)")

        // Placeholder: Would send PositionUpdate message via WebSocket
    }

    func syncSpatialState() async throws -> SpatialScene {
        // In real implementation: Fetch spatial state from backend
        let scene = SpatialScene(
            entities: [],
            lights: createDefaultLighting(),
            materials: [],
            audioSources: []
        )

        self.spatialScene = scene
        return scene
    }

    func placeContent(_ content: SharedContent, at transform: SpatialTransform) async throws {
        // Update local scene
        let entity = SpatialEntity(
            id: content.id,
            type: .content,
            transform: transform,
            modelReference: content.url
        )

        spatialScene?.entities.append(entity)

        // In real implementation: Broadcast to other participants
        print("Placed content: \(content.title) at position: \(transform.position.x), \(transform.position.y), \(transform.position.z)")
    }

    func removeContent(id: UUID) async throws {
        // Remove from local scene
        spatialScene?.entities.removeAll { $0.id == id }

        // In real implementation: Broadcast removal to other participants
        print("Removed content: \(id)")
    }

    // MARK: - Private Methods

    private func createDefaultLighting() -> [LightConfiguration] {
        return [
            LightConfiguration(
                type: .directional,
                intensity: 1000,
                color: CodableColor(red: 1.0, green: 1.0, blue: 1.0),
                position: SIMD3(0, 5, 0)
            ),
            LightConfiguration(
                type: .ambient,
                intensity: 300,
                color: CodableColor(red: 0.9, green: 0.9, blue: 1.0),
                position: SIMD3(0, 0, 0)
            )
        ]
    }
}
