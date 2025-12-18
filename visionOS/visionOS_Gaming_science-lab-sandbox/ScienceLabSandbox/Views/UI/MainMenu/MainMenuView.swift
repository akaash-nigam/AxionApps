//
//  MainMenuView.swift
//  Science Lab Sandbox
//
//  Main menu view for the application
//

import SwiftUI

struct MainMenuView: View {

    @EnvironmentObject var gameCoordinator: GameCoordinator
    @EnvironmentObject var appState: AppState

    @State private var showSettings = false
    @State private var showProgress = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Text("Science Lab Sandbox")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Experiment with the universe from your living room")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 60)

                Spacer()

                // Main Menu Buttons
                VStack(spacing: 20) {
                    // New Experiment
                    MenuButton(
                        title: "New Experiment",
                        icon: "flask.fill",
                        color: .blue
                    ) {
                        gameCoordinator.transitionToLaboratorySelection()
                    }

                    // Continue
                    if gameCoordinator.currentExperiment != nil {
                        MenuButton(
                            title: "Continue",
                            icon: "play.fill",
                            color: .green
                        ) {
                            gameCoordinator.resumeExperiment()
                        }
                    }

                    // Laboratory Selection
                    MenuButton(
                        title: "Choose Laboratory",
                        icon: "square.grid.2x2.fill",
                        color: .purple
                    ) {
                        gameCoordinator.transitionToLaboratorySelection()
                    }

                    // Progress
                    MenuButton(
                        title: "My Progress",
                        icon: "chart.bar.fill",
                        color: .orange
                    ) {
                        showProgress = true
                    }

                    // Settings
                    MenuButton(
                        title: "Settings",
                        icon: "gearshape.fill",
                        color: .gray
                    ) {
                        showSettings = true
                    }
                }
                .padding(.horizontal, 100)

                Spacer()

                // Footer
                PlayerStatsFooter()
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showProgress) {
            ProgressView()
                .environmentObject(gameCoordinator)
        }
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .frame(width: 50)

                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.title3)
                    .opacity(isHovered ? 1.0 : 0.5)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(isHovered ? 0.3 : 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: isHovered ? 3 : 2)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Player Stats Footer

struct PlayerStatsFooter: View {
    @EnvironmentObject var gameCoordinator: GameCoordinator

    var body: some View {
        HStack(spacing: 40) {
            StatBadge(
                icon: "star.fill",
                value: "\(gameCoordinator.playerProgress.currentLevel)",
                label: "Level",
                color: .yellow
            )

            StatBadge(
                icon: "flame.fill",
                value: "\(gameCoordinator.playerProgress.completedExperiments.count)",
                label: "Experiments",
                color: .orange
            )

            StatBadge(
                icon: "trophy.fill",
                value: "\(gameCoordinator.playerProgress.achievements.count)",
                label: "Achievements",
                color: .purple
            )

            StatBadge(
                icon: "clock.fill",
                value: formatLabTime(gameCoordinator.playerProgress.totalLabTime),
                label: "Lab Time",
                color: .blue
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private func formatLabTime(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = Int(duration) / 60
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
        .environmentObject(GameCoordinator())
        .environmentObject(AppState())
}
