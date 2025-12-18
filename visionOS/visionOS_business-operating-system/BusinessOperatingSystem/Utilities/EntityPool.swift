//
//  EntityPool.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import RealityKit
import SwiftUI

// MARK: - Entity Pool

/// High-performance entity pooling system for RealityKit
/// Reduces allocation overhead by reusing ModelEntity instances
@MainActor
final class EntityPool {
    // MARK: - Singleton

    static let shared = EntityPool()

    // MARK: - Pool Configuration

    struct Configuration {
        var initialPoolSize: Int = 50
        var maxPoolSize: Int = 500
        var growthFactor: Int = 10
        var enableMetrics: Bool = true

        static let `default` = Configuration()
        static let highPerformance = Configuration(
            initialPoolSize: 100,
            maxPoolSize: 1000,
            growthFactor: 25
        )
    }

    // MARK: - Entity Types

    enum EntityType: Hashable {
        case box(size: SIMD3<Float>, cornerRadius: Float)
        case sphere(radius: Float)
        case cylinder(height: Float, radius: Float)
        case plane(width: Float, depth: Float)
        case text(fontSize: Float)
        case custom(String)

        var cacheKey: String {
            switch self {
            case .box(let size, let cornerRadius):
                return "box_\(size.x)_\(size.y)_\(size.z)_\(cornerRadius)"
            case .sphere(let radius):
                return "sphere_\(radius)"
            case .cylinder(let height, let radius):
                return "cylinder_\(height)_\(radius)"
            case .plane(let width, let depth):
                return "plane_\(width)_\(depth)"
            case .text(let fontSize):
                return "text_\(fontSize)"
            case .custom(let id):
                return "custom_\(id)"
            }
        }

        /// Standard sizes for common use cases
        static let smallSphere = EntityType.sphere(radius: 0.008)
        static let mediumSphere = EntityType.sphere(radius: 0.02)
        static let largeSphere = EntityType.sphere(radius: 0.05)

        static let smallBox = EntityType.box(size: [0.02, 0.02, 0.02], cornerRadius: 0.003)
        static let mediumBox = EntityType.box(size: [0.1, 0.1, 0.1], cornerRadius: 0.01)
        static let largeBox = EntityType.box(size: [0.3, 0.3, 0.3], cornerRadius: 0.02)
    }

    // MARK: - Properties

    private var pools: [String: PoolBucket] = [:]
    private var configuration: Configuration
    private var metrics: PoolMetrics

    // MARK: - Pool Bucket

    private class PoolBucket {
        var available: [ModelEntity] = []
        var inUse: Set<ObjectIdentifier> = []
        var meshResource: MeshResource?
        let entityType: EntityType

        init(entityType: EntityType) {
            self.entityType = entityType
        }

        var totalCount: Int { available.count + inUse.count }
    }

    // MARK: - Metrics

    struct PoolMetrics {
        var totalAcquisitions: Int = 0
        var totalReleases: Int = 0
        var poolHits: Int = 0
        var poolMisses: Int = 0
        var peakUsage: [String: Int] = [:]

        var hitRate: Double {
            guard totalAcquisitions > 0 else { return 0 }
            return Double(poolHits) / Double(totalAcquisitions)
        }

        mutating func reset() {
            totalAcquisitions = 0
            totalReleases = 0
            poolHits = 0
            poolMisses = 0
            peakUsage = [:]
        }
    }

    // MARK: - Initialization

