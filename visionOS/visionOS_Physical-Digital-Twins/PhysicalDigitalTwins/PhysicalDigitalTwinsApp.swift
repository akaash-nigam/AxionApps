//
//  PhysicalDigitalTwinsApp.swift
//  PhysicalDigitalTwins
//
//  Main app entry point
//

import SwiftUI

@main
struct PhysicalDigitalTwinsApp: App {
    // Initialize dependencies
    private let dependencies = AppDependencies()

    // App state
    @State private var appState: AppState

    init() {
        self.appState = AppState(dependencies: dependencies)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
