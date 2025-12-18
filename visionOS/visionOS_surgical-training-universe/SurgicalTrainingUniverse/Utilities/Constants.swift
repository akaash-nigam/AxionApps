//
//  Constants.swift
//  SurgicalTrainingUniverse
//
//  App-wide constants and configuration values
//

import Foundation
import SwiftUI

enum Constants {

    // MARK: - App Information

    enum App {
        static let name = "Surgical Training Universe"
        static let bundleIdentifier = "com.surgical.training.universe"
        static let appStoreID = "TBD"
        static let supportEmail = "support@surgicaltraining.universe"
        static let privacyPolicyURL = URL(string: "https://surgicaltraining.universe/privacy")!
        static let termsOfServiceURL = URL(string: "https://surgicaltraining.universe/terms")!
    }

    // MARK: - Performance Thresholds

    enum Performance {
        static let targetFrameRate = 120 // fps
        static let minimumFrameRate = 90 // fps
        static let maxMemoryUsage: UInt64 = 2_147_483_648 // 2GB
        static let handTrackingLatency: TimeInterval = 0.010 // 10ms
        static let visualFeedbackLatency: TimeInterval = 0.020 // 20ms
    }

    // MARK: - Scoring Thresholds

    enum Scoring {
        static let passThreshold = 70.0
        static let goodThreshold = 80.0
        static let excellentThreshold = 90.0

        static let minScore = 0.0
        static let maxScore = 100.0

        // Grade boundaries
        static let gradeA = 90.0
        static let gradeB = 80.0
        static let gradeC = 70.0
        static let gradeD = 60.0
    }

    // MARK: - Session Limits

    enum Session {
        static let minDuration: TimeInterval = 60 // 1 minute
        static let maxDuration: TimeInterval = 86_400 // 24 hours
        static let expectedDuration: TimeInterval = 2_700 // 45 minutes
        static let maxMovements = 10_000
        static let maxComplications = 50
        static let autoSaveInterval: TimeInterval = 300 // 5 minutes
    }

    // MARK: - Analytics

    enum Analytics {
        static let defaultTimeRange = 30 // days
        static let maxTimeRange = 365 // days
        static let minSessionsForTrend = 5
        static let minSessionsForMastery = 20
        static let learningCurveWindowSize = 10 // sessions
    }

    // MARK: - Mastery Levels

    enum Mastery {
        static let noviceMaxSessions = 10
        static let beginnerMaxSessions = 30
        static let competentMaxSessions = 50
        static let proficientMaxSessions = 100

        static let noviceMaxScore = 60.0
        static let beginnerMaxScore = 70.0
        static let competentMaxScore = 80.0
        static let proficientMaxScore = 90.0
    }

    // MARK: - UI Configuration

    enum UI {
        // Spacing
        static let spacingXS: CGFloat = 4
        static let spacingS: CGFloat = 8
        static let spacingM: CGFloat = 16
        static let spacingL: CGFloat = 24
        static let spacingXL: CGFloat = 32
        static let spacingXXL: CGFloat = 48

        // Corner Radius
        static let cornerRadiusS: CGFloat = 8
        static let cornerRadiusM: CGFloat = 12
        static let cornerRadiusL: CGFloat = 16
        static let cornerRadiusXL: CGFloat = 24

        // Icons
        static let iconSizeS: CGFloat = 16
        static let iconSizeM: CGFloat = 24
        static let iconSizeL: CGFloat = 32
        static let iconSizeXL: CGFloat = 48

        // Animation
        static let animationDurationShort: TimeInterval = 0.2
        static let animationDurationMedium: TimeInterval = 0.3
        static let animationDurationLong: TimeInterval = 0.5
    }

    // MARK: - Colors

    enum Colors {
        // Performance Colors
        static let excellent = Color.green
        static let good = Color.blue
        static let average = Color.orange
        static let poor = Color.red

        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // Trend Colors
        static let improving = Color.green
        static let stable = Color.gray
        static let declining = Color.red
    }

    // MARK: - RealityKit Configuration

    enum RealityKit {
        static let defaultModelScale: Float = 1.0
        static let maxRenderDistance: Float = 10.0 // meters
        static let minRenderDistance: Float = 0.1 // meters
        static let lodDistanceThreshold: Float = 2.0 // meters
        static let physicsUpdateRate = 60 // Hz
    }

    // MARK: - Hand Tracking

