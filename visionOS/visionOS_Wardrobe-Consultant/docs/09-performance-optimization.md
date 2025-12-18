# Performance Budget & Optimization Plan

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines performance budgets, optimization strategies, and monitoring approaches for Wardrobe Consultant. Given the app's reliance on AR rendering, ML inference, and 3D graphics, meeting performance targets is critical for delivering a smooth 60fps experience on Vision Pro.

## 2. Performance Budget

### 2.1 Frame Rate Budget

**Target**: 60 FPS (16.67ms per frame)

**Frame Time Breakdown**:
```
Total Budget: 16.67ms per frame

├─ AR Tracking: 4ms (24%)
│  ├─ Body tracking: 2ms
│  └─ Person segmentation: 2ms
│
├─ 3D Rendering: 8ms (48%)
│  ├─ Model updates: 2ms
│  ├─ Physics simulation: 2ms
│  ├─ Shader execution: 3ms
│  └─ Lighting/shadows: 1ms
│
├─ Application Logic: 3ms (18%)
│  ├─ View updates: 1.5ms
│  ├─ State management: 1ms
│  └─ Event handling: 0.5ms
│
└─ System Overhead: 1.67ms (10%)
```

**Critical Threshold**: 50 FPS (20ms per frame)
- Below 50fps, motion sickness risk increases
- Below 45fps, experience becomes unusable

### 2.2 App Launch Budget

**Target**: < 2 seconds to interactive

**Launch Time Breakdown**:
```
Total Budget: 2000ms

├─ System Launch: 500ms (25%)
│  ├─ Process start: 200ms
│  └─ Framework loading: 300ms
│
├─ Core Data Stack: 400ms (20%)
│  ├─ Store loading: 300ms
│  └─ Initial fetch: 100ms
│
├─ ML Models: 500ms (25%)
│  ├─ Clothing classifier: 300ms
│  └─ Style recommender: 200ms
│
├─ Initial UI: 400ms (20%)
│  ├─ View hierarchy: 200ms
│  └─ Initial data load: 200ms
│
└─ Misc: 200ms (10%)
```

### 2.3 Memory Budget

**Total Budget**: 2GB (typical usage)
**Critical Threshold**: 3GB (maximum before issues)

**Memory Breakdown**:
```
Total: 2GB

├─ App Code & Frameworks: 100MB (5%)
├─ UI & View Hierarchy: 150MB (7.5%)
├─ Core Data & Cache: 200MB (10%)
├─ Wardrobe Photos: 500MB (25%)
├─ 3D Models (cached): 500MB (25%)
├─ AR Session: 300MB (15%)
├─ ML Models: 100MB (5%)
└─ Available Buffer: 150MB (7.5%)
```

### 2.4 Network Budget

**API Call Latency**:
- Weather API: < 500ms
- Calendar sync: < 1000ms
- CloudKit sync: < 2000ms

**Data Transfer**:
- Per session: < 10MB
- Per month: < 100MB

### 2.5 Storage Budget

**Initial Install**: < 50MB
**Maximum Storage**: < 5GB
- App binary: 50MB
- ML models: 30MB
- User data: Up to 4.92GB

### 2.6 Battery Budget

**Target**: < 10% battery drain per 30 minutes of use

**Power Consumption**:
- Idle: < 1% per minute
- Browsing wardrobe: < 2% per minute
- Virtual try-on (AR): < 5% per minute

## 3. Performance Monitoring

### 3.1 Metrics to Track

**Real-time Metrics**:
- Frame rate (FPS)
- Frame time (ms)
- Memory usage (MB)
- CPU usage (%)
- GPU usage (%)
- Battery level (%)
- Network latency (ms)

**Aggregated Metrics**:
- Average frame rate per session
- 95th percentile frame time
- Peak memory usage
- Crash-free sessions
- App launch time distribution

### 3.1 Instrumentation

