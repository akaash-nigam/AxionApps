# Performance Optimization Guide - AI Agent Coordinator

## Document Information
- **Version**: 1.0.0
- **Last Updated**: 2025-01-20
- **Platform**: Apple Vision Pro (visionOS 2.0+)

---

## Table of Contents

1. [Performance Overview](#performance-overview)
2. [Benchmarking](#benchmarking)
3. [Rendering Optimization](#rendering-optimization)
4. [Memory Management](#memory-management)
5. [Network Optimization](#network-optimization)
6. [Data Processing](#data-processing)
7. [3D Visualization Optimization](#3d-visualization-optimization)
8. [SwiftData Performance](#swiftdata-performance)
9. [Concurrency Best Practices](#concurrency-best-practices)
10. [Profiling Tools](#profiling-tools)

---

## Performance Overview

### Target Performance Metrics

| Metric | Target | Acceptable | Poor |
|--------|--------|------------|------|
| Frame Rate | 90 FPS | 60 FPS | < 60 FPS |
| App Launch Time | < 2s | < 5s | > 5s |
| Agent Load Time (1000) | < 1s | < 3s | > 3s |
| Memory Usage | < 500 MB | < 1 GB | > 1 GB |
| Network Latency | < 100ms | < 500ms | > 500ms |
| UI Response Time | < 16ms | < 100ms | > 100ms |

### Performance Categories

1. **Critical Path**: App launch, agent loading, UI responsiveness
2. **User Experience**: Smooth animations, gesture response, transitions
3. **Background**: Metrics collection, sync, caching
4. **Optional**: Advanced visualizations, analytics

---

## Benchmarking

### Built-in Performance Monitor

Enable performance overlay:

```swift
// Settings > Advanced > Performance Monitor
// Shows:
// - FPS (frames per second)
// - Memory usage
// - Network activity
// - CPU/GPU usage
```

### Manual Benchmarking

```swift
import Foundation

class PerformanceTimer {
    private var startTime: CFAbsoluteTime = 0

    func start(_ label: String = "") {
        startTime = CFAbsoluteTimeGetCurrent()
        print("⏱️ Starting: \(label)")
    }

    func stop(_ label: String = "") {
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("⏱️ \(label): \(String(format: "%.3f", elapsed))s")
    }
}

// Usage
let timer = PerformanceTimer()
timer.start("Load Agents")
let agents = try await coordinator.loadAgents()
timer.stop("Load Agents")
```

### Key Operations to Benchmark

1. **Agent Loading**
   ```swift
   // Benchmark agent loading for different counts
   let counts = [100, 500, 1000, 5000, 10000]
   for count in counts {
       timer.start("Load \(count) agents")
       let agents = try await loadAgents(count: count)
       timer.stop("Load \(count) agents")
   }
   ```

2. **Visualization Generation**
   ```swift
   timer.start("Generate Galaxy Layout")
   let layout = visualizationEngine.generateGalaxyLayout(
       agents: agents,
       connections: connections
   )
   timer.stop("Generate Galaxy Layout")
   ```

3. **Metrics Collection**
   ```swift
   timer.start("Collect Metrics")
   let metrics = try await metricsCollector.getLatestMetrics(agentId: id)
   timer.stop("Collect Metrics")
   ```

---

## Rendering Optimization

### Level of Detail (LOD)

Implement distance-based LOD to reduce geometry complexity:

```swift
class LODManager {
    enum LODLevel {
        case high      // 0-2 meters
        case medium    // 2-10 meters
        case low       // 10-50 meters
        case minimal   // > 50 meters
    }

    func updateAgentLOD(agent: AgentEntity, cameraDistance: Float) {
        let lod = determineLOD(distance: cameraDistance)

        switch lod {
        case .high:
            agent.model?.mesh = highDetailMesh
            agent.particleSystem?.isEnabled = true
            agent.showLabels = true
            agent.shadowQuality = .high

        case .medium:
            agent.model?.mesh = mediumDetailMesh
            agent.particleSystem?.isEnabled = true
            agent.showLabels = true
            agent.shadowQuality = .medium

        case .low:
            agent.model?.mesh = lowDetailMesh
            agent.particleSystem?.isEnabled = false
            agent.showLabels = false
            agent.shadowQuality = .low

        case .minimal:
            agent.model?.mesh = simpleSphere
            agent.removeAllComponents(except: [ModelComponent.self])
        }
    }

    private func determineLOD(distance: Float) -> LODLevel {
        switch distance {
        case 0..<2: return .high
        case 2..<10: return .medium
        case 10..<50: return .low
        default: return .minimal
        }
    }
}
```

### Frustum Culling

Don't render objects outside the view frustum:

```swift
class FrustumCuller {
    func cullEntities(
        entities: [AgentEntity],
        camera: PerspectiveCamera
    ) -> [AgentEntity] {
        return entities.filter { entity in
            isInFrustum(
                position: entity.position,
                camera: camera
            )
        }
    }

    private func isInFrustum(
        position: SIMD3<Float>,
        camera: PerspectiveCamera
    ) -> Bool {
        // Transform position to camera space
        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        var clipPosition = projectionMatrix * viewMatrix * SIMD4<Float>(
            position.x, position.y, position.z, 1.0
        )

        // Perspective divide
        clipPosition /= clipPosition.w

        // Check if within [-1, 1] range
        return abs(clipPosition.x) <= 1.0 &&
               abs(clipPosition.y) <= 1.0 &&
               abs(clipPosition.z) <= 1.0
    }
}
```

### Occlusion Culling

Don't render objects blocked by other objects:

```swift
class OcclusionCuller {
    private var occlusionQuery: MTLBuffer?

    func performOcclusionTest(
        entity: AgentEntity,
        renderEncoder: MTLRenderCommandEncoder
    ) -> Bool {
        // Render bounding box to occlusion buffer
        // Check if any pixels passed depth test
        // Return true if visible

        return true // Simplified
    }

    func cullOccludedEntities(
        entities: [AgentEntity]
    ) -> [AgentEntity] {
        // Sort by distance (front to back)
        let sorted = entities.sorted {
            $0.distanceFromCamera < $1.distanceFromCamera
        }

        var visible: [AgentEntity] = []

        for entity in sorted {
            if !isOccluded(entity, by: visible) {
                visible.append(entity)
            }
        }

        return visible
    }
}
```

### Instanced Rendering

Use GPU instancing for identical objects:

```swift
class InstancedRenderer {
    func renderAgents(
        _ agents: [AgentEntity],
        encoder: MTLRenderCommandEncoder
    ) {
        // Group by visual style
        let grouped = Dictionary(grouping: agents) { $0.visualStyle }

        for (style, styleAgents) in grouped {
            if styleAgents.count > 10 {
                // Use instanced rendering
                renderInstanced(styleAgents, encoder: encoder)
            } else {
                // Individual rendering for small groups
                for agent in styleAgents {
                    renderIndividual(agent, encoder: encoder)
                }
            }
        }
    }

    private func renderInstanced(
        _ agents: [AgentEntity],
        encoder: MTLRenderCommandEncoder
    ) {
        let transforms = agents.map { $0.transform.matrix }
        let instanceBuffer = createBuffer(from: transforms)

        encoder.setVertexBuffer(instanceBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: meshVertexCount,
            instanceCount: agents.count
        )
    }
}
```

---

## Memory Management

### Object Pooling

Reuse objects instead of allocating new ones:

```swift
class EntityPool {
    private var availableEntities: [AgentType: [AgentEntity]] = [:]
    private let maxPoolSize = 1000

    func acquire(type: AgentType) -> AgentEntity {
        if let entity = availableEntities[type]?.popLast() {
            return entity
        }
        return createNewEntity(type: type)
    }

    func release(_ entity: AgentEntity) {
        entity.reset()

        let poolSize = availableEntities[entity.type, default: []].count
        if poolSize < maxPoolSize {
            availableEntities[entity.type, default: []].append(entity)
        }
        // else: let it be deallocated
    }

    func prewarm(type: AgentType, count: Int) {
        for _ in 0..<count {
            let entity = createNewEntity(type: type)
            release(entity)
        }
    }
}

// Usage
// Prewarm pool at app launch
entityPool.prewarm(type: .llm, count: 100)

// Acquire when needed
let entity = entityPool.acquire(type: .llm)
// Use entity
entityPool.release(entity)
```

### Lazy Loading

Load data only when needed:

```swift
class LazyDataLoader {
    private var loadedRanges: Set<DateInterval> = []

    func loadMetricsIfNeeded(for range: DateInterval) async throws {
        // Check if already loaded
        if loadedRanges.contains(where: { $0.contains(range) }) {
            return
        }

        // Load only missing data
        let missing = range.subtract(loadedRanges)
        for missingRange in missing {
            let metrics = try await fetchMetrics(for: missingRange)
            await cache.store(metrics, for: missingRange)
            loadedRanges.insert(missingRange)
        }
    }
}
```

### Memory Warnings

Handle low memory conditions:

```swift
class MemoryManager {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        // Clear caches
        imageCache.removeAllObjects()
        layoutCache.removeAllObjects()

        // Release pooled objects
        entityPool.releaseAll()

        // Reduce quality
        lodManager.setGlobalLOD(.low)

        // Force garbage collection (Swift doesn't have explicit GC,
        // but we can nil out references)
        temporaryData = nil

        Logger.warning("Memory warning - caches cleared")
    }
}
```

### Texture Atlasing

Combine small textures into larger atlas:

```swift
class TextureAtlasManager {
    private var atlas: MTLTexture?
    private var uvMapping: [String: CGRect] = [:]

    func createAtlas(from textures: [String: UIImage]) {
        // Arrange textures in grid
        let gridSize = Int(ceil(sqrt(Double(textures.count))))
        let textureSize = 2048 / gridSize

        let atlasSize = CGSize(
            width: gridSize * textureSize,
            height: gridSize * textureSize
        )

        UIGraphicsBeginImageContext(atlasSize)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return }

        var x = 0, y = 0
        for (name, image) in textures {
            let rect = CGRect(
                x: x * textureSize,
                y: y * textureSize,
                width: textureSize,
                height: textureSize
            )

            image.draw(in: rect)

            // Store UV coordinates (normalized 0-1)
            uvMapping[name] = CGRect(
                x: Double(x) / Double(gridSize),
                y: Double(y) / Double(gridSize),
                width: 1.0 / Double(gridSize),
                height: 1.0 / Double(gridSize)
            )

            x += 1
            if x >= gridSize {
                x = 0
                y += 1
            }
        }

        if let atlasImage = UIGraphicsGetImageFromCurrentImageContext() {
            atlas = createTexture(from: atlasImage)
        }
    }

    func uvCoordinates(for textureName: String) -> CGRect {
        return uvMapping[textureName] ?? .zero
    }
}
```

---

## Network Optimization

### Request Batching

Combine multiple requests into one:

```swift
actor RequestBatcher {
    private var pendingRequests: [MetricsRequest] = []
    private var batchTimer: Task<Void, Never>?
    private let batchDelay: Duration = .milliseconds(100)
    private let maxBatchSize = 50

    func enqueue(_ request: MetricsRequest) async -> MetricsResponse {
        return await withCheckedContinuation { continuation in
            pendingRequests.append((request, continuation))

            if pendingRequests.count >= maxBatchSize {
                scheduleBatchImmediately()
            } else if batchTimer == nil {
                scheduleBatchTimer()
            }
        }
    }

    private func scheduleBatchTimer() {
        batchTimer = Task {
            try? await Task.sleep(for: batchDelay)
            await processBatch()
        }
    }

    private func scheduleBatchImmediately() {
        batchTimer?.cancel()
        batchTimer = nil
        Task {
            await processBatch()
        }
    }

    private func processBatch() async {
        guard !pendingRequests.isEmpty else { return }

        let batch = pendingRequests
        pendingRequests = []
        batchTimer = nil

        do {
            // Single network request for all
            let responses = try await networkClient.batchFetch(
                batch.map { $0.request }
            )

            // Distribute responses
            for (index, (_, continuation)) in batch.enumerated() {
                continuation.resume(returning: responses[index])
            }
        } catch {
            // Handle errors
            for (_, continuation) in batch {
                continuation.resume(throwing: error)
            }
        }
    }
}
```

### Response Caching

Cache network responses:

```swift
class NetworkCache {
    private let cache = NSCache<NSString, CachedResponse>()
    private let maxAge: TimeInterval = 60 // 60 seconds

    struct CachedResponse {
        let data: Data
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > 60
        }
    }

    func get(for url: URL) -> Data? {
        guard let cached = cache.object(forKey: url.absoluteString as NSString) else {
            return nil
        }

        if cached.isExpired {
            cache.removeObject(forKey: url.absoluteString as NSString)
            return nil
        }

        return cached.data
    }

    func set(_ data: Data, for url: URL) {
        let response = CachedResponse(data: data, timestamp: Date())
        cache.setObject(response, forKey: url.absoluteString as NSString)
    }
}

// Usage in NetworkClient
func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
    // Check cache first
    if let cachedData = networkCache.get(for: endpoint.url) {
        return try JSONDecoder().decode(T.self, from: cachedData)
    }

    // Fetch from network
    let data = try await URLSession.shared.data(from: endpoint.url).0

    // Cache response
    networkCache.set(data, for: endpoint.url)

    return try JSONDecoder().decode(T.self, from: data)
}
```

### Compression

Enable request/response compression:

```swift
class CompressedNetworkClient {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept-Encoding": "gzip, deflate, br"
        ]
        session = URLSession(configuration: config)
    }

    func post<T: Encodable, R: Decodable>(
        _ endpoint: Endpoint,
        body: T
    ) async throws -> R {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")

        // Encode and compress body
        let jsonData = try JSONEncoder().encode(body)
        let compressedData = try compress(jsonData)
        request.httpBody = compressedData

        // Response is automatically decompressed by URLSession
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(R.self, from: data)
    }

    private func compress(_ data: Data) throws -> Data {
        return try (data as NSData).compressed(using: .lzfse) as Data
    }
}
```

### Connection Pooling

Reuse network connections:

```swift
// URLSession automatically pools connections
// Configure for optimal performance:

let config = URLSessionConfiguration.default
config.httpMaximumConnectionsPerHost = 6
config.timeoutIntervalForRequest = 30
config.timeoutIntervalForResource = 60
config.requestCachePolicy = .returnCacheDataElseLoad
config.urlCache = URLCache(
    memoryCapacity: 50_000_000,   // 50 MB
    diskCapacity: 100_000_000,    // 100 MB
    diskPath: "network_cache"
)

let session = URLSession(configuration: config)
```

---

## Data Processing

### Pagination

Load data in chunks:

```swift
class PaginatedAgentLoader {
    private let pageSize = 100
    private var currentPage = 0
    private var hasMorePages = true

    func loadNextPage() async throws -> [AIAgent] {
        guard hasMorePages else { return [] }

        let agents = try await repository.fetchAgents(
            offset: currentPage * pageSize,
            limit: pageSize
        )

        hasMorePages = agents.count == pageSize
        currentPage += 1

        return agents
    }

    func reset() {
        currentPage = 0
        hasMorePages = true
    }
}
```

### Background Processing

Process data on background threads:

```swift
actor DataProcessor {
    func processMetrics(_ rawMetrics: [RawMetric]) async -> [ProcessedMetric] {
        // Heavy processing on background thread
        return await Task.detached(priority: .userInitiated) {
            rawMetrics.map { raw in
                ProcessedMetric(
                    agentId: raw.agentId,
                    averageLatency: calculateAverage(raw.latencies),
                    p95Latency: calculatePercentile(raw.latencies, 0.95),
                    p99Latency: calculatePercentile(raw.latencies, 0.99),
                    throughput: calculateThroughput(raw.requestCount, raw.duration)
                )
            }
        }.value
    }

    private func calculatePercentile(
        _ values: [Double],
        _ percentile: Double
    ) -> Double {
        let sorted = values.sorted()
        let index = Int(Double(sorted.count) * percentile)
        return sorted[min(index, sorted.count - 1)]
    }
}
```

### Debouncing

Delay processing until user stops input:

```swift
class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: Duration

    init(delay: Duration = .milliseconds(500)) {
        self.delay = delay
    }

    func debounce(_ action: @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            if !Task.isCancelled {
                await action()
            }
        }
    }
}

// Usage in search
class SearchViewModel {
    private let debouncer = Debouncer()

    var searchQuery: String = "" {
        didSet {
            debouncer.debounce {
                await self.performSearch()
            }
        }
    }

    private func performSearch() async {
        // Search only after user stops typing for 500ms
        let results = try? await searchService.search(query: searchQuery)
        // Update UI
    }
}
```

---

## 3D Visualization Optimization

### Spatial Indexing

Use octree for efficient spatial queries:

```swift
class Octree {
    private var root: OctreeNode?
    private let maxDepth = 6
    private let maxEntitiesPerNode = 8

    class OctreeNode {
        var bounds: BoundingBox
        var entities: [AgentEntity] = []
        var children: [OctreeNode?] = Array(repeating: nil, count: 8)
        var isLeaf: Bool { children.allSatisfy { $0 == nil } }
    }

    func insert(_ entity: AgentEntity) {
        if root == nil {
            root = OctreeNode(bounds: calculateBounds(for: [entity]))
        }
        insert(entity, into: root!, depth: 0)
    }

    func query(frustum: Frustum) -> [AgentEntity] {
        guard let root = root else { return [] }
        var results: [AgentEntity] = []
        query(frustum, node: root, results: &results)
        return results
    }

    private func query(
        _ frustum: Frustum,
        node: OctreeNode,
        results: inout [AgentEntity]
    ) {
        // Check if node intersects frustum
        guard frustum.intersects(node.bounds) else { return }

        // Add entities from this node
        results.append(contentsOf: node.entities)

        // Recursively check children
        for child in node.children.compactMap({ $0 }) {
            query(frustum, node: child, results: &results)
        }
    }
}
```

### View Frustum Optimization

Only process visible entities:

```swift
class VisibilityManager {
    private var visibleEntities: Set<UUID> = []

    func updateVisibility(
        entities: [AgentEntity],
        camera: Camera
    ) {
        let frustum = calculateFrustum(from: camera)

        visibleEntities = Set(
            entities
                .filter { frustum.contains($0.position) }
                .map { $0.id }
        )
    }

    func isVisible(_ entity: AgentEntity) -> Bool {
        visibleEntities.contains(entity.id)
    }

    func visibleCount() -> Int {
        visibleEntities.count
    }
}

// In rendering loop
visibilityManager.updateVisibility(entities: allAgents, camera: camera)

for agent in allAgents where visibilityManager.isVisible(agent) {
    render(agent)
}
```

### Progressive Loading

Load visualization in stages:

```swift
class ProgressiveVisualizationLoader {
    func load(agents: [AIAgent]) async {
        // Stage 1: Load core agents (highest priority)
        let core = agents.filter { $0.tags.contains("critical") }
        await renderAgents(core, quality: .high)

        // Stage 2: Load active agents
        let active = agents.filter { $0.status == .active && !core.contains($0) }
        await renderAgents(active, quality: .medium)

        // Stage 3: Load remaining agents
        let remaining = agents.filter { !core.contains($0) && !active.contains($0) }
        await renderAgents(remaining, quality: .low)

        // Stage 4: Upgrade quality over time
        await upgradeQuality()
    }

    private func renderAgents(_ agents: [AIAgent], quality: QualityLevel) async {
        for agent in agents {
            await renderAgent(agent, quality: quality)

            // Yield every 10 agents to avoid blocking
            if agents.firstIndex(of: agent)! % 10 == 0 {
                await Task.yield()
            }
        }
    }
}
```

---

## SwiftData Performance

### Batch Operations

Use batch inserts/updates:

```swift
@MainActor
class OptimizedRepository {
    private let modelContext: ModelContext

    func batchInsert(_ agents: [AIAgent]) async throws {
        // Insert in batches of 100
        for batch in agents.chunked(into: 100) {
            for agent in batch {
                modelContext.insert(agent)
            }

            // Save batch
            try modelContext.save()
        }
    }

    func batchUpdate(_ updates: [(UUID, AgentStatus)]) async throws {
        let descriptor = FetchDescriptor<AIAgent>(
            predicate: #Predicate { agent in
                updates.map { $0.0 }.contains(agent.id)
            }
        )

        let agents = try modelContext.fetch(descriptor)

        for agent in agents {
            if let update = updates.first(where: { $0.0 == agent.id }) {
                agent.status = update.1
            }
        }

        try modelContext.save()
    }
}
```

### Fetch Optimization

Use predicates and limits:

```swift
// Good: Fetch only what you need
let descriptor = FetchDescriptor<AIAgent>(
    predicate: #Predicate { agent in
        agent.status == .active &&
        agent.type == .llm
    },
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
descriptor.fetchLimit = 100

let agents = try modelContext.fetch(descriptor)

// Bad: Fetch everything then filter
let allAgents = try modelContext.fetch(FetchDescriptor<AIAgent>())
let filtered = allAgents.filter { $0.status == .active && $0.type == .llm }
```

### Relationships

Optimize relationship loading:

```swift
// Lazy loading (default - good for large datasets)
@Model
class AIAgent {
    var connections: [AgentConnection] = []  // Loaded on access
}

// Eager loading (use sparingly)
let descriptor = FetchDescriptor<AIAgent>()
descriptor.relationshipKeyPathsForPrefetching = [\.connections]
let agents = try modelContext.fetch(descriptor)
// connections already loaded
```

---

## Concurrency Best Practices

### Async/Await Patterns

```swift
// Good: Concurrent loading
async let agents = loadAgents()
async let metrics = loadMetrics()
async let connections = loadConnections()

let (loadedAgents, loadedMetrics, loadedConnections) =
    await (agents, metrics, connections)

// Bad: Sequential loading
let agents = await loadAgents()       // Wait
let metrics = await loadMetrics()     // Wait
let connections = await loadConnections()  // Wait
```

### Actor Usage

```swift
// Use actors for shared mutable state
actor MetricsCache {
    private var cache: [UUID: AgentMetrics] = [:]

    func get(_ id: UUID) -> AgentMetrics? {
        cache[id]
    }

    func set(_ id: UUID, metrics: AgentMetrics) {
        cache[id] = metrics
    }

    func clear() {
        cache.removeAll()
    }
}

// Not thread-safe without actor
class UnsafeMetricsCache {
    private var cache: [UUID: AgentMetrics] = [:]  // ⚠️ Race conditions!

    func get(_ id: UUID) -> AgentMetrics? {
        cache[id]  // Unsafe concurrent access
    }
}
```

### Task Groups

```swift
func loadAllMetrics(for agents: [AIAgent]) async throws -> [AgentMetrics] {
    try await withThrowingTaskGroup(of: AgentMetrics.self) { group in
        for agent in agents {
            group.addTask {
                try await self.loadMetrics(for: agent.id)
            }
        }

        var allMetrics: [AgentMetrics] = []
        for try await metrics in group {
            allMetrics.append(metrics)
        }

        return allMetrics
    }
}
```

---

## Profiling Tools

### Xcode Instruments

1. **Time Profiler**:
   ```
   Product > Profile (Cmd + I)
   Select "Time Profiler"
   Record while using app
   Identify CPU hotspots
   ```

2. **Allocations**:
   ```
   Track memory allocations
   Find memory leaks
   Identify retain cycles
   ```

3. **Network**:
   ```
   Monitor network requests
   Measure bandwidth usage
   Identify slow requests
   ```

4. **GPU**:
   ```
   Track GPU utilization
   Find rendering bottlenecks
   Optimize draw calls
   ```

### MetricKit

```swift
import MetricKit

class PerformanceMonitor: NSObject, MXMetricManagerSubscriber {
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // CPU metrics
            if let cpuMetrics = payload.cpuMetrics {
                print("CPU Time: \(cpuMetrics.cumulativeCPUTime)")
            }

            // Memory metrics
            if let memoryMetrics = payload.memoryMetrics {
                print("Peak Memory: \(memoryMetrics.peakMemoryUsage)")
            }

            // Display metrics
            if let displayMetrics = payload.displayMetrics {
                print("Average FPS: \(60.0 / displayMetrics.averagePixelLuminance)")
            }
        }
    }
}
```

---

## Performance Checklist

Before releasing:

- [ ] Profile with Instruments (Time Profiler, Allocations)
- [ ] Test with large datasets (10,000+ agents)
- [ ] Verify memory stays under 1 GB
- [ ] Check frame rate stays above 60 FPS
- [ ] Test on actual Vision Pro device (not just simulator)
- [ ] Monitor network usage
- [ ] Verify battery life impact is acceptable
- [ ] Test with poor network conditions
- [ ] Profile cold and warm launches
- [ ] Check for memory leaks
- [ ] Verify proper multithreading
- [ ] Test edge cases (0 agents, 100,000 agents)

---

**Need help optimizing?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or contact performance@aiagentcoordinator.dev
