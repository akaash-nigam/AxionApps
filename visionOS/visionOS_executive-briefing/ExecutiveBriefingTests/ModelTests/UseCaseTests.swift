import XCTest
import SwiftData
import simd
@testable import ExecutiveBriefing

final class UseCaseTests: XCTestCase {
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([
            UseCase.self,
            Metric.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: configuration)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    func testUseCaseInitialization() {
        // Given
        let useCase = UseCase(
            title: "Remote Expert Assistance",
            roi: 400,
            timeframe: "12 months",
            example: "Mercedes-Benz"
        )

        // Then
        XCTAssertNotNil(useCase.id)
        XCTAssertEqual(useCase.title, "Remote Expert Assistance")
        XCTAssertEqual(useCase.roi, 400)
        XCTAssertEqual(useCase.timeframe, "12 months")
        XCTAssertEqual(useCase.example, "Mercedes-Benz")
        XCTAssertTrue(useCase.metrics.isEmpty)
    }

    func testUseCaseROICategory() {
        // Given
        let exceptionalCase = UseCase(title: "Test", roi: 450, timeframe: "12m", example: "Ex")
        let highCase = UseCase(title: "Test", roi: 350, timeframe: "12m", example: "Ex")
        let mediumCase = UseCase(title: "Test", roi: 250, timeframe: "12m", example: "Ex")
        let standardCase = UseCase(title: "Test", roi: 150, timeframe: "12m", example: "Ex")

        // Then
        XCTAssertEqual(exceptionalCase.roiCategory, .exceptional)
        XCTAssertEqual(highCase.roiCategory, .high)
        XCTAssertEqual(mediumCase.roiCategory, .medium)
        XCTAssertEqual(standardCase.roiCategory, .standard)
    }

    func testUseCasePosition3D() {
        // Given
        var useCase = UseCase(
            title: "Test",
            roi: 400,
            timeframe: "12m",
            example: "Ex"
        )

        // When
        useCase.position3D = SIMD3<Float>(100, 200, 300)

        // Then
        XCTAssertNotNil(useCase.position3D)
        XCTAssertEqual(useCase.position3D?.x, 100)
        XCTAssertEqual(useCase.position3D?.y, 200)
        XCTAssertEqual(useCase.position3D?.z, 300)
        XCTAssertEqual(useCase.position3DX, 100)
        XCTAssertEqual(useCase.position3DY, 200)
        XCTAssertEqual(useCase.position3DZ, 300)
    }

    func testUseCaseAccessibilityDescription() {
        // Given
        let useCase = UseCase(
            title: "Remote Expert Assistance",
            roi: 400,
            timeframe: "12 months",
            example: "Mercedes-Benz"
        )

        // When
        let description = useCase.accessibilityDescription

        // Then
        XCTAssertEqual(description, "Remote Expert Assistance, ROI: 400% in 12 months")
    }

    func testUseCaseWithMetrics() async throws {
        // Given
        let metric1 = Metric(label: "Cost Reduction", value: "67%")
        let metric2 = Metric(label: "Time Saved", value: "50%")

        let useCase = UseCase(
            title: "Test",
            roi: 400,
            timeframe: "12m",
            metrics: [metric1, metric2],
            example: "Ex"
        )

        // When
        modelContext.insert(useCase)
        try modelContext.save()

        // Then
        XCTAssertEqual(useCase.metrics.count, 2)

        let fetchDescriptor = FetchDescriptor<UseCase>()
        let fetchedCases = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedCases.first?.metrics.count, 2)
    }

    func testROICategoryColors() {
        // Test color name mapping
        XCTAssertEqual(ROICategory.exceptional.colorName, "green")
        XCTAssertEqual(ROICategory.high.colorName, "blue")
        XCTAssertEqual(ROICategory.medium.colorName, "orange")
        XCTAssertEqual(ROICategory.standard.colorName, "gray")
    }
}
