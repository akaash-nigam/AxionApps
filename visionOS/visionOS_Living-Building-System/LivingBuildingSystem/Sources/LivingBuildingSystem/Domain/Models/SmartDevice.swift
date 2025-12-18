import Foundation
import SwiftData

@Model
final class SmartDevice {
    @Attribute(.unique) var id: UUID
    var name: String
    var deviceType: DeviceType
    var manufacturer: String?
    var model: String?

    // Integration identifiers
    var homeKitIdentifier: String?

    var isReachable: Bool
    var lastSeen: Date?

    @Relationship(deleteRule: .nullify, inverse: \Room.devices)
    var room: Room?

    @Relationship(deleteRule: .cascade, inverse: \DeviceState.device)
    var currentState: DeviceState?

    var createdAt: Date
    var updatedAt: Date

    init(name: String, deviceType: DeviceType) {
        self.id = UUID()
        self.name = name
        self.deviceType = deviceType
        self.isReachable = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Device Type
enum DeviceType: String, Codable, CaseIterable {
    case light
    case switch_
    case outlet
    case thermostat
    case lock
    case garageDoor
    case sensor

    var displayName: String {
        switch self {
        case .light: "Light"
        case .switch_: "Switch"
        case .outlet: "Outlet"
        case .thermostat: "Thermostat"
        case .lock: "Lock"
        case .garageDoor: "Garage Door"
        case .sensor: "Sensor"
        }
    }

    var icon: String {
        switch self {
        case .light: "lightbulb.fill"
        case .switch_: "light.switch.on.fill"
        case .outlet: "powerplug.fill"
        case .thermostat: "thermometer"
        case .lock: "lock.fill"
        case .garageDoor: "garage"
        case .sensor: "sensor.fill"
        }
    }

    var supportsOnOff: Bool {
        switch self {
        case .light, .switch_, .outlet:
            return true
        default:
            return false
        }
    }

    var supportsBrightness: Bool {
        self == .light
    }

    var supportsTemperature: Bool {
        self == .thermostat
    }
}

// MARK: - Preview Support
extension SmartDevice {
    static var preview: SmartDevice {
        let device = SmartDevice(name: "Living Room Light", deviceType: .light)
        device.isReachable = true

        let state = DeviceState()
        state.isOn = true
        state.brightness = 0.75
        device.currentState = state

        return device
    }

    static var previewList: [SmartDevice] {
        [
            SmartDevice(name: "Living Room Light", deviceType: .light).apply {
                $0.currentState = DeviceState()
                $0.currentState?.isOn = true
            },
            SmartDevice(name: "Kitchen Light", deviceType: .light).apply {
                $0.currentState = DeviceState()
                $0.currentState?.isOn = false
            },
            SmartDevice(name: "Thermostat", deviceType: .thermostat).apply {
                $0.currentState = DeviceState()
                $0.currentState?.temperature = 72.0
                $0.currentState?.targetTemperature = 70.0
            },
            SmartDevice(name: "Front Door Lock", deviceType: .lock).apply {
                $0.currentState = DeviceState()
                $0.currentState?.isLocked = true
            }
        ]
    }

    func apply(_ changes: (SmartDevice) -> Void) -> SmartDevice {
        changes(self)
        return self
    }
}
