//
//  Character.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData

/// Character in a screenplay
@Model
final class Character {
    @Attribute(.unique) var id: UUID
    var name: String
    var age: Int?
    var gender: String?
    var characterDescription: String?
    var voice: VoiceSettings
    var appearance: AppearanceSettings
    var metadata: CharacterMetadata
    var createdAt: Date
    var modifiedAt: Date

    // Relationships
    @Relationship(inverse: \Scene.characters)
    var scenes: [Scene]?

    init(
        id: UUID = UUID(),
        name: String,
        age: Int? = nil,
        gender: String? = nil,
        characterDescription: String? = nil,
        voice: VoiceSettings = VoiceSettings(),
        appearance: AppearanceSettings = AppearanceSettings(),
        metadata: CharacterMetadata = CharacterMetadata(),
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.characterDescription = characterDescription
        self.voice = voice
        self.appearance = appearance
        self.metadata = metadata
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    /// Display name with age/gender if available
    var displayName: String {
        var display = name
        if let age = age {
            display += " (\(age))"
        }
        if let gender = gender {
            display += " - \(gender)"
        }
        return display
    }

    /// Color for this character (generated from name hash)
    var color: String {
        let hash = name.hashValue
        let colors = [
            "#F44336", "#E91E63", "#9C27B0", "#673AB7",
            "#3F51B5", "#2196F3", "#03A9F4", "#00BCD4",
            "#009688", "#4CAF50", "#8BC34A", "#CDDC39",
            "#FFC107", "#FF9800", "#FF5722", "#795548"
        ]
        return colors[abs(hash) % colors.count]
    }
}

// MARK: - Voice Settings

struct VoiceSettings: Codable, Hashable {
    var voiceId: String  // System voice ID or API voice ID
    var provider: VoiceProvider
    var pitch: Float  // 0.5 to 2.0
    var rate: Float   // 0.5 to 2.0
    var volume: Float  // 0.0 to 1.0
    var accent: String?
    var style: String?

    init(
        voiceId: String = "com.apple.voice.compact.en-US.Samantha",
        provider: VoiceProvider = .appleNeuralVoices,
        pitch: Float = 1.0,
        rate: Float = 1.0,
        volume: Float = 1.0,
        accent: String? = nil,
        style: String? = nil
    ) {
        self.voiceId = voiceId
        self.provider = provider
        self.pitch = pitch
        self.rate = rate
        self.volume = volume
        self.accent = accent
        self.style = style
    }

    /// Validate voice settings
    var isValid: Bool {
        pitch >= 0.5 && pitch <= 2.0 &&
        rate >= 0.5 && rate <= 2.0 &&
        volume >= 0.0 && volume <= 1.0
    }
}

enum VoiceProvider: String, Codable, CaseIterable {
    case appleNeuralVoices = "Apple Neural Voices"
    case elevenLabs = "ElevenLabs"
    case custom = "Custom"
}

// MARK: - Appearance Settings

struct AppearanceSettings: Codable, Hashable {
    var height: Float?  // in meters
    var build: String?
    var avatarId: String?  // Reference to 3D avatar asset
    var customModelURL: String?  // URL to custom USDZ model
    var defaultPosition: SpatialCoordinates?

    init(
        height: Float? = nil,
        build: String? = nil,
        avatarId: String? = nil,
        customModelURL: String? = nil,
        defaultPosition: SpatialCoordinates? = nil
    ) {
        self.height = height
        self.build = build
        self.avatarId = avatarId
        self.customModelURL = customModelURL
        self.defaultPosition = defaultPosition
    }

    /// Default height if not specified (1.7m ≈ 5'7")
    var effectiveHeight: Float {
        height ?? 1.7
    }
}

// MARK: - Character Extensions

extension Character {
    /// Sample characters for testing
    static func sampleCharacters() -> [Character] {
        [
            Character(
                name: "ALEX CHEN",
                age: 28,
                gender: "Non-binary",
                characterDescription: "A struggling writer with a secret",
                metadata: CharacterMetadata(role: .protagonist)
            ),
            Character(
                name: "SARAH MARTINEZ",
                age: 32,
                gender: "Female",
                characterDescription: "Alex's best friend and confidant",
                metadata: CharacterMetadata(role: .supporting)
            ),
            Character(
                name: "DETECTIVE MORGAN",
                age: 45,
                gender: "Male",
                characterDescription: "Hardened detective on a case",
                metadata: CharacterMetadata(role: .antagonist)
            )
        ]
    }
}
