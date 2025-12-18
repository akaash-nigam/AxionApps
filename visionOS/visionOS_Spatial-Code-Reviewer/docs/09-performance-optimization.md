# Performance Optimization Strategy Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document defines performance targets, optimization strategies, profiling approaches, and monitoring systems for Spatial Code Reviewer to ensure smooth 60fps+ performance on Apple Vision Pro.

## 2. Performance Targets

### 2.1 Frame Rate Targets

| Metric | Minimum | Target | Exceptional |
|--------|---------|--------|-------------|
| Frame Rate | 60 fps | 90 fps | 120 fps |
| Frame Time | < 16.7ms | < 11.1ms | < 8.3ms |
| Input Latency | < 50ms | < 30ms | < 20ms |
| Jank (dropped frames) | < 1% | < 0.1% | 0% |

### 2.2 Loading & Response Times

| Operation | Target | Max Acceptable |
|-----------|--------|----------------|
| App Launch | < 2s | < 3s |
| Repository Clone | < 30s for 100MB | < 60s |
| File Parse | < 50ms for 500 LOC | < 200ms |
| Index Build | < 30s for 100K LOC | < 60s |
| Layout Transition | < 300ms | < 500ms |
| API Request | < 1s | < 3s |
| Search Query | < 100ms | < 500ms |

### 2.3 Memory Targets

| Resource | Target | Maximum |
|----------|--------|---------|
| Total Memory | < 1GB | < 2GB |
| Entity Count | < 100 | < 200 |
| Texture Memory | < 200MB | < 500MB |
| Parse Cache | < 100MB | < 200MB |

## 3. Rendering Optimization

### 3.1 Entity Culling System

```swift
class OptimizedCullingSystem: System {
    static let query = EntityQuery(
        where: .has(CodeWindowComponent.self) || .has(DependencyLineComponent.self)
    )

    private let frustum: ViewFrustum
    private let occlusionCulling: OcclusionCullingSystem

    init(scene: Scene) {
        self.frustum = ViewFrustum(scene: scene)
        self.occlusionCulling = OcclusionCullingSystem()
    }

    func update(context: SceneUpdateContext) {
        let camera = context.scene.camera ?? Entity()
        updateFrustum(camera: camera)

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            // Frustum culling
            let inFrustum = frustum.contains(entity.visualBounds(relativeTo: nil))

            // Distance culling
            let distance = length(entity.position(relativeTo: camera) - camera.position)
            let isTooFar = distance > 10.0 // 10 meters

            // Occlusion culling
            let isOccluded = occlusionCulling.isOccluded(entity, from: camera)

            // Update visibility
            let shouldBeVisible = inFrustum && !isTooFar && !isOccluded

            if entity.isEnabled != shouldBeVisible {
                entity.isEnabled = shouldBeVisible

                // Track statistics
                if shouldBeVisible {
                    PerformanceMonitor.shared.recordEntityShown()
                } else {
                    PerformanceMonitor.shared.recordEntityHidden()
                }
            }

            // LOD management
            if shouldBeVisible {
                updateLOD(entity, distance: distance)
            }
        }
    }

    private func updateFrustum(camera: Entity) {
        frustum.update(from: camera)
    }

    private func updateLOD(_ entity: Entity, distance: Float) {
        if var codeWindow = entity.components[CodeWindowComponent.self] {
            let oldLOD = codeWindow.lodLevel

            // Determine LOD level based on distance
            let newLOD: LODLevel
            if distance < 2.0 {
                newLOD = .high      // Full detail
            } else if distance < 4.0 {
                newLOD = .medium    // Reduced detail
            } else {
                newLOD = .low       // Minimal detail
            }

            if oldLOD != newLOD {
                codeWindow.lodLevel = newLOD
                entity.components[CodeWindowComponent.self] = codeWindow

                // Regenerate geometry if needed
                if let codeWindowEntity = entity as? CodeWindowEntity {
                    codeWindowEntity.updateDetail(for: newLOD)
                }
            }
        }
    }
}

enum LODLevel {
    case high
    case medium
    case low
}

extension CodeWindowComponent {
    var lodLevel: LODLevel {
        get { // Implementation }
        set { // Implementation }
    }
}
```

