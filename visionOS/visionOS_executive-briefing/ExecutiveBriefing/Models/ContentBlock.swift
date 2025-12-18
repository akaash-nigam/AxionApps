import Foundation
import SwiftData

/// Represents a block of content within a briefing section
@Model
final class ContentBlock {
    /// Unique identifier
    var id: UUID

    /// Type of content block
    var type: ContentType

    /// Main content text
    var content: String

    /// Optional metadata (key-value pairs)
    var metadata: [String: String]?

    /// Display order within section
    var order: Int

    /// Initialize a new content block
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - type: Content type
    ///   - content: Content text
    ///   - metadata: Optional metadata
    ///   - order: Display order
    init(
        id: UUID = UUID(),
        type: ContentType,
        content: String,
        metadata: [String: String]? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.metadata = metadata
        self.order = order
    }
}

/// Types of content blocks
enum ContentType: String, Codable {
    case heading
    case subheading
    case paragraph
    case bulletList
    case numberedList
    case metric
    case callout
    case quote
    case codeBlock
    case table

    /// Display name for the content type
    var displayName: String {
        switch self {
        case .heading: return "Heading"
        case .subheading: return "Subheading"
        case .paragraph: return "Paragraph"
        case .bulletList: return "Bullet List"
        case .numberedList: return "Numbered List"
        case .metric: return "Metric"
        case .callout: return "Callout"
        case .quote: return "Quote"
        case .codeBlock: return "Code Block"
        case .table: return "Table"
        }
    }
}

// MARK: - Hashable & Equatable
extension ContentBlock: Hashable {
    static func == (lhs: ContentBlock, rhs: ContentBlock) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