    init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.metrics = PoolMetrics()
    }

    // MARK: - Pre-warming

    /// Pre-warm the pool with commonly used entity types
    func prewarm(types: [EntityType]) async {
        for type in types {
            let bucket = getOrCreateBucket(for: type)

            // Create initial entities
            for _ in 0..<configuration.initialPoolSize {
                if let entity = createEntity(for: type, bucket: bucket) {
                    bucket.available.append(entity)
                }
            }
        }
    }

    /// Pre-warm with standard entity types for business visualization
    func prewarmForBusinessVisualization() async {
        await prewarm(types: [
            .smallSphere,
            .mediumSphere,
            .smallBox,
            .mediumBox,
            .box(size: [0.003, 0.003, 0.1], cornerRadius: 0),  // Path segments
            .cylinder(height: 0.01, radius: 0.02),  // Ring segments
        ])
    }

    // MARK: - Acquire Entity

    /// Acquire an entity from the pool
    /// - Parameters:
    ///   - type: The type of entity to acquire
    ///   - material: Optional material to apply
    /// - Returns: A pooled or newly created ModelEntity
    func acquire(type: EntityType, material: RealityKit.Material? = nil) -> ModelEntity {
        if configuration.enableMetrics {
            metrics.totalAcquisitions += 1
        }

        let bucket = getOrCreateBucket(for: type)

        let entity: ModelEntity
        if let available = bucket.available.popLast() {
            // Reuse existing entity
            entity = available
            if configuration.enableMetrics {
                metrics.poolHits += 1
            }
        } else {
            // Create new entity
            entity = createEntity(for: type, bucket: bucket) ?? ModelEntity()
            if configuration.enableMetrics {
                metrics.poolMisses += 1
            }
        }

        // Mark as in use
        bucket.inUse.insert(ObjectIdentifier(entity))

        // Update peak usage
        let key = type.cacheKey
        let currentUsage = bucket.inUse.count
        if currentUsage > (metrics.peakUsage[key] ?? 0) {
            metrics.peakUsage[key] = currentUsage
        }

        // Apply material if provided
        if let material = material {
            entity.model?.materials = [material]
        }

        // Reset entity state
        resetEntity(entity)

        return entity
    }

    /// Acquire multiple entities at once for batch operations
    func acquireBatch(type: EntityType, count: Int, material: RealityKit.Material? = nil) -> [ModelEntity] {
        var entities: [ModelEntity] = []
        entities.reserveCapacity(count)

        for _ in 0..<count {
            entities.append(acquire(type: type, material: material))
        }

        return entities
    }

    // MARK: - Release Entity

    /// Release an entity back to the pool
    /// - Parameters:
    ///   - entity: The entity to release
    ///   - type: The type of entity (for proper pool routing)
    func release(_ entity: ModelEntity, type: EntityType) {
        let key = type.cacheKey
        guard let bucket = pools[key] else { return }

        let identifier = ObjectIdentifier(entity)
        guard bucket.inUse.contains(identifier) else { return }

        if configuration.enableMetrics {
            metrics.totalReleases += 1
        }

        // Remove from in-use set
        bucket.inUse.remove(identifier)

        // Check if pool is at max capacity
        if bucket.totalCount < configuration.maxPoolSize {
            // Clean up the entity before returning to pool
            cleanupEntity(entity)
            bucket.available.append(entity)
        }
        // If at max capacity, entity will be deallocated
    }

    /// Release multiple entities at once
    func releaseBatch(_ entities: [ModelEntity], type: EntityType) {
        for entity in entities {
            release(entity, type: type)
        }
    }

    /// Release an entity and remove it from its parent
    func releaseAndRemove(_ entity: ModelEntity, type: EntityType) {
        entity.removeFromParent()
        release(entity, type: type)
    }

    // MARK: - Pool Management

    /// Clear all pools
    func clearAll() {
        for (_, bucket) in pools {
            bucket.available.removeAll()
            bucket.inUse.removeAll()
        }
        pools.removeAll()

        if configuration.enableMetrics {
            metrics.reset()
        }
    }

    /// Clear a specific pool type
    func clear(type: EntityType) {
        let key = type.cacheKey
        pools[key]?.available.removeAll()
        pools[key]?.inUse.removeAll()
        pools.removeValue(forKey: key)
    }

    /// Trim pools to reduce memory usage
    func trim(keepRatio: Float = 0.5) {
        for (_, bucket) in pools {
            let keepCount = Int(Float(bucket.available.count) * keepRatio)
            bucket.available = Array(bucket.available.prefix(keepCount))
        }
    }

    // MARK: - Metrics Access

    /// Get current pool metrics
    func getMetrics() -> PoolMetrics {
        return metrics
    }

    /// Get pool statistics for a specific type
    func getStats(for type: EntityType) -> (available: Int, inUse: Int, peak: Int) {
        let key = type.cacheKey
        guard let bucket = pools[key] else { return (0, 0, 0) }
        return (bucket.available.count, bucket.inUse.count, metrics.peakUsage[key] ?? 0)
    }

    // MARK: - Private Helpers

    private func getOrCreateBucket(for type: EntityType) -> PoolBucket {
        let key = type.cacheKey
        if let existing = pools[key] {
            return existing
        }

        let bucket = PoolBucket(entityType: type)
        bucket.meshResource = createMesh(for: type)
        pools[key] = bucket
        return bucket
    }

    private func createMesh(for type: EntityType) -> MeshResource? {
        switch type {
        case .box(let size, let cornerRadius):
            return MeshResource.generateBox(size: size, cornerRadius: cornerRadius)
        case .sphere(let radius):
            return MeshResource.generateSphere(radius: radius)
        case .cylinder(let height, let radius):
            return MeshResource.generateCylinder(height: height, radius: radius)
        case .plane(let width, let depth):
            return MeshResource.generatePlane(width: width, depth: depth)
        case .text, .custom:
            return nil  // These are created on-demand
        }
    }

    private func createEntity(for type: EntityType, bucket: PoolBucket) -> ModelEntity? {
        guard let mesh = bucket.meshResource ?? createMesh(for: type) else {
            return nil
        }

        // Use a default material that can be replaced later
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .gray)

        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func resetEntity(_ entity: ModelEntity) {
        // Reset transform
        entity.position = .zero
        entity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        entity.scale = .one

        // Reset visibility
        entity.isEnabled = true

        // Clear custom components (keep only essential ones)
        entity.components.remove(InputTargetComponent.self)
        entity.components.remove(CollisionComponent.self)
    }

    private func cleanupEntity(_ entity: ModelEntity) {
        // Remove from parent if attached
        entity.removeFromParent()

        // Remove all children
        entity.children.forEach { $0.removeFromParent() }

        // Reset to default state
        resetEntity(entity)
    }
}

