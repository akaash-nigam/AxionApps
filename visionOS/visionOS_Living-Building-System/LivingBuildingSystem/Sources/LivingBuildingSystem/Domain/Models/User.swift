import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var role: UserRole
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Home.users)
    var home: Home?

    @Relationship(deleteRule: .cascade, inverse: \UserPreferences.user)
    var preferences: UserPreferences?

    init(name: String, role: UserRole = .member) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.createdAt = Date()
    }
}

enum UserRole: String, Codable {
    case owner
    case admin
    case member
    case guest

    var displayName: String {
        switch self {
        case .owner: "Owner"
        case .admin: "Admin"
        case .member: "Member"
        case .guest: "Guest"
        }
    }
}

// MARK: - Preview Support
extension User {
    static var preview: User {
        User(name: "John Doe", role: .owner)
    }
}
