# Spatial Persistence & AR Architecture
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines how the Reality Annotation Platform uses ARKit and RealityKit to create, persist, and relocalize spatial annotations in physical environments. It covers the full lifecycle from anchor creation to multi-session persistence.

---

## 2. visionOS AR Capabilities

### 2.1 visionOS World Tracking

visionOS provides automatic world tracking with:
- **Scene Understanding**: Automatic detection of planes, objects, hands
- **Persistent Anchors**: Spatial anchors that persist across sessions
- **World Tracking**: 6DOF tracking of device position/orientation
- **Scene Reconstruction**: Mesh representation of physical environment

### 2.2 Key Differences from iOS ARKit

| Feature | iOS ARKit | visionOS |
|---------|-----------|----------|
| World Tracking | Requires ARWorldTrackingConfiguration | Automatic, always on |
| Anchor Persistence | ARWorldMap save/load | Built-in OS-level persistence |
| Scene Understanding | Optional | Always available |
| Coordinate System | Camera-relative | World-space anchored |
| Session Management | Manual ARSession | Managed by system |

---

## 3. Spatial Coordinate Systems

### 3.1 Coordinate System Hierarchy

```
World Space (visionOS)
    ↓
ARWorldAnchor (persistent reference point)
    ↓
Annotation Local Space (position relative to anchor)
    ↓
RealityKit Entity Transform
```

### 3.2 Transform Chain

```swift
// World → Anchor → Annotation → Entity

// 1. World space position (from user tap)
let worldPosition: SIMD3<Float> = (x: 0.5, y: 1.2, z: -2.0)

// 2. Create anchor at nearby stable location
let anchorTransform = Transform(
    translation: nearestPlanePoint(worldPosition)
)
let worldAnchor = AnchorEntity(.world(transform: anchorTransform))

// 3. Annotation position relative to anchor
let relativePosition = worldPosition - anchorTransform.translation

// 4. Entity attached to anchor
let annotationEntity = ModelEntity()
annotationEntity.position = relativePosition
worldAnchor.addChild(annotationEntity)
```

### 3.3 Coordinate Space Conversions

```swift
extension ARSessionManager {
    /// Convert from world space to anchor-relative space
    func worldToAnchor(
        _ worldPosition: SIMD3<Float>,
        anchor: AnchorEntity
    ) -> SIMD3<Float> {
        let anchorTransform = anchor.transformMatrix(relativeTo: nil)
        let anchorPosition = SIMD3<Float>(
            anchorTransform.columns.3.x,
            anchorTransform.columns.3.y,
            anchorTransform.columns.3.z
        )
        return worldPosition - anchorPosition
    }

    /// Convert from anchor-relative to world space
    func anchorToWorld(
        _ relativePosition: SIMD3<Float>,
        anchor: AnchorEntity
    ) -> SIMD3<Float> {
        let anchorTransform = anchor.transformMatrix(relativeTo: nil)
        let anchorPosition = SIMD3<Float>(
            anchorTransform.columns.3.x,
            anchorTransform.columns.3.y,
            anchorTransform.columns.3.z
        )
        return anchorPosition + relativePosition
    }
}
```

---

## 4. Anchor Strategy

### 4.1 Anchor Placement Philosophy

**Goal**: Maximize relocalization success across sessions

**Strategy**:
1. **Anchor to stable features**: Planes (walls, floors, tables)
2. **Avoid temporary objects**: Don't anchor to chairs, small objects
3. **Use spatial clustering**: Group nearby annotations under one anchor
4. **Limit anchor count**: Max 20-30 anchors per space (performance)

### 4.2 Anchor Types

```swift
enum AnchorType {
    case plane(ARPlaneAnchor) // Wall, floor, table
    case world(Transform) // Generic world position
    case image(ARImageAnchor) // QR code, poster (future)
    case object(ARObjectAnchor) // Recognized object (future)
}
```

### 4.3 Anchor Creation Logic

