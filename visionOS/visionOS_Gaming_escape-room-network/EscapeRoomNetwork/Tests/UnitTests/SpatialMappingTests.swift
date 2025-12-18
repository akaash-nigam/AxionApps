import XCTest
@testable import EscapeRoomNetwork

/// Unit tests for spatial mapping manager
final class SpatialMappingTests: XCTestCase {

    var sut: SpatialMappingManager!

    override func setUp() {
        super.setUp()
        sut = SpatialMappingManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.getCurrentRoomData())
    }

    // MARK: - Room Scanning Tests

    func testStartRoomScanning() async {
        // Given
        var progressUpdates: [Float] = []
        sut.onScanProgress = { progress in
            progressUpdates.append(progress)
        }

        var completionCalled = false
        sut.onScanComplete = { _ in
            completionCalled = true
        }

        // When
        await sut.startRoomScanning()

        // Then
        XCTAssertTrue(completionCalled)
        XCTAssertGreaterThan(progressUpdates.count, 0)
        XCTAssertNotNil(sut.getCurrentRoomData())
    }

    func testStopRoomScanning() {
        // When
        sut.stopRoomScanning()

        // Then - Should not crash
    }

    func testRoomDataAfterScanning() async {
        // When
        await sut.startRoomScanning()

        // Then
        let roomData = sut.getCurrentRoomData()
        XCTAssertNotNil(roomData)
        XCTAssertNotEqual(roomData?.dimensions, SIMD3<Float>.zero)
    }

    // MARK: - Furniture Recognition Tests

    func testClassifyFurnitureNearTable() async {
        // Given
        await sut.startRoomScanning()

        // When - Position near table
        let furnitureType = sut.classifyFurniture(at: SIMD3<Float>(0, 0.75, 0))

        // Then
        XCTAssertEqual(furnitureType, .table)
    }

    func testClassifyFurnitureNearSofa() async {
        // Given
        await sut.startRoomScanning()

        // When - Position near sofa
        let furnitureType = sut.classifyFurniture(at: SIMD3<Float>(-2, 0.5, 0))

        // Then
        XCTAssertEqual(furnitureType, .sofa)
    }

    func testClassifyFurnitureNoMatch() async {
        // Given
        await sut.startRoomScanning()

        // When - Position far from any furniture
        let furnitureType = sut.classifyFurniture(at: SIMD3<Float>(10, 10, 10))

        // Then
        XCTAssertNil(furnitureType)
    }

    // MARK: - Spatial Query Tests

    func testFindSuitablePositionsForClues() async {
        // Given
        await sut.startRoomScanning()

        // When
        let positions = sut.findSuitablePositions(for: .clue, count: 2)

        // Then
        XCTAssertEqual(positions.count, 2)
        for position in positions {
            XCTAssertGreaterThan(position.y, 0.5) // Should be on furniture surfaces
        }
    }

    func testFindSuitablePositionsForLocks() async {
        // Given
        await sut.startRoomScanning()

        // When
        let positions = sut.findSuitablePositions(for: .lock, count: 3)

        // Then
        XCTAssertEqual(positions.count, 3)
        for position in positions {
            XCTAssertEqual(position.y, 1.5, accuracy: 0.1) // Should be at eye level
        }
    }

    func testFindSuitablePositionsForHints() async {
        // Given
        await sut.startRoomScanning()

        // When
        let positions = sut.findSuitablePositions(for: .hint, count: 5)

        // Then
        XCTAssertEqual(positions.count, 5)
        // Hints should be distributed throughout room
    }

    // MARK: - Room Data Validation Tests

    func testRoomDataHasFurniture() async {
        // When
        await sut.startRoomScanning()

        // Then
        let roomData = sut.getCurrentRoomData()
        XCTAssertNotNil(roomData)
        XCTAssertFalse(roomData!.furniture.isEmpty)
        XCTAssertGreaterThanOrEqual(roomData!.furniture.count, 1)
    }

    func testRoomDataHasAnchorPoints() async {
        // When
        await sut.startRoomScanning()

        // Then
        let roomData = sut.getCurrentRoomData()
        XCTAssertNotNil(roomData)
        XCTAssertFalse(roomData!.anchorPoints.isEmpty)
    }

    func testRoomDimensionsValid() async {
        // When
        await sut.startRoomScanning()

        // Then
        let roomData = sut.getCurrentRoomData()
        XCTAssertNotNil(roomData)

        let dimensions = roomData!.dimensions
        XCTAssertGreaterThan(dimensions.x, 0)
        XCTAssertGreaterThan(dimensions.y, 0)
        XCTAssertGreaterThan(dimensions.z, 0)
    }

    // MARK: - Concurrent Scanning Tests

    func testConcurrentScanningPrevented() async {
        // Given
        let expectation1 = XCTestExpectation(description: "First scan completes")
        sut.onScanComplete = { _ in expectation1.fulfill() }

        // When - Start first scan
        Task {
            await sut.startRoomScanning()
        }

        // Try to start second scan immediately
        await sut.startRoomScanning()

        // Then - Second scan should be ignored
        await fulfillment(of: [expectation1], timeout: 2.0)
    }

    // MARK: - Performance Tests

    func testScanningPerformance() {
        measure {
            Task {
                await sut.startRoomScanning()
            }
        }
    }

    func testFurnitureClassificationPerformance() async {
        // Given
        await sut.startRoomScanning()

        // When/Then
        measure {
            _ = sut.classifyFurniture(at: SIMD3<Float>(0, 0.75, 0))
        }
    }

    func testPositionFindingPerformance() async {
        // Given
        await sut.startRoomScanning()

        // When/Then
        measure {
            _ = sut.findSuitablePositions(for: .clue, count: 10)
        }
    }
}
