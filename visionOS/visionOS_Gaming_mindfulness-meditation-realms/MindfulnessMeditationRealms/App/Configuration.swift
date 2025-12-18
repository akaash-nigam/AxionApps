import Foundation

/// Application-wide configuration and constants
enum AppConfiguration {

    // MARK: - App Information

    static let appName = "Mindfulness Meditation Realms"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    // MARK: - Performance Targets

    enum Performance {
        static let targetFrameRate: Double = 90.0
        static let maxMemoryUsageMB: Int = 2048
        static let maxBatteryDrainPercentPerHour: Int = 20
    }

    // MARK: - Session Defaults

    enum Session {
        static let defaultDuration: TimeInterval = 600 // 10 minutes
        static let minDuration: TimeInterval = 300 // 5 minutes
        static let maxDuration: TimeInterval = 3600 // 60 minutes
        static let defaultBreathingRate: Double = 15.0 // breaths per minute
    }

    // MARK: - Biometric Thresholds

    enum Biometric {
        static let highStressThreshold: Float = 0.7
        static let lowStressThreshold: Float = 0.3
        static let highCalmThreshold: Float = 0.7
        static let normalBreathingRate: ClosedRange<Double> = 12.0...20.0
    }

    // MARK: - Audio Configuration

    enum Audio {
        static let ambienceVolume: Float = 0.6
        static let musicVolume: Float = 0.3
        static let guidanceVolume: Float = 0.8
        static let spatialAudioEnabled = true
    }

    // MARK: - Environment Settings

    enum Environment {
        static let defaultEnvironment = "ZenGarden"
        static let transitionDuration: TimeInterval = 2.0
        static let maxParticlesPerSystem: Int = 1000
        static let maxConcurrentParticleSystems: Int = 10
    }

    // MARK: - Progress & Gamification

    enum Progress {
        static let experiencePerMinute: Int = 10
        static let streakBonusXP: Int = 50
        static let newEnvironmentXP: Int = 100

        static func experienceForLevel(_ level: Int) -> Int {
            return Int(100 * pow(Double(level), 1.5))
        }
    }

    // MARK: - CloudKit Configuration

    enum Cloud {
        static let containerIdentifier = "iCloud.com.mindfulness.realms"
        static let syncEnabled = true
    }

    // MARK: - Subscription Tiers

    enum Subscription {
        static let freeTierEnvironmentCount = 3
        static let premiumMonthlyPrice: Decimal = 14.99
        static let premiumAnnualPrice: Decimal = 99.99
        static let trialDurationDays = 7
    }

    // MARK: - Feature Flags

    enum Features {
        static let biometricMonitoringEnabled = true
        static let multiplayerEnabled = true
        static let voiceGuidanceEnabled = true
        static let customSoundscapesEnabled = false // Coming soon
        static let arExtensionsEnabled = false // Future feature
    }
}