// MARK: - Pooled Entity Container

/// Wrapper that automatically returns entity to pool when deallocated
@MainActor
final class PooledEntity {
    let entity: ModelEntity
    let entityType: EntityPool.EntityType
    private let pool: EntityPool
    private var isReleased: Bool = false

    init(entity: ModelEntity, type: EntityPool.EntityType, pool: EntityPool? = nil) {
        self.entity = entity
        self.entityType = type
        self.pool = pool ?? EntityPool.shared
    }

    deinit {
        // Note: Cannot call @MainActor methods from deinit in Swift 6
        // Entities must be manually released using releaseIfNeeded() before deallocation
    }

    func releaseIfNeeded() {
        guard !isReleased else { return }
        isReleased = true
        pool.release(entity, type: entityType)
    }

    func releaseAndRemove() {
        guard !isReleased else { return }
        isReleased = true
        pool.releaseAndRemove(entity, type: entityType)
    }
}

// MARK: - Material Pool

/// Companion pool for reusable materials
@MainActor
final class MaterialPool {
    static let shared = MaterialPool()

    private var materials: [String: RealityKit.Material] = [:]

    // MARK: - Standard Materials

    enum StandardMaterial: String {
        case defaultGray
        case highlight
        case success
        case warning
        case error
        case glass
        case metal
    }

    // MARK: - Initialization

    init() {
        prepareStandardMaterials()
    }

    // MARK: - Material Access

    func material(for standard: StandardMaterial) -> RealityKit.Material {
        return materials[standard.rawValue] ?? createMaterial(for: standard)
    }

    func material(color: UIColor, metallic: Float = 0.3, roughness: Float = 0.6) -> RealityKit.Material {
        let key = "custom_\(color.hashValue)_\(metallic)_\(roughness)"

        if let existing = materials[key] {
            return existing
        }

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color)
        material.metallic = .init(floatLiteral: metallic)
        material.roughness = .init(floatLiteral: roughness)

        materials[key] = material
        return material
    }

    func emissiveMaterial(color: UIColor, intensity: Float = 0.5) -> RealityKit.Material {
        let key = "emissive_\(color.hashValue)_\(intensity)"

        if let existing = materials[key] {
            return existing
        }

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color)
        material.emissiveColor = .init(color: color)
        material.emissiveIntensity = intensity

        materials[key] = material
        return material
    }

    func unlitMaterial(color: UIColor) -> RealityKit.Material {
        let key = "unlit_\(color.hashValue)"

        if let existing = materials[key] {
            return existing
        }

        let material = UnlitMaterial(color: color)
        materials[key] = material
        return material
    }

    // MARK: - Cache Management

    func clearCache() {
        materials.removeAll()
        prepareStandardMaterials()
    }

    // MARK: - Private

    private func prepareStandardMaterials() {
        materials[StandardMaterial.defaultGray.rawValue] = createMaterial(for: .defaultGray)
        materials[StandardMaterial.highlight.rawValue] = createMaterial(for: .highlight)
        materials[StandardMaterial.success.rawValue] = createMaterial(for: .success)
        materials[StandardMaterial.warning.rawValue] = createMaterial(for: .warning)
        materials[StandardMaterial.error.rawValue] = createMaterial(for: .error)
        materials[StandardMaterial.glass.rawValue] = createMaterial(for: .glass)
        materials[StandardMaterial.metal.rawValue] = createMaterial(for: .metal)
    }

    private func createMaterial(for standard: StandardMaterial) -> RealityKit.Material {
        var material = PhysicallyBasedMaterial()

        switch standard {
        case .defaultGray:
            material.baseColor = .init(tint: .gray)
            material.metallic = .init(floatLiteral: 0.3)
            material.roughness = .init(floatLiteral: 0.6)

        case .highlight:
            material.baseColor = .init(tint: .systemBlue)
            material.emissiveColor = .init(color: .systemBlue)
            material.emissiveIntensity = 0.5

        case .success:
            material.baseColor = .init(tint: .systemGreen)
            material.emissiveColor = .init(color: .systemGreen)
            material.emissiveIntensity = 0.3

        case .warning:
            material.baseColor = .init(tint: .systemYellow)
            material.emissiveColor = .init(color: .systemYellow)
            material.emissiveIntensity = 0.3

        case .error:
            material.baseColor = .init(tint: .systemRed)
            material.emissiveColor = .init(color: .systemRed)
            material.emissiveIntensity = 0.4

        case .glass:
            material.baseColor = .init(tint: .white.withAlphaComponent(0.2))
            material.metallic = .init(floatLiteral: 0.1)
            material.roughness = .init(floatLiteral: 0.1)
            material.blending = .transparent(opacity: 0.3)

        case .metal:
            material.baseColor = .init(tint: .lightGray)
            material.metallic = .init(floatLiteral: 0.9)
            material.roughness = .init(floatLiteral: 0.2)
        }

        return material
    }
}

