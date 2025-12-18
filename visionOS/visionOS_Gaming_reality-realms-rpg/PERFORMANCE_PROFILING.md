# Reality Realms RPG - Performance Profiling Guide

## Table of Contents

- [Overview](#overview)
- [Performance Targets](#performance-targets)
- [Profiling Tools](#profiling-tools)
- [CPU Profiling](#cpu-profiling)
- [GPU Profiling](#gpu-profiling)
- [Memory Profiling](#memory-profiling)
- [Frame Rate Analysis](#frame-rate-analysis)
- [Common Performance Bottlenecks](#common-performance-bottlenecks)
- [Optimization Strategies](#optimization-strategies)
- [Metal Debugging](#metal-debugging)
- [Performance Testing](#performance-testing)
- [Monitoring in Production](#monitoring-in-production)

---

## Overview

Performance is critical for Reality Realms RPG. As a visionOS spatial computing game, we must maintain a smooth, comfortable experience to prevent motion sickness and ensure immersion.

### Why Performance Matters

1. **Comfort**: Low frame rates cause motion sickness in VR/MR
2. **Immersion**: Stuttering breaks presence
3. **Battery Life**: Efficient code extends gameplay sessions
4. **Thermal Management**: Prevents device throttling

### Performance Philosophy

- **Target First**: Always profile before optimizing
- **Measure Everything**: Use data, not intuition
- **Progressive Degradation**: Reduce quality before dropping frames
- **User Choice**: Let users choose performance vs. quality

---

## Performance Targets

### Frame Rate

Reality Realms targets **90 FPS** for smooth spatial computing:

```yaml
frame_rate_targets:
  minimum: 72 FPS      # Never drop below (causes discomfort)
  target: 90 FPS       # Standard target
  maximum: 96 FPS      # Vision Pro display limit

frame_time_budgets:
  target: 11.1ms       # 90 FPS = 11.1ms per frame
  minimum: 13.9ms      # 72 FPS maximum
```

### Frame Time Budget

Total frame time: **11.1ms @ 90 FPS**

```yaml
time_budgets:
  input_processing: 0.5ms    # Hand tracking, eye tracking, gestures
  physics_simulation: 2.0ms  # Collision detection, rigid bodies
  ai_updates: 1.5ms          # Enemy AI, pathfinding
  game_logic: 2.0ms          # ECS systems, event processing
  animation: 1.0ms           # Skeletal animation, blend trees
  rendering: 4.0ms           # RealityKit rendering, Metal draw calls
  audio: 0.5ms               # Spatial audio updates
  network: 0.5ms             # Multiplayer sync (if active)
  reserve: 0.6ms             # Buffer for spikes
```

### Memory Budget

Total memory budget: **4GB**

```yaml
memory_budgets:
  total: 4GB

  breakdown:
    textures: 1.5GB          # All texture assets
    geometry: 1.0GB          # 3D models, meshes
    audio: 512MB             # Sound effects, music
    code_and_data: 512MB     # App binary, Swift data structures
    ai_systems: 256MB        # Behavior trees, navigation meshes
    networking: 128MB        # Multiplayer buffers
    ui: 128MB                # SwiftUI views, HUD elements
    reserve: 512MB           # OS overhead, safety margin
```

### Polygon Budget

On-screen polygons: **2 million maximum**

```yaml
polygon_budgets:
  total_on_screen: 2M

  per_entity:
    player_character:
      lod0: 50K              # Within 2m
      lod1: 25K              # 2-5m
      lod2: 10K              # 5-10m
      lod3: 5K               # 10-20m
      lod4: 2K               # 20m+

    enemy_character:
      lod0: 30K
      lod1: 15K
      lod2: 7.5K
      lod3: 3K

    furniture:
      lod0: 10K
      lod1: 5K
      lod2: 2.5K

    props:
      lod0: 5K
      lod1: 2K
      lod2: 1K
```

### Draw Call Budget

Target: **500 draw calls per frame**

```yaml
draw_call_budgets:
  maximum: 500 per frame
  target: 300 per frame      # Leaves headroom

  breakdown:
    entities: 200            # Characters, enemies, NPCs
    environment: 150         # Furniture, props, decorations
    effects: 100             # Particles, spell effects
    ui: 50                   # HUD, menus
```

---

## Profiling Tools

### Instruments

Instruments is Apple's primary profiling tool, included with Xcode.

#### Launching Instruments

```bash
# From Xcode: Product → Profile (⌘I)

# Or from Terminal:
open -a Instruments

# Or with specific template:
instruments -t "Time Profiler" -D ~/Desktop/profile.trace -w 'Apple Vision Pro'
```

#### Key Instruments Templates

1. **Time Profiler**: CPU usage, hot paths
2. **Allocations**: Memory allocations, leaks
3. **Leaks**: Memory leak detection
4. **System Trace**: System-wide performance
5. **Metal System Trace**: GPU performance
6. **Energy Log**: Power consumption

### Xcode Debug Gauges

Real-time performance monitoring during development:

**View → Debug Area → Show Debug Navigator (⌘7)**

Gauges show:
- CPU usage (per thread)
- Memory usage
- Disk I/O
- Network activity
- FPS (when running)

### Reality Realms Built-in Profiler

The game includes a built-in performance monitor:

```swift
// Enable debug overlay
PerformanceMonitor.shared.enableDebugOverlay()

// Log stats to console
PerformanceMonitor.shared.logPerformanceStats()
```

**Debug Overlay Shows**:
- Current FPS
- Average FPS (1-second window)
- Frame time (ms)
- Memory usage (MB)
- Quality level
- Active entities count
- Draw calls (if available)

---

## CPU Profiling

### Using Time Profiler

Time Profiler shows where CPU time is spent.

#### Step 1: Record Profile

1. **Launch**: Product → Profile (⌘I)
2. **Select**: Time Profiler template
3. **Record**: Click red record button
4. **Play**: Perform actions to profile (combat, exploration, etc.)
5. **Stop**: Click stop button after 10-30 seconds

#### Step 2: Analyze Results

**Call Tree View**:
- Shows function call hierarchy
- Percent of total CPU time
- Self time (excluding child calls)

**Key Columns**:
- **Self**: Time in this function only
- **Total**: Time in this function + children
- **Symbol**: Function name

**Controls**:
- **Invert Call Tree**: Show bottom-up (find hot functions)
- **Hide System Libraries**: Focus on your code
- **Flatten Recursion**: Combine recursive calls

#### Step 3: Identify Hot Paths

Look for functions consuming >5% total time:

```
Example Hot Path:
GameLoop.update()           100%   (entry point)
├─ CombatSystem.update()     35%   (optimization target)
│  ├─ findNearbyEnemies()    20%   (expensive!)
│  └─ calculateDamage()       15%   (acceptable)
├─ AISystem.update()         25%
├─ RenderSystem.update()     20%
└─ PhysicsSystem.update()    15%
```

**Action Items**:
1. `findNearbyEnemies()` is 20% - investigate
2. Consider spatial partitioning (quadtree/octree)
3. Cache results if enemies don't move often

### Profiling Game Loop

The game loop is the heart of performance:

```swift
class GameLoop {
    func update(deltaTime: TimeInterval) {
        // Profile each phase
        let start = Date()

        processInput(deltaTime)
        let inputTime = Date().timeIntervalSince(start)

        updatePhysics(deltaTime)
        let physicsTime = Date().timeIntervalSince(start) - inputTime

        updateGameLogic(deltaTime)
        let logicTime = Date().timeIntervalSince(start) - physicsTime - inputTime

        updateAI(deltaTime)
        let aiTime = Date().timeIntervalSince(start) - logicTime - physicsTime - inputTime

        render()
        let renderTime = Date().timeIntervalSince(start) - aiTime - logicTime - physicsTime - inputTime

        // Log if over budget
        let totalTime = Date().timeIntervalSince(start)
        if totalTime > 0.0111 {  // 11.1ms
            print("""
            ⚠️ Frame over budget: \(totalTime * 1000)ms
               Input: \(inputTime * 1000)ms
               Physics: \(physicsTime * 1000)ms
               Logic: \(logicTime * 1000)ms
               AI: \(aiTime * 1000)ms
               Render: \(renderTime * 1000)ms
            """)
        }
    }
}
```

### Profiling Entity Systems

Profile ECS systems individually:

```swift
class CombatSystem {
    private var profileData: [String: TimeInterval] = [:]

    func update(entities: [GameEntity], deltaTime: TimeInterval) {
        let startTime = Date()

        // Your system logic
        for entity in entities {
            // ...
        }

        let duration = Date().timeIntervalSince(startTime)
        profileData["lastUpdate"] = duration

        if duration > 0.002 {  // 2ms budget
            print("⚠️ CombatSystem over budget: \(duration * 1000)ms")
        }
    }

    func getAverageUpdateTime() -> TimeInterval {
        return profileData["lastUpdate"] ?? 0
    }
}
```

### CPU Performance Best Practices

1. **Avoid Work in Hot Paths**
   ```swift
   // Bad: String interpolation in loop
   for i in 0..<10000 {
       print("Processing \(i)")  // Expensive!
   }

   // Good: Batch logging
   let processed = 10000
   print("Processed \(processed) items")
   ```

2. **Cache Expensive Computations**
   ```swift
   // Bad: Recalculate every frame
   let distance = sqrt(pow(dx, 2) + pow(dy, 2))

   // Good: Cache if positions unchanged
   if positionChanged {
       cachedDistance = sqrt(pow(dx, 2) + pow(dy, 2))
   }
   return cachedDistance
   ```

3. **Use Spatial Partitioning**
   ```swift
   // Bad: O(n²) for nearby entity checks
   for entity in entities {
       for other in entities where other != entity {
           if distance(entity, other) < radius {
               // Process
           }
       }
   }

   // Good: O(n log n) with quadtree
   let nearby = quadtree.query(entity.position, radius: radius)
   for other in nearby {
       // Process
   }
   ```

---

## GPU Profiling

### Using Metal System Trace

Metal System Trace shows GPU performance.

#### Step 1: Capture Trace

1. **Launch**: Product → Profile (⌘I)
2. **Select**: Metal System Trace
3. **Record**: Run game for 5-10 seconds
4. **Stop**: Stop recording

#### Step 2: Analyze GPU Timeline

**Key Tracks**:
- **Vertex Shader**: Time in vertex processing
- **Fragment Shader**: Time in pixel processing
- **Compute Shader**: Time in compute kernels
- **Memory**: GPU memory transfers
- **Command Buffers**: Metal command submissions

**Look For**:
- Long shader execution times (>2ms)
- Memory transfer bottlenecks
- Pipeline stalls (gaps in timeline)
- Overdraw (multiple fragments per pixel)

#### Step 3: Shader Optimization

Identify expensive shaders:

```metal
// Example expensive shader
fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> baseColor [[texture(0)]],
                               texture2d<float> normal [[texture(1)]],
                               texture2d<float> roughness [[texture(2)]]) {
    // This is expensive if all textures sampled every pixel!
    float4 color = baseColor.sample(sampler, in.texCoord);
    float4 norm = normal.sample(sampler, in.texCoord);
    float rough = roughness.sample(sampler, in.texCoord).r;

    // Complex lighting calculation
    float3 lighting = calculatePBR(norm.xyz, rough, ...);

    return float4(color.rgb * lighting, color.a);
}
```

**Optimizations**:
1. Use simpler shaders for distant objects
2. Reduce texture samples
3. Use lower-resolution textures for far objects
4. Combine textures (pack channels)

### GPU Performance Metrics

Monitor these metrics:

```swift
// RealityKit provides some metrics
// Check rendering statistics

struct RenderStats {
    var drawCalls: Int
    var triangles: Int
    var vertices: Int
    var shaderCompilations: Int
}

func logRenderStats(_ stats: RenderStats) {
    if stats.drawCalls > 500 {
        print("⚠️ Too many draw calls: \(stats.drawCalls)")
    }

    if stats.triangles > 2_000_000 {
        print("⚠️ Too many triangles: \(stats.triangles)")
    }
}
```

### Reducing Draw Calls

Draw calls are expensive. Minimize them:

**1. Batching**
```swift
// Bad: Separate draw call per object
for entity in entities {
    render(entity)  // 100 entities = 100 draw calls
}

// Good: Batch similar objects
let batches = groupByMaterial(entities)
for batch in batches {
    renderBatch(batch)  // 100 entities = 5-10 draw calls
}
```

**2. Instancing**
```swift
// Render many copies of same mesh
let instanceCount = 100
renderInstanced(mesh: goblinMesh, count: instanceCount)
// 1 draw call instead of 100
```

**3. Texture Atlasing**
```swift
// Bad: Many small textures = many material changes
let texture1 = loadTexture("sword.png")
let texture2 = loadTexture("shield.png")
// ... 50 different textures

// Good: Pack into atlas
let atlas = TextureAtlas(textures: allTextures)
// 1 texture, adjust UVs
```

### LOD (Level of Detail)

Reduce polygon count for distant objects:

```swift
class LODManager {
    func updateLOD(for entity: Entity, cameraPosition: SIMD3<Float>) {
        let distance = length(entity.position - cameraPosition)

        let lodLevel: Int
        switch distance {
        case 0..<2:   lodLevel = 0  // Ultra (50K polys)
        case 2..<5:   lodLevel = 1  // High (25K polys)
        case 5..<10:  lodLevel = 2  // Medium (10K polys)
        case 10..<20: lodLevel = 3  // Low (5K polys)
        default:      lodLevel = 4  // Minimum (2K polys)
        }

        if entity.currentLOD != lodLevel {
            entity.swapModel(lodLevel: lodLevel)
        }
    }
}
```

---

## Memory Profiling

### Using Allocations Instrument

Track memory allocations and find leaks.

#### Step 1: Record Allocations

1. **Launch**: Product → Profile (⌘I)
2. **Select**: Allocations
3. **Record**: Play game for 1-2 minutes
4. **Mark Generation**: Click "Mark Generation" periodically
5. **Stop**: Stop recording

#### Step 2: Analyze Allocations

**Statistics View**:
- **Persistent**: Memory not freed
- **Transient**: Memory allocated and freed
- **Total**: All allocations

**Look For**:
- Growing persistent memory (leaks)
- Large transient allocations (optimization targets)
- Unexpected allocation patterns

**Generations**:
- Compare generations to find leaks
- Memory that grows between generations is likely leaked

#### Step 3: Find Leaks

Use Leaks instrument for automatic detection:

1. **Launch**: Product → Profile (⌘I)
2. **Select**: Leaks
3. **Record**: Run game
4. **Leaks**: Red bars indicate leaks
5. **Inspect**: Click leak to see allocation stack trace

### Memory Management Best Practices

#### 1. Avoid Retain Cycles

```swift
// Bad: Retain cycle
class GameManager {
    var eventHandler: (() -> Void)?

    init() {
        eventHandler = {
            self.handleEvent()  // Captures self strongly!
        }
    }
}

// Good: Weak self
class GameManager {
    var eventHandler: (() -> Void)?

    init() {
        eventHandler = { [weak self] in
            self?.handleEvent()
        }
    }
}
```

#### 2. Use Weak References for Delegates

```swift
// EventBus already handles this
EventBus.shared.subscribe(MyEvent.self) { [weak self] event in
    self?.handle(event)
}
```

#### 3. Release Large Assets

```swift
class AssetManager {
    var loadedAssets: [UUID: Asset] = [:]

    func unloadUnusedAssets() {
        let now = Date()

        loadedAssets = loadedAssets.filter { id, asset in
            let timeSinceUse = now.timeIntervalSince(asset.lastUsed)
            return timeSinceUse < 300  // Keep if used in last 5 minutes
        }
    }
}
```

#### 4. Pool Frequently Allocated Objects

```swift
class ObjectPool<T> {
    private var pool: [T] = []
    private let factory: () -> T

    init(size: Int, factory: @escaping () -> T) {
        self.factory = factory
        pool = (0..<size).map { _ in factory() }
    }

    func acquire() -> T? {
        return pool.popLast() ?? factory()
    }

    func release(_ object: T) {
        pool.append(object)
    }
}

// Usage
let projectilePool = ObjectPool<Projectile>(size: 100) {
    Projectile()
}

// Acquire from pool instead of allocating
let projectile = projectilePool.acquire()

// Release back to pool when done
projectilePool.release(projectile)
```

### Memory Budget Monitoring

```swift
class MemoryMonitor {
    func checkMemoryBudget() {
        let usage = getMemoryUsage()
        let budget: UInt64 = 4 * 1024 * 1024 * 1024  // 4GB

        if usage > budget * 90 / 100 {  // 90% of budget
            print("⚠️ Memory usage high: \(usage / 1024 / 1024)MB / \(budget / 1024 / 1024)MB")

            // Take action
            unloadDistantAssets()
            clearCaches()
        }
    }

    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }
}
```

---

## Frame Rate Analysis

### Measuring Frame Rate

```swift
class FPSCounter {
    private var frameTimes: [TimeInterval] = []
    private let maxSamples = 90  // 1 second at 90 FPS

    func recordFrame(deltaTime: TimeInterval) {
        frameTimes.append(deltaTime)

        if frameTimes.count > maxSamples {
            frameTimes.removeFirst()
        }
    }

    var currentFPS: Double {
        guard let lastFrame = frameTimes.last, lastFrame > 0 else {
            return 0
        }
        return 1.0 / lastFrame
    }

    var averageFPS: Double {
        guard !frameTimes.isEmpty else { return 0 }

        let avgFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        return avgFrameTime > 0 ? 1.0 / avgFrameTime : 0
    }

    var minFPS: Double {
        guard let maxFrameTime = frameTimes.max(), maxFrameTime > 0 else {
            return 0
        }
        return 1.0 / maxFrameTime
    }

    var maxFPS: Double {
        guard let minFrameTime = frameTimes.min(), minFrameTime > 0 else {
            return 0
        }
        return 1.0 / minFrameTime
    }

    func percentileFPS(_ percentile: Double) -> Double {
        guard !frameTimes.isEmpty else { return 0 }

        let sorted = frameTimes.sorted()
        let index = Int(Double(sorted.count) * percentile / 100.0)
        let frameTime = sorted[min(index, sorted.count - 1)]

        return frameTime > 0 ? 1.0 / frameTime : 0
    }
}

// Usage
let fpsCounter = FPSCounter()

// In game loop
fpsCounter.recordFrame(deltaTime: deltaTime)

// Get statistics
print("Current: \(fpsCounter.currentFPS) FPS")
print("Average: \(fpsCounter.averageFPS) FPS")
print("Min: \(fpsCounter.minFPS) FPS")
print("1% Low: \(fpsCounter.percentileFPS(1)) FPS")  // Worst 1% of frames
```

### Frame Time Histogram

Visualize frame time distribution:

```swift
class FrameTimeHistogram {
    private var buckets: [Int] = Array(repeating: 0, count: 20)  // 0-20ms in 1ms buckets

    func record(frameTime: TimeInterval) {
        let ms = Int(frameTime * 1000)
        let bucket = min(ms, buckets.count - 1)
        buckets[bucket] += 1
    }

    func printHistogram() {
        print("\nFrame Time Histogram:")
        print("Time(ms) | Count")
        print("---------|-------")

        for (index, count) in buckets.enumerated() {
            if count > 0 {
                let bar = String(repeating: "█", count: count / 10)
                print("\(String(format: "%2d", index))ms    | \(count) \(bar)")
            }
        }

        // Highlight target
        print("         |")
        print("11ms ←── | Target (90 FPS)")
        print("14ms ←── | Minimum (72 FPS)")
    }
}
```

### Detecting Frame Drops

```swift
class FrameDropDetector {
    private let targetFrameTime: TimeInterval = 1.0 / 90.0
    private let dropThreshold: TimeInterval = 1.0 / 72.0

    func checkFrame(deltaTime: TimeInterval) {
        if deltaTime > dropThreshold {
            print("⚠️ Frame drop: \(deltaTime * 1000)ms (\(1.0 / deltaTime) FPS)")

            // Log stack trace to find culprit
            Thread.callStackSymbols.forEach { print($0) }
        }
    }
}
```

---

## Common Performance Bottlenecks

### 1. Too Many Entities

**Symptom**: FPS drops when many enemies on screen

**Diagnosis**:
```swift
let entityCount = entities.filter { $0.isActive }.count
print("Active entities: \(entityCount)")

if entityCount > 100 {
    print("⚠️ Too many entities!")
}
```

**Solutions**:
- Limit active entities (despawn distant ones)
- Use object pooling
- Implement frustum culling (don't process off-screen entities)

### 2. Expensive AI Updates

**Symptom**: FPS drops with many AI entities

**Diagnosis**: Profile AISystem.update() in Time Profiler

**Solutions**:
- Update AI at lower frequency (every 3-5 frames)
- Use simpler AI for distant enemies
- Limit active AI agents

```swift
class AISystem {
    private var frameCounter = 0

    func update(entities: [GameEntity], deltaTime: TimeInterval) {
        frameCounter += 1

        for entity in entities {
            guard let ai = entity.getComponent(AIComponent.self) else { continue }

            // Update distant AI less frequently
            let distance = calculateDistanceToPlayer(entity)
            let updateFrequency = distance < 5 ? 1 : (distance < 10 ? 3 : 5)

            if frameCounter % updateFrequency == 0 {
                updateAI(entity, ai, deltaTime * Double(updateFrequency))
            }
        }
    }
}
```

### 3. Physics Simulation

**Symptom**: Physics.update() takes >2ms

**Solutions**:
- Use simpler collision shapes (spheres/capsules vs. convex hulls)
- Reduce physics substeps
- Use static colliders for non-moving objects
- Disable physics for distant objects

### 4. Texture Thrashing

**Symptom**: GPU memory transfers visible in Metal trace

**Solutions**:
- Use texture compression (ASTC for visionOS)
- Reduce texture resolution
- Implement texture streaming (load/unload based on distance)
- Use mipmaps

### 5. Shader Complexity

**Symptom**: Fragment shader time >2ms in Metal trace

**Solutions**:
- Simplify shaders for distant objects
- Reduce texture samples
- Use precomputed lighting where possible
- Optimize shader code (avoid branches, complex math)

---

## Optimization Strategies

### Progressive Quality Degradation

Maintain frame rate by reducing quality:

```swift
class AdaptiveQualityManager {
    func adjustQuality(currentFPS: Double, targetFPS: Double = 90) {
        if currentFPS < targetFPS - 5 {
            // Reduce quality
            if qualityLevel == .ultra {
                setQuality(.high)
            } else if qualityLevel == .high {
                setQuality(.medium)
            } else if qualityLevel == .medium {
                setQuality(.low)
            }
        } else if currentFPS > targetFPS + 5 && qualityLevel != .ultra {
            // Increase quality
            if qualityLevel == .low {
                setQuality(.medium)
            } else if qualityLevel == .medium {
                setQuality(.high)
            } else if qualityLevel == .high {
                setQuality(.ultra)
            }
        }
    }

    private func setQuality(_ level: QualityLevel) {
        qualityLevel = level

        switch level {
        case .ultra:
            resolutionScale = 1.0
            shadowQuality = .ultra
            particleLimit = 1000
            lodBias = 1.0
        case .high:
            resolutionScale = 0.9
            shadowQuality = .high
            particleLimit = 750
            lodBias = 0.9
        case .medium:
            resolutionScale = 0.8
            shadowQuality = .medium
            particleLimit = 500
            lodBias = 0.8
        case .low:
            resolutionScale = 0.7
            shadowQuality = .low
            particleLimit = 250
            lodBias = 0.7
        }
    }
}
```

### Asynchronous Loading

Load assets without blocking the game loop:

```swift
class AssetLoader {
    func loadAssetAsync(_ path: String) async throws -> Asset {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let asset = try self.loadAssetSync(path)
                    continuation.resume(returning: asset)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // Usage
    Task {
        do {
            let model = try await loadAssetAsync("character.usdz")
            await MainActor.run {
                applyModel(model)
            }
        } catch {
            print("Failed to load asset: \(error)")
        }
    }
}
```

### Occlusion Culling

Don't render what the player can't see:

```swift
class OcclusionCuller {
    func cullEntities(
        _ entities: [GameEntity],
        cameraPosition: SIMD3<Float>,
        cameraDirection: SIMD3<Float>,
        fov: Float
    ) -> [GameEntity] {
        return entities.filter { entity in
            // Check if in view frustum
            let toEntity = normalize(entity.position - cameraPosition)
            let dotProduct = dot(toEntity, cameraDirection)
            let angle = acos(dotProduct)

            return angle < fov / 2
        }
    }
}
```

---

## Metal Debugging

### Metal Frame Debugger

Capture and inspect a single frame:

1. **In Xcode**: Debug → Capture GPU Frame
2. **Inspect**: View geometry, textures, shaders
3. **Debug Shaders**: Step through shader code

### Metal Performance HUD

Enable in Scheme settings:

1. **Edit Scheme** (Product → Scheme → Edit Scheme)
2. **Run → Options**
3. **Metal API Validation**: Enabled
4. **GPU Frame Capture**: Enabled

### Common Metal Issues

**Issue: Excessive pipeline state changes**
```
Solution: Batch draw calls by material/shader
```

**Issue: Large constant buffers**
```
Solution: Use smaller, frequently updated buffers
```

**Issue: Synchronization stalls**
```
Solution: Use triple buffering, async resource updates
```

---

## Performance Testing

### Automated Performance Tests

```swift
import XCTest

class PerformanceTests: XCTestCase {
    func testGameLoopPerformance() {
        measure(metrics: [XCTClockMetric()]) {
            let gameLoop = GameLoop()

            for _ in 0..<90 {  // 1 second at 90 FPS
                gameLoop.update(deltaTime: 1.0 / 90.0)
            }
        }

        // Assert performance
        let baseline = 0.0111  // 11.1ms for 90 FPS
        // XCTest will warn if performance degrades
    }

    func testCombatSystemPerformance() {
        let entities = createTestEntities(count: 100)
        let combatSystem = CombatSystem()

        measure(metrics: [XCTClockMetric()]) {
            combatSystem.update(entities: entities, deltaTime: 1.0 / 90.0)
        }
    }

    func testMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            let scene = GameScene.createLargeScene()
            scene.loadAllAssets()
        }
    }
}
```

### Load Testing

Test with maximum expected load:

```swift
func testMaximumEnemies() {
    let maxEnemies = 50
    let enemies = (0..<maxEnemies).map { _ in
        Enemy(enemyType: .goblin)
    }

    let fpsCounter = FPSCounter()

    for _ in 0..<900 {  // 10 seconds
        let startTime = Date()

        // Update all enemies
        for enemy in enemies {
            updateEnemy(enemy, deltaTime: 1.0 / 90.0)
        }

        let deltaTime = Date().timeIntervalSince(startTime)
        fpsCounter.recordFrame(deltaTime: deltaTime)
    }

    XCTAssertGreaterThan(fpsCounter.averageFPS, 72, "Failed to maintain minimum FPS with max enemies")
}
```

---

## Monitoring in Production

### Performance Metrics

Collect metrics for analysis:

```swift
struct PerformanceMetrics: Codable {
    let sessionID: UUID
    let timestamp: Date
    let averageFPS: Double
    let minFPS: Double
    let frameDropCount: Int
    let averageMemoryMB: Double
    let peakMemoryMB: Double
    let playDuration: TimeInterval
    let qualityLevel: String
    let deviceModel: String
}

class MetricsCollector {
    func collectMetrics() -> PerformanceMetrics {
        return PerformanceMetrics(
            sessionID: sessionID,
            timestamp: Date(),
            averageFPS: PerformanceMonitor.shared.averageFPS,
            minFPS: calculateMinFPS(),
            frameDropCount: frameDropCounter,
            averageMemoryMB: calculateAverageMemory(),
            peakMemoryMB: peakMemoryUsage,
            playDuration: playDuration,
            qualityLevel: PerformanceMonitor.shared.qualityLevel.rawValue,
            deviceModel: UIDevice.current.model
        )
    }

    func uploadMetrics(_ metrics: PerformanceMetrics) {
        // Upload to analytics service
    }
}
```

### Crash Reporting

Integrate crash reporting to catch performance-related crashes:

```swift
// Use Apple's Crash Reporting or third-party service
// Crashes often indicate performance issues (out of memory, watchdog timeout)
```

---

**Performance Guide Version**: 1.0
**Last Updated**: 2025-11-19
**Maintained By**: Reality Realms Development Team

---

Remember: **Profile first, optimize second.** Never optimize without data!
