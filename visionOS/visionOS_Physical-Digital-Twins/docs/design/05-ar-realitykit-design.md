# AR & RealityKit Design Document

## Overview

This document defines the augmented reality and spatial computing implementation for Physical-Digital Twins on visionOS. The app creates spatial digital twins that appear anchored to physical objects in the user's environment.

## visionOS Spatial Computing Model

### App Structure

```
┌──────────────────────────────────────────┐
│           WindowGroup                    │
│   (2D inventory management interface)    │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│        ImmersiveSpace                    │
│   (AR scanning and twin visualization)   │
│                                          │
│  ┌────────────┐  ┌────────────┐        │
│  │ Physical   │  │ Digital    │        │
│  │ Object     │─▶│ Twin Card  │        │
│  │ (Real)     │  │ (Virtual)  │        │
│  └────────────┘  └────────────┘        │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│           Volume                         │
│  (3D assembly instructions viewer)       │
└──────────────────────────────────────────┘
```

### Scene Hierarchy

```swift
@main
struct PhysicalDigitalTwinsApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        // 2D Window for inventory management
        WindowGroup {
            ContentView()
                .environment(appState)
        }

        // Immersive space for AR scanning
        ImmersiveSpace(id: "scanning") {
            ScanningSpaceView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)

        // Volume for 3D instructions
        WindowGroup(id: "assembly-instructions") {
            AssemblyInstructionsView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)
    }
}
```

## RealityKit Components

### Digital Twin Entity

```swift
import RealityKit

class DigitalTwinEntity: Entity, HasAnchoring, HasCollision {
    let twinID: UUID
    var infoCard: Entity
    var highlightRing: Entity?
    var interactionComponent: InteractionComponent

    init(twin: any DigitalTwin, anchor: AnchoringComponent) {
        self.twinID = twin.id
        self.infoCard = Self.createInfoCard(for: twin)
        super.init()

        // Set up anchoring to physical object
        self.anchoring = anchor

        // Add collision for ray casting
        self.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.01])])

        // Add info card as child
        self.addChild(infoCard)

        // Set up interaction component
        self.interactionComponent = InteractionComponent()
        self.components.set(interactionComponent)
    }

    required init() {
        fatalError("Use init(twin:anchor:)")
    }

    static func createInfoCard(for twin: any DigitalTwin) -> Entity {
        // Create 3D card with info
        let cardEntity = Entity()

        // Background panel
        let panelMesh = MeshResource.generatePlane(width: 0.3, height: 0.2, cornerRadius: 0.02)
        var panelMaterial = UnlitMaterial()
        panelMaterial.color = .init(tint: .white.withAlphaComponent(0.9))
        let panel = ModelEntity(mesh: panelMesh, materials: [panelMaterial])

        cardEntity.addChild(panel)

        // Text content (will use SwiftUI attachment)
        return cardEntity
    }

    func showHighlight() {
        guard highlightRing == nil else { return }

        let ringMesh = MeshResource.generatePlane(width: 0.35, height: 0.25, cornerRadius: 0.02)
        var ringMaterial = UnlitMaterial()
        ringMaterial.color = .init(tint: .blue.withAlphaComponent(0.5))

        let ring = ModelEntity(mesh: ringMesh, materials: [ringMaterial])
        ring.position.z = -0.001 // Slightly behind card

        self.addChild(ring)
        self.highlightRing = ring

        // Animate glow
        var transform = ring.transform
        transform.scale = [1.0, 1.0, 1.0]
        ring.move(to: transform, relativeTo: nil, duration: 0.3)
    }

    func hideHighlight() {
        highlightRing?.removeFromParent()
        highlightRing = nil
    }
}
```

### Custom Components

```swift
// Component for interaction state
struct InteractionComponent: Component {
    var isGazed: Bool = false
    var isSelected: Bool = false
}

// Component for anchoring to recognized objects
struct ObjectAnchorComponent: Component {
    let recognizedObjectID: UUID
    var trackingState: TrackingState

    enum TrackingState {
        case tracking
        case limited
        case lost
    }
}

// Component for animation state
struct TwinAnimationComponent: Component {
    var isAnimating: Bool = false
    var animationType: AnimationType

    enum AnimationType {
        case fadeIn
        case pulse
        case expand
        case none
    }
}
```

## Anchoring Strategies

### 1. World Anchoring (Default)

**Use Case**: General objects without specific plane detection

```swift
class WorldAnchoringStrategy {
    func anchor(entity: Entity, at position: SIMD3<Float>) {
        let anchorComponent = AnchoringComponent(.world(transform: Transform(
            scale: [1, 1, 1],
            rotation: simd_quatf(),
            translation: position
        )))

        entity.anchoring = anchorComponent
    }
}
```

### 2. Image Anchoring

**Use Case**: Books, posters with recognizable images

