//
//  SettingsViewModel.swift
//  SurgicalTrainingUniverse
//
//  ViewModel for Settings view - manages user preferences and app configuration
//

import Foundation
import SwiftData
import Observation

@Observable
final class SettingsViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - Published State

    var currentUser: SurgeonProfile?
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    // Profile Settings
    var editedName: String = ""
    var editedEmail: String = ""
    var editedSpecialization: SurgicalSpecialty = .generalSurgery
    var editedLevel: TrainingLevel = .resident1
    var editedInstitution: String = ""

    // App Preferences
    var hapticFeedbackEnabled = true
    var soundEffectsEnabled = true
    var spatialAudioEnabled = true
    var aiCoachingEnabled = true
    var realTimeAnalyticsEnabled = true
    var autoSaveEnabled = true

    // Display Settings
    var showPerformanceHUD = true
    var showAIInsights = true
    var showGridLines = false
    var lightingMode: LightingMode = .realistic

    // Privacy Settings
    var shareAnonymousData = false
    var recordSessions = true
    var saveRecordings = true

    // Accessibility
    var reduceMotion = false
    var increaseContrast = false
    var voiceGuidanceEnabled = false

    // MARK: - Computed Properties

    var isProfileValid: Bool {
        !editedName.isEmpty && !editedEmail.isEmpty && editedEmail.contains("@")
    }

    var hasUnsavedChanges: Bool {
        guard let user = currentUser else { return false }

        return editedName != user.name ||
               editedEmail != user.email ||
               editedSpecialization != user.specialization ||
               editedLevel != user.level ||
               editedInstitution != user.institution
    }

    var specializationDisplayName: String {
        switch editedSpecialization {
        case .generalSurgery: return "General Surgery"
        case .cardiacSurgery: return "Cardiac Surgery"
        case .neurosurgery: return "Neurosurgery"
        case .orthopedics: return "Orthopedics"
        case .traumaSurgery: return "Trauma Surgery"
        case .roboticSurgery: return "Robotic Surgery"
        }
    }

    var trainingLevelDisplayName: String {
        switch editedLevel {
        case .medicalStudent: return "Medical Student"
        case .resident1: return "PGY-1 Resident"
        case .resident2: return "PGY-2 Resident"
        case .resident3: return "PGY-3 Resident"
        case .chiefResident: return "Chief Resident"
        case .fellow: return "Fellow"
        case .attending: return "Attending Surgeon"
        }
    }

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        currentUser: SurgeonProfile? = nil
    ) {
        self.modelContext = modelContext
        self.currentUser = currentUser

        loadPreferences()
        loadUserProfile()
    }

    // MARK: - Profile Management

    /// Load current user profile data
    func loadUserProfile() {
        guard let user = currentUser else { return }

        editedName = user.name
        editedEmail = user.email
        editedSpecialization = user.specialization
        editedLevel = user.level
        editedInstitution = user.institution
    }

    /// Save profile changes
    @MainActor
    func saveProfile() async {
        guard let user = currentUser, isProfileValid else {
            errorMessage = "Please fill in all required fields"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            // Update user profile
            user.name = editedName
            user.email = editedEmail
            user.specialization = editedSpecialization
            user.level = editedLevel
            user.institution = editedInstitution

            try modelContext.save()

            successMessage = "Profile updated successfully"

        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Discard profile changes
    func discardChanges() {
        loadUserProfile()
    }

    // MARK: - Preferences Management

    /// Load app preferences from UserDefaults
    private func loadPreferences() {
        let defaults = UserDefaults.standard

        hapticFeedbackEnabled = defaults.bool(forKey: "hapticFeedbackEnabled", default: true)
        soundEffectsEnabled = defaults.bool(forKey: "soundEffectsEnabled", default: true)
        spatialAudioEnabled = defaults.bool(forKey: "spatialAudioEnabled", default: true)
        aiCoachingEnabled = defaults.bool(forKey: "aiCoachingEnabled", default: true)
        realTimeAnalyticsEnabled = defaults.bool(forKey: "realTimeAnalyticsEnabled", default: true)
        autoSaveEnabled = defaults.bool(forKey: "autoSaveEnabled", default: true)

        showPerformanceHUD = defaults.bool(forKey: "showPerformanceHUD", default: true)
        showAIInsights = defaults.bool(forKey: "showAIInsights", default: true)
        showGridLines = defaults.bool(forKey: "showGridLines", default: false)

        if let lightingValue = defaults.string(forKey: "lightingMode"),
           let lighting = LightingMode(rawValue: lightingValue) {
            lightingMode = lighting
        }

        shareAnonymousData = defaults.bool(forKey: "shareAnonymousData", default: false)
        recordSessions = defaults.bool(forKey: "recordSessions", default: true)
        saveRecordings = defaults.bool(forKey: "saveRecordings", default: true)

        reduceMotion = defaults.bool(forKey: "reduceMotion", default: false)
        increaseContrast = defaults.bool(forKey: "increaseContrast", default: false)
        voiceGuidanceEnabled = defaults.bool(forKey: "voiceGuidanceEnabled", default: false)
    }

    /// Save preferences to UserDefaults
    func savePreferences() {
        let defaults = UserDefaults.standard

        defaults.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
        defaults.set(soundEffectsEnabled, forKey: "soundEffectsEnabled")
        defaults.set(spatialAudioEnabled, forKey: "spatialAudioEnabled")
        defaults.set(aiCoachingEnabled, forKey: "aiCoachingEnabled")
        defaults.set(realTimeAnalyticsEnabled, forKey: "realTimeAnalyticsEnabled")
        defaults.set(autoSaveEnabled, forKey: "autoSaveEnabled")

        defaults.set(showPerformanceHUD, forKey: "showPerformanceHUD")
        defaults.set(showAIInsights, forKey: "showAIInsights")
        defaults.set(showGridLines, forKey: "showGridLines")
        defaults.set(lightingMode.rawValue, forKey: "lightingMode")

        defaults.set(shareAnonymousData, forKey: "shareAnonymousData")
        defaults.set(recordSessions, forKey: "recordSessions")
        defaults.set(saveRecordings, forKey: "saveRecordings")

        defaults.set(reduceMotion, forKey: "reduceMotion")
        defaults.set(increaseContrast, forKey: "increaseContrast")
        defaults.set(voiceGuidanceEnabled, forKey: "voiceGuidanceEnabled")

        successMessage = "Preferences saved"
    }

    /// Reset all preferences to defaults
    func resetPreferences() {
        hapticFeedbackEnabled = true
        soundEffectsEnabled = true
        spatialAudioEnabled = true
        aiCoachingEnabled = true
        realTimeAnalyticsEnabled = true
        autoSaveEnabled = true

        showPerformanceHUD = true
        showAIInsights = true
        showGridLines = false
        lightingMode = .realistic

        shareAnonymousData = false
        recordSessions = true
        saveRecordings = true

        reduceMotion = false
        increaseContrast = false
        voiceGuidanceEnabled = false

        savePreferences()
    }

    // MARK: - Data Management

    /// Export user data
    func exportUserData() -> String {
        guard let user = currentUser else {
            return "No user data available"
        }

        var data = "SURGICAL TRAINING UNIVERSE - USER DATA EXPORT\n"
        data += "Generated: \(Date())\n\n"
        data += "PROFILE\n"
        data += "Name: \(user.name)\n"
        data += "Email: \(user.email)\n"
        data += "Specialization: \(specializationDisplayName)\n"
        data += "Level: \(trainingLevelDisplayName)\n"
        data += "Institution: \(user.institution)\n\n"
        data += "STATISTICS\n"
        data += "Total Procedures: \(user.totalProcedures)\n"
        data += "Average Accuracy: \(String(format: "%.1f%%", user.averageAccuracy))\n"
        data += "Average Efficiency: \(String(format: "%.1f%%", user.averageEfficiency))\n"
        data += "Average Safety: \(String(format: "%.1f%%", user.averageSafety))\n"

        return data
    }

    /// Clear all user data
    @MainActor
    func clearAllData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Delete all sessions, certifications, etc.
            // This is a destructive operation
            if let user = currentUser {
                for session in user.sessions {
                    modelContext.delete(session)
                }
                try modelContext.save()
                successMessage = "All data cleared successfully"
            }

        } catch {
            errorMessage = "Failed to clear data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - App Information

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var fullVersion: String {
        "Version \(appVersion) (\(buildNumber))"
    }

    // MARK: - Validation

    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Supporting Types

enum LightingMode: String, CaseIterable {
    case realistic = "realistic"
    case bright = "bright"
    case dim = "dim"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .realistic: return "Realistic"
        case .bright: return "Bright"
        case .dim: return "Dim"
        case .custom: return "Custom"
        }
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}
