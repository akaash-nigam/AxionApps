//
//  CorporateUniversityApp.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct CorporateUniversityApp: App {
    // MARK: - Properties

    @State private var appModel = AppModel()

    // MARK: - Scene Configuration

    var body: some Scene {
        // Main Dashboard Window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)
        .modelContainer(appModel.modelContainer)

        // Course Browser Window
        WindowGroup(id: "courseBrowser") {
            CourseBrowserView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 700)
        .modelContainer(appModel.modelContainer)

        // Course Detail Window
        WindowGroup(id: "courseDetail", for: UUID.self) { $courseId in
            if let courseId = courseId {
                CourseDetailView(courseId: courseId)
                    .environment(appModel)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 900)
        .modelContainer(appModel.modelContainer)

        // Learning Window (Active Lesson)
        WindowGroup(id: "learningWindow", for: UUID.self) { $lessonId in
            if let lessonId = lessonId {
                LessonView(lessonId: lessonId)
                    .environment(appModel)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(appModel.modelContainer)

        // Analytics Window
        WindowGroup(id: "analytics") {
            AnalyticsView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1400, height: 900)
        .modelContainer(appModel.modelContainer)

        // Skill Tree Volume
        WindowGroup(id: "skillTreeVolume") {
            SkillTreeVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.2, height: 1.2, depth: 1.0, in: .meters)

        // Progress Globe Volume
        WindowGroup(id: "progressGlobe") {
            ProgressGlobeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.8, depth: 0.8, in: .meters)

        // Immersive Learning Environment
        ImmersiveSpace(id: "learningEnvironment") {
            LearningEnvironmentView()
                .environment(appModel)
        }
        .immersionStyle(selection: $appModel.immersionStyle, in: .mixed, .progressive, .full)

        // Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 800, height: 600)
        .windowResizability(.contentSize)
        .modelContainer(appModel.modelContainer)
    }
}
