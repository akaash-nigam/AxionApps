# RealityKit Implementation Guide
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document provides detailed implementation guidance for RealityKit-based 3D visualizations in the Living Building System, with focus on energy flow particle systems, spatial anchoring, and performance optimization.

## 2. RealityKit Architecture

### 2.1 Entity-Component System

```swift
// Base entity structure
class FlowVisualizationEntity: Entity {
    var flowComponent: FlowComponent
    var particleComponent: ParticleEmitterComponent
    var audioComponent: AudioPlaybackComponent

    required init() {
        self.flowComponent = FlowComponent()
        self.particleComponent = ParticleEmitterComponent()
        self.audioComponent = AudioPlaybackComponent()
        super.init()
    }
}
```

### 2.2 Component Types

```swift
// Custom component for energy flow
struct FlowComponent: Component {
    var sourcePosition: SIMD3<Float>
    var destinationPosition: SIMD3<Float>
    var flowRate: Double // kW
    var energyType: EnergyType
    var isActive: Bool = true
}

// Particle system component wrapper
extension ParticleEmitterComponent {
    static func energyFlow(
        flowRate: Double,
        color: UIColor,
        particleCount: Int
    ) -> ParticleEmitterComponent {
        var component = ParticleEmitterComponent()
        component.emitterShape = .point
        component.birthRate = Float(flowRate * 10) // Scale to flow rate
        component.lifeSpan = 2.0
        component.speed = 0.5
        component.color = .constant(color)
        component.size = 0.01
        return component
    }
}
```

## 3. Energy Flow Visualization

### 3.1 Particle System Setup

```swift
class EnergyFlowRenderer {
    private var rootEntity: Entity?
    private var flowEntities: [UUID: Entity] = [:]

    func createFlowVisualization(
        from source: SIMD3<Float>,
        to destination: SIMD3<Float>,
        power: Double,
        energyType: EnergyType
    ) -> Entity {
        let flowEntity = Entity()

        // Create particle emitter
        let particleComponent = ParticleEmitterComponent.energyFlow(
            flowRate: power,
            color: colorForPower(power),
            particleCount: Int(power * 50)
        )
        flowEntity.components.set(particleComponent)

        // Position at source
        flowEntity.position = source

        // Create flow path using spline
        let path = createFlowPath(from: source, to: destination)
        animateParticlesAlongPath(entity: flowEntity, path: path)

        // Add glow effect
        addGlowEffect(to: flowEntity, intensity: Float(power / 5.0))

        return flowEntity
    }

    private func createFlowPath(
        from source: SIMD3<Float>,
        to destination: SIMD3<Float>
    ) -> [SIMD3<Float>] {
        // Create smooth spline curve
        var points: [SIMD3<Float>] = []
        let steps = 20

        for i in 0...steps {
            let t = Float(i) / Float(steps)
            // Catmull-Rom spline for smooth curves
            let point = interpolate(from: source, to: destination, t: t)
            points.append(point)
        }

        return points
    }

    private func animateParticlesAlongPath(
        entity: Entity,
        path: [SIMD3<Float>]
    ) {
        // Animate entity position along path
        var transforms: [Transform] = []
        for point in path {
            var transform = Transform()
            transform.translation = point
            transforms.append(transform)
        }

        // Create animation
        let duration: TimeInterval = 2.0
        entity.move(
            to: transforms.last!,
            relativeTo: nil,
            duration: duration,
            timingFunction: .linear
        )

        // Loop animation
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(duration))
                entity.position = path.first!
                entity.move(
                    to: transforms.last!,
                    relativeTo: nil,
                    duration: duration,
                    timingFunction: .linear
                )
            }
        }
    }

    private func colorForPower(_ power: Double) -> UIColor {
        let hue = CGFloat(max(0, min(1, 1 - (power / 5.0)))) * 0.33 // Green to Red
        return UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    }

    private func addGlowEffect(to entity: Entity, intensity: Float) {
        guard let modelComponent = entity.components[ModelComponent.self] else { return }

        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(CGFloat(intensity)))
        material.blending = .transparent(opacity: .init(floatLiteral: Double(intensity)))

        // Apply emissive glow
        // modelComponent.materials = [material]
    }
}
```

### 3.2 Real-Time Updates

```swift
class FlowVisualizationSystem: System {
    static let query = EntityQuery(where: .has(FlowComponent.self))

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var flowComponent = entity.components[FlowComponent.self] else { continue }

            // Update particle emission based on flow rate
            if var particleComponent = entity.components[ParticleEmitterComponent.self] {
                particleComponent.birthRate = Float(flowComponent.flowRate * 10)
                entity.components.set(particleComponent)
            }

            // Update color based on energy level
            updateColor(for: entity, flowRate: flowComponent.flowRate)
        }
    }

    private func updateColor(for entity: Entity, flowRate: Double) {
        // Smoothly transition colors
        let targetColor = colorForFlowRate(flowRate)
        // Apply color transition
    }

    private func colorForFlowRate(_ rate: Double) -> UIColor {
        let hue = CGFloat(max(0, min(1, 1 - (rate / 5.0)))) * 0.33
        return UIColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1.0)
    }
}
```