### 3.2 Entity Pooling

```swift
class EntityPoolManager {
    static let shared = EntityPoolManager()

    private var pools: [String: any EntityPool] = [:]

    init() {
        setupPools()
    }

    private func setupPools() {
        pools["codeWindow"] = TypedEntityPool<CodeWindowEntity>(
            initialSize: 20,
            maxSize: 50
        ) {
            CodeWindowEntity(file: CodeFile(path: "", content: ""), position: .zero)
        }

        pools["dependencyLine"] = TypedEntityPool<DependencyLineEntity>(
            initialSize: 50,
            maxSize: 200
        ) {
            DependencyLineEntity(
                from: Entity(),
                to: Entity(),
                type: .import
            )
        }

        pools["issueMarker"] = TypedEntityPool<IssueMarkerEntity>(
            initialSize: 10,
            maxSize: 50
        ) {
            IssueMarkerEntity(
                issue: Issue(number: 0, title: "", severity: .info),
                nearFile: CodeWindowEntity(file: CodeFile(path: "", content: ""), position: .zero)
            )
        }
    }

    func acquire<T: Entity>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let pool = pools[key] as? TypedEntityPool<T> else {
            return nil
        }
        return pool.acquire()
    }

    func release<T: Entity>(_ entity: T) {
        let key = String(describing: T.self)
        guard let pool = pools[key] as? TypedEntityPool<T> else {
            return
        }
        pool.release(entity)
    }

    func warmup() {
        // Pre-create pool entities
        for (_, pool) in pools {
            pool.warmup()
        }
    }
}

protocol EntityPool {
    func warmup()
}

class TypedEntityPool<T: Entity>: EntityPool {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T
    private let maxSize: Int

    init(initialSize: Int, maxSize: Int, factory: @escaping () -> T) {
        self.factory = factory
        self.maxSize = maxSize

        for _ in 0..<initialSize {
            available.append(factory())
        }
    }

    func acquire() -> T {
        let entity: T
        if let pooled = available.popLast() {
            entity = pooled
        } else {
            entity = factory()
        }

        inUse.insert(ObjectIdentifier(entity))
        entity.isEnabled = true
        return entity
    }

    func release(_ entity: T) {
        guard inUse.contains(ObjectIdentifier(entity)) else { return }

        inUse.remove(ObjectIdentifier(entity))
        entity.isEnabled = false
        entity.removeFromParent()

        // Reset entity state
        entity.position = .zero
        entity.orientation = .init(angle: 0, axis: [0, 1, 0])
        entity.scale = [1, 1, 1]

        if available.count < maxSize {
            available.append(entity)
        }
    }

    func warmup() {
        // Pool is already warmed up in init
    }

    var pooledCount: Int { available.count }
    var activeCount: Int { inUse.count }
}
```

### 3.3 Batch Rendering

```swift
class BatchRenderer {
    private var batches: [MaterialKey: [ModelComponent]] = [:]

    struct MaterialKey: Hashable {
        let materialType: String
        let blendMode: String
    }

    func addToBatch(_ model: ModelComponent) {
        let key = MaterialKey(
            materialType: String(describing: type(of: model.materials.first)),
            blendMode: "default"
        )

        if batches[key] == nil {
            batches[key] = []
        }
        batches[key]?.append(model)
    }

    func render() {
        for (key, models) in batches {
            renderBatch(models, with: key)
        }
        batches.removeAll(keepingCapacity: true)
    }

    private func renderBatch(_ models: [ModelComponent], with key: MaterialKey) {
        // Batch render all models with same material
        // This reduces draw calls significantly
    }
}
```

### 3.4 Texture Atlasing

