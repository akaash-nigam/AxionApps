//
//  SettingsView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showProfile = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section {
                    Button {
                        showProfile = true
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("User Profile")
                                    .font(.headline)

                                Text("Manage your preferences and measurements")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Integrations
                Section("Integrations") {
                    Toggle("Weather Integration", isOn: $viewModel.enableWeatherIntegration)
                    Toggle("Calendar Integration", isOn: $viewModel.enableCalendarIntegration)
                    Toggle("Notifications", isOn: $viewModel.enableNotifications)
                }

                // Display
                Section("Display") {
                    Picker("Temperature Unit", selection: $viewModel.temperatureUnit) {
                        Text("Fahrenheit").tag(TemperatureUnit.fahrenheit)
                        Text("Celsius").tag(TemperatureUnit.celsius)
                    }
                }

                // Data & Privacy
                Section("Data & Privacy") {
                    NavigationLink {
                        DataPrivacyView()
                    } label: {
                        Label("Data & Privacy", systemImage: "hand.raised.fill")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash.fill")
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About Wardrobe Consultant", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showProfile) {
                UserProfileView()
            }
            .confirmationDialog(
                "Delete All Data",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    Task {
                        await viewModel.deleteAllData()
                    }
                }
            } message: {
                Text("This will permanently delete all your wardrobe items, outfits, and profile data. This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                await viewModel.loadSettings()
            }
            .onChange(of: viewModel.enableWeatherIntegration) { _, _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.enableCalendarIntegration) { _, _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.enableNotifications) { _, _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.temperatureUnit) { _, _ in
                Task { await viewModel.saveSettings() }
            }
        }
    }
}

// MARK: - Settings ViewModel
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var enableWeatherIntegration = true
    @Published var enableCalendarIntegration = true
    @Published var enableNotifications = true
    @Published var temperatureUnit: TemperatureUnit = .fahrenheit
    @Published var errorMessage: String?

    private let userProfileRepository: UserProfileRepository
    private let wardrobeRepository: WardrobeRepository
    private let outfitRepository: OutfitRepository

    init(
        userProfileRepository: UserProfileRepository = CoreDataUserProfileRepository.shared,
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared,
        outfitRepository: OutfitRepository = CoreDataOutfitRepository.shared
    ) {
        self.userProfileRepository = userProfileRepository
        self.wardrobeRepository = wardrobeRepository
        self.outfitRepository = outfitRepository
    }

    func loadSettings() async {
        do {
            let profile = try await userProfileRepository.fetch()
            enableWeatherIntegration = profile.enableWeatherIntegration
            enableCalendarIntegration = profile.enableCalendarIntegration
            enableNotifications = profile.enableNotifications
            temperatureUnit = profile.temperatureUnit
        } catch {
            errorMessage = "Failed to load settings: \(error.localizedDescription)"
        }
    }

    func saveSettings() async {
        do {
            var profile = try await userProfileRepository.fetch()
            profile.enableWeatherIntegration = enableWeatherIntegration
            profile.enableCalendarIntegration = enableCalendarIntegration
            profile.enableNotifications = enableNotifications
            profile.temperatureUnit = temperatureUnit
            try await userProfileRepository.update(profile)
        } catch {
            errorMessage = "Failed to save settings: \(error.localizedDescription)"
        }
    }

    func deleteAllData() async {
        do {
            try await wardrobeRepository.deleteAll()
            try await outfitRepository.deleteAll()
            try await userProfileRepository.delete()
            try await userProfileRepository.deleteBodyMeasurements()
        } catch {
            errorMessage = "Failed to delete data: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Privacy View
struct DataPrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Privacy Matters")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Wardrobe Consultant is designed with privacy-by-design principles:")
                    .font(.body)

                VStack(alignment: .leading, spacing: 12) {
                    PrivacyFeature(
                        icon: "lock.shield.fill",
                        title: "Local Storage",
                        description: "All your data is stored locally on your device using encrypted Core Data."
                    )

                    PrivacyFeature(
                        icon: "key.fill",
                        title: "Keychain Protection",
                        description: "Sensitive information like body measurements are stored in the secure Keychain."
                    )

                    PrivacyFeature(
                        icon: "photo.fill",
                        title: "Photo Privacy",
                        description: "Photos are stored with complete file protection and never leave your device."
                    )

                    PrivacyFeature(
                        icon: "cloud.slash.fill",
                        title: "No Cloud Sync",
                        description: "Your data stays on your device. We don't have access to any of your personal information."
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)

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

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "hanger")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Wardrobe Consultant")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .foregroundStyle(.secondary)

                Text("Your personal AI-powered wardrobe assistant for visionOS")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.vertical)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.headline)

                    FeatureRow(icon: "tshirt.fill", text: "Digital wardrobe management")
                    FeatureRow(icon: "sparkles", text: "AI outfit suggestions")
                    FeatureRow(icon: "cube.fill", text: "Virtual try-on with AR")
                    FeatureRow(icon: "cloud.sun.fill", text: "Weather-based recommendations")
                    FeatureRow(icon: "lock.shield.fill", text: "Privacy-first design")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(text)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