## 4. Spatial Anchoring

### 4.1 ARKit Integration

```swift
class SpatialAnchorManager {
    private var anchors: [UUID: ARAnchor] = [:]
    private let arSession: ARKitSession

    init() {
        self.arSession = ARKitSession()
    }

    func placeAnchor(
        at position: SIMD3<Float>,
        for roomID: UUID
    ) async throws -> UUID {
        // Create anchor
        let anchor = AnchorEntity(.world(transform: makeTransform(at: position)))

        // Make persistent
        let persistentAnchor = try await arSession.addAnchor(anchor)

        let anchorID = UUID()
        anchors[anchorID] = persistentAnchor

        // Save to database
        await saveAnchor(anchorID: anchorID, roomID: roomID, position: position)

        return anchorID
    }

    func loadAnchors(for roomID: UUID) async throws -> [ARAnchor] {
        // Load from database
        let savedAnchors = await loadSavedAnchors(for: roomID)

        var loadedAnchors: [ARAnchor] = []
        for savedAnchor in savedAnchors {
            if let persistentID = savedAnchor.persistentIdentifier,
               let anchor = try? await arSession.lookupAnchor(persistentID) {
                loadedAnchors.append(anchor)
            }
        }

        return loadedAnchors
    }

    private func makeTransform(at position: SIMD3<Float>) -> simd_float4x4 {
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4(position.x, position.y, position.z, 1)
        return transform
    }

    private func saveAnchor(
        anchorID: UUID,
        roomID: UUID,
        position: SIMD3<Float>
    ) async {
        // Save to SwiftData
    }

    private func loadSavedAnchors(for roomID: UUID) async -> [RoomAnchor] {
        // Load from SwiftData
        []
    }
}
```

### 4.2 Contextual Display Anchoring

```swift
struct ContextualDisplayAnchor: View {
    let room: Room
    @State private var anchorEntity: AnchorEntity?

    var body: some View {
        RealityView { content in
            // Find or create anchor for this room
            if let anchorPosition = room.displayAnchorPosition {
                let anchor = AnchorEntity(.world(transform: makeTransform(at: anchorPosition)))

                // Add display content
                let displayEntity = createDisplayEntity(for: room)
                anchor.addChild(displayEntity)

                content.add(anchor)
                anchorEntity = anchor
            }
        } update: { content in
            // Update display content when room data changes
            updateDisplayContent(for: room)
        }
    }

    private func createDisplayEntity(for room: Room) -> Entity {
        let entity = Entity()

        // Add 3D text, widgets, etc.
        let textMesh = MeshResource.generateText(
            room.name,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1)
        )

        var material = UnlitMaterial()
        material.color = .init(tint: .white)

        let textModel = ModelComponent(mesh: textMesh, materials: [material])
        entity.components.set(textModel)

        return entity
    }

    private func makeTransform(at position: SIMD3<Float>) -> simd_float4x4 {
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4(position.x, position.y, position.z, 1)
        return transform
    }

    private func updateDisplayContent(for room: Room) {
        // Update entity components based on room state
    }
}
```

## 5. 3D Models & Materials

### 5.1 Device Models

```swift
class DeviceModelLoader {
    func loadModel(for deviceType: DeviceType) async throws -> Entity {
        // Load USDZ models
        let modelName = deviceType.modelFileName
        let entity = try await Entity(named: modelName, in: realityKitContentBundle)

        // Apply materials
        applyMaterials(to: entity, for: deviceType)

        return entity
    }

    private func applyMaterials(to entity: Entity, for deviceType: DeviceType) {
        entity.enumerateHierarchy { entity, stop in
            guard var modelComponent = entity.components[ModelComponent.self] else { return }

            // Apply physically-based material
            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(tint: deviceType.primaryColor)
            material.roughness = 0.5
            material.metallic = 0.3

            modelComponent.materials = [material]
            entity.components.set(modelComponent)
        }
    }
}

extension DeviceType {
    var modelFileName: String {
        switch self {
        case .light: "LightBulb.usdz"
        case .thermostat: "Thermostat.usdz"
        case .camera: "Camera.usdz"
        default: "GenericDevice.usdz"
        }
    }

    var primaryColor: UIColor {
        switch self {
        case .light: .yellow
        case .thermostat: .systemBlue
        case .camera: .darkGray
        default: .systemGray
        }
    }
}
```

### 5.2 Material Shaders

```swift
// Custom shader for energy glow effect
extension ShaderGraphMaterial {
    static func energyGlow(intensity: Float) throws -> ShaderGraphMaterial {
        let shader = CustomMaterial.SurfaceShader(
            named: "EnergyGlowShader",
            in: .main
        )

        var material = try ShaderGraphMaterial(surfaceShader: shader)
        material.setParameter("intensity", value: .float(intensity))

        return material
    }
}
```

## 6. Occlusion & Rendering

### 6.1 Mesh Occlusion

