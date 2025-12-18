import Foundation
import SwiftData

@Model
final class UserPreferences {
    @Attribute(.unique) var id: UUID

    @Relationship(deleteRule: .nullify, inverse: \User.preferences)
    var user: User?

    var temperatureUnit: TemperatureUnit
    var updatedAt: Date

    init() {
        self.id = UUID()
        self.temperatureUnit = .fahrenheit
        self.updatedAt = Date()
    }
}

enum TemperatureUnit: String, Codable {
    case fahrenheit
    case celsius

    var symbol: String {
        switch self {
        case .fahrenheit: "°F"
        case .celsius: "°C"
        }
    }
}
