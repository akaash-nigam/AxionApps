import Foundation
import RealityKit

actor OcclusionDetector {
    private var visibilityCache: [CacheKey: VisibilityData] = [:]

    struct CacheKey: Hashable {
        let seekerId: UUID
        let hiderId: UUID
    }

    struct VisibilityData {
        var isVisible: Bool
        var visibilityPercentage: Float
        var lastUpdate: Date
        var cacheLifetime: TimeInterval = 0.1 // 100ms
    }

    // MARK: - Visibility Checking

    func checkVisibility(
        from seeker: Player,
        to hider: Player,
        in roomLayout: RoomLayout
    ) async -> Bool {
        let cacheKey = CacheKey(seekerId: seeker.id, hiderId: hider.id)

        // Check cache first
        if let cached = visibilityCache[cacheKey],
           Date().timeIntervalSince(cached.lastUpdate) < cached.cacheLifetime {
            return cached.isVisible
        }

        // Calculate visibility
        let percentage = await calculateVisibilityPercentage(
            from: seeker.position,
            to: hider.position,
            in: roomLayout
        )

        let isVisible = percentage >= 0.3  // 30% threshold

        // Update cache
        visibilityCache[cacheKey] = VisibilityData(
            isVisible: isVisible,
            visibilityPercentage: percentage,
            lastUpdate: Date()
        )

        return isVisible
    }

    func calculateVisibilityPercentage(
        from viewerPos: SIMD3<Float>,
        to targetPos: SIMD3<Float>,
        in roomLayout: RoomLayout
    ) async -> Float {
        // Generate 9 sample points (3x3 grid) around target
        let samplePoints = generateSampleGrid(around: targetPos, gridSize: 3)

        var visibleCount = 0

        for point in samplePoints {
            let isVisible = await isPointVisible(
                from: viewerPos,
                to: point,
                in: roomLayout
            )

            if isVisible {
                visibleCount += 1
            }
        }

        return Float(visibleCount) / Float(samplePoints.count)
    }

    private func isPointVisible(
        from origin: SIMD3<Float>,
        to target: SIMD3<Float>,
        in roomLayout: RoomLayout
    ) async -> Bool {
        let direction = normalize(target - origin)
        let distance = length(target - origin)

        // Check if any furniture blocks the line of sight
        for furniture in roomLayout.furniture {
            if rayIntersectsFurniture(
                origin: origin,
                direction: direction,
                distance: distance,
                furniture: furniture
            ) {
                return false  // Blocked
            }
        }

        return true  // Clear line of sight
    }

    private func rayIntersectsFurniture(
        origin: SIMD3<Float>,
        direction: SIMD3<Float>,
        distance: Float,
        furniture: FurnitureItem
    ) -> Bool {
        // Simple AABB (Axis-Aligned Bounding Box) intersection test
        let furnitureMin = furniture.position - furniture.size / 2
        let furnitureMax = furniture.position + furniture.size / 2

        // Ray-box intersection
        let tMin = (furnitureMin - origin) / direction
        let tMax = (furnitureMax - origin) / direction

        let t1 = min(tMin, tMax)
        let t2 = max(tMin, tMax)

        let tNear = max(max(t1.x, t1.y), t1.z)
        let tFar = min(min(t2.x, t2.y), t2.z)

        // Check if intersection occurs within ray distance
        return tNear <= tFar && tFar > 0 && tNear < distance - 0.05
    }

    private func generateSampleGrid(around position: SIMD3<Float>, gridSize: Int) -> [SIMD3<Float>] {
        var points: [SIMD3<Float>] = []
        let offset: Float = 0.3  // 30cm spread

        for x in 0..<gridSize {
            for y in 0..<gridSize {
                for z in 0..<gridSize {
                    let t = SIMD3<Float>(
                        Float(x) / Float(gridSize - 1) - 0.5,
                        Float(y) / Float(gridSize - 1) - 0.5,
                        Float(z) / Float(gridSize - 1) - 0.5
                    )
                    let point = position + t * offset
                    points.append(point)
                }
            }
        }

        return points
    }

    // MARK: - Cache Management

    func clearCache() {
        visibilityCache.removeAll()
    }

    func clearCache(for playerId: UUID) {
        visibilityCache = visibilityCache.filter { key, _ in
            key.seekerId != playerId && key.hiderId != playerId
        }
    }

    func getCacheSize() -> Int {
        return visibilityCache.count
    }
}
