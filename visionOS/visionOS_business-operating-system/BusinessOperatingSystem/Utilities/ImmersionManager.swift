//
//  ImmersionManager.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import SwiftUI
import RealityKit

// MARK: - Immersion Manager

/// Manages progressive immersion levels for visionOS experiences
/// Provides smooth transitions between different immersion states
@MainActor
@Observable
final class ImmersionManager {
    // MARK: - Singleton

    static let shared = ImmersionManager()

    // MARK: - Immersion Levels

    /// Available immersion levels with progressive engagement
    enum ImmersionLevel: Int, CaseIterable, Comparable {
        case none = 0           // Standard window mode
        case minimal = 1        // Window with subtle spatial elements
        case partial = 2        // Mixed reality with passthrough
        case focused = 3        // Reduced passthrough, focused workspace
        case full = 4           // Full immersion, minimal passthrough
        case complete = 5       // Complete virtual environment

        static func < (lhs: ImmersionLevel, rhs: ImmersionLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var displayName: String {
            switch self {
            case .none: return "Standard"
            case .minimal: return "Minimal"
            case .partial: return "Partial"
            case .focused: return "Focused"
            case .full: return "Full"
            case .complete: return "Complete"
            }
        }

        var description: String {
            switch self {
            case .none:
                return "Standard window mode with full passthrough"
            case .minimal:
                return "Windows with subtle 3D elements around you"
            case .partial:
                return "Mixed reality with business data overlays"
            case .focused:
                return "Dimmed surroundings for better focus"
            case .full:
                return "Immersive workspace with minimal passthrough"
            case .complete:
                return "Fully virtual business environment"
            }
        }

        var iconName: String {
            switch self {
            case .none: return "rectangle.on.rectangle"
            case .minimal: return "square.3.layers.3d"
            case .partial: return "view.3d"
            case .focused: return "square.dashed"
            case .full: return "cube.transparent"
            case .complete: return "globe"
            }
        }

        /// The passthrough opacity (1.0 = full passthrough, 0.0 = no passthrough)
        var passthroughOpacity: Double {
            switch self {
            case .none: return 1.0
            case .minimal: return 0.95
            case .partial: return 0.7
            case .focused: return 0.4
            case .full: return 0.15
            case .complete: return 0.0
            }
        }

        /// Whether this level requires an immersive space
        var requiresImmersiveSpace: Bool {
            self.rawValue >= ImmersionLevel.partial.rawValue
        }

        /// The immersion style for this level
        var immersionStyle: any ImmersionStyle {
            switch self {
            case .none, .minimal:
                return .mixed
            case .partial, .focused:
                return .mixed
            case .full:
                return .progressive(0.7...1.0, initialAmount: 0.7)
            case .complete:
                return .full
            }
        }
    }

    // MARK: - Properties

    /// Current immersion level
    private(set) var currentLevel: ImmersionLevel = .none

    /// Target immersion level (during transitions)
    private(set) var targetLevel: ImmersionLevel = .none

    /// Whether a transition is in progress
    private(set) var isTransitioning: Bool = false

    /// Current transition progress (0.0 to 1.0)
    private(set) var transitionProgress: Double = 1.0

    /// Whether the immersive space is currently open
    private(set) var isImmersiveSpaceOpen: Bool = false

    /// User preference for maximum allowed immersion
    var maximumAllowedLevel: ImmersionLevel = .complete

    /// Transition duration in seconds
    var transitionDuration: TimeInterval = 0.5

    /// Whether to animate transitions
    var animateTransitions: Bool = true

    // MARK: - Callbacks

    var onLevelChange: ((ImmersionLevel, ImmersionLevel) -> Void)?
    var onTransitionStart: ((ImmersionLevel, ImmersionLevel) -> Void)?
    var onTransitionComplete: ((ImmersionLevel) -> Void)?

    // MARK: - Private Properties

    private var transitionTask: Task<Void, Never>?

    // MARK: - Initialization

    private init() {}

    // MARK: - Level Management

