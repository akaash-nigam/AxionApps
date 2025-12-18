//
//  Constants.swift
//  AIAgentCoordinator
//
//  Centralized constants to replace magic numbers throughout the codebase
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import simd

// MARK: - App Constants

/// Application-wide constants
enum AppConstants {

    // MARK: - Capacity Limits

    /// Maximum number of agents that can be visualized simultaneously
    static let maxAgentsVisualized = 50_000

    /// Maximum number of collaboration participants
    static let maxCollaborationParticipants = 8

    /// Default page size for agent lists
    static let defaultPageSize = 50

    // MARK: - Timing

    /// Default refresh interval for metrics (in seconds)
    static let defaultMetricsRefreshInterval: TimeInterval = 1.0

    /// Debounce delay for search input (in seconds)
    static let searchDebounceDelay: TimeInterval = 0.3

    /// Animation duration for standard transitions (in seconds)
    static let standardAnimationDuration: TimeInterval = 0.3

    /// Long press duration for context menus (in seconds)
    static let longPressDuration: TimeInterval = 0.5
}

// MARK: - Metrics Constants

/// Constants for metrics collection and aggregation
enum MetricsConstants {

    /// Update frequency in Hz (updates per second)
    static let updateFrequencyHz = 100

    /// Milliseconds per update cycle
    static let updateIntervalMs: Int = 1000 / updateFrequencyHz

    /// Maximum history size per agent (10 minutes at 100Hz = 60,000 samples)
    static let maxHistorySize = 60_000

    /// History duration in seconds
    static let historyDurationSeconds: TimeInterval = 600 // 10 minutes

    // MARK: - Health Thresholds

    /// CPU usage threshold for warning state (0.0 - 1.0)
    static let cpuWarningThreshold: Double = 0.7

    /// CPU usage threshold for critical state (0.0 - 1.0)
    static let cpuCriticalThreshold: Double = 0.9

    /// Error rate threshold for warning state (0.0 - 1.0)
    static let errorRateWarningThreshold: Double = 0.05

    /// Error rate threshold for critical state (0.0 - 1.0)
    static let errorRateCriticalThreshold: Double = 0.10

    /// Latency threshold for warning state (in seconds)
    static let latencyWarningThreshold: TimeInterval = 0.1 // 100ms

    /// Latency threshold for critical state (in seconds)
    static let latencyCriticalThreshold: TimeInterval = 0.5 // 500ms

    /// Health score threshold for healthy status (0.0 - 1.0)
    static let healthyScoreThreshold: Double = 0.7
}

// MARK: - Visualization Constants

/// Constants for 3D visualization and layout algorithms
enum VisualizationConstants {

    // MARK: - Scene Bounds

    /// Default scene size in meters (width, height, depth)
    static let defaultSceneBounds = SIMD3<Float>(10, 10, 10)

    /// Maximum scene size in meters
    static let maxSceneBounds = SIMD3<Float>(100, 100, 100)

    // MARK: - Galaxy Layout

    /// Number of spiral arms in galaxy visualization
    static let galaxySpiralArmCount = 5

    /// Base radius for galaxy spiral (in meters)
    static let galaxyBaseRadius: Float = 1.0

    /// Radius increment per agent in spiral (in meters)
    static let galaxyRadiusIncrement: Float = 0.02

    /// Angle increment per agent in spiral (in radians)
    static let galaxyAngleIncrement: Float = 0.5

    /// Vertical variation range for galaxy layout (in meters)
    static let galaxyVerticalVariation: ClosedRange<Float> = -0.5...0.5

    // MARK: - Grid Layout

    /// Default spacing between agents in grid layout (in meters)
    static let gridSpacing: Float = 0.5

    // MARK: - Cluster Layout

    /// Radius of cluster circles (in meters)
    static let clusterRadius: Float = 3.0

    /// Inner radius variation for agents within cluster (in meters)
    static let clusterInnerRadiusRange: ClosedRange<Float> = 0.5...1.5

    // MARK: - Landscape Layout

    /// Maximum height for performance landscape (in meters)
    static let landscapeMaxHeight: Float = 5.0

    // MARK: - River Layout

