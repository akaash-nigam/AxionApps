//
//  RealityAnnotationApp.swift
//  Reality Annotation Platform
//
//  Main app entry point for visionOS
//

import SwiftUI
import SwiftData

@main
struct RealityAnnotationApp: App {
    @StateObject private var appState = AppState.shared

    // SwiftData model container
    let modelContainer: ModelContainer

    init() {
        do {
            // Create SwiftData schema
            let schema = Schema([
                Annotation.self,
                Layer.self,
                User.self,
                Comment.self,
                ARWorldMapData.self
            ])

            // Configure model container
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("✅ SwiftData initialized successfully")
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        // Main 2D window
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)

        // AR immersive space
        ImmersiveSpace(id: "ar-space") {
            ImmersiveView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
