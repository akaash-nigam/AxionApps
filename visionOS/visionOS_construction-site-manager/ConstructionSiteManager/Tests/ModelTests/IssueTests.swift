//
//  IssueTests.swift
//  Construction Site Manager Tests
//
//  Unit tests for Issue models
//

import Testing
import Foundation
@testable import ConstructionSiteManager

@Suite("Issue Model Tests")
struct IssueTests {

    @Test("Issue initializes correctly")
    func testIssueInitialization() {
        // Arrange
        let title = "Electrical conduit conflict"
        let description = "Conduit conflicts with duct"
        let dueDate = Date().addingTimeInterval(86400 * 7)  // 7 days from now

        // Act
        let issue = Issue(
            title: title,
            description: description,
            type: .coordination,
            priority: .high,
            assignedTo: "John Doe",
            reporter: "Jane Smith",
            dueDate: dueDate
        )

        // Assert
        #expect(issue.title == title)
        #expect(issue.issueDescription == description)
        #expect(issue.type == .coordination)
        #expect(issue.priority == .high)
        #expect(issue.status == .open)
        #expect(issue.assignedTo == "John Doe")
        #expect(issue.reporter == "Jane Smith")
    }

    @Test("Issue position getter and setter")
    func testIssuePosition() {
        // Arrange
        let position = SIMD3<Float>(10, 5, 8)
        let dueDate = Date().addingTimeInterval(86400)

        // Act
        let issue = Issue(
            title: "Test",
            description: "Test",
            type: .quality,
            priority: .medium,
            position: position,
            assignedTo: "Test",
            reporter: "Test",
            dueDate: dueDate
        )

        // Assert
        #expect(issue.position == position)
        #expect(issue.positionX == 10)
        #expect(issue.positionY == 5)
        #expect(issue.positionZ == 8)
    }

    @Test("Issue overdue detection - not overdue")
    func testIssueNotOverdue() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 7)  // 7 days from now
        let issue = Issue(
            title: "Future issue",
            description: "Not due yet",
            type: .quality,
            priority: .low,
            assignedTo: "Test",
            reporter: "Test",
            dueDate: futureDate
        )

        // Assert
        #expect(!issue.isOverdue)
    }

    @Test("Issue overdue detection - is overdue")
    func testIssueIsOverdue() {
        // Arrange
        let pastDate = Date().addingTimeInterval(-86400)  // 1 day ago
        let issue = Issue(
            title: "Past issue",
            description: "Already due",
            type: .safety,
            priority: .critical,
            assignedTo: "Test",
            reporter: "Test",
            dueDate: pastDate
        )

        // Assert
        #expect(issue.isOverdue)
    }

    @Test("Issue days until due calculation")
    func testDaysUntilDue() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 5)  // 5 days from now
        let issue = Issue(
            title: "Test",
            description: "Test",
            type: .coordination,
            priority: .medium,
            assignedTo: "Test",
            reporter: "Test",
            dueDate: futureDate
        )

        // Act
        let daysUntilDue = issue.daysUntilDue

        // Assert
        #expect(daysUntilDue >= 4 && daysUntilDue <= 5)  // Allow for time precision
    }

    @Test("Issue priority ordering")
    func testIssuePriorityOrdering() {
        #expect(IssuePriority.low < IssuePriority.medium)
        #expect(IssuePriority.medium < IssuePriority.high)
        #expect(IssuePriority.high < IssuePriority.critical)
    }

    @Test("Issue status colors")
    func testIssueStatusColors() {
        #expect(IssueStatus.open.displayName == "Open")
        #expect(IssueStatus.closed.displayName == "Closed")
        #expect(IssueStatus.resolved.displayName == "Resolved")
    }

    @Test("Issue type icons exist")
    func testIssueTypeIcons() {
        for issueType in IssueType.allCases {
            let icon = issueType.icon
            #expect(!icon.isEmpty)
        }
    }

    @Test("Issue with related elements")
    func testIssueRelatedElements() {
        // Arrange
        let elementIDs = ["elem-1", "elem-2", "elem-3"]
        let dueDate = Date().addingTimeInterval(86400)

        // Act
        let issue = Issue(
            title: "Multi-element issue",
            description: "Affects multiple elements",
            type: .coordination,
            priority: .high,
            relatedElementIDs: elementIDs,
            assignedTo: "Test",
            reporter: "Test",
            dueDate: dueDate
        )

        // Assert
        #expect(issue.relatedElementIDs.count == 3)
        #expect(issue.relatedElementIDs.contains("elem-1"))
        #expect(issue.relatedElementIDs.contains("elem-2"))
        #expect(issue.relatedElementIDs.contains("elem-3"))
    }

    @Test("Issue with cost and schedule impact")
    func testIssueWithImpacts() {
        // Arrange
        let costImpact = 15000.0
        let scheduleImpact: TimeInterval = 86400 * 3  // 3 days
        let dueDate = Date().addingTimeInterval(86400)

        // Act
        let issue = Issue(
            title: "High impact issue",
            description: "Significant impact",
            type: .design,
            priority: .critical,
            assignedTo: "Test",
            reporter: "Test",
            dueDate: dueDate,
            costImpact: costImpact,
            scheduleImpact: scheduleImpact
        )

        // Assert
        #expect(issue.costImpact == costImpact)
        #expect(issue.scheduleImpact == scheduleImpact)
    }
}