```swift
protocol AnchorManager {
    /// Find or create appropriate anchor for position
    func anchorFor(position: SIMD3<Float>) async throws -> UUID

    /// Create new anchor at position
    func createAnchor(at position: SIMD3<Float>, type: AnchorType) async throws -> UUID

    /// Find nearest existing anchor within radius
    func nearestAnchor(to position: SIMD3<Float>, maxDistance: Float) -> UUID?

    /// Remove anchor (when no annotations reference it)
    func removeAnchor(id: UUID) async throws
}

class DefaultAnchorManager: AnchorManager {
    private let maxAnchorDistance: Float = 2.0 // meters
    private var anchors: [UUID: AnchorEntity] = [:]

    func anchorFor(position: SIMD3<Float>) async throws -> UUID {
        // Try to find existing anchor nearby
        if let existingID = nearestAnchor(to: position, maxDistance: maxAnchorDistance) {
            return existingID
        }

        // Create new anchor
        // Prefer plane anchors for stability
        if let planeAnchor = await findPlaneNear(position) {
            return try await createAnchor(at: position, type: .plane(planeAnchor))
        } else {
            return try await createAnchor(at: position, type: .world(Transform(translation: position)))
        }
    }

    private func findPlaneNear(_ position: SIMD3<Float>) async -> ARPlaneAnchor? {
        // Query scene understanding for planes
        // Return closest plane within 0.5 meters
        // Implementation uses visionOS scene APIs
        return nil // Placeholder
    }

    func nearestAnchor(to position: SIMD3<Float>, maxDistance: Float) -> UUID? {
        var nearest: (id: UUID, distance: Float)?

        for (id, anchor) in anchors {
            let anchorPos = anchor.position(relativeTo: nil)
            let distance = simd_distance(position, anchorPos)

            if distance <= maxDistance {
                if nearest == nil || distance < nearest!.distance {
                    nearest = (id, distance)
                }
            }
        }

        return nearest?.id
    }
}
```

---

## 5. Spatial Persistence

### 5.1 Persistence Architecture

```
┌─────────────────────────────────────────────────┐
│            Annotation Created                    │
└───────────────────┬─────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │  Find/Create Anchor  │
         └──────────┬───────────┘
                    ↓
         ┌──────────────────────┐
         │ Save to SwiftData    │ → Local DB: Annotation + anchorID
         └──────────┬───────────┘
                    ↓
         ┌──────────────────────┐
         │ Persist Anchor Data  │ → ARWorldMapData in DB
         └──────────┬───────────┘
                    ↓
         ┌──────────────────────┐
         │  Sync to CloudKit    │ → Cloud backup
         └──────────────────────┘
```

### 5.2 ARWorldMap Persistence

visionOS doesn't use ARWorldMap the same way as iOS. Instead:

**visionOS Approach**:
- Anchors are automatically persistent at OS level
- We store anchor **identifiers** and **transforms**
- visionOS handles relocalization automatically

```swift
struct PersistentAnchorData: Codable {
    var id: UUID
    var transform: simd_float4x4
    var type: String // "plane", "world", etc.
    var planeType: String? // "horizontal", "vertical"
    var createdAt: Date
    var lastLocalizedAt: Date?
    var reliability: Float // 0.0 - 1.0, how often it relocalizes successfully
}

class WorldMapManager {
    /// Save current anchor state
    func saveAnchorState() async throws {
        let anchorData = anchors.map { PersistentAnchorData(from: $0) }
        let worldMapData = ARWorldMapData(
            id: currentSpaceID,
            worldMapData: try JSONEncoder().encode(anchorData),
            ownerID: currentUserID
        )
        try await repository.save(worldMapData)
    }

    /// Load anchor state for space
    func loadAnchorState(spaceID: UUID) async throws {
        guard let worldMapData = try await repository.fetch(spaceID) else {
            throw ARError.worldMapNotFound
        }

        let anchorData = try JSONDecoder().decode(
            [PersistentAnchorData].self,
            from: worldMapData.worldMapData
        )

        // Attempt to relocalize each anchor
        for data in anchorData {
            await relocalizeAnchor(data)
        }
    }

    /// Attempt to find existing anchor at saved location
    private func relocalizeAnchor(_ data: PersistentAnchorData) async {
        // visionOS will automatically try to track anchors
        // We create a new anchor with saved transform as hint
        let anchor = AnchorEntity()
        anchor.transform = Transform(matrix: data.transform)
        // Add to scene
        // visionOS will snap to real position if detected
    }
}
```

### 5.3 Space Recognition

**Problem**: How do we know we're in the same physical space?

**Solution**: Multi-factor space identification