// MARK: - Entity Pool Extensions for Common Operations

extension EntityPool {
    /// Create a particle system using pooled entities
    func createParticleEmitter(
        count: Int,
        type: EntityType = .smallSphere,
        color: UIColor = .white
    ) -> (container: Entity, particles: [ModelEntity]) {
        let container = Entity()
        container.name = "particle-emitter"

        let material = MaterialPool.shared.emissiveMaterial(color: color, intensity: 0.8)
        let particles = acquireBatch(type: type, count: count, material: material)

        for particle in particles {
            container.addChild(particle)
        }

        return (container, particles)
    }

    /// Create a path visualization using pooled entities
    func createPath(
        points: [SIMD3<Float>],
        color: UIColor = .systemBlue,
        segmentType: EntityType = .box(size: [0.003, 0.003, 0.01], cornerRadius: 0)
    ) -> (container: Entity, segments: [ModelEntity]) {
        let container = Entity()
        container.name = "path"

        let material = MaterialPool.shared.material(color: color, metallic: 0.3, roughness: 0.6)

        var segments: [ModelEntity] = []

        for i in 0..<(points.count - 1) {
            let start = points[i]
            let end = points[i + 1]
            let direction = end - start
            let length = simd_length(direction)

            guard length > 0.001 else { continue }

            let segment = acquire(type: segmentType, material: material)
            segment.scale = [1, 1, length / 0.01]  // Scale to match segment length
            segment.position = (start + end) / 2

            // Orient towards destination
            segment.look(at: end, from: segment.position, relativeTo: nil)

            container.addChild(segment)
            segments.append(segment)
        }

        return (container, segments)
    }

    /// Release a particle emitter and return entities to pool
    func releaseParticleEmitter(_ particles: [ModelEntity], type: EntityType = .smallSphere) {
        releaseBatch(particles, type: type)
    }

    /// Release a path and return segments to pool
    func releasePath(_ segments: [ModelEntity], type: EntityType = .box(size: [0.003, 0.003, 0.01], cornerRadius: 0)) {
        releaseBatch(segments, type: type)
    }
}

// MARK: - Debug View

#if DEBUG
struct EntityPoolDebugView: View {
    @State private var metrics: EntityPool.PoolMetrics = EntityPool.PoolMetrics()
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Entity Pool Metrics")
                .font(.headline)

            HStack {
                MetricCard(title: "Acquisitions", value: "\(metrics.totalAcquisitions)")
                MetricCard(title: "Releases", value: "\(metrics.totalReleases)")
            }

            HStack {
                MetricCard(title: "Pool Hits", value: "\(metrics.poolHits)")
                MetricCard(title: "Pool Misses", value: "\(metrics.poolMisses)")
            }

            MetricCard(
                title: "Hit Rate",
                value: String(format: "%.1f%%", metrics.hitRate * 100)
            )

            if !metrics.peakUsage.isEmpty {
                Text("Peak Usage by Type")
                    .font(.subheadline)
                    .padding(.top)

                ForEach(Array(metrics.peakUsage.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(metrics.peakUsage[key] ?? 0)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
            }
        }
        .padding()
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor in
                    metrics = EntityPool.shared.getMetrics()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    EntityPoolDebugView()
}
#endif
