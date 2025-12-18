import Foundation
import simd

/// Main data structure representing the entire city
struct CityData: Codable, Identifiable {
    // MARK: - Properties

    let id: UUID
    var name: String
    var createdDate: Date
    var lastModified: Date
    var surfaceSize: SIMD2<Float>

    var buildings: [Building]
    var roads: [Road]
    var zones: [Zone]
    var infrastructure: Infrastructure

    var citizens: [Citizen]
    var vehicles: [Vehicle]

    var economy: EconomyState
    var statistics: Statistics

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String = "New City",
        surfaceSize: SIMD2<Float> = SIMD2(1.0, 1.0)
    ) {
        self.id = id
        self.name = name
        self.createdDate = Date()
        self.lastModified = Date()
        self.surfaceSize = surfaceSize

        self.buildings = []
        self.roads = []
        self.zones = []
        self.infrastructure = Infrastructure()

        self.citizens = []
        self.vehicles = []

        self.economy = EconomyState()
        self.statistics = Statistics()
    }

    // MARK: - Computed Properties

    var population: Int {
        citizens.count
    }

    var buildingCount: Int {
        buildings.count
    }

    var roadLength: Float {
        roads.reduce(0) { $0 + $1.length }
    }
}

// MARK: - Building

/// Represents a single building in the city
struct Building: Codable, Identifiable, Equatable {
    let id: UUID
    var type: BuildingType
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var level: Int
    var capacity: Int
    var occupancy: Int
    var constructionProgress: Float
    var isConstructed: Bool

    init(
        id: UUID = UUID(),
        type: BuildingType,
        position: SIMD3<Float>,
        rotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3(0, 1, 0)),
        level: Int = 1,
        capacity: Int = 0,
        occupancy: Int = 0,
        constructionProgress: Float = 0.0
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.level = level
        self.capacity = capacity
        self.occupancy = occupancy
        self.constructionProgress = constructionProgress
        self.isConstructed = constructionProgress >= 1.0
    }

    var bounds: SIMD2<Float> {
        type.footprint
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, type, position, rotation, level, capacity, occupancy, constructionProgress, isConstructed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(BuildingType.self, forKey: .type)
        level = try container.decode(Int.self, forKey: .level)
        capacity = try container.decode(Int.self, forKey: .capacity)
        occupancy = try container.decode(Int.self, forKey: .occupancy)
        constructionProgress = try container.decode(Float.self, forKey: .constructionProgress)
        isConstructed = try container.decode(Bool.self, forKey: .isConstructed)

        // Decode SIMD3<Float> from array
        let posArray = try container.decode([Float].self, forKey: .position)
        position = SIMD3(posArray[0], posArray[1], posArray[2])

        // Decode simd_quatf from array [x, y, z, w]
        let rotArray = try container.decode([Float].self, forKey: .rotation)
        rotation = simd_quatf(ix: rotArray[0], iy: rotArray[1], iz: rotArray[2], r: rotArray[3])
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(level, forKey: .level)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(occupancy, forKey: .occupancy)
        try container.encode(constructionProgress, forKey: .constructionProgress)
        try container.encode(isConstructed, forKey: .isConstructed)

        // Encode SIMD3<Float> as array
        try container.encode([position.x, position.y, position.z], forKey: .position)

        // Encode simd_quatf as array [x, y, z, w]
        try container.encode([rotation.imag.x, rotation.imag.y, rotation.imag.z, rotation.real], forKey: .rotation)
    }
}

// MARK: - Building Type

/// Types of buildings available in the game
enum BuildingType: Codable, Equatable {
    case residential(ResidentialType)
    case commercial(CommercialType)
    case industrial(IndustrialType)
    case infrastructure(InfrastructureType)

    enum ResidentialType: Codable {
        case smallHouse
        case mediumHouse
        case largeHouse
        case apartment
        case tower
    }

    enum CommercialType: Codable {
        case smallShop
        case largeShop
        case office
        case mall
        case hotel
    }

    enum IndustrialType: Codable {
        case smallFactory
        case largeFactory
        case warehouse
        case powerPlant
        case waterTreatment
    }

    enum InfrastructureType: Codable {
        case school
        case hospital
        case policeStation
        case fireStation
        case park
    }

