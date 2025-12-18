# Performance Optimization Guide - Tactical Team Shooters

Comprehensive guide to achieving and maintaining 120 FPS on Apple Vision Pro.

## Performance Targets

### Frame Rate
- **Target**: 120 FPS (8.33ms per frame)
- **Minimum**: 90 FPS (11.11ms per frame)
- **Critical**: Never drop below 60 FPS

### Memory
- **Target**: < 2GB total memory
- **Maximum**: < 3GB
- **Texture memory**: < 1GB

### Latency
- **Motion-to-photon**: < 20ms
- **Input lag**: < 10ms
- **Network latency**: < 50ms

### Thermal
- **Sustained performance**: 30+ minutes
- **Temperature**: Stay within thermal limits

## CPU Optimization

### Game Loop Optimization

**120 FPS Game Loop**:

```swift
class GameEngine {
    let targetFrameTime: TimeInterval = 1.0 / 120.0  // 8.33ms
    var accumulator: TimeInterval = 0.0

    func update(deltaTime: TimeInterval) {
        // Profile frame time
        let frameStart = CACurrentMediaTime()

        // Fixed timestep for physics
        accumulator += deltaTime
        while accumulator >= targetFrameTime {
            fixedUpdate(targetFrameTime)
            accumulator -= targetFrameTime
        }

        // Variable timestep for rendering
        variableUpdate(deltaTime)

        // Check frame time
        let frameTime = CACurrentMediaTime() - frameStart
        if frameTime > targetFrameTime {
            print("Frame overrun: \(frameTime * 1000)ms")
        }
    }
}
```

### Task Prioritization

```swift
enum TaskPriority {
    case critical   // Player input, collision detection
    case high       // AI, networking
    case medium     // Animation, audio
    case low        // UI updates, analytics
}

func executeWithPriority(_ priority: TaskPriority, _ task: () -> Void) {
    switch priority {
    case .critical:
        task()  // Execute immediately
    case .high:
        DispatchQueue.global(qos: .userInteractive).async(execute: task)
    case .medium:
        DispatchQueue.global(qos: .userInitiated).async(execute: task)
    case .low:
        DispatchQueue.global(qos: .utility).async(execute: task)
    }
}
```

### Object Pooling

Avoid allocations during gameplay:

```swift
class ObjectPool<T> {
    private var available: [T] = []
    private let factory: () -> T

    init(initialCapacity: Int, factory: @escaping () -> T) {
        self.factory = factory
        for _ in 0..<initialCapacity {
            available.append(factory())
        }
    }

    func acquire() -> T {
        if available.isEmpty {
            return factory()
        }
        return available.removeLast()
    }

    func release(_ object: T) {
        available.append(object)
    }
}

// Usage
let bulletPool = ObjectPool<Bullet>(initialCapacity: 100) {
    Bullet()
}

func fireBullet() {
    let bullet = bulletPool.acquire()
    // Use bullet
}

func onBulletDestroyed(_ bullet: Bullet) {
    bulletPool.release(bullet)
}
```

### Batch Processing

Process similar tasks together:

```swift
// ❌ Bad: Process individually
for player in players {
    updatePlayerPosition(player)
    updatePlayerAnimation(player)
    updatePlayerAudio(player)
}

// ✅ Good: Batch by system
// Position updates (cache-friendly)
for player in players {
    updatePlayerPosition(player)
}

// Animation updates
for player in players {
    updatePlayerAnimation(player)
}

// Audio updates
for player in players {
    updatePlayerAudio(player)
}
```

### Multithreading

Parallelize independent systems:

```swift
actor GameSystems {
    func updateParallel(deltaTime: TimeInterval) async {
        async let physics = updatePhysics(deltaTime)
        async let ai = updateAI(deltaTime)
        async let audio = updateAudio(deltaTime)
        async let particles = updateParticles(deltaTime)

        // Wait for all to complete
        _ = await (physics, ai, audio, particles)
    }
}
```

## GPU Optimization

### Draw Call Reduction

**Instancing**:

