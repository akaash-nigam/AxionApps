//
//  ContentView.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        @Bindable var appModel = appModel

        NavigationSplitView {
            // Sidebar
            List {
                Section("Overview") {
                    NavigationLink(value: Route.dashboard) {
                        Label("Dashboard", systemImage: "chart.bar.fill")
                    }

                    NavigationLink(value: Route.analytics) {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                }

                Section("Actions") {
                    NavigationLink(value: Route.recognition) {
                        Label("Give Recognition", systemImage: "star.fill")
                    }
                }

                Section("Experiences") {
                    Button {
                        Task {
                            await openImmersiveSpace(id: "culture-campus")
                        }
                    } label: {
                        Label("Culture Campus", systemImage: "mountain.2.fill")
                    }
                }

                Section("Settings") {
                    NavigationLink(value: Route.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("Culture")
        } detail: {
            // Main content based on selection
            DashboardView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
