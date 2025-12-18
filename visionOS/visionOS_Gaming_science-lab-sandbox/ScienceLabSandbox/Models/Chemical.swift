//
//  Chemical.swift
//  Science Lab Sandbox
//
//  Chemical substance data model
//

import Foundation
import SwiftUI

// MARK: - Chemical

struct Chemical: Codable, Identifiable, Hashable {
    let id: UUID
    let formula: String
    let name: String
    let molarMass: Double  // g/mol

    var concentration: Double  // mol/L
    var volume: Double  // mL
    var temperature: Double  // Celsius
    var pressure: Double  // kPa

    // Safety properties
    let hazardClass: HazardClass
    let flammability: FlammabilityRating
    let reactivity: ReactivityRating
    let toxicity: ToxicityLevel

    // Physical properties
    let color: ColorDescription
    let state: MatterState
    var opacity: Double  // 0.0 to 1.0
    let density: Double  // g/mL

    // Chemical properties
    let pH: Double?
    let boilingPoint: Double?  // Celsius
    let meltingPoint: Double?  // Celsius

    init(
        id: UUID = UUID(),
        formula: String,
        name: String,
        molarMass: Double,
        concentration: Double = 1.0,
        volume: Double = 100.0,
        temperature: Double = 25.0,
        pressure: Double = 101.325,
        hazardClass: HazardClass = .safe,
        flammability: FlammabilityRating = .nonFlammable,
        reactivity: ReactivityRating = .stable,
        toxicity: ToxicityLevel = .nonToxic,
        color: ColorDescription = .clear,
        state: MatterState = .liquid,
        opacity: Double = 1.0,
        density: Double = 1.0,
        pH: Double? = nil,
        boilingPoint: Double? = nil,
        meltingPoint: Double? = nil
    ) {
        self.id = id
        self.formula = formula
        self.name = name
        self.molarMass = molarMass
        self.concentration = concentration
        self.volume = volume
        self.temperature = temperature
        self.pressure = pressure
        self.hazardClass = hazardClass
        self.flammability = flammability
        self.reactivity = reactivity
        self.toxicity = toxicity
        self.color = color
        self.state = state
        self.opacity = opacity
        self.density = density
        self.pH = pH
        self.boilingPoint = boilingPoint
        self.meltingPoint = meltingPoint
    }

    // Calculate moles
    func moles() -> Double {
        return concentration * volume / 1000.0  // Convert mL to L
    }

    // Calculate mass
    func mass() -> Double {
        return moles() * molarMass
    }

    // Common chemicals
    static let water = Chemical(
        formula: "H2O",
        name: "Water",
        molarMass: 18.015,
        color: .clear,
        state: .liquid,
        opacity: 0.95,
        density: 1.0,
        pH: 7.0,
        boilingPoint: 100.0,
        meltingPoint: 0.0
    )

    static let hydrochloricAcid = Chemical(
        formula: "HCl",
        name: "Hydrochloric Acid",
        molarMass: 36.461,
        hazardClass: .corrosive,
        reactivity: .reactive,
        toxicity: .toxic,
        color: .clear,
        state: .aqueous,
        pH: 1.0
    )

    static let sodiumHydroxide = Chemical(
        formula: "NaOH",
        name: "Sodium Hydroxide",
        molarMass: 39.997,
        hazardClass: .corrosive,
        reactivity: .reactive,
        toxicity: .toxic,
        color: .clear,
        state: .aqueous,
        pH: 14.0
    )

    static let sodiumChloride = Chemical(
        formula: "NaCl",
        name: "Sodium Chloride",
        molarMass: 58.443,
        hazardClass: .safe,
        color: .white,
        state: .solid,
        density: 2.16
    )

    static let vinegar = Chemical(
        formula: "CH3COOH",
        name: "Acetic Acid (Vinegar)",
        molarMass: 60.052,
        concentration: 0.83,  // 5% vinegar
        hazardClass: .irritant,
        color: .clear,
        state: .aqueous,
        pH: 2.9
    )

    static let bakingSoda = Chemical(
        formula: "NaHCO3",
        name: "Sodium Bicarbonate",
        molarMass: 84.007,
        hazardClass: .safe,
        color: .white,
        state: .solid,
        pH: 8.3
    )
}

// MARK: - Hazard Class

enum HazardClass: String, Codable {
    case safe
    case irritant
    case corrosive
    case toxic
    case explosive
    case radioactive
    case oxidizer
    case flammable

    var displayName: String {
        switch self {
        case .safe: return "Safe"
        case .irritant: return "Irritant"
        case .corrosive: return "Corrosive"
        case .toxic: return "Toxic"
        case .explosive: return "Explosive"
        case .radioactive: return "Radioactive"
        case .oxidizer: return "Oxidizer"
        case .flammable: return "Flammable"
        }
    }

    var systemImage: String {
        switch self {
        case .safe: return "checkmark.shield"
        case .irritant: return "exclamationmark.triangle"
        case .corrosive: return "drop.triangle"
        case .toxic: return "skull"
        case .explosive: return "burst"
        case .radioactive: return "atom"
        case .oxidizer: return "flame"
        case .flammable: return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .safe: return .green
        case .irritant: return .yellow
        case .corrosive: return .orange
        case .toxic: return .red
        case .explosive: return .red
        case .radioactive: return .purple
        case .oxidizer: return .orange
        case .flammable: return .red
        }
    }
}

// MARK: - Flammability Rating

enum FlammabilityRating: Int, Codable {
    case nonFlammable = 0
    case slightlyFlammable = 1
    case combustible = 2
    case flammable = 3
    case extremelyFlammable = 4
}

// MARK: - Reactivity Rating

enum ReactivityRating: Int, Codable {
    case stable = 0
    case slightlyReactive = 1
    case reactive = 2
    case highlyReactive = 3
    case mayDetonate = 4
}

// MARK: - Toxicity Level

enum ToxicityLevel: Int, Codable {
    case nonToxic = 0
    case slightlyToxic = 1
    case toxic = 2
    case highlyToxic = 3
    case extremelyToxic = 4
}

// MARK: - Matter State

enum MatterState: String, Codable {
    case solid
    case liquid
    case gas
    case plasma
    case aqueous  // Dissolved in water

    var displayName: String {
        switch self {
        case .solid: return "Solid"
        case .liquid: return "Liquid"
        case .gas: return "Gas"
        case .plasma: return "Plasma"
        case .aqueous: return "Aqueous"
        }
    }
}

// MARK: - Color Description

enum ColorDescription: String, Codable {
    case clear
    case white
    case black
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case brown
    case pink
    case colorless

    var swiftUIColor: Color {
        switch self {
        case .clear, .colorless: return Color.clear
        case .white: return Color.white
        case .black: return Color.black
        case .red: return Color.red
        case .orange: return Color.orange
        case .yellow: return Color.yellow
        case .green: return Color.green
        case .blue: return Color.blue
        case .purple: return Color.purple
        case .brown: return Color.brown
        case .pink: return Color.pink
        }
    }
}
