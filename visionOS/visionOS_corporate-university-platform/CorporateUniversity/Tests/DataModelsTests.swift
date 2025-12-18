//
//  DataModelsTests.swift
//  CorporateUniversityTests
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import XCTest
@testable import CorporateUniversity

final class DataModelsTests: XCTestCase {

    // MARK: - Learner Tests

    func testLearnerInitialization() {
        // Given
        let learner = Learner(
            employeeId: "EMP001",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@company.com",
            department: "Engineering",
            role: "Software Engineer"
        )

        // Then
        XCTAssertEqual(learner.employeeId, "EMP001")
        XCTAssertEqual(learner.firstName, "John")
        XCTAssertEqual(learner.lastName, "Doe")
        XCTAssertEqual(learner.fullName, "John Doe")
        XCTAssertEqual(learner.email, "john.doe@company.com")
        XCTAssertEqual(learner.department, "Engineering")
        XCTAssertEqual(learner.role, "Software Engineer")
        XCTAssertEqual(learner.learningStyle, .multimodal)
        XCTAssertEqual(learner.skillLevel, .beginner)
    }

    func testLearnerFullName() {
        // Given
        let learner = Learner(
            employeeId: "EMP002",
            firstName: "Jane",
            lastName: "Smith",
            email: "jane.smith@company.com",
            department: "Sales",
            role: "Account Manager"
        )

        // Then
        XCTAssertEqual(learner.fullName, "Jane Smith")
    }

    // MARK: - Course Tests

    func testCourseInitialization() {
        // Given
        let course = Course(
            title: "Swift Programming",
            courseDescription: "Learn Swift",
            category: .technology,
            difficulty: .beginner,
            estimatedDuration: 36000
        )

        // Then
        XCTAssertEqual(course.title, "Swift Programming")
        XCTAssertEqual(course.courseDescription, "Learn Swift")
        XCTAssertEqual(course.category, .technology)
        XCTAssertEqual(course.difficulty, .beginner)
        XCTAssertEqual(course.estimatedDuration, 36000)
        XCTAssertEqual(course.modules.count, 0)
        XCTAssertFalse(course.supports3D)
        XCTAssertFalse(course.supportsCollaboration)
    }

    func testCourseSampleData() {
        // Given
        let course = Course.sample

        // Then
        XCTAssertNotNil(course)
        XCTAssertFalse(course.title.isEmpty)
        XCTAssertGreaterThan(course.estimatedDuration, 0)
    }

    // MARK: - CourseEnrollment Tests

    func testCourseEnrollmentInitialization() {
        // Given
        let learnerId = UUID()
        let courseId = UUID()
        let enrollment = CourseEnrollment(
            learnerIdRef: learnerId,
            courseIdRef: courseId
        )

        // Then
        XCTAssertEqual(enrollment.learnerIdRef, learnerId)
        XCTAssertEqual(enrollment.courseIdRef, courseId)
        XCTAssertEqual(enrollment.progressPercentage, 0.0)
        XCTAssertEqual(enrollment.timeSpent, 0)
        XCTAssertEqual(enrollment.status, .active)
        XCTAssertNotNil(enrollment.enrolledAt)
    }

    func testCourseEnrollmentProgress() {
        // Given
        var enrollment = CourseEnrollment(
            learnerIdRef: UUID(),
            courseIdRef: UUID()
        )

        // When
        enrollment.progressPercentage = 50.0
        enrollment.timeSpent = 1800

        // Then
        XCTAssertEqual(enrollment.progressPercentage, 50.0)
        XCTAssertEqual(enrollment.timeSpent, 1800)
    }

    // MARK: - LearningModule Tests

    func testLearningModuleInitialization() {
        // Given
        let module = LearningModule(
            title: "Module 1",
            orderIndex: 0,
            moduleType: .video,
            estimatedDuration: 3600
        )

        // Then
        XCTAssertEqual(module.title, "Module 1")
        XCTAssertEqual(module.orderIndex, 0)
        XCTAssertEqual(module.moduleType, .video)
        XCTAssertEqual(module.estimatedDuration, 3600)
        XCTAssertEqual(module.lessons.count, 0)
        XCTAssertEqual(module.assessments.count, 0)
    }

    // MARK: - Lesson Tests

    func testLessonInitialization() {
        // Given
        let lesson = Lesson(
            title: "Lesson 1",
            content: "Lesson content here",
            orderIndex: 0,
            interactionType: .passive,
            estimatedDuration: 1800
        )

        // Then
        XCTAssertEqual(lesson.title, "Lesson 1")
        XCTAssertEqual(lesson.content, "Lesson content here")
        XCTAssertEqual(lesson.orderIndex, 0)
        XCTAssertEqual(lesson.interactionType, .passive)
        XCTAssertEqual(lesson.estimatedDuration, 1800)
        XCTAssertNil(lesson.videoURL)
        XCTAssertNil(lesson.model3DURL)
    }

