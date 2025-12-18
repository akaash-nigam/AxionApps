import Foundation
import simd

/// Represents an environmental setting for a scene
struct SettingData: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String
    let historicalPeriod: HistoricalPeriod

    // Visual design
    let architecturalStyle: ArchitecturalStyle
    let colorPalette: ColorPalette
    let lightingDesign: LightingDesign
    let weatherConditions: WeatherData?

    // Spatial configuration
    let furnitureRequirements: [FurnitureType]
    let minimumRoomSize: SIMD3<Float> // meters (x, y, z)
    let optimalRoomSize: SIMD3<Float>

    // Assets
    let environmentAssets: [AssetReference]
    let propModels: [PropData]
    let soundscapeID: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        historicalPeriod: HistoricalPeriod,
        architecturalStyle: ArchitecturalStyle,
        colorPalette: ColorPalette,
        lightingDesign: LightingDesign,
        weatherConditions: WeatherData? = nil,
        furnitureRequirements: [FurnitureType],
        minimumRoomSize: SIMD3<Float>,
        optimalRoomSize: SIMD3<Float>,
        environmentAssets: [AssetReference],
        propModels: [PropData],
        soundscapeID: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.historicalPeriod = historicalPeriod
        self.architecturalStyle = architecturalStyle
        self.colorPalette = colorPalette
        self.lightingDesign = lightingDesign
        self.weatherConditions = weatherConditions
        self.furnitureRequirements = furnitureRequirements
        self.minimumRoomSize = minimumRoomSize
        self.optimalRoomSize = optimalRoomSize
        self.environmentAssets = environmentAssets
        self.propModels = propModels
        self.soundscapeID = soundscapeID
    }
}

// MARK: - Supporting Types

enum ArchitecturalStyle: String, Codable, Sendable {
    case castle
    case manor
    case cottage
    case palace
    case temple
    case theater
    case outdoor
}

struct ColorPalette: Codable, Sendable {
    let primary: String // Hex color
    let secondary: String
    let accent: String
    let mood: String // Description

    init(primary: String, secondary: String, accent: String, mood: String) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.mood = mood
    }
}

struct LightingDesign: Codable, Sendable {
    let timeOfDay: TimeOfDay
    let intensity: Float // 0.0 - 1.0
    let colorTemperature: Float // Kelvin
    let sources: [LightSource]
}

enum TimeOfDay: String, Codable, Sendable {
    case dawn
    case morning
    case afternoon
    case dusk
    case night
}

struct LightSource: Codable, Identifiable, Sendable {
    let id: UUID
    let type: LightSourceType
    let position: String // Descriptive position
    let intensity: Float
}

enum LightSourceType: String, Codable, Sendable {
    case candle
    case torch
    case lantern
    case sunlight
    case moonlight
    case fireplace
}

struct WeatherData: Codable, Sendable {
    let condition: WeatherCondition
    let intensity: Float // 0.0 - 1.0
    let temperature: Float // Celsius
}

enum WeatherCondition: String, Codable, Sendable {
    case clear
    case rain
    case snow
    case fog
    case storm
}

enum FurnitureType: String, Codable, Sendable {
    case chair
    case table
    case couch
    case bed
    case desk
    case bookshelf
}

struct AssetReference: Codable, Identifiable, Sendable {
    let id: UUID
    let assetID: String
    let assetType: AssetType
    let url: String?
}

enum AssetType: String, Codable, Sendable {
    case model3D
    case texture
    case audio
    case animation
}

struct PropData: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let modelAssetID: String
    let isInteractive: Bool
    let interactionType: PropInteractionType?
    let narrativeSignificance: String?

    // Physics
    let physicsMaterial: PhysicsMaterial
    let mass: Float
    let canBePickedUp: Bool

    init(
        id: UUID = UUID(),
        name: String,
        modelAssetID: String,
        isInteractive: Bool,
        interactionType: PropInteractionType? = nil,
        narrativeSignificance: String? = nil,
        physicsMaterial: PhysicsMaterial,
        mass: Float,
        canBePickedUp: Bool
    ) {
        self.id = id
        self.name = name
        self.modelAssetID = modelAssetID
        self.isInteractive = isInteractive
        self.interactionType = interactionType
        self.narrativeSignificance = narrativeSignificance
        self.physicsMaterial = physicsMaterial
        self.mass = mass
        self.canBePickedUp = canBePickedUp
    }
}

enum PropInteractionType: String, Codable, Sendable {
    case examine
    case manipulate
    case give
    case use
}

struct PhysicsMaterial: Codable, Sendable {
    let staticFriction: Float
    let dynamicFriction: Float
    let restitution: Float // Bounce
    let density: Float

    static let wood = PhysicsMaterial(staticFriction: 0.5, dynamicFriction: 0.3, restitution: 0.2, density: 600)
    static let metal = PhysicsMaterial(staticFriction: 0.4, dynamicFriction: 0.3, restitution: 0.5, density: 7850)
    static let paper = PhysicsMaterial(staticFriction: 0.6, dynamicFriction: 0.4, restitution: 0.1, density: 700)
}