```swift
import OSSignpost
import os.log

class PerformanceMonitor {
    private let log = OSLog(subsystem: "com.wardrobeconsultant", category: "Performance")

    // MARK: - Signposts
    func measureBlockPerformance<T>(
        name: StaticString,
        block: () throws -> T
    ) rethrows -> T {
        let signpostID = OSSignpostID(log: log)
        os_signpost(.begin, log: log, name: name, signpostID: signpostID)

        defer {
            os_signpost(.end, log: log, name: name, signpostID: signpostID)
        }

        return try block()
    }

    // MARK: - Frame Rate Monitoring
    private var frameTimes: [TimeInterval] = []
    private var lastFrameTime: TimeInterval?

    func recordFrame() {
        let currentTime = Date().timeIntervalSince1970

        if let lastTime = lastFrameTime {
            let frameTime = currentTime - lastTime
            frameTimes.append(frameTime)

            // Keep rolling window of 60 frames
            if frameTimes.count > 60 {
                frameTimes.removeFirst()
            }

            // Alert if dropping frames
            if frameTime > 0.02 { // 50 FPS threshold
                Logger.performance.warning("Frame drop detected: \(frameTime * 1000, privacy: .public)ms")
            }
        }

        lastFrameTime = currentTime
    }

    func getAverageFrameRate() -> Double {
        guard !frameTimes.isEmpty else { return 0 }
        let avgFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        return 1.0 / avgFrameTime
    }

    // MARK: - Memory Monitoring
    func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }

    func logMemoryWarningIfNeeded() {
        let memoryUsage = getCurrentMemoryUsage()
        let memoryMB = Double(memoryUsage) / 1_048_576

        if memoryMB > 2500 { // 2.5 GB warning threshold
            Logger.performance.warning("High memory usage: \(memoryMB, privacy: .public)MB")
            // Trigger cleanup
            NotificationCenter.default.post(name: .memoryWarning, object: nil)
        }
    }
}

// MARK: - Logger Extension
extension Logger {
    static let performance = Logger(subsystem: "com.wardrobeconsultant", category: "Performance")
}
```

### 3.3 MetricKit Integration

```swift
import MetricKit

class MetricsManager: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricsManager()

    private override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // App launch metrics
            if let launchMetrics = payload.applicationLaunchMetrics {
                let avgLaunchTime = launchMetrics.histogrammedTimeToFirstDraw.averageValue
                Logger.performance.info("Average launch time: \(avgLaunchTime, privacy: .public)s")

                // Alert if launch time exceeds budget
                if avgLaunchTime > 2.0 {
                    reportSlowLaunch(avgLaunchTime)
                }
            }

            // Memory metrics
            if let memoryMetrics = payload.memoryMetrics {
                let peakMemory = memoryMetrics.peakMemoryUsage
                Logger.performance.info("Peak memory: \(peakMemory, privacy: .public) bytes")
            }

            // Hang metrics
            if let hangMetrics = payload.applicationHangMetrics {
                let hangCount = hangMetrics.cumulativeHangTime
                Logger.performance.warning("Hang time: \(hangCount, privacy: .public)")
            }

            // CPU metrics
            if let cpuMetrics = payload.cpuMetrics {
                let cumulativeCPU = cpuMetrics.cumulativeCPUTime
                Logger.performance.info("CPU time: \(cumulativeCPU, privacy: .public)s")
            }
        }
    }

    private func reportSlowLaunch(_ time: TimeInterval) {
        // Report to analytics
    }
}
```

## 4. Optimization Strategies

### 4.1 AR Rendering Optimizations

**Level of Detail (LOD)**:
```swift
class LODOptimizer {
    func selectAppropriateModel(
        distance: Float,
        available models: [LODLevel: ModelEntity]
    ) -> ModelEntity {
        switch distance {
        case 0..<1.5:
            return models[.high] ?? models[.medium]!
        case 1.5..<3.0:
            return models[.medium]!
        default:
            return models[.low]!
        }
    }
}

enum LODLevel {
    case high    // 50K vertices
    case medium  // 20K vertices
    case low     // 5K vertices
}
```

**Occlusion Culling**:
```swift
class OcclusionCuller {
    func cullInvisibleObjects(
        camera: PerspectiveCamera,
        objects: [ModelEntity]
    ) -> [ModelEntity] {
        return objects.filter { object in
            isVisible(object, from: camera)
        }
    }

    private func isVisible(_ object: ModelEntity, from camera: PerspectiveCamera) -> Bool {
        // Frustum culling
        let bounds = object.visualBounds(relativeTo: nil)
        return camera.frustum.intersects(bounds)
    }
}
```

**Texture Optimization**:
```swift
class TextureOptimizer {
    func optimizeTexture(_ texture: TextureResource) -> TextureResource {
        // Use ASTC compression
        // Generate mipmaps
        // Reduce resolution for distant objects
        return texture
    }
}
```

### 4.2 Core Data Optimizations

**Batch Fetching**:
```swift
func fetchWardrobeItems() async throws -> [WardrobeItem] {
    let request: NSFetchRequest<WardrobeItem> = WardrobeItem.fetchRequest()

    // Batch configuration
    request.fetchBatchSize = 50
    request.returnsObjectsAsFaults = false

    // Prefetch relationships
    request.relationshipKeyPathsForPrefetching = ["outfits", "wearEvents"]

    return try await context.perform {
        try context.fetch(request)
    }
}
```

**Background Context**:
```swift
func saveItemsInBackground(_ items: [WardrobeItemDTO]) async throws {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    try await context.perform {
        for itemDTO in items {
            let item = WardrobeItem(context: context)
            // ... populate
        }
        try context.save()
    }
}
```

