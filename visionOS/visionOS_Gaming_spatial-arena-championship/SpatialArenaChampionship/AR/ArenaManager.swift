//
//  ArenaManager.swift
//  Spatial Arena Championship
//
//  Arena calibration and room scanning manager
//

import Foundation
import ARKit
import RealityKit
import Observation

// MARK: - Arena Manager

@Observable
@MainActor
class ArenaManager {
    // MARK: - Properties

    private var arkitSession: ARKitSession?
    private var worldTrackingProvider: WorldTrackingProvider?
    private var sceneReconstructionProvider: SceneReconstructionProvider?
    private var planeDetectionProvider: PlaneDetectionProvider?

    // Room data
    var roomBounds: RoomBounds?
    var detectedPlanes: [UUID: DetectedPlane] = [:]
    var safePlayArea: PlayArea?
    var obstacles: [UUID: Obstacle] = [:]

    // State
    var calibrationState: CalibrationState = .notStarted
    var isScanning: Bool = false
    var scanProgress: Float = 0.0
    var roomSize: SIMD3<Float> = .zero

    // Anchors
    private var arenaAnchorEntity: AnchorEntity?

    // Callbacks
    var onCalibrationComplete: ((PlayArea) -> Void)?
    var onObstacleDetected: ((Obstacle) -> Void)?

    // MARK: - Initialization

    init() {
        setupARKit()
    }

    private func setupARKit() {
        guard WorldTrackingProvider.isSupported else {
            print("World tracking not supported")
            return
        }

        arkitSession = ARKitSession()
        worldTrackingProvider = WorldTrackingProvider()

        if SceneReconstructionProvider.isSupported {
            sceneReconstructionProvider = SceneReconstructionProvider()
        }

        if PlaneDetectionProvider.isSupported {
            planeDetectionProvider = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
        }
    }

    // MARK: - Start/Stop

    func start() async throws {
        guard let session = arkitSession else {
            throw ARKitError.notSupported
        }

        var providers: [any DataProvider] = []

        if let worldTracking = worldTrackingProvider {
            providers.append(worldTracking)
        }

        if let sceneReconstruction = sceneReconstructionProvider {
            providers.append(sceneReconstruction)
        }

        if let planeDetection = planeDetectionProvider {
            providers.append(planeDetection)
        }

        try await session.run(providers)
    }

    func stop() {
        arkitSession?.stop()
    }

    // MARK: - Calibration

    func startCalibration() async throws {
        calibrationState = .scanning
        isScanning = true
        scanProgress = 0.0

        // Start ARKit
        try await start()

        // Monitor plane detection
        startPlaneDetection()

        // Auto-complete after scanning timeout
        Task {
            for i in 0...100 {
                guard isScanning else { break }
                scanProgress = Float(i) / 100.0
                try? await Task.sleep(for: .milliseconds(50))
            }

            if isScanning {
                await completeCalibration()
            }
        }
    }

    private func startPlaneDetection() {
        guard let provider = planeDetectionProvider else { return }

        Task {
            for await update in provider.anchorUpdates {
                await handlePlaneUpdate(update)
            }
        }
    }