```swift
class OcclusionManager {
    func enableOcclusion(for entity: Entity) {
        // Enable occlusion by real-world geometry
        entity.components.set(OcclusionComponent())
    }

    func createOcclusionMesh(from sceneMesh: MeshAnchor) -> Entity {
        let entity = Entity()

        let meshResource = MeshResource.generate(from: sceneMesh.geometry)
        var material = OcclusionMaterial()

        let modelComponent = ModelComponent(mesh: meshResource, materials: [material])
        entity.components.set(modelComponent)

        return entity
    }
}
```

### 6.2 Level of Detail (LOD)

```swift
class LODSystem: System {
    static let query = EntityQuery(where: .has(ModelComponent.self))

    func update(context: SceneUpdateContext) {
        guard let cameraPosition = context.scene.activeCamera?.position else { return }

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            let distance = simd_distance(entity.position, cameraPosition)

            // Adjust detail based on distance
            updateLOD(for: entity, distance: distance)
        }
    }

    private func updateLOD(for entity: Entity, distance: Float) {
        guard var modelComponent = entity.components[ModelComponent.self] else { return }

        // Reduce particle count for distant flows
        if var particleComponent = entity.components[ParticleEmitterComponent.self] {
            if distance > 3.0 {
                particleComponent.birthRate *= 0.5 // Reduce particles
            }
            entity.components.set(particleComponent)
        }

        // Simplify materials
        if distance > 5.0 {
            // Use simpler unlit materials
            var material = UnlitMaterial()
            material.color = .init(tint: .white)
            modelComponent.materials = [material]
            entity.components.set(modelComponent)
        }
    }
}
```

## 7. Performance Optimization

### 7.1 Entity Pooling

```swift
class EntityPool {
    private var availableEntities: [Entity] = []
    private var activeEntities: Set<Entity> = []

    func acquire() -> Entity {
        if let entity = availableEntities.popLast() {
            activeEntities.insert(entity)
            return entity
        } else {
            let entity = createNewEntity()
            activeEntities.insert(entity)
            return entity
        }
    }

    func release(_ entity: Entity) {
        entity.isEnabled = false
        activeEntities.remove(entity)
        availableEntities.append(entity)
    }

    private func createNewEntity() -> Entity {
        let entity = Entity()
        // Setup default components
        return entity
    }
}
```

### 7.2 Batch Updates

```swift
class BatchedFlowUpdater {
    private var pendingUpdates: [UUID: FlowUpdate] = [:]
    private let updateInterval: TimeInterval = 1.0 / 30.0 // 30 Hz

    func scheduleUpdate(flowID: UUID, newRate: Double) {
        pendingUpdates[flowID] = FlowUpdate(flowRate: newRate, timestamp: Date())
    }

    func processBatch() {
        for (flowID, update) in pendingUpdates {
            applyUpdate(flowID: flowID, update: update)
        }
        pendingUpdates.removeAll()
    }

    private func applyUpdate(flowID: UUID, update: FlowUpdate) {
        // Apply batched updates to entities
    }
}

struct FlowUpdate {
    let flowRate: Double
    let timestamp: Date
}
```

## 8. Collision & Interaction

### 8.1 Tap Handling

```swift
struct InteractiveDevice: View {
    let device: SmartDevice
    @State private var entity: Entity?

    var body: some View {
        RealityView { content in
            let deviceEntity = try? await DeviceModelLoader().loadModel(for: device.deviceType)
            deviceEntity?.components.set(InputTargetComponent())
            deviceEntity?.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)]))

            content.add(deviceEntity!)
            entity = deviceEntity
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(entity)
                .onEnded { value in
                    handleTap(on: device)
                }
        )
    }

    private func handleTap(on device: SmartDevice) {
        // Toggle device
        Task {
            try? await deviceManager.toggleDevice(device)
        }

        // Haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        // Audio cue
        playAudioCue(.deviceToggled, at: entity?.position)
    }
}
```

## 9. Debugging & Visualization

### 9.1 Debug Overlays

```swift
#if DEBUG
extension Entity {
    func enableDebugVisualization() {
        // Show bounding box
        let bounds = visualBounds(relativeTo: nil)
        let boxMesh = MeshResource.generateBox(size: bounds.extents)

        var material = UnlitMaterial()
        material.color = .init(tint: .green.withAlphaComponent(0.3))

        let debugModel = ModelComponent(mesh: boxMesh, materials: [material])
        let debugEntity = Entity()
        debugEntity.components.set(debugModel)
        debugEntity.position = bounds.center

        addChild(debugEntity)
    }
}
#endif
```

### 9.2 Performance Monitoring

```swift
class RealityKitPerformanceMonitor {
    private var frameCount = 0
    private var lastTime = Date()

    func update() {
        frameCount += 1

        let now = Date()
        let elapsed = now.timeIntervalSince(lastTime)

        if elapsed >= 1.0 {
            let fps = Double(frameCount) / elapsed
            print("RealityKit FPS: \(fps)")

            frameCount = 0
            lastTime = now
        }
    }
}
```

---

**Document Owner**: Graphics Team
**Review Cycle**: On major RealityKit updates
**Next Review**: As needed
