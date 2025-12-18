import Foundation

/// Weapon data and definitions
actor WeaponDataManager {
    static let shared = WeaponDataManager()

    private var weaponDefinitions: [UUID: WeaponDefinition] = [:]

    func loadWeaponDefinitions() async {
        // TODO: Load weapon definitions from data files
        print("Weapon definitions loaded")
    }

    func getWeapon(id: UUID) -> WeaponDefinition? {
        return weaponDefinitions[id]
    }
}

struct WeaponDefinition: Codable {
    var id: UUID
    var name: String
    var weaponClass: WeaponClass
    var damage: Float
    var fireRate: Int
    var magazineSize: Int
    var recoilPattern: [Float]

    enum WeaponClass: String, Codable {
        case rifle
        case smg
        case shotgun
        case sniper
        case pistol
    }
}
