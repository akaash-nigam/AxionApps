//
//  WardrobeConsultantApp.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct WardrobeConsultantApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
        }

        ImmersiveSpace(id: "virtualTryOn") {
            VirtualTryOnView()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showOnboarding = false

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingCoordinatorView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            showOnboarding = coordinator.shouldShowOnboarding()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "tshirt.fill")
                }

            OutfitsView()
                .tabItem {
                    Label("Outfits", systemImage: "square.grid.3x3.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// MARK: - Placeholder Views (to be implemented)
struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("Home - Coming Soon")
                .navigationTitle("Home")
        }
    }
}

struct WardrobeView: View {
    var body: some View {
        NavigationStack {
            Text("Wardrobe - Coming Soon")
                .navigationTitle("Wardrobe")
        }
    }
}

struct OutfitsView: View {
    var body: some View {
        NavigationStack {
            Text("Outfits - Coming Soon")
                .navigationTitle("Outfits")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Settings - Coming Soon")
                .navigationTitle("Settings")
        }
    }
}

struct OnboardingCoordinatorView: View {
    var body: some View {
        Text("Onboarding - Coming Soon")
    }
}

struct VirtualTryOnView: View {
    var body: some View {
        Text("Virtual Try-On - Coming Soon")
    }
}
