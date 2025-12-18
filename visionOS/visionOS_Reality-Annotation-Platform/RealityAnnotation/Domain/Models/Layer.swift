//
//  Layer.swift
//  Reality Annotation Platform
//
//  Layer model for organizing annotations
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Layer {
    // Identity
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Properties
    var name: String
    var icon: String // SF Symbol name
    var colorHex: String // Stored as hex string

    // Hierarchy
    var parentLayerID: UUID?
    @Relationship(deleteRule: .nullify) var parentLayer: Layer?
    @Relationship(deleteRule: .cascade) var childLayers: [Layer]

    // Annotations
    @Relationship(deleteRule: .nullify, inverse: \Annotation.layer)
    var annotations: [Annotation]

    // Ownership
    var ownerID: String
    var isPublic: Bool

    // Settings
    var isVisible: Bool
    var autoExpireDays: Int?

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool

    // Sync
    var syncStatus: String

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "tag.fill",
        color: LayerColor = .blue,
        ownerID: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = color.hex
        self.ownerID = ownerID
        self.isPublic = false
        self.isVisible = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.childLayers = []
        self.annotations = []
        self.syncStatus = "pending"
    }

    // MARK: - Computed Properties

    var color: LayerColor {
        get { LayerColor(hex: colorHex) ?? .blue }
        set { colorHex = newValue.hex }
    }

    var annotationCount: Int {
        annotations.filter { !$0.isDeleted }.count
    }
}

// MARK: - Layer Color

enum LayerColor: String, Codable, CaseIterable {
    case red, orange, yellow, green, blue, purple, pink, gray

    var hex: String {
        switch self {
        case .red: return "#FF3B30"
        case .orange: return "#FF9500"
        case .yellow: return "#FFCC00"
        case .green: return "#34C759"
        case .blue: return "#007AFF"
        case .purple: return "#AF52DE"
        case .pink: return "#FF2D55"
        case .gray: return "#8E8E93"
        }
    }

    var swiftUIColor: Color {
        Color(hex: hex)
    }

    init?(hex: String) {
        guard let color = LayerColor.allCases.first(where: { $0.hex == hex }) else {
            return nil
        }
        self = color
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