```swift
struct SpaceIdentifier {
    // Spatial fingerprint
    var roomDimensions: SIMD3<Float>? // Approximate room size
    var wallPlanes: [PlaneDescriptor] // Major walls detected
    var floorArea: Float? // Floor surface area

    // User-provided
    var locationName: String? // e.g., "Living Room"
    var locationDescription: String?
    var thumbnailImage: Data? // Photo of the space

    // Matching algorithm
    func matches(_ other: SpaceIdentifier, threshold: Float = 0.8) -> Bool {
        var score: Float = 0.0
        var factors = 0

        // Compare room dimensions (if available)
        if let dims1 = roomDimensions, let dims2 = other.roomDimensions {
            let dimSimilarity = 1.0 - simd_distance(dims1, dims2) / 10.0
            score += max(0, dimSimilarity)
            factors += 1
        }

        // Compare floor area
        if let area1 = floorArea, let area2 = other.floorArea {
            let areaDiff = abs(area1 - area2) / max(area1, area2)
            score += max(0, 1.0 - areaDiff)
            factors += 1
        }

        // Compare wall planes
        let wallSimilarity = compareWallPlanes(wallPlanes, other.wallPlanes)
        score += wallSimilarity
        factors += 1

        return factors > 0 && (score / Float(factors)) >= threshold
    }

    private func compareWallPlanes(_ p1: [PlaneDescriptor], _ p2: [PlaneDescriptor]) -> Float {
        // Compare count and orientations of major walls
        // Implementation details...
        return 0.5 // Placeholder
    }
}

struct PlaneDescriptor: Codable {
    var normal: SIMD3<Float> // Wall orientation
    var area: Float // Wall size
    var center: SIMD3<Float> // Wall center position
}
```

---

## 6. Annotation Rendering

### 6.1 RealityKit Entity Hierarchy

```swift
/// Root entity attached to anchor
class AnnotationGroupEntity: Entity {
    var anchorID: UUID
    var annotations: [UUID: AnnotationEntity] = [:]

    func addAnnotation(_ annotation: Annotation) {
        let entity = AnnotationEntity(annotation: annotation)
        entity.position = annotation.position
        addChild(entity)
        annotations[annotation.id] = entity
    }
}

/// Individual annotation entity
class AnnotationEntity: Entity, HasModel, HasCollision {
    var annotationID: UUID
    var annotation: Annotation

    init(annotation: Annotation) {
        self.annotationID = annotation.id
        self.annotation = annotation
        super.init()

        // Create visual representation
        setupAppearance()
        setupCollision()
        setupInteraction()
    }

    private func setupAppearance() {
        switch annotation.type {
        case .text:
            createTextCard()
        case .photo:
            createPhotoFrame()
        case .drawing:
            createDrawingCanvas()
        case .voiceMemo:
            createAudioPlayer()
        case .video:
            createVideoPlayer()
        case .object3D:
            load3DModel()
        }
    }

    private func createTextCard() {
        // Create a billboard-style card with text
        let mesh = MeshResource.generatePlane(width: 0.3, height: 0.2)

        var material = UnlitMaterial()
        material.color = .init(tint: .white)

        model = ModelComponent(mesh: mesh, materials: [material])

        // Add text as attachment (SwiftUI view)
        // Implementation in AnnotationRenderer
    }
}
```

### 6.2 Billboard Behavior (Face User)

```swift
extension AnnotationEntity {
    /// Make annotation always face the user
    func updateOrientation(cameraTransform: Transform) {
        let annotationPosition = position(relativeTo: nil)
        let cameraPosition = SIMD3<Float>(
            cameraTransform.translation.x,
            cameraTransform.translation.y,
            cameraTransform.translation.z
        )

        // Calculate look-at rotation
        let direction = normalize(cameraPosition - annotationPosition)
        let up = SIMD3<Float>(0, 1, 0)
        let right = normalize(cross(up, direction))
        let trueUp = cross(direction, right)

        let rotationMatrix = simd_float3x3(right, trueUp, direction)
        let quaternion = simd_quatf(rotationMatrix)

        // Apply rotation
        orientation = quaternion
    }
}
```

### 6.3 LOD (Level of Detail)

```swift
enum AnnotationLOD {
    case full // < 2 meters: Full detail
    case simplified // 2-5 meters: Simplified view
    case icon // 5-10 meters: Just icon
    case hidden // > 10 meters: Not rendered
}

extension AnnotationEntity {
    func updateLOD(distance: Float) {
        let lod = calculateLOD(distance: distance)

        switch lod {
        case .full:
            showFullDetail()
        case .simplified:
            showSimplified()
        case .icon:
            showIcon()
        case .hidden:
            isEnabled = false
        }
    }

    private func calculateLOD(distance: Float) -> AnnotationLOD {
        switch distance {
        case 0..<2: return .full
        case 2..<5: return .simplified
        case 5..<10: return .icon
        default: return .hidden
        }
    }
}
```

