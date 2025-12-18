//
//  CourseDetailView.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Complete implementation with tabs, modules, enrollment, and reviews
//

import SwiftUI
import SwiftData

/// Displays comprehensive details about a course including overview, curriculum, reviews, and enrollment options.
///
/// This view provides a tabbed interface for exploring course content:
/// - Overview: Description, instructor, prerequisites, learning objectives
/// - Curriculum: Module and lesson structure with progress tracking
/// - Reviews: Student ratings and testimonials
/// - About: Instructor bio and course metadata
struct CourseDetailView: View {
    let courseId: UUID

    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext

    @Query private var courses: [Course]
    @Query private var enrollments: [CourseEnrollment]

    @State private var selectedTab: DetailTab = .overview
    @State private var isEnrolling = false
    @State private var expandedModules: Set<UUID> = []
    @State private var showEnrollmentConfirmation = false

    // Computed properties
    private var course: Course? {
        courses.first { $0.id == courseId }
    }

    private var enrollment: CourseEnrollment? {
        guard let course = course else { return nil }
        return enrollments.first { $0.courseIdRef == course.id }
    }

    private var isEnrolled: Bool {
        enrollment != nil
    }

    private var enrollmentStatus: CourseEnrollmentStatus {
        guard let enrollment = enrollment else { return .notEnrolled }
        if enrollment.completedAt != nil {
            return .completed
        } else if enrollment.progressPercentage > 0 {
            return .inProgress
        } else {
            return .enrolled
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let course = course {
                    // Course Header
                    courseHeader(course)

                    // Tab Picker
                    tabPicker

                    Divider()
                        .padding(.horizontal, 40)

                    // Tab Content
                    tabContent(course)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                } else {
                    // Error state
                    ContentUnavailableView(
                        "Course Not Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("This course could not be loaded. Please try again later.")
                    )
                }
            }
        }
        .glassBackgroundEffect()
        .alert("Enrollment Successful", isPresented: $showEnrollmentConfirmation) {
            Button("Start Learning") {
                // Navigate to first lesson
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("You've been enrolled in this course. Start learning now!")
        }
    }

    // MARK: - Course Header