```swift
class ImageAnchoringStrategy {
    func anchor(entity: Entity, to image: ReferenceImage) async throws {
        // Use ARKit image tracking
        let imageAnchor = AnchorEntity(.image(group: "recognizedObjects", name: image.name))
        imageAnchor.addChild(entity)
    }
}

struct ReferenceImage {
    let name: String
    let physicalWidth: Float // in meters
    let image: CGImage
}
```

### 3. Object Anchoring

**Use Case**: Recognized 3D objects (furniture, appliances)

```swift
class ObjectAnchoringStrategy {
    func anchor(entity: Entity, to objectAnchor: ARObjectAnchor) {
        let anchor = AnchorEntity(.anchor(identifier: objectAnchor.identifier))
        anchor.addChild(entity)
    }
}
```

### 4. Plane Anchoring

**Use Case**: Items on tables, shelves

```swift
class PlaneAnchoringStrategy {
    func anchor(entity: Entity, onPlane plane: ARPlaneAnchor) {
        let anchor = AnchorEntity(.plane(
            .horizontal,
            classification: plane.classification,
            minimumBounds: [0.1, 0.1]
        ))

        // Position entity at detected location
        var transform = entity.transform
        transform.translation = [plane.transform.columns.3.x,
                                plane.transform.columns.3.y,
                                plane.transform.columns.3.z]
        entity.transform = transform

        anchor.addChild(entity)
    }
}
```

## Digital Twin Card UI

### SwiftUI + RealityKit Integration

```swift
struct DigitalTwinCard: View {
    let twin: any DigitalTwin

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: twin.objectType.iconName)
                    .font(.title2)
                Text(twin.displayName)
                    .font(.headline)
                Spacer()
            }

            Divider()

            // Content varies by type
            if let bookTwin = twin as? BookTwin {
                BookTwinContent(book: bookTwin)
            } else if let foodTwin = twin as? FoodTwin {
                FoodTwinContent(food: foodTwin)
            }

            // Actions
            HStack {
                Button("Details") {
                    // Show full details in window
                }
                Button("Edit") {
                    // Open editor
                }
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct BookTwinContent: View {
    let book: BookTwin

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("by \(book.author)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let rating = book.averageRating {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                }
            }

            Text("Status: \(book.readingStatus.rawValue)")
                .font(.caption)
        }
    }
}
```

### Attaching SwiftUI to RealityKit

```swift
class DigitalTwinRenderer {
    func createTwinWithSwiftUI(twin: any DigitalTwin) -> Entity {
        let entity = Entity()

        // Create SwiftUI view
        let cardView = DigitalTwinCard(twin: twin)

        // Attach to entity (visionOS feature)
        let attachment = ViewAttachment(cardView)
        entity.components.set(attachment)

        return entity
    }
}
```

## Assembly Instructions Overlay

### AR Instruction System

```swift
class AssemblyInstructionRenderer {
    private var instructionEntities: [Entity] = []

    func showStep(_ step: AssemblyStep, on object: Entity) {
        clearInstructions()

        // Create instruction overlays
        for instruction in step.instructions {
            let entity = createInstructionEntity(instruction)
            positionEntity(entity, relativeTo: object, at: instruction.targetPosition)
            instructionEntities.append(entity)
        }
    }

    private func createInstructionEntity(_ instruction: Instruction) -> Entity {
        let entity = Entity()

        switch instruction.type {
        case .highlight(let area):
            // Highlight specific part
            let highlight = createHighlight(area: area, color: .green)
            entity.addChild(highlight)

        case .arrow(let from, let to):
            // Show directional arrow
            let arrow = createArrow(from: from, to: to)
            entity.addChild(arrow)

        case .text(let message):
            // Floating text
            let textEntity = createTextEntity(message)
            entity.addChild(textEntity)

        case .animation(let animationURL):
            // Animated 3D instructions
            let animatedModel = try? Entity.load(contentsOf: animationURL)
            if let model = animatedModel {
                entity.addChild(model)
            }
        }

        return entity
    }

    private func createHighlight(area: CGRect, color: UIColor) -> Entity {
        let mesh = MeshResource.generateBox(
            width: Float(area.width),
            height: Float(area.height),
            depth: 0.01
        )

        var material = UnlitMaterial()
        material.color = .init(tint: color.withAlphaComponent(0.3))

        let highlight = ModelEntity(mesh: mesh, materials: [material])

        // Pulse animation
        var transform = highlight.transform
        transform.scale = [1.05, 1.05, 1.0]
        highlight.move(to: transform, relativeTo: nil, duration: 0.5)

        return highlight
    }

    private func createArrow(from: SIMD3<Float>, to: SIMD3<Float>) -> Entity {
        // Create arrow from cylinder + cone
        let direction = normalize(to - from)
        let distance = length(to - from)

        let shaft = MeshResource.generateBox(width: 0.01, height: distance - 0.05, depth: 0.01)
        let head = MeshResource.generateCone(height: 0.05, radius: 0.02)

        var material = UnlitMaterial()
        material.color = .init(tint: .blue)

        let shaftEntity = ModelEntity(mesh: shaft, materials: [material])
        let headEntity = ModelEntity(mesh: head, materials: [material])

        // Position head at arrow tip
        headEntity.position = [0, distance / 2, 0]

        let arrow = Entity()
        arrow.addChild(shaftEntity)
        arrow.addChild(headEntity)

        // Rotate arrow to point in correct direction
        arrow.look(at: to, from: from, relativeTo: nil)

        return arrow
    }

    private func createTextEntity(_ text: String) -> Entity {
        // Use TextMesh for 3D text (if available) or SwiftUI attachment
        let entity = Entity()

        // For now, use SwiftUI attachment
        let textView = Text(text)
            .font(.title3)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(8)

        let attachment = ViewAttachment(textView)
        entity.components.set(attachment)

        return entity
    }

    private func positionEntity(_ entity: Entity, relativeTo object: Entity, at position: SIMD3<Float>) {
        entity.position = object.position + position
        object.addChild(entity)
    }

    func clearInstructions() {
        instructionEntities.forEach { $0.removeFromParent() }
        instructionEntities.removeAll()
    }
}

struct AssemblyStep {
    let stepNumber: Int
    let title: String
    let description: String
    let instructions: [Instruction]
    let estimatedTime: TimeInterval?
}

struct Instruction {
    let type: InstructionType
    let targetPosition: SIMD3<Float>
}

enum InstructionType {
    case highlight(area: CGRect)
    case arrow(from: SIMD3<Float>, to: SIMD3<Float>)
    case text(String)
    case animation(URL)
}
```