    var footprint: SIMD2<Float> {
        switch self {
        case .residential(let type):
            switch type {
            case .smallHouse: return SIMD2(0.05, 0.05)  // 5cm x 5cm
            case .mediumHouse: return SIMD2(0.07, 0.07)
            case .largeHouse: return SIMD2(0.10, 0.10)
            case .apartment: return SIMD2(0.08, 0.08)
            case .tower: return SIMD2(0.06, 0.06)
            }
        case .commercial(let type):
            switch type {
            case .smallShop: return SIMD2(0.05, 0.05)
            case .largeShop: return SIMD2(0.08, 0.08)
            case .office: return SIMD2(0.10, 0.10)
            case .mall: return SIMD2(0.15, 0.15)
            case .hotel: return SIMD2(0.12, 0.12)
            }
        case .industrial(let type):
            switch type {
            case .smallFactory: return SIMD2(0.10, 0.10)
            case .largeFactory: return SIMD2(0.15, 0.15)
            case .warehouse: return SIMD2(0.12, 0.08)
            case .powerPlant: return SIMD2(0.20, 0.20)
            case .waterTreatment: return SIMD2(0.15, 0.15)
            }
        case .infrastructure(let type):
            switch type {
            case .school: return SIMD2(0.12, 0.12)
            case .hospital: return SIMD2(0.15, 0.15)
            case .policeStation: return SIMD2(0.08, 0.08)
            case .fireStation: return SIMD2(0.08, 0.08)
            case .park: return SIMD2(0.10, 0.10)
            }
        }
    }

    var baseCost: Float {
        switch self {
        case .residential(let type):
            switch type {
            case .smallHouse: return 1000
            case .mediumHouse: return 2000
            case .largeHouse: return 5000
            case .apartment: return 8000
            case .tower: return 20000
            }
        case .commercial(let type):
            switch type {
            case .smallShop: return 1500
            case .largeShop: return 3000
            case .office: return 10000
            case .mall: return 25000
            case .hotel: return 15000
            }
        case .industrial(let type):
            switch type {
            case .smallFactory: return 5000
            case .largeFactory: return 15000
            case .warehouse: return 8000
            case .powerPlant: return 50000
            case .waterTreatment: return 30000
            }
        case .infrastructure(let type):
            switch type {
            case .school: return 10000
            case .hospital: return 20000
            case .policeStation: return 8000
            case .fireStation: return 8000
            case .park: return 2000
            }
        }
    }

    var displayName: String {
        switch self {
        case .residential(let type):
            switch type {
            case .smallHouse: return "Small House"
            case .mediumHouse: return "Medium House"
            case .largeHouse: return "Large House"
            case .apartment: return "Apartment Building"
            case .tower: return "Residential Tower"
            }
        case .commercial(let type):
            switch type {
            case .smallShop: return "Small Shop"
            case .largeShop: return "Large Shop"
            case .office: return "Office Building"
            case .mall: return "Shopping Mall"
            case .hotel: return "Hotel"
            }
        case .industrial(let type):
            switch type {
            case .smallFactory: return "Small Factory"
            case .largeFactory: return "Large Factory"
            case .warehouse: return "Warehouse"
            case .powerPlant: return "Power Plant"
            case .waterTreatment: return "Water Treatment Plant"
            }
        case .infrastructure(let type):
            switch type {
            case .school: return "School"
            case .hospital: return "Hospital"
            case .policeStation: return "Police Station"
            case .fireStation: return "Fire Station"
            case .park: return "Park"
            }
        }
    }

    var isResidential: Bool {
        if case .residential = self { return true }
        return false
    }

    var isCommercial: Bool {
        if case .commercial = self { return true }
        return false
    }

    var isIndustrial: Bool {
        if case .industrial = self { return true }
        return false
    }

    var isInfrastructure: Bool {
        if case .infrastructure = self { return true }
        return false
    }
}

// MARK: - Road

/// Represents a road segment in the city
struct Road: Codable, Identifiable, Equatable {
    let id: UUID
    var type: RoadType
    var path: [SIMD3<Float>]
    var lanes: Int
    var trafficCapacity: Int
    var connections: [UUID]  // Connected road IDs

    init(
        id: UUID = UUID(),
        type: RoadType = .street,
        path: [SIMD3<Float>],
        lanes: Int = 2,
        trafficCapacity: Int = 100
    ) {
        self.id = id
        self.type = type
        self.path = path
        self.lanes = lanes
        self.trafficCapacity = trafficCapacity
        self.connections = []
    }

    var length: Float {
        guard path.count > 1 else { return 0 }
        var totalLength: Float = 0
        for i in 0..<(path.count - 1) {
            totalLength += simd_distance(path[i], path[i + 1])
        }
        return totalLength
    }
}

