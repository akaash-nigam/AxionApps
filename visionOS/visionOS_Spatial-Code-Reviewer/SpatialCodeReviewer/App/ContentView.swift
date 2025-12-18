//
//  ContentView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                if appState.isAuthenticated {
                    // Main app interface
                    RepositoryListView()
                        .navigationDestination(for: Repository.self) { repository in
                            RepositoryDetailView(repository: repository)
                        }
                } else {
                    // Welcome/authentication screen
                    WelcomeView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }

                if appState.isAuthenticated {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            appState.signOut()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onChange(of: appState.selectedRepository) { oldValue, newValue in
                if let repository = newValue {
                    navigationPath.append(repository)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
