# ADR 0003: Entity Pooling for 3D Performance

## Status
Accepted

## Context
RealityKit applications in visionOS can create thousands of 3D entities for:
- Department visualizations (buildings, floors, indicators)
- KPI gauges with multiple segments
- Data flow paths with particles
- Performance rings and labels

Creating and destroying `ModelEntity` instances repeatedly causes:
- Garbage collection pressure
- Frame rate drops during entity creation
- Memory fragmentation

## Decision
We implemented an `EntityPool` system that:
1. Pre-allocates commonly used entity types
2. Provides `acquire()` / `release()` pattern for entity reuse
3. Tracks metrics for pool optimization
4. Integrates with a companion `MaterialPool` for material caching

### Core Design:
```swift
@MainActor
final class EntityPool {
    static let shared = EntityPool()

    enum EntityType: Hashable {
        case box(size: SIMD3<Float>, cornerRadius: Float)
        case sphere(radius: Float)
        // ...
    }

    func acquire(type: EntityType, material: Material?) -> ModelEntity
    func release(_ entity: ModelEntity, type: EntityType)
    func prewarmForBusinessVisualization() async
}
```

### Integration Pattern:
```swift
final class DepartmentEntityBuilder {
    private var pooledEntities: [(ModelEntity, EntityPool.EntityType)] = []

    func releasePooledEntities() {
        for (entity, type) in pooledEntities {
            entityPool.releaseAndRemove(entity, type: type)
        }
    }
}
```

## Consequences

### Positive
- Significantly reduced GC pressure during scene updates
- Smoother frame rates when rebuilding visualizations
- Metrics help identify optimization opportunities
- Material pooling reduces shader compilation hitches

### Negative
- Additional complexity in entity lifecycle management
- Must remember to release entities (mitigated by `SceneEntityManager`)
- Pool sizing requires tuning based on actual usage

### Performance Metrics
- Pool hit rate target: >90%
- Entity acquisition: <0.1ms (vs 2-5ms for fresh creation)
- Memory overhead: ~20% more baseline for pre-allocated entities

## Related Decisions
- ADR 0004: Barnes-Hut Layout Algorithm
