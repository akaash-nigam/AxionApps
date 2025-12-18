# Performance Optimization Plan

## Performance Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Frame Rate | 90fps | 60fps minimum |
| App Launch Time | 2s | 5s max |
| Scene Load Time | 3s | 10s max |
| Object Detection | 50ms | 200ms max |
| Label Creation | 0.1s per object | 2s for full room |
| AI Response | 800ms | 2s max |
| Speech Recognition | 200ms | 500ms max |
| Memory Usage | 850MB | 1.2GB max |

## Rendering Optimization

### Frame Rate Optimization

```swift
class RenderingOptimizer {
    // Target 90fps = 11ms per frame
    let targetFrameTime: Double = 1.0 / 90.0

    func optimizeScene(_ scene: Scene) {
        // Enable occlusion culling
        scene.enableFrustumCulling()

        // LOD management
        updateLODLevels(in: scene)

        // Texture streaming
        streamTextures(for: scene)
    }

    private func updateLODLevels(in scene: Scene) {
        let camera = scene.camera
        for entity in scene.entities {
            let distance = simd_distance(entity.position, camera.position)

            // Switch LOD based on distance
            if distance < 2.0 {
                entity.useLOD(.high)
            } else if distance < 5.0 {
                entity.useLOD(.medium)
            } else {
                entity.useLOD(.low)
            }
        }
    }
}
```

### Occlusion Culling

```swift
class OcclusionCuller {
    func cullHiddenEntities(in scene: Scene, from viewpoint: SIMD3<Float>) {
        // Frustum culling
        let frustum = calculateViewFrustum(from: viewpoint)

        for entity in scene.entities {
            // Check if entity is in frustum
            if !frustum.contains(entity.boundingBox) {
                entity.isEnabled = false
                continue
            }

            // Check if entity is occluded
            if isOccluded(entity, from: viewpoint) {
                entity.isEnabled = false
            } else {
                entity.isEnabled = true
            }
        }
    }

    private func isOccluded(_ entity: Entity, from viewpoint: SIMD3<Float>) -> Bool {
        // Ray cast to check occlusion
        // Simplified implementation
        return false
    }
}
```

### Texture Optimization

```swift
class TextureManager {
    private var textureCache: [String: TextureResource] = [:]
    private let maxCacheSize: Int = 200_000_000 // 200MB

    func loadTexture(named name: String, quality: TextureQuality) async -> TextureResource? {
        let cacheKey = "\(name)_\(quality)"

        // Check cache
        if let cached = textureCache[cacheKey] {
            return cached
        }

        // Load appropriate quality
        let texture = await loadTextureFromDisk(name: name, quality: quality)
        textureCache[cacheKey] = texture

        // Manage cache size
        evictIfNeeded()

        return texture
    }

    private func loadTextureFromDisk(name: String, quality: TextureQuality) async -> TextureResource? {
        let filename: String
        switch quality {
        case .high:
            filename = "\(name)_4k.png"
        case .medium:
            filename = "\(name)_2k.png"
        case .low:
            filename = "\(name)_1k.png"
        }

        return try? await TextureResource(named: filename)
    }

    private func evictIfNeeded() {
        var currentSize = textureCache.values.reduce(0) { $0 + $1.estimatedSize }

        if currentSize > maxCacheSize {
            // Remove least recently used
            let sorted = textureCache.sorted { $0.value.lastAccessTime < $1.value.lastAccessTime }
            for (key, texture) in sorted {
                textureCache.removeValue(forKey: key)
                currentSize -= texture.estimatedSize

                if currentSize <= maxCacheSize * 8 / 10 { // 80%
                    break
                }
            }
        }
    }
}

enum TextureQuality {
    case high, medium, low
}
```

## Memory Optimization

### Memory Profiling

