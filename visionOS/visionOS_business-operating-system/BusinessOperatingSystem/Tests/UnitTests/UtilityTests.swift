//
//  UtilityTests.swift
//  BusinessOperatingSystemTests
//
//  Created by BOS Team on 2025-01-20.
//

import XCTest
@testable import BusinessOperatingSystem

// MARK: - SpatialLayoutEngine Tests

final class SpatialLayoutEngineTests: XCTestCase {

    var layoutEngine: SpatialLayoutEngine!

    override func setUp() {
        super.setUp()
        layoutEngine = SpatialLayoutEngine()
    }

    override func tearDown() {
        layoutEngine = nil
        super.tearDown()
    }

    // MARK: - Configuration Tests

    func testDefaultConfiguration() {
        let config = SpatialLayoutEngine.ForceDirectedConfig()

        XCTAssertEqual(config.repulsionStrength, 0.5)
        XCTAssertEqual(config.attractionStrength, 0.1)
        XCTAssertEqual(config.centeringStrength, 0.05)
        XCTAssertEqual(config.damping, 0.85)
        XCTAssertEqual(config.minDistance, 0.1)
        XCTAssertEqual(config.barnesHutThreshold, 100)
        XCTAssertEqual(config.theta, 0.5)
    }

    func testHighPerformanceConfiguration() {
        let config = SpatialLayoutEngine.ForceDirectedConfig.highPerformance

        XCTAssertEqual(config.barnesHutThreshold, 50)
        XCTAssertEqual(config.theta, 0.7)
    }

    // MARK: - Path Generation Tests

    func testGeneratePathBasic() {
        let start = SIMD3<Float>(0, 0, 0)
        let end = SIMD3<Float>(1, 0, 0)

        let path = layoutEngine.generatePath(from: start, to: end, arcHeight: 0.3, steps: 10)

        XCTAssertEqual(path.count, 10)
        XCTAssertEqual(path.first!, start, accuracy: 0.001)
        XCTAssertEqual(path.last!, end, accuracy: 0.001)
    }

    func testGeneratePathHasArc() {
        let start = SIMD3<Float>(0, 0, 0)
        let end = SIMD3<Float>(2, 0, 0)

        let path = layoutEngine.generatePath(from: start, to: end, arcHeight: 0.5, steps: 11)

        // Middle point should be elevated
        let midIndex = path.count / 2
        XCTAssertGreaterThan(path[midIndex].y, 0.4)
    }

    func testGeneratePathStepsCount() {
        let start = SIMD3<Float>(0, 0, 0)
        let end = SIMD3<Float>(1, 1, 1)

        let path5 = layoutEngine.generatePath(from: start, to: end, arcHeight: 0.2, steps: 5)
        let path20 = layoutEngine.generatePath(from: start, to: end, arcHeight: 0.2, steps: 20)
        let path100 = layoutEngine.generatePath(from: start, to: end, arcHeight: 0.2, steps: 100)

        XCTAssertEqual(path5.count, 5)
        XCTAssertEqual(path20.count, 20)
        XCTAssertEqual(path100.count, 100)
    }

    // MARK: - Bounds Calculation Tests

    func testCalculateBoundsEmpty() {
        let bounds = layoutEngine.calculateBounds(for: [])

        XCTAssertEqual(bounds.center, .zero)
        XCTAssertEqual(bounds.size, .zero)
    }

    func testCalculateBoundsSinglePoint() {
        let positions: [SIMD3<Float>] = [[1, 2, 3]]
        let bounds = layoutEngine.calculateBounds(for: positions)

        XCTAssertEqual(bounds.center, SIMD3<Float>(1, 2, 3))
        XCTAssertEqual(bounds.size, .zero)
    }

    func testCalculateBoundsMultiplePoints() {
        let positions: [SIMD3<Float>] = [
            [0, 0, 0],
            [2, 4, 6],
            [1, 2, 3]
        ]
        let bounds = layoutEngine.calculateBounds(for: positions)

        XCTAssertEqual(bounds.center, SIMD3<Float>(1, 2, 3), accuracy: 0.001)
        XCTAssertEqual(bounds.size, SIMD3<Float>(2, 4, 6), accuracy: 0.001)
    }
}

// MARK: - OctreeNode Tests

final class OctreeNodeTests: XCTestCase {