## Interaction Model

### Gaze + Pinch Interaction

```swift
@MainActor
class SpatialInteractionManager: ObservableObject {
    @Published var gazedEntity: Entity?
    @Published var selectedEntity: Entity?

    private var gestureRecognizer: SpatialTapGesture?

    func setupInteraction(for scene: RealityKit.Scene) {
        // ARKit provides eye tracking automatically on visionOS
        // Use RealityKit's input system for gaze detection

        scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            self?.updateGazeTarget(in: event.scene)
        }.store(in: &cancellables)
    }

    private func updateGazeTarget(in scene: RealityKit.Scene) {
        // Get gaze direction from user's head pose
        guard let gazeDirection = getGazeDirection() else { return }

        // Ray cast to find entity under gaze
        let raycastResult = scene.raycast(
            origin: gazeDirection.origin,
            direction: gazeDirection.direction,
            length: 10.0,
            query: .nearest,
            mask: .default,
            relativeTo: nil
        )

        if let hit = raycastResult.first,
           let entity = hit.entity as? DigitalTwinEntity {
            // Update gaze target
            if gazedEntity != entity {
                gazedEntity?.hideHighlight()
                entity.showHighlight()
                gazedEntity = entity
            }
        } else {
            // No entity under gaze
            gazedEntity?.hideHighlight()
            gazedEntity = nil
        }
    }

    func handleTap(on entity: Entity) {
        selectedEntity = entity

        // Expand entity or show details
        if let twinEntity = entity as? DigitalTwinEntity {
            showDetailsWindow(for: twinEntity.twinID)
        }
    }

    private func getGazeDirection() -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        // visionOS provides this through ARKit
        // Simplified version:
        return (
            origin: [0, 0, 0], // User's head position
            direction: [0, 0, -1] // Forward direction
        )
    }

    private var cancellables = Set<AnyCancellable>()
}
```

### Hand Tracking Gestures

```swift
class HandGestureManager {
    func setupGestures(for view: some View) -> some View {
        view
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        handleTap(on: value.entity)
                    }
            )
            .gesture(
                DragGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        handleDrag(entity: value.entity, translation: value.translation3D)
                    }
            )
    }

    private func handleTap(on entity: Entity) {
        // Open details, toggle state, etc.
    }

    private func handleDrag(entity: Entity, translation: Vector3D) {
        // Move entity (if allowed)
        var transform = entity.transform
        transform.translation += SIMD3<Float>(
            Float(translation.x),
            Float(translation.y),
            Float(translation.z)
        )
        entity.move(to: transform, relativeTo: nil, duration: 0.1)
    }
}
```

## Spatial Persistence

### Saving Anchor Positions

