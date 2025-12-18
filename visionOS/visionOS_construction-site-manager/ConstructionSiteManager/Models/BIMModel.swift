//
//  BIMModel.swift
//  Construction Site Manager
//
//  BIM model and element definitions
//

import Foundation
import SwiftData
import simd

// MARK: - BIM Model

/// Represents a Building Information Model
@Model
final class BIMModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var version: String
    var format: BIMFormat
    var fileURL: String  // URL as string for SwiftData compatibility
    var localCacheURL: String?
    var sizeInBytes: Int64
    var disciplines: [Discipline]
    var isCached: Bool
    var lastSyncDate: Date?
    var createdDate: Date
    var lastModifiedDate: Date

    @Relationship(deleteRule: .cascade) var elements: [BIMElement]
    @Relationship(inverse: \Project.bimModels) var project: Project?

    init(
        id: UUID = UUID(),
        name: String,
        version: String = "1.0",
        format: BIMFormat,
        fileURL: String,
        localCacheURL: String? = nil,
        sizeInBytes: Int64 = 0,
        disciplines: [Discipline] = [],
        isCached: Bool = false
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.format = format
        self.fileURL = fileURL
        self.localCacheURL = localCacheURL
        self.sizeInBytes = sizeInBytes
        self.disciplines = disciplines
        self.isCached = isCached
        self.lastSyncDate = nil
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        self.elements = []
    }

    var elementCount: Int {
        elements.count
    }

    var completionPercentage: Double {
        guard !elements.isEmpty else { return 0.0 }
        let completed = elements.filter { $0.status == .completed || $0.status == .approved }.count
        return Double(completed) / Double(elements.count)
    }
}

// MARK: - BIM Element

/// Represents a single element in the BIM model (wall, beam, etc.)
@Model
final class BIMElement {
    @Attribute(.unique) var ifcGuid: String  // IFC Global Unique ID
    var ifcType: String  // e.g., "IfcWall", "IfcBeam"
    var name: String
    var discipline: Discipline
    var floor: Int?
    var zone: String?
    var status: ElementStatus
    var percentComplete: Double  // 0.0 to 1.0
    var assignedTo: String?
    var lastUpdated: Date
    var completionDate: Date?

    // Geometry (simplified - stored as JSON string)
    var geometryJSON: String?

    // Placement
    var positionX: Float
    var positionY: Float
    var positionZ: Float
    var rotationW: Float
    var rotationX: Float
    var rotationY: Float
    var rotationZ: Float
    var scaleX: Float
    var scaleY: Float
    var scaleZ: Float

    // Properties (stored as JSON string for flexibility)
    var propertiesJSON: String?

    @Relationship(inverse: \BIMModel.elements) var model: BIMModel?
    @Relationship(deleteRule: .cascade) var progressRecords: [ElementProgressRecord]

    init(
        ifcGuid: String,
        ifcType: String,
        name: String,
        discipline: Discipline,
        floor: Int? = nil,
        zone: String? = nil,
        status: ElementStatus = .notStarted,
        percentComplete: Double = 0.0,
        assignedTo: String? = nil,
        position: SIMD3<Float> = .zero,
        rotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0]),
        scale: SIMD3<Float> = SIMD3<Float>(repeating: 1.0)
    ) {
        self.ifcGuid = ifcGuid
        self.ifcType = ifcType
        self.name = name
        self.discipline = discipline
        self.floor = floor
        self.zone = zone
        self.status = status
        self.percentComplete = percentComplete
        self.assignedTo = assignedTo
        self.lastUpdated = Date()

        self.positionX = position.x
        self.positionY = position.y
        self.positionZ = position.z

        self.rotationW = rotation.vector.w
        self.rotationX = rotation.vector.x
        self.rotationY = rotation.vector.y
        self.rotationZ = rotation.vector.z

        self.scaleX = scale.x
        self.scaleY = scale.y
        self.scaleZ = scale.z

        self.progressRecords = []
    }

    var position: SIMD3<Float> {
        get { SIMD3<Float>(positionX, positionY, positionZ) }
        set {
            positionX = newValue.x
            positionY = newValue.y
            positionZ = newValue.z
        }
    }

    var rotation: simd_quatf {
        get { simd_quatf(ix: rotationX, iy: rotationY, iz: rotationZ, r: rotationW) }
        set {
            rotationW = newValue.vector.w
            rotationX = newValue.vector.x
            rotationY = newValue.vector.y
            rotationZ = newValue.vector.z
        }
    }

    var scale: SIMD3<Float> {
        get { SIMD3<Float>(scaleX, scaleY, scaleZ) }
        set {
            scaleX = newValue.x
            scaleY = newValue.y
            scaleZ = newValue.z
        }
    }

    var transform: Transform3D {
        Transform3D(position: position, rotation: rotation, scale: scale)
    }
}

// MARK: - Element Progress Record

/// Tracks progress updates for a BIM element
@Model
final class ElementProgressRecord {
    @Attribute(.unique) var id: UUID
    var status: ElementStatus
    var percentComplete: Double
    var timestamp: Date
    var updatedBy: String
    var notes: String?
    var photoURLs: [String]

    @Relationship(inverse: \BIMElement.progressRecords) var element: BIMElement?

    init(
        id: UUID = UUID(),
        status: ElementStatus,
        percentComplete: Double,
        timestamp: Date = Date(),
        updatedBy: String,
        notes: String? = nil,
        photoURLs: [String] = []
    ) {
        self.id = id
        self.status = status
        self.percentComplete = percentComplete
        self.timestamp = timestamp
        self.updatedBy = updatedBy
        self.notes = notes
        self.photoURLs = photoURLs
    }
}

// MARK: - Helper Structures

/// Reference to a photo in storage
struct PhotoReference: Codable, Identifiable, Equatable {
    var id: UUID
    var fileURL: String
    var thumbnailURL: String?
    var captureDate: Date
    var locationX: Float?
    var locationY: Float?
    var locationZ: Float?
    var directionX: Float?
    var directionY: Float?
    var directionZ: Float?
    var metadata: PhotoMetadata?

    init(
        id: UUID = UUID(),
        fileURL: String,
        thumbnailURL: String? = nil,
        captureDate: Date = Date(),
        location: SIMD3<Float>? = nil,
        direction: SIMD3<Float>? = nil,
        metadata: PhotoMetadata? = nil
    ) {
        self.id = id
        self.fileURL = fileURL
        self.thumbnailURL = thumbnailURL
        self.captureDate = captureDate
        self.metadata = metadata

        if let loc = location {
            self.locationX = loc.x
            self.locationY = loc.y
            self.locationZ = loc.z
        }

        if let dir = direction {
            self.directionX = dir.x
            self.directionY = dir.y
            self.directionZ = dir.z
        }
    }

    var location: SIMD3<Float>? {
        guard let x = locationX, let y = locationY, let z = locationZ else { return nil }
        return SIMD3<Float>(x, y, z)
    }

    var direction: SIMD3<Float>? {
        guard let x = directionX, let y = directionY, let z = directionZ else { return nil }
        return SIMD3<Float>(x, y, z)
    }
}

struct PhotoMetadata: Codable, Equatable {
    var cameraMake: String?
    var cameraModel: String?
    var width: Int
    var height: Int
    var orientation: Int
    var flashUsed: Bool
    var focalLength: Double?
    var exposureTime: Double?
    var iso: Int?
}
