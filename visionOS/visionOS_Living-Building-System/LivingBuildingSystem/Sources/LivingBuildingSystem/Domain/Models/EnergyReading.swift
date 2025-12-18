import Foundation
import SwiftData

@Model
final class EnergyReading {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var energyType: EnergyType

    // Consumption
    var instantaneousPower: Double? // kW or gallons/min
    var cumulativeConsumption: Double? // kWh or gallons

    // Generation (solar)
    var instantaneousGeneration: Double? // kW
    var cumulativeGeneration: Double? // kWh

    // By circuit/appliance (optional)
    var circuitBreakdownData: Data? // Encoded [String: Double]

    var deviceID: UUID? // If specific device (smart plug)

    init(timestamp: Date = Date(), energyType: EnergyType) {
        self.id = UUID()
        self.timestamp = timestamp
        self.energyType = energyType
    }

    // Helper to work with circuit breakdown
    var circuitBreakdown: [String: Double]? {
        get {
            guard let data = circuitBreakdownData else { return nil }
            return try? JSONDecoder().decode([String: Double].self, from: data)
        }
        set {
            circuitBreakdownData = try? JSONEncoder().encode(newValue)
        }
    }

    // Calculate cost based on energy type and rate
    func calculateCost(configuration: EnergyConfiguration) -> Double {
        switch energyType {
        case .electricity:
            return (cumulativeConsumption ?? 0) * configuration.electricityRatePerKWh
        case .gas:
            return (cumulativeConsumption ?? 0) * (configuration.gasRatePerTherm ?? 0)
        case .water:
            return (cumulativeConsumption ?? 0) * configuration.waterRatePerGallon
        case .solar:
            // Solar is generation, not consumption
            return 0
        }
    }

    // Net power (generation - consumption)
    var netPower: Double? {
        guard let generation = instantaneousGeneration,
              let consumption = instantaneousPower else {
            return nil
        }
        return generation - consumption
    }
}

enum EnergyType: String, Codable {
    case electricity
    case gas
    case water
    case solar
}

// MARK: - Preview Data
extension EnergyReading {
    static var preview: EnergyReading {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        reading.instantaneousPower = 3.5 // 3.5 kW
        reading.cumulativeConsumption = 125.4 // 125.4 kWh today
        return reading
    }

    static var previewSolar: EnergyReading {
        let reading = EnergyReading(timestamp: Date(), energyType: .solar)
        reading.instantaneousGeneration = 4.2 // 4.2 kW generating
        reading.cumulativeGeneration = 28.5 // 28.5 kWh generated today
        return reading
    }

    static var previewMultiple: [EnergyReading] {
        let now = Date()
        return (0..<24).map { hour in
            let reading = EnergyReading(
                timestamp: Calendar.current.date(byAdding: .hour, value: -hour, to: now)!,
                energyType: .electricity
            )
            // Simulate usage pattern
            let baseLoad = 1.5
            let peakHour = (8...20).contains(23 - hour)
            reading.instantaneousPower = baseLoad + (peakHour ? Double.random(in: 1.0...4.0) : Double.random(in: 0.0...1.0))
            reading.cumulativeConsumption = Double(hour) * 2.5
            return reading
        }.reversed()
    }
}
