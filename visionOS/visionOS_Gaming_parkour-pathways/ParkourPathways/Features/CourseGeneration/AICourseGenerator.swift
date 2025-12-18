//
//  AICourseGenerator.swift
//  Parkour Pathways
//
//  AI-powered course generation system
//

import Foundation
import simd

class AICourseGenerator {
    private let difficultyEngine: DifficultyEngine
    private let spatialOptimizer: SpatialOptimizer
    private let safetyValidator: SafetyValidator

    init(
        difficultyEngine: DifficultyEngine,
        spatialOptimizer: SpatialOptimizer,
        safetyValidator: SafetyValidator
    ) {
        self.difficultyEngine = difficultyEngine
        self.spatialOptimizer = spatialOptimizer
        self.safetyValidator = safetyValidator
    }

    // MARK: - Course Generation

    func generateCourse(
        for space: RoomModel,
        player: PlayerData,
        difficulty: DifficultyLevel
    ) async throws -> CourseData {
        // Phase 1: Analyze space capabilities
        let spaceAnalysis = analyzeSpace(space)

        // Phase 2: Calculate obstacle budget
        let obstacleCount = calculateObstacleCount(
            space: spaceAnalysis,
            difficulty: difficulty
        )

        // Phase 3: Generate obstacle graph
        var obstacleGraph = generateObstacleGraph(
            space: spaceAnalysis,
            skillLevel: player.skillLevel,
            difficulty: difficulty,
            count: obstacleCount
        )

        // Phase 4: Optimize for flow
        obstacleGraph = spatialOptimizer.optimize(
            graph: obstacleGraph,
            playerProfile: player.physicalProfile
        )

        // Phase 5: Validate safety
        try safetyValidator.validate(
            course: obstacleGraph,
            space: space
        )

        // Phase 6: Add checkpoints
        let checkpoints = generateCheckpoints(obstacleGraph)

        // Phase 7: Calculate requirements and metadata
        let spaceRequirements = calculateSpaceRequirements(obstacleGraph)
        let estimatedDuration = calculateEstimatedDuration(obstacleGraph, player: player)

        return CourseData(
            name: generateCourseName(difficulty),
            difficulty: difficulty,
            obstacles: obstacleGraph.obstacles,
            checkpoints: checkpoints,
            spaceRequirements: spaceRequirements,
            estimatedDuration: estimatedDuration,
            tags: generateTags(obstacleGraph, difficulty: difficulty)
        )
    }

    // MARK: - Space Analysis

    private func analyzeSpace(_ roomModel: RoomModel) -> SpaceAnalysis {
        let floorArea = roomModel.width * roomModel.length
        let volume = floorArea * roomModel.height

        // Find usable floor space
        let floorSurfaces = roomModel.surfaces.filter { $0.type == .floor }
        let usableFloorArea = floorSurfaces.reduce(0) { $0 + estimateArea($1.vertices) }

        // Identify walls
        let walls = roomModel.surfaces.filter { $0.type == .wall }

        // Calculate furniture obstacles
        let furnitureObstacles = roomModel.furniture.map { item in
            FurnitureObstacle(
                position: item.position,
                boundingBox: item.boundingBox,
                type: item.type
            )
        }

        return SpaceAnalysis(
            totalArea: floorArea,
            usableArea: usableFloorArea,
            volume: volume,
            height: roomModel.height,
            walls: walls,
            furnitureObstacles: furnitureObstacles,
            playableRegions: identifyPlayableRegions(roomModel)
        )
    }

    private func estimateArea(_ vertices: [SIMD3<Float>]) -> Float {
        guard vertices.count >= 3 else { return 0 }
        var area: Float = 0
        for i in stride(from: 0, to: vertices.count - 2, by: 3) {
            let v1 = vertices[i + 1] - vertices[i]
            let v2 = vertices[i + 2] - vertices[i]
            area += simd_length(simd_cross(v1, v2)) / 2.0
        }
        return area
    }

    private func identifyPlayableRegions(_ roomModel: RoomModel) -> [PlayableRegion] {
        var regions: [PlayableRegion] = []

        // Identify clear floor areas
        let clearFloorArea = roomModel.width * roomModel.length

        // Create primary playable region
        regions.append(PlayableRegion(
            center: SIMD3<Float>(0, 0, 0),
            radius: min(roomModel.width, roomModel.length) / 2,
            heightRange: 0...roomModel.height
        ))

        return regions
    }

