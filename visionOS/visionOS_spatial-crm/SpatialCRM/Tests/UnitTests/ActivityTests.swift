//
//  ActivityTests.swift
//  SpatialCRMTests
//
//  Unit tests for Activity model
//

import Testing
import Foundation
@testable import SpatialCRM

@Suite("Activity Model Tests")
struct ActivityTests {

    @Test("Activity initialization")
    func testActivityInitialization() {
        let scheduledDate = Date()
        let activity = Activity(
            type: .meeting,
            subject: "Product Demo",
            description: "Demonstrate new features",
            scheduledAt: scheduledDate
        )

        #expect(activity.type == .meeting)
        #expect(activity.subject == "Product Demo")
        #expect(activity.activityDescription == "Demonstrate new features")
        #expect(activity.scheduledAt == scheduledDate)
        #expect(activity.isCompleted == false)
    }

    @Test("Activity completion")
    func testActivityCompletion() {
        let activity = Activity(
            type: .call,
            subject: "Follow-up call",
            scheduledAt: Date()
        )

        #expect(activity.isCompleted == false)
        #expect(activity.completedAt == nil)

        activity.complete(outcome: .successful)

        #expect(activity.isCompleted == true)
        #expect(activity.completedAt != nil)
        #expect(activity.outcome == .successful)
        #expect(activity.duration != nil)
    }

    @Test("Overdue detection for pending activities")
    func testOverdueDetection() {
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let activity = Activity(
            type: .task,
            subject: "Complete proposal",
            scheduledAt: pastDate
        )

        #expect(activity.isOverdue == true)
    }

    @Test("Not overdue when completed")
    func testNotOverdueWhenCompleted() {
        let pastDate = Date().addingTimeInterval(-3600)
        let activity = Activity(
            type: .task,
            subject: "Complete proposal",
            scheduledAt: pastDate
        )

        activity.complete(outcome: .successful)

        #expect(activity.isOverdue == false)
    }

    @Test("Activity type icons")
    func testActivityTypeIcons() {
        #expect(ActivityType.call.icon == "phone.fill")
        #expect(ActivityType.meeting.icon == "person.2.fill")
        #expect(ActivityType.email.icon == "envelope.fill")
        #expect(ActivityType.task.icon == "checkmark.circle.fill")
        #expect(ActivityType.note.icon == "note.text")
        #expect(ActivityType.demo.icon == "play.rectangle.fill")
    }

    @Test("Sentiment enumeration and scores")
    func testSentimentScores() {
        #expect(Sentiment.veryPositive.score == 1.0)
        #expect(Sentiment.positive.score == 0.5)
        #expect(Sentiment.neutral.score == 0.0)
        #expect(Sentiment.negative.score == -0.5)
        #expect(Sentiment.veryNegative.score == -1.0)
    }

    @Test("Sentiment emojis")
    func testSentimentEmojis() {
        #expect(Sentiment.veryPositive.emoji == "😄")
        #expect(Sentiment.positive.emoji == "🙂")
        #expect(Sentiment.neutral.emoji == "😐")
        #expect(Sentiment.negative.emoji == "😟")
        #expect(Sentiment.veryNegative.emoji == "😞")
    }

    @Test("Duration formatting")
    func testDurationFormatting() {
        let activity = Activity(
            type: .call,
            subject: "Test call",
            scheduledAt: Date()
        )

        // Simulate 45 minute duration
        activity.duration = 45 * 60

        let formatted = activity.formattedDuration
        #expect(formatted == "45 min")
    }

    @Test("Duration formatting for hours")
    func testDurationFormattingHours() {
        let activity = Activity(
            type: .meeting,
            subject: "Test meeting",
            scheduledAt: Date()
        )

        // Simulate 90 minute duration
        activity.duration = 90 * 60

        let formatted = activity.formattedDuration
        #expect(formatted == "1 hr 30 min")
    }

    @Test("Activity sample data")
    func testSampleData() {
        let sample = Activity.sample

        #expect(sample.type == .meeting)
        #expect(sample.sentiment == .positive)
        #expect(!sample.keyTopics.isEmpty)
    }

    @Test("Activity outcome enumeration")
    func testActivityOutcomes() {
        #expect(ActivityOutcome.successful.rawValue == "successful")
        #expect(ActivityOutcome.unsuccessful.rawValue == "unsuccessful")
        #expect(ActivityOutcome.rescheduled.rawValue == "rescheduled")
        #expect(ActivityOutcome.noAnswer.rawValue == "noAnswer")
        #expect(ActivityOutcome.leftMessage.rawValue == "leftMessage")
    }
}