@Suite("Issue Comment Tests")
struct IssueCommentTests {

    @Test("Comment initialization")
    func testCommentInit() {
        // Arrange & Act
        let comment = IssueComment(
            text: "This needs immediate attention",
            author: "John Doe"
        )

        // Assert
        #expect(comment.text == "This needs immediate attention")
        #expect(comment.author == "John Doe")
        #expect(comment.photoURLs.isEmpty)
    }

    @Test("Comment with photos")
    func testCommentWithPhotos() {
        // Arrange
        let photoURLs = ["photo1.jpg", "photo2.jpg"]

        // Act
        let comment = IssueComment(
            text: "See attached photos",
            author: "Jane Smith",
            photoURLs: photoURLs
        )

        // Assert
        #expect(comment.photoURLs.count == 2)
        #expect(comment.photoURLs.contains("photo1.jpg"))
    }
}

@Suite("Annotation Tests")
struct AnnotationTests {

    @Test("Annotation initialization")
    func testAnnotationInit() {
        // Arrange
        let position = SIMD3<Float>(5, 2, 3)

        // Act
        let annotation = Annotation(
            type: .note,
            text: "Check this area",
            author: "Inspector",
            position: position
        )

        // Assert
        #expect(annotation.type == .note)
        #expect(annotation.text == "Check this area")
        #expect(annotation.author == "Inspector")
        #expect(annotation.position == position)
        #expect(annotation.status == .active)
    }

    @Test("Annotation with assignment")
    func testAnnotationAssignment() {
        // Arrange
        let position = SIMD3<Float>(1, 2, 3)

        // Act
        let annotation = Annotation(
            type: .issue,
            text: "Fix this",
            author: "Manager",
            position: position,
            assignedTo: "Worker A"
        )

        // Assert
        #expect(annotation.assignedTo == "Worker A")
    }

    @Test("Annotation types have icons")
    func testAnnotationTypeIcons() {
        #expect(AnnotationType.note.icon == "note.text")
        #expect(AnnotationType.issue.icon == "exclamationmark.triangle")
        #expect(AnnotationType.measurement.icon == "ruler")
        #expect(AnnotationType.photo.icon == "camera")
        #expect(AnnotationType.voice.icon == "mic")
    }

    @Test("Annotation status transitions")
    func testAnnotationStatusTransitions() {
        // Arrange
        var annotation = Annotation(
            type: .issue,
            text: "Problem",
            author: "User",
            position: SIMD3<Float>(0, 0, 0)
        )

        // Assert initial status
        #expect(annotation.status == .active)

        // Act - resolve
        annotation.status = .resolved

        // Assert
        #expect(annotation.status == .resolved)
        #expect(annotation.status.displayName == "Resolved")
    }
}
