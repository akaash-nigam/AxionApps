//
//  CoreDataUserProfileRepository.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import CoreData
import Security

/// Core Data implementation of UserProfileRepository
class CoreDataUserProfileRepository: UserProfileRepository {
    static let shared = CoreDataUserProfileRepository()

    private let persistenceController: PersistenceController
    private let keychainService = KeychainService.shared

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Profile Operations
    func fetch() async throws -> UserProfile {
        let context = persistenceController.container.viewContext

        return try await context.perform {
            let request = UserProfileEntity.fetchRequest()
            request.fetchLimit = 1

            // Return first profile or create default
            if let entity = try context.fetch(request).first {
                return entity.toDomainModel()
            } else {
                // Create default profile
                let defaultProfile = UserProfile()
                let entity = UserProfileEntity(from: defaultProfile, context: context)
                try context.save()
                return entity.toDomainModel()
            }
        }
    }

    func update(_ profile: UserProfile) async throws {
        let context = persistenceController.newBackgroundContext()

        try await context.perform {
            let request = UserProfileEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", profile.id as CVarArg)
            request.fetchLimit = 1

            if let entity = try context.fetch(request).first {
                // Update existing
                entity.updateFrom(profile)
            } else {
                // Create new
                _ = UserProfileEntity(from: profile, context: context)
            }

            try context.save()
        }
    }

    func delete() async throws {
        let context = persistenceController.newBackgroundContext()

        try await context.perform {
            let request = UserProfileEntity.fetchRequest()
            let entities = try context.fetch(request)

            for entity in entities {
                context.delete(entity)
            }

            try context.save()
        }
    }

    // MARK: - Body Measurements (Keychain)
    func getBodyMeasurements() async throws -> BodyMeasurements? {
        return try keychainService.retrieveBodyMeasurements()
    }

    func saveBodyMeasurements(_ measurements: BodyMeasurements) async throws {
        try keychainService.storeBodyMeasurements(measurements)
    }

    func deleteBodyMeasurements() async throws {
        try keychainService.deleteBodyMeasurements()
    }
}

// MARK: - Keychain Service
class KeychainService {
    static let shared = KeychainService()

    private let service = "com.wardrobeconsultant.secure"

    // MARK: - Store Body Measurements
    func storeBodyMeasurements(_ measurements: BodyMeasurements) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(measurements)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "body_measurements",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw UserProfileRepositoryError.keychainError(status)
        }
    }

    // MARK: - Retrieve Body Measurements
    func retrieveBodyMeasurements() throws -> BodyMeasurements? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "body_measurements",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            if status == errSecItemNotFound {
                return nil
            }
            throw UserProfileRepositoryError.keychainError(status)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(BodyMeasurements.self, from: data)
    }

    // MARK: - Delete Body Measurements
    func deleteBodyMeasurements() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "body_measurements"
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw UserProfileRepositoryError.keychainError(status)
        }
    }
}

// NOTE: Full implementation will be completed in Epic 2: Data Layer & Persistence