    // MARK: - Assessment Tests

    func testAssessmentInitialization() {
        // Given
        let assessment = Assessment(
            title: "Quiz 1",
            assessmentType: .quiz
        )

        // Then
        XCTAssertEqual(assessment.title, "Quiz 1")
        XCTAssertEqual(assessment.assessmentType, .quiz)
        XCTAssertEqual(assessment.passingScore, 70.0)
        XCTAssertNil(assessment.timeLimit)
        XCTAssertEqual(assessment.attemptsAllowed, 3)
        XCTAssertFalse(assessment.isProctored)
    }

    func testAssessmentCustomSettings() {
        // Given
        let assessment = Assessment(
            title: "Final Exam",
            assessmentType: .quiz,
            passingScore: 80.0,
            timeLimit: 3600,
            attemptsAllowed: 1,
            isProctored: true
        )

        // Then
        XCTAssertEqual(assessment.passingScore, 80.0)
        XCTAssertEqual(assessment.timeLimit, 3600)
        XCTAssertEqual(assessment.attemptsAllowed, 1)
        XCTAssertTrue(assessment.isProctored)
    }

    // MARK: - Question Tests

    func testQuestionInitialization() {
        // Given
        let question = Question(
            questionText: "What is 2+2?",
            questionType: .multipleChoice,
            options: ["2", "3", "4", "5"],
            correctAnswer: "4"
        )

        // Then
        XCTAssertEqual(question.questionText, "What is 2+2?")
        XCTAssertEqual(question.questionType, .multipleChoice)
        XCTAssertEqual(question.options.count, 4)
        XCTAssertEqual(question.correctAnswer, "4")
        XCTAssertEqual(question.points, 1.0)
    }

    // MARK: - AssessmentResult Tests

    func testAssessmentResultInitialization() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(1800)

        let result = AssessmentResult(
            id: UUID(),
            enrollmentIdRef: UUID(),
            assessmentId: UUID(),
            attemptNumber: 1,
            score: 85.0,
            passed: true,
            startedAt: startDate,
            submittedAt: endDate,
            timeSpent: 1800
        )

        // Then
        XCTAssertEqual(result.attemptNumber, 1)
        XCTAssertEqual(result.score, 85.0)
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.timeSpent, 1800)
    }

    // MARK: - Achievement Tests

    func testAchievementInitialization() {
        // Given
        let achievement = Achievement(
            title: "First Course Completed",
            achievementDescription: "Complete your first course",
            iconName: "star.fill",
            category: .completion
        )

        // Then
        XCTAssertEqual(achievement.title, "First Course Completed")
        XCTAssertEqual(achievement.iconName, "star.fill")
        XCTAssertEqual(achievement.category, .completion)
        XCTAssertNotNil(achievement.earnedAt)
    }

    // MARK: - LearningProfile Tests

    func testLearningProfileInitialization() {
        // Given
        let learnerId = UUID()
        let profile = LearningProfile(
            learnerIdRef: learnerId
        )

        // Then
        XCTAssertEqual(profile.learnerIdRef, learnerId)
        XCTAssertEqual(profile.learningPace, 2.0)
        XCTAssertEqual(profile.preferredSessionLength, 1800)
        XCTAssertEqual(profile.engagementScore, 0.5)
        XCTAssertEqual(profile.retentionRate, 0.5)
        XCTAssertEqual(profile.skillGrowthRate, 0.5)
    }

    // MARK: - Enum Tests

    func testLearningStyleEnum() {
        let allStyles: [LearningStyle] = [.visual, .auditory, .kinesthetic, .reading, .multimodal]
        XCTAssertEqual(allStyles.count, 5)
    }

    func testSkillLevelEnum() {
        let allLevels: [SkillLevel] = [.beginner, .intermediate, .advanced, .expert]
        XCTAssertEqual(allLevels.count, 4)
    }

    func testCourseCategoryEnum() {
        let allCategories: [CourseCategory] = [.technology, .leadership, .sales, .operations, .compliance, .softSkills]
        XCTAssertEqual(allCategories.count, 6)
    }

    func testDifficultyLevelEnum() {
        let allLevels: [DifficultyLevel] = [.beginner, .intermediate, .advanced, .expert]
        XCTAssertEqual(allLevels.count, 4)
    }
}
