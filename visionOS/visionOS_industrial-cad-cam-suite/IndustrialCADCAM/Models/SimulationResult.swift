import Foundation
import SwiftData

@Model
final class SimulationResult {
    @Attribute(.unique) var id: UUID
    var simulationName: String
    var simulationType: String // "Stress", "Thermal", "Modal", "Fluid"

    var partID: UUID
    var part: Part?

    var timestamp: Date

    // Analysis results (simplified - would be more complex in production)
    var maxStress: Double? // MPa
    var maxStressLocation: Position3D?
    var minSafetyFactor: Double?

    var maxTemperature: Double? // °C
    var minTemperature: Double?

    var naturalFrequencies: [Double]? // Hz

    // Visualization data
    @Attribute(.externalStorage)
    var visualizationData: Data?

    var colorMapType: String // "stress", "thermal", "displacement"

    // Summary
    var passed: Bool
    var recommendations: [String]

    var createdDate: Date

    init(
        simulationName: String,
        simulationType: String,
        partID: UUID
    ) {
        self.id = UUID()
        self.simulationName = simulationName
        self.simulationType = simulationType
        self.partID = partID
        self.timestamp = Date()
        self.passed = false
        self.recommendations = []
        self.createdDate = Date()
        self.colorMapType = "stress"
    }

    // MARK: - Computed Properties
    var statusColor: String {
        passed ? "green" : "red"
    }

    var summary: String {
        switch simulationType {
        case "Stress":
            if let maxStress = maxStress, let safetyFactor = minSafetyFactor {
                return "Max Stress: \(String(format: "%.1f", maxStress)) MPa, Safety Factor: \(String(format: "%.2f", safetyFactor))"
            }
        case "Thermal":
            if let maxTemp = maxTemperature, let minTemp = minTemperature {
                return "Temperature Range: \(String(format: "%.1f", minTemp))°C - \(String(format: "%.1f", maxTemp))°C"
            }
        case "Modal":
            if let frequencies = naturalFrequencies, !frequencies.isEmpty {
                return "First Natural Frequency: \(String(format: "%.1f", frequencies[0])) Hz"
            }
        default:
            break
        }
        return "No data available"
    }
}
