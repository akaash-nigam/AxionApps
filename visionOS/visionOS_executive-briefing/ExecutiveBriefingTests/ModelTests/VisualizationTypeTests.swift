import XCTest
@testable import ExecutiveBriefing

final class VisualizationTypeTests: XCTestCase {
    func testVisualizationTypeDisplayNames() {
        XCTAssertEqual(VisualizationType.roiComparison.displayName, "ROI Comparison")
        XCTAssertEqual(VisualizationType.decisionMatrix.displayName, "Decision Matrix")
        XCTAssertEqual(VisualizationType.investmentTimeline.displayName, "Investment Timeline")
        XCTAssertEqual(VisualizationType.riskOpportunityMatrix.displayName, "Risk/Opportunity Matrix")
        XCTAssertEqual(VisualizationType.competitivePositioning.displayName, "Competitive Positioning")
    }

    func testVisualizationTypeIcons() {
        // Verify all types have icons
        for vizType in VisualizationType.allCases {
            XCTAssertFalse(vizType.icon.isEmpty)
        }

        // Test specific icons
        XCTAssertEqual(VisualizationType.roiComparison.icon, "chart.bar.fill")
        XCTAssertEqual(VisualizationType.decisionMatrix.icon, "square.grid.2x2.fill")
    }

    func testVisualizationTypeDescriptions() {
        // Verify all types have descriptions
        for vizType in VisualizationType.allCases {
            XCTAssertFalse(vizType.description.isEmpty)
        }
    }

    func testVisualizationTypeDimensions() {
        // Test ROI comparison dimensions
        let roiDimensions = VisualizationType.roiComparison.suggestedDimensions
        XCTAssertEqual(roiDimensions.width, 600)
        XCTAssertEqual(roiDimensions.height, 600)
        XCTAssertEqual(roiDimensions.depth, 600)

        // Test decision matrix dimensions
        let matrixDimensions = VisualizationType.decisionMatrix.suggestedDimensions
        XCTAssertEqual(matrixDimensions.width, 700)
        XCTAssertEqual(matrixDimensions.height, 500)
        XCTAssertEqual(matrixDimensions.depth, 500)

        // Test timeline dimensions
        let timelineDimensions = VisualizationType.investmentTimeline.suggestedDimensions
        XCTAssertEqual(timelineDimensions.width, 800)
        XCTAssertEqual(timelineDimensions.height, 400)
        XCTAssertEqual(timelineDimensions.depth, 400)
    }

    func testVisualizationTypeAccessibilityLabels() {
        // Verify all types have accessibility labels
        for vizType in VisualizationType.allCases {
            XCTAssertFalse(vizType.accessibilityLabel.isEmpty)
            XCTAssertTrue(vizType.accessibilityLabel.contains("visualization"))
        }
    }

    func testVisualizationTypeIdentifiable() {
        // Test that each type has a unique ID
        let types = VisualizationType.allCases
        let ids = types.map { $0.id }
        let uniqueIds = Set(ids)

        XCTAssertEqual(ids.count, uniqueIds.count)
    }

    func testVisualizationTypeCodable() throws {
        // Test encoding
        let vizType = VisualizationType.roiComparison
        let encoder = JSONEncoder()
        let data = try encoder.encode(vizType)

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(VisualizationType.self, from: data)

        XCTAssertEqual(vizType, decoded)
    }

    func testAllCases() {
        // Verify we have all expected visualization types
        XCTAssertEqual(VisualizationType.allCases.count, 5)

        let types = VisualizationType.allCases
        XCTAssertTrue(types.contains(.roiComparison))
        XCTAssertTrue(types.contains(.decisionMatrix))
        XCTAssertTrue(types.contains(.investmentTimeline))
        XCTAssertTrue(types.contains(.riskOpportunityMatrix))
        XCTAssertTrue(types.contains(.competitivePositioning))
    }
}
