//
//  CourseBrowserView.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import SwiftUI
import SwiftData

struct CourseBrowserView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow

    @State private var searchText = ""
    @State private var selectedCategory: CourseCategory?
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var sortOrder: SortOrder = .newest

    var body: some View {
        NavigationSplitView {
            // Sidebar with filters
            List(selection: $selectedCategory) {
                Section("Category") {
                    NavigationLink(value: nil as CourseCategory?) {
                        Label("All Courses", systemImage: "square.grid.2x2")
                    }

                    ForEach([CourseCategory.technology, .leadership, .sales, .operations, .compliance, .softSkills], id: \.self) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue.capitalized, systemImage: iconFor(category))
                        }
                    }
                }

                Section("Difficulty") {
                    ForEach([DifficultyLevel.beginner, .intermediate, .advanced, .expert], id: \.self) { level in
                        Button {
                            selectedDifficulty = selectedDifficulty == level ? nil : level
                        } label: {
                            HStack {
                                Text(level.rawValue.capitalized)
                                Spacer()
                                if selectedDifficulty == level {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }

                Section("Features") {
                    Toggle("3D Content", isOn: .constant(false))
                    Toggle("Collaboration", isOn: .constant(false))
                }
            }
            .navigationTitle("Filters")
            .frame(minWidth: 220)

        } detail: {
            // Main content area
            VStack(spacing: 0) {
                // Search and Sort Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search courses...", text: $searchText)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    Spacer()

                    Menu {
                        Button("Newest First") { sortOrder = .newest }
                        Button("Most Popular") { sortOrder = .popular }
                        Button("Shortest") { sortOrder = .duration }
                        Button("Title A-Z") { sortOrder = .alphabetical }
                    } label: {
                        Label("Sort: \(sortOrder.rawValue)", systemImage: "arrow.up.arrow.down")
                    }
                    .buttonStyle(.bordered)
                }
                .padding()

                Divider()

                // Course Grid
                ScrollView {
                    if filteredCourses.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 20)
                        ], spacing: 20) {
                            ForEach(filteredCourses, id: \.id) { course in
                                CourseGridCard(course: course)
                                    .onTapGesture {
                                        openWindow(id: "courseDetail", value: course.id)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Browse Courses")
        }
        .task {
            if appModel.availableCourses.isEmpty {
                await appModel.loadCourses()
            }
        }
    }

    // MARK: - Filtered Courses

    private var filteredCourses: [Course] {
        var courses = appModel.availableCourses

        // Filter by category
        if let category = selectedCategory {
            courses = courses.filter { $0.category == category }
        }

        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            courses = courses.filter { $0.difficulty == difficulty }
        }

        // Search
        if !searchText.isEmpty {
            courses = courses.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.courseDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortOrder {
        case .newest:
            courses.sort { $0.publishedAt > $1.publishedAt }
        case .popular:
            // TODO: Sort by enrollment count
            break
        case .duration:
            courses.sort { $0.estimatedDuration < $1.estimatedDuration }
        case .alphabetical:
            courses.sort { $0.title < $1.title }
        }

        return courses
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Courses Found")
                .font(.title)
                .fontWeight(.semibold)

            Text("Try adjusting your filters or search terms")
                .foregroundStyle(.secondary)

            Button("Clear Filters") {
                selectedCategory = nil
                selectedDifficulty = nil
                searchText = ""
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func iconFor(_ category: CourseCategory) -> String {
        switch category {
        case .technology: return "laptopcomputer"
        case .leadership: return "person.3.fill"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .operations: return "gearshape.2.fill"
        case .compliance: return "checkmark.shield.fill"
        case .softSkills: return "brain.head.profile"
        }
    }
}

// MARK: - Supporting Types

enum SortOrder: String {
    case newest = "Newest"
    case popular = "Popular"
    case duration = "Duration"
    case alphabetical = "A-Z"
}

// MARK: - Course Grid Card

struct CourseGridCard: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(height: 180)
                .overlay {
                    VStack {
                        Spacer()
                        if course.supports3D {
                            HStack {
                                Spacer()
                                Label("3D", systemImage: "cube.transparent.fill")
                                    .font(.caption)
                                    .padding(8)
                                    .background(.blue, in: Capsule())
                            }
                            .padding(8)
                        }
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                // Category badge
                Text(course.category.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.2), in: Capsule())

                Text(course.title)
                    .font(.headline)
                    .lineLimit(2)
                    .frame(height: 44, alignment: .top)

                Text(course.courseDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .top)

                Divider()

                HStack {
                    Label(course.difficulty.rawValue, systemImage: "chart.bar.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Label(durationFormatted, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .hoverEffect(.lift)
    }

    private var durationFormatted: String {
        let hours = Int(course.estimatedDuration) / 3600
        return "\(hours)h"
    }
}

// MARK: - Preview

#Preview {
    CourseBrowserView()
        .environment(AppModel())
}
