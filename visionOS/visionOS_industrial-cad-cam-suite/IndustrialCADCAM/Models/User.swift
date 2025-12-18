import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var username: String
    var displayName: String
    var email: String
    var role: String // "designer", "engineer", "manager", "viewer"

    var avatarData: Data?

    var preferences: UserPreferencesData

    var createdDate: Date
    var lastLoginDate: Date

    init(
        username: String,
        displayName: String,
        email: String,
        role: String = "designer"
    ) {
        self.id = UUID()
        self.username = username
        self.displayName = displayName
        self.email = email
        self.role = role
        self.preferences = UserPreferencesData()
        self.createdDate = Date()
        self.lastLoginDate = Date()
    }

    // MARK: - Default User
    static var defaultUser: User {
        User(
            username: "demo_user",
            displayName: "Demo User",
            email: "demo@company.com",
            role: "designer"
        )
    }
}

// MARK: - Supporting Types
struct UserPreferencesData: Codable {
    var units: String = "metric"
    var gridSize: Double = 10.0
    var snapToGrid: Bool = true
    var showGrid: Bool = true
    var theme: String = "dark"
    var language: String = "en"
}
