//
//  DataModels.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Learner

@Model
class Learner {
    @Attribute(.unique) var id: UUID
    var employeeId: String
    var firstName: String
    var lastName: String
    var email: String
    var department: String
    var role: String
    var avatarURL: URL?

    // Learning Profile
    var learningStyle: LearningStyle
    var skillLevel: SkillLevel

    // Relationships
    @Relationship(deleteRule: .cascade) var enrollments: [CourseEnrollment]
    @Relationship(deleteRule: .cascade) var achievements: [Achievement]
    @Relationship(deleteRule: .nullify) var learningProfile: LearningProfile?

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date?

    init(
        id: UUID = UUID(),
        employeeId: String,
        firstName: String,
        lastName: String,
        email: String,
        department: String,
        role: String,
        avatarURL: URL? = nil,
        learningStyle: LearningStyle = .multimodal,
        skillLevel: SkillLevel = .beginner,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.employeeId = employeeId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.department = department
        self.role = role
        self.avatarURL = avatarURL
        self.learningStyle = learningStyle
        self.skillLevel = skillLevel
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.enrollments = []
        self.achievements = []
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

enum LearningStyle: String, Codable {
    case visual, auditory, kinesthetic, reading, multimodal
}

enum SkillLevel: String, Codable {
    case beginner, intermediate, advanced, expert
}

// MARK: - Course

@Model
class Course: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var title: String
    var courseDescription: String
    var category: CourseCategory
    var difficulty: DifficultyLevel

    // Content Structure
    @Relationship(deleteRule: .cascade) var modules: [LearningModule]
    var estimatedDuration: TimeInterval

    // Spatial Content
    var environmentType: EnvironmentType
    var immersionLevel: ImmersionLevel
    var supports3D: Bool
    var supportsCollaboration: Bool

    // Metadata
    var tags: [String]
    var thumbnailURL: URL?
    var contentVersion: String
    var publishedAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        courseDescription: String,
        category: CourseCategory,
        difficulty: DifficultyLevel,
        estimatedDuration: TimeInterval,
        environmentType: EnvironmentType = .classroom,
        immersionLevel: ImmersionLevel = .window,
        supports3D: Bool = false,
        supportsCollaboration: Bool = false,
        tags: [String] = [],
        thumbnailURL: URL? = nil,
        contentVersion: String = "1.0",
        publishedAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.courseDescription = courseDescription
        self.category = category
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.environmentType = environmentType
        self.immersionLevel = immersionLevel
        self.supports3D = supports3D
        self.supportsCollaboration = supportsCollaboration
        self.tags = tags
        self.thumbnailURL = thumbnailURL
        self.contentVersion = contentVersion
        self.publishedAt = publishedAt
        self.updatedAt = updatedAt
        self.modules = []
    }
}

enum CourseCategory: String, Codable, Sendable {
    case technology, leadership, sales, operations, compliance, softSkills
}

enum DifficultyLevel: String, Codable, Sendable {
    case beginner, intermediate, advanced, expert
}

enum EnvironmentType: String, Codable {
    case classroom, factory, office, laboratory, outdoors, custom
}

enum ImmersionLevel: String, Codable {
    case window, volume, mixed, progressive, full
}

// MARK: - Learning Module

@Model
class LearningModule: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var title: String
    var moduleDescription: String
    var orderIndex: Int
    var moduleType: ModuleType

    // Relationships
    @Relationship(deleteRule: .cascade) var lessons: [Lesson]
    @Relationship(deleteRule: .cascade) var assessments: [Assessment]

    var estimatedDuration: TimeInterval

    init(
        id: UUID = UUID(),
        title: String,
        moduleDescription: String = "",
        orderIndex: Int,
        moduleType: ModuleType,
        estimatedDuration: TimeInterval
    ) {
        self.id = id
        self.title = title
        self.moduleDescription = moduleDescription
        self.orderIndex = orderIndex
        self.moduleType = moduleType
        self.estimatedDuration = estimatedDuration
        self.lessons = []
        self.assessments = []
    }
}

enum ModuleType: String, Codable {
    case video, interactive, simulation, assessment, collaboration
}

// MARK: - Lesson

@Model
class Lesson {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var orderIndex: Int
    var contentType: ContentType

    // Content Assets
    var videoURL: URL?
    var model3DURL: URL?
    var interactiveContentURL: URL?

    // Spatial Configuration
    var spatialLayoutData: Data? // Encoded SpatialLayout
    var interactionType: InteractionType

