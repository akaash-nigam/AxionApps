# Performance & Optimization Plan
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Performance Targets](#performance-targets)
2. [Rendering Optimization](#rendering-optimization)
3. [Memory Management](#memory-management)
4. [Database Optimization](#database-optimization)
5. [Network Optimization](#network-optimization)
6. [Battery Optimization](#battery-optimization)
7. [Profiling Strategy](#profiling-strategy)

## Performance Targets

### Key Metrics

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| App Launch Time | < 2s | < 3s |
| Transaction Sync | < 10s | < 15s |
| View Render Time | < 100ms | < 200ms |
| Frame Rate (3D) | 60 fps | 45 fps |
| Memory Usage (Idle) | < 150MB | < 250MB |
| Memory Usage (Active) | < 300MB | < 500MB |
| Network Request Time | < 3s | < 5s |
| Database Query Time | < 50ms | < 100ms |
| Battery Drain (1hr use) | < 15% | < 25% |

### Performance Budget

```swift
// PerformanceBudget.swift
enum PerformanceBudget {
    // Rendering
    static let maxDrawCallsPerFrame = 1000
    static let maxTrianglesPerFrame = 500_000
    static let maxParticlesActive = 10_000

    // Memory
    static let maxMemoryUsage: UInt64 = 500 * 1024 * 1024 // 500MB
    static let maxTextureMemory: UInt64 = 100 * 1024 * 1024 // 100MB

    // Database
    static let maxFetchBatchSize = 100
    static let maxConcurrentQueries = 5

    // Network
    static let maxConcurrentRequests = 3
    static let requestTimeout: TimeInterval = 30
}
```

## Rendering Optimization

### Frame Rate Management

```swift
// FrameRateManager.swift
@MainActor
class FrameRateManager {
    private var lastFrameTime: TimeInterval = 0
    private var frameCount = 0
    private var fps: Double = 0

    func update(currentTime: TimeInterval) {
        frameCount += 1

        let elapsed = currentTime - lastFrameTime

        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastFrameTime = currentTime

            // Log FPS drops
            if fps < 55 {
                Logger.performance.warning("FPS dropped to \(fps)")
            }
        }
    }

    func shouldSkipFrame(complexity: RenderComplexity) -> Bool {
        // Skip frame rendering if FPS is too low
        fps < 50 && complexity == .high
    }
}

enum RenderComplexity {
    case low, medium, high
}
```

### Particle System Optimization

```swift
// Optimized particle pooling
actor ParticlePool {
    private var pool: [ParticleEntity]
    private var inUse: Set<ObjectIdentifier>

    init(capacity: Int) {
        self.pool = []
        self.inUse = []

        // Pre-allocate particles
        for _ in 0..<capacity {
            pool.append(ParticleEntity())
        }
    }

    func acquire() -> ParticleEntity? {
        guard let particle = pool.popLast() else {
            Logger.performance.warning("Particle pool exhausted")
            return nil
        }

        inUse.insert(ObjectIdentifier(particle))
        return particle
    }

    func release(_ particle: ParticleEntity) {
        particle.reset()
        inUse.remove(ObjectIdentifier(particle))
        pool.append(particle)
    }

    var utilizationPercentage: Float {
        Float(inUse.count) / Float(inUse.count + pool.count) * 100
    }
}
```

### Level of Detail (LOD)

```swift
// LODSystem.swift
class LODSystem {
    func update(entities: [Entity], cameraPosition: SIMD3<Float>) {
        for entity in entities {
            let distance = simd_distance(entity.position, cameraPosition)
            let lodLevel = calculateLOD(distance: distance)

            applyLOD(lodLevel, to: entity)
        }
    }

    private func calculateLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<3: return .high
        case 3..<6: return .medium
        case 6..<10: return .low
        default: return .culled
        }
    }

    private func applyLOD(_ level: LODLevel, to entity: Entity) {
        switch level {
        case .high:
            entity.isEnabled = true
            // Full detail rendering

        case .medium:
            entity.isEnabled = true
            // Reduce particle count, simplify shaders
            reduceComplexity(entity, factor: 0.5)

        case .low:
            entity.isEnabled = true
            // Minimal rendering
            reduceComplexity(entity, factor: 0.25)

        case .culled:
            entity.isEnabled = false
        }
    }

    private func reduceComplexity(_ entity: Entity, factor: Float) {
        if let particleEmitter = entity.components[ParticleEmitterComponent.self] {
            var modified = particleEmitter
            modified.birthRate *= factor
            entity.components[ParticleEmitterComponent.self] = modified
        }
    }
}

enum LODLevel {
    case high, medium, low, culled
}
```

### Culling Strategy

```swift
// FrustumCulling.swift
class FrustumCulling {
    func cull(entities: [Entity], camera: PerspectiveCamera) -> [Entity] {
        entities.filter { entity in
            isVisible(entity, from: camera)
        }
    }

    private func isVisible(_ entity: Entity, from camera: PerspectiveCamera) -> Bool {
        // Check if entity is within camera frustum
        let screenPosition = camera.project(entity.position)

        // Check if behind camera
        guard screenPosition.z > 0 else { return false }

        // Check if within screen bounds
        let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        return bounds.contains(CGPoint(x: screenPosition.x, y: screenPosition.y))
    }
}
```

## Memory Management

### Memory Monitoring

```swift
// MemoryMonitor.swift
actor MemoryMonitor {
    private var currentUsage: UInt64 = 0
    private let warningThreshold: UInt64 = 400 * 1024 * 1024 // 400MB
    private let criticalThreshold: UInt64 = 500 * 1024 * 1024 // 500MB

    func update() {
        currentUsage = getCurrentMemoryUsage()

        if currentUsage >= criticalThreshold {
            handleCriticalMemory()
        } else if currentUsage >= warningThreshold {
            handleWarningMemory()
        }
    }

    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }

    private func handleWarningMemory() {
        Logger.performance.warning("Memory usage high: \(currentUsage / 1024 / 1024)MB")

        // Clear caches
        NotificationCenter.default.post(name: .memoryWarning, object: nil)
    }

    private func handleCriticalMemory() {
        Logger.performance.error("Critical memory usage: \(currentUsage / 1024 / 1024)MB")

        // Aggressive cleanup
        NotificationCenter.default.post(name: .memoryCritical, object: nil)

        // Reduce quality
        reduceRenderingQuality()

        // Force clear caches
        clearAllCaches()
    }

    private func reduceRenderingQuality() {
        // Reduce particle counts
        // Simplify geometries
        // Disable effects
    }

    private func clearAllCaches() {
        ImageCache.shared.clear()
        URLCache.shared.removeAllCachedResponses()
    }
}

extension Notification.Name {
    static let memoryWarning = Notification.Name("memoryWarning")
    static let memoryCritical = Notification.Name("memoryCritical")
}
```

### Cache Management

```swift
// CacheManager.swift
actor CacheManager<Key: Hashable, Value> {
    private var cache: [Key: CacheEntry] = [:]
    private let maxSize: Int
    private let expirationTime: TimeInterval

    struct CacheEntry {
        let value: Value
        let timestamp: Date
        let size: Int
    }

    init(maxSize: Int = 100, expirationTime: TimeInterval = 3600) {
        self.maxSize = maxSize
        self.expirationTime = expirationTime
    }

    func get(_ key: Key) -> Value? {
        guard let entry = cache[key] else { return nil }

        // Check expiration
        if Date().timeIntervalSince(entry.timestamp) > expirationTime {
            cache.removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    func set(_ value: Value, forKey key: Key, size: Int = 1) {
        // Evict if needed
        if cache.count >= maxSize {
            evictLRU()
        }

        cache[key] = CacheEntry(
            value: value,
            timestamp: Date(),
            size: size
        )
    }

    func clear() {
        cache.removeAll()
        Logger.performance.info("Cache cleared")
    }

    private func evictLRU() {
        // Find oldest entry
        guard let oldestKey = cache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key else {
            return
        }

        cache.removeValue(forKey: oldestKey)
    }
}
```

## Database Optimization

### Query Optimization

```swift
// Optimized Core Data fetching
extension NSManagedObjectContext {
    func optimizedFetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        prefetch: [String] = []
    ) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        // Batch fetching
        request.fetchBatchSize = 50

        // Limit results
        if let limit = limit {
            request.fetchLimit = limit
        }

        // Prefetch relationships to avoid faulting
        request.relationshipKeyPathsForPrefetching = prefetch

        // Only fetch needed properties
        // request.propertiesToFetch = ["id", "amount", "date"]

        return try fetch(request)
    }
}

// Usage
let transactions = try context.optimizedFetch(
    TransactionEntity.self,
    predicate: NSPredicate(format: "date >= %@", startDate as NSDate),
    sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)],
    limit: 100,
    prefetch: ["account", "category"]
)
```

### Background Processing

```swift
// Background Core Data operations
actor BackgroundDataProcessor {
    private let persistenceController: PersistenceController

    func processBulkTransactions(_ transactions: [Transaction]) async throws {
        let context = persistenceController.container.newBackgroundContext()

        try await context.perform {
            for transaction in transactions {
                let entity = TransactionEntity(context: context)
                // Map transaction to entity
            }

            // Batch save
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
```

### Database Indexing

```swift
// Core Data model configuration
// In .xcdatamodel file, add indexes:
// - TransactionEntity: date, accountId, categoryId
// - AccountEntity: plaidAccountId
// - BudgetEntity: startDate, endDate, isActive

// Compound indexes for common queries:
// - (accountId, date) for transaction history
// - (categoryId, date) for category spending
```

## Network Optimization

### Request Batching

```swift
// NetworkBatcher.swift
actor NetworkBatcher {
    private var pendingRequests: [Request] = []
    private let batchSize = 10
    private let batchDelay: TimeInterval = 1.0
    private var batchTimer: Task<Void, Never>?

    func addRequest(_ request: Request) async throws -> Response {
        pendingRequests.append(request)

        if pendingRequests.count >= batchSize {
            return try await executeBatch()
        } else {
            scheduleBatch()
            return try await request.response
        }
    }

    private func scheduleBatch() {
        batchTimer?.cancel()

        batchTimer = Task {
            try? await Task.sleep(nanoseconds: UInt64(batchDelay * 1_000_000_000))
            _ = try? await executeBatch()
        }
    }

    private func executeBatch() async throws -> Response {
        let batch = pendingRequests
        pendingRequests.removeAll()

        // Execute batched requests
        let responses = try await withThrowingTaskGroup(of: Response.self) { group in
            for request in batch {
                group.addTask {
                    try await self.execute(request)
                }
            }

            var results: [Response] = []
            for try await response in group {
                results.append(response)
            }
            return results
        }

        return responses.first! // Simplified
    }

    private func execute(_ request: Request) async throws -> Response {
        // Execute single request
        fatalError("Not implemented")
    }
}
```

### Caching Strategy

```swift
// HTTP caching
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .returnCacheDataElseLoad
configuration.urlCache = URLCache(
    memoryCapacity: 50 * 1024 * 1024, // 50MB
    diskCapacity: 200 * 1024 * 1024  // 200MB
)
```

### Compression

```swift
// Enable response compression
var request = URLRequest(url: url)
request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
```

## Battery Optimization

### Background Task Optimization

```swift
// Efficient background sync
class BackgroundSyncManager {
    func scheduleSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.pfn.sync")

        // Schedule during optimal times
        request.earliestBeginDate = Date().addingTimeInterval(4 * 3600) // 4 hours

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Logger.performance.error("Background sync scheduling failed: \(error)")
        }
    }

    func handleBackgroundSync(task: BGAppRefreshTask) {
        let syncOperation = TransactionSyncOperation()

        task.expirationHandler = {
            syncOperation.cancel()
        }

        syncOperation.completionBlock = {
            task.setTaskCompleted(success: !syncOperation.isCancelled)
            self.scheduleSync() // Schedule next sync
        }

        // Execute sync
        OperationQueue().addOperation(syncOperation)
    }
}
```

### Power-Aware Rendering

```swift
// Reduce rendering when on battery
@Observable
class PowerManager {
    var isOnBattery: Bool = false
    var batteryLevel: Float = 1.0

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updatePowerState()

        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePowerState()
        }
    }

    private func updatePowerState() {
        isOnBattery = UIDevice.current.batteryState == .unplugged
        batteryLevel = UIDevice.current.batteryLevel

        // Adjust performance based on power state
        if isOnBattery && batteryLevel < 0.2 {
            enablePowerSavingMode()
        }
    }

    private func enablePowerSavingMode() {
        // Reduce particle counts
        // Lower frame rate target
        // Disable animations
        // Reduce sync frequency

        Logger.performance.info("Power saving mode enabled")
    }
}
```

## Profiling Strategy

### Instruments Profiling

```swift
// Profile-specific logging
#if DEBUG
import os.signpost

extension OSLog {
    static let performance = OSLog(subsystem: "com.pfn", category: "performance")
}

func profileBlock<T>(_ name: StaticString, block: () throws -> T) rethrows -> T {
    let signpostID = OSSignpostID(log: .performance)
    os_signpost(.begin, log: .performance, name: name, signpostID: signpostID)

    let result = try block()

    os_signpost(.end, log: .performance, name: name, signpostID: signpostID)
    return result
}

// Usage
let result = profileBlock("LoadTransactions") {
    try await repository.fetchAll()
}
#endif
```

### Performance Monitoring

```swift
// PerformanceMonitor.swift
@MainActor
class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private var metrics: [String: PerformanceMetric] = [:]

    struct PerformanceMetric {
        var count: Int = 0
        var totalDuration: TimeInterval = 0
        var minDuration: TimeInterval = .infinity
        var maxDuration: TimeInterval = 0

        var averageDuration: TimeInterval {
            count > 0 ? totalDuration / TimeInterval(count) : 0
        }
    }

    func measure<T>(_ operation: String, block: () async throws -> T) async rethrows -> T {
        let start = Date()

        let result = try await block()

        let duration = Date().timeIntervalSince(start)
        recordMetric(operation, duration: duration)

        return result
    }

    private func recordMetric(_ operation: String, duration: TimeInterval) {
        var metric = metrics[operation, default: PerformanceMetric()]

        metric.count += 1
        metric.totalDuration += duration
        metric.minDuration = min(metric.minDuration, duration)
        metric.maxDuration = max(metric.maxDuration, duration)

        metrics[operation] = metric

        // Log slow operations
        if duration > 1.0 {
            Logger.performance.warning("\(operation) took \(duration)s")
        }
    }

    func printReport() {
        for (operation, metric) in metrics.sorted(by: { $0.key < $1.key }) {
            print("""
            \(operation):
              Count: \(metric.count)
              Average: \(String(format: "%.3f", metric.averageDuration))s
              Min: \(String(format: "%.3f", metric.minDuration))s
              Max: \(String(format: "%.3f", metric.maxDuration))s
            """)
        }
    }
}

// Usage
let transactions = await PerformanceMonitor.shared.measure("SyncTransactions") {
    try await syncService.syncTransactions()
}
```

### Continuous Monitoring

```swift
// Use MetricKit for production monitoring
import MetricKit

class MetricsSubscriber: NSObject, MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Analyze metrics
            if let cpuMetrics = payload.cpuMetrics {
                Logger.performance.info("CPU time: \(cpuMetrics.cumulativeCPUTime)")
            }

            if let memoryMetrics = payload.memoryMetrics {
                Logger.performance.info("Peak memory: \(memoryMetrics.peakMemoryUsage)")
            }

            // Send to analytics
        }
    }
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: Analytics & Observability Design
