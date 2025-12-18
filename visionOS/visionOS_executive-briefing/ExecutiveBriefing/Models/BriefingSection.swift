import Foundation
import SwiftData

/// Represents a major section in the executive briefing
@Model
final class BriefingSection {
    /// Unique identifier for the section
    var id: UUID

    /// Display title of the section
    var title: String

    /// Order in which section appears (for sorting)
    var order: Int

    /// SF Symbol name for the section icon
    var icon: String

    /// Array of content blocks within this section
    @Relationship(deleteRule: .cascade)
    var content: [ContentBlock]

    /// Optional visualization type associated with this section
    var visualizationType: VisualizationType?

    /// Timestamp when section was last accessed
    var lastAccessed: Date?

    /// Initialize a new briefing section
    /// - Parameters:
    ///   - id: Unique identifier (generated if not provided)
    ///   - title: Section title
    ///   - order: Display order
    ///   - icon: SF Symbol name
    ///   - content: Array of content blocks
    ///   - visualizationType: Optional 3D visualization type
    init(
        id: UUID = UUID(),
        title: String,
        order: Int,
        icon: String,
        content: [ContentBlock] = [],
        visualizationType: VisualizationType? = nil
    ) {
        self.id = id
        self.title = title
        self.order = order
        self.icon = icon
        self.content = content
        self.visualizationType = visualizationType
        self.lastAccessed = nil
    }

    /// Computed property for accessibility label
    var accessibilityLabel: String {
        "\(title) section, order \(order)"
    }
}

// MARK: - Hashable & Equatable
extension BriefingSection: Hashable {
    static func == (lhs: BriefingSection, rhs: BriefingSection) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
