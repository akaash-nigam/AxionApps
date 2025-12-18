//
//  SpatialMappingManager.swift
//  Mystery Investigation
//
//  Manages ARKit spatial mapping and room scanning
//

import ARKit
import RealityKit

@Observable
class SpatialMappingManager {
    // MARK: - ARKit Session
    private var arkitSession: ARKitSession?
    private var worldTracking: WorldTrackingProvider?
    private var sceneReconstruction: SceneReconstructionProvider?
    private var planeDetection: PlaneDetectionProvider?

    // MARK: - Room Data
    private(set) var roomSize: SIMD3<Float> = SIMD3<Float>(3.0, 2.5, 3.0) // Default 3m x 2.5m x 3m
    private(set) var detectedPlanes: [PlaneAnchor] = []
    private(set) var isScanning: Bool = false

    // MARK: - Initialization
    init() {
        setupARKit()
    }

    // MARK: - ARKit Setup
    private func setupARKit() {
        arkitSession = ARKitSession()
        worldTracking = WorldTrackingProvider()
        sceneReconstruction = SceneReconstructionProvider()
        planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    }

    // MARK: - Room Scanning
    func startRoomScanning() async {
        guard let session = arkitSession,
              let worldTracking = worldTracking,
              let sceneReconstruction = sceneReconstruction,
              let planeDetection = planeDetection else {
            print("ARKit providers not initialized")
            return
        }

        do {
            isScanning = true
            try await session.run([worldTracking, sceneReconstruction, planeDetection])
            print("Room scanning started")
        } catch {
            print("Failed to start ARKit session: \(error)")
            isScanning = false
        }
    }

    func stopRoomScanning() {
        arkitSession?.stop()
        isScanning = false
        print("Room scanning stopped")
    }

    // MARK: - Plane Detection
    func updateDetectedPlanes(_ planes: [PlaneAnchor]) {
        detectedPlanes = planes
        calculateRoomSize()
    }

    private func calculateRoomSize() {
        // Calculate room bounds from detected planes
        var minBounds = SIMD3<Float>(repeating: .infinity)
        var maxBounds = SIMD3<Float>(repeating: -.infinity)

        for plane in detectedPlanes {
            let position = plane.transform.columns.3
            let extent = SIMD3<Float>(plane.geometry.extent.width, 0, plane.geometry.extent.height)

            minBounds = min(minBounds, SIMD3<Float>(position.x, position.y, position.z) - extent / 2)
            maxBounds = max(maxBounds, SIMD3<Float>(position.x, position.y, position.z) + extent / 2)
        }

        if minBounds.x != .infinity {
            roomSize = maxBounds - minBounds
            print("Room size calculated: \(roomSize)")
        }
    }

    // MARK: - Evidence Placement
    func placeEvidence(_ evidence: Evidence, in scene: RealityKit.Scene) -> Entity? {
        // Find appropriate surface based on evidence anchor data
        let anchor = evidence.spatialAnchor

        guard let surface = findSurface(type: anchor.surfaceType) else {
            print("Could not find surface of type: \(anchor.surfaceType)")
            return nil
        }

        // Create evidence entity at surface position
        let evidenceEntity = createEvidenceEntity(for: evidence)
        evidenceEntity.position = surface.position + anchor.relativePosition

        scene.addAnchor(surface)
        surface.addChild(evidenceEntity)

        return evidenceEntity
    }

    private func findSurface(type: SpatialAnchorData.SurfaceType) -> AnchorEntity? {
        // Find appropriate plane based on surface type
        switch type {
        case .floor:
            return findHorizontalPlane(facing: .up)
        case .ceiling:
            return findHorizontalPlane(facing: .down)
        case .wall:
            return findVerticalPlane()
        case .table:
            return findTableSurface()
        case .custom:
            return AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        }
    }

    private func findHorizontalPlane(facing: PlaneAnchor.Alignment.Kind) -> AnchorEntity? {
        // Find floor or ceiling plane
        let horizontalPlanes = detectedPlanes.filter { $0.alignment == .horizontal }
        guard let plane = horizontalPlanes.first else { return nil }

        let position = plane.transform.columns.3
        return AnchorEntity(world: SIMD3<Float>(position.x, position.y, position.z))
    }

    private func findVerticalPlane() -> AnchorEntity? {
        // Find wall plane
        let verticalPlanes = detectedPlanes.filter { $0.alignment == .vertical }
        guard let plane = verticalPlanes.first else { return nil }

        let position = plane.transform.columns.3
        return AnchorEntity(world: SIMD3<Float>(position.x, position.y, position.z))
    }

    private func findTableSurface() -> AnchorEntity? {
        // Find horizontal plane at table height (0.7-0.9m)
        let tablePlanes = detectedPlanes.filter {
            $0.alignment == .horizontal &&
            $0.transform.columns.3.y > 0.7 &&
            $0.transform.columns.3.y < 0.9
        }
        guard let plane = tablePlanes.first else {
            return findHorizontalPlane(facing: .up) // Fallback to floor
        }

        let position = plane.transform.columns.3
        return AnchorEntity(world: SIMD3<Float>(position.x, position.y, position.z))
    }

    private func createEvidenceEntity(for evidence: Evidence) -> Entity {
        // Create basic entity (in production, would load 3D model)
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(color: .yellow, isMetallic: false)]
        )

        entity.name = evidence.name
        entity.components.set(EvidenceComponent(evidenceData: evidence))

        return entity
    }

    // MARK: - Room Adaptation
    func adaptEvidenceLayout(for evidence: [Evidence]) -> [Evidence] {
        // Scale evidence placement based on room size
        let scale = min(roomSize.x / 3.0, roomSize.z / 3.0) // Normalize to 3m reference

        return evidence.map { ev in
            var adapted = ev
            var anchor = ev.spatialAnchor
            anchor.relativePosition = anchor.relativePosition * scale
            // Note: Would need to make spatialAnchor mutable in production
            return adapted
        }
    }
}