    // MARK: - Obstacle Generation

    private func calculateObstacleCount(
        space: SpaceAnalysis,
        difficulty: DifficultyLevel
    ) -> Int {
        // Base count on usable area (1 obstacle per 2 square meters)
        let baseCount = Int(space.usableArea / 2.0)

        // Adjust for difficulty
        let difficultyMultiplier: Float = {
            switch difficulty {
            case .easy: return 0.6
            case .medium: return 1.0
            case .hard: return 1.4
            case .expert: return 1.8
            }
        }()

        return max(3, Int(Float(baseCount) * difficultyMultiplier))
    }

    private func generateObstacleGraph(
        space: SpaceAnalysis,
        skillLevel: SkillLevel,
        difficulty: DifficultyLevel,
        count: Int
    ) -> ObstacleGraph {
        var graph = ObstacleGraph()

        // Determine available obstacle types for skill level
        let availableTypes = getAvailableObstacleTypes(for: skillLevel)

        for _ in 0..<count {
            // Select obstacle type based on difficulty and variety
            let obstacleType = selectObstacleType(
                available: availableTypes,
                difficulty: difficulty,
                existing: graph.obstacles
            )

            // Find optimal placement
            if let placement = findOptimalPlacement(
                type: obstacleType,
                existing: graph.obstacles,
                space: space
            ) {
                let obstacle = createObstacle(
                    type: obstacleType,
                    placement: placement,
                    difficulty: difficulty
                )

                graph.add(obstacle)
            }
        }

        return graph
    }

    private func getAvailableObstacleTypes(for skillLevel: SkillLevel) -> [ObstacleType] {
        switch skillLevel {
        case .novice, .beginner:
            return [.precisionTarget, .stepVault, .balanceBeam]

        case .intermediate:
            return [.precisionTarget, .stepVault, .speedVault, .balanceBeam, .wallRun, .vaultBox]

        case .advanced, .expert, .master:
            return [.precisionTarget, .stepVault, .speedVault, .kongVault, .balanceBeam, .wallRun, .vaultBox, .climbingSurface]
        }
    }

    private func selectObstacleType(
        available: [ObstacleType],
        difficulty: DifficultyLevel,
        existing: [Obstacle]
    ) -> ObstacleType {
        // Prefer variety - avoid too many of the same type
        let existingCounts = Dictionary(grouping: existing, by: { $0.type })
            .mapValues { $0.count }

        // Select type with lowest count
        let sorted = available.sorted { type1, type2 in
            let count1 = existingCounts[type1] ?? 0
            let count2 = existingCounts[type2] ?? 0
            return count1 < count2
        }

        return sorted.randomElement() ?? .precisionTarget
    }

    private func findOptimalPlacement(
        type: ObstacleType,
        existing: [Obstacle],
        space: SpaceAnalysis
    ) -> ObstaclePlacement? {
        var candidates: [ObstaclePlacement] = []

        // Grid-based sampling of space
        let gridSize: Float = 0.5
        let bounds = space.playableRegions.first

        guard let region = bounds else { return nil }

        for x in stride(from: -region.radius, to: region.radius, by: gridSize) {
            for z in stride(from: -region.radius, to: region.radius, by: gridSize) {
                let position = region.center + SIMD3<Float>(x, 0, z)

                if isValidPosition(position, type: type, existing: existing, space: space) {
                    let score = scorePlacement(
                        position: position,
                        type: type,
                        existing: existing
                    )

                    candidates.append(ObstaclePlacement(
                        position: position,
                        rotation: simd_quatf(),
                        score: score
                    ))
                }
            }
        }

        // Select best placement
        return candidates.max(by: { $0.score < $1.score })
    }

    private func isValidPosition(
        _ position: SIMD3<Float>,
        type: ObstacleType,
        existing: [Obstacle],
        space: SpaceAnalysis
    ) -> Bool {
        // Check minimum spacing from existing obstacles
        let minSpacing: Float = 1.0
        for obstacle in existing {
            if simd_distance(position, obstacle.position) < minSpacing {
                return false
            }
        }

        // Check within playable region
        guard let region = space.playableRegions.first else { return false }
        let distance = simd_distance(position, region.center)
        if distance > region.radius - 0.5 {
            return false
        }

        // Check furniture clearance
        for furniture in space.furnitureObstacles {
            if simd_distance(position, furniture.position) < 0.8 {
                return false
            }
        }

        return true
    }