---

## 7. ARSession Management

### 7.1 Session Lifecycle

```swift
@MainActor
class ARSessionManager: ObservableObject {
    @Published var state: ARSessionState = .stopped
    @Published var trackingQuality: TrackingQuality = .unknown

    private var realityKitContent: RealityViewContent?
    private let anchorManager: AnchorManager
    private let annotationRenderer: AnnotationRenderer

    func startSession() {
        state = .starting
        // visionOS automatically starts AR session
        // We just need to set up our entities
        setupScene()
        state = .running
    }

    func stopSession() {
        state = .stopping
        cleanup()
        state = .stopped
    }

    private func setupScene() {
        // Create root anchor for all annotations
        // Load annotations from database
        // Create RealityKit entities
    }

    func update(deltaTime: TimeInterval, cameraTransform: Transform) {
        // Update billboard orientations
        // Update LOD based on distance
        // Cull offscreen annotations
        annotationRenderer.update(
            deltaTime: deltaTime,
            cameraTransform: cameraTransform
        )
    }
}

enum ARSessionState {
    case stopped
    case starting
    case running
    case paused
    case stopping
}

enum TrackingQuality {
    case unknown
    case poor
    case normal
    case excellent
}
```

### 7.2 Error Handling

```swift
enum ARError: LocalizedError {
    case sessionFailed
    case trackingLost
    case worldMapNotFound
    case anchorCreationFailed
    case relocalizationFailed

    var errorDescription: String? {
        switch self {
        case .sessionFailed:
            return "Failed to start AR session"
        case .trackingLost:
            return "AR tracking lost. Try moving device slowly."
        case .worldMapNotFound:
            return "No saved world map found for this space"
        case .anchorCreationFailed:
            return "Failed to create spatial anchor"
        case .relocalizationFailed:
            return "Could not relocalize in this space. Create new annotations?"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .trackingLost:
            return "Move your device slowly and ensure good lighting"
        case .relocalizationFailed:
            return "Make sure you're in the same physical location"
        default:
            return nil
        }
    }
}
```

---

## 8. Spatial Queries

### 8.1 Finding Nearby Annotations

```swift
protocol SpatialQueryService {
    /// Find annotations within radius of position
    func findAnnotations(
        near position: SIMD3<Float>,
        radius: Float
    ) async -> [Annotation]

    /// Find annotations in view frustum
    func findAnnotations(in frustum: ViewFrustum) async -> [Annotation]

    /// Find annotations intersecting ray (for tap selection)
    func raycast(from origin: SIMD3<Float>, direction: SIMD3<Float>) async -> Annotation?
}

class DefaultSpatialQueryService: SpatialQueryService {
    private let repository: AnnotationRepository

    func findAnnotations(near position: SIMD3<Float>, radius: Float) async -> [Annotation] {
        let allAnnotations = await repository.fetchAll()

        return allAnnotations.filter { annotation in
            let distance = simd_distance(annotation.position, position)
            return distance <= radius
        }
    }

    func findAnnotations(in frustum: ViewFrustum) async -> [Annotation] {
        let allAnnotations = await repository.fetchAll()

        return allAnnotations.filter { annotation in
            frustum.contains(annotation.position)
        }
    }

    func raycast(from origin: SIMD3<Float>, direction: SIMD3<Float>) async -> Annotation? {
        let allAnnotations = await repository.fetchAll()

        var closest: (annotation: Annotation, distance: Float)?

        for annotation in allAnnotations {
            if let distance = rayIntersects(annotation: annotation, from: origin, direction: direction) {
                if closest == nil || distance < closest!.distance {
                    closest = (annotation, distance)
                }
            }
        }

        return closest?.annotation
    }

    private func rayIntersects(
        annotation: Annotation,
        from origin: SIMD3<Float>,
        direction: SIMD3<Float>
    ) -> Float? {
        // Simplified: Treat annotation as sphere
        let radius: Float = 0.15 * annotation.scale // 15cm radius

        let oc = origin - annotation.position
        let a = dot(direction, direction)
        let b = 2.0 * dot(oc, direction)
        let c = dot(oc, oc) - radius * radius
        let discriminant = b * b - 4 * a * c

        if discriminant < 0 {
            return nil // No intersection
        } else {
            let t = (-b - sqrt(discriminant)) / (2.0 * a)
            return t > 0 ? t : nil
        }
    }
}

struct ViewFrustum {
    var planes: [SIMD4<Float>] // 6 frustum planes

    func contains(_ point: SIMD3<Float>) -> Bool {
        for plane in planes {
            let distance = dot(SIMD3(plane.x, plane.y, plane.z), point) + plane.w
            if distance < 0 {
                return false // Outside this plane
            }
        }
        return true // Inside all planes
    }
}
```

