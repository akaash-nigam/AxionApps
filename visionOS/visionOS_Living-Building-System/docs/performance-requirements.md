# Performance Requirements Specification
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document defines the performance requirements and optimization strategies for the Living Building System on visionOS, ensuring smooth, responsive user experiences.

## 2. Performance Targets

### 2.1 Rendering Performance

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Frame Rate | 60 FPS | 45 FPS |
| Frame Time | ≤ 16.67ms | ≤ 22ms |
| Particle Count | 5000 active | 10000 max |
| Draw Calls | ≤ 500/frame | ≤ 1000/frame |

### 2.2 Response Times

| Action | Target | Maximum |
|--------|--------|---------|
| App Launch | < 2s | < 4s |
| Device Toggle | < 200ms | < 500ms |
| Scene Execution | < 500ms | < 1s |
| Contextual Display | < 300ms | < 500ms |
| Energy Data Update | < 100ms | < 250ms |

### 2.3 Memory Usage

| Component | Target | Maximum |
|-----------|--------|---------|
| App Baseline | < 100 MB | < 200 MB |
| Immersive Space | < 300 MB | < 500 MB |
| Energy Visualization | < 50 MB | < 100 MB |
| Image Cache | < 50 MB | < 100 MB |
| Total Peak | < 500 MB | < 800 MB |

### 2.4 Battery Impact

| Scenario | Target | Maximum |
|----------|--------|---------|
| Idle Monitoring | < 2% drain/hour | < 5% drain/hour |
| Active Use | < 10% drain/hour | < 15% drain/hour |
| Energy Visualization | < 12% drain/hour | < 20% drain/hour |

### 2.5 Network Performance

| Metric | Target |
|--------|--------|
| API Request Timeout | 10s |
| Concurrent Requests | ≤ 10 |
| Max Retries | 3 |
| Cache Hit Rate | > 80% |

## 3. Performance Budgets

### 3.1 CPU Budget

```swift
struct CPUBudget {
    static let mainThreadBudget: TimeInterval = 16.67 // ms (60 FPS)
    static let backgroundTaskBudget: TimeInterval = 100.0 // ms

    // Per-frame budgets
    static let renderingBudget: TimeInterval = 10.0 // ms
    static let uiUpdateBudget: TimeInterval = 4.0 // ms
    static let dataProcessingBudget: TimeInterval = 2.0 // ms
}
```

### 3.2 Memory Budget

```swift
struct MemoryBudget {
    static let baselineMemory: Int = 100 * 1024 * 1024 // 100 MB
    static let immersiveSpaceMemory: Int = 300 * 1024 * 1024 // 300 MB
    static let cacheMemory: Int = 50 * 1024 * 1024 // 50 MB

    static func checkBudget() -> Bool {
        let used = MemoryMonitor.shared.currentUsage()
        let total = baselineMemory + immersiveSpaceMemory + cacheMemory

        return used <= total
    }
}
```

## 4. Optimization Strategies

### 4.1 Lazy Loading

```swift
class LazyImageLoader {
    private var cache: [UUID: UIImage] = [:]
    private var loading: Set<UUID> = []

    func loadImage(for id: UUID, url: URL) async -> UIImage? {
        // Return cached if available
        if let cached = cache[id] {
            return cached
        }

        // Prevent duplicate loads
        guard !loading.contains(id) else {
            // Wait for existing load
            while loading.contains(id) {
                try? await Task.sleep(for: .milliseconds(100))
            }
            return cache[id]
        }

        loading.insert(id)
        defer { loading.remove(id) }

        // Load image
        guard let data = try? await URLSession.shared.data(from: url).0,
              let image = UIImage(data: data) else {
            return nil
        }

        cache[id] = image
        return image
    }
}
```

### 4.2 View Caching

```swift
struct CachedView<Content: View>: View {
    let content: Content
    @State private var renderedImage: UIImage?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if let image = renderedImage {
            Image(uiImage: image)
        } else {
            content
                .onAppear {
                    // Render once and cache
                    renderedImage = renderAsImage(content)
                }
        }
    }

    private func renderAsImage(_ view: Content) -> UIImage? {
        // Render view to image
        nil // Implementation
    }
}
```

