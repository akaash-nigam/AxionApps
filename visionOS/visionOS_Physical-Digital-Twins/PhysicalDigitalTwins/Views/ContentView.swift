//
//  ContentView.swift
//  PhysicalDigitalTwins
//
//  Main content view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            InventoryListView()
                .tabItem {
                    Label("Inventory", systemImage: "square.stack.3d.up.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState(dependencies: AppDependencies()))
}