    var estimatedDuration: TimeInterval

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        orderIndex: Int,
        contentType: ContentType = .text,
        videoURL: URL? = nil,
        model3DURL: URL? = nil,
        interactiveContentURL: URL? = nil,
        interactionType: InteractionType = .passive,
        estimatedDuration: TimeInterval
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.orderIndex = orderIndex
        self.contentType = contentType
        self.videoURL = videoURL
        self.model3DURL = model3DURL
        self.interactiveContentURL = interactiveContentURL
        self.interactionType = interactionType
        self.estimatedDuration = estimatedDuration
    }
}

enum ContentType: String, Codable {
    case video, text, quiz, simulation, interactive
}

enum InteractionType: String, Codable {
    case passive, interactive, simulation, collaborative
}

// MARK: - Course Enrollment

@Model
class CourseEnrollment: @unchecked Sendable {
    @Attribute(.unique) var id: UUID

    var learnerIdRef: UUID // Reference to Learner
    var courseIdRef: UUID // Reference to Course

    var enrolledAt: Date
    var startedAt: Date?
    var completedAt: Date?

    var progressPercentage: Double
    var currentModuleId: UUID?
    var timeSpent: TimeInterval

    @Relationship(deleteRule: .cascade) var moduleProgress: [ModuleProgress]
    @Relationship(deleteRule: .cascade) var assessmentResults: [AssessmentResult]

    var status: EnrollmentStatus

    init(
        id: UUID = UUID(),
        learnerIdRef: UUID,
        courseIdRef: UUID,
        enrolledAt: Date = Date(),
        progressPercentage: Double = 0.0,
        timeSpent: TimeInterval = 0,
        status: EnrollmentStatus = .active
    ) {
        self.id = id
        self.learnerIdRef = learnerIdRef
        self.courseIdRef = courseIdRef
        self.enrolledAt = enrolledAt
        self.progressPercentage = progressPercentage
        self.timeSpent = timeSpent
        self.status = status
        self.moduleProgress = []
        self.assessmentResults = []
    }
}

enum EnrollmentStatus: String, Codable {
    case active, completed, dropped, suspended
}

// MARK: - Module Progress

@Model
class ModuleProgress {
    @Attribute(.unique) var id: UUID

    var enrollmentIdRef: UUID
    var moduleId: UUID

    var startedAt: Date?
    var completedAt: Date?
    var progressPercentage: Double
    var lessonsCompleted: [UUID]

    var status: ProgressStatus

    init(
        id: UUID = UUID(),
        enrollmentIdRef: UUID,
        moduleId: UUID,
        progressPercentage: Double = 0.0,
        status: ProgressStatus = .notStarted
    ) {
        self.id = id
        self.enrollmentIdRef = enrollmentIdRef
        self.moduleId = moduleId
        self.progressPercentage = progressPercentage
        self.status = status
        self.lessonsCompleted = []
    }
}

enum ProgressStatus: String, Codable {
    case notStarted, inProgress, completed
}

// MARK: - Assessment

@Model
class Assessment {
    @Attribute(.unique) var id: UUID
    var title: String
    var assessmentDescription: String
    var assessmentType: AssessmentType

    @Relationship(deleteRule: .cascade) var questions: [Question]

    var passingScore: Double
    var timeLimit: TimeInterval?
    var attemptsAllowed: Int
    var isProctored: Bool

    init(
        id: UUID = UUID(),
        title: String,
        assessmentDescription: String = "",
        assessmentType: AssessmentType,
        passingScore: Double = 70.0,
        timeLimit: TimeInterval? = nil,
        attemptsAllowed: Int = 3,
        isProctored: Bool = false
    ) {
        self.id = id
        self.title = title
        self.assessmentDescription = assessmentDescription
        self.assessmentType = assessmentType
        self.passingScore = passingScore
        self.timeLimit = timeLimit
        self.attemptsAllowed = attemptsAllowed
        self.isProctored = isProctored
        self.questions = []
    }
}

enum AssessmentType: String, Codable {
    case quiz, practicalSkill, simulation, peerReview, project
}

// MARK: - Question

@Model
class Question {
    @Attribute(.unique) var id: UUID
    var questionText: String
    var questionType: QuestionType
    var options: [String] // For multiple choice
    var correctAnswer: String
    var points: Double

    init(
        id: UUID = UUID(),
        questionText: String,
        questionType: QuestionType,
        options: [String] = [],
        correctAnswer: String,
        points: Double = 1.0
    ) {
        self.id = id
        self.questionText = questionText
        self.questionType = questionType
        self.options = options
        self.correctAnswer = correctAnswer
        self.points = points
    }
}

enum QuestionType: String, Codable {
    case multipleChoice, trueFalse, shortAnswer, essay, practical
}

// MARK: - Assessment Result

@Model
class AssessmentResult {
    @Attribute(.unique) var id: UUID