### 4.3 Data Pagination

```swift
class PaginatedDataLoader<T> {
    private let pageSize = 50
    private var currentPage = 0
    private var allLoaded = false

    func loadNextPage() async throws -> [T] {
        guard !allLoaded else { return [] }

        let offset = currentPage * pageSize
        let items = try await fetchItems(offset: offset, limit: pageSize)

        if items.count < pageSize {
            allLoaded = true
        }

        currentPage += 1
        return items
    }

    private func fetchItems(offset: Int, limit: Int) async throws -> [T] {
        // Fetch from database or API
        []
    }
}
```

### 4.4 Throttling & Debouncing

```swift
actor Throttler {
    private var lastExecutionTime: Date?
    private let minimumInterval: TimeInterval

    init(interval: TimeInterval) {
        self.minimumInterval = interval
    }

    func execute<T>(_ operation: () async throws -> T) async throws -> T? {
        let now = Date()

        if let lastTime = lastExecutionTime,
           now.timeIntervalSince(lastTime) < minimumInterval {
            // Skip execution
            return nil
        }

        lastExecutionTime = now
        return try await operation()
    }
}

// Usage: Throttle energy updates to 10 Hz
class EnergyManager {
    private let updateThrottler = Throttler(interval: 0.1) // 100ms

    func updateEnergyData(_ data: EnergyReading) async {
        _ = await updateThrottler.execute {
            await processEnergyData(data)
        }
    }
}
```

```swift
actor Debouncer {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func submit(_ operation: @escaping () async -> Void) {
        task?.cancel()

        task = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            await operation()
        }
    }
}

// Usage: Debounce search input
class SearchManager {
    private let searchDebouncer = Debouncer(delay: 0.3)

    func search(query: String) {
        await searchDebouncer.submit {
            await performSearch(query)
        }
    }
}
```

## 5. Performance Monitoring

### 5.1 Frame Rate Monitor

```swift
class FrameRateMonitor {
    private var frameCount = 0
    private var lastTime = CACurrentMediaTime()
    private var fps: Double = 60.0

    func update() {
        frameCount += 1

        let now = CACurrentMediaTime()
        let elapsed = now - lastTime

        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastTime = now

            if fps < 45 {
                Logger.shared.log(
                    "Low frame rate detected: \(fps) FPS",
                    level: .warning
                )
            }
        }
    }

    func getCurrentFPS() -> Double {
        fps
    }
}
```

### 5.2 Memory Monitor

```swift
class MemoryMonitor {
    static let shared = MemoryMonitor()

    func currentUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return 0
        }

        return Int(info.resident_size)
    }

    func startMonitoring(interval: TimeInterval = 5.0) {
        Task {
            while !Task.isCancelled {
                let usage = currentUsage()
                let usageMB = Double(usage) / 1024 / 1024

                Logger.shared.log(
                    "Memory usage: \(String(format: "%.1f", usageMB)) MB",
                    level: .debug
                )

                if usage > MemoryBudget.baselineMemory + MemoryBudget.immersiveSpaceMemory {
                    Logger.shared.log(
                        "High memory usage detected",
                        level: .warning
                    )
                }

                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }
}
```

### 5.3 Performance Metrics

```swift
class PerformanceMetrics {
    struct Metric {
        let name: String
        let duration: TimeInterval
        let timestamp: Date
    }

    private var metrics: [Metric] = []

    func measure<T>(
        _ name: String,
        operation: () async throws -> T
    ) async rethrows -> T {
        let start = Date()
        let result = try await operation()
        let duration = Date().timeIntervalSince(start)

        metrics.append(Metric(
            name: name,
            duration: duration,
            timestamp: start
        ))

        if duration > 1.0 {
            Logger.shared.log(
                "Slow operation: \(name) took \(duration)s",
                level: .warning
            )
        }

        return result
    }

    func getMetrics(for name: String) -> [Metric] {
        metrics.filter { $0.name == name }
    }

    func averageDuration(for name: String) -> TimeInterval? {
        let filtered = getMetrics(for: name)
        guard !filtered.isEmpty else { return nil }

        let total = filtered.reduce(0.0) { $0 + $1.duration }
        return total / Double(filtered.count)
    }
}
```

