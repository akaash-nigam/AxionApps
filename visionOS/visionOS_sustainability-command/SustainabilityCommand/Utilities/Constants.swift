import Foundation

// MARK: - App Constants

enum Constants {

    // MARK: - API Configuration

    enum API {
        static let baseURL = "https://api.sustainability.com"
        static let devBaseURL = "https://dev-api.sustainability.com"
        static let timeout: TimeInterval = 30
        static let maxRetries = 3
        static let version = "v1"
    }

    // MARK: - Emission Factors

    enum EmissionFactors {
        // Energy (kg CO2e per kWh)
        static let gridElectricity: Double = 0.5
        static let solarPower: Double = 0.05
        static let windPower: Double = 0.01
        static let naturalGas: Double = 0.2

        // Transport (kg CO2e per ton-km)
        static let seaFreight: Double = 0.01
        static let airFreight: Double = 0.50
        static let rail: Double = 0.03
        static let truck: Double = 0.06

        // Manufacturing (kg CO2e per kg product)
        static let steel: Double = 2.0
        static let aluminum: Double = 8.0
        static let plastic: Double = 3.0
        static let paper: Double = 1.0
    }

    // MARK: - Visualization Constants

    enum Visualization {
        // Earth dimensions
        static let earthRadius: Float = 1.5 // meters
        static let earthDistance: Float = 5.0 // meters from user
        static let atmosphereRadius: Float = 1.6 // meters

        // Facility markers
        static let markerSize: Float = 0.05 // meters
        static let markerScaleMin: Float = 0.8
        static let markerScaleMax: Float = 1.5

        // Animation
        static let rotationSpeed: Float = .pi / 60 // 2 minutes per rotation
        static let particleLifespan: Float = 2.0 // seconds
        static let transitionDuration: Double = 0.3 // seconds

        // Performance
        static let targetFPS: Int = 90
        static let maxParticles: Int = 10000
        static let lodDistanceHigh: Float = 2.0 // meters
        static let lodDistanceMedium: Float = 5.0 // meters
    }

    // MARK: - UI Constants

    enum UI {
        // Window sizes (points)
        static let dashboardWidth: CGFloat = 1400
        static let dashboardHeight: CGFloat = 900
        static let goalsWidth: CGFloat = 600
        static let goalsHeight: CGFloat = 800
        static let analyticsWidth: CGFloat = 1000
        static let analyticsHeight: CGFloat = 700

        // Spacing
        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 16
        static let paddingLarge: CGFloat = 24
        static let paddingXLarge: CGFloat = 32

        // Corner radius
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusMedium: CGFloat = 12
        static let cornerRadiusLarge: CGFloat = 16
        static let cornerRadiusXLarge: CGFloat = 20

        // Text sizes (3D)
        static let textSizeSmall: Float = 0.02 // meters
        static let textSizeMedium: Float = 0.03 // meters
        static let textSizeLarge: Float = 0.05 // meters

        // Minimum interactive size
        static let minimumTapTarget: CGFloat = 60 // points
    }

    // MARK: - Data Refresh

    enum Refresh {
        static let realTimeInterval: TimeInterval = 5 // seconds
        static let dashboardInterval: TimeInterval = 30 // seconds
        static let analyticsInterval: TimeInterval = 60 // seconds
        static let backgroundInterval: TimeInterval = 300 // 5 minutes
    }

    // MARK: - Cache

    enum Cache {
        static let maxMemoryCacheSizeMB: Int = 100
        static let maxDiskCacheSizeMB: Int = 500
        static let defaultTTL: TimeInterval = 3600 // 1 hour
        static let imageTTL: TimeInterval = 86400 // 24 hours
    }

    // MARK: - Thresholds

    enum Thresholds {
        // Emissions (tCO2e)
        static let lowEmissions: Double = 500
        static let mediumEmissions: Double = 2000
        static let highEmissions: Double = 5000

        // Progress (percentage)
        static let onTrackThreshold: Double = 0.85 // 85%
        static let atRiskThreshold: Double = 0.65 // 65%

