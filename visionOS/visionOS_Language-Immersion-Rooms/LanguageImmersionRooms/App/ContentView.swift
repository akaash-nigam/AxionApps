//
//  ContentView.swift
//  Language Immersion Rooms
//
//  Main menu view
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        Group {
            if appState.isOnboarding {
                OnboardingView()
            } else if !appState.isAuthenticated {
                SignInView()
            } else {
                MainMenuView()
            }
        }
    }
}

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 10) {
                    Text("Language Immersion Rooms")
                        .font(.system(size: 48, weight: .bold))

                    Text("Learn Spanish through immersive experiences")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // Progress Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("🇪🇸")
                            .font(.system(size: 40))

                        VStack(alignment: .leading) {
                            Text("Continue Learning Spanish")
                                .font(.title2)

                            Text("\(appState.wordsEncounteredToday) words today")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Streak
                        VStack {
                            Text("\(appState.currentStreak)")
                                .font(.system(size: 32, weight: .bold))
                            Text("day streak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Progress bar
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Today's Progress")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ProgressView(value: appState.todayProgress)
                            .tint(.green)
                    }

                    // Start button
                    Button {
                        startLearningSession()
                    } label: {
                        Label("Start Session", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(20)

                // Quick Actions
                HStack(spacing: 20) {
                    QuickActionButton(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress",
                        action: { appState.showingProgress = true }
                    )

                    QuickActionButton(
                        icon: "gearshape",
                        title: "Settings",
                        action: { appState.showingSettings = true }
                    )
                }
            }
            .padding(60)
        }
        .sheet(isPresented: $appState.showingProgress) {
            ProgressView()
        }
        .sheet(isPresented: $appState.showingSettings) {
            SettingsView()
        }
    }

    private func startLearningSession() {
        appState.startLearningSession()

        Task {
            await openImmersiveSpace(id: "LearningSpace")
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 48))

                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
}
