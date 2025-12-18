//
//  LearningServiceTests.swift
//  CorporateUniversityTests
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import XCTest
@testable import CorporateUniversity

final class LearningServiceTests: XCTestCase {
    var sut: LearningService!
    var networkClient: NetworkClient!
    var cacheManager: CacheManager!

    override func setUp() {
        super.setUp()
        networkClient = NetworkClient()
        cacheManager = CacheManager()
        sut = LearningService(networkClient: networkClient, cacheManager: cacheManager)
    }

    override func tearDown() {
        sut = nil
        networkClient = nil
        cacheManager = nil
        super.tearDown()
    }

    // MARK: - Fetch Courses Tests

    func testFetchCourses_ReturnsNonEmptyArray() async throws {
        // When
        let courses = try await sut.fetchCourses(filter: .all)

        // Then
        XCTAssertFalse(courses.isEmpty, "Should return at least one course")
    }

    func testFetchCourses_ReturnsValidCourseData() async throws {
        // When
        let courses = try await sut.fetchCourses(filter: .all)

        // Then
        for course in courses {
            XCTAssertFalse(course.title.isEmpty, "Course title should not be empty")
            XCTAssertFalse(course.courseDescription.isEmpty, "Course description should not be empty")
            XCTAssertGreaterThan(course.estimatedDuration, 0, "Estimated duration should be positive")
        }
    }

    func testFetchCourses_CategoryFilter() async throws {
        // When
        let technologyCourses = try await sut.fetchCourses(filter: .category(.technology))

        // Then
        for course in technologyCourses {
            XCTAssertEqual(course.category, .technology, "All courses should be in technology category")
        }
    }

    // MARK: - Enroll Tests

    func testEnrollInCourse_CreatesEnrollment() async throws {
        // Given
        let learnerId = UUID()
        let courseId = UUID()

        // When
        let enrollment = try await sut.enrollInCourse(learnerId: learnerId, courseId: courseId)

        // Then
        XCTAssertEqual(enrollment.learnerIdRef, learnerId)
        XCTAssertEqual(enrollment.courseIdRef, courseId)
        XCTAssertEqual(enrollment.progressPercentage, 0.0)
        XCTAssertEqual(enrollment.status, .active)
    }

    // MARK: - Fetch Enrollments Tests

    func testFetchEnrollments_ReturnsEnrollments() async throws {
        // Given
        let userId = UUID()

        // When
        let enrollments = try await sut.fetchEnrollments(userId: userId)

        // Then
        XCTAssertFalse(enrollments.isEmpty, "Should return enrollments")

        for enrollment in enrollments {
            XCTAssertEqual(enrollment.learnerIdRef, userId)
            XCTAssertGreaterThanOrEqual(enrollment.progressPercentage, 0.0)
            XCTAssertLessThanOrEqual(enrollment.progressPercentage, 100.0)
        }
    }

    // MARK: - Complete Lesson Tests

    func testCompleteLesson_DoesNotThrow() async throws {
        // Given
        let userId = UUID()
        let lessonId = UUID()

        // When/Then - should not throw
        try await sut.completeLesson(userId: userId, lessonId: lessonId)
    }

    // MARK: - Fetch Modules Tests

    func testFetchModules_ReturnsModules() async throws {
        // Given
        let courseId = UUID()

        // When
        let modules = try await sut.fetchModules(courseId: courseId)

        // Then
        XCTAssertFalse(modules.isEmpty, "Should return modules")

        for (index, module) in modules.enumerated() {
            XCTAssertEqual(module.orderIndex, index, "Modules should be ordered correctly")
            XCTAssertFalse(module.title.isEmpty)
            XCTAssertGreaterThan(module.estimatedDuration, 0)
        }
    }

    // MARK: - Cache Tests

    func testFetchCourses_UsesCacheOnSecondCall() async throws {
        // Given - First call to populate cache
        _ = try await sut.fetchCourses(filter: .all)

        // When - Second call should use cache
        let startTime = Date()
        let cachedCourses = try await sut.fetchCourses(filter: .all)
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertFalse(cachedCourses.isEmpty)
        XCTAssertLessThan(duration, 0.1, "Cached call should be very fast")
    }
}

// MARK: - Cache Manager Tests

final class CacheManagerTests: XCTestCase {
    var sut: CacheManager!

    override func setUp() {
        super.setUp()
        sut = CacheManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testStoreCourses_AndRetrieve() async {
        // Given
        let courses = [Course.sample]
        let filter = CourseFilter.all

        // When
        await sut.storeCourses(courses, filter: filter)
        let retrieved = await sut.getCourses(filter: filter)

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, courses.count)
    }

    func testClear_RemovesAllCachedData() async {
        // Given
        let courses = [Course.sample]
        await sut.storeCourses(courses, filter: .all)

        // When
        await sut.clear()
        let retrieved = await sut.getCourses(filter: .all)

        // Then
        XCTAssertNil(retrieved, "Cache should be empty after clear")
    }
}
