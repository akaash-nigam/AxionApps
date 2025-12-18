# Performance Budget & Optimization Plan

## Overview

Performance targets and optimization strategies for Physical-Digital Twins to ensure smooth 90Hz experience on Vision Pro.

## Performance Targets

### Frame Rate
- **Mixed Immersion**: 90 Hz (11.1ms per frame)
- **Full Immersion**: 90 Hz (required)
- **Window Mode**: 60 Hz minimum

### Latency Targets
| Operation | Target | Acceptable | Notes |
|-----------|--------|-----------|-------|
| Barcode scan | <100ms | <200ms | Critical path |
| ML recognition | <200ms | <500ms | User waiting |
| API fetch | <1s | <3s | Can be async |
| Twin creation | <50ms | <100ms | Local operation |
| Database query | <50ms | <100ms | Indexed queries |
| Image load | <200ms | <500ms | With caching |
| AR anchor | <100ms | <200ms | Spatial experience |

### Memory Budget
| Component | Budget | Notes |
|-----------|--------|-------|
| App baseline | 200 MB | Minimum footprint |
| Image cache | 500 MB | LRU eviction |
| ML models | 50 MB | On-device models |
| RealityKit entities | 100 MB | Max 50 entities |
| **Total** | **850 MB** | Peak usage |

### Battery Impact
- **Target**: <10% battery per hour of active use
- **Background**: <2% per day

## Optimization Strategies

### 1. Image Optimization

```swift
class ImageOptimizer {
    func optimizeForCache(_ image: UIImage) -> Data? {
        // Resize to reasonable dimensions
        let maxDimension: CGFloat = 1024
        let resized = image.resized(maxDimension: maxDimension)

        // Compress to WebP format (better than JPEG)
        return resized.webPData(quality: 0.8)
    }

    func thumbnail(from image: UIImage) -> UIImage? {
        // Generate 200x200 thumbnail
        return image.resized(maxDimension: 200)
    }
}
```

### 2. Database Optimization

```swift
// Indices on frequently queried fields
// Core Data model:
// - objectType (Category filter)
// - createdAt (Sorting)
// - expirationDate (Expiring soon queries)

class DatabaseOptimizer {
    func configureFetchRequest<T>(_ request: NSFetchRequest<T>) -> NSFetchRequest<T> {
        // Batch fetching
        request.fetchBatchSize = 20

        // Fetch limit for lists
        request.fetchLimit = 100

        // Prefetch relationships
        request.relationshipKeyPathsForPrefetching = ["digitalTwin", "location"]

        return request
    }
}
```

### 3. Lazy Loading

```swift
@Observable
class InventoryViewModel {
    private(set) var items: [InventoryItem] = []
    private var allItemsLoaded = false

    func loadMoreIfNeeded(currentItem: InventoryItem?) async {
        guard let currentItem = currentItem else { return }

        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await loadNextPage()
        }
    }

    private func loadNextPage() async {
        guard !allItemsLoaded else { return }

        let nextBatch = try? await repository.fetchItems(
            offset: items.count,
            limit: 20
        )

        if let batch = nextBatch {
            items.append(contentsOf: batch)
            allItemsLoaded = batch.count < 20
        }
    }
}
```

### 4. AR Entity Pooling

```swift
class EntityPool {
    private var pool: [String: [Entity]] = [:]
    private let maxPoolSize = 20

    func acquire(type: String) -> Entity {
        if var entities = pool[type], !entities.isEmpty {
            return entities.removeLast()
        }
        return createNewEntity(type: type)
    }

    func release(_ entity: Entity, type: String) {
        entity.isEnabled = false
        entity.position = .zero

        if pool[type, default: []].count < maxPoolSize {
            pool[type, default: []].append(entity)
        }
    }
}
```

### 5. Core ML Optimization

```swift
let config = MLModelConfiguration()
config.computeUnits = .cpuAndNeuralEngine // Use Neural Engine
config.allowLowPrecisionAccumulationOnGPU = true

// Quantize model for smaller size and faster inference
// Use Float16 instead of Float32 where possible
```

