import Foundation
import SwiftData

@Model
final class DeviceState {
    @Attribute(.unique) var id: UUID

    @Relationship(deleteRule: .nullify, inverse: \SmartDevice.currentState)
    var device: SmartDevice?

    // State properties
    var isOn: Bool?
    var brightness: Double? // 0.0 to 1.0
    var temperature: Double? // Current temperature (Fahrenheit)
    var targetTemperature: Double? // Target temperature
    var isLocked: Bool?
    var position: Double? // 0.0 (closed) to 1.0 (open) - for garage doors, blinds

    var lastUpdated: Date

    init() {
        self.id = UUID()
        self.lastUpdated = Date()
    }
}

// MARK: - Helper Methods
extension DeviceState {
    func update(isOn: Bool) {
        self.isOn = isOn
        self.lastUpdated = Date()
    }

    func update(brightness: Double) {
        self.brightness = max(0.0, min(1.0, brightness))
        self.lastUpdated = Date()
    }

    func update(targetTemperature: Double) {
        self.targetTemperature = targetTemperature
        self.lastUpdated = Date()
    }

    func update(isLocked: Bool) {
        self.isLocked = isLocked
        self.lastUpdated = Date()
    }
}