## 6. Profiling & Benchmarking

### 6.1 Benchmark Tests

```swift
@Test("Device toggle performance")
func benchmarkDeviceToggle() async throws {
    let appState = AppState()
    let mockService = MockHomeKitService()
    let manager = DeviceManager(appState: appState, homeKitService: mockService)

    var device = SmartDevice(name: "Test Light", deviceType: .light)
    appState.devices[device.id] = device

    let iterations = 100
    let start = Date()

    for _ in 0..<iterations {
        try await manager.toggleDevice(device)
    }

    let duration = Date().timeIntervalSince(start)
    let avgTime = duration / Double(iterations)

    print("Average toggle time: \(avgTime * 1000)ms")

    // Should be under 200ms
    #expect(avgTime < 0.2)
}

@Test("Energy data processing performance")
func benchmarkEnergyProcessing() async throws {
    let readings = (0..<1000).map { _ in
        EnergyReading(timestamp: Date(), energyType: .electricity)
    }

    let start = Date()

    // Process readings
    let aggregated = aggregateReadings(readings)

    let duration = Date().timeIntervalSince(start)

    print("Processing time for 1000 readings: \(duration * 1000)ms")

    // Should complete in under 100ms
    #expect(duration < 0.1)
}
```

### 6.2 Instruments Integration

```swift
import os.signpost

class PerformanceSignposts {
    static let subsystem = "com.lbs.app"

    static let deviceControl = OSLog(subsystem: subsystem, category: "Device Control")
    static let energyUpdate = OSLog(subsystem: subsystem, category: "Energy Update")
    static let rendering = OSLog(subsystem: subsystem, category: "Rendering")

    static func measure<T>(
        _ log: OSLog,
        name: StaticString,
        operation: () throws -> T
    ) rethrows -> T {
        let signpostID = OSSignpostID(log: log)
        os_signpost(.begin, log: log, name: name, signpostID: signpostID)
        defer {
            os_signpost(.end, log: log, name: name, signpostID: signpostID)
        }

        return try operation()
    }
}

// Usage
func toggleDevice(_ device: SmartDevice) async throws {
    try await PerformanceSignposts.measure(.deviceControl, name: "Toggle Device") {
        try await homeKitService.toggleDevice(device)
    }
}
```

## 7. Optimization Techniques

### 7.1 Entity Pooling

```swift
class EntityPool {
    private var availableEntities: [Entity] = []
    private var inUseEntities: Set<Entity> = []
    private let maxPoolSize = 1000

    func acquire() -> Entity {
        if let entity = availableEntities.popLast() {
            entity.isEnabled = true
            inUseEntities.insert(entity)
            return entity
        } else {
            let entity = Entity()
            inUseEntities.insert(entity)
            return entity
        }
    }

    func release(_ entity: Entity) {
        entity.isEnabled = false
        inUseEntities.remove(entity)

        if availableEntities.count < maxPoolSize {
            availableEntities.append(entity)
        }
    }

    func releaseAll() {
        for entity in inUseEntities {
            release(entity)
        }
    }
}
```

### 7.2 Texture Compression

```swift
class TextureManager {
    func loadCompressedTexture(named name: String) -> TextureResource? {
        // Load compressed texture (ASTC, BC7, etc.)
        // Reduces memory usage by 4-8x

        guard let url = Bundle.main.url(forResource: name, withExtension: "ktx") else {
            return nil
        }

        return try? TextureResource.load(contentsOf: url)
    }
}
```

### 7.3 LOD (Level of Detail)

```swift
class LODManager {
    enum DetailLevel {
        case high
        case medium
        case low
    }

    func detailLevel(for distance: Float) -> DetailLevel {
        switch distance {
        case 0..<2.0:
            return .high
        case 2.0..<5.0:
            return .medium
        default:
            return .low
        }
    }

    func applyLOD(to entity: Entity, distance: Float) {
        let level = detailLevel(for: distance)

        switch level {
        case .high:
            // Full detail
            if var particleComponent = entity.components[ParticleEmitterComponent.self] {
                particleComponent.birthRate = 100
                entity.components.set(particleComponent)
            }

        case .medium:
            // Reduced detail
            if var particleComponent = entity.components[ParticleEmitterComponent.self] {
                particleComponent.birthRate = 50
                entity.components.set(particleComponent)
            }

        case .low:
            // Minimal detail
            if var particleComponent = entity.components[ParticleEmitterComponent.self] {
                particleComponent.birthRate = 10
                entity.components.set(particleComponent)
            }
        }
    }
}
```

