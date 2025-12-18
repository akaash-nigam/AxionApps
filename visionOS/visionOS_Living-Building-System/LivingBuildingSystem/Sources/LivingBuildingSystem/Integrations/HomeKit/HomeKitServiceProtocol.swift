import Foundation
import HomeKit

/// Protocol defining HomeKit service operations
protocol HomeKitServiceProtocol: Actor {
    /// Request HomeKit authorization
    func requestAuthorization() async throws

    /// Discover all accessories in the primary home
    func discoverAccessories() async throws -> [SmartDevice]

    /// Toggle a device on/off
    func toggleDevice(_ device: SmartDevice) async throws

    /// Set device brightness (for lights)
    func setBrightness(_ device: SmartDevice, brightness: Double) async throws

    /// Set thermostat target temperature
    func setTargetTemperature(_ device: SmartDevice, temperature: Double) async throws

    /// Start monitoring device state changes
    func startMonitoring()

    /// Stop monitoring device state changes
    func stopMonitoring()
}

// MARK: - HomeKit Error
enum HomeKitError: LocalizedError {
    case noPrimaryHome
    case serviceNotFound
    case characteristicNotFound
    case accessoryNotReachable
    case authorizationFailed
    case operationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noPrimaryHome:
            return "No primary home configured"
        case .serviceNotFound:
            return "Device service not available"
        case .characteristicNotFound:
            return "Device characteristic not found"
        case .accessoryNotReachable:
            return "Device is not reachable"
        case .authorizationFailed:
            return "HomeKit authorization denied"
        case .operationFailed(let error):
            return "Operation failed: \(error.localizedDescription)"
        }
    }
}
