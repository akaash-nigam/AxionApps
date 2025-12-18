//
//  AnnotationRenderer.swift
//  Reality Annotation Platform
//
//  Renders and updates annotation entities in the AR scene
//

import Foundation
import RealityKit

@MainActor
class AnnotationRenderer {
    // Entity management
    private var entities: [UUID: AnnotationEntity] = [:]
    private var rootEntity: Entity?

    // Managers
    private let anchorManager: AnchorManager

    // Performance settings
    private let maxVisibleAnnotations = 100
    private var lastUpdateTime: Date?

    // MARK: - Initialization

    init(anchorManager: AnchorManager) {
        self.anchorManager = anchorManager
    }

    // MARK: - Scene Setup

    /// Set the root entity for the scene
    func setRootEntity(_ entity: Entity) {
        self.rootEntity = entity
        print("🎬 Annotation renderer root entity set")
    }

    // MARK: - Entity Management

    /// Create and add annotation entity to scene
    func createEntity(for annotation: Annotation) async {
        // Check if entity already exists
        if entities[annotation.id] != nil {
            print("⚠️ Entity already exists for annotation: \(annotation.id)")
            return
        }

        // Create annotation entity
        let annotationEntity = AnnotationEntity(annotation: annotation)

        // Get or create anchor
        do {
            let anchorID = try await anchorManager.anchorFor(position: annotation.position)

            if let anchor = anchorManager.getAnchor(anchorID) {
                // Calculate position relative to anchor
                let relativePosition = annotation.position - anchor.position

                // Set entity position relative to anchor
                annotationEntity.position = relativePosition

                // Add to anchor
                anchor.addChild(annotationEntity)

                // Add to root if anchor isn't already in scene
                if anchor.parent == nil, let root = rootEntity {
                    root.addChild(anchor)
                }

                // Store entity
                entities[annotation.id] = annotationEntity

                // Animate appearance
                annotationEntity.animateAppearance()

                print("✅ Created entity for annotation: \(annotation.id)")
            }
        } catch {
            print("❌ Failed to create entity: \(error)")
        }
    }

    /// Remove annotation entity from scene
    func removeEntity(for annotationID: UUID) async {
        guard let entity = entities[annotationID] else {
            print("⚠️ No entity found for annotation: \(annotationID)")
            return
        }

        // Animate removal
        await entity.animateRemoval()

        // Remove from scene
        entity.removeFromParent()

        // Remove from dictionary
        entities.removeValue(forKey: annotationID)

        print("🗑️ Removed entity for annotation: \(annotationID)")
    }

    /// Update annotation entity
    func updateEntity(for annotation: Annotation) {
        guard let entity = entities[annotation.id] else {
            print("⚠️ No entity found to update: \(annotation.id)")
            return
        }

        entity.updateAnnotation(annotation)
        print("🔄 Updated entity for annotation: \(annotation.id)")
    }

    /// Get entity for annotation
    func getEntity(for annotationID: UUID) -> AnnotationEntity? {
        return entities[annotationID]
    }

    // MARK: - Scene Updates

    /// Update all entities (called every frame)
    func update(cameraPosition: SIMD3<Float>, deltaTime: TimeInterval) {
        // Throttle updates (don't update every single frame)
        if let lastUpdate = lastUpdateTime,
           Date().timeIntervalSince(lastUpdate) < 1.0 / 30.0 { // 30 FPS max
            return
        }

        lastUpdateTime = Date()

        // Update visible entities
        for (_, entity) in entities {
            guard entity.isEnabled else { continue }

            // Calculate distance to camera
            let entityPos = entity.position(relativeTo: nil)
            let distance = simd_distance(entityPos, cameraPosition)

            // Update LOD based on distance
            entity.updateLOD(distance: distance)

            // Update billboard orientation
            entity.updateBillboard(cameraPosition: cameraPosition)
        }
    }

    /// Reload all annotations from service
    func reloadAnnotations(_ annotations: [Annotation]) async {
        // Remove entities that no longer exist
        let annotationIDs = Set(annotations.map { $0.id })
        let entitiesToRemove = entities.keys.filter { !annotationIDs.contains($0) }

        for id in entitiesToRemove {
            await removeEntity(for: id)
        }

        // Create or update entities
        for annotation in annotations {
            if entities[annotation.id] != nil {
                // Update existing
                updateEntity(for: annotation)
            } else {
                // Create new
                await createEntity(for: annotation)
            }
        }

        print("🔄 Reloaded \(annotations.count) annotations")
    }

    // MARK: - Spatial Queries

    /// Find entity at ray intersection
    func raycast(from origin: SIMD3<Float>, direction: SIMD3<Float>) -> AnnotationEntity? {
        var closest: (entity: AnnotationEntity, distance: Float)?

        for (_, entity) in entities {
            guard entity.isEnabled else { continue }

            // Simple sphere-based ray intersection
            let entityPos = entity.position(relativeTo: nil)
            let radius: Float = 0.15 // Approximate interaction radius

            if let distance = rayIntersectsSphere(
                rayOrigin: origin,
                rayDirection: direction,
                sphereCenter: entityPos,
                sphereRadius: radius
            ) {
                if closest == nil || distance < closest!.distance {
                    closest = (entity, distance)
                }
            }
        }

        return closest?.entity
    }

    private func rayIntersectsSphere(
        rayOrigin: SIMD3<Float>,
        rayDirection: SIMD3<Float>,
        sphereCenter: SIMD3<Float>,
        sphereRadius: Float
    ) -> Float? {
        let oc = rayOrigin - sphereCenter
        let a = dot(rayDirection, rayDirection)
        let b = 2.0 * dot(oc, rayDirection)
        let c = dot(oc, oc) - sphereRadius * sphereRadius
        let discriminant = b * b - 4 * a * c

        if discriminant < 0 {
            return nil
        }

        let t = (-b - sqrt(discriminant)) / (2.0 * a)
        return t > 0 ? t : nil
    }

    // MARK: - Cleanup

    /// Remove all entities
    func clearAll() async {
        for id in Array(entities.keys) {
            await removeEntity(for: id)
        }

        entities.removeAll()
        print("🧹 Cleared all annotation entities")
    }

    // MARK: - Debug

    func printStatus() {
        print("🎨 Annotation Renderer Status:")
        print("  Total entities: \(entities.count)")
        print("  Enabled entities: \(entities.values.filter { $0.isEnabled }.count)")
        print("  Max visible: \(maxVisibleAnnotations)")
    }
}
