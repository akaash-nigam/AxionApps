//
//  SpatialCodeReviewerApp.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

@main
struct SpatialCodeReviewerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1200, height: 800, depth: 400, in: .points)

        ImmersiveSpace(id: "CodeReviewSpace") {
            CodeReviewImmersiveView()
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedRepository: Repository?
    @Published var isImmersiveSpaceActive = false

    // Services
    let authService = AuthService()
    let repositoryService = RepositoryService()

    init() {
        checkAuthenticationStatus()
    }

    private func checkAuthenticationStatus() {
        // Check if user has valid token in Keychain
        Task {
            do {
                let token = try await authService.retrieveStoredToken()
                if !token.isExpired {
                    self.isAuthenticated = true
                    // TODO: Fetch user info
                }
            } catch {
                print("No stored authentication token")
            }
        }
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
        selectedRepository = nil

        Task {
            try? await authService.clearToken()
        }
    }
}
