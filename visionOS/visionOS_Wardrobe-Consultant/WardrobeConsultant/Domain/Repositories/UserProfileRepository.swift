//
//  UserProfileRepository.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation

/// Protocol for user profile data access
protocol UserProfileRepository {
    // MARK: - Profile Operations
    func fetch() async throws -> UserProfile
    func update(_ profile: UserProfile) async throws
    func delete() async throws

    // MARK: - Body Measurements (Keychain)
    func getBodyMeasurements() async throws -> BodyMeasurements?
    func saveBodyMeasurements(_ measurements: BodyMeasurements) async throws
    func deleteBodyMeasurements() async throws
}

/// Errors that can occur during user profile repository operations
enum UserProfileRepositoryError: Error {
    case profileNotFound
    case invalidProfile
    case saveFailed(Error)
    case deleteFailed(Error)
    case keychainError(OSStatus)

    var localizedDescription: String {
        switch self {
        case .profileNotFound:
            return "User profile not found"
        case .invalidProfile:
            return "Invalid user profile"
        case .saveFailed(let error):
            return "Failed to save user profile: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete user profile: \(error.localizedDescription)"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        }
    }
}
