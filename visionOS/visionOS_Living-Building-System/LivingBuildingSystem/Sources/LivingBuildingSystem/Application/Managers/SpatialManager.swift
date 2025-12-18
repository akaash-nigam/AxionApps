import Foundation
import ARKit
import RealityKit

@MainActor
final class SpatialManager: ObservableObject {
    private let appState: AppState
    private var arKitSession: ARKitSession?
    private var worldTracking: WorldTrackingProvider?
    private var sceneReconstruction: SceneReconstructionProvider?

    // Spatial anchors
    @Published var anchors: [UUID: AnchorEntity] = [:]
    @Published var roomMeshes: [UUID: MeshAnchor] = [:]

    // Tracking state
    @Published var isTrackingActive = false
    @Published var userPosition: SIMD3<Float> = .zero
    @Published var userForward: SIMD3<Float> = .init(0, 0, -1)

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Session Management

    func startTracking() async throws {
        Logger.shared.log("Starting spatial tracking", category: "SpatialManager")

        // Create ARKit session
        let session = ARKitSession()
        let worldTracking = WorldTrackingProvider()
        let sceneReconstruction = SceneReconstructionProvider()

        self.arKitSession = session
        self.worldTracking = worldTracking
        self.sceneReconstruction = sceneReconstruction

        do {
            try await session.run([worldTracking, sceneReconstruction])
            isTrackingActive = true

            Logger.shared.log("Spatial tracking started successfully", category: "SpatialManager")

            // Start monitoring updates
            await monitorWorldTracking()
            await monitorSceneReconstruction()
        } catch {
            Logger.shared.log("Failed to start tracking", level: .error, error: error, category: "SpatialManager")
            throw SpatialError.trackingFailed(error)
        }
    }

    func stopTracking() {
        Logger.shared.log("Stopping spatial tracking", category: "SpatialManager")

        arKitSession?.stop()
        isTrackingActive = false
    }

    // MARK: - World Tracking

    private func monitorWorldTracking() async {
        guard let worldTracking = worldTracking else { return }

        for await update in worldTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                // Update user position and orientation
                if let deviceAnchor = update.anchor as? DeviceAnchor {
                    userPosition = deviceAnchor.originFromAnchorTransform.columns.3.xyz

                    // Extract forward direction from transform
                    let forward = deviceAnchor.originFromAnchorTransform.columns.2.xyz
                    userForward = normalize(-forward) // Negative Z is forward
                }

            case .removed:
                break
            }
        }
    }

    // MARK: - Scene Reconstruction

    private func monitorSceneReconstruction() async {
        guard let sceneReconstruction = sceneReconstruction else { return }

        for await update in sceneReconstruction.anchorUpdates {
            switch update.event {
            case .added, .updated:
                if let meshAnchor = update.anchor as? MeshAnchor {
                    roomMeshes[meshAnchor.id] = meshAnchor
                    Logger.shared.log("Mesh anchor updated: \(meshAnchor.id)", category: "SpatialManager")
                }

            case .removed:
                roomMeshes.removeValue(forKey: update.anchor.id)
            }
        }
    }

    // MARK: - Spatial Anchors

    func placeAnchor(
        at position: SIMD3<Float>,
        for room: Room
    ) async throws -> UUID {
        Logger.shared.log("Placing anchor for room: \(room.name)", category: "SpatialManager")

        // Create anchor entity
        let anchorEntity = AnchorEntity(.world(transform: makeTransform(at: position)))

        let anchorID = UUID()
        anchors[anchorID] = anchorEntity

        // Save anchor to database
        let anchor = RoomAnchor(
            anchorType: .wallDisplay,
            position: position,
            rotation: simd_quatf(angle: 0, axis: .init(0, 1, 0))
        )
        anchor.room = room

        Logger.shared.log("Anchor placed successfully", category: "SpatialManager")
        return anchorID
    }

    func loadAnchors(for room: Room) async throws {
        Logger.shared.log("Loading anchors for room: \(room.name)", category: "SpatialManager")

        for anchor in room.anchors {
            let anchorEntity = AnchorEntity(.world(transform: makeTransform(at: anchor.position)))
            anchors[anchor.id] = anchorEntity
        }
    }

    func removeAnchor(_ anchorID: UUID) {
        Logger.shared.log("Removing anchor: \(anchorID)", category: "SpatialManager")
        anchors.removeValue(forKey: anchorID)
    }

    // MARK: - Proximity Detection

    func distanceToPosition(_ position: SIMD3<Float>) -> Float {
        simd_distance(userPosition, position)
    }

    func isUserLookingAt(_ position: SIMD3<Float>, threshold: Float = 0.8) -> Bool {
        let toPosition = normalize(position - userPosition)
        let dotProduct = simd_dot(userForward, toPosition)
        return dotProduct > threshold
    }

    func findNearestWallPosition() -> SIMD3<Float>? {
        // Use raycasting to find nearest wall
        guard !roomMeshes.isEmpty else { return nil }

        // Cast ray in forward direction
        let rayOrigin = userPosition
        let rayDirection = userForward

        // Find intersection with room meshes
        var nearestDistance: Float = .infinity
        var nearestPosition: SIMD3<Float>?

        for mesh in roomMeshes.values {
            // Simplified raycast - in production, use proper mesh intersection
            let meshPosition = mesh.originFromAnchorTransform.columns.3.xyz
            let distance = simd_distance(rayOrigin, meshPosition)

            if distance < nearestDistance {
                nearestDistance = distance
                nearestPosition = meshPosition
            }
        }

        return nearestPosition
    }

    // MARK: - Helper Methods

    private func makeTransform(at position: SIMD3<Float>) -> simd_float4x4 {
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4(position.x, position.y, position.z, 1)
        return transform
    }
}

