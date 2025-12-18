//
//  AccessibilityManager.swift
//  Parkour Pathways
//
//  Comprehensive accessibility features for inclusive gaming
//

import Foundation
import SwiftUI
import Combine

/// Manages accessibility features for inclusive gameplay
@MainActor
class AccessibilityManager: ObservableObject {

    // MARK: - Published Properties

    @Published var isVoiceOverEnabled: Bool = false
    @Published var isReduceMotionEnabled: Bool = false
    @Published var isColorBlindModeEnabled: Bool = false
    @Published var colorBlindMode: ColorBlindMode = .none
    @Published var textSizeMultiplier: CGFloat = 1.0
    @Published var contrastLevel: ContrastLevel = .standard
    @Published var assistiveDifficultyEnabled: Bool = false
    @Published var audioDescriptionsEnabled: Bool = false

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        observeSystemSettings()
        loadUserPreferences()
    }

    // MARK: - Setup

    private func observeSystemSettings() {
        // Observe VoiceOver
        NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
            }
            .store(in: &cancellables)

        // Observe Reduce Motion
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .sink { [weak self] _ in
                self?.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
            }
            .store(in: &cancellables)

        // Set initial values
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
    }

    private func loadUserPreferences() {
        // Load from UserDefaults
        if let colorBlindModeRaw = UserDefaults.standard.string(forKey: "colorBlindMode"),
           let mode = ColorBlindMode(rawValue: colorBlindModeRaw) {
            colorBlindMode = mode
            isColorBlindModeEnabled = mode != .none
        }

        textSizeMultiplier = CGFloat(UserDefaults.standard.float(forKey: "textSizeMultiplier"))
        if textSizeMultiplier == 0 {
            textSizeMultiplier = 1.0
        }

        if let contrastRaw = UserDefaults.standard.string(forKey: "contrastLevel"),
           let contrast = ContrastLevel(rawValue: contrastRaw) {
            contrastLevel = contrast
        }

        assistiveDifficultyEnabled = UserDefaults.standard.bool(forKey: "assistiveDifficultyEnabled")
        audioDescriptionsEnabled = UserDefaults.standard.bool(forKey: "audioDescriptionsEnabled")
    }

    // MARK: - Public API - Visual Accessibility

    /// Enable color blind mode
    func setColorBlindMode(_ mode: ColorBlindMode) {
        colorBlindMode = mode
        isColorBlindModeEnabled = mode != .none
        UserDefaults.standard.set(mode.rawValue, forKey: "colorBlindMode")

        announceForAccessibility("Color blind mode set to \(mode.displayName)")
    }

    /// Set text size multiplier
    func setTextSizeMultiplier(_ multiplier: CGFloat) {
        textSizeMultiplier = max(0.75, min(2.0, multiplier))
        UserDefaults.standard.set(Float(textSizeMultiplier), forKey: "textSizeMultiplier")

        announceForAccessibility("Text size set to \(Int(textSizeMultiplier * 100))%")
    }

    /// Set contrast level
    func setContrastLevel(_ level: ContrastLevel) {
        contrastLevel = level
        UserDefaults.standard.set(level.rawValue, forKey: "contrastLevel")

        announceForAccessibility("Contrast set to \(level.displayName)")
    }

    /// Apply color filter for color blind mode
    func applyColorFilter(to color: Color) -> Color {
        guard isColorBlindModeEnabled else { return color }

        // Convert to RGB components
        // Note: Simplified implementation - would use proper color space conversion
        switch colorBlindMode {
        case .none:
            return color
        case .protanopia:
            return adjustColorForProtanopia(color)
        case .deuteranopia:
            return adjustColorForDeuteranopia(color)
        case .tritanopia:
            return adjustColorForTritanopia(color)
        }
    }

    // MARK: - Public API - Gameplay Accessibility

    /// Enable assistive difficulty adjustments
    func setAssistiveDifficulty(_ enabled: Bool) {
        assistiveDifficultyEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "assistiveDifficultyEnabled")

        announceForAccessibility(enabled ? "Assistive difficulty enabled" : "Assistive difficulty disabled")
    }

    /// Get difficulty modifiers for assistive mode
    func getDifficultyModifiers() -> DifficultyModifiers {
        guard assistiveDifficultyEnabled else {
            return DifficultyModifiers()
        }

        return DifficultyModifiers(
            timeMultiplier: 1.5, // 50% more time
            precisionTolerance: 1.3, // 30% larger target zones
            safetyMargin: 1.2, // 20% larger safety margins
            checkpointFrequency: 1.5 // 50% more checkpoints
        )
    }

    // MARK: - Public API - Audio Accessibility

    /// Enable audio descriptions
    func setAudioDescriptions(_ enabled: Bool) {
        audioDescriptionsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "audioDescriptionsEnabled")

        announceForAccessibility(enabled ? "Audio descriptions enabled" : "Audio descriptions disabled")
    }

    /// Get audio description for gameplay event
    func getAudioDescription(for event: GameplayEvent) -> String? {
        guard audioDescriptionsEnabled else { return nil }

        switch event {
        case .jumpStarted(let height):
            return "Preparing to jump \(Int(height * 100)) centimeters"

        case .landingSuccessful(let score):
            let quality = score > 0.9 ? "perfect" : score > 0.7 ? "good" : "okay"
            return "Landed \(quality)"

        case .vaultPerformed(let type):
            return "Performed \(type) vault"

        case .checkpointReached(let index, let total):
            return "Reached checkpoint \(index) of \(total)"

        case .courseComplete(let score):
            let performance = score > 0.9 ? "excellent" : score > 0.7 ? "good" : "completed"
            return "Course \(performance), score \(Int(score * 100))%"

        case .obstacleDetected(let distance, let type):
            return "\(type) ahead, \(Int(distance)) meters"
        }
    }

    // MARK: - Public API - VoiceOver Support

    /// Announce message for VoiceOver
    func announceForAccessibility(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    /// Get accessibility label for UI element
    func accessibilityLabel(for element: GameElement) -> String {
        switch element {
        case .precisionTarget(let distance, let size):
            return "Precision target, \(Int(distance)) meters away, \(Int(size * 100)) centimeters diameter"

        case .vaultBox(let height, let distance):
            return "Vault box, \(Int(height * 100)) centimeters high, \(Int(distance)) meters away"

        case .wallTarget(let height, let distance):
            return "Wall target, \(Int(height * 100)) centimeters high, \(Int(distance)) meters away"

        case .checkpoint(let index, let total):
            return "Checkpoint \(index) of \(total)"

        case .safeZone:
            return "Safe zone"

        case .dangerZone:
            return "Danger zone, proceed with caution"
        }
    }

    /// Get accessibility hint for UI element
    func accessibilityHint(for element: GameElement) -> String? {
        switch element {
        case .precisionTarget:
            return "Jump to land on this target"

        case .vaultBox:
            return "Place hands on box and vault over"

        case .wallTarget:
            return "Run and touch this target on the wall"

        case .checkpoint:
            return "Pass through to save progress"

        case .safeZone:
            return "Safe area to rest"

        case .dangerZone:
            return "Avoid this area"
        }
    }

    // MARK: - Public API - Input Accessibility

    /// Check if simplified controls should be used
    func shouldUseSimplifiedControls() -> Bool {
        return assistiveDifficultyEnabled || isVoiceOverEnabled
    }

    /// Get control assistance level
    func getControlAssistanceLevel() -> Float {
        if isVoiceOverEnabled {
            return 0.8 // High assistance for VoiceOver users
        } else if assistiveDifficultyEnabled {
            return 0.5 // Medium assistance
        } else {
            return 0.0 // No assistance
        }
    }

    // MARK: - Private Helpers - Color Adjustments

    private func adjustColorForProtanopia(_ color: Color) -> Color {
        // Simplified protanopia (red-blind) adjustment
        // Would use proper LMS color space transformation in production
        return color
    }

    private func adjustColorForDeuteranopia(_ color: Color) -> Color {
        // Simplified deuteranopia (green-blind) adjustment
        return color
    }

    private func adjustColorForTritanopia(_ color: Color) -> Color {
        // Simplified tritanopia (blue-blind) adjustment
        return color
    }
}

