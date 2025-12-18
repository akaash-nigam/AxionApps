//
//  MainMenuView.swift
//  Mystery Investigation
//
//  Main menu screen
//

import SwiftUI

struct MainMenuView: View {
    @Environment(GameCoordinator.self) private var coordinator
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Background (detective office aesthetic)
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                VStack(spacing: 10) {
                    Text("MYSTERY")
                        .font(.system(size: 60, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("INVESTIGATION")
                        .font(.system(size: 48, weight: .light, design: .serif))
                        .foregroundColor(.yellow)
                }
                .padding(.top, 60)

                // Tagline
                Text("Become the detective in your own crime scene")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                // Menu buttons
                VStack(spacing: 20) {
                    MenuButton(title: "Start New Case", icon: "play.fill") {
                        coordinator.currentState = .caseSelection
                    }

                    MenuButton(title: "Continue Investigation", icon: "arrow.clockwise") {
                        // Load last saved case
                    }
                    .opacity(coordinator.playerProgress.inProgressCases.isEmpty ? 0.5 : 1.0)
                    .disabled(coordinator.playerProgress.inProgressCases.isEmpty)

                    MenuButton(title: "Case Archives", icon: "folder.fill") {
                        // Show completed cases
                    }

                    MenuButton(title: "Settings", icon: "gearshape.fill") {
                        showSettings = true
                    }

                    MenuButton(title: "How to Play", icon: "questionmark.circle.fill") {
                        // Show tutorial
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Player stats
                HStack(spacing: 40) {
                    StatBadge(
                        label: "Rank",
                        value: coordinator.playerProgress.detectiveRank.rawValue
                    )

                    StatBadge(
                        label: "Cases Solved",
                        value: "\(coordinator.playerProgress.completedCases.count)"
                    )

                    StatBadge(
                        label: "XP",
                        value: "\(coordinator.playerProgress.totalXP)"
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.title3)

                Spacer()
            }
            .padding()
            .frame(maxWidth: 600)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatBadge: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MainMenuView()
        .environment(GameCoordinator())
}
