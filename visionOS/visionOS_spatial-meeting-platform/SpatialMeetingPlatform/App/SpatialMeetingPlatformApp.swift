//
//  SpatialMeetingPlatformApp.swift
//  SpatialMeetingPlatform
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

@main
struct SpatialMeetingPlatformApp: App {

    // MARK: - State

    @State private var appModel = AppModel()
    @State private var immersionMode: ImmersionStyle = .mixed

    // MARK: - SwiftData Model Container

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Meeting.self,
            User.self,
            Participant.self,
            SharedContent.self,
            Transcript.self,
            ActionItem.self,
            Decision.self,
            MeetingAnalytics.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene Configuration

    var body: some Scene {
        // Primary Dashboard Window
        WindowGroup(id: "dashboard") {
            DashboardView()
                .environment(appModel)
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 700)

        // Meeting Controls Window
        WindowGroup(id: "meeting-controls") {
            MeetingControlsView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 400, height: 500)

        // Shared Content Window
        WindowGroup(id: "shared-content") {
            SharedContentView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 900)

        // 3D Meeting Space Volume
        WindowGroup(id: "meeting-volume") {
            MeetingVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2.0, height: 2.0, depth: 2.0, in: .meters)

        // Collaboration Volume (Whiteboard)
        WindowGroup(id: "collaboration-volume") {
            CollaborationVolumeView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.0, in: .meters)

        // Full Immersive Meeting Space
        ImmersiveSpace(id: "immersive-meeting") {
            ImmersiveMeetingView()
                .environment(appModel)
        }
        .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
    }
}
