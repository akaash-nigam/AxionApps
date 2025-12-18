//
//  SpatialMappingSystem.swift
//  Parkour Pathways
//
//  ARKit spatial mapping and room scanning
//

import ARKit
import RealityKit
import simd

@MainActor
class SpatialMappingSystem: ObservableObject {
    // Published state
    @Published var isScanning = false
    @Published var scanProgress: Float = 0.0
    @Published var roomModel: RoomModel?
    @Published var playArea: PlayArea?

    // ARKit session
    private var arkitSession: ARKitSession?
    private var worldTracking: WorldTrackingProvider?
    private var sceneReconstruction: SceneReconstructionProvider?
    private var planeDetection: PlaneDetectionProvider?

    // Detected surfaces
    private var detectedPlanes: [UUID: PlaneAnchor] = [:]
    private var roomMeshEntity: Entity?

    // MARK: - Initialization

    func initialize() async throws {
        // Create ARKit session
        arkitSession = ARKitSession()

        // Create providers
        worldTracking = WorldTrackingProvider()
        sceneReconstruction = SceneReconstructionProvider()
        planeDetection = PlaneDetectionProvider()

        // Request authorizations
        let authorizationResult = await arkitSession?.requestAuthorization(for: [
            .worldSensing,
            .handTracking
        ])

        guard authorizationResult?[.worldSensing] == .allowed else {
            throw SpatialMappingError.authorizationDenied
        }

        // Start providers
        guard let worldTracking = worldTracking,
              let sceneReconstruction = sceneReconstruction,
              let planeDetection = planeDetection else {
            throw SpatialMappingError.initializationFailed
        }

        try await arkitSession?.run([
            worldTracking,
            sceneReconstruction,
            planeDetection
        ])
    }

    // MARK: - Room Scanning

    func scanRoom() async throws -> RoomScanResult {
        isScanning = true
        scanProgress = 0.0

        var detectedSurfaces: [RoomModel.Surface] = []
        var scanDuration: TimeInterval = 0
        let maxScanDuration: TimeInterval = 30.0 // 30 seconds max

        let startTime = Date()

        // Monitor scene reconstruction
        guard let sceneReconstruction = sceneReconstruction else {
            throw SpatialMappingError.scanningFailed
        }

        for await update in sceneReconstruction.anchorUpdates {
            switch update.event {
            case .added, .updated:
                let meshAnchor = update.anchor

                // Process mesh geometry
                let surface = processMeshAnchor(meshAnchor)
                detectedSurfaces.append(surface)

                // Update progress
                scanDuration = Date().timeIntervalSince(startTime)
                scanProgress = min(Float(scanDuration / maxScanDuration), 0.95)

                // Complete when we have good coverage or timeout
                if scanProgress >= 0.95 || scanDuration >= maxScanDuration {
                    break
                }

            case .removed:
                break
            }
        }

        // Classify the space
        let classification = classifySpace(detectedSurfaces)

        // Generate room model
        let roomModel = generateRoomModel(
            surfaces: detectedSurfaces,
            classification: classification
        )

        // Detect play area
        let playArea = detectPlayArea()

        // Store results
        self.roomModel = roomModel
        self.playArea = playArea

        isScanning = false
        scanProgress = 1.0

        return RoomScanResult(
            roomModel: roomModel,
            surfaces: detectedSurfaces,
            classification: classification
        )
    }

    private func processMeshAnchor(_ meshAnchor: MeshAnchor) -> RoomModel.Surface {
        // Extract mesh vertices
        let vertices = extractVertices(meshAnchor)

        // Calculate average normal
        let normal = calculateAverageNormal(vertices)

        return RoomModel.Surface(
            id: meshAnchor.id,
            type: classifySurface(normal: normal),
            vertices: vertices,
            normal: normal
        )
    }

    private func extractVertices(_ meshAnchor: MeshAnchor) -> [SIMD3<Float>] {
        // Extract vertices from mesh geometry
        let geometry = meshAnchor.geometry
        var vertices: [SIMD3<Float>] = []

        for index in 0..<geometry.vertices.count {
            let vertex = geometry.vertices[index]
            // Transform to world space
            let worldVertex = meshAnchor.originFromAnchorTransform * SIMD4<Float>(vertex, 1)
            vertices.append(SIMD3<Float>(worldVertex.x, worldVertex.y, worldVertex.z))
        }

        return vertices
    }

    private func calculateAverageNormal(_ vertices: [SIMD3<Float>]) -> SIMD3<Float> {
        guard vertices.count >= 3 else { return SIMD3<Float>(0, 1, 0) }

        // Simple normal calculation from first triangle
        let v1 = vertices[1] - vertices[0]
        let v2 = vertices[2] - vertices[0]
        return simd_normalize(simd_cross(v1, v2))
    }

    private func classifySurface(normal: SIMD3<Float>) -> RoomModel.SurfaceType {
        let worldUp = SIMD3<Float>(0, 1, 0)
        let angle = acos(simd_dot(normal, worldUp))
        let angleDegrees = angle * 180.0 / .pi

        if angleDegrees < 15 {
            return .floor
        } else if angleDegrees > 165 {
            return .ceiling
        } else if angleDegrees > 75 && angleDegrees < 105 {
            return .wall
        } else {
            return .sloped
        }
    }

