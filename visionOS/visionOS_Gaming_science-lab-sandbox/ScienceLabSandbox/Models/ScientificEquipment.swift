//
//  ScientificEquipment.swift
//  Science Lab Sandbox
//
//  Equipment definitions and types
//

import Foundation

// MARK: - Scientific Equipment

struct ScientificEquipment: Codable, Identifiable {
    let id: UUID
    let type: EquipmentType
    let name: String
    let modelAsset: String
    let capabilities: [EquipmentCapability]
    let precisionMM: Double  // Precision in millimeters
    let operatingRange: ClosedRange<Double>?

    init(
        id: UUID = UUID(),
        type: EquipmentType,
        name: String,
        modelAsset: String,
        capabilities: [EquipmentCapability],
        precisionMM: Double = 1.0,
        operatingRange: ClosedRange<Double>? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.modelAsset = modelAsset
        self.capabilities = capabilities
        self.precisionMM = precisionMM
        self.operatingRange = operatingRange
    }
}

// MARK: - Equipment Type

enum EquipmentType: String, Codable, CaseIterable {
    // Chemistry Equipment
    case beaker
    case flask
    case testTube
    case burner
    case pipette
    case graduatedCylinder
    case funnel
    case stirRod
    case thermometer
    case pHMeter
    case scale

    // Physics Equipment
    case forceSensor
    case motionTracker
    case voltmeter
    case ammeter
    case oscilloscope
    case resistor
    case capacitor
    case battery
    case wire
    case magnet
    case pulley
    case spring

    // Biology Equipment
    case microscope
    case dissectionKit
    case petriDish
    case centrifuge
    case incubator
    case autoclave
    case slide
    case coverSlip

    // Astronomy Equipment
    case telescope
    case planetarium
    case spectrometer
    case starChart

    // General Equipment
    case safetyGoggles
    case labCoat
    case gloves
    case timer
    case notebook

    var displayName: String {
        switch self {
        case .beaker: return "Beaker"
        case .flask: return "Flask"
        case .testTube: return "Test Tube"
        case .burner: return "Bunsen Burner"
        case .pipette: return "Pipette"
        case .graduatedCylinder: return "Graduated Cylinder"
        case .funnel: return "Funnel"
        case .stirRod: return "Stirring Rod"
        case .thermometer: return "Thermometer"
        case .pHMeter: return "pH Meter"
        case .scale: return "Digital Scale"
        case .forceSensor: return "Force Sensor"
        case .motionTracker: return "Motion Tracker"
        case .voltmeter: return "Voltmeter"
        case .ammeter: return "Ammeter"
        case .oscilloscope: return "Oscilloscope"
        case .resistor: return "Resistor"
        case .capacitor: return "Capacitor"
        case .battery: return "Battery"
        case .wire: return "Wire"
        case .magnet: return "Magnet"
        case .pulley: return "Pulley"
        case .spring: return "Spring"
        case .microscope: return "Microscope"
        case .dissectionKit: return "Dissection Kit"
        case .petriDish: return "Petri Dish"
        case .centrifuge: return "Centrifuge"
        case .incubator: return "Incubator"
        case .autoclave: return "Autoclave"
        case .slide: return "Microscope Slide"
        case .coverSlip: return "Cover Slip"
        case .telescope: return "Telescope"
        case .planetarium: return "Planetarium"
        case .spectrometer: return "Spectrometer"
        case .starChart: return "Star Chart"
        case .safetyGoggles: return "Safety Goggles"
        case .labCoat: return "Lab Coat"
        case .gloves: return "Safety Gloves"
        case .timer: return "Timer"
        case .notebook: return "Lab Notebook"
        }
    }

    var discipline: ScientificDiscipline {
        switch self {
        case .beaker, .flask, .testTube, .burner, .pipette, .graduatedCylinder,
             .funnel, .stirRod, .thermometer, .pHMeter, .scale:
            return .chemistry
        case .forceSensor, .motionTracker, .voltmeter, .ammeter, .oscilloscope,
             .resistor, .capacitor, .battery, .wire, .magnet, .pulley, .spring:
            return .physics
        case .microscope, .dissectionKit, .petriDish, .centrifuge, .incubator,
             .autoclave, .slide, .coverSlip:
            return .biology
        case .telescope, .planetarium, .spectrometer, .starChart:
            return .astronomy
        case .safetyGoggles, .labCoat, .gloves, .timer, .notebook:
            return .chemistry  // General, defaulting to chemistry
        }
    }
}

// MARK: - Equipment Capability

enum EquipmentCapability: String, Codable {
    case measure
    case contain
    case heat
    case cool
    case mix
    case separate
    case observe
    case record
    case protect
    case calculate
    case amplify
    case detect
}

// MARK: - Equipment State

struct EquipmentState: Codable {
    var isActive: Bool
    var temperature: Double?  // Celsius
    var contents: [String]?  // Chemical IDs or specimen IDs
    var measurement: Double?
    var setting: String?

    init(
        isActive: Bool = false,
        temperature: Double? = nil,
        contents: [String]? = nil,
        measurement: Double? = nil,
        setting: String? = nil
    ) {
        self.isActive = isActive
        self.temperature = temperature
        self.contents = contents
        self.measurement = measurement
        self.setting = setting
    }
}