```swift
import ARKit

class SpatialPersistenceManager {
    private let worldMapURL: URL

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.worldMapURL = documentsPath.appendingPathComponent("worldmap.arexperience")
    }

    func saveWorldMap(from session: ARKitSession) async throws {
        // Get current world map
        let worldMap = try await session.worldMap

        // Save anchor positions
        let encodedData = try NSKeyedArchiver.archivedData(
            withRootObject: worldMap,
            requiringSecureCoding: true
        )

        try encodedData.write(to: worldMapURL)
    }

    func loadWorldMap() throws -> ARWorldMap? {
        guard FileManager.default.fileExists(atPath: worldMapURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: worldMapURL)
        let worldMap = try NSKeyedUnarchiver.unarchivedObject(
            ofClass: ARWorldMap.self,
            from: data
        )

        return worldMap
    }

    func saveTwinPosition(twinID: UUID, anchor: ARAnchor) {
        // Store twin position in database
        let anchorData = AnchorPosition(
            twinID: twinID,
            transform: anchor.transform,
            timestamp: Date()
        )

        // Save to Core Data
        PersistenceController.shared.saveAnchorPosition(anchorData)
    }
}

struct AnchorPosition: Codable {
    let twinID: UUID
    let transform: simd_float4x4
    let timestamp: Date
}
```

## Performance Optimization

### Level of Detail (LOD)

```swift
class LODManager {
    func updateLOD(for entities: [DigitalTwinEntity], from cameraPosition: SIMD3<Float>) {
        for entity in entities {
            let distance = length(entity.position - cameraPosition)

            // Adjust detail based on distance
            if distance < 1.0 {
                // High detail (full info card)
                entity.infoCard.isEnabled = true
            } else if distance < 3.0 {
                // Medium detail (icon + title only)
                entity.infoCard.isEnabled = true
                simplifyCard(entity.infoCard)
            } else if distance < 10.0 {
                // Low detail (just icon)
                entity.infoCard.isEnabled = false
                showIconOnly(entity)
            } else {
                // Very far, hide completely
                entity.isEnabled = false
            }
        }
    }

    private func simplifyCard(_ card: Entity) {
        // Remove detailed content, show only essentials
    }

    private func showIconOnly(_ entity: DigitalTwinEntity) {
        // Show just a floating icon
    }
}
```

### Entity Pooling

```swift
class EntityPool {
    private var pool: [ObjectCategory: [Entity]] = [:]

    func getEntity(for category: ObjectCategory) -> Entity {
        if var entities = pool[category], !entities.isEmpty {
            return entities.removeLast()
        } else {
            return createNewEntity(for: category)
        }
    }

    func returnEntity(_ entity: Entity, category: ObjectCategory) {
        entity.removeFromParent()
        pool[category, default: []].append(entity)
    }

    private func createNewEntity(for category: ObjectCategory) -> Entity {
        // Create base entity for category
        return Entity()
    }
}
```

### Frame Rate Targets

```
- Mixed immersion: 90 Hz (target)
- Full immersion: 90 Hz (required)
- Entity count: < 50 visible at once
- Draw calls: < 200 per frame
- Triangle count: < 100k per frame
```

## Accessibility

### VoiceOver Support

```swift
extension DigitalTwinEntity {
    func configureAccessibility() {
        self.accessibilityLabel = twin.displayName
        self.accessibilityHint = "Double tap to view details"
        self.accessibilityTraits = [.button]

        // Custom actions
        self.accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: "View Details",
                target: self,
                selector: #selector(showDetails)
            ),
            UIAccessibilityCustomAction(
                name: "Edit",
                target: self,
                selector: #selector(edit)
            )
        ]
    }
}
```

## Testing AR Features

### RealityKit Unit Tests

```swift
class ARSceneTests: XCTestCase {
    func testEntityCreation() async throws {
        let twin = BookTwin(title: "Test Book", author: "Test Author")
        let entity = DigitalTwinEntity(
            twin: twin,
            anchor: AnchoringComponent(.world(transform: .identity))
        )

        XCTAssertNotNil(entity.infoCard)
        XCTAssertEqual(entity.twinID, twin.id)
    }

    func testAnchorPositioning() async throws {
        let position = SIMD3<Float>(0, 1, -2)
        let strategy = WorldAnchoringStrategy()

        let entity = Entity()
        strategy.anchor(entity: entity, at: position)

        XCTAssertEqual(entity.position, position)
    }
}
```

### AR Simulator Testing

- Use Xcode's visionOS Simulator for basic testing
- Device testing required for:
  - Hand tracking
  - Eye tracking
  - Real-world object recognition
  - Performance validation

## Summary

This AR architecture provides:
- **Spatial Awareness**: Entities anchored to physical objects
- **Rich Interaction**: Gaze, tap, and hand gestures
- **Performance**: LOD, entity pooling, 90Hz target
- **Persistence**: Save anchor positions across sessions
- **Accessibility**: VoiceOver and custom actions
- **Assembly Instructions**: Contextual AR overlays

The spatial computing features are what differentiate this from a standard inventory app—digital twins feel truly connected to physical objects.