```swift
class TextureAtlasManager {
    private var atlases: [String: TextureAtlas] = [:]

    struct TextureAtlas {
        let texture: TextureResource
        let regions: [String: CGRect]
    }

    func createAtlas(for images: [String: UIImage]) -> TextureAtlas {
        // Pack multiple textures into single atlas
        let packer = TexturePacker()

        for (key, image) in images {
            packer.addImage(image, withKey: key)
        }

        let packedTexture = packer.pack()
        let regions = packer.regions

        return TextureAtlas(
            texture: packedTexture,
            regions: regions
        )
    }

    func getTextureRegion(for key: String, in atlasName: String) -> CGRect? {
        return atlases[atlasName]?.regions[key]
    }
}
```

## 4. Memory Optimization

### 4.1 Memory Pool

```swift
class MemoryPool {
    private let allocator: MemoryAllocator
    private var blocks: [MemoryBlock] = []

    init(blockSize: Int = 1024 * 1024) { // 1MB blocks
        self.allocator = MemoryAllocator(blockSize: blockSize)
    }

    func allocate(size: Int) -> UnsafeMutableRawPointer? {
        return allocator.allocate(size: size)
    }

    func deallocate(_ pointer: UnsafeMutableRawPointer, size: Int) {
        allocator.deallocate(pointer, size: size)
    }

    func reset() {
        allocator.reset()
        blocks.removeAll(keepingCapacity: true)
    }
}

class MemoryAllocator {
    private let blockSize: Int
    private var currentBlock: MemoryBlock?
    private var blocks: [MemoryBlock] = []

    init(blockSize: Int) {
        self.blockSize = blockSize
        allocateNewBlock()
    }

    func allocate(size: Int) -> UnsafeMutableRawPointer? {
        guard let block = currentBlock else { return nil }

        if block.canAllocate(size: size) {
            return block.allocate(size: size)
        } else {
            allocateNewBlock()
            return currentBlock?.allocate(size: size)
        }
    }

    func deallocate(_ pointer: UnsafeMutableRawPointer, size: Int) {
        // Mark as freed but don't actually free (pool management)
    }

    func reset() {
        for block in blocks {
            block.reset()
        }
        currentBlock = blocks.first
    }

    private func allocateNewBlock() {
        let block = MemoryBlock(size: blockSize)
        blocks.append(block)
        currentBlock = block
    }
}

class MemoryBlock {
    private let memory: UnsafeMutableRawPointer
    private let size: Int
    private var offset: Int = 0

    init(size: Int) {
        self.size = size
        self.memory = UnsafeMutableRawPointer.allocate(
            byteCount: size,
            alignment: MemoryLayout<Int>.alignment
        )
    }

    deinit {
        memory.deallocate()
    }

    func canAllocate(size: Int) -> Bool {
        return offset + size <= self.size
    }

    func allocate(size: Int) -> UnsafeMutableRawPointer? {
        guard canAllocate(size: size) else { return nil }

        let pointer = memory.advanced(by: offset)
        offset += size
        return pointer
    }

    func reset() {
        offset = 0
    }
}
```

### 4.2 Lazy Loading

```swift
class LazyCodeLoader {
    private var loadedFiles: [String: CodeFile] = [:]
    private let loadQueue = DispatchQueue(
        label: "com.spatialcodereviewer.lazyloader",
        qos: .userInitiated
    )

    func loadFile(_ path: String) async throws -> CodeFile {
        // Check cache first
        if let cached = loadedFiles[path] {
            return cached
        }

        // Load asynchronously
        return try await withCheckedThrowingContinuation { continuation in
            loadQueue.async {
                do {
                    let file = try self.loadFromDisk(path)
                    self.loadedFiles[path] = file
                    continuation.resume(returning: file)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func loadFromDisk(_ path: String) throws -> CodeFile {
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url)

        return CodeFile(
            path: path,
            content: content,
            language: Language.detect(from: path)
        )
    }

    func preload(_ paths: [String]) {
        for path in paths {
            loadQueue.async {
                _ = try? self.loadFromDisk(path)
            }
        }
    }

    func unload(_ path: String) {
        loadedFiles.removeValue(forKey: path)
    }

    func clearCache() {
        loadedFiles.removeAll(keepingCapacity: true)
    }
}
```

