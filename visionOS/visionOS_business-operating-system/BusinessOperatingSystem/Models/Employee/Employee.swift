//
//  Employee.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Employee

/// Represents an employee within the organization
public struct Employee: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    var name: String
    var email: String
    var title: String
    var department: Department.ID
    var manager: Employee.ID?
    var directReports: [Employee.ID]
    var status: EmployeeStatus
    var avatarURL: URL?
    var availability: AvailabilityStatus
    var hireDate: Date?
    var skills: [String]?

    // MARK: - Computed Properties

    var isManager: Bool {
        !directReports.isEmpty
    }

    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.prefix(1) ?? ""
        let lastInitial = components.count > 1 ? components.last?.prefix(1) ?? "" : ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }

    var isActive: Bool {
        status == .active
    }
}

// MARK: - Employee Status

extension Employee {
    public enum EmployeeStatus: String, Codable, Sendable {
        case active
        case onLeave
        case terminated

        var displayName: String {
            switch self {
            case .active: return "Active"
            case .onLeave: return "On Leave"
            case .terminated: return "Terminated"
            }
        }

        var color: String {
            switch self {
            case .active: return "#34C759"
            case .onLeave: return "#FF9500"
            case .terminated: return "#8E8E93"
            }
        }
    }

    public enum AvailabilityStatus: String, Codable, Sendable {
        case available
        case busy
        case offline
        case inMeeting

        var displayName: String {
            switch self {
            case .available: return "Available"
            case .busy: return "Busy"
            case .offline: return "Offline"
            case .inMeeting: return "In Meeting"
            }
        }

        var color: String {
            switch self {
            case .available: return "#34C759"
            case .busy: return "#FFCC00"
            case .offline: return "#8E8E93"
            case .inMeeting: return "#007AFF"
            }
        }

        var iconName: String {
            switch self {
            case .available: return "circle.fill"
            case .busy: return "minus.circle.fill"
            case .offline: return "circle"
            case .inMeeting: return "video.fill"
            }
        }
    }
}

// MARK: - Mock Extension

extension Employee {
    static func mock(
        name: String = "Jane Doe",
        title: String = "Senior Engineer",
        status: EmployeeStatus = .active
    ) -> Employee {
        Employee(
            id: UUID(),
            name: name,
            email: "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@acme.com",
            title: title,
            department: UUID(),
            manager: nil,
            directReports: [],
            status: status,
            avatarURL: nil,
            availability: .available,
            hireDate: Date().addingTimeInterval(-365 * 24 * 60 * 60),  // 1 year ago
            skills: ["Swift", "SwiftUI", "RealityKit"]
        )
    }
}
