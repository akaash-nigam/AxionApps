import SwiftUI

/// Color extensions for the app's design system
extension Color {
    // MARK: - Brand Colors

    /// Primary accent color
    static let accentColor = Color.blue

    /// Success/High Performance
    static let successGreen = Color.green

    /// Warning/Medium Performance
    static let warningOrange = Color.orange

    /// Critical/Low Performance
    static let criticalRed = Color.red

    /// Executive dark theme
    static let executiveDark = Color(red: 0.11, green: 0.11, blue: 0.12)

    /// Premium gold accent
    static let premiumGold = Color(red: 1.0, green: 0.84, blue: 0.04)

    // MARK: - ROI Category Colors

    /// Color for ROI category
    static func roiColor(for category: ROICategory) -> Color {
        switch category {
        case .exceptional:
            return .successGreen
        case .high:
            return .accentColor
        case .medium:
            return .warningOrange
        case .standard:
            return .gray
        }
    }

    // MARK: - Semantic Colors

    /// Card background
    static let cardBackground = Color(uiColor: .secondarySystemBackground)

    /// Divider color
    static let dividerColor = Color(uiColor: .separator)
}
