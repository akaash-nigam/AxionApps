//
//  Element.swift
//  Molecular Design Platform
//
//  Chemical elements with their properties
//

import Foundation
import SwiftUI

// MARK: - Element

enum Element: String, Codable, CaseIterable {
    case hydrogen = "H"
    case carbon = "C"
    case nitrogen = "N"
    case oxygen = "O"
    case fluorine = "F"
    case phosphorus = "P"
    case sulfur = "S"
    case chlorine = "Cl"
    case bromine = "Br"
    case iodine = "I"

    // Metals
    case sodium = "Na"
    case magnesium = "Mg"
    case potassium = "K"
    case calcium = "Ca"
    case iron = "Fe"
    case copper = "Cu"
    case zinc = "Zn"

    // MARK: - Properties

    var symbol: String {
        rawValue
    }

    var name: String {
        switch self {
        case .hydrogen: return "Hydrogen"
        case .carbon: return "Carbon"
        case .nitrogen: return "Nitrogen"
        case .oxygen: return "Oxygen"
        case .fluorine: return "Fluorine"
        case .phosphorus: return "Phosphorus"
        case .sulfur: return "Sulfur"
        case .chlorine: return "Chlorine"
        case .bromine: return "Bromine"
        case .iodine: return "Iodine"
        case .sodium: return "Sodium"
        case .magnesium: return "Magnesium"
        case .potassium: return "Potassium"
        case .calcium: return "Calcium"
        case .iron: return "Iron"
        case .copper: return "Copper"
        case .zinc: return "Zinc"
        }
    }

    var atomicNumber: Int {
        switch self {
        case .hydrogen: return 1
        case .carbon: return 6
        case .nitrogen: return 7
        case .oxygen: return 8
        case .fluorine: return 9
        case .phosphorus: return 15
        case .sulfur: return 16
        case .chlorine: return 17
        case .bromine: return 35
        case .iodine: return 53
        case .sodium: return 11
        case .magnesium: return 12
        case .potassium: return 19
        case .calcium: return 20
        case .iron: return 26
        case .copper: return 29
        case .zinc: return 30
        }
    }

    var atomicWeight: Double {
        switch self {
        case .hydrogen: return 1.008
        case .carbon: return 12.011
        case .nitrogen: return 14.007
        case .oxygen: return 15.999
        case .fluorine: return 18.998
        case .phosphorus: return 30.974
        case .sulfur: return 32.06
        case .chlorine: return 35.45
        case .bromine: return 79.904
        case .iodine: return 126.904
        case .sodium: return 22.990
        case .magnesium: return 24.305
        case .potassium: return 39.098
        case .calcium: return 40.078
        case .iron: return 55.845
        case .copper: return 63.546
        case .zinc: return 65.38
        }
    }

    /// Van der Waals radius in Angstroms
    var vdwRadius: Float {
        switch self {
        case .hydrogen: return 1.20
        case .carbon: return 1.70
        case .nitrogen: return 1.55
        case .oxygen: return 1.52
        case .fluorine: return 1.47
        case .phosphorus: return 1.80
        case .sulfur: return 1.80
        case .chlorine: return 1.75
        case .bromine: return 1.85
        case .iodine: return 1.98
        case .sodium: return 2.27
        case .magnesium: return 1.73
        case .potassium: return 2.75
        case .calcium: return 2.31
        case .iron: return 2.00
        case .copper: return 1.40
        case .zinc: return 1.39
        }
    }

    /// Covalent radius in Angstroms
    var covalentRadius: Float {
        switch self {
        case .hydrogen: return 0.31
        case .carbon: return 0.76
        case .nitrogen: return 0.71
        case .oxygen: return 0.66
        case .fluorine: return 0.57
        case .phosphorus: return 1.07
        case .sulfur: return 1.05
        case .chlorine: return 1.02
        case .bromine: return 1.20
        case .iodine: return 1.39
        case .sodium: return 1.66
        case .magnesium: return 1.41
        case .potassium: return 2.03
        case .calcium: return 1.76
        case .iron: return 1.32
        case .copper: return 1.32
        case .zinc: return 1.22
        }
    }

    /// CPK (Corey-Pauling-Koltun) color for molecular visualization
    var cpkColor: Color {
        switch self {
        case .hydrogen: return .white
        case .carbon: return Color(red: 0.5, green: 0.5, blue: 0.5) // Gray
        case .nitrogen: return Color(red: 0.2, green: 0.2, blue: 1.0) // Blue
        case .oxygen: return Color(red: 1.0, green: 0.05, blue: 0.05) // Red
        case .fluorine: return Color(red: 0.12, green: 0.94, blue: 0.12) // Green
        case .phosphorus: return Color(red: 1.0, green: 0.5, blue: 0.0) // Orange
        case .sulfur: return Color(red: 1.0, green: 1.0, blue: 0.19) // Yellow
        case .chlorine: return Color(red: 0.12, green: 0.94, blue: 0.12) // Green
        case .bromine: return Color(red: 0.65, green: 0.16, blue: 0.16) // Brown
        case .iodine: return Color(red: 0.58, green: 0.0, blue: 0.58) // Purple
        case .sodium: return Color(red: 0.67, green: 0.36, blue: 0.95) // Violet
        case .magnesium: return Color(red: 0.54, green: 1.0, blue: 0.0) // Green
        case .potassium: return Color(red: 0.56, green: 0.25, blue: 0.83) // Purple
        case .calcium: return Color(red: 0.24, green: 1.0, blue: 0.0) // Green
        case .iron: return Color(red: 0.88, green: 0.40, blue: 0.20) // Orange
        case .copper: return Color(red: 0.78, green: 0.50, blue: 0.20) // Copper
        case .zinc: return Color(red: 0.49, green: 0.50, blue: 0.69) // Gray-blue
        }
    }

    /// Electronegativity (Pauling scale)
    var electronegativity: Double {
        switch self {
        case .hydrogen: return 2.20
        case .carbon: return 2.55
        case .nitrogen: return 3.04
        case .oxygen: return 3.44
        case .fluorine: return 3.98
        case .phosphorus: return 2.19
        case .sulfur: return 2.58
        case .chlorine: return 3.16
        case .bromine: return 2.96
        case .iodine: return 2.66
        case .sodium: return 0.93
        case .magnesium: return 1.31
        case .potassium: return 0.82
        case .calcium: return 1.00
        case .iron: return 1.83
        case .copper: return 1.90
        case .zinc: return 1.65
        }
    }

    /// Typical valence (number of bonds)
    var typicalValence: Int {
        switch self {
        case .hydrogen: return 1
        case .carbon: return 4
        case .nitrogen: return 3
        case .oxygen: return 2
        case .fluorine: return 1
        case .phosphorus: return 3
        case .sulfur: return 2
        case .chlorine: return 1
        case .bromine: return 1
        case .iodine: return 1
        case .sodium: return 1
        case .magnesium: return 2
        case .potassium: return 1
        case .calcium: return 2
        case .iron: return 2
        case .copper: return 2
        case .zinc: return 2
        }
    }
}

// MARK: - Element Extensions

extension Element {
    /// Check if element is a metal
    var isMetal: Bool {
        switch self {
        case .sodium, .magnesium, .potassium, .calcium, .iron, .copper, .zinc:
            return true
        default:
            return false
        }
    }

    /// Check if element is a halogen
    var isHalogen: Bool {
        switch self {
        case .fluorine, .chlorine, .bromine, .iodine:
            return true
        default:
            return false
        }
    }

    /// Check if element is a nonmetal
    var isNonmetal: Bool {
        !isMetal && !isHalogen
    }
}
