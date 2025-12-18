import Foundation
import HomeKit

/// HomeKit service implementation for device discovery and control
actor HomeKitService: NSObject, HomeKitServiceProtocol {
    private let homeManager: HMHomeManager
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    private var accessories: [HMAccessory] = []

    // Callbacks for state updates
    var onDeviceStateChanged: ((SmartDevice) -> Void)?

    override init() {
        self.homeManager = HMHomeManager()
        super.init()
        homeManager.delegate = self
    }

    // MARK: - State Change Handler

    func setStateChangeHandler(_ handler: @escaping (SmartDevice) -> Void) {
        onDeviceStateChanged = handler
        Logger.shared.log("State change handler registered", category: "HomeKit")
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        Logger.shared.log("Requesting HomeKit authorization", category: "HomeKit")

        // HomeKit authorization is implicit - wait for home manager to be ready
        try await withCheckedThrowingContinuation { continuation in
            authorizationContinuation = continuation
        }
    }

    // MARK: - Device Discovery

    func discoverAccessories() async throws -> [SmartDevice] {
        Logger.shared.log("Discovering HomeKit accessories", category: "HomeKit")

        guard let primaryHome = homeManager.primaryHome else {
            throw HomeKitError.noPrimaryHome
        }

        accessories = primaryHome.accessories

        // Convert HomeKit accessories to SmartDevice models
        var devices: [SmartDevice] = []

        for accessory in accessories {
            if let device = convertToSmartDevice(accessory) {
                devices.append(device)
            }
        }

        Logger.shared.log("Discovered \(devices.count) accessories", category: "HomeKit")
        return devices
    }

    // MARK: - Device Control

    func toggleDevice(_ device: SmartDevice) async throws {
        guard let accessory = findAccessory(for: device) else {
            throw HomeKitError.accessoryNotReachable
        }

        guard let service = accessory.services.first(where: { isPowerService($0) }) else {
            throw HomeKitError.serviceNotFound
        }

        guard let characteristic = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypePowerState
        }) else {
            throw HomeKitError.characteristicNotFound
        }

        // Get current state
        let currentValue = characteristic.value as? Bool ?? false
        let newValue = !currentValue

        Logger.shared.log("Toggling device \(device.name) to \(newValue)", category: "HomeKit")

        // Write new value
        try await writeCharacteristic(characteristic, value: newValue)
    }

    func setBrightness(_ device: SmartDevice, brightness: Double) async throws {
        guard let accessory = findAccessory(for: device) else {
            throw HomeKitError.accessoryNotReachable
        }

        guard let service = accessory.services.first(where: {
            $0.serviceType == HMServiceTypeLightbulb
        }) else {
            throw HomeKitError.serviceNotFound
        }

        guard let characteristic = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeBrightness
        }) else {
            throw HomeKitError.characteristicNotFound
        }

        let value = Int(brightness * 100) // Convert 0-1 to 0-100
        Logger.shared.log("Setting brightness for \(device.name) to \(value)%", category: "HomeKit")

        try await writeCharacteristic(characteristic, value: value)
    }

    func setTargetTemperature(_ device: SmartDevice, temperature: Double) async throws {
        guard let accessory = findAccessory(for: device) else {
            throw HomeKitError.accessoryNotReachable
        }

        guard let service = accessory.services.first(where: {
            $0.serviceType == HMServiceTypeThermostat
        }) else {
            throw HomeKitError.serviceNotFound
        }

        guard let characteristic = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeTargetTemperature
        }) else {
            throw HomeKitError.characteristicNotFound
        }

        Logger.shared.log("Setting target temperature for \(device.name) to \(temperature)°F", category: "HomeKit")

        try await writeCharacteristic(characteristic, value: temperature)
    }

    // MARK: - Monitoring

    func startMonitoring() {
        Logger.shared.log("Starting HomeKit monitoring", category: "HomeKit")

        guard let primaryHome = homeManager.primaryHome else { return }

        for accessory in primaryHome.accessories {
            accessory.delegate = self

            // Enable notifications for all characteristics
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.properties.contains(.supportsEventNotification) {
                        characteristic.enableNotification(true) { error in
                            if let error = error {
                                Logger.shared.log(
                                    "Failed to enable notifications",
                                    level: .error,
                                    error: error,
                                    category: "HomeKit"
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    func stopMonitoring() {
        Logger.shared.log("Stopping HomeKit monitoring", category: "HomeKit")

        guard let primaryHome = homeManager.primaryHome else { return }

        for accessory in primaryHome.accessories {
            accessory.delegate = nil
        }
    }

    // MARK: - Helper Methods

    private func writeCharacteristic(_ characteristic: HMCharacteristic, value: Any) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            characteristic.writeValue(value) { error in
                if let error = error {
                    continuation.resume(throwing: HomeKitError.operationFailed(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func readCharacteristic(_ characteristic: HMCharacteristic) async throws -> Any? {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Any?, Error>) in
            characteristic.readValue { error in
                if let error = error {
                    continuation.resume(throwing: HomeKitError.operationFailed(error))
                } else {
                    continuation.resume(returning: characteristic.value)
                }
            }
        }
    }

    private func findAccessory(for device: SmartDevice) -> HMAccessory? {
        guard let identifier = device.homeKitIdentifier else { return nil }
        return accessories.first { $0.uniqueIdentifier.uuidString == identifier }
    }

    private func convertToSmartDevice(_ accessory: HMAccessory) -> SmartDevice? {
        // Determine device type from accessory category
        let deviceType = determineDeviceType(from: accessory)

        let device = SmartDevice(name: accessory.name, deviceType: deviceType)
        device.homeKitIdentifier = accessory.uniqueIdentifier.uuidString
        device.manufacturer = accessory.manufacturer
        device.model = accessory.model
        device.isReachable = accessory.isReachable
        device.lastSeen = Date()

        // Get current state
        let state = extractDeviceState(from: accessory, deviceType: deviceType)
        device.currentState = state

        return device
    }

    private func determineDeviceType(from accessory: HMAccessory) -> DeviceType {
        switch accessory.category.categoryType {
        case HMAccessoryCategoryTypeLightbulb:
            return .light
        case HMAccessoryCategoryTypeSwitch:
            return .switch_
        case HMAccessoryCategoryTypeOutlet:
            return .outlet
        case HMAccessoryCategoryTypeThermostat:
            return .thermostat
        case HMAccessoryCategoryTypeDoorLock:
            return .lock
        case HMAccessoryCategoryTypeGarageDoorOpener:
            return .garageDoor
        case HMAccessoryCategoryTypeSensor:
            return .sensor
        default:
            return .switch_
        }
    }

    private func extractDeviceState(from accessory: HMAccessory, deviceType: DeviceType) -> DeviceState {
        let state = DeviceState()

        for service in accessory.services {
            // Get power state
            if let powerChar = service.characteristics.first(where: {
                $0.characteristicType == HMCharacteristicTypePowerState
            }) {
                state.isOn = powerChar.value as? Bool
            }

            // Get brightness
            if deviceType == .light,
               let brightnessChar = service.characteristics.first(where: {
                   $0.characteristicType == HMCharacteristicTypeBrightness
               }) {
                if let value = brightnessChar.value as? Int {
                    state.brightness = Double(value) / 100.0
                }
            }

            // Get temperature
            if deviceType == .thermostat {
                if let currentTemp = service.characteristics.first(where: {
                    $0.characteristicType == HMCharacteristicTypeCurrentTemperature
                }) {
                    state.temperature = currentTemp.value as? Double
                }

                if let targetTemp = service.characteristics.first(where: {
                    $0.characteristicType == HMCharacteristicTypeTargetTemperature
                }) {
                    state.targetTemperature = targetTemp.value as? Double
                }
            }

            // Get lock state
            if deviceType == .lock,
               let lockChar = service.characteristics.first(where: {
                   $0.characteristicType == HMCharacteristicTypeCurrentLockMechanismState
               }) {
                if let value = lockChar.value as? Int {
                    state.isLocked = (value == HMCharacteristicValueLockMechanismState.secured.rawValue)
                }
            }
        }

        return state
    }

    private func isPowerService(_ service: HMService) -> Bool {
        service.serviceType == HMServiceTypeLightbulb ||
        service.serviceType == HMServiceTypeSwitch ||
        service.serviceType == HMServiceTypeOutlet
    }
}

// MARK: - HMHomeManagerDelegate

extension HomeKitService: HMHomeManagerDelegate {
    nonisolated func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Task {
            await resumeAuthorization()
        }
    }

    private func resumeAuthorization() {
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    nonisolated func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        Logger.shared.log("Home added: \(home.name)", category: "HomeKit")
    }

    nonisolated func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        Logger.shared.log("Home removed: \(home.name)", category: "HomeKit")
    }
}

// MARK: - HMAccessoryDelegate

extension HomeKitService: HMAccessoryDelegate {
    nonisolated func accessory(
        _ accessory: HMAccessory,
        service: HMService,
        didUpdateValueFor characteristic: HMCharacteristic
    ) {
        Logger.shared.log(
            "Characteristic updated: \(accessory.name) - \(characteristic.characteristicType)",
            category: "HomeKit"
        )

        // Notify about state change
        Task {
            await handleCharacteristicUpdate(accessory, characteristic)
        }
    }

    private func handleCharacteristicUpdate(_ accessory: HMAccessory, _ characteristic: HMCharacteristic) {
        // Convert to SmartDevice and notify
        if let device = convertToSmartDevice(accessory) {
            onDeviceStateChanged?(device)
        }
    }
}
