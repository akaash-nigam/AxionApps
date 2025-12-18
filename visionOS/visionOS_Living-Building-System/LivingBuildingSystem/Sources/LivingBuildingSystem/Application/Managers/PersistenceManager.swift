import Foundation
import SwiftData

@MainActor
final class PersistenceManager {
    private let modelContext: ModelContext
    private let appState: AppState

    init(modelContext: ModelContext, appState: AppState) {
        self.modelContext = modelContext
        self.appState = appState
    }

    // MARK: - Load State

    func loadSavedState() async throws {
        Logger.shared.log("Loading saved state", category: "Persistence")

        // Load homes
        let homeDescriptor = FetchDescriptor<Home>()
        let homes = try modelContext.fetch(homeDescriptor)

        if let firstHome = homes.first {
            appState.currentHome = firstHome
            Logger.shared.log("Loaded home: \(firstHome.name)", category: "Persistence")

            // Load rooms
            if let firstRoom = firstHome.rooms.first {
                appState.currentRoom = firstRoom
            }
        }

        // Load users
        let userDescriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(userDescriptor)

        if let firstUser = users.first {
            appState.currentUser = firstUser
            Logger.shared.log("Loaded user: \(firstUser.name)", category: "Persistence")
        }

        Logger.shared.log("State loaded successfully", category: "Persistence")
    }

    // MARK: - Save State

    func saveCurrentState() async throws {
        Logger.shared.log("Saving current state", category: "Persistence")

        // Save devices to their rooms
        for device in appState.devices.values {
            if !modelContext.hasChanges(for: device) {
                modelContext.insert(device)
            }
        }

        // Save current home
        if let home = appState.currentHome, !modelContext.hasChanges(for: home) {
            modelContext.insert(home)
        }

        // Save current user
        if let user = appState.currentUser, !modelContext.hasChanges(for: user) {
            modelContext.insert(user)
        }

        try modelContext.save()
        Logger.shared.log("State saved successfully", category: "Persistence")
    }

    // MARK: - Auto-Save

    func startAutoSave(interval: TimeInterval = 300) {
        Logger.shared.log("Starting auto-save (every \(interval)s)", category: "Persistence")

        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))

                do {
                    try await saveCurrentState()
                } catch {
                    Logger.shared.log("Auto-save failed", level: .error, error: error, category: "Persistence")
                }
            }
        }
    }

    // MARK: - Home Management

    func createHome(name: String, address: String? = nil) throws -> Home {
        Logger.shared.log("Creating new home: \(name)", category: "Persistence")

        let home = Home(name: name, address: address)
        modelContext.insert(home)

        // Create default rooms
        let defaultRooms = [
            Room(name: "Living Room", roomType: .livingRoom),
            Room(name: "Kitchen", roomType: .kitchen),
            Room(name: "Bedroom", roomType: .bedroom),
            Room(name: "Bathroom", roomType: .bathroom)
        ]

        for room in defaultRooms {
            room.home = home
            home.rooms.append(room)
            modelContext.insert(room)
        }

        try modelContext.save()

        appState.currentHome = home
        appState.currentRoom = defaultRooms.first

        Logger.shared.log("Home created with \(defaultRooms.count) rooms", category: "Persistence")
        return home
    }

    // MARK: - User Management

    func createUser(name: String, role: UserRole = .owner) throws -> User {
        Logger.shared.log("Creating user: \(name)", category: "Persistence")

        let user = User(name: name, role: role)
        user.home = appState.currentHome
        modelContext.insert(user)

        // Create preferences
        let preferences = UserPreferences()
        preferences.user = user
        user.preferences = preferences
        modelContext.insert(preferences)

        try modelContext.save()

        appState.currentUser = user

        Logger.shared.log("User created successfully", category: "Persistence")
        return user
    }

    // MARK: - Device Assignment

    func assignDeviceToRoom(_ device: SmartDevice, room: Room) throws {
        Logger.shared.log("Assigning device \(device.name) to room \(room.name)", category: "Persistence")

        device.room = room
        room.devices.append(device)

        if !modelContext.hasChanges(for: device) {
            modelContext.insert(device)
        }

        try modelContext.save()
    }

    // MARK: - Cleanup

    func clearAllData() throws {
        Logger.shared.log("Clearing all data", category: "Persistence")

        try modelContext.delete(model: Home.self)
        try modelContext.delete(model: Room.self)
        try modelContext.delete(model: RoomAnchor.self)
        try modelContext.delete(model: SmartDevice.self)
        try modelContext.delete(model: DeviceState.self)
        try modelContext.delete(model: User.self)
        try modelContext.delete(model: UserPreferences.self)

        try modelContext.save()

        // Clear app state
        appState.devices.removeAll()
        appState.currentHome = nil
        appState.currentRoom = nil
        appState.currentUser = nil

        Logger.shared.log("All data cleared", category: "Persistence")
    }
}

// MARK: - ModelContext Extension

extension ModelContext {
    func hasChanges<T: PersistentModel>(for model: T) -> Bool {
        // Check if model is already tracked
        return registeredModel(for: model.persistentModelID) != nil
    }
}