```swift
class MemoryProfiler {
    func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }

    func logMemoryWarning() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("⚠️ Memory warning received")
            self.triggerMemoryCleanup()
        }
    }

    private func triggerMemoryCleanup() {
        // Clear caches
        URLCache.shared.removeAllCachedResponses()

        // Unload unused assets
        AssetManager.shared.clearUnusedAssets()

        // Request autoreleasepool drain
    }
}
```

### Object Pooling

```swift
class EntityPool<T: Entity> {
    private var available: [T] = []
    private var inUse: Set<ObjectIdentifier> = []
    private let factory: () -> T

    init(initialSize: Int = 10, factory: @escaping () -> T) {
        self.factory = factory

        for _ in 0..<initialSize {
            available.append(factory())
        }
    }

    func acquire() -> T {
        if available.isEmpty {
            return factory()
        }

        let entity = available.removeLast()
        inUse.insert(ObjectIdentifier(entity))
        return entity
    }

    func release(_ entity: T) {
        inUse.remove(ObjectIdentifier(entity))
        entity.reset() // Reset to default state
        available.append(entity)
    }

    func releaseAll() {
        // Move all in-use back to available
        available.removeAll()
        inUse.removeAll()
    }
}

// Usage
let labelPool = EntityPool<ObjectLabelEntity>(initialSize: 50) {
    ObjectLabelEntity.default
}

// Acquire
let label = labelPool.acquire()

// Use label...

// Release when done
labelPool.release(label)
```

## Network Optimization

### Request Batching

```swift
class BatchRequestManager {
    private var pendingRequests: [APIRequest] = []
    private let batchInterval: TimeInterval = 0.5
    private var batchTimer: Timer?

    func enqueue(_ request: APIRequest) {
        pendingRequests.append(request)

        if batchTimer == nil {
            batchTimer = Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: false) { [weak self] _ in
                self?.executeBatch()
            }
        }
    }

    private func executeBatch() {
        guard !pendingRequests.isEmpty else { return }

        // Combine requests
        let batchRequest = APIBatchRequest(requests: pendingRequests)

        Task {
            do {
                let responses = try await APIClient.shared.execute(batchRequest)
                distributeResponses(responses)
            } catch {
                handleError(error)
            }
        }

        pendingRequests.removeAll()
        batchTimer = nil
    }
}
```

### Response Caching

```swift
class ResponseCache {
    private let cache = NSCache<NSString, CachedResponse>()

    func cache(_ response: Data, for key: String, ttl: TimeInterval) {
        let cached = CachedResponse(data: response, expiry: Date().addingTimeInterval(ttl))
        cache.setObject(cached, forKey: key as NSString)
    }

    func get(_ key: String) -> Data? {
        guard let cached = cache.object(forKey: key as NSString) else {
            return nil
        }

        // Check expiry
        if cached.expiry < Date() {
            cache.removeObject(forKey: key as NSString)
            return nil
        }

        return cached.data
    }
}

class CachedResponse {
    let data: Data
    let expiry: Date

    init(data: Data, expiry: Date) {
        self.data = data
        self.expiry = expiry
    }
}
```

## CPU Optimization

### Background Processing

```swift
class BackgroundProcessor {
    private let processingQueue = DispatchQueue(
        label: "com.languageimmersion.processing",
        qos: .userInitiated,
        attributes: .concurrent
    )

    func processInBackground<T>(_ task: @escaping () throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            processingQueue.async {
                do {
                    let result = try task()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func batchProcess<T, U>(_ items: [T], transform: @escaping (T) async throws -> U) async throws -> [U] {
        // Process in parallel with limited concurrency
        return try await withThrowingTaskGroup(of: (Int, U).self) { group in
            for (index, item) in items.enumerated() {
                group.addTask {
                    let result = try await transform(item)
                    return (index, result)
                }
            }

            var results: [(Int, U)] = []
            for try await result in group {
                results.append(result)
            }

            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
}
```

### Lazy Initialization

