//
//  DashboardView.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import SwiftUI
import SwiftData

/// Main dashboard view - the central hub for learning
struct DashboardView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @Query(sort: \CourseEnrollment.enrolledAt, order: .reverse)
    private var enrollments: [CourseEnrollment]

    @State private var showingCourseBrowser = false
    @State private var selectedCourseId: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Welcome Header
                welcomeSection

                // In Progress Courses
                if !inProgressEnrollments.isEmpty {
                    inProgressSection
                }

                // Learning Path
                if let currentUser = appModel.currentUser {
                    learningPathSection
                }

                // Recommended Courses
                recommendedSection

                // Quick Stats
                quickStatsSection
            }
            .padding(40)
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // Search Button
                Button {
                    openWindow(id: "courseBrowser")
                } label: {
                    Label("Browse Courses", systemImage: "magnifyingglass")
                }

                // Analytics Button
                Button {
                    openWindow(id: "analytics")
                } label: {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }

                // Profile Button
                Menu {
                    Button("Settings") {
                        openWindow(id: "settings")
                    }
                    Button("View 3D Progress") {
                        openWindow(id: "progressGlobe")
                    }
                    Divider()
                    Button("Logout", role: .destructive) {
                        Task {
                            await appModel.logout()
                        }
                    }
                } label: {
                    Label("Profile", systemImage: "person.circle.fill")
                }
            }
        }
        .glassBackgroundEffect()
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back, \(appModel.currentUser?.firstName ?? "Learner")")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.primary)

            Text("Continue your learning journey")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - In Progress Section

    private var inProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Continue Learning")
                    .font(.title)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    // TODO: Show all in progress courses
                }
                .buttonStyle(.bordered)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(inProgressEnrollments.prefix(3), id: \.id) { enrollment in
                        InProgressCourseCard(enrollment: enrollment)
                            .onTapGesture {
                                selectedCourseId = enrollment.courseIdRef
                                openWindow(id: "courseDetail", value: enrollment.courseIdRef)
                            }
                    }
                }
            }
        }
    }

    // MARK: - Learning Path Section

    private var learningPathSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Learning Path")
                    .font(.title)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    openWindow(id: "skillTreeVolume")
                } label: {
                    Label("View in 3D", systemImage: "cube.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            VStack(spacing: 12) {
                ForEach(inProgressEnrollments.prefix(3), id: \.id) { enrollment in
                    LearningPathRow(enrollment: enrollment)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Recommended Section

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.title)
                    .fontWeight(.semibold)

                Spacer()

                Button("Browse All") {
                    openWindow(id: "courseBrowser")
                }
                .buttonStyle(.bordered)
            }

            if appModel.availableCourses.isEmpty {
                // Show placeholder
                placeholderCourseCards
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(appModel.availableCourses.prefix(4), id: \.id) { course in
                            CourseCard(course: course)
                                .onTapGesture {
                                    openWindow(id: "courseDetail", value: course.id)
                                }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.title)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                StatCard(
                    title: "Courses Enrolled",
                    value: "\(enrollments.count)",
                    icon: "book.fill",
                    color: .blue
                )

                StatCard(
                    title: "Completed",
                    value: "\(completedEnrollments.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "In Progress",
                    value: "\(inProgressEnrollments.count)",
                    icon: "clock.fill",
                    color: .orange
                )

                StatCard(
                    title: "Achievements",
                    value: "\(appModel.currentUser?.achievements.count ?? 0)",
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }

    // MARK: - Placeholder

    private var placeholderCourseCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { _ in
                    PlaceholderCourseCard()
                }
            }
        }
        .task {
            await appModel.loadCourses()
        }
    }

    // MARK: - Computed Properties

    private var inProgressEnrollments: [CourseEnrollment] {
        enrollments.filter { $0.status == .active && $0.progressPercentage < 100 }
    }

    private var completedEnrollments: [CourseEnrollment] {
        enrollments.filter { $0.status == .completed || $0.progressPercentage >= 100 }
    }
}

// MARK: - Supporting Views

struct InProgressCourseCard: View {
    let enrollment: CourseEnrollment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(width: 280, height: 160)
                .overlay {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Course Title") // TODO: Fetch actual course
                    .font(.headline)
                    .lineLimit(2)

                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(enrollment.progressPercentage))% Complete")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(timeSpentFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: enrollment.progressPercentage, total: 100)
                        .tint(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 280)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var timeSpentFormatted: String {
        let hours = Int(enrollment.timeSpent) / 3600
        let minutes = (Int(enrollment.timeSpent) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct LearningPathRow: View {
    let enrollment: CourseEnrollment

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: enrollment.status == .completed ? "checkmark.circle.fill" : "circle.fill")
                .font(.title2)
                .foregroundStyle(enrollment.status == .completed ? .green : .blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Module \(enrollment.currentModuleId?.uuidString.prefix(8) ?? "1")") // TODO: Fetch actual module
                    .font(.headline)

                ProgressView(value: enrollment.progressPercentage, total: 100)
                    .frame(maxWidth: 300)
            }

            Spacer()

            Text("\(Int(enrollment.progressPercentage))%")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}

struct CourseCard: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(width: 280, height: 160)
                .overlay {
                    if course.supports3D {
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                    } else {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(course.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack {
                    Label(course.difficulty.rawValue.capitalized, systemImage: "chart.bar.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Label(durationFormatted, systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 280)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var durationFormatted: String {
        let hours = Int(course.estimatedDuration) / 3600
        return "\(hours)h"
    }
}

struct PlaceholderCourseCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(width: 280, height: 160)
                .overlay {
                    ProgressView()
                }

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.ultraThinMaterial)
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.ultraThinMaterial)
                    .frame(height: 16)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 280)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 36, weight: .bold))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AppModel())
}
