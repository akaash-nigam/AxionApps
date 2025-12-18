//
//  SpatialMappingService.swift
//  Reality Minecraft
//
//  Handles spatial mapping and surface detection using ARKit
//

import Foundation
import ARKit
import RealityKit
import simd

/// Service for spatial mapping and surface detection
@MainActor
class SpatialMappingService: ObservableObject {
    @Published private(set) var detectedSurfaces: [DetectedSurface] = []
    @Published private(set) var meshAnchors: [UUID: MeshAnchor] = [:]
    @Published private(set) var isRunning: Bool = false

    private var arkitSession: ARKitSession?
    private var worldTrackingProvider: WorldTrackingProvider?
    private var planeDetectionProvider: PlaneDetectionProvider?
    private var sceneReconstructionProvider: SceneReconstructionProvider?

    // MARK: - Lifecycle

    /// Start spatial mapping
    func startSpatialMapping() async {
        print("🗺 Starting spatial mapping...")

        arkitSession = ARKitSession()
        worldTrackingProvider = WorldTrackingProvider()
        planeDetectionProvider = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
        sceneReconstructionProvider = SceneReconstructionProvider()

        do {
            try await arkitSession?.run([
                worldTrackingProvider!,
                planeDetectionProvider!,
                sceneReconstructionProvider!
            ])

            isRunning = true
            print("✅ Spatial mapping started")

            // Start processing updates
            startProcessingUpdates()
        } catch {
            print("❌ Failed to start spatial mapping: \(error)")
        }
    }

    /// Stop spatial mapping
    func stopSpatialMapping() async {
        arkitSession?.stop()
        isRunning = false
        print("⏹ Spatial mapping stopped")
    }

    // MARK: - Update Processing

    private func startProcessingUpdates() {
        // Process plane detection updates
        Task {
            await processPlaneUpdates()
        }

        // Process mesh updates
        Task {
            await processMeshUpdates()
        }
    }

    private func processPlaneUpdates() async {
        guard let planeProvider = planeDetectionProvider else { return }

        for await update in planeProvider.anchorUpdates {
            handlePlaneUpdate(update)
        }
    }

    private func processMeshUpdates() async {
        guard let meshProvider = sceneReconstructionProvider else { return }

        for await update in meshProvider.anchorUpdates {
            handleMeshUpdate(update)
        }
    }

    // MARK: - Plane Handling

    private func handlePlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) {
        switch update.event {
        case .added, .updated:
            let anchor = update.anchor
            let surface = DetectedSurface(
                id: anchor.id,
                classification: anchor.classification,
                transform: anchor.originFromAnchorTransform,
                extent: SIMD2(anchor.planeExtent.width, anchor.planeExtent.height),
                alignment: anchor.alignment
            )

            // Update or add surface
            if let index = detectedSurfaces.firstIndex(where: { $0.id == surface.id }) {
                detectedSurfaces[index] = surface
            } else {
                detectedSurfaces.append(surface)
            }

            print("✅ Detected surface: \(surface.classification)")

        case .removed:
            detectedSurfaces.removeAll { $0.id == update.anchor.id }
        }
    }

    // MARK: - Mesh Handling

    private func handleMeshUpdate(_ update: AnchorUpdate<MeshAnchor>) {
        switch update.event {
        case .added:
            meshAnchors[update.anchor.id] = update.anchor
            print("✅ Mesh anchor added: \(update.anchor.id)")

        case .updated:
            meshAnchors[update.anchor.id] = update.anchor

        case .removed:
            meshAnchors.removeValue(forKey: update.anchor.id)
            print("🗑 Mesh anchor removed: \(update.anchor.id)")
        }
    }

    // MARK: - Surface Queries

    /// Get all horizontal surfaces (floors, tables)
    func getHorizontalSurfaces() -> [DetectedSurface] {
        return detectedSurfaces.filter { $0.alignment == .horizontal }
    }

    /// Get all vertical surfaces (walls)
    func getVerticalSurfaces() -> [DetectedSurface] {
        return detectedSurfaces.filter { $0.alignment == .vertical }
    }

    /// Find nearest surface to a point
    func findNearestSurface(to point: SIMD3<Float>) -> DetectedSurface? {
        var nearestSurface: DetectedSurface?
        var nearestDistance: Float = .infinity

        for surface in detectedSurfaces {
            let surfacePosition = SIMD3<Float>(
                surface.transform.columns.3.x,
                surface.transform.columns.3.y,
                surface.transform.columns.3.z
            )

            let distance = simd_distance(point, surfacePosition)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestSurface = surface
            }
        }

        return nearestSurface
    }

    /// Raycast to find surface intersection
    func raycastToSurface(origin: SIMD3<Float>, direction: SIMD3<Float>) -> SurfaceHit? {
        // Simplified raycast - in production would use ARKit's raycast
        for surface in detectedSurfaces {
            if let hit = rayIntersectsSurface(
                origin: origin,
                direction: direction,
                surface: surface
            ) {
                return hit
            }
        }

        return nil
    }

    private func rayIntersectsSurface(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        surface: DetectedSurface
    ) -> SurfaceHit? {
        // Simplified plane intersection
        let surfacePosition = SIMD3<Float>(
            surface.transform.columns.3.x,
            surface.transform.columns.3.y,
            surface.transform.columns.3.z
        )

        let surfaceNormal = surface.normal

        // Plane intersection formula
        let denom = simd_dot(direction, surfaceNormal)
        if abs(denom) < 0.0001 { return nil } // Parallel

        let t = simd_dot(surfacePosition - origin, surfaceNormal) / denom
        if t < 0 { return nil } // Behind ray

        let hitPoint = origin + direction * t

        return SurfaceHit(
            point: hitPoint,
            normal: surfaceNormal,
            surface: surface,
            distance: t
        )
    }
}

// MARK: - Detected Surface

/// Represents a detected surface in the environment
struct DetectedSurface: Identifiable {
    let id: UUID
    let classification: PlaneAnchor.Classification
    let transform: simd_float4x4
    let extent: SIMD2<Float> // Width and height
    let alignment: PlaneAnchor.Alignment

    var normal: SIMD3<Float> {
        switch alignment {
        case .horizontal:
            return SIMD3<Float>(0, 1, 0)
        case .vertical:
            let forward = SIMD3<Float>(
                transform.columns.2.x,
                transform.columns.2.y,
                transform.columns.2.z
            )
            return normalize(forward)
        @unknown default:
            return SIMD3<Float>(0, 1, 0)
        }
    }

    var center: SIMD3<Float> {
        return SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
}

// MARK: - Surface Hit

/// Represents a raycast hit on a surface
struct SurfaceHit {
    let point: SIMD3<Float>
    let normal: SIMD3<Float>
    let surface: DetectedSurface
    let distance: Float
}

// MARK: - Surface Classification Extension

extension PlaneAnchor.Classification {
    var description: String {
        switch self {
        case .wall: return "Wall"
        case .floor: return "Floor"
        case .ceiling: return "Ceiling"
        case .table: return "Table"
        case .seat: return "Seat"
        case .window: return "Window"
        case .door: return "Door"
        @unknown default: return "Unknown"
        }
    }
}