```swift
class LazyResourceLoader {
    private lazy var objectDetector: ObjectDetector = {
        return ObjectDetector()
    }()

    private lazy var grammarChecker: GrammarChecker = {
        return GrammarChecker()
    }()

    // Only loaded when needed
    func getObjectDetector() -> ObjectDetector {
        return objectDetector
    }
}
```

## Database Optimization

### Efficient Queries

```swift
class OptimizedQueries {
    func fetchVocabulary(for language: Language, limit: Int = 100) -> [VocabularyWord] {
        let context = PersistenceController.shared.container.viewContext

        let request: NSFetchRequest<VocabularyWordEntity> = VocabularyWordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "languageCode == %@", language.id)
        request.sortDescriptors = [NSSortDescriptor(key: "frequency", ascending: false)]
        request.fetchLimit = limit

        // Use batch faulting for better performance
        request.returnsObjectsAsFaults = false

        let results = try? context.fetch(request)
        return results?.map { $0.toModel() } ?? []
    }

    func batchInsert(_ words: [VocabularyWord]) {
        let context = PersistenceController.shared.container.newBackgroundContext()

        context.perform {
            // Batch insert is more efficient
            for word in words {
                let entity = VocabularyWordEntity(context: context)
                entity.configure(from: word)
            }

            try? context.save()
        }
    }
}
```

### Indexing

```sql
-- CoreData model indexes
CREATE INDEX idx_vocabulary_language ON VocabularyWordEntity(languageCode);
CREATE INDEX idx_vocabulary_state ON VocabularyWordEntity(learningState);
CREATE INDEX idx_conversation_date ON ConversationEntity(startTime);
```

## Asset Loading Optimization

### Progressive Loading

```swift
class ProgressiveEnvironmentLoader {
    func loadEnvironment(_ env: Environment) async {
        // Phase 1: Skeleton (immediate)
        await loadSkeleton(env)

        // Phase 2: Low-res textures (500ms)
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadLowResTextures(env)
        }

        // Phase 3: High-res textures (background)
        Task(priority: .low) {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await loadHighResTextures(env)
        }
    }

    private func loadSkeleton(_ env: Environment) async {
        // Load simple geometry only
    }

    private func loadLowResTextures(_ env: Environment) async {
        // Load 1K textures
    }

    private func loadHighResTextures(_ env: Environment) async {
        // Load 4K textures
    }
}
```

## Monitoring & Profiling

### Performance Metrics

```swift
class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private var metrics: [String: [Double]] = [:]

    func measure<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let start = Date()
        let result = try block()
        let duration = Date().timeIntervalSince(start)

        recordMetric(operation, duration: duration)

        return result
    }

    private func recordMetric(_ name: String, duration: TimeInterval) {
        if metrics[name] == nil {
            metrics[name] = []
        }

        metrics[name]?.append(duration)

        // Report if exceeds threshold
        if duration > thresholdFor(name) {
            print("⚠️ Performance warning: \(name) took \(duration * 1000)ms")
        }
    }

    private func thresholdFor(_ operation: String) -> TimeInterval {
        switch operation {
        case "object_detection": return 0.2
        case "ai_response": return 2.0
        case "scene_load": return 10.0
        default: return 1.0
        }
    }

    func getAverageTime(for operation: String) -> TimeInterval? {
        guard let times = metrics[operation], !times.isEmpty else { return nil }
        return times.reduce(0, +) / Double(times.count)
    }
}

// Usage
let result = PerformanceMonitor.shared.measure("object_detection") {
    detector.detectObjects(in: image)
}
```

## Optimization Checklist

- [ ] Frame rate consistently above 60fps
- [ ] Memory usage under 1GB
- [ ] App launch under 3 seconds
- [ ] Scene transitions smooth (no stuttering)
- [ ] Network requests cached appropriately
- [ ] Large assets loaded progressively
- [ ] Database queries optimized with indexes
- [ ] Object pooling for frequently created entities
- [ ] Textures compressed and appropriately sized
- [ ] Background tasks don't block main thread
- [ ] Memory warnings handled gracefully
- [ ] Performance metrics monitored in production