```swift
// Render multiple identical objects in one draw call
var instanceTransforms: [simd_float4x4] = []

for bullet in bullets {
    instanceTransforms.append(bullet.transform)
}

// Single draw call for all bullets
meshResource.render(instanceTransforms: instanceTransforms)
```

**Batching**:

```swift
// Combine meshes with same material
let combinedMesh = MeshResource.combine([mesh1, mesh2, mesh3])
```

### LOD (Level of Detail)

```swift
enum LODLevel {
    case high       // < 10m: Full detail
    case medium     // 10-30m: Reduced detail
    case low        // 30-50m: Minimal detail
    case culled     // > 50m: Not rendered
}

func selectLOD(distance: Float) -> LODLevel {
    switch distance {
    case ..<10: return .high
    case 10..<30: return .medium
    case 30..<50: return .low
    default: return .culled
    }
}

// Apply LOD
for entity in visibleEntities {
    let distance = distance(camera.position, entity.position)
    let lod = selectLOD(distance: distance)

    entity.model?.mesh = entity.meshes[lod]
}
```

### Frustum Culling

Only render visible objects:

```swift
func frustumCull(camera: Camera) -> [Entity] {
    entities.filter { entity in
        camera.frustum.contains(entity.boundingBox)
    }
}
```

### Occlusion Culling

Don't render objects behind walls:

```swift
class OcclusionCullingSystem {
    func isVisible(_ entity: Entity, from camera: Camera) -> Bool {
        // Raycast from camera to entity
        let ray = Ray(origin: camera.position, direction: normalize(entity.position - camera.position))

        // Check for obstructions
        if let hit = physicsWorld.raycast(ray, maxDistance: distance(camera.position, entity.position)) {
            // Something is blocking view
            return hit.entity == entity
        }

        return true
    }
}
```

## Memory Optimization

### Texture Optimization

**Compression**:

```swift
// Use compressed texture formats
// ASTC for color textures (good quality, low memory)
// BC7 for high-quality textures
// BC4 for grayscale/normal maps
```

**Mipmaps**:

```swift
// Generate mipmaps for distant objects
textureResource.generateMipmaps()

// Saves GPU bandwidth and improves quality
```

**Texture Streaming**:

```swift
class TextureStreamingSystem {
    func loadTexture(for entity: Entity, distance: Float) {
        let resolution = selectResolution(distance: distance)

        if entity.currentTextureResolution != resolution {
            entity.loadTexture(resolution: resolution)
        }
    }

    func selectResolution(distance: Float) -> TextureResolution {
        switch distance {
        case ..<10: return .full_4K
        case 10..<30: return .medium_2K
        case 30..<50: return .low_1K
        default: return .minimal_512
        }
    }
}
```

### Mesh Optimization

**Vertex Reduction**:

```swift
// Use simplified meshes for distant objects
let simplifiedMesh = meshSimplifier.simplify(
    mesh: originalMesh,
    targetVertexCount: originalMesh.vertexCount / 2
)
```

**Index Buffers**:

```swift
// Use 16-bit indices when possible
if mesh.vertexCount < 65536 {
    mesh.indices = UInt16.indices
} else {
    mesh.indices = UInt32.indices
}
```

### Memory Pooling

```swift
class MemoryPool {
    private var buffers: [UnsafeMutableRawPointer] = []
    private let bufferSize: Int

    init(bufferSize: Int, initialCount: Int) {
        self.bufferSize = bufferSize
        for _ in 0..<initialCount {
            buffers.append(UnsafeMutableRawPointer.allocate(
                byteCount: bufferSize,
                alignment: 16
            ))
        }
    }

    func acquireBuffer() -> UnsafeMutableRawPointer {
        if let buffer = buffers.popLast() {
            return buffer
        }
        return UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 16)
    }

    func releaseBuffer(_ buffer: UnsafeMutableRawPointer) {
        buffers.append(buffer)
    }
}
```

## Physics Optimization

### Spatial Partitioning