### 8.2 Spatial Indexing (Future Optimization)

For large numbers of annotations, implement spatial partitioning:

```swift
/// Octree for efficient spatial queries
class AnnotationOctree {
    private var root: OctreeNode
    private let maxDepth = 5
    private let maxAnnotationsPerNode = 8

    func insert(_ annotation: Annotation) {
        root.insert(annotation, depth: 0, maxDepth: maxDepth)
    }

    func query(near position: SIMD3<Float>, radius: Float) -> [Annotation] {
        var results: [Annotation] = []
        root.query(near: position, radius: radius, results: &results)
        return results
    }
}

class OctreeNode {
    var bounds: AxisAlignedBoundingBox
    var annotations: [Annotation] = []
    var children: [OctreeNode]?

    // Implementation...
}
```

---

## 9. Multi-User Spatial Consistency

### 9.1 Shared Spaces

When multiple users are in same physical space:

**Challenge**: Each user's AR session has its own coordinate system

**Solution**: Anchor alignment

```swift
protocol SpaceAlignmentService {
    /// Request alignment with another user's coordinate system
    func alignWith(user: User) async throws

    /// Share alignment anchor
    func shareAnchor(_ anchorID: UUID, with user: User) async throws
}

class DefaultSpaceAlignmentService: SpaceAlignmentService {
    func alignWith(user: User) async throws {
        // 1. Both users look at same physical feature (e.g., QR code, image)
        // 2. Create anchor at that feature
        // 3. Share anchor transform
        // 4. Align coordinate systems

        // For MVP: Users manually "sync" by creating annotation at same location
        // Future: Automatic alignment using SharePlay + collaborative session
    }
}
```

### 9.2 Coordinate System Drift

Over time, AR tracking can drift. Mitigation:

```swift
class DriftCorrection {
    private var referenceAnchors: [UUID: ReferenceAnchorData] = [:]

    /// Periodically check if anchors have drifted
    func checkForDrift() async {
        for (id, referenceData) in referenceAnchors {
            guard let currentAnchor = anchorManager.anchor(for: id) else { continue }

            let currentTransform = currentAnchor.transform
            let drift = calculateDrift(
                current: currentTransform,
                reference: referenceData.transform
            )

            if drift > acceptableDriftThreshold {
                // Attempt relocalization
                await attemptRelocalization(anchorID: id)
            }
        }
    }

    private func calculateDrift(
        current: Transform,
        reference: Transform
    ) -> Float {
        let translationDrift = simd_distance(
            current.translation,
            reference.translation
        )
        // Simplified: just check translation drift
        return translationDrift
    }

    private let acceptableDriftThreshold: Float = 0.05 // 5cm
}

struct ReferenceAnchorData {
    var transform: Transform
    var lastUpdated: Date
}
```

---

## 10. Performance Optimization

### 10.1 Rendering Budget

```swift
struct RenderingBudget {
    var maxVisibleAnnotations = 100
    var maxActiveAnchors = 30
    var updateFrequency: TimeInterval = 1.0 / 60.0 // 60 FPS
}

class AnnotationRenderer {
    private let budget: RenderingBudget

    func update(deltaTime: TimeInterval, cameraTransform: Transform) {
        // 1. Cull annotations outside view frustum
        let visibleAnnotations = cullByFrustum(cameraTransform)

        // 2. Sort by distance
        let sortedByDistance = visibleAnnotations.sorted {
            distance($0, to: cameraTransform) < distance($1, to: cameraTransform)
        }

        // 3. Take only top N by budget
        let toRender = Array(sortedByDistance.prefix(budget.maxVisibleAnnotations))

        // 4. Update LOD for each
        for annotation in toRender {
            let dist = distance(annotation, to: cameraTransform)
            annotation.updateLOD(distance: dist)
        }

        // 5. Disable entities beyond budget
        disableExcessEntities(keep: Set(toRender.map { $0.id }))
    }
}
```

