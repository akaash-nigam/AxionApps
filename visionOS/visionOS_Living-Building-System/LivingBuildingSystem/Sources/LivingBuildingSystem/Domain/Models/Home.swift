import Foundation
import SwiftData

@Model
final class Home {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Room.home)
    var rooms: [Room]

    @Relationship(deleteRule: .cascade, inverse: \User.home)
    var users: [User]

    @Relationship(deleteRule: .cascade)
    var energyConfiguration: EnergyConfiguration?

    var timezone: TimeZone

    init(name: String, address: String? = nil) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.createdAt = Date()
        self.updatedAt = Date()
        self.timezone = .current
        self.rooms = []
        self.users = []
    }
}

// MARK: - Preview Support
extension Home {
    static var preview: Home {
        let home = Home(name: "My Home", address: "123 Main St")

        let kitchen = Room(name: "Kitchen", roomType: .kitchen)
        let livingRoom = Room(name: "Living Room", roomType: .livingRoom)
        let bedroom = Room(name: "Bedroom", roomType: .bedroom)

        home.rooms = [kitchen, livingRoom, bedroom]

        return home
    }
}
