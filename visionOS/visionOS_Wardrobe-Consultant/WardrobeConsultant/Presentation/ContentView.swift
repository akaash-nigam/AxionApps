//
//  ContentView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

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

            OutfitListView()
                .tabItem {
                    Label("Outfits", systemImage: "sparkles")
                }

            RecommendationsView()
                .tabItem {
                    Label("AI", systemImage: "brain")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingFlow()
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
