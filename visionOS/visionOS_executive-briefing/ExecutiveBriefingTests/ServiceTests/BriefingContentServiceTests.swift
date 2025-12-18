import XCTest
import SwiftData
@testable import ExecutiveBriefing

final class BriefingContentServiceTests: XCTestCase {
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    var service: BriefingContentService!

    override func setUp() async throws {
        let schema = Schema([
            BriefingSection.self,
            ContentBlock.self,
            UseCase.self,
            Metric.self,
            ActionItem.self,
            InvestmentPhase.self,
            ChecklistItem.self,
            UserProgress.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: configuration)
        modelContext = ModelContext(modelContainer)
        service = BriefingContentService(modelContext: modelContext)
    }

    override func tearDown() async throws {
        service = nil
        modelContext = nil
        modelContainer = nil
    }

    func testLoadBriefing() async throws {
        // Given
        let section1 = BriefingSection(title: "Section 1", order: 1, icon: "star")
        let section2 = BriefingSection(title: "Section 2", order: 2, icon: "circle")
        modelContext.insert(section1)
        modelContext.insert(section2)
        try modelContext.save()

        // When
        let sections = try await service.loadBriefing()

        // Then
        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections[0].order, 1)
        XCTAssertEqual(sections[1].order, 2)
    }

    func testGetSection() async throws {
        // Given
        let section = BriefingSection(title: "Test", order: 1, icon: "star")
        modelContext.insert(section)
        try modelContext.save()

        // When
        let fetched = try await service.getSection(id: section.id)

        // Then
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, section.id)
    }

    func testSearchContent() async throws {
        // Given
        let content = ContentBlock(type: .paragraph, content: "AR/VR technology is revolutionary")
        let section = BriefingSection(
            title: "Executive Summary",
            order: 1,
            icon: "star",
            content: [content]
        )
        modelContext.insert(section)
        try modelContext.save()

        // When
        let results = try await service.searchContent(query: "AR/VR")

        // Then
        XCTAssertGreaterThan(results.count, 0)
    }

    func testLoadUseCases() async throws {
        // Given
        let useCase1 = UseCase(title: "Test 1", roi: 400, timeframe: "12m", example: "Ex", order: 0)
        let useCase2 = UseCase(title: "Test 2", roi: 300, timeframe: "12m", example: "Ex", order: 1)
        modelContext.insert(useCase1)
        modelContext.insert(useCase2)
        try modelContext.save()

        // When
        let useCases = try await service.loadUseCases()

        // Then
        XCTAssertEqual(useCases.count, 2)
    }

    func testGetTopUseCasesByROI() async throws {
        // Given
        for i in 0..<15 {
            let useCase = UseCase(
                title: "Test \(i)",
                roi: 100 + (i * 10),
                timeframe: "12m",
                example: "Ex",
                order: i
            )
            modelContext.insert(useCase)
        }
        try modelContext.save()

        // When
        let topCases = try await service.getTopUseCasesByROI(limit: 10)

        // Then
        XCTAssertEqual(topCases.count, 10)
        XCTAssertGreaterThan(topCases[0].roi, topCases[9].roi)
    }

    func testGetActionItemsForRole() async throws {
        // Given
        let ceoItem = ActionItem(role: .ceo, title: "CEO Task", descriptionText: "Test")
        let cfoItem = ActionItem(role: .cfo, title: "CFO Task", descriptionText: "Test")
        modelContext.insert(ceoItem)
        modelContext.insert(cfoItem)
        try modelContext.save()

        // When
        let ceoItems = try await service.getActionItems(for: .ceo)

        // Then
        XCTAssertEqual(ceoItems.count, 1)
        XCTAssertEqual(ceoItems.first?.role, .ceo)
    }

    func testToggleActionItem() async throws {
        // Given
        let item = ActionItem(role: .ceo, title: "Test", descriptionText: "Test")
        modelContext.insert(item)
        try modelContext.save()
        XCTAssertFalse(item.completed)

        // When
        try await service.toggleActionItem(item)

        // Then
        XCTAssertTrue(item.completed)

        // Toggle again
        try await service.toggleActionItem(item)
        XCTAssertFalse(item.completed)
    }

    func testGetUserProgress() async throws {
        // When
        let progress = try await service.getUserProgress()

        // Then
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress.userId, "default")
    }

    func testRecordSectionVisit() async throws {
        // Given
        let sectionId = UUID()

        // When
        try await service.recordSectionVisit(sectionId)

        // Then
        let progress = try await service.getUserProgress()
        XCTAssertTrue(progress.hasVisited(sectionId))
    }

    func testRecordTimeSpent() async throws {
        // When
        try await service.recordTimeSpent(300)

        // Then
        let progress = try await service.getUserProgress()
        XCTAssertEqual(progress.totalTimeSpent, 300)
    }
}