    private func scorePlacement(
        position: SIMD3<Float>,
        type: ObstacleType,
        existing: [Obstacle]
    ) -> Float {
        var score: Float = 1.0

        // Prefer positions that create good flow
        if let lastObstacle = existing.last {
            let distance = simd_distance(position, lastObstacle.position)

            // Ideal distance is 1.5-2.5 meters
            if distance >= 1.5 && distance <= 2.5 {
                score += 0.5
            }
        }

        // Prefer varied positioning (not all in a line)
        if existing.count >= 2 {
            let variety = calculatePositionVariety(position, existing: existing)
            score += variety * 0.3
        }

        return score
    }

    private func calculatePositionVariety(_ position: SIMD3<Float>, existing: [Obstacle]) -> Float {
        // Calculate how different this position is from existing pattern
        // Higher score for more variety
        return 0.5
    }

    private func createObstacle(
        type: ObstacleType,
        placement: ObstaclePlacement,
        difficulty: DifficultyLevel
    ) -> Obstacle {
        let scale = getDefaultScale(for: type)
        let difficultyValue = getDifficultyValue(for: difficulty)

        return Obstacle(
            type: type,
            position: placement.position,
            rotation: placement.rotation,
            scale: scale,
            difficulty: difficultyValue
        )
    }

    private func getDefaultScale(for type: ObstacleType) -> SIMD3<Float> {
        switch type {
        case .precisionTarget:
            return SIMD3<Float>(0.3, 0.05, 0.3)
        case .vaultBox, .stepVault, .speedVault, .kongVault:
            return SIMD3<Float>(1.0, 0.6, 0.6)
        case .balanceBeam:
            return SIMD3<Float>(0.2, 3.0, 0.2)
        case .virtualWall, .wallRun:
            return SIMD3<Float>(3.0, 2.5, 0.1)
        case .climbingSurface:
            return SIMD3<Float>(2.0, 3.0, 0.2)
        case .gap:
            return SIMD3<Float>(1.5, 0.1, 1.5)
        }
    }

    private func getDifficultyValue(for difficulty: DifficultyLevel) -> Float {
        switch difficulty {
        case .easy: return 0.25
        case .medium: return 0.5
        case .hard: return 0.75
        case .expert: return 1.0
        }
    }

    // MARK: - Checkpoint Generation

    private func generateCheckpoints(_ graph: ObstacleGraph) -> [Checkpoint] {
        var checkpoints: [Checkpoint] = []
        let obstacles = graph.obstacles

        // Create checkpoint every 3-5 obstacles
        let checkpointInterval = 4

        for i in stride(from: checkpointInterval, to: obstacles.count, by: checkpointInterval) {
            let obstacleSubset = Array(obstacles[max(0, i - checkpointInterval)..<i])
            let position = calculateCheckpointPosition(obstacleSubset)

            checkpoints.append(Checkpoint(
                position: position,
                order: checkpoints.count + 1,
                requiredObstacles: obstacleSubset.map { $0.id }
            ))
        }

        return checkpoints
    }

    private func calculateCheckpointPosition(_ obstacles: [Obstacle]) -> SIMD3<Float> {
        guard !obstacles.isEmpty else { return .zero }
        let sum = obstacles.reduce(SIMD3<Float>.zero) { $0 + $1.position }
        return sum / Float(obstacles.count)
    }

    // MARK: - Helper Methods

    private func calculateSpaceRequirements(_ graph: ObstacleGraph) -> SpaceRequirements {
        guard !graph.obstacles.isEmpty else {
            return SpaceRequirements()
        }

        var minBounds = SIMD3<Float>(.infinity, .infinity, .infinity)
        var maxBounds = SIMD3<Float>(-.infinity, -.infinity, -.infinity)

        for obstacle in graph.obstacles {
            minBounds = simd_min(minBounds, obstacle.position - obstacle.scale)
            maxBounds = simd_max(maxBounds, obstacle.position + obstacle.scale)
        }

        let dimensions = maxBounds - minBounds

        return SpaceRequirements(
            minWidth: dimensions.x + 1.0, // Add margin
            minLength: dimensions.z + 1.0,
            minHeight: dimensions.y + 0.5
        )
    }

