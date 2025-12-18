//
//  Organization.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Organization

/// Represents a business organization with its structure and departments
public struct Organization: Identifiable, Codable, Sendable {
    public let id: UUID
    var name: String
    var structure: OrganizationType
    var departments: [Department]
    var metadata: OrganizationMetadata
    var spatialConfiguration: SpatialLayout
    var visualTheme: VisualTheme

    // MARK: - Organization Type

    public enum OrganizationType: String, Codable, Sendable {
        case hierarchical
        case matrix
        case flat
        case hybrid

        var displayName: String {
            switch self {
            case .hierarchical: return "Hierarchical"
            case .matrix: return "Matrix"
            case .flat: return "Flat"
            case .hybrid: return "Hybrid"
            }
        }
    }
}

// MARK: - Organization Metadata

public struct OrganizationMetadata: Codable, Hashable, Sendable {
    var industry: String
    var size: Int  // Total employees
    var revenue: Decimal?
    var foundedYear: Int?
    var headquarters: String?

    var formattedRevenue: String? {
        guard let revenue = revenue else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: revenue as NSNumber)
    }

    var sizeCategory: String {
        switch size {
        case ..<50: return "Small"
        case 50..<250: return "Medium"
        case 250..<1000: return "Large"
        default: return "Enterprise"
        }
    }
}

// MARK: - Spatial Layout

public struct SpatialLayout: Codable, Hashable, Sendable {
    var layoutAlgorithm: LayoutAlgorithm
    var scale: Float
    var customPositions: [UUID: SIMD3<Float>]?

    public enum LayoutAlgorithm: String, Codable, Sendable {
        case radial
        case grid
        case hierarchical
        case forceDirected
        case custom

        var displayName: String {
            switch self {
            case .radial: return "Radial"
            case .grid: return "Grid"
            case .hierarchical: return "Hierarchical"
            case .forceDirected: return "Force-Directed"
            case .custom: return "Custom"
            }
        }
    }
}

// MARK: - Visual Theme

public struct VisualTheme: Codable, Hashable, Sendable {
    var primaryColor: String  // Hex color
    var secondaryColor: String
    var accentColor: String
    var darkMode: Bool

    static let `default` = VisualTheme(
        primaryColor: "#007AFF",
        secondaryColor: "#5856D6",
        accentColor: "#00D084",
        darkMode: true
    )
}

// MARK: - Mock Extension

extension Organization {
    static func mock() -> Organization {
        Organization(
            id: UUID(),
            name: "Acme Corporation",
            structure: .hierarchical,
            departments: [
                .mock(name: "Engineering", type: .engineering),
                .mock(name: "Sales", type: .sales),
                .mock(name: "Marketing", type: .marketing),
                .mock(name: "Finance", type: .finance)
            ],
            metadata: OrganizationMetadata(
                industry: "Technology",
                size: 1250,
                revenue: 125_000_000,
                foundedYear: 2010,
                headquarters: "San Francisco, CA"
            ),
            spatialConfiguration: SpatialLayout(
                layoutAlgorithm: .radial,
                scale: 1.0,
                customPositions: nil
            ),
            visualTheme: .default
        )
    }
}