    enum HandTracking {
        static let trackingFrequency = 1000 // Hz
        static let handPresenceTimeout: TimeInterval = 0.1 // 100ms
        static let smoothingFactor: Float = 0.3 // Kalman filter
        static let predictionTime: TimeInterval = 0.015 // 15ms ahead
        static let minimumConfidence: Float = 0.7
    }

    // MARK: - Haptic Feedback

    enum Haptics {
        static let impactIntensityLight: Float = 0.3
        static let impactIntensityMedium: Float = 0.6
        static let impactIntensityHeavy: Float = 1.0
        static let feedbackDelay: TimeInterval = 0.005 // 5ms
    }

    // MARK: - Audio

    enum Audio {
        static let defaultVolume: Float = 0.7
        static let spatialAudioDistance: Float = 5.0 // meters
        static let feedbackVolume: Float = 0.5
    }

    // MARK: - Data Limits

    enum DataLimits {
        static let maxSessions = 1000
        static let maxCertifications = 50
        static let maxAchievements = 100
        static let nameMaxLength = 50
        static let descriptionMaxLength = 500
        static let institutionMaxLength = 100
    }

    // MARK: - Cache

    enum Cache {
        static let maxCacheSize: UInt64 = 536_870_912 // 512MB
        static let cacheExpirationTime: TimeInterval = 604_800 // 1 week
        static let maxCachedModels = 20
    }

    // MARK: - Network

    enum Network {
        static let timeout: TimeInterval = 30.0
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 2.0
    }

    // MARK: - Validation Ranges

    enum Validation {
        static let velocityMax: Float = 1.0 // m/s
        static let forceMax: Float = 1.0 // normalized
        static let positionMax: Float = 2.0 // meters from origin
        static let precisionMin = 0.0
        static let precisionMax = 100.0
    }

    // MARK: - Feature Flags

    enum Features {
        static let enableAICoaching = true
        static let enableCollaboration = true
        static let enableVoiceGuidance = false
        static let enableAdvancedAnalytics = true
        static let enableCloudSync = false
        static let enableBetaFeatures = false
    }

    // MARK: - Debug

    enum Debug {
        #if DEBUG
        static let isDebugMode = true
        static let showFPS = true
        static let showMemoryUsage = true
        static let logLevel = "verbose"
        #else
        static let isDebugMode = false
        static let showFPS = false
        static let showMemoryUsage = false
        static let logLevel = "error"
        #endif
    }

    // MARK: - Procedure Types

    enum Procedures {
        static let available: [ProcedureType] = [
            .appendectomy,
            .cholecystectomy,
            .laparoscopicSurgery,
            .herniorrhaphy,
            .colonoscopy
        ]

        static let difficulty: [ProcedureType: DifficultyLevel] = [
            .appendectomy: .beginner,
            .cholecystectomy: .intermediate,
            .laparoscopicSurgery: .intermediate,
            .herniorrhaphy: .beginner,
            .colonoscopy: .beginner
        ]

        static let estimatedDuration: [ProcedureType: TimeInterval] = [
            .appendectomy: 2700, // 45 minutes
            .cholecystectomy: 3600, // 60 minutes
            .laparoscopicSurgery: 5400, // 90 minutes
            .herniorrhaphy: 1800, // 30 minutes
            .colonoscopy: 1200 // 20 minutes
        ]
    }

    // MARK: - URLs

    enum URLs {
        static let apiBaseURL = URL(string: "https://api.surgicaltraining.universe/v1")!
        static let documentationURL = URL(string: "https://docs.surgicaltraining.universe")!
        static let feedbackURL = URL(string: "https://surgicaltraining.universe/feedback")!
    }

    // MARK: - User Defaults Keys

    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let currentUserId = "currentUserId"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let soundEffectsEnabled = "soundEffectsEnabled"
        static let spatialAudioEnabled = "spatialAudioEnabled"
        static let aiCoachingEnabled = "aiCoachingEnabled"
        static let realTimeAnalyticsEnabled = "realTimeAnalyticsEnabled"
        static let autoSaveEnabled = "autoSaveEnabled"
        static let showPerformanceHUD = "showPerformanceHUD"
        static let showAIInsights = "showAIInsights"
        static let showGridLines = "showGridLines"
        static let lightingMode = "lightingMode"
        static let shareAnonymousData = "shareAnonymousData"
        static let recordSessions = "recordSessions"
        static let saveRecordings = "saveRecordings"
        static let reduceMotion = "reduceMotion"
        static let increaseContrast = "increaseContrast"
        static let voiceGuidanceEnabled = "voiceGuidanceEnabled"
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String {
    case beginner
    case intermediate
    case advanced
    case expert

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        case .expert: return .purple
        }
    }
}