// MARK: - Supporting Types

enum ColorBlindMode: String {
    case none = "none"
    case protanopia = "protanopia" // Red-blind
    case deuteranopia = "deuteranopia" // Green-blind
    case tritanopia = "tritanopia" // Blue-blind

    var displayName: String {
        switch self {
        case .none: return "None"
        case .protanopia: return "Protanopia (Red-Blind)"
        case .deuteranopia: return "Deuteranopia (Green-Blind)"
        case .tritanopia: return "Tritanopia (Blue-Blind)"
        }
    }
}

enum ContrastLevel: String {
    case standard = "standard"
    case high = "high"
    case maximum = "maximum"

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .high: return "High"
        case .maximum: return "Maximum"
        }
    }
}

struct DifficultyModifiers {
    var timeMultiplier: Float = 1.0
    var precisionTolerance: Float = 1.0
    var safetyMargin: Float = 1.0
    var checkpointFrequency: Float = 1.0
}

enum GameplayEvent {
    case jumpStarted(height: Float)
    case landingSuccessful(score: Float)
    case vaultPerformed(type: String)
    case checkpointReached(index: Int, total: Int)
    case courseComplete(score: Float)
    case obstacleDetected(distance: Float, type: String)
}

enum GameElement {
    case precisionTarget(distance: Float, size: Float)
    case vaultBox(height: Float, distance: Float)
    case wallTarget(height: Float, distance: Float)
    case checkpoint(index: Int, total: Int)
    case safeZone
    case dangerZone
}
