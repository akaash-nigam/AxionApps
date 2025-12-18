import Foundation
import SwiftData

@Model
final class EnergyConfiguration {
    @Attribute(.unique) var id: UUID

    var hasSmartMeter: Bool
    var hasSolar: Bool
    var hasBattery: Bool

    var electricityRatePerKWh: Double
    var gasRatePerTherm: Double?
    var waterRatePerGallon: Double

    // API credentials (encrypted in Keychain, only store identifiers here)
    var meterAPIIdentifier: String?
    var solarAPIIdentifier: String?
    var batteryAPIIdentifier: String?

    var updatedAt: Date

    init() {
        self.id = UUID()
        self.hasSmartMeter = false
        self.hasSolar = false
        self.hasBattery = false
        self.electricityRatePerKWh = 0.15
        self.waterRatePerGallon = 0.006
        self.updatedAt = Date()
    }

    // Helper methods
    func updateRates(electricity: Double? = nil, gas: Double? = nil, water: Double? = nil) {
        if let electricity = electricity {
            self.electricityRatePerKWh = electricity
        }
        if let gas = gas {
            self.gasRatePerTherm = gas
        }
        if let water = water {
            self.waterRatePerGallon = water
        }
        self.updatedAt = Date()
    }

    var isConfigured: Bool {
        hasSmartMeter || hasSolar || hasBattery
    }
}