    /// Amplitude of river sinusoidal path (in meters)
    static let riverAmplitude: Float = 2.0

    /// Total length of river (in meters)
    static let riverLength: Float = 10.0

    /// Frequency of river oscillation
    static let riverFrequency: Float = 4 * .pi

    // MARK: - Level of Detail Distances

    /// Distance threshold for high LOD (in meters)
    static let lodHighDistance: Float = 2.0

    /// Distance threshold for medium LOD (in meters)
    static let lodMediumDistance: Float = 10.0

    /// Distance threshold for low LOD (in meters)
    static let lodLowDistance: Float = 50.0

    // MARK: - Agent Visual Parameters

    /// Base size for agent spheres (in meters)
    static let agentBaseSize: Float = 0.1

    /// Maximum size for agent spheres (in meters)
    static let agentMaxSize: Float = 0.5

    /// Sphere segments for high detail
    static let sphereSegmentsHigh = 32

    /// Sphere segments for medium detail
    static let sphereSegmentsMedium = 16

    /// Sphere segments for low detail
    static let sphereSegmentsLow = 8

    /// Sphere segments for minimal detail
    static let sphereSegmentsMinimal = 4

    /// Particle count for high detail effects
    static let particleCountHigh = 100

    /// Particle count for medium detail effects
    static let particleCountMedium = 20
}

// MARK: - Network Constants

/// Constants for network operations
enum NetworkConstants {

    // MARK: - Timeouts

    /// Default request timeout (in seconds)
    static let defaultTimeout: TimeInterval = 30

    /// Long-running request timeout (in seconds)
    static let longTimeout: TimeInterval = 120

    /// Connection timeout (in seconds)
    static let connectionTimeout: TimeInterval = 10

    // MARK: - Retry Configuration

    /// Default number of retry attempts
    static let defaultRetryAttempts = 3

    /// Maximum number of retry attempts
    static let maxRetryAttempts = 5

    /// Initial retry delay (in seconds)
    static let initialRetryDelay: TimeInterval = 1.0

    /// Maximum retry delay (in seconds)
    static let maxRetryDelay: TimeInterval = 30.0

    /// Retry backoff multiplier
    static let retryBackoffMultiplier: Double = 2.0

    // MARK: - Rate Limiting

    /// Default requests per second limit
    static let defaultRequestsPerSecond = 10

    /// Default requests per minute limit
    static let defaultRequestsPerMinute = 600

    /// Default requests per hour limit
    static let defaultRequestsPerHour = 10_000

    /// Burst capacity multiplier
    static let burstCapacityMultiplier: Double = 1.5
}

// MARK: - UI Constants

/// Constants for user interface elements
enum UIConstants {

    // MARK: - Window Sizes

    /// Control panel default width
    static let controlPanelWidth: CGFloat = 900

    /// Control panel default height
    static let controlPanelHeight: CGFloat = 700

    /// Agent list window width
    static let agentListWidth: CGFloat = 400

    /// Agent list window height
    static let agentListHeight: CGFloat = 600

    /// Settings window width
    static let settingsWidth: CGFloat = 500

    /// Settings window height
    static let settingsHeight: CGFloat = 400

    // MARK: - Volumetric Window

    /// Agent detail volume size in meters (width, height, depth)
    static let agentDetailVolumeSize: (width: Float, height: Float, depth: Float) = (0.6, 0.6, 0.6)

    // MARK: - Spacing

    /// Standard padding
    static let standardPadding: CGFloat = 16

    /// Compact padding
    static let compactPadding: CGFloat = 8

    /// Section spacing
    static let sectionSpacing: CGFloat = 20

    // MARK: - Corner Radius

    /// Standard corner radius
    static let standardCornerRadius: CGFloat = 12

    /// Large corner radius
    static let largeCornerRadius: CGFloat = 16

    /// Small corner radius
    static let smallCornerRadius: CGFloat = 8

    // MARK: - Status Indicator

    /// Status indicator size
    static let statusIndicatorSize: CGFloat = 12

    // MARK: - Font Sizes

    /// Large count display font size
    static let largeCountFontSize: CGFloat = 40
}