    func testOctreeNodeInitialization() {
        let node = OctreeNode(center: SIMD3<Float>(0, 0, 0), halfSize: 1.0)

        XCTAssertEqual(node.center, .zero)
        XCTAssertEqual(node.halfSize, 1.0)
        XCTAssertEqual(node.totalMass, 0)
        XCTAssertEqual(node.centerOfMass, .zero)
        XCTAssertNil(node.entity)
        XCTAssertEqual(node.children.count, 8)
        XCTAssertTrue(node.children.allSatisfy { $0 == nil })
    }

    func testOctreeNodeOctantCalculation() {
        let node = OctreeNode(center: SIMD3<Float>(0, 0, 0), halfSize: 1.0)

        // Test all 8 octants
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(0.5, 0.5, 0.5)), 7)    // +++
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(-0.5, 0.5, 0.5)), 6)   // -++
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(0.5, -0.5, 0.5)), 5)   // +-+
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(-0.5, -0.5, 0.5)), 4)  // --+
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(0.5, 0.5, -0.5)), 3)   // ++-
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(-0.5, 0.5, -0.5)), 2)  // -+-
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(0.5, -0.5, -0.5)), 1)  // +--
        XCTAssertEqual(node.octantIndex(for: SIMD3<Float>(-0.5, -0.5, -0.5)), 0) // ---
    }

    func testOctreeNodeInsertion() {
        let node = OctreeNode(center: SIMD3<Float>(0, 0, 0), halfSize: 1.0)
        let entityID = UUID()

        node.insert(position: SIMD3<Float>(0.5, 0.5, 0.5), mass: 1.0, entityID: entityID)

        XCTAssertEqual(node.totalMass, 1.0)
        XCTAssertEqual(node.entity, entityID)
    }

    func testOctreeNodeMultipleInsertions() {
        let node = OctreeNode(center: SIMD3<Float>(0, 0, 0), halfSize: 2.0)

        node.insert(position: SIMD3<Float>(0.5, 0.5, 0.5), mass: 1.0, entityID: UUID())
        node.insert(position: SIMD3<Float>(-0.5, -0.5, -0.5), mass: 2.0, entityID: UUID())

        XCTAssertEqual(node.totalMass, 3.0)
        // Center of mass should be weighted
        let expectedCOM = (SIMD3<Float>(0.5, 0.5, 0.5) * 1.0 + SIMD3<Float>(-0.5, -0.5, -0.5) * 2.0) / 3.0
        XCTAssertEqual(node.centerOfMass, expectedCOM, accuracy: 0.001)
    }

    func testOctreeNodeIsLeaf() {
        let node = OctreeNode(center: SIMD3<Float>(0, 0, 0), halfSize: 1.0)

        XCTAssertTrue(node.isLeaf)

        node.insert(position: SIMD3<Float>(0.5, 0.5, 0.5), mass: 1.0, entityID: UUID())
        XCTAssertTrue(node.isLeaf)

        // Insert second entity to cause subdivision
        node.insert(position: SIMD3<Float>(-0.5, -0.5, -0.5), mass: 1.0, entityID: UUID())
        XCTAssertFalse(node.isLeaf)
    }
}

// MARK: - SpatialHashGrid Tests

final class SpatialHashGridTests: XCTestCase {

    func testSpatialHashGridInitialization() {
        let grid = SpatialHashGrid(cellSize: 0.5)

        XCTAssertEqual(grid.cellSize, 0.5)
    }

    func testSpatialHashGridInsertAndQuery() {
        let grid = SpatialHashGrid(cellSize: 1.0)
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        grid.insert(id: id1, position: SIMD3<Float>(0, 0, 0))
        grid.insert(id: id2, position: SIMD3<Float>(0.5, 0.5, 0.5))
        grid.insert(id: id3, position: SIMD3<Float>(5, 5, 5))  // Far away

        let neighbors = grid.getNeighbors(of: id1, radius: 1.5)

        XCTAssertTrue(neighbors.contains(id2))
        XCTAssertFalse(neighbors.contains(id3))
        XCTAssertFalse(neighbors.contains(id1))  // Shouldn't include self
    }

    func testSpatialHashGridClear() {
        let grid = SpatialHashGrid(cellSize: 1.0)

        grid.insert(id: UUID(), position: SIMD3<Float>(0, 0, 0))
        grid.insert(id: UUID(), position: SIMD3<Float>(1, 1, 1))

        grid.clear()

        let id = UUID()
        grid.insert(id: id, position: SIMD3<Float>(0, 0, 0))
        let neighbors = grid.getNeighbors(of: id, radius: 10)

        XCTAssertTrue(neighbors.isEmpty)
    }