    var enrollmentIdRef: UUID
    var assessmentId: UUID

    var attemptNumber: Int
    var score: Double
    var passed: Bool

    var startedAt: Date
    var submittedAt: Date
    var timeSpent: TimeInterval

    @Relationship(deleteRule: .cascade) var answers: [QuestionAnswer]

    init(
        id: UUID = UUID(),
        enrollmentIdRef: UUID,
        assessmentId: UUID,
        attemptNumber: Int,
        score: Double,
        passed: Bool,
        startedAt: Date,
        submittedAt: Date,
        timeSpent: TimeInterval
    ) {
        self.id = id
        self.enrollmentIdRef = enrollmentIdRef
        self.assessmentId = assessmentId
        self.attemptNumber = attemptNumber
        self.score = score
        self.passed = passed
        self.startedAt = startedAt
        self.submittedAt = submittedAt
        self.timeSpent = timeSpent
        self.answers = []
    }
}

// MARK: - Question Answer

@Model
class QuestionAnswer {
    @Attribute(.unique) var id: UUID
    var questionId: UUID
    var userAnswer: String
    var isCorrect: Bool
    var pointsEarned: Double

    init(
        id: UUID = UUID(),
        questionId: UUID,
        userAnswer: String,
        isCorrect: Bool,
        pointsEarned: Double
    ) {
        self.id = id
        self.questionId = questionId
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.pointsEarned = pointsEarned
    }
}

// MARK: - Achievement

@Model
class Achievement {
    @Attribute(.unique) var id: UUID
    var title: String
    var achievementDescription: String
    var iconName: String
    var category: AchievementCategory
    var earnedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        achievementDescription: String,
        iconName: String,
        category: AchievementCategory,
        earnedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = achievementDescription
        self.iconName = iconName
        self.category = category
        self.earnedAt = earnedAt
    }
}

enum AchievementCategory: String, Codable {
    case completion, streak, speed, mastery, collaboration, innovation
}

// MARK: - Learning Profile

@Model
class LearningProfile {
    @Attribute(.unique) var id: UUID

    var learnerIdRef: UUID

    // AI-Generated Insights
    var learningPace: Double // lessons per week
    var preferredSessionLength: TimeInterval
    var strengthAreas: [String]
    var improvementAreas: [String]

    // Personalization
    var recommendedCourses: [UUID]

    // Analytics
    var engagementScore: Double
    var retentionRate: Double
    var skillGrowthRate: Double

    var lastAnalyzedAt: Date

    init(
        id: UUID = UUID(),
        learnerIdRef: UUID,
        learningPace: Double = 2.0,
        preferredSessionLength: TimeInterval = 1800,
        strengthAreas: [String] = [],
        improvementAreas: [String] = [],
        recommendedCourses: [UUID] = [],
        engagementScore: Double = 0.5,
        retentionRate: Double = 0.5,
        skillGrowthRate: Double = 0.5,
        lastAnalyzedAt: Date = Date()
    ) {
        self.id = id
        self.learnerIdRef = learnerIdRef
        self.learningPace = learningPace
        self.preferredSessionLength = preferredSessionLength
        self.strengthAreas = strengthAreas
        self.improvementAreas = improvementAreas
        self.recommendedCourses = recommendedCourses
        self.engagementScore = engagementScore
        self.retentionRate = retentionRate
        self.skillGrowthRate = skillGrowthRate
        self.lastAnalyzedAt = lastAnalyzedAt
    }
}

// MARK: - Sample Data Extensions

extension Learner {
    static var sample: Learner {
        Learner(
            employeeId: "EMP001",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@company.com",
            department: "Engineering",
            role: "Software Engineer"
        )
    }
}

extension Course {
    static var sample: Course {
        Course(
            title: "Introduction to Swift Programming",
            courseDescription: "Learn the basics of Swift programming language with hands-on exercises.",
            category: .technology,
            difficulty: .beginner,
            estimatedDuration: 36000, // 10 hours
            supports3D: true,
            supportsCollaboration: true,
            tags: ["Swift", "Programming", "iOS"]
        )
    }
}

extension LearningModule {
    static var sample: LearningModule {
        LearningModule(
            title: "Module 1: Swift Basics",
            moduleDescription: "Introduction to Swift syntax and fundamental concepts.",
            orderIndex: 0,
            moduleType: .video,
            estimatedDuration: 3600 // 1 hour
        )
    }
}

extension Lesson {
    static var sample: Lesson {
        Lesson(
            title: "Lesson 1: Variables and Constants",
            content: "Learn about variables, constants, and data types in Swift.",
            orderIndex: 0,
            interactionType: .interactive,
            estimatedDuration: 1800 // 30 minutes
        )
    }
}
