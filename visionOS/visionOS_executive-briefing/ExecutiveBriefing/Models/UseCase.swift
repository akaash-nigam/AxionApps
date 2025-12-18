import Foundation
import SwiftData
import simd

/// Represents a use case with ROI data
@Model
final class UseCase {
    /// Unique identifier
    var id: UUID

    /// Use case title
    var title: String

    /// ROI percentage (e.g., 400 for 400%)
    var roi: Int

    /// Timeframe for achieving ROI
    var timeframe: String

    /// Related metrics
    @Relationship(deleteRule: .cascade)
    var metrics: [Metric]

    /// Example implementation or company
    var example: String

    /// Category or domain
    var category: String?

    /// Optional 3D position for spatial visualization
    var position3DX: Float?
    var position3DY: Float?
    var position3DZ: Float?

    /// Order for display
    var order: Int

    /// Initialize a new use case
    /// - Parameters:
    ///   - id: Unique identifier
    ///   - title: Use case title
    ///   - roi: ROI percentage
    ///   - timeframe: Time to achieve ROI
    ///   - metrics: Associated metrics
    ///   - example: Example company/implementation
    ///   - category: Optional category
    ///   - order: Display order
    init(
        id: UUID = UUID(),
        title: String,
        roi: Int,
        timeframe: String,
        metrics: [Metric] = [],
        example: String,
        category: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.roi = roi
        self.timeframe = timeframe
        self.metrics = metrics
        self.example = example
        self.category = category
        self.order = order
    }

    /// Get or set 3D position as SIMD3
    var position3D: SIMD3<Float>? {
        get {
            guard let x = position3DX, let y = position3DY, let z = position3DZ else {
                return nil
            }
            return SIMD3(x, y, z)
        }
        set {
            position3DX = newValue?.x
            position3DY = newValue?.y
            position3DZ = newValue?.z
        }
    }

    /// ROI category for color coding
    var roiCategory: ROICategory {
        switch roi {
        case 400...: return .exceptional
        case 300..<400: return .high
        case 200..<300: return .medium
        default: return .standard
        }
    }

    /// Accessibility description
    var accessibilityDescription: String {
        "\(title), ROI: \(roi)% in \(timeframe)"
    }
}

/// ROI performance categories
enum ROICategory {
    case exceptional  // 400%+
    case high         // 300-399%
    case medium       // 200-299%
    case standard     // < 200%

    var colorName: String {
        switch self {
        case .exceptional: return "green"
        case .high: return "blue"
        case .medium: return "orange"
        case .standard: return "gray"
        }
    }
}

// MARK: - Hashable & Equatable
extension UseCase: Hashable {
    static func == (lhs: UseCase, rhs: UseCase) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
