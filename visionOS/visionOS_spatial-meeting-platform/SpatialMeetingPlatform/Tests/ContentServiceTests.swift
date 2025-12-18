import XCTest
@testable import SpatialMeetingPlatform
import Foundation

final class ContentServiceTests: XCTestCase {
    var sut: ContentService!

    override func setUp() {
        super.setUp()
        sut = ContentService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Content Sharing Tests

    func testShareContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .document,
            title: "Test Document"
        )

        XCTAssertEqual(sut.sharedContent.count, 0)

        // When
        try await sut.shareContent(content)

        // Then
        XCTAssertEqual(sut.sharedContent.count, 1)
        XCTAssertTrue(sut.sharedContent.contains(where: { $0.id == content.id }))
    }

    func testUpdateContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .whiteboard,
            title: "Test Whiteboard"
        )

        try await sut.shareContent(content)
        let originalVersion = content.version

        // When
        try await sut.updateContent(content)

        // Then
        let updated = sut.sharedContent.first { $0.id == content.id }
        XCTAssertEqual(updated?.version, originalVersion + 1)
    }

    func testRemoveContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .document,
            title: "Test Document"
        )

        try await sut.shareContent(content)
        XCTAssertEqual(sut.sharedContent.count, 1)

        // When
        try await sut.removeContent(content.id)

        // Then
        XCTAssertEqual(sut.sharedContent.count, 0)
    }

    // MARK: - Content Selection Tests

    func testSelectContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .model3D,
            title: "Test Model"
        )

        try await sut.shareContent(content)

        // When
        sut.selectContent(content)

        // Then
        XCTAssertNotNil(sut.selectedContent)
        XCTAssertEqual(sut.selectedContent?.id, content.id)
    }

    func testDeselectContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .document,
            title: "Test"
        )

        try await sut.shareContent(content)
        sut.selectContent(content)

        // When
        sut.deselectContent()

        // Then
        XCTAssertNil(sut.selectedContent)
    }

    // MARK: - Content Manipulation Tests

    func testMoveContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .document,
            title: "Test"
        )

        try await sut.shareContent(content)

        let newPosition = SpatialPosition(x: 5.0, y: 2.0, z: -3.0)

        // When
        try await sut.moveContent(content.id, to: newPosition)

        // Then
        let updated = sut.sharedContent.first { $0.id == content.id }
        XCTAssertEqual(updated?.position.x, 5.0)
        XCTAssertEqual(updated?.position.y, 2.0)
        XCTAssertEqual(updated?.position.z, -3.0)
    }

    func testScaleContent() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .model3D,
            title: "Test Model"
        )

        try await sut.shareContent(content)

        // When
        try await sut.scaleContent(content.id, scale: 2.5)

        // Then
        let updated = sut.sharedContent.first { $0.id == content.id }
        XCTAssertEqual(updated?.scale, 2.5)
    }

    // MARK: - Content Creation Tests

    func testCreateWhiteboard() {
        // Given
        let meetingId = UUID()
        let creatorId = UUID()

        // When
        let whiteboard = sut.createWhiteboard(
            meetingId: meetingId,
            creatorId: creatorId,
            title: "Brainstorm Session"
        )

        // Then
        XCTAssertEqual(whiteboard.type, .whiteboard)
        XCTAssertEqual(whiteboard.title, "Brainstorm Session")
        XCTAssertEqual(whiteboard.meetingId, meetingId)
        XCTAssertEqual(whiteboard.creatorId, creatorId)
        XCTAssertEqual(whiteboard.scale, 2.0)
    }

    func testCreateDocumentViewer() {
        // Given
        let url = URL(string: "https://example.com/document.pdf")!

        // When
        let document = sut.createDocumentViewer(
            meetingId: UUID(),
            creatorId: UUID(),
            title: "Quarterly Report",
            url: url
        )

        // Then
        XCTAssertEqual(document.type, .document)
        XCTAssertEqual(document.url, url)
        XCTAssertEqual(document.scale, 1.0)
    }

    func testCreate3DModel() {
        // Given
        let url = URL(string: "https://example.com/model.usdz")!

        // When
        let model = sut.create3DModel(
            meetingId: UUID(),
            creatorId: UUID(),
            title: "Product Prototype",
            url: url
        )

        // Then
        XCTAssertEqual(model.type, .model3D)
        XCTAssertEqual(model.url, url)
        XCTAssertEqual(model.scale, 1.5)
    }

    // MARK: - Annotation Tests

    func testAddAnnotation() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .document,
            title: "Test Document"
        )

        try await sut.shareContent(content)

        let annotation = Annotation(
            contentId: content.id,
            authorId: UUID(),
            text: "Important point",
            position: SpatialPosition(x: 0.5, y: 0.5, z: 0)
        )

        // When
        try await sut.addAnnotation(to: content.id, annotation: annotation)

        // Then
        let updated = sut.sharedContent.first { $0.id == content.id }
        XCTAssertEqual(updated?.annotations.count, 1)
        XCTAssertEqual(updated?.annotations.first?.text, "Important point")
    }

    func testRemoveAnnotation() async throws {
        // Given
        let content = SharedContent(
            meetingId: UUID(),
            creatorId: UUID(),
            type: .document,
            title: "Test Document"
        )

        try await sut.shareContent(content)

        let annotation = Annotation(
            contentId: content.id,
            authorId: UUID(),
            text: "Test annotation",
            position: SpatialPosition(x: 0, y: 0, z: 0)
        )

        try await sut.addAnnotation(to: content.id, annotation: annotation)

        // When
        try await sut.removeAnnotation(annotation.id, from: content.id)

        // Then
        let updated = sut.sharedContent.first { $0.id == content.id }
        XCTAssertEqual(updated?.annotations.count, 0)
    }
}
