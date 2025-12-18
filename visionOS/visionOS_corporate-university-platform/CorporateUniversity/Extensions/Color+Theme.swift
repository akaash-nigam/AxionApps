//
//  Color+Theme.swift
//  CorporateUniversity
//
//  App-wide color palette and theming
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    /// Primary brand color
    static let appPrimary = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF (iOS Blue)

    /// Secondary brand color
    static let appSecondary = Color(red: 0.35, green: 0.34, blue: 0.84) // #5856D6 (Purple)

    /// Accent color for highlights
    static let appAccent = Color(red: 1.0, green: 0.58, blue: 0.0) // #FF9500 (Orange)

    // MARK: - Semantic Colors

    /// Success state color
    static let appSuccess = Color(red: 0.2, green: 0.78, blue: 0.35) // #34C759 (Green)

    /// Warning state color
    static let appWarning = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00 (Yellow)

    /// Error/Danger state color
    static let appError = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30 (Red)

    /// Info state color
    static let appInfo = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF (Blue)

    // MARK: - Category Colors

    /// Technology courses
    static let categoryTechnology = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue

    /// Leadership courses
    static let categoryLeadership = Color(red: 0.35, green: 0.34, blue: 0.84) // Purple

    /// Business courses
    static let categoryBusiness = Color(red: 0.2, green: 0.78, blue: 0.35) // Green

    /// Design courses
    static let categoryDesign = Color(red: 1.0, green: 0.18, blue: 0.33) // Pink

    /// Data Science courses
    static let categoryDataScience = Color(red: 0.65, green: 0.24, blue: 0.94) // Deep Purple

    /// Soft Skills courses
    static let categorySoftSkills = Color(red: 1.0, green: 0.58, blue: 0.0) // Orange

    /// Compliance courses
    static let categoryCompliance = Color(red: 0.56, green: 0.56, blue: 0.58) // Gray

    /// Sales courses
    static let categorySales = Color(red: 0.2, green: 0.78, blue: 0.35) // Green

    /// Marketing courses
    static let categoryMarketing = Color(red: 1.0, green: 0.27, blue: 0.23) // Red

    // MARK: - Difficulty Colors

    /// Beginner level
    static let difficultyBeginner = Color(red: 0.2, green: 0.78, blue: 0.35) // Green

    /// Intermediate level
    static let difficultyIntermediate = Color(red: 1.0, green: 0.58, blue: 0.0) // Orange

    /// Advanced level
    static let difficultyAdvanced = Color(red: 1.0, green: 0.23, blue: 0.19) // Red

    // MARK: - Achievement Rarity Colors

    /// Common achievement
    static let rarityCommon = Color(red: 0.56, green: 0.56, blue: 0.58) // Gray

    /// Uncommon achievement
    static let rarityUncommon = Color(red: 0.2, green: 0.78, blue: 0.35) // Green

    /// Rare achievement
    static let rarityRare = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue

    /// Epic achievement
    static let rarityEpic = Color(red: 0.65, green: 0.24, blue: 0.94) // Purple

    /// Legendary achievement
    static let rarityLegendary = Color(red: 1.0, green: 0.58, blue: 0.0) // Gold/Orange

    // MARK: - Text Colors

    /// Primary text color (adapts to light/dark mode)
    static let textPrimary = Color.primary

    /// Secondary text color
    static let textSecondary = Color.secondary

    /// Tertiary text color
    static let textTertiary = Color.gray.opacity(0.6)

    /// Disabled text color
    static let textDisabled = Color.gray.opacity(0.4)

    // MARK: - Background Colors

    /// Primary background
    static let backgroundPrimary = Color(uiColor: .systemBackground)

    /// Secondary background
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)

    /// Tertiary background
    static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)

    /// Grouped background
    static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)

    // MARK: - Gradient Colors

    /// Primary gradient
    static let gradientPrimary = LinearGradient(
        colors: [appPrimary, appSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Success gradient
    static let gradientSuccess = LinearGradient(
        colors: [appSuccess, appSuccess.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Accent gradient
    static let gradientAccent = LinearGradient(
        colors: [appAccent, appAccent.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Technology gradient
    static let gradientTechnology = LinearGradient(
        colors: [categoryTechnology, categoryTechnology.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Premium gradient (gold)
    static let gradientPremium = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.84, blue: 0.0),
            Color(red: 1.0, green: 0.65, blue: 0.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Chart Colors

    /// Chart color palette for data visualization
    static let chartColors: [Color] = [
        appPrimary,
        appSecondary,
        appAccent,
        appSuccess,
        categoryDesign,
        categoryDataScience,
        categorySoftSkills,
        categoryMarketing
    ]

    // MARK: - Helper Methods

    /// Get category color by category name
    static func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "technology":
            return categoryTechnology
        case "leadership":
            return categoryLeadership
        case "business":
            return categoryBusiness
        case "design":
            return categoryDesign
        case "data_science", "datascience", "data science":
            return categoryDataScience
        case "soft_skills", "softskills", "soft skills":
            return categorySoftSkills
        case "compliance":
            return categoryCompliance
        case "sales":
            return categorySales
        case "marketing":
            return categoryMarketing
        default:
            return .gray
        }
    }

    /// Get difficulty color by difficulty level
    static func difficultyColor(for difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner", "easy":
            return difficultyBeginner
        case "intermediate", "medium":
            return difficultyIntermediate
        case "advanced", "hard":
            return difficultyAdvanced
        default:
            return .gray
        }
    }

    /// Get rarity color by rarity level
    static func rarityColor(for rarity: String) -> Color {
        switch rarity.lowercased() {
        case "common":
            return rarityCommon
        case "uncommon":
            return rarityUncommon
        case "rare":
            return rarityRare
        case "epic":
            return rarityEpic
        case "legendary":
            return rarityLegendary
        default:
            return .gray
        }
    }

    // MARK: - Opacity Variants

    /// Returns color with specified opacity
    func withOpacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }

    /// Light variant (increased brightness)
    var lighter: Color {
        self.opacity(0.7)
    }

    /// Dark variant (decreased brightness)
    var darker: Color {
        Color(uiColor: UIColor(self).darker())
    }

    // MARK: - Custom Color Initializers

    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Convert to hex string
    var hexString: String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

// MARK: - UIColor Extensions

extension UIColor {
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }

    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        return self.adjust(by: abs(percentage))
    }

    /// Adjust color brightness
    func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return UIColor(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            alpha: alpha
        )
    }
}

// MARK: - Theme Protocol

protocol Themeable {
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
}

// MARK: - Default Theme

struct DefaultTheme: Themeable {
    var primaryColor: Color = .appPrimary
    var secondaryColor: Color = .appSecondary
    var accentColor: Color = .appAccent
    var backgroundColor: Color = .backgroundPrimary
}

// MARK: - Dark Theme

struct DarkTheme: Themeable {
    var primaryColor: Color = .appPrimary.lighter
    var secondaryColor: Color = .appSecondary.lighter
    var accentColor: Color = .appAccent.lighter
    var backgroundColor: Color = .black
}

// MARK: - Color Accessibility

extension Color {
    /// Check if color provides sufficient contrast ratio for accessibility
    func contrastRatio(with color: Color) -> CGFloat {
        let luminance1 = UIColor(self).relativeLuminance
        let luminance2 = UIColor(color).relativeLuminance

        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)

        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Check if color meets WCAG AA standard for contrast
    func meetsWCAGAA(with color: Color, forLargeText: Bool = false) -> Bool {
        let ratio = contrastRatio(with: color)
        return forLargeText ? ratio >= 3.0 : ratio >= 4.5
    }

    /// Check if color meets WCAG AAA standard for contrast
    func meetsWCAGAAA(with color: Color, forLargeText: Bool = false) -> Bool {
        let ratio = contrastRatio(with: color)
        return forLargeText ? ratio >= 4.5 : ratio >= 7.0
    }
}

extension UIColor {
    /// Calculate relative luminance
    var relativeLuminance: CGFloat {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rsRGB = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let gsRGB = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let bsRGB = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)

        return 0.2126 * rsRGB + 0.7152 * gsRGB + 0.0722 * bsRGB
    }
}
