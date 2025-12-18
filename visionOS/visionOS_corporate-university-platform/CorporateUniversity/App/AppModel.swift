//
//  AppModel.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import SwiftUI
import SwiftData
import GroupActivities

/// Main application state and coordinator
@Observable
@MainActor
class AppModel {
    // MARK: - Properties

    /// SwiftData model container
    let modelContainer: ModelContainer

    /// Service container for dependency injection
    let services: ServiceContainer

    // MARK: - Authentication State

    var currentUser: Learner?
    var isAuthenticated: Bool = false
    var authToken: String?

    // MARK: - Learning State

    var currentCourse: Course?
    var currentLesson: Lesson?
    var enrollments: [CourseEnrollment] = []
    var availableCourses: [Course] = []

    // MARK: - Spatial State

    var immersionStyle: ImmersionStyle = .mixed
    var currentEnvironment: LearningEnvironmentType?
    var activeSpace: SpaceType = .dashboard
    var openWindows: Set<String> = []
    var immersiveSpaceActive: Bool = false

    // MARK: - UI State

    var isLoading: Bool = false
    var errorMessage: String?
    var showAlert: Bool = false
    var showOnboarding: Bool = false

    // MARK: - Collaboration State

    nonisolated(unsafe) var groupSession: GroupSession<LearningActivity>?
    var isCollaborating: Bool = false
    var collaborators: [Participant] = []

    // MARK: - Initialization

    init() {
        // Initialize SwiftData container
        let schema = Schema([
            Learner.self,
            Course.self,
            LearningModule.self,
            Lesson.self,
            CourseEnrollment.self,
            Assessment.self,
            AssessmentResult.self,
            Achievement.self,
            LearningProfile.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        // Initialize services
        self.services = ServiceContainer()

        // Check for existing session
        checkAuthenticationStatus()
    }

    // MARK: - Authentication

    func checkAuthenticationStatus() {
        // TODO: Check keychain for stored auth token
        // TODO: Validate token with backend
        isAuthenticated = false
    }

    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // TODO: Implement actual authentication
        // For now, mock success
        do {
            let token = try await services.authenticationService.login(
                email: email,
                password: password
            )
            self.authToken = token
            self.isAuthenticated = true

            // Load user profile
            try await loadUserProfile()
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
            showAlert = true
            throw error
        }
    }

    func logout() async {
        isAuthenticated = false
        authToken = nil
        currentUser = nil
        enrollments = []
        currentCourse = nil
        currentLesson = nil
    }

    // MARK: - User Profile

    func loadUserProfile() async throws {
        guard authToken != nil else {
            throw AppError.notAuthenticated
        }

        // TODO: Fetch user profile from API
        // For now, create mock user
        let user = Learner(
            id: UUID(),
            employeeId: "EMP001",
            firstName: "Demo",
            lastName: "User",
            email: "demo@company.com",
            department: "Engineering",
            role: "Software Engineer"
        )

        self.currentUser = user

        // Load enrollments
        try await loadEnrollments()
    }

    // MARK: - Courses

    func loadCourses() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let courses = try await services.learningService.fetchCourses(filter: .all)
            self.availableCourses = courses
        } catch {
            errorMessage = "Failed to load courses: \(error.localizedDescription)"
            showAlert = true
        }
    }

    func loadEnrollments() async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        let enrollments = try await services.learningService.fetchEnrollments(
            userId: user.id
        )
        self.enrollments = enrollments
    }

    func enrollInCourse(_ course: Course) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        isLoading = true
        defer { isLoading = false }

        let enrollment = try await services.learningService.enrollInCourse(
            learnerId: user.id,
            courseId: course.id
        )

        enrollments.append(enrollment)
        errorMessage = "Successfully enrolled in \(course.title)"
        showAlert = true
    }

    // MARK: - Learning

    func startLesson(_ lesson: Lesson) async {
        currentLesson = lesson

        // Track analytics
        await services.analyticsService.trackEvent(
            AnalyticsEvent(
                type: .lessonStarted,
                timestamp: Date(),
                data: ["lessonId": lesson.id.uuidString]
            )
        )
    }

    func completeLesson(_ lesson: Lesson) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        // Update progress
        try await services.learningService.completeLesson(
            userId: user.id,
            lessonId: lesson.id
        )

        // Track analytics
        await services.analyticsService.trackEvent(
            AnalyticsEvent(
                type: .lessonCompleted,
                timestamp: Date(),
                data: ["lessonId": lesson.id.uuidString]
            )
        )
    }

    // MARK: - Space Management

    func openSpace(_ space: SpaceType) async {
        await MainActor.run {
            activeSpace = space
        }

        switch space {
        case .dashboard:
            openWindows.insert("dashboard")
        case .courseBrowser:
            openWindows.insert("courseBrowser")
        case .analytics:
            openWindows.insert("analytics")
        case .settings:
            openWindows.insert("settings")
        case .skillTreeVolume:
            openWindows.insert("skillTreeVolume")
        case .progressGlobe:
            openWindows.insert("progressGlobe")
        case .learningEnvironment:
            immersiveSpaceActive = true
        }
    }

    func closeSpace(_ space: SpaceType) async {
        await MainActor.run {
            switch space {
            case .learningEnvironment:
                immersiveSpaceActive = false
            default:
                openWindows.remove(space.windowId)
            }
        }
    }

    // MARK: - Collaboration

    func startCollaborativeSession() async throws {
        guard let currentCourse = currentCourse else {
            throw AppError.noCourseSelected
        }

        let activity = LearningActivity(
            courseId: currentCourse.id,
            courseName: currentCourse.title
        )

        do {
            // For GroupActivity, we need to prepare for incoming sessions
            for await session in LearningActivity.sessions() {
                self.groupSession = session
                self.isCollaborating = true

                // Monitor session state
                Task {
                    await monitorCollaborationSession(session)
                }
                break // Only handle the first session
            }
        } catch {
            errorMessage = "Failed to start collaborative session: \(error.localizedDescription)"
            showAlert = true
            throw error
        }
    }

    func endCollaborativeSession() async {
        groupSession?.end()
        groupSession = nil
        isCollaborating = false
        collaborators = []
    }

    private func monitorCollaborationSession(_ session: GroupSession<LearningActivity>) async {
        // Monitor session state changes
        for await state in session.$state.values {
            if case .invalidated = state {
                await endCollaborativeSession()
            }
        }
    }
}

// MARK: - Supporting Types

enum SpaceType {
    case dashboard
    case courseBrowser
    case analytics
    case settings
    case skillTreeVolume
    case progressGlobe
    case learningEnvironment

    var windowId: String {
        switch self {
        case .dashboard: return "dashboard"
        case .courseBrowser: return "courseBrowser"
        case .analytics: return "analytics"
        case .settings: return "settings"
        case .skillTreeVolume: return "skillTreeVolume"
        case .progressGlobe: return "progressGlobe"
        case .learningEnvironment: return "learningEnvironment"
        }
    }
}

enum LearningEnvironmentType {
    case classroom
    case manufacturingFloor
    case boardroom
    case innovationLab
    case outdoorTraining
}

enum AppError: LocalizedError {
    case notAuthenticated
    case noCourseSelected
    case networkError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action."
        case .noCourseSelected:
            return "Please select a course first."
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Group Activity Support

struct LearningActivity: GroupActivity, Sendable {
    let courseId: UUID
    let courseName: String

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Learning: \(courseName)"
        metadata.type = .generic
        metadata.fallbackURL = URL(string: "https://corporateuniversity.com")
        return metadata
    }
}

struct Participant: Identifiable {
    let id: UUID
    let name: String
    let avatar: URL?
}
