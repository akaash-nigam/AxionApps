//
//  WelcomeView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon and branding
            VStack(spacing: 16) {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: isAuthenticating)

                Text("Spatial Code Reviewer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Transform code review into an immersive 3D experience")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Features highlights
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "cube.fill",
                    title: "3D Code Visualization",
                    description: "View code files floating in space"
                )

                FeatureRow(
                    icon: "arrow.triangle.branch",
                    title: "Dependency Graphs",
                    description: "See relationships between files"
                )

                FeatureRow(
                    icon: "person.2.fill",
                    title: "Team Collaboration",
                    description: "Review code together in real-time"
                )
            }
            .padding(.horizontal, 40)

            Spacer()

            // Connect button
            VStack(spacing: 16) {
                Button {
                    authenticateWithGitHub()
                } label: {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                        }

                        Text("Connect GitHub")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isAuthenticating)

                Text("By connecting, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func authenticateWithGitHub() {
        isAuthenticating = true

        Task {
            do {
                try await appState.authService.authenticate(provider: .github)
                await MainActor.run {
                    appState.isAuthenticated = true
                    isAuthenticating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isAuthenticating = false
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