### 4.3 Memory Pressure Handling

```swift
class MemoryPressureHandler {
    private let notificationCenter = NotificationCenter.default
    private var observations: [NSObjectProtocol] = []

    func startMonitoring() {
        let warningObserver = notificationCenter.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }

        observations.append(warningObserver)
    }

    private func handleMemoryWarning() {
        print("⚠️ Memory warning received")

        // Clear caches
        ParseCache.shared.clear()
        ImageCache.shared.clear()

        // Release pooled entities
        EntityPoolManager.shared.releaseUnused()

        // Reduce entity count
        reduceVisibleEntities()

        // Force garbage collection
        autoreleasepool {
            // Create temporary autoreleasepool to release objects
        }

        print("✓ Memory cleanup completed")
    }

    private func reduceVisibleEntities() {
        // Hide distant entities
        // Reduce LOD levels
        // Clear off-screen caches
    }

    deinit {
        observations.forEach { notificationCenter.removeObserver($0) }
    }
}
```

## 5. Async Operations

### 5.1 Async Task Manager

```swift
actor AsyncTaskManager {
    private var tasks: [String: Task<Void, Error>] = [:]
    private let maxConcurrentTasks: Int = 4

    func execute<T>(
        _ key: String,
        priority: TaskPriority = .medium,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        // Cancel existing task with same key
        if let existingTask = tasks[key] {
            existingTask.cancel()
        }

        // Wait if too many concurrent tasks
        while tasks.count >= maxConcurrentTasks {
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }

        let task = Task(priority: priority) {
            defer { tasks.removeValue(forKey: key) }
            return try await operation()
        }

        tasks[key] = task as? Task<Void, Error>

        return try await task.value
    }

    func cancelAll() {
        for (_, task) in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }
}
```

### 5.2 Background Processing

```swift
class BackgroundProcessor {
    private let processingQueue = DispatchQueue(
        label: "com.spatialcodereviewer.background",
        qos: .utility,
        attributes: .concurrent
    )

    func processInBackground<T>(
        _ operation: @escaping () throws -> T
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func batchProcess<T>(
        items: [T],
        batchSize: Int = 10,
        operation: @escaping (T) throws -> Void
    ) async throws {
        for batch in items.chunked(into: batchSize) {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for item in batch {
                    group.addTask {
                        try operation(item)
                    }
                }

                try await group.waitForAll()
            }

            // Small delay between batches to avoid overwhelming
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
```

## 6. Performance Monitoring

### 6.1 Performance Monitor

```swift
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published var currentFPS: Double = 60.0
    @Published var frameTime: TimeInterval = 0.0
    @Published var memoryUsage: UInt64 = 0
    @Published var entityCount: Int = 0

    private var frameTimestamps: [TimeInterval] = []
    private let maxSamples = 60

    private let displayLink: CADisplayLink?

    init() {
        // Setup display link for FPS monitoring
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)

        startMemoryMonitoring()
    }

    @objc private func update(displayLink: CADisplayLink) {
        let now = displayLink.timestamp
        frameTimestamps.append(now)

        if frameTimestamps.count > maxSamples {
            frameTimestamps.removeFirst()
        }

        calculateFPS()
        frameTime = displayLink.duration
    }

    private func calculateFPS() {
        guard frameTimestamps.count > 1 else { return }

        let timeSpan = frameTimestamps.last! - frameTimestamps.first!
        currentFPS = Double(frameTimestamps.count - 1) / timeSpan
    }

    private func startMemoryMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }

    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        if result == KERN_SUCCESS {
            memoryUsage = info.resident_size
        }
    }

    func recordEntityShown() {
        entityCount += 1
    }

    func recordEntityHidden() {
        entityCount -= 1
    }

    // Metrics
    struct Metrics {
        let avgFPS: Double
        let minFPS: Double
        let maxFPS: Double
        let avgFrameTime: TimeInterval
        let peakMemory: UInt64
        let avgEntityCount: Int
    }

    func getMetrics() -> Metrics {
        // Return aggregated metrics
        return Metrics(
            avgFPS: currentFPS,
            minFPS: 0,
            maxFPS: 0,
            avgFrameTime: frameTime,
            peakMemory: memoryUsage,
            avgEntityCount: entityCount
        )
    }
}
```

