//
//  ObjectDetectionServiceTests.swift
//  Language Immersion Rooms Tests
//
//  Unit tests for object detection service
//

import XCTest
@testable import LanguageImmersionRooms

final class ObjectDetectionServiceTests: XCTestCase {

    var service: ObjectDetectionService!

    override func setUp() {
        super.setUp()
        service = ObjectDetectionService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Detection Tests

    func testDetectObjectsReturnsResults() async throws {
        let objects = try await service.detectObjects()

        XCTAssertFalse(objects.isEmpty, "Should detect at least some objects")
        XCTAssertGreaterThan(objects.count, 0)
    }

    func testDetectedObjectsHaveLabels() async throws {
        let objects = try await service.detectObjects()

        for object in objects {
            XCTAssertFalse(object.label.isEmpty, "All detected objects should have labels")
        }
    }

    func testDetectedObjectsHaveConfidence() async throws {
        let objects = try await service.detectObjects()

        for object in objects {
            XCTAssertGreaterThanOrEqual(object.confidence, 0.0)
            XCTAssertLessThanOrEqual(object.confidence, 1.0)
        }
    }

    func testDetectedObjectsHaveBoundingBoxes() async throws {
        let objects = try await service.detectObjects()

        for object in objects {
            XCTAssertGreaterThan(object.boundingBox.width, 0)
            XCTAssertGreaterThan(object.boundingBox.height, 0)
        }
    }

    func testDetectedObjectsHavePositions() async throws {
        let objects = try await service.detectObjects()

        // In simulated mode, all objects should have positions
        for object in objects {
            XCTAssertNotNil(object.position, "Simulated objects should have positions")
        }
    }

    func testDetectedObjectsHaveUniqueIds() async throws {
        let objects = try await service.detectObjects()

        let ids = objects.map { $0.id }
        let uniqueIds = Set(ids)

        XCTAssertEqual(ids.count, uniqueIds.count, "All objects should have unique IDs")
    }

    // MARK: - Simulated Data Tests

    func testSimulatedObjectLabels() async throws {
        let objects = try await service.detectObjects()

        // Check that we get common household objects
        let labels = objects.map { $0.label.lowercased() }

        // Should contain some common items
        let commonItems = ["table", "chair", "sofa", "lamp", "door", "window"]
        let hasCommonItems = commonItems.contains { item in
            labels.contains(item)
        }

        XCTAssertTrue(hasCommonItems, "Should detect common household objects")
    }

    func testSimulatedObjectPositions() async throws {
        let objects = try await service.detectObjects()

        // Check that positions are reasonable (within typical room bounds)
        for object in objects {
            guard let position = object.position else {
                XCTFail("All simulated objects should have positions")
                continue
            }

            // X should be within reasonable room width (-5 to 5 meters)
            XCTAssertGreaterThan(position.x, -5.0)
            XCTAssertLessThan(position.x, 5.0)

            // Y should be at reasonable heights (0 to 3 meters)
            XCTAssertGreaterThan(position.y, 0.0)
            XCTAssertLessThan(position.y, 3.0)

            // Z should be within reasonable depth (-5 to 5 meters)
            XCTAssertGreaterThan(position.z, -5.0)
            XCTAssertLessThan(position.z, 5.0)
        }
    }

    func testSimulatedObjectConfidence() async throws {
        let objects = try await service.detectObjects()

        // Simulated objects should have high confidence
        for object in objects {
            XCTAssertGreaterThan(object.confidence, 0.7, "Simulated objects should have high confidence")
        }
    }

    // MARK: - Multiple Detection Tests

    func testMultipleDetectionCalls() async throws {
        let objects1 = try await service.detectObjects()
        let objects2 = try await service.detectObjects()

        XCTAssertFalse(objects1.isEmpty)
        XCTAssertFalse(objects2.isEmpty)

        // Both calls should return results
        XCTAssertGreaterThan(objects1.count, 0)
        XCTAssertGreaterThan(objects2.count, 0)
    }

    func testConsistentDetection() async throws {
        let objects1 = try await service.detectObjects()
        let objects2 = try await service.detectObjects()

        // In simulated mode, should get similar number of objects
        XCTAssertEqual(objects1.count, objects2.count, accuracy: 5)
    }

    // MARK: - Performance Tests

    func testDetectionPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Detection completes")

            Task {
                _ = try await service.detectObjects()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Edge Cases

    func testNoError() async {
        do {
            _ = try await service.detectObjects()
            // Should not throw
            XCTAssert(true)
        } catch {
            XCTFail("Detection should not throw error in simulated mode: \(error)")
        }
    }
}
