import XCTest
@testable import ExecutiveBriefing

final class MarkdownParserTests: XCTestCase {
    var parser: MarkdownParser!

    override func setUp() async throws {
        parser = MarkdownParser()
    }

    override func tearDown() async throws {
        parser = nil
    }

    func testParseSimpleMarkdown() async throws {
        // Given
        let markdown = """
        # Executive Summary

        This is a paragraph.

        ## Key Points

        - Point 1
        - Point 2

        Another paragraph.

        # Second Section

        Content here.
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections[0].title, "Executive Summary")
        XCTAssertEqual(sections[1].title, "Second Section")
    }

    func testParseContentBlocks() async throws {
        // Given
        let markdown = """
        # Test Section

        This is a paragraph.

        ## Subheading

        ### Smaller Heading

        - Bullet 1
        - Bullet 2

        1. Numbered 1
        2. Numbered 2

        ROI: 400%
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertEqual(sections.count, 1)
        let content = sections[0].content

        // Should have: paragraph, subheading, heading, 2 bullets, 2 numbered, 1 metric
        XCTAssertGreaterThan(content.count, 0)

        // Check for different content types
        XCTAssertTrue(content.contains { $0.type == .paragraph })
        XCTAssertTrue(content.contains { $0.type == .subheading })
        XCTAssertTrue(content.contains { $0.type == .heading })
        XCTAssertTrue(content.contains { $0.type == .bulletList })
        XCTAssertTrue(content.contains { $0.type == .numberedList })
        XCTAssertTrue(content.contains { $0.type == .metric })
    }

    func testIconAssignment() async throws {
        // Given
        let markdown = """
        # Executive Summary

        Content

        # Top 10 Use Cases

        Content

        # Critical Decisions

        Content

        # Investment Priorities

        Content

        # Action Items

        Content
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertEqual(sections[0].icon, "doc.text.fill") // Summary
        XCTAssertEqual(sections[1].icon, "chart.bar.fill") // Use Cases
        XCTAssertEqual(sections[2].icon, "arrow.triangle.branch") // Decisions
        XCTAssertEqual(sections[3].icon, "dollarsign.circle.fill") // Investment
        XCTAssertEqual(sections[4].icon, "checkmark.circle.fill") // Actions
    }

    func testVisualizationTypeAssignment() async throws {
        // Given
        let markdown = """
        # Top 10 Use Cases

        Content

        # Critical Decisions

        Content

        # Investment Priorities

        Content
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertEqual(sections[0].visualizationType, .roiComparison)
        XCTAssertEqual(sections[1].visualizationType, .decisionMatrix)
        XCTAssertEqual(sections[2].visualizationType, .investmentTimeline)
    }

    func testEmptyMarkdown() async throws {
        // Given
        let markdown = ""

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertTrue(sections.isEmpty)
    }

    func testMarkdownWithOnlyText() async throws {
        // Given
        let markdown = """
        Just some text without headers.
        More text.
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertTrue(sections.isEmpty) // No H1 headers = no sections
    }

    func testMetricDetection() async throws {
        // Given
        let markdown = """
        # Test

        ROI: 400%
        Cost: $5M
        Improvement: 3x
        Metrics: 67% reduction
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        let content = sections[0].content
        let metrics = content.filter { $0.type == .metric }

        XCTAssertGreaterThan(metrics.count, 0)
    }

    func testSectionOrdering() async throws {
        // Given
        let markdown = """
        # First Section

        Content

        # Second Section

        Content

        # Third Section

        Content
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        XCTAssertEqual(sections[0].order, 0)
        XCTAssertEqual(sections[1].order, 1)
        XCTAssertEqual(sections[2].order, 2)
    }

    func testContentOrdering() async throws {
        // Given
        let markdown = """
        # Test

        First paragraph.
        Second paragraph.
        Third paragraph.
        """

        // When
        let sections = try await parser.parseContent(markdown)

        // Then
        let content = sections[0].content
        XCTAssertEqual(content[0].order, 0)
        XCTAssertEqual(content[1].order, 1)
        XCTAssertEqual(content[2].order, 2)
    }
}