### 6. Caching Strategy

```swift
actor CacheManager {
    private var memoryCache: NSCache<NSString, AnyObject>
    private let diskCache: DiskCache

    init() {
        memoryCache = NSCache()
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        memoryCache.countLimit = 100

        diskCache = DiskCache(maxSize: 500 * 1024 * 1024) // 500 MB
    }

    func get(key: String) async -> Data? {
        // Try memory first
        if let cached = memoryCache.object(forKey: key as NSString) as? Data {
            return cached
        }

        // Try disk
        if let data = await diskCache.get(key: key) {
            // Promote to memory
            memoryCache.setObject(data as AnyObject, forKey: key as NSString)
            return data
        }

        return nil
    }
}
```

## Monitoring

### Performance Metrics

```swift
import OSLog

class PerformanceMonitor {
    private let signposter = OSSignposter()

    func measure<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let signpostID = signposter.makeSignpostID()
        let state = signposter.beginInterval(operation, id: signpostID)

        defer {
            signposter.endInterval(operation, state)
        }

        return try block()
    }

    func measureAsync<T>(_ operation: String, block: () async throws -> T) async rethrows -> T {
        let start = Date()
        defer {
            let duration = Date().timeIntervalSince(start)
            logger.info("\(operation) took \(duration * 1000, privacy: .public)ms")
        }

        return try await block()
    }
}

// Usage
let result = try await performanceMonitor.measureAsync("Object Recognition") {
    try await visionService.recognizeObject(from: image)
}
```

### Instruments Integration

**Key metrics to track**:
- Time Profiler: CPU hotspots
- Allocations: Memory leaks
- Leaks: Retain cycles
- Energy Log: Battery impact
- Core Data: Query performance
- Network: API latency

## Optimization Checklist

### Pre-Launch
- [ ] Profile with Instruments (Time Profiler, Allocations)
- [ ] Test with 10,000+ inventory items
- [ ] Measure cold start time (<3s target)
- [ ] Test AR performance with 20+ entities
- [ ] Verify memory usage stays <850 MB
- [ ] Test on device (not simulator) for accurate metrics
- [ ] Profile battery drain (background and active)
- [ ] Optimize images (WebP, thumbnails)
- [ ] Add database indices
- [ ] Implement caching strategy

### Post-Launch
- [ ] Monitor crash-free rate (>99.5%)
- [ ] Track API latency metrics
- [ ] Monitor battery feedback
- [ ] Analyze slow operations via logging
- [ ] A/B test performance improvements

## Known Performance Bottlenecks

### Bottleneck 1: Large Image Files
**Problem**: High-resolution photos consume memory
**Solution**: Generate thumbnails, lazy load full images

### Bottleneck 2: Unindexed Queries
**Problem**: Slow searches on large datasets
**Solution**: Add Core Data indices on searchable fields

### Bottleneck 3: Too Many AR Entities
**Problem**: Frame rate drops with 50+ entities
**Solution**: LOD system, entity pooling, occlusion culling

### Bottleneck 4: Blocking API Calls
**Problem**: UI freezes during network requests
**Solution**: async/await, show loading states

## Performance Testing

```swift
class PerformanceTests: XCTestCase {
    func testRecognitionLatency() {
        measure(metrics: [XCTClockMetric()]) {
            _ = try? recognitionRouter.recognize(image: testImage)
        }

        // Assert < 500ms
    }

    func testInventoryScaling() {
        // Create 10k items
        for i in 0..<10000 {
            createTestItem(index: i)
        }

        measure {
            _ = repository.fetchAll()
        }

        // Assert < 200ms
    }
}
```

## Summary

Performance budget ensures:
- **Smooth Experience**: 90 Hz frame rate
- **Fast Response**: <500ms recognition
- **Efficient Memory**: <850 MB peak usage
- **Battery Friendly**: <10% per hour
- **Scalable**: Handles 10k+ items

Performance is a feature. Users notice when it's bad and take it for granted when it's good. Aim for the latter.
