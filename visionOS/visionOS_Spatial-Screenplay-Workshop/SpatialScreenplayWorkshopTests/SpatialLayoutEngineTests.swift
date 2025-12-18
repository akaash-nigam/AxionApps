//
//  SpatialLayoutEngineTests.swift
//  SpatialScreenplayWorkshopTests
//
//  Created on 2025-11-24
//

import XCTest
@testable import SpatialScreenplayWorkshop

/// Unit tests for SpatialLayoutEngine
final class SpatialLayoutEngineTests: XCTestCase {
    var layoutEngine: SpatialLayoutEngine!
    var testScenes: [Scene]!

    override func setUp() {
        super.setUp()
        layoutEngine = SpatialLayoutEngine()
        testScenes = createTestScenes()
    }

    override func tearDown() {
        layoutEngine = nil
        testScenes = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createTestScenes() -> [Scene] {
        var scenes: [Scene] = []

        // Act I: 5 scenes
        for i in 1...5 {
            let scene = Scene(
                sceneNumber: i,
                slugLine: SlugLine(
                    setting: .interior,
                    location: "Test Location \(i)",
                    timeOfDay: .day
                ),
                content: SceneContent(elements: []),
                position: ScenePosition(act: 1, sequence: i),
                metadata: Metadata()
            )
            scenes.append(scene)
        }

        // Act II: 8 scenes
        for i in 6...13 {
            let scene = Scene(
                sceneNumber: i,
                slugLine: SlugLine(
                    setting: .exterior,
                    location: "Test Location \(i)",
                    timeOfDay: .night
                ),
                content: SceneContent(elements: []),
                position: ScenePosition(act: 2, sequence: i - 5),
                metadata: Metadata()
            )
            scenes.append(scene)
        }

        // Act III: 5 scenes
        for i in 14...18 {
            let scene = Scene(
                sceneNumber: i,
                slugLine: SlugLine(
                    setting: .interior,
                    location: "Test Location \(i)",
                    timeOfDay: .day
                ),
                content: SceneContent(elements: []),
                position: ScenePosition(act: 3, sequence: i - 13),
                metadata: Metadata()
            )
            scenes.append(scene)
        }

        return scenes
    }

    // MARK: - Position Calculation Tests

    func testCalculatePositions_ReturnsAllScenes() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: testScenes, in: containerSize)

