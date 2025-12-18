import Foundation

struct Weapon: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: WeaponType
    var stats: WeaponStats
    var attachments: [Attachment] = []

    // Cosmetics
    var skinId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        type: WeaponType,
        stats: WeaponStats
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.stats = stats
    }
}

// MARK: - Weapon Type

enum WeaponType: String, Codable, CaseIterable {
    case assaultRifle
    case smg
    case sniper
    case shotgun
    case pistol
    case lmg

    var displayName: String {
        switch self {
        case .assaultRifle: return "Assault Rifle"
        case .smg: return "SMG"
        case .sniper: return "Sniper Rifle"
        case .shotgun: return "Shotgun"
        case .pistol: return "Pistol"
        case .lmg: return "LMG"
        }
    }

    var category: WeaponCategory {
        switch self {
        case .assaultRifle, .smg, .lmg:
            return .automatic
        case .sniper:
            return .precision
        case .shotgun:
            return .closeRange
        case .pistol:
            return .secondary
        }
    }
}

enum WeaponCategory {
    case automatic
    case precision
    case closeRange
    case secondary
}

// MARK: - Weapon Stats

struct WeaponStats: Codable, Hashable {
    var damage: Int
    var fireRate: Double  // Rounds per minute
    var recoil: RecoilPattern
    var accuracy: Double  // 0.0 - 1.0
    var range: Double  // Effective range in meters
    var magazineSize: Int
    var reserveAmmo: Int
    var reloadTime: TimeInterval
    var muzzleVelocity: Float  // m/s
    var penetration: Float  // 0.0 - 1.0

    // Derived values
    var damagePerSecond: Double {
        Double(damage) * (fireRate / 60.0)
    }

    var timeToKill: TimeInterval {
        let shotsToKill = ceil(100.0 / Double(damage))
        let fireInterval = 60.0 / fireRate
        return TimeInterval(shotsToKill - 1) * fireInterval
    }
}

// MARK: - Recoil Pattern

struct RecoilPattern: Codable, Hashable {
    var verticalKick: Float
    var horizontalSpread: Float
    var resetTime: TimeInterval
    var pattern: [SIMD2<Float>]  // Spray pattern coordinates

    static let ak47Pattern = RecoilPattern(
        verticalKick: 0.15,
        horizontalSpread: 0.08,
        resetTime: 0.4,
        pattern: [
            SIMD2<Float>(0, 0.15),
            SIMD2<Float>(0.02, 0.28),
            SIMD2<Float>(-0.03, 0.38),
            SIMD2<Float>(0.05, 0.45),
            SIMD2<Float>(-0.04, 0.50),
            SIMD2<Float>(0.08, 0.52),
            SIMD2<Float>(-0.10, 0.53),
            SIMD2<Float>(0.12, 0.52),
            SIMD2<Float>(-0.08, 0.50),
            SIMD2<Float>(0.05, 0.48)
        ]
    )

    static let m4Pattern = RecoilPattern(
        verticalKick: 0.12,
        horizontalSpread: 0.05,
        resetTime: 0.35,
        pattern: [
            SIMD2<Float>(0, 0.12),
            SIMD2<Float>(0.01, 0.22),
            SIMD2<Float>(-0.02, 0.30),
            SIMD2<Float>(0.03, 0.36),
            SIMD2<Float>(-0.02, 0.40),
            SIMD2<Float>(0.04, 0.42),
            SIMD2<Float>(-0.05, 0.43),
            SIMD2<Float>(0.06, 0.42),
            SIMD2<Float>(-0.04, 0.40),
            SIMD2<Float>(0.02, 0.38)
        ]
    )
}

// MARK: - Attachment

struct Attachment: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: AttachmentType
    var modifiers: WeaponModifiers

    init(
        id: UUID = UUID(),
        name: String,
        type: AttachmentType,
        modifiers: WeaponModifiers
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.modifiers = modifiers
    }
}

enum AttachmentType: String, Codable {
    case optic
    case barrel
    case grip
    case magazine
    case stock
    case muzzle