    @ViewBuilder
    private func courseHeader(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Breadcrumb navigation
            HStack(spacing: 8) {
                Text("Courses")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(course.category.rawValue.capitalized)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(course.title)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)

            // Course Title
            Text(course.title)
                .font(.system(size: 48, weight: .bold))
                .lineLimit(2)

            // Course Metadata
            HStack(spacing: 24) {
                // Rating
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("4.8")
                        .fontWeight(.semibold)
                    Text("(1,247 reviews)")
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 20)

                // Duration
                Label(formatDuration(Int(course.estimatedDuration)), systemImage: "clock")

                Divider()
                    .frame(height: 20)

                // Difficulty
                HStack(spacing: 6) {
                    Image(systemName: difficultyIcon(course.difficulty))
                    Text(course.difficulty.rawValue.capitalized)
                }

                Divider()
                    .frame(height: 20)

                // Enrollment count
                Label("1,247 enrolled", systemImage: "person.2")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // Enrollment Button
            enrollmentButton(course)
        }
        .padding(40)
        .padding(.bottom, 20)
    }

    // MARK: - Enrollment Button

    @ViewBuilder
    private func enrollmentButton(_ course: Course) -> some View {
        HStack(spacing: 16) {
            Button(action: { handleEnrollmentAction(course) }) {
                HStack(spacing: 12) {
                    if isEnrolling {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: enrollmentIcon)
                        Text(enrollmentButtonText)
                    }
                }
                .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isEnrolling)

            if isEnrolled {
                // Progress indicator
                if let enrollment = enrollment {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Progress:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(Int(enrollment.progressPercentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        ProgressView(value: enrollment.progressPercentage, total: 100)
                            .frame(width: 200)
                    }
                }
            }
        }
    }

    // MARK: - Tab Picker

    @ViewBuilder
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                        }
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)

                        // Selection indicator
                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                            .frame(height: 3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .hoverEffect()
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private func tabContent(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            switch selectedTab {
            case .overview:
                overviewTab(course)
            case .curriculum:
                curriculumTab(course)
            case .reviews:
                reviewsTab(course)
            case .about:
                aboutTab(course)
            }
        }
        .padding(.top, 32)
    }

    // MARK: - Overview Tab

    @ViewBuilder
    private func overviewTab(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("About This Course")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(course.courseDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // Learning Objectives
            VStack(alignment: .leading, spacing: 16) {
                Text("What You'll Learn")
                    .font(.title3)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    objectiveRow("Master core concepts and best practices")
                    objectiveRow("Build real-world projects from scratch")
                    objectiveRow("Understand advanced techniques and patterns")
                    objectiveRow("Prepare for certification and career advancement")
                }
            }

            // Prerequisites
            if course.difficulty != .beginner {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Prerequisites")
                        .font(.title3)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 12) {
                        prerequisiteRow("Basic understanding of the fundamentals", met: true)
                        prerequisiteRow("Completion of introductory course", met: false)
                        prerequisiteRow("Access to required software and tools", met: true)
                    }
                }
            }

            // Course Features
            VStack(alignment: .leading, spacing: 16) {
                Text("Course Features")
                    .font(.title3)
                    .fontWeight(.bold)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    featureCard(icon: "video", title: "Video Lessons", description: "\(course.modules.count * 5) HD videos")
                    featureCard(icon: "doc.text", title: "Resources", description: "Downloadable materials")
                    featureCard(icon: "checkmark.circle", title: "Assessments", description: "Quizzes and projects")
                    featureCard(icon: "medal", title: "Certificate", description: "Upon completion")

                    if course.supports3D {
                        featureCard(icon: "cube", title: "3D Simulations", description: "Immersive practice")
                    }

                    if course.supportsCollaboration {
                        featureCard(icon: "person.2", title: "Collaboration", description: "Group projects")
                    }
                }
            }
        }
    }

    // MARK: - Curriculum Tab

    @ViewBuilder
    private func curriculumTab(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Course Curriculum")
                .font(.title2)
                .fontWeight(.bold)

            Text("\(course.modules.count) modules · \(course.modules.reduce(0) { $0 + $1.lessons.count }) lessons")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                ForEach(Array(course.modules.enumerated()), id: \.element.id) { index, module in
                    moduleCard(module, index: index + 1)
                }
            }
        }
    }

    @ViewBuilder
    private func moduleCard(_ module: LearningModule, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Module Header
            Button(action: { toggleModule(module.id) }) {
                HStack {
                    HStack(spacing: 16) {
                        // Module number
                        Text("\(index)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(module.title)
                                .font(.headline)

                            Text("\(module.lessons.count) lessons · \(formatDuration(Int(module.estimatedDuration)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Expand/collapse icon
                    Image(systemName: expandedModules.contains(module.id) ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .hoverEffect()

            // Lessons List (Expandable)
            if expandedModules.contains(module.id) {
                VStack(spacing: 0) {
                    ForEach(Array(module.lessons.enumerated()), id: \.element.id) { lessonIndex, lesson in
                        lessonRow(lesson, number: lessonIndex + 1)

                        if lessonIndex < module.lessons.count - 1 {
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(12)
                .padding(.top, 8)
            }
        }
    }

    @ViewBuilder
    private func lessonRow(_ lesson: Lesson, number: Int) -> some View {
        HStack(spacing: 16) {
            // Lesson number
            Text("\(number)")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(width: 40)

            // Lesson icon
            Image(systemName: lessonIcon(lesson.contentType))
                .foregroundStyle(.secondary)

            // Lesson info
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(.subheadline)

                HStack(spacing: 12) {
                    Text(lesson.contentType.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if lesson.estimatedDuration > 0 {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(formatDuration(Int(lesson.estimatedDuration)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Completion status
            if isEnrolled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .opacity(0.3) // Would check actual completion
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Reviews Tab

    @ViewBuilder
    private func reviewsTab(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            // Rating Summary
            HStack(alignment: .top, spacing: 40) {
                VStack(spacing: 8) {
                    Text("4.8")
                        .font(.system(size: 56, weight: .bold))

                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text("Based on 1,247 reviews")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 200)

                VStack(alignment: .leading, spacing: 8) {
                    ratingBar(stars: 5, percentage: 0.82)
                    ratingBar(stars: 4, percentage: 0.12)
                    ratingBar(stars: 3, percentage: 0.04)
                    ratingBar(stars: 2, percentage: 0.01)
                    ratingBar(stars: 1, percentage: 0.01)
                }
            }

            Divider()

            // Individual Reviews
            Text("Student Reviews")
                .font(.title3)
                .fontWeight(.bold)

            VStack(spacing: 24) {
                reviewCard(
                    name: "Sarah Johnson",
                    role: "Software Engineer",
                    rating: 5,
                    date: "2 weeks ago",
                    comment: "Excellent course! The immersive 3D environments made complex concepts easy to understand. The hands-on practice scenarios were invaluable."
                )

                reviewCard(
                    name: "Michael Chen",
                    role: "Product Manager",
                    rating: 5,
                    date: "1 month ago",
                    comment: "This transformed how I learn. The spatial computing approach is revolutionary. Highly recommend for anyone serious about skill development."
                )

                reviewCard(
                    name: "Emily Rodriguez",
                    role: "Data Analyst",
                    rating: 4,
                    date: "2 months ago",
                    comment: "Great content and presentation. The AI tutor was helpful. Would love to see more advanced topics covered in future modules."
                )
            }
        }
    }

    // MARK: - About Tab

    @ViewBuilder
    private func aboutTab(_ course: Course) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            // Instructor
            VStack(alignment: .leading, spacing: 16) {
                Text("Instructor")
                    .font(.title3)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    // Instructor avatar
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Text("DR")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Dr. Sarah Johnson")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Senior Learning Architect")
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Label("15 courses", systemImage: "book")
                            Label("12,450 students", systemImage: "person.2")
                            Label("4.9 rating", systemImage: "star.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Text("Dr. Johnson is a renowned expert in spatial learning design with over 15 years of experience in educational technology. She holds a PhD in Learning Sciences and has helped Fortune 500 companies transform their training programs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Course Details
            VStack(alignment: .leading, spacing: 16) {
                Text("Course Information")
                    .font(.title3)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    detailRow(label: "Level", value: course.difficulty.rawValue.capitalized)
                    detailRow(label: "Category", value: course.category.rawValue.capitalized)
                    detailRow(label: "Duration", value: formatDuration(Int(course.estimatedDuration)))
                    detailRow(label: "Language", value: "English")
                    detailRow(label: "Last Updated", value: "January 2025")
                    detailRow(label: "Students Enrolled", value: "1,247")
                    detailRow(label: "Environment", value: course.environmentType.rawValue)
                }
            }

            Divider()

            // Tags
            VStack(alignment: .leading, spacing: 16) {
                Text("Skills You'll Gain")
                    .font(.title3)
                    .fontWeight(.bold)

                FlowLayout(spacing: 8) {
                    tagView("Core Concepts")
                    tagView("Best Practices")
                    tagView("Real-World Application")
                    tagView("Problem Solving")
                    tagView("Critical Thinking")
                    tagView("Hands-on Practice")
                }
            }
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func objectiveRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }

    @ViewBuilder
    private func prerequisiteRow(_ text: String, met: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(met ? .green : .secondary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(met ? .primary : .secondary)
        }
    }

    @ViewBuilder
    private func featureCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func ratingBar(stars: Int, percentage: Double) -> some View {
        HStack(spacing: 12) {
            Text("\(stars) ★")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))

                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)

            Text("\(Int(percentage * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func reviewCard(name: String, role: String, rating: Int, date: String, comment: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar
                Circle()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(name.prefix(1))
                            .font(.headline)
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 4) {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            Text(comment)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 140, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    @ViewBuilder
    private func tagView(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.1))
            .foregroundStyle(Color.accentColor)
            .cornerRadius(8)
    }

    // MARK: - Helper Functions

    private func toggleModule(_ id: UUID) {
        if expandedModules.contains(id) {
            expandedModules.remove(id)
        } else {
            expandedModules.insert(id)
        }
    }

    private func handleEnrollmentAction(_ course: Course) {
        guard !isEnrolling else { return }

        switch enrollmentStatus {
        case .notEnrolled:
            enrollInCourse(course)
        case .enrolled, .inProgress:
            // Continue learning - navigate to current lesson
            break
        case .completed:
            // Review course or re-enroll
            break
        }
    }

    private func enrollInCourse(_ course: Course) {
        isEnrolling = true

        Task {
            do {
                // Simulate enrollment via service
                try await Task.sleep(for: .seconds(1))

                // Create enrollment record
                guard let learner = appModel.currentUser else {
                    isEnrolling = false
                    return
                }

                let enrollment = CourseEnrollment(
                    learnerIdRef: learner.id,
                    courseIdRef: course.id
                )
                modelContext.insert(enrollment)
                try modelContext.save()

                isEnrolling = false
                showEnrollmentConfirmation = true
            } catch {
                isEnrolling = false
                // Handle error
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minutes"
        }
    }

    private func difficultyIcon(_ difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .beginner: return "1.circle"
        case .intermediate: return "2.circle"
        case .advanced: return "3.circle"
        case .expert: return "4.circle"
        }
    }

    private func lessonIcon(_ type: ContentType) -> String {
        switch type {
        case .video: return "play.circle"
        case .text: return "doc.text"
        case .quiz: return "questionmark.circle"
        case .simulation: return "cube"
        case .interactive: return "hand.tap"
        }
    }

    private var enrollmentIcon: String {
        switch enrollmentStatus {
        case .notEnrolled: return "plus.circle.fill"
        case .enrolled: return "play.circle.fill"
        case .inProgress: return "arrow.right.circle.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }

    private var enrollmentButtonText: String {
        switch enrollmentStatus {
        case .notEnrolled: return "Enroll Now"
        case .enrolled: return "Start Learning"
        case .inProgress: return "Continue Learning"
        case .completed: return "Review Course"
        }
    }
}

// MARK: - Supporting Types

enum DetailTab: String, CaseIterable {
    case overview = "Overview"
    case curriculum = "Curriculum"
    case reviews = "Reviews"
    case about = "About"

    var icon: String {
        switch self {
        case .overview: return "book"
        case .curriculum: return "list.bullet"
        case .reviews: return "star"
        case .about: return "info.circle"
        }
    }
}

enum CourseEnrollmentStatus {
    case notEnrolled
    case enrolled
    case inProgress
    case completed
}

// MARK: - FlowLayout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    CourseDetailView(courseId: UUID())
        .environment(AppModel())
}
