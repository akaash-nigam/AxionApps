import Foundation

/// Game settings and configuration
struct GameSettings: Codable {

    // MARK: - Gameplay Settings

    var sensitivity: Float
    var aimAssist: AimAssistLevel
    var crosshairStyle: CrosshairStyle
    var showDamageNumbers: Bool

    // MARK: - Graphics Settings

    var qualityPreset: GraphicsQuality
    var renderScale: Float
    var antiAliasing: AntiAliasingMode
    var shadowQuality: ShadowQuality

    // MARK: - Audio Settings

    var masterVolume: Float
    var sfxVolume: Float
    var musicVolume: Float
    var voiceChatVolume: Float
    var spatialAudioEnabled: Bool

    // MARK: - Controls Settings

    var primaryInputMethod: InputMethod
    var invertYAxis: Bool
    var toggleCrouch: Bool
    var toggleADS: Bool

    // MARK: - Accessibility Settings

    var colorblindMode: ColorblindMode
    var subtitlesEnabled: Bool
    var highContrastMode: Bool

    // MARK: - Network Settings

    var preferredRegion: Region

    // MARK: - Default Configuration

    static var `default`: GameSettings {
        return GameSettings(
            sensitivity: 1.0,
            aimAssist: .off,
            crosshairStyle: .dot,
            showDamageNumbers: true,
            qualityPreset: .high,
            renderScale: 1.0,
            antiAliasing: .msaa4x,
            shadowQuality: .high,
            masterVolume: 0.8,
            sfxVolume: 0.8,
            musicVolume: 0.5,
            voiceChatVolume: 1.0,
            spatialAudioEnabled: true,
            primaryInputMethod: .handTracking,
            invertYAxis: false,
            toggleCrouch: false,
            toggleADS: false,
            colorblindMode: .off,
            subtitlesEnabled: false,
            highContrastMode: false,
            preferredRegion: .auto
        )
    }

    // MARK: - Persistence

    private static let fileName = "game_settings.json"

    static func loadFromDisk() -> GameSettings? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentDirectory.appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: fileURL),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else {
            return nil
        }

        return settings
    }

    func saveToDisk() async throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw SettingsError.directoryNotFound
        }

        let fileURL = documentDirectory.appendingPathComponent(Self.fileName)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(self)
        try data.write(to: fileURL)
    }
}

// MARK: - Enumerations

enum AimAssistLevel: String, Codable {
    case off
    case low
    case medium
    case high
}

enum CrosshairStyle: String, Codable {
    case dot
    case cross
    case circle
    case none
}

enum GraphicsQuality: String, Codable {
    case low
    case medium
    case high
    case ultra
}

enum AntiAliasingMode: String, Codable {
    case none
    case msaa2x
    case msaa4x
    case msaa8x
}

enum ShadowQuality: String, Codable {
    case off
    case low
    case medium
    case high
}

enum InputMethod: String, Codable {
    case handTracking
    case eyeTracking
    case controller
    case hybrid
}

enum ColorblindMode: String, Codable {
    case off
    case protanopia
    case deuteranopia
    case tritanopia
}

enum Region: String, Codable {
    case auto
    case usEast
    case usWest
    case europe
    case asia
    case oceania
}

enum SettingsError: Error {
    case directoryNotFound
    case encodingFailed
    case decodingFailed
}
