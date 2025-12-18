# Performance & Optimization Plan
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Performance Targets

### 1.1 Key Metrics

| Metric | Target | Critical |
|--------|--------|----------|
| Frame Rate | 90 FPS | 60 FPS minimum |
| App Launch | < 2 seconds | < 3 seconds |
| Annotation Load | < 1 second (100 items) | < 2 seconds |
| CloudKit Sync | < 5 seconds | < 10 seconds |
| Memory Usage | < 500 MB | < 1 GB |
| Battery Impact | Low | Medium |

### 1.2 Performance Budget

```
Per Frame (16.6ms @ 60 FPS):
- AR Tracking: 4ms
- Scene Rendering: 6ms
- Physics/Collision: 1ms
- UI Updates: 2ms
- Business Logic: 2ms
- Buffer: 1.6ms
```

---

## 2. Rendering Optimization

### 2.1 Level of Detail (LOD)

```swift
class LODManager {
    func updateLOD(for entities: [AnnotationEntity], cameraPosition: SIMD3<Float>) {
        for entity in entities {
            let distance = simd_distance(entity.position, cameraPosition)

            let lod = calculateLOD(distance: distance)
            entity.applyLOD(lod)
        }
    }

    private func calculateLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<2: return .high    // Full detail
        case 2..<5: return .medium  // Simplified
        case 5..<10: return .low    // Icon only
        default: return .culled     // Not rendered
        }
    }
}

enum LODLevel {
    case high    // Full annotation with text, icon, background
    case medium  // Simplified: icon + title only
    case low     // Icon only, small
    case culled  // Not rendered
}

extension AnnotationEntity {
    func applyLOD(_ lod: LODLevel) {
        switch lod {
        case .high:
            showFullDetail()
        case .medium:
            showSimplified()
        case .low:
            showIcon()
        case .culled:
            isEnabled = false
        }
    }

    private func showSimplified() {
        // Hide text content
        textAttachment?.isEnabled = false

        // Show only icon and small background
        iconEntity.scale = SIMD3(repeating: 0.5)
        cardEntity.scale = SIMD3(repeating: 0.3)
    }
}
```

### 2.2 Frustum Culling

```swift
class FrustumCuller {
    func cullEntities(_ entities: [AnnotationEntity], frustum: ViewFrustum) -> [AnnotationEntity] {
        return entities.filter { entity in
            let position = entity.position(relativeTo: nil)
            return frustum.contains(position)
        }
    }
}

struct ViewFrustum {
    var planes: [SIMD4<Float>] // 6 frustum planes

    func contains(_ point: SIMD3<Float>) -> Bool {
        for plane in planes {
            let distance = dot(SIMD3(plane.x, plane.y, plane.z), point) + plane.w
            if distance < 0 { return false }
        }
        return true
    }
}
```

### 2.3 Occlusion Culling

```swift
class OcclusionManager {
    func cullOccluded(_ entities: [AnnotationEntity], scene: Scene) -> [AnnotationEntity] {
        return entities.filter { entity in
            !isOccluded(entity, in: scene)
        }
    }

    private func isOccluded(_ entity: Entity, in scene: Scene) -> Bool {
        // Use visionOS scene understanding to detect occlusion
        // Check if entity is behind walls, furniture, etc.
        return false // Placeholder
    }
}
```

### 2.4 Instancing for Similar Annotations

```swift
class InstancedRenderingManager {
    func batchSimilarAnnotations(_ entities: [AnnotationEntity]) {
        // Group by type and appearance
        let groups = Dictionary(grouping: entities) { entity in
            entity.appearance.hash
        }

        for (_, group) in groups {
            if group.count > 3 {
                // Use instanced rendering for this group
                createInstancedBatch(for: group)
            }
        }
    }

    private func createInstancedBatch(for entities: [AnnotationEntity]) {
        // Create single mesh with multiple instances
        // Each instance has unique transform
    }
}
```

---

## 3. Memory Optimization

### 3.1 Lazy Loading

```swift
class AnnotationLoader {
    private var loadedAnnotations = Set<UUID>()
    private let maxLoadedDistance: Float = 20.0

    func updateLoadedAnnotations(cameraPosition: SIMD3<Float>) async {
        // Load nearby
        let nearby = await spatialQuery.findAnnotations(
            near: cameraPosition,
            radius: maxLoadedDistance
        )

        for annotation in nearby {
            if !loadedAnnotations.contains(annotation.id) {
                await load(annotation)
                loadedAnnotations.insert(annotation.id)
            }
        }

        // Unload distant
        let toUnload = loadedAnnotations.filter { id in
            guard let annotation = annotationCache[id] else { return true }
            let distance = simd_distance(annotation.position, cameraPosition)
            return distance > maxLoadedDistance * 1.5
        }

        for id in toUnload {
            unload(id)
            loadedAnnotations.remove(id)
        }
    }

    private func load(_ annotation: Annotation) async {
        // Load media assets
        if let mediaURL = annotation.content.mediaURL {
            await mediaCache.load(mediaURL)
        }

        // Create entity
        await renderer.createEntity(for: annotation)
    }

    private func unload(_ id: UUID) {
        renderer.removeEntity(for: id)
        mediaCache.evict(id)
    }
}
```

