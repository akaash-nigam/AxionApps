import XCTest
import SwiftData
@testable import ExecutiveBriefing

final class BriefingSectionTests: XCTestCase {
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([
            BriefingSection.self,
            ContentBlock.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: configuration)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    func testBriefingSectionInitialization() {
        // Given
        let section = BriefingSection(
            title: "Executive Summary",
            order: 1,
            icon: "star.fill"
        )

        // Then
        XCTAssertNotNil(section.id)
        XCTAssertEqual(section.title, "Executive Summary")
        XCTAssertEqual(section.order, 1)
        XCTAssertEqual(section.icon, "star.fill")
        XCTAssertTrue(section.content.isEmpty)
        XCTAssertNil(section.visualizationType)
        XCTAssertNil(section.lastAccessed)
    }

    func testBriefingSectionWithContent() {
        // Given
        let contentBlock = ContentBlock(
            type: .paragraph,
            content: "Test content"
        )
        let section = BriefingSection(
            title: "Test Section",
            order: 1,
            icon: "doc.fill",
            content: [contentBlock]
        )

        // Then
        XCTAssertEqual(section.content.count, 1)
        XCTAssertEqual(section.content.first?.content, "Test content")
    }

    func testBriefingSectionAccessibilityLabel() {
        // Given
        let section = BriefingSection(
            title: "Executive Summary",
            order: 1,
            icon: "star.fill"
        )

        // When
        let label = section.accessibilityLabel

        // Then
        XCTAssertEqual(label, "Executive Summary section, order 1")
    }

    func testBriefingSectionEquality() {
        // Given
        let id = UUID()
        let section1 = BriefingSection(
            id: id,
            title: "Test",
            order: 1,
            icon: "star"
        )
        let section2 = BriefingSection(
            id: id,
            title: "Different Title",
            order: 2,
            icon: "circle"
        )
        let section3 = BriefingSection(
            title: "Test",
            order: 1,
            icon: "star"
        )

        // Then
        XCTAssertEqual(section1, section2) // Same ID
        XCTAssertNotEqual(section1, section3) // Different ID
    }

    func testBriefingSectionPersistence() async throws {
        // Given
        let section = BriefingSection(
            title: "Test Section",
            order: 1,
            icon: "star.fill"
        )

        // When
        modelContext.insert(section)
        try modelContext.save()

        // Then
        let fetchDescriptor = FetchDescriptor<BriefingSection>()
        let fetchedSections = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedSections.count, 1)
        XCTAssertEqual(fetchedSections.first?.title, "Test Section")
    }

    func testBriefingSectionWithVisualizationType() {
        // Given
        let section = BriefingSection(
            title: "Use Cases",
            order: 2,
            icon: "chart.bar",
            visualizationType: .roiComparison
        )

        // Then
        XCTAssertEqual(section.visualizationType, .roiComparison)
    }
}
