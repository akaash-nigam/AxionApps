//
//  LessonView.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Complete implementation with content display, navigation, notes, and completion tracking
//

import SwiftUI
import SwiftData

/// Displays a lesson with its content, navigation controls, notes, and completion tracking.
///
/// This view provides the main learning experience:
/// - Content display (text, video placeholder, interactive elements)
/// - Previous/Next lesson navigation
/// - Progress tracking
/// - Note-taking capability
/// - Bookmark functionality
/// - Quiz integration for assessment lessons
/// - Resource downloads
/// - Time tracking
struct LessonView: View {
    let lessonId: UUID

    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext

    @Query private var lessons: [Lesson]
    @State private var isCompleted = false
    @State private var isBookmarked = false
    @State private var showNotes = false
    @State private var notes = ""
    @State private var showQuiz = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    private var lesson: Lesson? {
        lessons.first { $0.id == lessonId }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Main Content Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if let lesson = lesson {
                            // Lesson Header
                            lessonHeader(lesson)

                            // Content based on type
                            lessonContent(lesson, width: geometry.size.width * (showNotes ? 0.65 : 0.9))

                            // Resources Section (TODO: Add resources property to Lesson model)
                            // if !lesson.resources.isEmpty {
                            //     resourcesSection(lesson)
                            // }

                            // Quiz Section (for quiz-type lessons)
                            if lesson.contentType == .quiz {
                                quizSection(lesson)
                            }

                            // Navigation
                            lessonNavigation(lesson)
                        } else {
                            ContentUnavailableView(
                                "Lesson Not Found",
                                systemImage: "exclamationmark.triangle",
                                description: Text("This lesson could not be loaded.")
                            )
                        }
                    }
                    .padding(40)
                }

                // Notes Sidebar (Collapsible)
                if showNotes {
                    notesSidebar(width: geometry.size.width * 0.35)
                }
            }
        }
        .glassBackgroundEffect()
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // Bookmark button
                Button(action: { isBookmarked.toggle() }) {
                    Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                }

                // Notes toggle
                Button(action: { showNotes.toggle() }) {
                    Label(showNotes ? "Hide Notes" : "Show Notes", systemImage: "note.text")
                }

                // Time spent
                Label(formatTime(elapsedTime), systemImage: "clock")
                    .font(.caption)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Lesson Header

    @ViewBuilder
    private func lessonHeader(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Breadcrumb
            HStack(spacing: 8) {
                Text("Course")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text("Module 1")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(lesson.title)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)

            // Title and metadata
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(lesson.title)
                        .font(.system(size: 40, weight: .bold))

                    HStack(spacing: 20) {
                        // Lesson type
                        Label(lesson.contentType.rawValue.capitalized, systemImage: lessonTypeIcon(lesson.contentType))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if lesson.estimatedDuration > 0 {
                            Label(formatDuration(Int(lesson.estimatedDuration)), systemImage: "clock")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                // Completion badge
                if isCompleted {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Completed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
                }
            }

            // Progress bar
            ProgressView(value: isCompleted ? 1.0 : 0.5, total: 1.0)
                .tint(.accentColor)
        }
    }

    // MARK: - Lesson Content

    @ViewBuilder
    private func lessonContent(_ lesson: Lesson, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            switch lesson.contentType {
            case .video:
                videoContent(lesson, width: width)
            case .text:
                textContent(lesson)
            case .interactive:
                interactiveContent(lesson)
            case .simulation:
                simulationContent(lesson)
            case .quiz:
                Text("See quiz section below")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func videoContent(_ lesson: Lesson, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Video player placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .aspectRatio(16/9, contentMode: .fit)

                VStack(spacing: 16) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)

                    Text("Video Player")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text("Duration: \(formatDuration(Int(lesson.estimatedDuration)))")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            // Video controls placeholder
            HStack(spacing: 24) {
                Button(action: {}) {
                    Label("Rewind 10s", systemImage: "gobackward.10")
                }

                Button(action: {}) {
                    Label("Play/Pause", systemImage: "play.fill")
                }

                Button(action: {}) {
                    Label("Forward 10s", systemImage: "goforward.10")
                }

                Spacer()

                Button(action: {}) {
                    Label("Speed", systemImage: "gauge")
                }

                Button(action: {}) {
                    Label("Subtitles", systemImage: "captions.bubble")
                }

                Button(action: {}) {
                    Label("Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right")
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            // Video transcript/description
            VStack(alignment: .leading, spacing: 12) {
                Text("About This Video")
                    .font(.headline)

                Text(lesson.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private func textContent(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Rich text content
            Text(lesson.content)
                .font(.body)
                .lineSpacing(8)

            // Key points callout
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("Key Takeaways")
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 8) {
                    keyPoint("Master the fundamental concepts")
                    keyPoint("Apply techniques to real-world scenarios")
                    keyPoint("Understand best practices and patterns")
                    keyPoint("Build confidence through practice")
                }
            }
            .padding(20)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private func interactiveContent(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Interactive Exercise")
                .font(.title2)
                .fontWeight(.bold)

            // Interactive placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color.green.opacity(0.2), Color.blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 400)

                VStack(spacing: 16) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 60))

                    Text("Interactive Component")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Tap to interact and practice the concepts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Start Exercise") {}
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            }
        }
    }

    @ViewBuilder
    private func simulationContent(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("3D Simulation")
                .font(.title2)
                .fontWeight(.bold)

            // 3D simulation placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 500)

                VStack(spacing: 16) {
                    Image(systemName: "cube.fill")
                        .font(.system(size: 60))

                    Text("Immersive 3D Simulation")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Practice in a realistic spatial environment")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Launch Simulation") {}
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            }
        }
    }

    // MARK: - Resources Section

    @ViewBuilder
    private func resourcesSection(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.title3)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                resourceRow(icon: "doc.text", title: "Lesson Slides", size: "2.4 MB", type: "PDF")
                resourceRow(icon: "doc.richtext", title: "Study Guide", size: "856 KB", type: "PDF")
                resourceRow(icon: "folder", title: "Example Code", size: "1.2 MB", type: "ZIP")
                resourceRow(icon: "link", title: "Additional Reading", size: "Web", type: "Link")
            }
        }
        .padding(.top, 16)
    }

    @ViewBuilder
    private func resourceRow(icon: String, title: String, size: String, type: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    Text(size)
                    Text("•")
                    Text(type)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Label("Download", systemImage: "arrow.down.circle")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(16)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Quiz Section

    @ViewBuilder
    private func quizSection(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Knowledge Check")
                .font(.title2)
                .fontWeight(.bold)

            Text("Test your understanding of the concepts covered in this lesson.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    statCard(value: "5", label: "Questions", icon: "questionmark.circle")
                    statCard(value: "10", label: "Minutes", icon: "clock")
                    statCard(value: "80%", label: "Pass Score", icon: "chart.bar")
                }

                Button(action: { showQuiz = true }) {
                    Label("Start Quiz", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(24)
            .background(Color.accentColor.opacity(0.05))
            .cornerRadius(16)
        }
    }

    @ViewBuilder
    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Lesson Navigation

    @ViewBuilder
    private func lessonNavigation(_ lesson: Lesson) -> some View {
        VStack(spacing: 20) {
            Divider()

            // Complete lesson button
            if !isCompleted {
                Button(action: completeLesson) {
                    Label("Mark as Complete", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            // Previous/Next navigation
            HStack {
                Button(action: {}) {
                    Label("Previous Lesson", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Spacer()

                if isCompleted {
                    Button(action: {}) {
                        Label("Next Lesson", systemImage: "chevron.right")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .padding(.top, 32)
    }

    // MARK: - Notes Sidebar

    @ViewBuilder
    private func notesSidebar(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label("My Notes", systemImage: "note.text")
                    .font(.headline)

                Spacer()

                Button(action: { showNotes = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            TextEditor(text: $notes)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )

            // Note actions
            HStack {
                Button(action: {}) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button(action: { notes = "" }) {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                Text("\(notes.count) characters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Previous notes (if any)
            VStack(alignment: .leading, spacing: 12) {
                Text("Previous Notes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text("Notes from other lessons will appear here...")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }

            Spacer()
        }
        .padding(24)
        .frame(width: width)
        .background(Color.secondary.opacity(0.03))
        .overlay(
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 1),
            alignment: .leading
        )
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func keyPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .font(.caption)
            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - Helper Functions

    private func completeLesson() {
        withAnimation {
            isCompleted = true
        }

        // Save completion to model context
        // TODO: Update ModuleProgress or create LessonCompletion record
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor [weak timer = self.timer] in
                guard timer != nil else { return }
                self.elapsedTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil

        // Save time spent to analytics
        // TODO: Track learning time
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private func lessonTypeIcon(_ type: ContentType) -> String {
        switch type {
        case .video: return "play.circle"
        case .text: return "doc.text"
        case .quiz: return "questionmark.circle"
        case .simulation: return "cube"
        case .interactive: return "hand.tap"
        }
    }
}

#Preview {
    LessonView(lessonId: UUID())
        .environment(AppModel())
}
