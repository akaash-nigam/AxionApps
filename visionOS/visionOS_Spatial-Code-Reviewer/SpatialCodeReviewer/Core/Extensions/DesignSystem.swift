//
//  DesignSystem.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

// MARK: - Colors

extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.purple

    static let appSuccess = Color.green
    static let appWarning = Color.orange
    static let appError = Color.red

    // Syntax highlighting
    static let syntaxKeyword = Color(red: 175/255, green: 0, blue: 219/255)
    static let syntaxString = Color(red: 209/255, green: 47/255, blue: 27/255)
    static let syntaxNumber = Color(red: 28/255, green: 0, blue: 207/255)
    static let syntaxComment = Color.gray
    static let syntaxFunction = Color(red: 62/255, green: 0, blue: 255/255)
    static let syntaxType = Color(red: 0, green: 134/255, blue: 140/255)
}

// MARK: - Typography

extension Font {
    static let appLargeTitle = Font.largeTitle.weight(.bold)
    static let appTitle = Font.title.weight(.semibold)
    static let appTitle2 = Font.title2.weight(.semibold)
    static let appTitle3 = Font.title3.weight(.semibold)
    static let appHeadline = Font.headline
    static let appBody = Font.body
    static let appCallout = Font.callout
    static let appSubheadline = Font.subheadline
    static let appFootnote = Font.footnote
    static let appCaption = Font.caption

    // Code fonts
    static let appCodeRegular = Font.custom("SF Mono", size: 14)
    static let appCodeMedium = Font.custom("SF Mono", size: 16)
    static let appCodeLarge = Font.custom("SF Mono", size: 18)
}

// MARK: - Spacing

enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .cornerRadius(CornerRadius.medium)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
