//
//  MainMenuView.swift
//  Reality Realms RPG
//
//  Main menu for the game
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @EnvironmentObject var appModel: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @State private var showSettings = false
    @State private var showCredits = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 10) {
                    Text("Reality Realms")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("The Living Room RPG")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)

                // Menu buttons
                VStack(spacing: 20) {
                    MenuButton(title: "Start Adventure", icon: "play.fill") {
                        startGame()
                    }

                    MenuButton(title: "Continue", icon: "arrow.right.circle.fill") {
                        continueGame()
                    }
                    .opacity(hasSaveData ? 1.0 : 0.5)
                    .disabled(!hasSaveData)

                    MenuButton(title: "Settings", icon: "gearshape.fill") {
                        showSettings = true
                    }

                    MenuButton(title: "Credits", icon: "info.circle.fill") {
                        showCredits = true
                    }
                }
                .padding(.horizontal, 60)

                Spacer()

                // Version info
                Text("Version 1.0.0 • visionOS 2.0+")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showCredits) {
            CreditsView()
        }
    }

    // MARK: - Actions

    private func startGame() {
        Task {
            await openImmersiveSpace(id: "GameSpace")
            appModel.isImmersiveSpaceOpen = true
            gameStateManager.startGame()
        }
    }

    private func continueGame() {
        // Load save data and start
        Task {
            await openImmersiveSpace(id: "GameSpace")
            appModel.isImmersiveSpaceOpen = true
            gameStateManager.startGame()
        }
    }

    private var hasSaveData: Bool {
        // Check if save data exists
        // TODO: Implement actual save data check
        return false
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isHovered ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Gameplay") {
                    Toggle("Tutorial Hints", isOn: .constant(true))
                    Picker("Difficulty", selection: .constant("Normal")) {
                        Text("Story").tag("Story")
                        Text("Easy").tag("Easy")
                        Text("Normal").tag("Normal")
                        Text("Hard").tag("Hard")
                        Text("Nightmare").tag("Nightmare")
                    }
                }

                Section("Graphics") {
                    Picker("Quality", selection: .constant("High")) {
                        Text("Performance").tag("Performance")
                        Text("Low").tag("Low")
                        Text("Medium").tag("Medium")
                        Text("High").tag("High")
                        Text("Ultra").tag("Ultra")
                    }
                }

                Section("Audio") {
                    Toggle("Music", isOn: .constant(true))
                    Toggle("Sound Effects", isOn: .constant(true))
                    Toggle("Voice Chat", isOn: .constant(true))
                }

                Section("Accessibility") {
                    Toggle("One-Handed Mode", isOn: .constant(false))
                    Toggle("Seated Play", isOn: .constant(false))
                    Picker("Gesture Sensitivity", selection: .constant("Medium")) {
                        Text("Low").tag("Low")
                        Text("Medium").tag("Medium")
                        Text("High").tag("High")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

// MARK: - Credits View

struct CreditsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Reality Realms RPG")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Created for Apple Vision Pro")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 20) {
                        CreditSection(title: "Development") {
                            CreditLine(role: "Game Design", name: "Reality Realms Team")
                            CreditLine(role: "Programming", name: "Claude & Team")
                            CreditLine(role: "Technical Architecture", name: "visionOS Specialists")
                        }

                        CreditSection(title: "Art & Audio") {
                            CreditLine(role: "Visual Design", name: "Art Team")
                            CreditLine(role: "3D Models", name: "3D Artists")
                            CreditLine(role: "Music & SFX", name: "Sound Designers")
                        }

                        CreditSection(title: "Special Thanks") {
                            Text("All our beta testers and early supporters")
                                .foregroundColor(.secondary)
                            Text("Apple for the incredible visionOS platform")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Credits")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

struct CreditSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            content()
        }
    }
}

struct CreditLine: View {
    let role: String
    let name: String

    var body: some View {
        HStack {
            Text(role)
                .foregroundColor(.secondary)
            Spacer()
            Text(name)
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(GameStateManager.shared)
        .environmentObject(AppModel())
}