        // Efficiency ratings
        static let excellentEfficiency: Double = 500 // tCO2e
        static let goodEfficiency: Double = 2000
        static let fairEfficiency: Double = 5000
    }

    // MARK: - Sustainability Goals

    enum Goals {
        static let netZeroDefaultYear: Int = 2050
        static let interimTargetYear: Int = 2030
        static let scopeBaseline: Double = 2020

        // Science-based targets
        static let scope1And2ReductionTarget: Double = 0.42 // 42% by 2030
        static let scope3ReductionTarget: Double = 0.25 // 25% by 2030
    }

    // MARK: - Units

    enum Units {
        static let carbonUnit = "tCO2e"
        static let energyUnit = "kWh"
        static let waterUnit = "L"
        static let wasteUnit = "kg"
        static let currencyUnit = "USD"
    }

    // MARK: - File Paths

    enum FilePaths {
        static let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        static let cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        static func reportPath(filename: String) -> URL {
            documentsDirectory.appendingPathComponent("Reports").appendingPathComponent(filename)
        }

        static func exportPath(filename: String) -> URL {
            documentsDirectory.appendingPathComponent("Exports").appendingPathComponent(filename)
        }
    }

    // MARK: - Notifications

    enum Notifications {
        static let dataUpdated = Notification.Name("SustainabilityDataUpdated")
        static let goalAchieved = Notification.Name("GoalAchieved")
        static let alertTriggered = Notification.Name("AlertTriggered")
        static let reportGenerated = Notification.Name("ReportGenerated")
        static let syncCompleted = Notification.Name("SyncCompleted")
    }

    // MARK: - User Defaults Keys

    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedOrganizationId = "selectedOrganizationId"
        static let preferredUnit = "preferredUnit"
        static let notificationsEnabled = "notificationsEnabled"
        static let lastSyncDate = "lastSyncDate"
        static let cacheVersion = "cacheVersion"
    }

    // MARK: - Feature Flags

    enum FeatureFlags {
        static let enableAIRecommendations = true
        static let enableRealTimeUpdates = true
        static let enableVoiceCommands = false
        static let enableSharePlay = true
        static let enableOfflineMode = true
        static let enableAdvancedAnalytics = true
    }

    // MARK: - Accessibility

    enum Accessibility {
        static let minimumContrastRatio: CGFloat = 7.0 // WCAG AAA
        static let voiceOverDelay: TimeInterval = 0.3
        static let hapticFeedbackIntensity: CGFloat = 0.7
    }

    // MARK: - Validation

    enum Validation {
        static let minPasswordLength = 8
        static let maxEmailLength = 254
        static let maxOrganizationNameLength = 100
        static let maxGoalTitleLength = 100
        static let maxDescriptionLength = 500

        // Emission data validation
        static let minEmissionValue: Double = 0
        static let maxEmissionValue: Double = 1_000_000 // 1 million tCO2e
        static let minGoalProgress: Double = 0
        static let maxGoalProgress: Double = 1.0
    }
}

// MARK: - App Information

enum AppInfo {
    static let version = "1.0.0"
    static let buildNumber = "1"
    static let appName = "Sustainability Command Center"
    static let bundleIdentifier = "com.sustainability.command"
    static let minimumVisionOSVersion = "2.0"

    static var fullVersion: String {
        "\(version) (\(buildNumber))"
    }
}

// MARK: - Reporting Standards

enum ReportingStandards {
    static let supportedFrameworks = [
        "CDP", // Carbon Disclosure Project
        "TCFD", // Task Force on Climate-related Financial Disclosures
        "GRI", // Global Reporting Initiative
        "SASB", // Sustainability Accounting Standards Board
        "TNFD", // Taskforce on Nature-related Financial Disclosures
    ]

    static let certifications = [
        "ISO 14001", // Environmental Management
        "B Corp",
        "LEED",
        "Carbon Neutral",
        "Science Based Targets"
    ]
}
