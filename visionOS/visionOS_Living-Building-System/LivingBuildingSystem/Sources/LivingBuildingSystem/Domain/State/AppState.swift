import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    // Current context
    var currentHome: Home?
    var currentRoom: Room?
    var currentUser: User?

    // Device state
    var devices: [UUID: SmartDevice] = [:]

    // UI state
    var selectedDeviceID: UUID?
    var showingSettings = false

    // Loading states
    var isLoadingDevices = false

    // Error state
    var currentError: LBSError?

    init() {
        // Initialize with default values
    }
}

// MARK: - Computed Properties
extension AppState {
    var devicesList: [SmartDevice] {
        Array(devices.values).sorted { $0.name < $1.name }
    }

    var devicesInCurrentRoom: [SmartDevice] {
        guard let roomID = currentRoom?.id else { return [] }
        return devices.values.filter { $0.room?.id == roomID }
    }

    var activeDeviceCount: Int {
        devices.values.filter { $0.currentState?.isOn == true }.count
    }

    var reachableDeviceCount: Int {
        devices.values.filter { $0.isReachable }.count
    }
}

// MARK: - Device Operations
extension AppState {
    func addDevice(_ device: SmartDevice) {
        devices[device.id] = device
    }

    func updateDevice(_ device: SmartDevice) {
        devices[device.id] = device
        device.updatedAt = Date()
    }

    func removeDevice(_ deviceID: UUID) {
        devices.removeValue(forKey: deviceID)
    }

    func device(for id: UUID) -> SmartDevice? {
        devices[id]
    }
}

// MARK: - Error Handling
extension AppState {
    func handleError(_ error: Error) {
        if let lbsError = error as? LBSError {
            currentError = lbsError
        } else {
            currentError = .unknown(error)
        }

        // Auto-dismiss after 5 seconds
        Task {
            try? await Task.sleep(for: .seconds(5))
            if currentError?.id == error.id {
                currentError = nil
            }
        }
    }

    func dismissError() {
        currentError = nil
    }
}

// MARK: - Preview Support
extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.currentHome = Home.preview
        state.currentUser = User.preview

        for device in SmartDevice.previewList {
            state.devices[device.id] = device
        }

        return state
    }
}

// MARK: - Error Helper
extension Error {
    var id: String {
        "\(type(of: self)).\(localizedDescription)"
    }
}