    /// Set the immersion level with optional animation
    func setLevel(_ level: ImmersionLevel, animated: Bool = true) async {
        // Clamp to maximum allowed
        let clampedLevel = min(level, maximumAllowedLevel)

        guard clampedLevel != currentLevel else { return }

        let previousLevel = currentLevel
        targetLevel = clampedLevel

        // Cancel any existing transition
        transitionTask?.cancel()

        // Notify transition start
        onTransitionStart?(previousLevel, clampedLevel)

        if animated && animateTransitions {
            await animateTransition(from: previousLevel, to: clampedLevel)
        } else {
            currentLevel = clampedLevel
            transitionProgress = 1.0
        }

        // Update immersive space if needed
        await updateImmersiveSpace(for: clampedLevel)

        // Play audio feedback
        if clampedLevel > previousLevel {
            SpatialAudioManager.shared.playNavigationFeedback(.enteredImmersive)
        } else if clampedLevel < previousLevel {
            SpatialAudioManager.shared.playNavigationFeedback(.exitedImmersive)
        }

        // Notify completion
        onLevelChange?(previousLevel, clampedLevel)
        onTransitionComplete?(clampedLevel)
    }

    /// Increase immersion by one level
    func increaseImmersion() async {
        let nextLevel = ImmersionLevel(rawValue: min(currentLevel.rawValue + 1, ImmersionLevel.complete.rawValue))
        await setLevel(nextLevel ?? .complete)
    }

    /// Decrease immersion by one level
    func decreaseImmersion() async {
        let prevLevel = ImmersionLevel(rawValue: max(currentLevel.rawValue - 1, 0))
        await setLevel(prevLevel ?? .none)
    }

    /// Reset to standard window mode
    func resetToStandard() async {
        await setLevel(.none)
    }

    // MARK: - Transition Animation

    private func animateTransition(from: ImmersionLevel, to: ImmersionLevel) async {
        isTransitioning = true
        transitionProgress = 0.0

        let steps = 20
        let stepDuration = transitionDuration / Double(steps)

        transitionTask = Task {
            for i in 1...steps {
                guard !Task.isCancelled else { break }

                let progress = Double(i) / Double(steps)

                // Ease-in-out curve
                let easedProgress = easeInOut(progress)

                await MainActor.run {
                    self.transitionProgress = easedProgress

                    // Interpolate between levels for smooth visual transition
                    // This would be used by views to animate their appearance
                }

                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            }

            await MainActor.run {
                self.currentLevel = to
                self.transitionProgress = 1.0
                self.isTransitioning = false
            }
        }

        await transitionTask?.value
    }

    private func easeInOut(_ t: Double) -> Double {
        return t < 0.5
            ? 2 * t * t
            : 1 - pow(-2 * t + 2, 2) / 2
    }

    // MARK: - Immersive Space Management

    private func updateImmersiveSpace(for level: ImmersionLevel) async {
        let needsImmersiveSpace = level.requiresImmersiveSpace

        if needsImmersiveSpace && !isImmersiveSpaceOpen {
            // Open immersive space
            isImmersiveSpaceOpen = true
            // In actual implementation, call openImmersiveSpace()
        } else if !needsImmersiveSpace && isImmersiveSpaceOpen {
            // Close immersive space
            isImmersiveSpaceOpen = false
            // In actual implementation, call dismissImmersiveSpace()
        }
    }

    /// Mark immersive space as opened (called from app)
    func immersiveSpaceOpened() {
        isImmersiveSpaceOpen = true
    }

    /// Mark immersive space as closed (called from app)
    func immersiveSpaceClosed() {
        isImmersiveSpaceOpen = false
        if currentLevel.requiresImmersiveSpace {
            currentLevel = .minimal
        }
    }

    // MARK: - Environment Configuration

    /// Get environment configuration for current level
    var environmentConfiguration: EnvironmentConfiguration {
        EnvironmentConfiguration(for: currentLevel)
    }

    /// Configuration for the virtual environment at each level
    struct EnvironmentConfiguration {
        let level: ImmersionLevel
        let skyboxOpacity: Float
        let groundPlaneEnabled: Bool
        let ambientLightIntensity: Float
        let fogEnabled: Bool
        let fogDensity: Float
        let spatialAudioEnabled: Bool

