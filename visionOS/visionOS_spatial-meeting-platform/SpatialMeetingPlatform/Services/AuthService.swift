//
//  AuthService.swift
//  SpatialMeetingPlatform
//
//  Authentication and user management service
//

import Foundation

class AuthService: AuthServiceProtocol {

    // MARK: - Properties

    private let apiClient: APIClient
    private let dataStore: DataStoreProtocol
    private let keychainKey = "com.spatial.meeting.user"

    // MARK: - Initialization

    init(apiClient: APIClient, dataStore: DataStoreProtocol) {
        self.apiClient = apiClient
        self.dataStore = dataStore
    }

    // MARK: - AuthServiceProtocol

    func authenticate(email: String, password: String) async throws -> User {
        // Call API
        let response = try await apiClient.login(email: email, password: password)

        // Convert DTO to User
        let user = User(
            id: response.user.id,
            email: response.user.email,
            displayName: response.user.displayName
        )

        // Cache user
        try cacheUser(user, token: response.token)

        return user
    }

    func signOut() async throws {
        // Clear token from API client
        apiClient.clearAuthToken()

        // Clear cached user
        clearCachedUser()

        print("User signed out")
    }

    func loadCachedUser() async throws -> User? {
        // In real implementation: Load from secure storage (Keychain)
        // For now, return nil
        return nil
    }

    // MARK: - Private Methods

    private func cacheUser(_ user: User, token: String) throws {
        // In real implementation: Store in Keychain
        apiClient.setAuthToken(token)
        print("User cached: \(user.email)")
    }

    private func clearCachedUser() {
        // In real implementation: Remove from Keychain
        print("User cache cleared")
    }
}