### 6.2 Profiling Points

```swift
class Profiler {
    static let shared = Profiler()

    private var timings: [String: [TimeInterval]] = [:]

    func measure<T>(
        _ operation: String,
        block: () throws -> T
    ) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - start
            record(operation, duration: duration)
        }

        return try block()
    }

    func measureAsync<T>(
        _ operation: String,
        block: () async throws -> T
    ) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - start
            record(operation, duration: duration)
        }

        return try await block()
    }

    private func record(_ operation: String, duration: TimeInterval) {
        if timings[operation] == nil {
            timings[operation] = []
        }

        timings[operation]?.append(duration)

        // Keep only recent measurements
        if timings[operation]!.count > 100 {
            timings[operation]!.removeFirst()
        }

        // Warn if slow
        if duration > 0.1 { // 100ms
            print("⚠️ Slow operation: \(operation) took \(duration * 1000)ms")
        }
    }

    func getStats(for operation: String) -> OperationStats? {
        guard let durations = timings[operation], !durations.isEmpty else {
            return nil
        }

        let avg = durations.reduce(0, +) / Double(durations.count)
        let min = durations.min() ?? 0
        let max = durations.max() ?? 0

        return OperationStats(
            operation: operation,
            count: durations.count,
            average: avg,
            minimum: min,
            maximum: max
        )
    }

    struct OperationStats {
        let operation: String
        let count: Int
        let average: TimeInterval
        let minimum: TimeInterval
        let maximum: TimeInterval

        var averageMs: Double { average * 1000 }
        var minimumMs: Double { minimum * 1000 }
        var maximumMs: Double { maximum * 1000 }
    }

    func printStats() {
        print("=== Performance Statistics ===")
        for operation in timings.keys.sorted() {
            if let stats = getStats(for: operation) {
                print("""
                    \(operation):
                      Count: \(stats.count)
                      Avg: \(String(format: "%.2f", stats.averageMs))ms
                      Min: \(String(format: "%.2f", stats.minimumMs))ms
                      Max: \(String(format: "%.2f", stats.maximumMs))ms
                    """)
            }
        }
    }
}
```

## 7. Optimization Checklist

### 7.1 Rendering Optimizations
- [ ] Frustum culling implemented
- [ ] Distance culling implemented
- [ ] Occlusion culling implemented
- [ ] LOD system in place
- [ ] Entity pooling active
- [ ] Batch rendering enabled
- [ ] Texture atlasing used
- [ ] Material instancing applied
- [ ] Shadow optimization implemented

### 7.2 Memory Optimizations
- [ ] Memory pooling implemented
- [ ] Lazy loading active
- [ ] Cache size limits enforced
- [ ] Memory pressure handling in place
- [ ] Texture compression enabled
- [ ] Unused assets released
- [ ] Circular references eliminated

### 7.3 Code Optimizations
- [ ] Async operations properly structured
- [ ] Background processing utilized
- [ ] Database queries optimized
- [ ] Parsing cached appropriately
- [ ] API calls batched when possible
- [ ] Algorithms optimized (O(n) vs O(n²))

## 8. References

- [System Architecture Document](./01-system-architecture.md)
- [3D Rendering & Spatial Layout](./03-spatial-rendering.md)
- Apple Performance Best Practices
- Metal Performance Shaders Guide

## 9. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
