import Foundation

/// Types of 3D visualizations available
enum VisualizationType: String, Codable, CaseIterable {
    case roiComparison
    case decisionMatrix
    case investmentTimeline
    case riskOpportunityMatrix
    case competitivePositioning

    /// Display name for UI
    var displayName: String {
        switch self {
        case .roiComparison: return "ROI Comparison"
        case .decisionMatrix: return "Decision Matrix"
        case .investmentTimeline: return "Investment Timeline"
        case .riskOpportunityMatrix: return "Risk/Opportunity Matrix"
        case .competitivePositioning: return "Competitive Positioning"
        }
    }

    /// Icon for the visualization type
    var icon: String {
        switch self {
        case .roiComparison: return "chart.bar.fill"
        case .decisionMatrix: return "square.grid.2x2.fill"
        case .investmentTimeline: return "timeline.selection"
        case .riskOpportunityMatrix: return "square.split.2x2.fill"
        case .competitivePositioning: return "chart.pie.fill"
        }
    }

    /// Description of what this visualization shows
    var description: String {
        switch self {
        case .roiComparison:
            return "Compare ROI across different use cases in 3D space"
        case .decisionMatrix:
            return "Visualize strategic decisions by impact and feasibility"
        case .investmentTimeline:
            return "Explore investment phases and budget allocation over time"
        case .riskOpportunityMatrix:
            return "Map risks and opportunities in strategic space"
        case .competitivePositioning:
            return "Analyze competitive positioning strategies"
        }
    }

    /// Suggested dimensions for the volume (width, height, depth in points)
    var suggestedDimensions: (width: Double, height: Double, depth: Double) {
        switch self {
        case .roiComparison:
            return (600, 600, 600)
        case .decisionMatrix:
            return (700, 500, 500)
        case .investmentTimeline:
            return (800, 400, 400)
        case .riskOpportunityMatrix:
            return (600, 600, 400)
        case .competitivePositioning:
            return (600, 600, 600)
        }
    }

    /// Accessibility label
    var accessibilityLabel: String {
        "\(displayName) visualization"
    }
}

// MARK: - Identifiable
extension VisualizationType: Identifiable {
    var id: String { rawValue }
}
