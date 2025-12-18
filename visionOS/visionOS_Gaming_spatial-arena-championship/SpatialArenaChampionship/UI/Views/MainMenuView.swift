//
//  MainMenuView.swift
//  Spatial Arena Championship
//
//  Main menu view
//

import SwiftUI

struct MainMenuView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.black, Color(hex: 0x1a1a2e)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                VStack(spacing: 10) {
                    Text("SPATIAL ARENA")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0x00d4ff), Color(hex: 0x00bfff)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("CHAMPIONSHIP")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xaaaaaa))
                }
                .padding(.top, 60)

                // Player Info
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(appState.localPlayer.username)
                            .font(.title2)
                            .fontWeight(.semibold)

                        HStack {
                            Text(appState.localPlayer.rank.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text("SR: \(appState.localPlayer.skillRating)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text("Level \(appState.localPlayer.level)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 60)

                Spacer()

                // Main Menu Buttons
                VStack(spacing: 20) {
                    MenuButton(
                        title: "PLAY",
                        subtitle: "Start a match",
                        icon: "play.fill",
                        color: Color(hex: 0x00d4ff)
                    ) {
                        startMatch()
                    }

                    MenuButton(
                        title: "TRAINING",
                        subtitle: "Practice your skills",
                        icon: "figure.run",
                        color: Color(hex: 0x00ff88)
                    ) {
                        startTraining()
                    }

                    MenuButton(
                        title: "PROFILE",
                        subtitle: "View stats and progress",
                        icon: "person.fill",
                        color: Color(hex: 0xffaa00)
                    ) {
                        // Navigate to profile
                    }

                    MenuButton(
                        title: "SETTINGS",
                        subtitle: "Configure game settings",
                        icon: "gearshape.fill",
                        color: Color(hex: 0xaaaaaa)
                    ) {
                        // Navigate to settings
                    }
                }
                .frame(maxWidth: 500)

                Spacer()

                // Footer
                HStack {
                    Text("v1.0.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    if appState.isOnline {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)

                            Text("Online")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)

                            Text("Offline")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Actions

    private func startMatch() {
        Task {
            await openImmersiveSpace(id: "ArenaSpace")
            // TODO: Start matchmaking
        }
    }

    private func startTraining() {
        Task {
            await openImmersiveSpace(id: "ArenaSpace")
            // TODO: Start training mode
        }
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isHovered ? 0.15 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(isHovered ? 0.5 : 0.2), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
        .environment(AppState())
}