// MARK: - RoomAnchor Model Extension

@Model
final class RoomAnchor {
    @Attribute(.unique) var id: UUID
    var anchorType: AnchorType

    // Spatial coordinates (stored as Data for SIMD3<Float>)
    @Attribute var positionData: Data
    @Attribute var rotationData: Data // Quaternion

    var persistentIdentifier: UUID? // ARKit persistent anchor ID
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var room: Room?

    init(anchorType: AnchorType, position: SIMD3<Float>, rotation: simd_quatf) {
        self.id = UUID()
        self.anchorType = anchorType
        self.positionData = Self.encode(position)
        self.rotationData = Self.encode(rotation)
        self.createdAt = Date()
    }

    var position: SIMD3<Float> {
        get { Self.decodePosition(positionData) }
        set { positionData = Self.encode(newValue) }
    }

    var rotation: simd_quatf {
        get { Self.decodeRotation(rotationData) }
        set { rotationData = Self.encode(newValue) }
    }

    private static func encode<T>(_ value: T) -> Data {
        withUnsafeBytes(of: value) { Data($0) }
    }

    private static func decodePosition(_ data: Data) -> SIMD3<Float> {
        data.withUnsafeBytes { $0.load(as: SIMD3<Float>.self) }
    }

    private static func decodeRotation(_ data: Data) -> simd_quatf {
        data.withUnsafeBytes { $0.load(as: simd_quatf.self) }
    }
}

enum AnchorType: String, Codable {
    case wallDisplay
    case floorMarker
    case deviceLocation
    case roomCenter
}

// MARK: - Spatial Error

enum SpatialError: LocalizedError {
    case trackingFailed(Error)
    case anchorPlacementFailed
    case insufficientData

    var errorDescription: String? {
        switch self {
        case .trackingFailed(let error):
            return "Spatial tracking failed: \(error.localizedDescription)"
        case .anchorPlacementFailed:
            return "Failed to place spatial anchor"
        case .insufficientData:
            return "Insufficient spatial data"
        }
    }
}

// MARK: - SIMD Extensions

extension simd_float4x4 {
    var xyz: SIMD3<Float> {
        SIMD3(x, y, z)
    }
}