```swift
class SpatialHashGrid {
    private var cells: [SIMD2<Int>: [Entity]] = [:]
    private let cellSize: Float = 5.0

    func insert(_ entity: Entity) {
        let cell = getCell(entity.position)
        cells[cell, default: []].append(entity)
    }

    func query(around position: SIMD3<Float>, radius: Float) -> [Entity] {
        var results: [Entity] = []

        // Check nearby cells
        let centerCell = getCell(position)
        let cellRadius = Int(ceil(radius / cellSize))

        for x in -cellRadius...cellRadius {
            for z in -cellRadius...cellRadius {
                let cell = SIMD2(centerCell.x + x, centerCell.y + z)
                if let entities = cells[cell] {
                    results.append(contentsOf: entities)
                }
            }
        }

        return results
    }

    private func getCell(_ position: SIMD3<Float>) -> SIMD2<Int> {
        SIMD2(
            Int(floor(position.x / cellSize)),
            Int(floor(position.z / cellSize))
        )
    }
}
```

### Simplified Collision Shapes

```swift
// ❌ Expensive: Per-polygon collision
let complexShape = ShapeResource.generateConvex(from: mesh)

// ✅ Fast: Simple shapes
let simpleShape = ShapeResource.generateBox(size: boundingBox.size)
let capsuleShape = ShapeResource.generateCapsule(height: 1.8, radius: 0.3)
```

### Collision Layers

```swift
struct CollisionLayer: OptionSet {
    let rawValue: UInt32

    static let player = CollisionLayer(rawValue: 1 << 0)
    static let bullet = CollisionLayer(rawValue: 1 << 1)
    static let environment = CollisionLayer(rawValue: 1 << 2)
    static let pickup = CollisionLayer(rawValue: 1 << 3)
}

// Bullets only collide with players and environment
bulletEntity.collisionFilter = CollisionFilter(
    group: .bullet,
    mask: [.player, .environment]
)
```

## Network Optimization

### Bandwidth Reduction

**Delta Compression**:

```swift
struct CompressedPlayerState {
    let playerId: UUID
    var position: SIMD3<Int16>?  // Quantize position to 16-bit
    var rotation: UInt16?        // Quantize rotation to 16-bit
    var health: UInt8?           // 0-100 fits in 8-bit
}

func compressPosition(_ position: SIMD3<Float>) -> SIMD3<Int16> {
    // Quantize to centimeters
    SIMD3<Int16>(
        Int16(position.x * 100),
        Int16(position.y * 100),
        Int16(position.z * 100)
    )
}
```

**Update Culling**:

```swift
func shouldSendUpdate(player: Player) -> Bool {
    let timeSinceLastUpdate = CACurrentMediaTime() - player.lastUpdateTime

    // Send updates less frequently for distant players
    let distance = distance(localPlayer.position, player.position)
    let updateInterval: TimeInterval

    switch distance {
    case ..<20: updateInterval = 0.05   // 20 Hz
    case 20..<50: updateInterval = 0.1  // 10 Hz
    default: updateInterval = 0.2       // 5 Hz
    }

    return timeSinceLastUpdate >= updateInterval
}
```

## Audio Optimization

### Voice Limits

```swift
enum AudioConstants {
    static let maxSimultaneousSounds = 32
    static let maxFootsteps = 8
    static let maxGunshots = 12
}

class AudioPrioritySystem {
    func playSound(_ sound: AudioResource, priority: Int) {
        if activeSounds.count >= AudioConstants.maxSimultaneousSounds {
            // Stop lowest priority sound
            if let lowest = activeSounds.min(by: { $0.priority < $1.priority }),
               lowest.priority < priority {
                lowest.stop()
                playSound(sound, priority: priority)
            }
        } else {
            playSound(sound, priority: priority)
        }
    }
}
```

### Spatial Audio Optimization

```swift
// Only apply expensive reverb/occlusion to nearby sounds
func updateSpatialAudio(_ audioSource: AudioSource) {
    let distance = distance(listener.position, audioSource.position)

    if distance < 10 {
        audioSource.enableReverb = true
        audioSource.enableOcclusion = true
    } else if distance < 30 {
        audioSource.enableReverb = true
        audioSource.enableOcclusion = false
    } else {
        audioSource.enableReverb = false
        audioSource.enableOcclusion = false
    }
}
```

## Profiling & Monitoring

### Frame Time Profiling

