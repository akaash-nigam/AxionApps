//
//  SettingsView.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var difficulty: AIDifficulty = .medium
    @State private var enableVoiceOver: Bool = false
    @State private var highContrast: Bool = false
    @State private var reducedMotion: Bool = false
    @State private var masterVolume: Double = 0.8
    @State private var sfxVolume: Double = 0.7
    @State private var musicVolume: Double = 0.5

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()

                    // Gameplay Settings
                    SettingsSection(title: "Gameplay") {
                        Picker("AI Difficulty", selection: $difficulty) {
                            ForEach(AIDifficulty.allCases, id: \.self) { diff in
                                Text(diff.rawValue).tag(diff)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Audio Settings
                    SettingsSection(title: "Audio") {
                        VolumeSlider(title: "Master Volume", value: $masterVolume)
                        VolumeSlider(title: "Effects Volume", value: $sfxVolume)
                        VolumeSlider(title: "Music Volume", value: $musicVolume)
                    }

                    // Accessibility Settings
                    SettingsSection(title: "Accessibility") {
                        Toggle("VoiceOver Support", isOn: $enableVoiceOver)
                        Toggle("High Contrast", isOn: $highContrast)
                        Toggle("Reduce Motion", isOn: $reducedMotion)
                    }

                    // Account
                    SettingsSection(title: "Account") {
                        if let warrior = appState.currentUser {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Logged in as:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("\(warrior.rank.rawValue) \(warrior.name)")
                                    .font(.subheadline)
                                    .bold()

                                Text(warrior.unit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Button("Logout") {
                                    appState.logout()
                                    dismiss()
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 8)
                            }
                        }
                    }

                    // Close button
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Divider()

            content
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .frame(maxWidth: 600)
    }
}

struct VolumeSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(value: $value, in: 0...1)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
