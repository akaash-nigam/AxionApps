//
//  AccessibilityHelpers.swift
//  AIAgentCoordinator
//
//  Accessibility utilities for visionOS spatial UI
//  Created by AI Agent Coordinator on 2025-01-20.
//

import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    /// Add comprehensive accessibility for an agent item
    func agentAccessibility(
        agent: AIAgent,
        metrics: AgentMetrics? = nil,
        isSelected: Bool = false
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(agentAccessibilityLabel(agent: agent, metrics: metrics))
            .accessibilityValue(agentAccessibilityValue(agent: agent, isSelected: isSelected))
            .accessibilityHint(agentAccessibilityHint(agent: agent))
            .accessibilityAddTraits(accessibilityTraits(for: agent))
    }

    /// Add accessibility for a status card
    func statusCardAccessibility(title: String, count: Int, total: Int) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title) agents")
            .accessibilityValue("\(count) of \(total), \(percentageString(count: count, total: total))")
    }

    /// Add accessibility for immersive space controls
    func immersiveSpaceAccessibility(spaceName: String, isActive: Bool) -> some View {
        self
            .accessibilityLabel("\(spaceName) immersive space")
            .accessibilityValue(isActive ? "Active" : "Inactive")
            .accessibilityHint(isActive ? "Double tap to exit" : "Double tap to enter")
    }

    /// Add accessibility for a metrics display
    func metricsAccessibility(metric: String, value: String, trend: MetricTrend = .stable) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(metric)
            .accessibilityValue("\(value), \(trend.accessibilityDescription)")
    }

    // MARK: - Private Helpers

    private func agentAccessibilityLabel(agent: AIAgent, metrics: AgentMetrics?) -> String {
        var label = "Agent \(agent.displayName)"

        if !agent.agentDescription.isEmpty {
            label += ", \(agent.agentDescription)"
        }

        return label
    }

    private func agentAccessibilityValue(agent: AIAgent, isSelected: Bool) -> String {
        var parts: [String] = []

        parts.append("Status: \(agent.status.accessibilityName)")
        parts.append("Type: \(agent.type.rawValue)")
        parts.append("Platform: \(agent.platform.rawValue)")

        if isSelected {
            parts.append("Selected")
        }

        return parts.joined(separator: ", ")
    }

    private func agentAccessibilityHint(agent: AIAgent) -> String {
        switch agent.status {
        case .active:
            return "Double tap to view details or stop this agent"
        case .idle:
            return "Double tap to view details or start this agent"
        case .error:
            return "Double tap to view error details and troubleshoot"
        case .learning:
            return "Agent is currently learning. Double tap for progress details"
        default:
            return "Double tap for agent details"
        }
    }

    private func accessibilityTraits(for agent: AIAgent) -> AccessibilityTraits {
        var traits: AccessibilityTraits = [.isButton]

        if agent.status == .error {
            // No direct .isWarning trait, but we can use header for emphasis
        }

        return traits
    }

    private func percentageString(count: Int, total: Int) -> String {
        guard total > 0 else { return "0 percent" }
        let percentage = (Double(count) / Double(total)) * 100
        return "\(Int(percentage)) percent"
    }
}

// MARK: - Metric Trend

enum MetricTrend {
    case increasing
    case decreasing
    case stable

    var accessibilityDescription: String {
        switch self {
        case .increasing: return "trending up"
        case .decreasing: return "trending down"
        case .stable: return "stable"
        }
    }
}

// MARK: - Status Accessibility Names

extension AgentStatus {
    var accessibilityName: String {
        switch self {
        case .active: return "Active and running"
        case .idle: return "Idle and ready"
        case .learning: return "Currently learning"
        case .error: return "Error state, needs attention"
        case .optimizing: return "Optimizing performance"
        case .paused: return "Paused by user"
        case .terminated: return "Terminated"
        }
    }
}

// MARK: - Spatial Accessibility

/// Accessibility helper for 3D/spatial elements
struct SpatialAccessibility {
    /// Generate accessibility label for a 3D agent entity
    static func labelForAgent(_ agent: AIAgent, at position: SIMD3<Float>) -> String {
        let direction = directionDescription(for: position)
        let distance = distanceDescription(for: position)

        return "\(agent.displayName), \(agent.status.accessibilityName), located \(direction), \(distance)"
    }

    /// Generate accessibility hint for spatial navigation
    static func spatialNavigationHint(agentCount: Int) -> String {
        "Galaxy view showing \(agentCount) agents. Use hand gestures to navigate and tap to select agents."
    }

    /// Describe position in accessible terms
    private static func directionDescription(for position: SIMD3<Float>) -> String {
        var parts: [String] = []

        if position.x > 0.5 {
            parts.append("to your right")
        } else if position.x < -0.5 {
            parts.append("to your left")
        }

        if position.y > 0.5 {
            parts.append("above")
        } else if position.y < -0.5 {
            parts.append("below")
        }

        if position.z > 0.5 {
            parts.append("behind you")
        } else if position.z < -0.5 {
            parts.append("in front of you")
        }

        return parts.isEmpty ? "centered" : parts.joined(separator: " and ")
    }

    /// Describe distance in accessible terms
    private static func distanceDescription(for position: SIMD3<Float>) -> String {
        let distance = sqrt(position.x * position.x + position.y * position.y + position.z * position.z)

        switch distance {
        case 0..<1:
            return "very close"
        case 1..<3:
            return "nearby"
        case 3..<10:
            return "at medium distance"
        default:
            return "far away"
        }
    }
}

// MARK: - Accessibility Announcements

/// Helper for making VoiceOver announcements
@MainActor
struct AccessibilityAnnouncement {
    /// Announce agent status change
    static func announceStatusChange(agent: AIAgent, oldStatus: AgentStatus) {
        let message = "\(agent.displayName) changed from \(oldStatus.accessibilityName) to \(agent.status.accessibilityName)"
        announce(message)
    }

    /// Announce new alert
    static func announceAlert(severity: AppAlertSeverity, title: String) {
        let prefix = severity == .critical ? "Critical alert" : severity == .warning ? "Warning" : "Info"
        announce("\(prefix): \(title)")
    }

    /// Announce collaboration event
    static func announceCollaborationEvent(_ event: String) {
        announce("Collaboration: \(event)")
    }

    /// Make a VoiceOver announcement
    private static func announce(_ message: String) {
        // Post accessibility notification
        #if os(visionOS) || os(iOS)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }
}

// MARK: - Accessible Color Descriptions

extension AgentStatus {
    var colorDescription: String {
        switch self {
        case .active: return "blue indicator"
        case .idle: return "gray indicator"
        case .learning: return "purple indicator"
        case .error: return "red indicator"
        case .optimizing: return "green indicator"
        case .paused: return "orange indicator"
        case .terminated: return "dark gray indicator"
        }
    }
}