**Query Optimization**:
```swift
// BAD: Fetch all then filter in memory
let allItems = try await repository.fetchAll()
let shirts = allItems.filter { $0.category == "shirt" }

// GOOD: Filter in database
let request = WardrobeItem.fetchRequest()
request.predicate = NSPredicate(format: "category == %@", "shirt")
let shirts = try context.fetch(request)
```

### 4.3 Image Optimization

**Lazy Loading**:
```swift
struct WardrobeItemCard: View {
    let item: WardrobeItem

    var body: some View {
        LazyVStack {
            AsyncImage(url: item.photoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
        }
    }
}
```

**Image Compression**:
```swift
class ImageCompressor {
    func compress(_ image: UIImage, quality: CGFloat = 0.7) -> Data? {
        // Use HEIC format for better compression
        if let heicData = image.heicData(compressionQuality: quality) {
            return heicData
        }

        // Fallback to JPEG
        return image.jpegData(compressionQuality: quality)
    }

    func generateThumbnail(_ image: UIImage, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
```

### 4.4 Network Optimization

**Request Coalescing**:
```swift
actor RequestCoalescer<Key: Hashable, Value> {
    private var inFlightRequests: [Key: Task<Value, Error>] = [:]

    func fetchOrCoalesce(
        key: Key,
        fetch: @escaping () async throws -> Value
    ) async throws -> Value {
        // If request already in flight, await its result
        if let existingTask = inFlightRequests[key] {
            return try await existingTask.value
        }

        // Start new request
        let task = Task {
            defer { inFlightRequests[key] = nil }
            return try await fetch()
        }

        inFlightRequests[key] = task
        return try await task.value
    }
}

// Usage
let weatherCoalescer = RequestCoalescer<CLLocation, CurrentWeather>()

func getWeather(for location: CLLocation) async throws -> CurrentWeather {
    return try await weatherCoalescer.fetchOrCoalesce(key: location) {
        try await weatherService.getCurrentWeather(for: location)
    }
}
```

**Caching**:
```swift
actor CacheManager<Key: Hashable, Value> {
    private var cache: [Key: CachedValue<Value>] = [:]
    private let ttl: TimeInterval

    init(ttl: TimeInterval = 3600) {
        self.ttl = ttl
    }

    func get(_ key: Key) -> Value? {
        guard let cached = cache[key] else {
            return nil
        }

        // Check if expired
        if Date().timeIntervalSince(cached.timestamp) > ttl {
            cache[key] = nil
            return nil
        }

        return cached.value
    }

    func set(_ key: Key, value: Value) {
        cache[key] = CachedValue(value: value, timestamp: Date())
    }

    func clear() {
        cache.removeAll()
    }
}

struct CachedValue<T> {
    let value: T
    let timestamp: Date
}
```

### 4.5 ML Model Optimization

**Model Quantization**:
```python
import coremltools as ct

# Load model
model = ct.models.MLModel('ClothingClassifier.mlmodel')

# Quantize to 8-bit
quantized_model = ct.models.neural_network.quantization_utils.quantize_weights(
    model,
    nbits=8
)

# Save quantized model
quantized_model.save('ClothingClassifier_quantized.mlmodel')

# Size reduction: ~75% smaller
```

**Batch Inference**:
```swift
class BatchMLInference {
    func classifyMultipleItems(_ images: [UIImage]) async throws -> [ClothingClassification] {
        // Process in batches of 5
        let batchSize = 5
        var results: [ClothingClassification] = []

        for batchStart in stride(from: 0, to: images.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, images.count)
            let batch = Array(images[batchStart..<batchEnd])

            // Parallel inference within batch
            let batchResults = try await withThrowingTaskGroup(of: ClothingClassification.self) { group in
                for image in batch {
                    group.addTask {
                        try await self.classifySingle(image)
                    }
                }

                var results: [ClothingClassification] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }

            results.append(contentsOf: batchResults)
        }

        return results
    }
}
```

## 5. Memory Management

### 5.1 Memory Leak Detection

```swift
class MemoryLeakDetector {
    private var trackedObjects: [ObjectIdentifier: WeakBox] = [:]

    func track<T: AnyObject>(_ object: T, name: String) {
        let id = ObjectIdentifier(object)
        trackedObjects[id] = WeakBox(object: object, name: name)
    }

    func checkForLeaks() {
        for (id, box) in trackedObjects {
            if box.object == nil {
                // Object was deallocated (good)
                trackedObjects[id] = nil
            } else {
                // Potential leak (object still alive)
                Logger.performance.warning("Potential leak: \(box.name, privacy: .public)")
            }
        }
    }
}

class WeakBox {
    weak var object: AnyObject?
    let name: String

    init(object: AnyObject, name: String) {
        self.object = object
        self.name = name
    }
}
```