    var displayName: String {
        rawValue.capitalized
    }

    var slot: Int {
        switch self {
        case .optic: return 0
        case .barrel: return 1
        case .grip: return 2
        case .magazine: return 3
        case .stock: return 4
        case .muzzle: return 5
        }
    }
}

struct WeaponModifiers: Codable, Hashable {
    var damageMultiplier: Float = 1.0
    var recoilMultiplier: Float = 1.0
    var accuracyMultiplier: Float = 1.0
    var rangeMultiplier: Float = 1.0
    var magazineSizeBonus: Int = 0
    var reloadTimeMultiplier: Float = 1.0
}

// MARK: - Predefined Weapons

extension Weapon {
    static let ak47 = Weapon(
        name: "AK-47",
        type: .assaultRifle,
        stats: WeaponStats(
            damage: 36,
            fireRate: 600,
            recoil: .ak47Pattern,
            accuracy: 0.7,
            range: 50,
            magazineSize: 30,
            reserveAmmo: 90,
            reloadTime: 2.5,
            muzzleVelocity: 715,
            penetration: 0.75
        )
    )

    static let m4a1 = Weapon(
        name: "M4A1",
        type: .assaultRifle,
        stats: WeaponStats(
            damage: 33,
            fireRate: 666,
            recoil: .m4Pattern,
            accuracy: 0.75,
            range: 48,
            magazineSize: 30,
            reserveAmmo: 90,
            reloadTime: 2.2,
            muzzleVelocity: 900,
            penetration: 0.7
        )
    )

    static let awp = Weapon(
        name: "AWP",
        type: .sniper,
        stats: WeaponStats(
            damage: 115,
            fireRate: 41,
            recoil: RecoilPattern(
                verticalKick: 0.5,
                horizontalSpread: 0.02,
                resetTime: 1.5,
                pattern: [SIMD2<Float>(0, 0.5)]
            ),
            accuracy: 0.95,
            range: 200,
            magazineSize: 10,
            reserveAmmo: 30,
            reloadTime: 3.5,
            muzzleVelocity: 850,
            penetration: 0.95
        )
    )

    static let glock = Weapon(
        name: "Glock-18",
        type: .pistol,
        stats: WeaponStats(
            damage: 28,
            fireRate: 400,
            recoil: RecoilPattern(
                verticalKick: 0.08,
                horizontalSpread: 0.04,
                resetTime: 0.25,
                pattern: [
                    SIMD2<Float>(0, 0.08),
                    SIMD2<Float>(0.02, 0.14),
                    SIMD2<Float>(-0.02, 0.18)
                ]
            ),
            accuracy: 0.65,
            range: 25,
            magazineSize: 20,
            reserveAmmo: 100,
            reloadTime: 1.8,
            muzzleVelocity: 375,
            penetration: 0.35
        )
    )

    static var allWeapons: [Weapon] {
        [.ak47, .m4a1, .awp, .glock]
    }
}

// MARK: - Equipment

struct Equipment: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: EquipmentType
    var quantity: Int

    init(
        id: UUID = UUID(),
        name: String,
        type: EquipmentType,
        quantity: Int = 1
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.quantity = quantity
    }
}

enum EquipmentType: String, Codable {
    case flashbang
    case smokeGrenade
    case fragGrenade
    case molotov
    case breachCharge
    case defuseKit
    case armor
    case helmet

    var maxQuantity: Int {
        switch self {
        case .flashbang: return 3
        case .smokeGrenade: return 2
        case .fragGrenade: return 1
        case .molotov: return 1
        case .breachCharge: return 2
        case .defuseKit: return 1
        case .armor: return 1
        case .helmet: return 1
        }
    }

    var price: Int {
        switch self {
        case .flashbang: return 200
        case .smokeGrenade: return 300
        case .fragGrenade: return 300
        case .molotov: return 400
        case .breachCharge: return 500
        case .defuseKit: return 400
        case .armor: return 650
        case .helmet: return 350
        }
    }
}
