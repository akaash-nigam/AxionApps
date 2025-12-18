import XCTest
@testable import HideAndSeekEvolved

final class OcclusionDetectorTests: XCTestCase {
    var sut: OcclusionDetector!
    var mockRoomLayout: RoomLayout!

    override func setUp() async throws {
        sut = OcclusionDetector()
        mockRoomLayout = createMockRoomLayout()
    }

    override func tearDown() async throws {
        sut = nil
        mockRoomLayout = nil
    }

    // MARK: - Visibility Tests

    func testCheckVisibility_clearLineOfSight_returnsTrue() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider = Player(name: "Hider", position: SIMD3(5, 1, 0))
        let emptyRoom = RoomLayout(
            bounds: BoundingBox(min: SIMD3(-10, 0, -10), max: SIMD3(10, 3, 10)),
            furniture: []
        )

        // When
        let isVisible = await sut.checkVisibility(from: seeker, to: hider, in: emptyRoom)

        // Then
        XCTAssertTrue(isVisible)
    }

    func testCheckVisibility_blockedByFurniture_returnsFalse() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider = Player(name: "Hider", position: SIMD3(5, 1, 0))

        // Place large furniture between them
        let blockingFurniture = FurnitureItem(
            type: .wardrobe,
            position: SIMD3(2.5, 1, 0),  // Halfway between
            size: SIMD3(1, 2, 0.6),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.9
        )

        var roomWithFurniture = mockRoomLayout!
        roomWithFurniture.furniture = [blockingFurniture]

        // When
        let isVisible = await sut.checkVisibility(from: seeker, to: hider, in: roomWithFurniture)

        // Then
        XCTAssertFalse(isVisible)
    }

    func testCheckVisibility_partiallyBlocked_usesThreshold() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider = Player(name: "Hider", position: SIMD3(5, 1, 0))

        // Small furniture that only partially blocks
        let smallFurniture = FurnitureItem(
            type: .chair,
            position: SIMD3(2.5, 0.5, 0),
            size: SIMD3(0.5, 1, 0.5),
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 0.5
        )

        var roomWithFurniture = mockRoomLayout!
        roomWithFurniture.furniture = [smallFurniture]

        // When
        let percentage = await sut.calculateVisibilityPercentage(
            from: seeker.position,
            to: hider.position,
            in: roomWithFurniture
        )

        // Then - Should be partially visible (some sample points blocked, some clear)
        XCTAssertGreaterThan(percentage, 0.0)
        XCTAssertLessThan(percentage, 1.0)
    }

    // MARK: - Visibility Percentage Tests

    func testCalculateVisibilityPercentage_clearView_returns100Percent() async {
        // Given
        let viewerPos = SIMD3<Float>(0, 1, 0)
        let targetPos = SIMD3<Float>(5, 1, 0)
        let emptyRoom = RoomLayout(
            bounds: BoundingBox(min: SIMD3(-10, 0, -10), max: SIMD3(10, 3, 10)),
            furniture: []
        )

        // When
        let percentage = await sut.calculateVisibilityPercentage(
            from: viewerPos,
            to: targetPos,
            in: emptyRoom
        )

        // Then
        XCTAssertEqual(percentage, 1.0, accuracy: 0.01)
    }

    func testCalculateVisibilityPercentage_completelyBlocked_returns0Percent() async {
        // Given
        let viewerPos = SIMD3<Float>(0, 1, 0)
        let targetPos = SIMD3<Float>(5, 1, 0)

        // Massive furniture completely blocking view
        let massiveFurniture = FurnitureItem(
            type: .wardrobe,
            position: SIMD3(2.5, 1, 0),
            size: SIMD3(5, 3, 5),  // Very large
            orientation: simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
            hidingPotential: 1.0
        )

        var roomWithFurniture = mockRoomLayout!
        roomWithFurniture.furniture = [massiveFurniture]

        // When
        let percentage = await sut.calculateVisibilityPercentage(
            from: viewerPos,
            to: targetPos,
            in: roomWithFurniture
        )

        // Then
        XCTAssertEqual(percentage, 0.0, accuracy: 0.01)
    }

    // MARK: - Cache Tests

    func testCheckVisibility_usesCaching() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider = Player(name: "Hider", position: SIMD3(5, 1, 0))

        // First call - populates cache
        _ = await sut.checkVisibility(from: seeker, to: hider, in: mockRoomLayout)

        // When - Second call should use cache
        let cachedResult = await sut.checkVisibility(from: seeker, to: hider, in: mockRoomLayout)

        // Then
        XCTAssertNotNil(cachedResult)
        let cacheSize = await sut.getCacheSize()
        XCTAssertEqual(cacheSize, 1)
    }

    func testClearCache_removesAllEntries() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider = Player(name: "Hider", position: SIMD3(5, 1, 0))
        _ = await sut.checkVisibility(from: seeker, to: hider, in: mockRoomLayout)

        // When
        await sut.clearCache()

        // Then
        let cacheSize = await sut.getCacheSize()
        XCTAssertEqual(cacheSize, 0)
    }

    func testClearCacheForPlayer_removesPlayerEntries() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider1 = Player(name: "Hider1", position: SIMD3(5, 1, 0))
        let hider2 = Player(name: "Hider2", position: SIMD3(3, 1, 0))

        _ = await sut.checkVisibility(from: seeker, to: hider1, in: mockRoomLayout)
        _ = await sut.checkVisibility(from: seeker, to: hider2, in: mockRoomLayout)

        // When
        await sut.clearCache(for: hider1.id)

        // Then
        let cacheSize = await sut.getCacheSize()
        XCTAssertLessThan(cacheSize, 2)
    }

    // MARK: - Edge Cases

    func testCheckVisibility_samPosition_returnsTrue() async {
        // Given - seeker and hider at same position
        let position = SIMD3<Float>(0, 1, 0)
        let seeker = Player(name: "Seeker", position: position)
        let hider = Player(name: "Hider", position: position)

        // When
        let isVisible = await sut.checkVisibility(from: seeker, to: hider, in: mockRoomLayout)

        // Then
        XCTAssertTrue(isVisible)
    }

    func testCheckVisibility_veryCloseDistance_returnsTrue() async {
        // Given
        let seeker = Player(name: "Seeker", position: SIMD3(0, 1, 0))
        let hider = Player(name: "Hider", position: SIMD3(0.1, 1, 0))  // 10cm away

        // When
        let isVisible = await sut.checkVisibility(from: seeker, to: hider, in: mockRoomLayout)

        // Then
        XCTAssertTrue(isVisible)
    }

    // MARK: - Helper Methods

    private func createMockRoomLayout() -> RoomLayout {
        return RoomLayout(
            bounds: BoundingBox(
                min: SIMD3(-5, 0, -5),
                max: SIMD3(5, 3, 5)
            ),
            furniture: []
        )
    }
}