        XCTAssertEqual(positions.count, testScenes.count, "Should return position for every scene")
    }

    func testCalculatePositions_GroupsByAct() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: testScenes, in: containerSize)

        // Group positions by act based on Z coordinate
        let act1Scenes = testScenes.filter { $0.position.act == 1 }
        let act2Scenes = testScenes.filter { $0.position.act == 2 }
        let act3Scenes = testScenes.filter { $0.position.act == 3 }

        let act1Positions = act1Scenes.compactMap { positions[$0] }
        let act2Positions = act2Scenes.compactMap { positions[$0] }
        let act3Positions = act3Scenes.compactMap { positions[$0] }

        // Verify Act I is at front (z = 0)
        XCTAssertTrue(act1Positions.allSatisfy { $0.z == 0.0 }, "Act I should be at z=0")

        // Verify Act II is behind Act I (z = -0.5)
        XCTAssertTrue(act2Positions.allSatisfy { $0.z == -0.5 }, "Act II should be at z=-0.5")

        // Verify Act III is furthest back (z = -1.0)
        XCTAssertTrue(act3Positions.allSatisfy { $0.z == -1.0 }, "Act III should be at z=-1.0")
    }

    func testCalculatePositions_NoOverlaps() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: testScenes, in: containerSize)

        let positionValues = Array(positions.values)

        // Check for overlaps (no two cards should be at same position)
        for i in 0..<positionValues.count {
            for j in (i+1)..<positionValues.count {
                let pos1 = positionValues[i]
                let pos2 = positionValues[j]

                // If same act (same Z), should not overlap in X,Y
                if abs(pos1.z - pos2.z) < 0.01 {
                    let distance = simd_distance(
                        SIMD2<Float>(pos1.x, pos1.y),
                        SIMD2<Float>(pos2.x, pos2.y)
                    )

                    let minDistance = SceneCardEntity.cardWidth + SpatialLayoutEngine.cardSpacingX
                    XCTAssertGreaterThanOrEqual(
                        distance,
                        minDistance * 0.9,  // Allow 10% tolerance
                        "Cards should not overlap"
                    )
                }
            }
        }
    }

    func testCalculateInsertPosition_ValidIndex() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let insertIndex = 3
        let position = layoutEngine.calculateInsertPosition(
            at: insertIndex,
            in: testScenes,
            containerSize: containerSize
        )

        // Should return valid 3D position
        XCTAssertNotEqual(position, .zero, "Should return non-zero position")
    }

    // MARK: - Act Divider Tests

    func testGetActDividerPositions_CreatesCorrectDividers() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let dividers = layoutEngine.getActDividerPositions(for: testScenes, in: containerSize)

        // Should have 2 dividers (between Acts I-II and II-III)
        XCTAssertEqual(dividers.count, 2, "Should have 2 act dividers")

        // Verify divider positions are between acts
        let divider1 = dividers.first { $0.fromAct == 1 && $0.toAct == 2 }
        XCTAssertNotNil(divider1, "Should have divider between Act I and II")
        XCTAssertEqual(divider1?.position.z, -0.25, accuracy: 0.01, "Divider should be at midpoint")

        let divider2 = dividers.first { $0.fromAct == 2 && $0.toAct == 3 }
        XCTAssertNotNil(divider2, "Should have divider between Act II and III")
        XCTAssertEqual(divider2?.position.z, -0.75, accuracy: 0.01, "Divider should be at midpoint")
    }

    // MARK: - Validation Tests

    func testValidate_WithinBounds() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: testScenes, in: containerSize)

        let isValid = layoutEngine.validate(positions: positions, containerSize: containerSize)

        XCTAssertTrue(isValid, "All positions should be within container bounds")
    }

    func testCalculateBoundingBox_CorrectBounds() {
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: testScenes, in: containerSize)

        let (min, max) = layoutEngine.calculateBoundingBox(positions: positions)

        // Min should be less than max in all dimensions
        XCTAssertLessThan(min.x, max.x, "Min X should be less than max X")
        XCTAssertLessThan(min.y, max.y, "Min Y should be less than max Y")
        XCTAssertLessThan(min.z, max.z, "Min Z should be less than max Z")

        // Bounding box should fit within container
        let width = max.x - min.x
        let height = max.y - min.y

        XCTAssertLessThanOrEqual(width, Float(containerSize.width), "Width should fit in container")
        XCTAssertLessThanOrEqual(height, Float(containerSize.height), "Height should fit in container")
    }

    // MARK: - Edge Case Tests

    func testCalculatePositions_SingleScene() {
        let singleScene = [testScenes[0]]
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: singleScene, in: containerSize)

        XCTAssertEqual(positions.count, 1, "Should handle single scene")

        if let position = positions[singleScene[0]] {
            // Single scene should be centered
            XCTAssertEqual(position.x, 0, accuracy: 0.01, "Single scene should be centered horizontally")
        }
    }

    func testCalculatePositions_EmptyScenes() {
        let emptyScenes: [Scene] = []
        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: emptyScenes, in: containerSize)

        XCTAssertTrue(positions.isEmpty, "Should handle empty scene list")
    }

    func testCalculatePositions_ManyScenes() {
        // Create 50 scenes
        var manyScenes: [Scene] = []
        for i in 1...50 {
            let act = (i - 1) / 17 + 1  // Distribute across 3 acts
            let scene = Scene(
                sceneNumber: i,
                slugLine: SlugLine(setting: .interior, location: "Location \(i)", timeOfDay: .day),
                content: SceneContent(elements: []),
                position: ScenePosition(act: act, sequence: i),
                metadata: Metadata()
            )
            manyScenes.append(scene)
        }

        let containerSize = CGSize(width: 4.0, height: 2.0)
        let positions = layoutEngine.calculatePositions(for: manyScenes, in: containerSize)

        XCTAssertEqual(positions.count, 50, "Should handle 50 scenes")

        // Verify no positions are NaN or infinite
        for position in positions.values {
            XCTAssertFalse(position.x.isNaN, "X should not be NaN")
            XCTAssertFalse(position.y.isNaN, "Y should not be NaN")
            XCTAssertFalse(position.z.isNaN, "Z should not be NaN")
            XCTAssertFalse(position.x.isInfinite, "X should not be infinite")
            XCTAssertFalse(position.y.isInfinite, "Y should not be infinite")
            XCTAssertFalse(position.z.isInfinite, "Z should not be infinite")
        }
    }

    // MARK: - Performance Tests

    func testCalculatePositions_Performance() {
        // Create 100 scenes
        var largeSceneSet: [Scene] = []
        for i in 1...100 {
            let act = (i - 1) / 34 + 1
            let scene = Scene(
                sceneNumber: i,
                slugLine: SlugLine(setting: .interior, location: "Location \(i)", timeOfDay: .day),
                content: SceneContent(elements: []),
                position: ScenePosition(act: act, sequence: i),
                metadata: Metadata()
            )
            largeSceneSet.append(scene)
        }

        let containerSize = CGSize(width: 4.0, height: 2.0)

        measure {
            _ = layoutEngine.calculatePositions(for: largeSceneSet, in: containerSize)
        }
    }
}