enum RoadType: Codable {
    case dirt
    case street
    case avenue
    case highway

    var width: Float {
        switch self {
        case .dirt: return 0.02      // 2cm
        case .street: return 0.03    // 3cm
        case .avenue: return 0.05    // 5cm
        case .highway: return 0.08   // 8cm
        }
    }
}

// MARK: - Zone

/// Represents a zoned area for auto-building
struct Zone: Codable, Identifiable, Equatable {
    let id: UUID
    var zoneType: ZoneType
    var area: [SIMD2<Float>]  // Polygon vertices
    var density: Float
    var maxBuildings: Int

    init(
        id: UUID = UUID(),
        zoneType: ZoneType,
        area: [SIMD2<Float>],
        density: Float = 0.5,
        maxBuildings: Int = 10
    ) {
        self.id = id
        self.zoneType = zoneType
        self.area = area
        self.density = density
        self.maxBuildings = maxBuildings
    }
}

enum ZoneType: Codable {
    case residential
    case commercial
    case industrial
    case mixed
    case park

    var displayName: String {
        switch self {
        case .residential: return "Residential"
        case .commercial: return "Commercial"
        case .industrial: return "Industrial"
        case .mixed: return "Mixed Use"
        case .park: return "Park"
        }
    }
}

// MARK: - Infrastructure

/// City infrastructure systems
struct Infrastructure: Codable {
    var powerCapacity: Float = 0
    var powerUsage: Float = 0
    var waterCapacity: Float = 0
    var waterUsage: Float = 0
    var powerCost: Float = 0
    var waterCost: Float = 0

    var hasPower: Bool {
        powerUsage <= powerCapacity
    }

    var hasWater: Bool {
        waterUsage <= waterCapacity
    }
}

// MARK: - Citizen

/// Represents an individual citizen
struct Citizen: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var age: Int
    var occupation: Occupation
    var home: UUID?       // Building ID
    var workplace: UUID?  // Building ID
    var happiness: Float
    var income: Float
    var currentActivity: Activity
    var currentPosition: SIMD3<Float>
    var targetPosition: SIMD3<Float>

    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        occupation: Occupation = .unemployed,
        happiness: Float = 0.75,
        income: Float = 0,
        currentActivity: Activity = .sleeping,
        currentPosition: SIMD3<Float> = SIMD3(0, 0, 0)
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.occupation = occupation
        self.home = nil
        self.workplace = nil
        self.happiness = happiness
        self.income = income
        self.currentActivity = currentActivity
        self.currentPosition = currentPosition
        self.targetPosition = currentPosition
    }
}

enum Occupation: Codable {
    case unemployed
    case retail
    case office
    case industrial
    case service
    case education
    case healthcare
}

enum Activity: Codable {
    case sleeping
    case commuting
    case working
    case shopping
    case leisure
    case returning
}

// MARK: - Vehicle

/// Represents a vehicle in the city
struct Vehicle: Codable, Identifiable, Equatable {
    let id: UUID
    var vehicleType: VehicleType
    var road: UUID?              // Current road ID
    var pathProgress: Float      // 0.0 to 1.0 along current road
    var speed: Float
    var currentPosition: SIMD3<Float>

    init(
        id: UUID = UUID(),
        vehicleType: VehicleType,
        speed: Float = 0.02
    ) {
        self.id = id
        self.vehicleType = vehicleType
        self.road = nil
        self.pathProgress = 0
        self.speed = speed
        self.currentPosition = SIMD3(0, 0, 0)
    }
}

enum VehicleType: Codable {
    case car
    case truck
    case bus
    case emergency
}

// MARK: - Economy State

/// Economic simulation state
struct EconomyState: Codable {
    var treasury: Float = 50000
    var taxRate: Float = 0.05  // 5%
    var income: Float = 0
    var expenses: Float = 0
    var unemployment: Float = 0
    var gdp: Float = 0

    var budget: Float {
        treasury
    }

    var netIncome: Float {
        income - expenses
    }
}

// MARK: - Statistics

/// City statistics
struct Statistics: Codable {
    var population: Int = 0
    var populationGrowth: Float = 0
    var averageHappiness: Float = 0.75
    var trafficDensity: Float = 0
    var powerUsage: Float = 0
    var waterUsage: Float = 0
    var pollution: Float = 0
    var crimeRate: Float = 0
}