### 10.2 Lazy Loading

```swift
class LazyAnnotationLoader {
    private var loadedAnnotations = Set<UUID>()

    func loadAnnotationsInView(cameraTransform: Transform) async {
        let nearby = await spatialQuery.findAnnotations(
            near: cameraTransform.translation,
            radius: 20.0 // Load within 20 meters
        )

        for annotation in nearby where !loadedAnnotations.contains(annotation.id) {
            await loadAnnotation(annotation)
            loadedAnnotations.insert(annotation.id)
        }

        // Unload distant annotations
        await unloadDistantAnnotations(cameraTransform: cameraTransform)
    }

    private func loadAnnotation(_ annotation: Annotation) async {
        // Load media assets if needed
        if let mediaURL = annotation.content.mediaURL {
            await mediaCache.load(mediaURL)
        }

        // Create RealityKit entity
        await annotationRenderer.createEntity(for: annotation)
    }

    private func unloadDistantAnnotations(cameraTransform: Transform) async {
        let toUnload = loadedAnnotations.filter { id in
            guard let annotation = annotationCache[id] else { return true }
            let distance = simd_distance(
                annotation.position,
                cameraTransform.translation
            )
            return distance > 30.0 // Unload beyond 30 meters
        }

        for id in toUnload {
            await annotationRenderer.removeEntity(for: id)
            loadedAnnotations.remove(id)
        }
    }
}
```

---

## 11. Testing AR Features

### 11.1 Challenges

- Can't easily test AR on CI/CD
- Simulator has limited AR capabilities
- Need real device testing

### 11.2 Mock AR Session

```swift
protocol ARSessionProtocol {
    func start()
    func stop()
    func addAnchor(at position: SIMD3<Float>) async throws -> UUID
}

// Real implementation
class RealARSession: ARSessionProtocol { ... }

// Mock for testing
class MockARSession: ARSessionProtocol {
    var anchors: [UUID: SIMD3<Float>] = [:]

    func addAnchor(at position: SIMD3<Float>) async throws -> UUID {
        let id = UUID()
        anchors[id] = position
        return id
    }
}

// In tests
func testAnnotationCreation() async throws {
    let mockSession = MockARSession()
    let service = AnnotationService(arSession: mockSession)

    let annotation = try await service.createAnnotation(
        content: "Test",
        position: SIMD3(0, 1, -2)
    )

    XCTAssertEqual(mockSession.anchors.count, 1)
}
```

---

## 12. Fallback Strategies

### 12.1 When AR Fails

```swift
enum ARFallbackMode {
    case fullAR // Normal mode
    case degradedAR // Some features disabled
    case noAR // List view only
}

class ARFallbackManager {
    @Published var currentMode: ARFallbackMode = .fullAR

    func handleARFailure(_ error: ARError) {
        switch error {
        case .trackingLost:
            // Temporary issue, stay in AR but show warning
            showTrackingWarning()

        case .relocalizationFailed:
            // Can't find anchors, offer to create new space
            currentMode = .degradedAR
            offerNewSpaceCreation()

        case .sessionFailed:
            // Critical failure, fall back to list view
            currentMode = .noAR
            showListViewOnly()
        }
    }

    private func showListViewOnly() {
        // Display annotations in 2D list
        // Still functional, just no spatial component
    }
}
```

---

## 13. Appendix

### 13.1 visionOS AR Best Practices

1. **Anchor to planes** when possible (more stable)
2. **Group annotations** under shared anchors (performance)
3. **Limit anchor count** (max 20-30 active)
4. **Use billboards** for text (always readable)
5. **Implement LOD** (performance at scale)
6. **Test relocalization** frequently (main pain point)
7. **Provide visual feedback** for tracking quality

### 13.2 Common Pitfalls

- ❌ Creating anchor per annotation (too many anchors)
- ❌ Not handling relocalization failure
- ❌ Anchoring to moving objects
- ❌ Ignoring tracking quality
- ❌ No LOD implementation (performance issues)

### 13.3 References

- [visionOS Spatial Computing](https://developer.apple.com/visionos/)
- [RealityKit Anchors](https://developer.apple.com/documentation/realitykit/anchoring-content)
- [ARKit World Tracking](https://developer.apple.com/documentation/arkit)
- [Spatial Computing Best Practices](https://developer.apple.com/wwdc23/)

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture, Data Model
**Next Steps**: Create CloudKit Sync Strategy document
