import Foundation

@MainActor
final class DeviceManager {
    private let appState: AppState
    private let homeKitService: HomeKitServiceProtocol

    init(appState: AppState, homeKitService: HomeKitServiceProtocol) {
        self.appState = appState
        self.homeKitService = homeKitService

        // Set up state change callback for real-time updates
        Task {
            await setupStateMonitoring()
        }
    }

    private func setupStateMonitoring() async {
        // Set up callback for device state changes
        await homeKitService.startMonitoring()

        // Wire HomeKit updates to AppState
        if let service = homeKitService as? HomeKitService {
            await service.setStateChangeHandler { [weak appState] updatedDevice in
                Task { @MainActor in
                    appState?.updateDevice(updatedDevice)
                    Logger.shared.log("Device state updated: \(updatedDevice.name)", category: "DeviceManager")
                }
            }
        }
    }

    // MARK: - Device Discovery

    func discoverDevices() async throws {
        Logger.shared.log("Starting device discovery", category: "DeviceManager")

        appState.isLoadingDevices = true
        defer { appState.isLoadingDevices = false }

        do {
            let devices = try await homeKitService.discoverAccessories()

            // Update app state with discovered devices
            for device in devices {
                appState.addDevice(device)
            }

            Logger.shared.log("Discovered \(devices.count) devices", category: "DeviceManager")
        } catch {
            Logger.shared.log("Device discovery failed", level: .error, error: error, category: "DeviceManager")
            appState.handleError(LBSError.deviceCommandFailed(UUID(), underlying: error))
            throw error
        }
    }

    // MARK: - Device Control

    func toggleDevice(_ device: SmartDevice) async throws {
        Logger.shared.log("Toggling device: \(device.name)", category: "DeviceManager")

        guard device.isReachable else {
            throw LBSError.deviceUnreachable(device.id)
        }

        guard device.deviceType.supportsOnOff else {
            Logger.shared.log("Device does not support on/off", level: .warning, category: "DeviceManager")
            return
        }

        // Optimistic update
        let originalState = device.currentState?.isOn
        device.currentState?.isOn = !(originalState ?? false)
        appState.updateDevice(device)

        do {
            try await homeKitService.toggleDevice(device)
            Logger.shared.log("Device toggled successfully", category: "DeviceManager")
        } catch {
            // Revert on error
            device.currentState?.isOn = originalState
            appState.updateDevice(device)

            Logger.shared.log("Failed to toggle device", level: .error, error: error, category: "DeviceManager")
            throw LBSError.deviceCommandFailed(device.id, underlying: error)
        }
    }

    func setBrightness(_ device: SmartDevice, brightness: Double) async throws {
        Logger.shared.log("Setting brightness for \(device.name) to \(brightness)", category: "DeviceManager")

        guard device.isReachable else {
            throw LBSError.deviceUnreachable(device.id)
        }

        guard device.deviceType.supportsBrightness else {
            Logger.shared.log("Device does not support brightness", level: .warning, category: "DeviceManager")
            return
        }

        // Optimistic update
        let originalBrightness = device.currentState?.brightness
        device.currentState?.brightness = brightness
        appState.updateDevice(device)

        do {
            try await homeKitService.setBrightness(device, brightness: brightness)
            Logger.shared.log("Brightness set successfully", category: "DeviceManager")
        } catch {
            // Revert on error
            device.currentState?.brightness = originalBrightness
            appState.updateDevice(device)

            Logger.shared.log("Failed to set brightness", level: .error, error: error, category: "DeviceManager")
            throw LBSError.deviceCommandFailed(device.id, underlying: error)
        }
    }

    func setTargetTemperature(_ device: SmartDevice, temperature: Double) async throws {
        Logger.shared.log("Setting target temperature for \(device.name) to \(temperature)", category: "DeviceManager")

        guard device.isReachable else {
            throw LBSError.deviceUnreachable(device.id)
        }

        guard device.deviceType.supportsTemperature else {
            Logger.shared.log("Device does not support temperature", level: .warning, category: "DeviceManager")
            return
        }

        // Optimistic update
        let originalTemp = device.currentState?.targetTemperature
        device.currentState?.targetTemperature = temperature
        appState.updateDevice(device)

        do {
            try await homeKitService.setTargetTemperature(device, temperature: temperature)
            Logger.shared.log("Target temperature set successfully", category: "DeviceManager")
        } catch {
            // Revert on error
            device.currentState?.targetTemperature = originalTemp
            appState.updateDevice(device)

            Logger.shared.log("Failed to set temperature", level: .error, error: error, category: "DeviceManager")
            throw LBSError.deviceCommandFailed(device.id, underlying: error)
        }
    }

    // MARK: - Device Management

    func refreshDevice(_ device: SmartDevice) async throws {
        // Re-fetch device state from HomeKit
        Logger.shared.log("Refreshing device: \(device.name)", category: "DeviceManager")

        // For MVP, we'll just trigger a full discovery
        // In production, we'd query just this device
        try await discoverDevices()
    }

    func removeDevice(_ device: SmartDevice) {
        Logger.shared.log("Removing device: \(device.name)", category: "DeviceManager")
        appState.removeDevice(device.id)
    }
}