    func testSpatialHashGridUpdate() {
        let grid = SpatialHashGrid(cellSize: 1.0)
        let id = UUID()

        grid.insert(id: id, position: SIMD3<Float>(0, 0, 0))
        grid.update(id: id, newPosition: SIMD3<Float>(10, 10, 10))

        // Position should be updated
        let otherID = UUID()
        grid.insert(id: otherID, position: SIMD3<Float>(0, 0, 0))
        let neighbors = grid.getNeighbors(of: otherID, radius: 1.0)

        XCTAssertFalse(neighbors.contains(id))
    }
}

// MARK: - ImmersionLevel Tests

@MainActor
final class ImmersionLevelTests: XCTestCase {

    func testImmersionLevelOrdering() {
        let levels = ImmersionManager.ImmersionLevel.allCases

        XCTAssertEqual(levels.count, 6)
        XCTAssertEqual(levels[0], .none)
        XCTAssertEqual(levels[5], .complete)
    }

    func testImmersionLevelComparison() {
        XCTAssertTrue(ImmersionManager.ImmersionLevel.none < .minimal)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.minimal < .partial)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.partial < .focused)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.focused < .full)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.full < .complete)
    }

    func testImmersionLevelPassthrough() {
        XCTAssertEqual(ImmersionManager.ImmersionLevel.none.passthroughOpacity, 1.0)
        XCTAssertEqual(ImmersionManager.ImmersionLevel.complete.passthroughOpacity, 0.0)

        // Verify decreasing passthrough as immersion increases
        var previousPassthrough = 2.0  // Start above 1.0
        for level in ImmersionManager.ImmersionLevel.allCases {
            XCTAssertLessThanOrEqual(level.passthroughOpacity, previousPassthrough)
            previousPassthrough = level.passthroughOpacity
        }
    }

    func testImmersionLevelRequiresImmersiveSpace() {
        XCTAssertFalse(ImmersionManager.ImmersionLevel.none.requiresImmersiveSpace)
        XCTAssertFalse(ImmersionManager.ImmersionLevel.minimal.requiresImmersiveSpace)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.partial.requiresImmersiveSpace)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.focused.requiresImmersiveSpace)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.full.requiresImmersiveSpace)
        XCTAssertTrue(ImmersionManager.ImmersionLevel.complete.requiresImmersiveSpace)
    }

    func testEnvironmentConfiguration() {
        let noneConfig = ImmersionManager.EnvironmentConfiguration(for: .none)
        let completeConfig = ImmersionManager.EnvironmentConfiguration(for: .complete)

        XCTAssertEqual(noneConfig.skyboxOpacity, 0.0)
        XCTAssertFalse(noneConfig.groundPlaneEnabled)
        XCTAssertFalse(noneConfig.spatialAudioEnabled)

        XCTAssertEqual(completeConfig.skyboxOpacity, 1.0)
        XCTAssertTrue(completeConfig.groundPlaneEnabled)
        XCTAssertTrue(completeConfig.spatialAudioEnabled)
        XCTAssertTrue(completeConfig.fogEnabled)
    }
}

// MARK: - NavigationDestination Tests

@MainActor
final class NavigationDestinationTests: XCTestCase {

    func testNavigationDestinationEquality() {
        let dept1 = NavigationDestination.department(UUID())
        let dept2 = NavigationDestination.department(dept1.id!)
        let dept3 = NavigationDestination.department(UUID())

        XCTAssertEqual(dept1, dept2)
        XCTAssertNotEqual(dept1, dept3)
    }

    func testNavigationDestinationID() {
        let id = UUID()
        let destinations: [NavigationDestination] = [
            .dashboard,
            .department(id),
            .kpiDetail(id),
            .report(id),
            .employee(id),
            .settings,
            .businessUniverse
        ]

        XCTAssertNil(NavigationDestination.dashboard.id)
        XCTAssertEqual(NavigationDestination.department(id).id, id)
        XCTAssertEqual(NavigationDestination.kpiDetail(id).id, id)
        XCTAssertNil(NavigationDestination.settings.id)
    }

    func testNavigationDestinationTitle() {
        XCTAssertEqual(NavigationDestination.dashboard.title, "Dashboard")
        XCTAssertEqual(NavigationDestination.settings.title, "Settings")
        XCTAssertEqual(NavigationDestination.businessUniverse.title, "Business Universe")
    }
}