### 7.4 Occlusion Culling

```swift
class OcclusionCuller {
    func cullInvisibleEntities(
        _ entities: [Entity],
        cameraPosition: SIMD3<Float>,
        cameraForward: SIMD3<Float>
    ) -> [Entity] {
        entities.filter { entity in
            let toEntity = entity.position - cameraPosition
            let distance = simd_length(toEntity)

            // Cull distant entities
            guard distance < 10.0 else { return false }

            // Cull entities behind camera
            let dot = simd_dot(simd_normalize(toEntity), cameraForward)
            return dot > -0.5
        }
    }
}
```

## 8. Battery Optimization

### 8.1 Background Task Management

```swift
class BackgroundTaskManager {
    func scheduleLowPriorityTask(_ task: @escaping () async -> Void) {
        Task(priority: .background) {
            await task()
        }
    }

    func schedulePeriodicTask(
        interval: TimeInterval,
        task: @escaping () async -> Void
    ) {
        Task {
            while !Task.isCancelled {
                await task()
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }
}
```

### 8.2 Adaptive Update Rates

```swift
class AdaptiveUpdateManager {
    private var updateInterval: TimeInterval = 1.0 // Start at 1 Hz

    func adjustUpdateRate(batteryLevel: Float) {
        switch batteryLevel {
        case 0..<0.2:
            // Low battery: reduce updates
            updateInterval = 10.0 // 0.1 Hz

        case 0.2..<0.5:
            // Medium battery
            updateInterval = 5.0 // 0.2 Hz

        default:
            // Normal operation
            updateInterval = 1.0 // 1 Hz
        }
    }

    func shouldUpdate(lastUpdate: Date) -> Bool {
        Date().timeIntervalSince(lastUpdate) >= updateInterval
    }
}
```

## 9. Network Optimization

### 9.1 Request Batching

```swift
class RequestBatcher {
    private var pendingRequests: [(UUID, (Result<Data, Error>) -> Void)] = []
    private let batchInterval: TimeInterval = 0.5

    func addRequest(id: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
        pendingRequests.append((id, completion))

        if pendingRequests.count == 1 {
            scheduleBatch()
        }
    }

    private func scheduleBatch() {
        Task {
            try? await Task.sleep(for: .seconds(batchInterval))
            await executeBatch()
        }
    }

    private func executeBatch() async {
        let batch = pendingRequests
        pendingRequests.removeAll()

        // Execute all requests in single API call
        let ids = batch.map { $0.0 }
        do {
            let results = try await fetchBatch(ids: ids)

            for (index, (_, completion)) in batch.enumerated() {
                completion(.success(results[index]))
            }
        } catch {
            for (_, completion) in batch {
                completion(.failure(error))
            }
        }
    }

    private func fetchBatch(ids: [UUID]) async throws -> [Data] {
        // Batch API request
        []
    }
}
```

### 9.2 Response Caching

```swift
class ResponseCache {
    private let cache = URLCache(
        memoryCapacity: 50 * 1024 * 1024, // 50 MB
        diskCapacity: 100 * 1024 * 1024 // 100 MB
    )

    func configureSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: config)
    }
}
```

## 10. Performance Testing Checklist

- [ ] Frame rate maintains 60 FPS during energy visualization
- [ ] Device toggle responds within 200ms
- [ ] App launches in under 2 seconds
- [ ] Memory usage stays under 500 MB
- [ ] Battery drain under 10% per hour during normal use
- [ ] Network requests complete within timeout
- [ ] UI remains responsive during background data sync
- [ ] Spatial tracking maintains lock in various lighting
- [ ] Particle systems scale down on distant views
- [ ] No memory leaks after 1 hour of continuous use

---

**Document Owner**: Performance Team
**Review Cycle**: Before each release
**Next Review**: As needed