    private func calculateEstimatedDuration(_ graph: ObstacleGraph, player: PlayerData) -> TimeInterval {
        let baseTimePerObstacle: TimeInterval = 10.0 // seconds
        let skillMultiplier: Double = {
            switch player.skillLevel {
            case .novice: return 1.5
            case .beginner: return 1.2
            case .intermediate: return 1.0
            case .advanced: return 0.8
            case .expert: return 0.6
            case .master: return 0.5
            }
        }()

        return Double(graph.obstacles.count) * baseTimePerObstacle * skillMultiplier
    }

    private func generateCourseName(_ difficulty: DifficultyLevel) -> String {
        let prefixes = ["Dynamic", "Swift", "Agile", "Flow", "Momentum"]
        let suffixes = ["Circuit", "Path", "Course", "Challenge", "Run"]

        let prefix = prefixes.randomElement() ?? "Dynamic"
        let suffix = suffixes.randomElement() ?? "Course"

        return "\(prefix) \(suffix)"
    }

    private func generateTags(_ graph: ObstacleGraph, difficulty: DifficultyLevel) -> [String] {
        var tags: [String] = [difficulty.rawValue]

        // Add tags based on obstacle types
        let obstacleTypes = Set(graph.obstacles.map { $0.type })

        if obstacleTypes.contains(.vaultBox) || obstacleTypes.contains(.speedVault) {
            tags.append("vaulting")
        }

        if obstacleTypes.contains(.balanceBeam) {
            tags.append("balance")
        }

        if obstacleTypes.contains(.wallRun) {
            tags.append("wall-running")
        }

        return tags
    }
}

// MARK: - Supporting Types

struct SpaceAnalysis {
    let totalArea: Float
    let usableArea: Float
    let volume: Float
    let height: Float
    let walls: [RoomModel.Surface]
    let furnitureObstacles: [FurnitureObstacle]
    let playableRegions: [PlayableRegion]
}

struct FurnitureObstacle {
    let position: SIMD3<Float>
    let boundingBox: SIMD3<Float>
    let type: RoomModel.FurnitureType
}

struct PlayableRegion {
    let center: SIMD3<Float>
    let radius: Float
    let heightRange: ClosedRange<Float>
}

struct ObstaclePlacement {
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let score: Float
}

class ObstacleGraph {
    var obstacles: [Obstacle] = []

    func add(_ obstacle: Obstacle) {
        obstacles.append(obstacle)
    }
}

// MARK: - Supporting Classes

class DifficultyEngine {
    func calculateDifficulty(_ factors: DifficultyFactors) -> Float {
        // Calculate overall difficulty from multiple factors
        return factors.obstacleComplexity * 0.25 +
               factors.spacing * 0.15 +
               factors.precisionRequired * 0.20 +
               factors.speedRequirement * 0.15 +
               factors.endurance * 0.15 +
               factors.technicalVariety * 0.10
    }
}

struct DifficultyFactors {
    var obstacleComplexity: Float = 0.5
    var spacing: Float = 0.5
    var precisionRequired: Float = 0.5
    var speedRequirement: Float = 0.5
    var endurance: Float = 0.5
    var technicalVariety: Float = 0.5
}

class SpatialOptimizer {
    func optimize(
        graph: ObstacleGraph,
        playerProfile: PhysicalProfile
    ) -> ObstacleGraph {
        // Optimize obstacle placement for flow
        // This would rearrange obstacles for better gameplay
        return graph
    }
}

class SafetyValidator {
    func validate(
        course: ObstacleGraph,
        space: RoomModel
    ) throws {
        // Validate that course is safe
        // Check spacing, boundaries, difficulty progression
        for obstacle in course.obstacles {
            // Check if obstacle is within room bounds
            guard obstacle.position.x > -space.width / 2 &&
                  obstacle.position.x < space.width / 2 &&
                  obstacle.position.z > -space.length / 2 &&
                  obstacle.position.z < space.length / 2 else {
                throw CourseGenerationError.obstacleOutOfBounds
            }
        }
    }
}

enum CourseGenerationError: Error {
    case obstacleOutOfBounds
    case insufficientSpace
    case unsafeConfiguration
}
