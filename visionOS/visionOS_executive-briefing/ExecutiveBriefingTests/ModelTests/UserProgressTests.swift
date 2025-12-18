import XCTest
import SwiftData
@testable import ExecutiveBriefing

final class UserProgressTests: XCTestCase {
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([UserProgress.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: configuration)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    func testUserProgressInitialization() {
        // Given
        let progress = UserProgress()

        // Then
        XCTAssertNotNil(progress.id)
        XCTAssertEqual(progress.userId, "default")
        XCTAssertTrue(progress.visitedSectionIds.isEmpty)
        XCTAssertTrue(progress.completedActionItemIds.isEmpty)
        XCTAssertEqual(progress.totalTimeSpent, 0)
        XCTAssertTrue(progress.favoriteSectionIds.isEmpty)
    }

    func testVisitSection() {
        // Given
        let progress = UserProgress()
        let sectionId = UUID()

        // When
        progress.visitSection(sectionId)

        // Then
        XCTAssertTrue(progress.hasVisited(sectionId))
        XCTAssertEqual(progress.visitedSectionIds.count, 1)

        // Visit again - should not duplicate
        progress.visitSection(sectionId)
        XCTAssertEqual(progress.visitedSectionIds.count, 1)
    }

    func testCompleteActionItem() {
        // Given
        let progress = UserProgress()
        let actionItemId = UUID()

        // When
        progress.completeActionItem(actionItemId)

        // Then
        XCTAssertTrue(progress.isActionItemCompleted(actionItemId))
        XCTAssertEqual(progress.completedActionItemIds.count, 1)
    }

    func testUncompleteActionItem() {
        // Given
        let progress = UserProgress()
        let actionItemId = UUID()
        progress.completeActionItem(actionItemId)

        // When
        progress.uncompleteActionItem(actionItemId)

        // Then
        XCTAssertFalse(progress.isActionItemCompleted(actionItemId))
        XCTAssertTrue(progress.completedActionItemIds.isEmpty)
    }

    func testAddTimeSpent() {
        // Given
        let progress = UserProgress()

        // When
        progress.addTimeSpent(300) // 5 minutes
        progress.addTimeSpent(600) // 10 minutes

        // Then
        XCTAssertEqual(progress.totalTimeSpent, 900) // 15 minutes
    }

    func testFormattedTimeSpent() {
        // Given
        let progress = UserProgress()

        // Test minutes only
        progress.addTimeSpent(600) // 10 minutes
        XCTAssertEqual(progress.formattedTimeSpent, "10m")

        // Test hours and minutes
        progress.addTimeSpent(4200) // Add 70 more minutes (total 80 minutes = 1h 20m)
        XCTAssertEqual(progress.formattedTimeSpent, "1h 20m")
    }

    func testToggleFavorite() {
        // Given
        let progress = UserProgress()
        let sectionId = UUID()

        // When - add favorite
        progress.toggleFavorite(sectionId)

        // Then
        XCTAssertTrue(progress.isFavorite(sectionId))

        // When - remove favorite
        progress.toggleFavorite(sectionId)

        // Then
        XCTAssertFalse(progress.isFavorite(sectionId))
    }

    func testReadingProgress() {
        // Given
        let progress = UserProgress()
        let totalSections = 10

        // When - no sections visited
        var percentage = progress.readingProgress(totalSections: totalSections)

        // Then
        XCTAssertEqual(percentage, 0)

        // When - 5 sections visited
        for _ in 0..<5 {
            progress.visitSection(UUID())
        }
        percentage = progress.readingProgress(totalSections: totalSections)

        // Then
        XCTAssertEqual(percentage, 50)

        // When - all sections visited
        for _ in 0..<5 {
            progress.visitSection(UUID())
        }
        percentage = progress.readingProgress(totalSections: totalSections)

        // Then
        XCTAssertEqual(percentage, 100)
    }

    func testReadingProgressWithZeroSections() {
        // Given
        let progress = UserProgress()

        // When
        let percentage = progress.readingProgress(totalSections: 0)

        // Then
        XCTAssertEqual(percentage, 0)
    }

    func testUserProgressPersistence() async throws {
        // Given
        let progress = UserProgress(userId: "test-user")
        progress.visitSection(UUID())
        progress.addTimeSpent(300)

        // When
        modelContext.insert(progress)
        try modelContext.save()

        // Then
        let fetchDescriptor = FetchDescriptor<UserProgress>()
        let fetchedProgress = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(fetchedProgress.count, 1)
        XCTAssertEqual(fetchedProgress.first?.userId, "test-user")
        XCTAssertEqual(fetchedProgress.first?.visitedSectionIds.count, 1)
    }
}