    private func handlePlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) async {
        switch update.event {
        case .added:
            await addPlane(update.anchor)
        case .updated:
            await updatePlane(update.anchor)
        case .removed:
            removePlane(update.anchor.id)
        }
    }

    private func addPlane(_ anchor: PlaneAnchor) async {
        let plane = DetectedPlane(
            id: anchor.id,
            classification: anchor.classification,
            alignment: anchor.alignment,
            center: anchor.originFromAnchorTransform.translation,
            extent: anchor.extent,
            transform: anchor.originFromAnchorTransform
        )

        detectedPlanes[anchor.id] = plane

        // Update room bounds
        updateRoomBounds()
    }

    private func updatePlane(_ anchor: PlaneAnchor) async {
        guard var plane = detectedPlanes[anchor.id] else { return }

        plane.center = anchor.originFromAnchorTransform.translation
        plane.extent = anchor.extent
        plane.transform = anchor.originFromAnchorTransform

        detectedPlanes[anchor.id] = plane

        // Update room bounds
        updateRoomBounds()
    }

    private func removePlane(_ id: UUID) {
        detectedPlanes.removeValue(forKey: id)
        updateRoomBounds()
    }

    private func updateRoomBounds() {
        // Find floor plane
        guard let floorPlane = detectedPlanes.values.first(where: {
            $0.alignment == .horizontal && $0.classification == .floor
        }) else {
            return
        }

        // Find walls
        let walls = detectedPlanes.values.filter {
            $0.alignment == .vertical && $0.classification == .wall
        }

        // Calculate room dimensions from walls
        var minX: Float = -.infinity
        var maxX: Float = .infinity
        var minZ: Float = -.infinity
        var maxZ: Float = .infinity

        for wall in walls {
            let position = wall.center
            let extent = wall.extent

            // Determine wall orientation and update bounds
            if abs(wall.transform.columns.2.x) > 0.5 {
                // Wall perpendicular to X axis
                let wallX = position.x
                if extent.x > 0.5 {
                    if wallX < 0 {
                        minX = max(minX, wallX)
                    } else {
                        maxX = min(maxX, wallX)
                    }
                }
            } else {
                // Wall perpendicular to Z axis
                let wallZ = position.z
                if extent.x > 0.5 {
                    if wallZ < 0 {
                        minZ = max(minZ, wallZ)
                    } else {
                        maxZ = min(maxZ, wallZ)
                    }
                }
            }
        }

        // Create room bounds
        let width = maxX - minX
        let depth = maxZ - minZ
        let height: Float = 3.0 // Default ceiling height

        let center = SIMD3<Float>(
            (minX + maxX) / 2.0,
            floorPlane.center.y + height / 2.0,
            (minZ + maxZ) / 2.0
        )

        let dimensions = SIMD3<Float>(
            abs(width),
            height,
            abs(depth)
        )

        roomBounds = RoomBounds(
            center: center,
            dimensions: dimensions,
            floorHeight: floorPlane.center.y
        )

        roomSize = dimensions

        // Calculate safe play area
        calculateSafePlayArea()
    }

    private func calculateSafePlayArea() {
        guard let bounds = roomBounds else { return }

        // Apply safety margins (30cm from walls)
        let safetyMargin: Float = 0.3

        let safeDimensions = SIMD3<Float>(
            max(0.5, bounds.dimensions.x - safetyMargin * 2),
            bounds.dimensions.y,
            max(0.5, bounds.dimensions.z - safetyMargin * 2)
        )

        // Clamp to game requirements
        let minPlayArea: Float = GameConstants.Arena.minPlayAreaSize
        let maxPlayArea: Float = GameConstants.Arena.maxPlayAreaSize

        let finalDimensions = SIMD3<Float>(
            min(maxPlayArea, max(minPlayArea, safeDimensions.x)),
            safeDimensions.y,
            min(maxPlayArea, max(minPlayArea, safeDimensions.z))
        )

        safePlayArea = PlayArea(
            center: bounds.center,
            dimensions: finalDimensions,
            floorHeight: bounds.floorHeight,
            isValid: isPlayAreaValid(finalDimensions)
        )
    }

    private func isPlayAreaValid(_ dimensions: SIMD3<Float>) -> Bool {
        let minSize = GameConstants.Arena.minPlayAreaSize
        return dimensions.x >= minSize && dimensions.z >= minSize
    }

    func completeCalibration() async {
        isScanning = false
        scanProgress = 1.0

        guard let playArea = safePlayArea, playArea.isValid else {
            calibrationState = .failed
            return
        }

        calibrationState = .completed
        onCalibrationComplete?(playArea)
    }

    func cancelCalibration() {
        isScanning = false
        calibrationState = .cancelled
        stop()
    }

    // MARK: - Obstacle Detection

    func startObstacleDetection() {
        guard let provider = sceneReconstructionProvider else { return }

        Task {
            for await update in provider.anchorUpdates {
                await handleSceneUpdate(update)
            }
        }
    }

    private func handleSceneUpdate(_ update: AnchorUpdate<MeshAnchor>) async {
        switch update.event {
        case .added:
            await detectObstacles(in: update.anchor)
        case .updated:
            await detectObstacles(in: update.anchor)
        case .removed:
            removeObstacle(update.anchor.id)
        }
    }

    private func detectObstacles(in anchor: MeshAnchor) async {
        // Analyze mesh geometry for obstacles
        let geometry = anchor.geometry
        let vertices = geometry.vertices
        let normals = geometry.normals

        // Simple obstacle detection: objects protruding from floor/walls
        guard let playArea = safePlayArea else { return }

        // Check if mesh is within play area
        let position = anchor.originFromAnchorTransform.translation
        if isPositionInPlayArea(position, playArea: playArea) {
            // Create obstacle
            let obstacle = Obstacle(
                id: anchor.id,
                position: position,
                extent: estimateExtent(from: vertices),
                type: classifyObstacle(position: position, normals: normals)
            )

            obstacles[anchor.id] = obstacle
            onObstacleDetected?(obstacle)
        }
    }

    private func removeObstacle(_ id: UUID) {
        obstacles.removeValue(forKey: id)
    }

    private func estimateExtent(from vertices: GeometrySource) -> SIMD3<Float> {
        // Calculate bounding box from vertices
        // Simplified: return default extent
        return SIMD3<Float>(0.5, 0.5, 0.5)
    }

    private func classifyObstacle(position: SIMD3<Float>, normals: GeometrySource) -> ObstacleType {
        // Classify based on position and normals
        if position.y < 0.5 {
            return .floor
        } else if position.y > 2.0 {
            return .ceiling
        } else {
            return .furniture
        }
    }

    private func isPositionInPlayArea(_ position: SIMD3<Float>, playArea: PlayArea) -> Bool {
        let halfExtent = playArea.dimensions / 2.0
        let min = playArea.center - halfExtent
        let max = playArea.center + halfExtent

        return position.x >= min.x && position.x <= max.x &&
               position.y >= min.y && position.y <= max.y &&
               position.z >= min.z && position.z <= max.z
    }

    // MARK: - Arena Setup

    func setupArenaInScene(_ scene: Scene, arena: Arena) throws {
        guard let playArea = safePlayArea, playArea.isValid else {
            throw ARKitError.invalidPlayArea
        }

        // Create arena anchor at floor center
        let arenaAnchor = AnchorEntity(world: playArea.center)
        scene.addAnchor(arenaAnchor)
        arenaAnchorEntity = arenaAnchor

        // Scale arena to fit play area
        let scaleFactor = calculateArenaScale(arena: arena, playArea: playArea)
        arenaAnchor.scale = SIMD3<Float>(repeating: scaleFactor)

        // Visualize boundaries
        let boundary = createBoundaryVisualization(playArea: playArea)
        arenaAnchor.addChild(boundary)
    }

    private func calculateArenaScale(arena: Arena, playArea: PlayArea) -> Float {
        let arenaSize = max(arena.dimensions.x, arena.dimensions.z)
        let playAreaSize = min(playArea.dimensions.x, playArea.dimensions.z)

        // Scale arena to fit 80% of play area
        return (playAreaSize * 0.8) / arenaSize
    }

    private func createBoundaryVisualization(playArea: PlayArea) -> Entity {
        let boundary = Entity()

        // Create grid lines on floor
        let gridSpacing: Float = 1.0
        let halfWidth = playArea.dimensions.x / 2.0
        let halfDepth = playArea.dimensions.z / 2.0

        // Vertical lines
        var x: Float = -halfWidth
        while x <= halfWidth {
            let line = createLine(
                from: SIMD3<Float>(x, 0, -halfDepth),
                to: SIMD3<Float>(x, 0, halfDepth)
            )
            boundary.addChild(line)
            x += gridSpacing
        }

        // Horizontal lines
        var z: Float = -halfDepth
        while z <= halfDepth {
            let line = createLine(
                from: SIMD3<Float>(-halfWidth, 0, z),
                to: SIMD3<Float>(halfWidth, 0, z)
            )
            boundary.addChild(line)
            z += gridSpacing
        }

        return boundary
    }

    private func createLine(from: SIMD3<Float>, to: SIMD3<Float>) -> Entity {
        let entity = Entity()

        let direction = to - from
        let length = simd_length(direction)

        // Create cylinder as line
        let mesh = MeshResource.generateBox(
            width: 0.01,
            height: length,
            depth: 0.01
        )

        var material = UnlitMaterial(color: .cyan)
        material.blending = .transparent(opacity: 0.3)

        entity.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )

        // Position and orient
        let center = (from + to) / 2.0
        entity.position = center

        // Rotate to align with direction
        let angle = atan2(direction.x, direction.z)
        entity.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])

        return entity
    }

    // MARK: - Validation

    func validatePlayArea() -> PlayAreaValidation {
        guard let playArea = safePlayArea else {
            return PlayAreaValidation(
                isValid: false,
                errors: ["No play area detected. Please scan your room."]
            )
        }

        var errors: [String] = []
        var warnings: [String] = []

        // Check minimum size
        let minSize = GameConstants.Arena.minPlayAreaSize
        if playArea.dimensions.x < minSize {
            errors.append("Play area width (\(playArea.dimensions.x)m) is less than minimum (\(minSize)m)")
        }
        if playArea.dimensions.z < minSize {
            errors.append("Play area depth (\(playArea.dimensions.z)m) is less than minimum (\(minSize)m)")
        }

        // Check for obstacles
        if obstacles.count > 5 {
            warnings.append("High number of obstacles detected (\(obstacles.count)). Consider clearing space.")
        }

        // Check ceiling height
        if playArea.dimensions.y < 2.2 {
            warnings.append("Low ceiling detected. Some visual effects may be clipped.")
        }

        return PlayAreaValidation(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }

    // MARK: - Reset

    func reset() {
        stop()
        detectedPlanes.removeAll()
        obstacles.removeAll()
        roomBounds = nil
        safePlayArea = nil
        calibrationState = .notStarted
        scanProgress = 0.0
    }
}

// MARK: - Supporting Types

enum CalibrationState {
    case notStarted
    case scanning
    case completed
    case failed
    case cancelled
}

struct RoomBounds {
    var center: SIMD3<Float>
    var dimensions: SIMD3<Float>
    var floorHeight: Float
}

struct PlayArea {
    var center: SIMD3<Float>
    var dimensions: SIMD3<Float>
    var floorHeight: Float
    var isValid: Bool
}

struct DetectedPlane {
    var id: UUID
    var classification: PlaneAnchor.Classification
    var alignment: PlaneAnchor.Alignment
    var center: SIMD3<Float>
    var extent: SIMD3<Float>
    var transform: simd_float4x4
}

struct Obstacle {
    var id: UUID
    var position: SIMD3<Float>
    var extent: SIMD3<Float>
    var type: ObstacleType
}

enum ObstacleType {
    case furniture
    case wall
    case floor
    case ceiling
    case unknown
}

struct PlayAreaValidation {
    var isValid: Bool
    var errors: [String] = []
    var warnings: [String] = []
}

enum ARKitError: Error {
    case notSupported
    case invalidPlayArea
    case calibrationFailed
}

// MARK: - Extensions

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