### 5.2 Memory Pressure Handling

```swift
class MemoryPressureManager {
    init() {
        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        Logger.performance.warning("Memory warning received")

        // Clear caches
        clearModelCache()
        clearImageCache()
        clearWeatherCache()

        // Reduce AR quality
        reduceARQuality()

        // Force garbage collection
        autoreleasepool {
            // Trigger cleanup
        }
    }

    private func clearModelCache() {
        ModelCache.shared.clear()
    }

    private func clearImageCache() {
        URLCache.shared.removeAllCachedResponses()
    }

    private func clearWeatherCache() {
        // Clear old weather data
    }

    private func reduceARQuality() {
        // Lower LOD level
        // Reduce texture quality
        // Disable physics simulation
    }
}
```

## 6. Profiling & Debugging

### 6.1 Instruments Profiles

**Time Profiler**:
- Identify hot code paths
- Find CPU bottlenecks
- Optimize expensive functions

**Allocations**:
- Track memory allocations
- Find memory leaks
- Identify retain cycles

**Core Data**:
- Identify slow queries
- Find excessive fetches
- Optimize relationships

**Metal**:
- GPU utilization
- Shader performance
- Rendering bottlenecks

### 6.2 Debug Flags

```swift
struct PerformanceFlags {
    static var showFPS = false
    static var showMemoryUsage = false
    static var logFrameTimes = false
    static var disablePhysics = false
    static var wireframeMode = false

    #if DEBUG
    static func enableDebugging() {
        showFPS = true
        showMemoryUsage = true
        logFrameTimes = true
    }
    #endif
}
```

### 6.3 Performance Overlay

```swift
struct PerformanceOverlay: View {
    @StateObject var monitor = PerformanceMonitor.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FPS: \(Int(monitor.currentFPS))")
            Text("Memory: \(monitor.memoryUsageMB, specifier: "%.1f") MB")
            Text("Frame Time: \(monitor.frameTime, specifier: "%.1f") ms")
        }
        .font(.system(.caption, design: .monospaced))
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .opacity(PerformanceFlags.showFPS ? 1 : 0)
    }
}
```

## 7. Performance Testing

### 7.1 Automated Performance Tests

```swift
class PerformanceTests: XCTestCase {
    func testAppLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testWardrobeLoadPerformance() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            _ = try? repository.fetchAll()
        }
    }

    func testARRenderingPerformance() {
        let metrics: [XCTMetric] = [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]

        measure(metrics: metrics) {
            // Render 60 frames
            for _ in 0..<60 {
                renderManager.updateFrame()
            }
        }
    }
}
```

### 7.2 Real-World Testing

**Test Scenarios**:
1. Large wardrobe (500+ items)
2. Extended AR session (10+ minutes)
3. Poor network conditions
4. Low memory device state
5. Background app activity

## 8. Performance Checklist

### 8.1 Pre-Release Checklist

- [ ] App launches in < 2 seconds
- [ ] AR maintains 60 FPS (90% of the time)
- [ ] Memory usage < 2GB typical
- [ ] No memory leaks detected
- [ ] Network requests cached appropriately
- [ ] Images compressed and optimized
- [ ] Core Data queries optimized
- [ ] ML models quantized
- [ ] LOD system implemented
- [ ] Battery usage acceptable

### 8.2 Post-Release Monitoring

- [ ] Monitor crash-free rate (target: 99.5%)
- [ ] Track average frame rate
- [ ] Monitor memory usage distribution
- [ ] Track API latency (95th percentile)
- [ ] Monitor app launch time distribution
- [ ] Track battery impact

## 9. Optimization Roadmap

### Phase 1: MVP (Week 1-4)
- [x] Define performance budgets
- [ ] Implement basic monitoring
- [ ] Optimize critical paths
- [ ] Test on device

### Phase 2: Beta (Week 5-8)
- [ ] Implement LOD system
- [ ] Optimize texture loading
- [ ] Reduce memory footprint
- [ ] Profile with Instruments

### Phase 3: Launch (Week 9-12)
- [ ] Final performance tuning
- [ ] MetricKit integration
- [ ] Real-world testing
- [ ] Performance dashboard

### Phase 4: Post-Launch
- [ ] Continuous monitoring
- [ ] Performance regression tests
- [ ] User-reported issues
- [ ] Iterative improvements

## 10. Next Steps

- ✅ Performance budget defined
- ⬜ Implement performance monitoring
- ⬜ Profile app with Instruments
- ⬜ Optimize hot paths
- ⬜ Test on Vision Pro hardware
- ⬜ Iterate based on metrics

---

**Document Status**: Draft - Ready for Review
**Next Document**: Onboarding & First-Run Experience Design
