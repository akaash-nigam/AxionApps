//
//  LearningService.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import Foundation

/// Service for learning-related operations
@Observable
class LearningService: @unchecked Sendable {
    // MARK: - Properties

    private let networkClient: NetworkClient
    private let cacheManager: CacheManager

    // MARK: - Initialization

    init(networkClient: NetworkClient, cacheManager: CacheManager) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
    }

    // MARK: - Course Management

    /// Fetch available courses
    nonisolated func fetchCourses(filter: CourseFilter) async throws -> [Course] {
        // Check cache first
        if let cached = await cacheManager.getCourses(filter: filter) {
            return cached
        }

        // For demo purposes, return mock data
        // In production, this would call: networkClient.request(endpoint: .courses(filter: filter), responseType: [Course].self)

        let mockCourses = [
            Course(
                title: "Swift Programming Fundamentals",
                courseDescription: "Learn the basics of Swift programming with hands-on exercises and real-world projects.",
                category: .technology,
                difficulty: .beginner,
                estimatedDuration: 36000, // 10 hours
                supports3D: true,
                supportsCollaboration: true,
                tags: ["Swift", "iOS", "Programming"]
            ),
            Course(
                title: "Leadership in the Digital Age",
                courseDescription: "Develop leadership skills for managing teams in modern organizations.",
                category: .leadership,
                difficulty: .intermediate,
                estimatedDuration: 28800, // 8 hours
                supports3D: false,
                supportsCollaboration: true,
                tags: ["Leadership", "Management"]
            ),
            Course(
                title: "Advanced Sales Techniques",
                courseDescription: "Master advanced sales strategies and customer relationship management.",
                category: .sales,
                difficulty: .advanced,
                estimatedDuration: 21600, // 6 hours
                supports3D: true,
                supportsCollaboration: false,
                tags: ["Sales", "CRM"]
            ),
            Course(
                title: "Manufacturing Process Optimization",
                courseDescription: "Learn to optimize manufacturing processes using data-driven approaches.",
                category: .operations,
                difficulty: .expert,
                estimatedDuration: 43200, // 12 hours
                environmentType: .factory,
                supports3D: true,
                supportsCollaboration: true,
                tags: ["Manufacturing", "Operations", "Six Sigma"]
            )
        ]

        // Store in cache
        await cacheManager.storeCourses(mockCourses, filter: filter)

        return mockCourses
    }

    /// Fetch course details
    nonisolated func fetchCourseDetail(courseId: UUID) async throws -> Course {
        // In production: networkClient.request(endpoint: .courseDetail(id: courseId), responseType: Course.self)
        return Course.sample
    }

    /// Enroll in a course
    nonisolated func enrollInCourse(learnerId: UUID, courseId: UUID) async throws -> CourseEnrollment {
        // In production: networkClient.request(endpoint: .enroll(...), method: .post, responseType: CourseEnrollment.self)

        let enrollment = CourseEnrollment(
            learnerIdRef: learnerId,
            courseIdRef: courseId,
            enrolledAt: Date()
        )

        return enrollment
    }

    /// Fetch user enrollments
    nonisolated func fetchEnrollments(userId: UUID) async throws -> [CourseEnrollment] {
        // In production: networkClient.request(endpoint: .enrollments(userId: userId), responseType: [CourseEnrollment].self)

        // Return mock data
        return [
            CourseEnrollment(
                learnerIdRef: userId,
                courseIdRef: UUID(),
                enrolledAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
                progressPercentage: 65.0,
                timeSpent: 18000, // 5 hours
                status: .active
            ),
            CourseEnrollment(
                learnerIdRef: userId,
                courseIdRef: UUID(),
                enrolledAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                progressPercentage: 100.0,
                timeSpent: 36000, // 10 hours
                status: .completed
            )
        ]
    }

    /// Update lesson progress
    nonisolated func completeLesson(userId: UUID, lessonId: UUID) async throws {
        // In production: networkClient.request(endpoint: .updateProgress(...), method: .post)
        print("Lesson completed: \(lessonId)")
    }

    /// Fetch modules for a course
    nonisolated func fetchModules(courseId: UUID) async throws -> [LearningModule] {
        // Return mock data
        return [
            LearningModule(
                title: "Introduction to Swift",
                moduleDescription: "Learn the basics of Swift syntax",
                orderIndex: 0,
                moduleType: .video,
                estimatedDuration: 3600
            ),
            LearningModule(
                title: "Variables and Data Types",
                moduleDescription: "Understanding variables, constants, and data types",
                orderIndex: 1,
                moduleType: .interactive,
                estimatedDuration: 5400
            )
        ]
    }

    /// Get enrollment for a specific course
    nonisolated func getEnrollment(courseId: UUID) async throws -> CourseEnrollment? {
        // In production: networkClient.request(...)
        return nil
    }
}

// MARK: - Cache Manager

actor CacheManager {
    private var coursesCache: [String: CacheEntry<[Course]>] = [:]
    private let maxAge: TimeInterval = 3600 // 1 hour

    struct CacheEntry<T: Sendable>: Sendable {
        let data: T
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > 3600
        }
    }

    func getCourses(filter: CourseFilter) -> [Course]? {
        let key = cacheKey(for: filter)
        guard let entry = coursesCache[key], !entry.isExpired else {
            return nil
        }
        return entry.data
    }

    func storeCourses(_ courses: [Course], filter: CourseFilter) {
        let key = cacheKey(for: filter)
        coursesCache[key] = CacheEntry(data: courses, timestamp: Date())
    }

    func clear() {
        coursesCache.removeAll()
    }

    private func cacheKey(for: CourseFilter) -> String {
        switch `for` {
        case .all:
            return "all"
        case .category(let category):
            return "category_\(category.rawValue)"
        case .difficulty(let difficulty):
            return "difficulty_\(difficulty.rawValue)"
        case .recommended(let userId):
            return "recommended_\(userId.uuidString)"
        }
    }
}
