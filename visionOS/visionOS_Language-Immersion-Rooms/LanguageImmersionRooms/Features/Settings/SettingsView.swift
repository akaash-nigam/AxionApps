//
//  SettingsView.swift
//  Language Immersion Rooms
//
//  Settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // User section
                Section("Account") {
                    if let user = appState.currentUser {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(user.username)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Sign Out", role: .destructive) {
                        appState.signOut()
                        dismiss()
                    }
                }

                // Language section
                Section("Language") {
                    HStack {
                        Text("Learning")
                        Spacer()
                        Text("\(appState.currentLanguage.flag) \(appState.currentLanguage.name)")
                            .foregroundStyle(.secondary)
                    }
                }

                // Display section
                Section("Display") {
                    Picker("Label Size", selection: $appState.labelSize) {
                        Text("Small").tag(LabelSize.small)
                        Text("Medium").tag(LabelSize.medium)
                        Text("Large").tag(LabelSize.large)
                    }
                }

                // Audio section
                Section("Audio") {
                    HStack {
                        Text("Speech Speed")
                        Spacer()
                        Text("\(appState.speechSpeed, specifier: "%.1f")x")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $appState.speechSpeed, in: 0.5...2.0, step: 0.1)
                }

                // Learning section
                Section("Learning") {
                    Toggle("Show Grammar Help", isOn: $appState.showGrammarHelp)
                }

                // About section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundStyle(.secondary)
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
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
