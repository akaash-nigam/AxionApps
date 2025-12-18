//
//  User.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - User

/// Represents an authenticated user in the system
public struct User: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    var email: String
    var name: String
    var role: Role?
    var department: Department.ID?
    var avatarURL: URL?
    var preferences: UserPreferences?

    // MARK: - Role

    public enum Role: String, Codable, Sendable {
        case executive
        case manager
        case employee
        case analyst
        case admin

        var displayName: String {
            switch self {
            case .executive: return "Executive"
            case .manager: return "Manager"
            case .employee: return "Employee"
            case .analyst: return "Analyst"
            case .admin: return "Administrator"
            }
        }

        var canViewAllDepartments: Bool {
            switch self {
            case .executive, .admin: return true
            default: return false
            }
        }

        var canEditKPIs: Bool {
            switch self {
            case .executive, .manager, .admin: return true
            default: return false
            }
        }
    }
}

// MARK: - User Preferences

public struct UserPreferences: Codable, Hashable, Sendable {
    var prefersDarkMode: Bool = true
    var defaultPresentationMode: String = "dashboard"
    var notificationsEnabled: Bool = true
    var spatialLayoutPreference: String = "radial"
}

// MARK: - Mock Extension

extension User {
    static func mock(
        name: String = "Jane Doe",
        email: String = "jane.doe@acme.com",
        role: Role = .manager
    ) -> User {
        User(
            id: UUID(),
            email: email,
            name: name,
            role: role,
            department: nil,
            avatarURL: nil,
            preferences: UserPreferences()
        )
    }
}
