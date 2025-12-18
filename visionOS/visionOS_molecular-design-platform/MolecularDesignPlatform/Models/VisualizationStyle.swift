//
//  VisualizationStyle.swift
//  Molecular Design Platform
//
//  3D visualization rendering styles
//

import Foundation

// MARK: - Visualization Style

enum VisualizationStyle: String, Codable, CaseIterable {
    case ballAndStick
    case spaceFilling
    case wireframe
    case ribbon
    case surface

    var displayName: String {
        switch self {
        case .ballAndStick: return "Ball and Stick"
        case .spaceFilling: return "Space Filling (CPK)"
        case .wireframe: return "Wireframe"
        case .ribbon: return "Ribbon"
        case .surface: return "Surface"
        }
    }

    var description: String {
        switch self {
        case .ballAndStick:
            return "Classic representation with spheres for atoms and cylinders for bonds"
        case .spaceFilling:
            return "Atoms shown at their van der Waals radii"
        case .wireframe:
            return "Simple line representation showing bonds only"
        case .ribbon:
            return "Protein secondary structure visualization"
        case .surface:
            return "Molecular surface or volume representation"
        }
    }

    var scaleFactor: Float {
        switch self {
        case .ballAndStick: return 0.3
        case .spaceFilling: return 1.0
        case .wireframe: return 0.0
        case .ribbon: return 0.0
        case .surface: return 1.0
        }
    }

    var showBonds: Bool {
        switch self {
        case .ballAndStick, .wireframe: return true
        case .spaceFilling, .ribbon, .surface: return false
        }
    }

    var showAtoms: Bool {
        switch self {
        case .ballAndStick, .spaceFilling: return true
        case .wireframe, .ribbon, .surface: return false
        }
    }
}

// MARK: - Color Scheme

enum ColorScheme: String, Codable, CaseIterable {
    case cpk
    case element
    case chain
    case temperature
    case charge

    var displayName: String {
        switch self {
        case .cpk: return "CPK (Standard)"
        case .element: return "By Element Type"
        case .chain: return "By Chain"
        case .temperature: return "By Temperature"
        case .charge: return "By Charge"
        }
    }
}