    private func classifySpace(_ surfaces: [RoomModel.Surface]) -> SpaceClassification {
        let floorArea = calculateTotalArea(surfaces.filter { $0.type == .floor })
        let wallCount = surfaces.filter { $0.type == .wall }.count

        if floorArea >= 16.0 { // 4m x 4m
            return .large
        } else if floorArea >= 9.0 { // 3m x 3m
            return .medium
        } else {
            return .small
        }
    }

    private func calculateTotalArea(_ surfaces: [RoomModel.Surface]) -> Float {
        // Calculate total surface area
        return surfaces.reduce(0) { total, surface in
            total + estimateArea(surface.vertices)
        }
    }

    private func estimateArea(_ vertices: [SIMD3<Float>]) -> Float {
        guard vertices.count >= 3 else { return 0 }

        // Simple area estimation
        var area: Float = 0
        for i in stride(from: 0, to: vertices.count - 2, by: 3) {
            let v1 = vertices[i + 1] - vertices[i]
            let v2 = vertices[i + 2] - vertices[i]
            let cross = simd_cross(v1, v2)
            area += simd_length(cross) / 2.0
        }
        return area
    }

    private func generateRoomModel(
        surfaces: [RoomModel.Surface],
        classification: SpaceClassification
    ) -> RoomModel {
        // Find room bounds
        var minBounds = SIMD3<Float>(.infinity, .infinity, .infinity)
        var maxBounds = SIMD3<Float>(-.infinity, -.infinity, -.infinity)

        for surface in surfaces {
            for vertex in surface.vertices {
                minBounds = simd_min(minBounds, vertex)
                maxBounds = simd_max(maxBounds, vertex)
            }
        }

        let dimensions = maxBounds - minBounds

        return RoomModel(
            width: dimensions.x,
            length: dimensions.z,
            height: dimensions.y,
            surfaces: surfaces,
            furniture: identifyFurniture(),
            safePlayArea: nil
        )
    }

    private func identifyFurniture() -> [RoomModel.FurnitureItem] {
        var furniture: [RoomModel.FurnitureItem] = []

        // Analyze detected objects for furniture
        // This would use object classification

        return furniture
    }

    func detectPlayArea() -> PlayArea {
        // Analyze floor planes to find largest play area
        let floorPlanes = detectedPlanes.values.filter { $0.classification == .floor }

        guard let largestFloor = floorPlanes.max(by: { $0.geometry.extent.x * $0.geometry.extent.z < $1.geometry.extent.x * $1.geometry.extent.z }) else {
            // Default play area
            return PlayArea(
                bounds: PlayArea.Bounds(
                    min: SIMD3<Float>(-1, 0, -1),
                    max: SIMD3<Float>(1, 2.5, 1)
                ),
                safeZone: PlayArea.Bounds(
                    min: SIMD3<Float>(-0.8, 0, -0.8),
                    max: SIMD3<Float>(0.8, 2.5, 0.8)
                ),
                centerPoint: .zero
            )
        }

        let extent = largestFloor.geometry.extent
        let transform = largestFloor.originFromAnchorTransform

        let halfWidth = extent.x / 2
        let halfLength = extent.z / 2

        let min = SIMD3<Float>(-halfWidth, 0, -halfLength)
        let max = SIMD3<Float>(halfWidth, extent.y, halfLength)

        // Apply safety margin
        let safetyMargin: Float = 0.5
        let safeMin = min + SIMD3<Float>(safetyMargin, 0, safetyMargin)
        let safeMax = max - SIMD3<Float>(safetyMargin, 0, safetyMargin)

        return PlayArea(
            bounds: PlayArea.Bounds(min: min, max: max),
            safeZone: PlayArea.Bounds(min: safeMin, max: safeMax),
            centerPoint: (min + max) / 2
        )
    }

    // MARK: - Room Mesh

    func getRoomMesh() async -> Entity? {
        guard let roomModel = roomModel else { return nil }

        if let existing = roomMeshEntity {
            return existing
        }

        // Create mesh entity from room model
        let entity = Entity()
        entity.name = "RoomMesh"

        // Create mesh from surfaces
        for surface in roomModel.surfaces {
            let surfaceEntity = createSurfaceMesh(surface)
            entity.addChild(surfaceEntity)
        }

        roomMeshEntity = entity
        return entity
    }

    private func createSurfaceMesh(_ surface: RoomModel.Surface) -> Entity {
        let entity = Entity()

        // Create mesh resource from vertices
        // This would create actual geometry

        // Add semi-transparent material
        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.1), texture: nil)

        return entity
    }
}

// MARK: - Supporting Types

enum SpaceClassification {
    case small   // < 3m x 3m
    case medium  // 3m x 3m to 4m x 4m
    case large   // > 4m x 4m
}

struct RoomScanResult {
    let roomModel: RoomModel
    let surfaces: [RoomModel.Surface]
    let classification: SpaceClassification
}

// MARK: - Errors

enum SpatialMappingError: Error {
    case authorizationDenied
    case initializationFailed
    case scanningFailed
    case noRoomData
}
