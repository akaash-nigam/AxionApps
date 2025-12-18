import Foundation
import SwiftData
import simd

@Model
class MeetingEnvironment {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: EnvironmentCategory

    // Visual properties
    var skyboxAsset: String?
    var lightingConfiguration: LightingConfiguration
    var spatialAudioReverb: AudioReverbPreset

    // Layout
    var participantPositions: [ParticipantPosition]
    var contentZones: [ContentZone]

    // Customization
    var brandingAssets: [String]?
    var customMaterials: [String]?

    var isDefault: Bool
    var isPublic: Bool
    var creatorId: UUID?

    init(
        name: String,
        category: EnvironmentCategory,
        lightingConfiguration: LightingConfiguration = .default,
        spatialAudioReverb: AudioReverbPreset = .room
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.lightingConfiguration = lightingConfiguration
        self.spatialAudioReverb = spatialAudioReverb
        self.participantPositions = []
        self.contentZones = []
        self.isDefault = false
        self.isPublic = true
    }
}

enum EnvironmentCategory: String, Codable {
    case boardroom
    case innovationLab
    case auditorium
    case cafe
    case outdoor
    case custom
}

struct LightingConfiguration: Codable {
    var ambientIntensity: Float
    var directionalLights: [DirectionalLight]
    var environmentProbe: String?

    static var `default`: LightingConfiguration {
        LightingConfiguration(
            ambientIntensity: 1.0,
            directionalLights: [
                DirectionalLight(
                    direction: SIMD3(0.3, -0.7, 0.3),
                    intensity: 1.0,
                    color: [1.0, 1.0, 1.0]
                )
            ],
            environmentProbe: nil
        )
    }
}

struct DirectionalLight: Codable {
    var direction: SIMD3<Float>
    var intensity: Float
    var color: SIMD3<Float>
}

enum AudioReverbPreset: String, Codable {
    case room
    case hall
    case auditorium
    case outdoor
    case none
}

struct ParticipantPosition: Codable, Identifiable {
    var id: UUID = UUID()
    var index: Int
    var position: SpatialPosition
    var label: String?
}

struct ContentZone: Codable, Identifiable {
    var id: UUID = UUID()
    var type: ZoneType
    var bounds: AxisAlignedBoundingBox
    var label: String
}

enum ZoneType: String, Codable {
    case presentation
    case whiteboard
    case shared
    case personal
}

struct AxisAlignedBoundingBox: Codable {
    var min: SIMD3<Float>
    var max: SIMD3<Float>

    func contains(_ point: SIMD3<Float>) -> Bool {
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }
}