### 3.2 Image Downsampling

```swift
class ImageOptimizer {
    func downsample(imageAt url: URL, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions) else {
            return nil
        }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
}
```

### 3.3 Memory Monitoring

```swift
actor MemoryMonitor {
    private var currentMemory: UInt64 = 0
    private let warningThreshold: UInt64 = 800_000_000 // 800 MB
    private let criticalThreshold: UInt64 = 1_000_000_000 // 1 GB

    func checkMemory() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            currentMemory = info.resident_size

            if currentMemory > criticalThreshold {
                handleCriticalMemory()
            } else if currentMemory > warningThreshold {
                handleWarningMemory()
            }
        }
    }

    private func handleWarningMemory() {
        // Clear caches
        mediaCache.evictOldest(count: 10)
    }

    private func handleCriticalMemory() {
        // Aggressive cleanup
        mediaCache.clear()
        unloadDistantAnnotations()
    }
}
```

---

## 4. Network Optimization

### 4.1 Request Batching

```swift
class BatchNetworkManager {
    private var pendingUploads: [Annotation] = []
    private let batchSize = 50
    private let batchInterval: TimeInterval = 5.0

    func queueUpload(_ annotation: Annotation) {
        pendingUploads.append(annotation)

        if pendingUploads.count >= batchSize {
            Task {
                await flush()
            }
        }
    }

    func flush() async {
        guard !pendingUploads.isEmpty else { return }

        let batch = Array(pendingUploads.prefix(batchSize))
        pendingUploads.removeFirst(min(batchSize, pendingUploads.count))

        do {
            try await cloudKitService.uploadBatch(batch)
        } catch {
            // Re-queue failed items
            pendingUploads.append(contentsOf: batch)
        }
    }

    func startPeriodicFlush() {
        Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: true) { _ in
            Task {
                await self.flush()
            }
        }
    }
}
```

### 4.2 Caching Strategy

```swift
class CacheManager {
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let diskCache: URL
    private let maxCacheSize: Int64 = 500_000_000 // 500 MB

    init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50_000_000 // 50 MB

        diskCache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AnnotationCache")

        try? FileManager.default.createDirectory(at: diskCache, withIntermediateDirectories: true)
    }

    func get(key: String) async -> Data? {
        // Check memory cache
        if let cached = memoryCache.object(forKey: key as NSString) as? Data {
            return cached
        }

        // Check disk cache
        let fileURL = diskCache.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL) {
            // Promote to memory cache
            memoryCache.setObject(data as NSData, forKey: key as NSString)
            return data
        }

        return nil
    }

    func set(key: String, value: Data) async {
        // Set in memory
        memoryCache.setObject(value as NSData, forKey: key as NSString)

        // Set on disk
        let fileURL = diskCache.appendingPathComponent(key)
        try? value.write(to: fileURL)

        // Check cache size
        await cleanupIfNeeded()
    }

    private func cleanupIfNeeded() async {
        let cacheSize = try? FileManager.default
            .contentsOfDirectory(at: diskCache, includingPropertiesForKeys: [.fileSizeKey])
            .reduce(0) { total, url in
                let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                return total + (size ?? 0)
            }

        if let size = cacheSize, size > maxCacheSize {
            // Delete oldest files
            await evictOldest(targetSize: maxCacheSize / 2)
        }
    }
}
```

---

## 5. Database Optimization

### 5.1 Indexing

```swift
// SwiftData automatically indexes @Attribute(.unique) properties
// Add compound indexes for common queries

@Model
final class Annotation {
    @Attribute(.unique) var id: UUID

    // Frequently queried together
    var layerID: UUID  // Indexed
    var ownerID: String // Indexed
    var createdAt: Date // Indexed for sorting
    var isDeleted: Bool // Indexed for filtering
}

// Query optimization
extension AnnotationRepository {
    func fetchRecent(limit: Int) async throws -> [Annotation] {
        let descriptor = FetchDescriptor<Annotation>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return try modelContext.fetch(descriptor)
    }
}
```

### 5.2 Query Optimization