// MARK: - EntityPool.EntityType Tests

@MainActor
final class EntityPoolTypeTests: XCTestCase {

    func testEntityTypeCacheKey() {
        let box1 = EntityPool.EntityType.box(size: [1, 1, 1], cornerRadius: 0.1)
        let box2 = EntityPool.EntityType.box(size: [1, 1, 1], cornerRadius: 0.1)
        let box3 = EntityPool.EntityType.box(size: [2, 2, 2], cornerRadius: 0.1)

        XCTAssertEqual(box1.cacheKey, box2.cacheKey)
        XCTAssertNotEqual(box1.cacheKey, box3.cacheKey)
    }

    func testEntityTypeStandardSizes() {
        XCTAssertEqual(EntityPool.EntityType.smallSphere.cacheKey, "sphere_0.008")
        XCTAssertEqual(EntityPool.EntityType.mediumSphere.cacheKey, "sphere_0.02")
        XCTAssertEqual(EntityPool.EntityType.largeSphere.cacheKey, "sphere_0.05")
    }

    func testEntityTypeCustom() {
        let custom = EntityPool.EntityType.custom("my-custom-entity")
        XCTAssertEqual(custom.cacheKey, "custom_my-custom-entity")
    }
}

// MARK: - SpatialAudioManager.SoundEffect Tests

final class SpatialAudioSoundEffectTests: XCTestCase {

    func testSoundEffectCategories() {
        // Interaction sounds
        XCTAssertEqual(SpatialAudioManager.SoundEffect.tap.category, .interaction)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.select.category, .interaction)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.drag.category, .interaction)

        // Navigation sounds
        XCTAssertEqual(SpatialAudioManager.SoundEffect.windowOpen.category, .interaction)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.immersiveEnter.category, .interaction)

        // Data sounds
        XCTAssertEqual(SpatialAudioManager.SoundEffect.dataUpdate.category, .data)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.kpiAlert.category, .data)

        // Notification sounds
        XCTAssertEqual(SpatialAudioManager.SoundEffect.success.category, .notification)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.error.category, .notification)

        // Ambient sounds
        XCTAssertEqual(SpatialAudioManager.SoundEffect.ambientHum.category, .ambient)
    }

    func testSoundEffectDurations() {
        XCTAssertEqual(SpatialAudioManager.SoundEffect.tap.duration, 0.1)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.windowOpen.duration, 0.3)
        XCTAssertEqual(SpatialAudioManager.SoundEffect.ambientHum.duration, 2.0)
    }

    func testAudioCategoryDefaultVolumes() {
        XCTAssertEqual(SpatialAudioManager.AudioCategory.interaction.defaultVolume, 0.6)
        XCTAssertEqual(SpatialAudioManager.AudioCategory.notification.defaultVolume, 0.8)
        XCTAssertEqual(SpatialAudioManager.AudioCategory.ambient.defaultVolume, 0.3)
        XCTAssertEqual(SpatialAudioManager.AudioCategory.data.defaultVolume, 0.4)
    }
}

// MARK: - SIMD3 Helper Tests

final class SIMD3HelperTests: XCTestCase {

    func testSIMD3Accuracy() {
        let a = SIMD3<Float>(1.0, 2.0, 3.0)
        let b = SIMD3<Float>(1.001, 2.001, 3.001)
        let c = SIMD3<Float>(1.1, 2.1, 3.1)

        XCTAssertEqual(a, b, accuracy: 0.01)
        XCTAssertNotEqual(a, c, accuracy: 0.01)
    }
}

// MARK: - XCTest Helper Extension

extension XCTestCase {
    func XCTAssertEqual(_ lhs: SIMD3<Float>, _ rhs: SIMD3<Float>, accuracy: Float, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lhs.x, rhs.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.y, rhs.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.z, rhs.z, accuracy: accuracy, file: file, line: line)
    }

    func XCTAssertNotEqual(_ lhs: SIMD3<Float>, _ rhs: SIMD3<Float>, accuracy: Float, file: StaticString = #file, line: UInt = #line) {
        let diffX = abs(lhs.x - rhs.x)
        let diffY = abs(lhs.y - rhs.y)
        let diffZ = abs(lhs.z - rhs.z)

        XCTAssertTrue(diffX > accuracy || diffY > accuracy || diffZ > accuracy, file: file, line: line)
    }
}