        init(for level: ImmersionLevel) {
            self.level = level

            switch level {
            case .none:
                skyboxOpacity = 0.0
                groundPlaneEnabled = false
                ambientLightIntensity = 1.0
                fogEnabled = false
                fogDensity = 0.0
                spatialAudioEnabled = false

            case .minimal:
                skyboxOpacity = 0.05
                groundPlaneEnabled = false
                ambientLightIntensity = 0.95
                fogEnabled = false
                fogDensity = 0.0
                spatialAudioEnabled = true

            case .partial:
                skyboxOpacity = 0.3
                groundPlaneEnabled = true
                ambientLightIntensity = 0.8
                fogEnabled = false
                fogDensity = 0.0
                spatialAudioEnabled = true

            case .focused:
                skyboxOpacity = 0.6
                groundPlaneEnabled = true
                ambientLightIntensity = 0.6
                fogEnabled = true
                fogDensity = 0.1
                spatialAudioEnabled = true

            case .full:
                skyboxOpacity = 0.85
                groundPlaneEnabled = true
                ambientLightIntensity = 0.4
                fogEnabled = true
                fogDensity = 0.2
                spatialAudioEnabled = true

            case .complete:
                skyboxOpacity = 1.0
                groundPlaneEnabled = true
                ambientLightIntensity = 0.3
                fogEnabled = true
                fogDensity = 0.3
                spatialAudioEnabled = true
            }
        }
    }
}

// MARK: - SwiftUI Views

/// Picker for selecting immersion level
struct ImmersionLevelPicker: View {
    @Bindable var manager = ImmersionManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Immersion Level")
                .font(.headline)

            ForEach(ImmersionManager.ImmersionLevel.allCases, id: \.rawValue) { level in
                Button {
                    Task {
                        await manager.setLevel(level)
                    }
                } label: {
                    HStack {
                        Image(systemName: level.iconName)
                            .frame(width: 24)

                        VStack(alignment: .leading) {
                            Text(level.displayName)
                                .font(.body)
                            Text(level.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if level == manager.currentLevel {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .disabled(level > manager.maximumAllowedLevel)
                .opacity(level > manager.maximumAllowedLevel ? 0.5 : 1.0)
            }
        }
        .padding()
    }
}

/// Compact immersion level control
struct ImmersionLevelControl: View {
    @Bindable var manager = ImmersionManager.shared

    var body: some View {
        HStack(spacing: 8) {
            Button {
                Task {
                    await manager.decreaseImmersion()
                }
            } label: {
                Image(systemName: "minus.circle")
            }
            .disabled(manager.currentLevel == .none)

            VStack(spacing: 2) {
                Image(systemName: manager.currentLevel.iconName)
                    .font(.title3)
                Text(manager.currentLevel.displayName)
                    .font(.caption2)
            }
            .frame(width: 60)

            Button {
                Task {
                    await manager.increaseImmersion()
                }
            } label: {
                Image(systemName: "plus.circle")
            }
            .disabled(manager.currentLevel >= manager.maximumAllowedLevel)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.regularMaterial)
        .clipShape(Capsule())
    }
}

/// Progress indicator during immersion transitions
struct ImmersionTransitionOverlay: View {
    @Bindable var manager = ImmersionManager.shared

    var body: some View {
        if manager.isTransitioning {
            ZStack {
                Color.black.opacity(0.3 * (1 - manager.transitionProgress))

                VStack(spacing: 12) {
                    ProgressView(value: manager.transitionProgress)
                        .progressViewStyle(.circular)

                    Text("Transitioning to \(manager.targetLevel.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

// MARK: - View Modifier

/// View modifier that adjusts content based on immersion level
struct ImmersionAwareModifier: ViewModifier {
    @Bindable var manager = ImmersionManager.shared
    let minLevel: ImmersionManager.ImmersionLevel

    func body(content: Content) -> some View {
        content
            .opacity(manager.currentLevel >= minLevel ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.3), value: manager.currentLevel)
    }
}

extension View {
    /// Only show this view at or above the specified immersion level
    func visibleAt(immersionLevel: ImmersionManager.ImmersionLevel) -> some View {
        modifier(ImmersionAwareModifier(minLevel: immersionLevel))
    }

    /// Fade based on immersion level
    func immersionOpacity(
        min: ImmersionManager.ImmersionLevel,
        max: ImmersionManager.ImmersionLevel,
        inverted: Bool = false
    ) -> some View {
        modifier(ImmersionOpacityModifier(minLevel: min, maxLevel: max, inverted: inverted))
    }
}

struct ImmersionOpacityModifier: ViewModifier {
    @Bindable var manager = ImmersionManager.shared
    let minLevel: ImmersionManager.ImmersionLevel
    let maxLevel: ImmersionManager.ImmersionLevel
    let inverted: Bool

    func body(content: Content) -> some View {
        let range = Float(maxLevel.rawValue - minLevel.rawValue)
        let current = Float(manager.currentLevel.rawValue - minLevel.rawValue)
        var opacity = range > 0 ? Double(current / range) : 1.0
        opacity = max(0, min(1, opacity))

        if inverted {
            opacity = 1 - opacity
        }

        return content.opacity(opacity)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ImmersionLevelPicker()
        Divider()
        ImmersionLevelControl()
    }
    .frame(width: 400)
}