```swift
// BAD: Fetch all then filter
let annotations = try await repository.fetchAll()
let filtered = annotations.filter { $0.layerID == targetLayerID }

// GOOD: Filter in database
let descriptor = FetchDescriptor<Annotation>(
    predicate: #Predicate { annotation in
        annotation.layerID == targetLayerID &&
        !annotation.isDeleted
    }
)
let filtered = try modelContext.fetch(descriptor)
```

---

## 6. Background Processing

### 6.1 Task Prioritization

```swift
class BackgroundTaskManager {
    func scheduleSync(priority: TaskPriority = .utility) {
        Task(priority: priority) {
            await syncCoordinator.sync()
        }
    }

    func processImages(priority: TaskPriority = .background) {
        Task(priority: priority) {
            await imageProcessor.processQueue()
        }
    }

    func fetchNearbyAnnotations(priority: TaskPriority = .userInitiated) {
        Task(priority: priority) {
            await annotationLoader.loadNearby()
        }
    }
}

// Priority levels:
// .userInitiated - User waiting for result (e.g., loading visible annotations)
// .utility - Important but not urgent (e.g., background sync)
// .background - Can be deferred (e.g., cache cleanup)
```

---

## 7. Battery Optimization

### 7.1 Reduce Update Frequency

```swift
class AdaptiveUpdateManager {
    private var updateInterval: TimeInterval = 1.0 / 60.0 // 60 FPS
    private let batteryMonitor = BatteryMonitor()

    func updateUpdateInterval() {
        let batteryLevel = batteryMonitor.level
        let isPowerConnected = batteryMonitor.isCharging

        if isPowerConnected {
            updateInterval = 1.0 / 90.0 // 90 FPS when charging
        } else if batteryLevel < 0.2 {
            updateInterval = 1.0 / 30.0 // 30 FPS when low battery
        } else if batteryLevel < 0.5 {
            updateInterval = 1.0 / 60.0 // 60 FPS
        } else {
            updateInterval = 1.0 / 90.0 // 90 FPS
        }
    }
}

class BatteryMonitor {
    var level: Float {
        UIDevice.current.batteryLevel
    }

    var isCharging: Bool {
        UIDevice.current.batteryState == .charging ||
        UIDevice.current.batteryState == .full
    }
}
```

---

## 8. Profiling & Monitoring

### 8.1 Instruments

```
Recommended Instruments templates:
- Time Profiler: Find slow code paths
- Allocations: Track memory usage
- Leaks: Detect memory leaks
- Network: Monitor CloudKit traffic
- Metal System Trace: GPU performance
```

### 8.2 Performance Logging

```swift
import OSLog

class PerformanceLogger {
    private static let logger = Logger(subsystem: "com.example.RealityAnnotation", category: "Performance")

    static func measure<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - start
            logger.info("[\(operation)] took \(duration * 1000, format: .fixed(precision: 2))ms")
        }
        return try block()
    }

    static func measureAsync<T>(_ operation: String, block: () async throws -> T) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - start
            logger.info("[\(operation)] took \(duration * 1000, format: .fixed(precision: 2))ms")
        }
        return try await block()
    }
}

// Usage
let annotations = await PerformanceLogger.measureAsync("FetchAnnotations") {
    try await repository.fetchAll()
}
```

---

## 9. Optimization Checklist

### 9.1 Rendering

- ✅ LOD implementation
- ✅ Frustum culling
- ✅ Occlusion culling
- ✅ Instanced rendering for similar objects
- ✅ Billboard optimization (update only when needed)

### 9.2 Memory

- ✅ Lazy loading of distant annotations
- ✅ Image downsampling
- ✅ Memory monitoring
- ✅ Cache eviction policy
- ✅ Weak references to avoid retain cycles

### 9.3 Network

- ✅ Request batching
- ✅ Caching strategy
- ✅ Delta sync (only changed data)
- ✅ Compression for media assets
- ✅ Offline queue

### 9.4 Database

- ✅ Proper indexing
- ✅ Query optimization
- ✅ Fetch limits
- ✅ Pagination for large result sets

### 9.5 Battery

- ✅ Adaptive frame rate
- ✅ Background task scheduling
- ✅ Efficient sync intervals
- ✅ Minimize wake-ups

---

## 10. Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testAnnotationLoadTime() async throws {
        measure {
            _ = try! await annotationService.fetchAnnotations(in: testLayerID)
        }
    }

    func testRenderingPerformance() {
        let entities = createTestEntities(count: 100)

        measure {
            renderer.update(entities: entities, cameraTransform: testTransform)
        }
    }

    func testMemoryUsage() {
        measureMetrics([XCTMemoryMetric()]) {
            // Load 1000 annotations
            _ = loadAnnotations(count: 1000)
        }
    }
}
```

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture, Spatial Persistence
**Next Steps**: Create Testing Strategy document