```swift
class PerformanceProfiler {
    private var frameTimes: [TimeInterval] = []

    func beginFrame() {
        frameStartTime = CACurrentMediaTime()
    }

    func endFrame() {
        let frameTime = CACurrentMediaTime() - frameStartTime
        frameTimes.append(frameTime)

        if frameTimes.count > 120 {
            frameTimes.removeFirst()
        }
    }

    var averageFPS: Double {
        let average = frameTimes.reduce(0, +) / Double(frameTimes.count)
        return 1.0 / average
    }

    var percentile95: TimeInterval {
        let sorted = frameTimes.sorted()
        return sorted[Int(Double(sorted.count) * 0.95)]
    }
}
```

### Instruments Integration

```swift
import os.signpost

let subsystem = "com.tacticalsquad.performance"
let pointOfInterest = OSLog(subsystem: subsystem, category: .pointsOfInterest)

func updatePhysics() {
    os_signpost(.begin, log: pointOfInterest, name: "Physics Update")
    // Physics code
    os_signpost(.end, log: pointOfInterest, name: "Physics Update")
}
```

### Performance Metrics

```swift
struct PerformanceMetrics {
    var fps: Double
    var frameTime: TimeInterval
    var cpuTime: TimeInterval
    var gpuTime: TimeInterval
    var memoryUsage: UInt64
    var drawCalls: Int
    var triangles: Int
}

class MetricsCollector {
    func collect() -> PerformanceMetrics {
        PerformanceMetrics(
            fps: profiler.averageFPS,
            frameTime: profiler.averageFrameTime,
            cpuTime: cpuProfiler.time,
            gpuTime: gpuProfiler.time,
            memoryUsage: getMemoryUsage(),
            drawCalls: renderer.drawCallCount,
            triangles: renderer.triangleCount
        )
    }
}
```

## Asset Optimization

### Model Optimization Checklist

- [ ] Remove unused vertices
- [ ] Merge duplicate vertices
- [ ] Optimize polygon count
- [ ] Use LODs for distant objects
- [ ] Bake lighting where possible
- [ ] Use texture atlases
- [ ] Compress textures (ASTC/BC7)
- [ ] Generate mipmaps
- [ ] Optimize material count

### Audio Optimization Checklist

- [ ] Use compressed formats (AAC, Opus)
- [ ] Reduce sample rate for effects (22kHz)
- [ ] Use mono for non-positional sounds
- [ ] Stream long audio files
- [ ] Preload frequently used sounds

## Best Practices

### DO

✅ Profile before optimizing
✅ Measure performance impact
✅ Use object pooling
✅ Batch similar operations
✅ Cull invisible objects
✅ Use LODs
✅ Compress textures
✅ Simplify collision shapes
✅ Limit particle count
✅ Monitor memory usage

### DON'T

❌ Optimize without profiling
❌ Allocate during gameplay
❌ Use expensive operations per-frame
❌ Render off-screen objects
❌ Use full-detail models at distance
❌ Neglect memory leaks
❌ Skip performance testing
❌ Ignore thermal throttling

## Performance Targets by System

| System | Frame Budget | Priority |
|--------|--------------|----------|
| Input Processing | 0.5ms | Critical |
| Physics | 1.5ms | Critical |
| Game Logic | 1.0ms | High |
| Animation | 1.0ms | High |
| Rendering | 3.0ms | Critical |
| Audio | 0.5ms | Medium |
| Networking | 0.5ms | Medium |
| UI | 0.3ms | Low |
| **Total** | **8.3ms** | **(120 FPS)** |

## Optimization Workflow

1. **Profile**: Identify bottlenecks using Instruments
2. **Prioritize**: Focus on critical systems first
3. **Optimize**: Implement optimizations
4. **Measure**: Verify performance improvement
5. **Iterate**: Repeat for other systems

## Tools

- **Xcode Instruments**: CPU, GPU, Memory profiling
- **RealityKit Debugger**: Draw call visualization
- **Metal Debugger**: GPU frame capture
- **Network Link Conditioner**: Test network performance

---

For specific optimization techniques, see the implementation in the respective system files.
