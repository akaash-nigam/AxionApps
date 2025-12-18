//
//  Annotation.swift
//  Reality Annotation Platform
//
//  Core annotation model
//

import Foundation
import SwiftData

@Model
final class Annotation {
    // Identity
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Content
    var type: AnnotationType
    var title: String?
    var contentText: String?
    var contentData: Data?
    var mediaURL: URL?

    // Spatial Properties
    var positionX: Float
    var positionY: Float
    var positionZ: Float
    var orientationW: Float
    var orientationX: Float
    var orientationY: Float
    var orientationZ: Float
    var scale: Float
    var anchorID: UUID

    // Organization
    var layerID: UUID
    @Relationship(deleteRule: .nullify) var layer: Layer?

    // Ownership
    var ownerID: String

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var deletedAt: Date?

    // Collaboration
    @Relationship(deleteRule: .cascade) var comments: [Comment]

    // Sync status
    var syncStatus: String // "synced", "pending", "conflict", "error"

    init(
        id: UUID = UUID(),
        type: AnnotationType,
        title: String? = nil,
        contentText: String? = nil,
        position: SIMD3<Float>,
        orientation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0]),
        scale: Float = 1.0,
        layerID: UUID,
        ownerID: String,
        anchorID: UUID = UUID()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.contentText = contentText
        self.positionX = position.x
        self.positionY = position.y
        self.positionZ = position.z
        self.orientationW = orientation.vector.w
        self.orientationX = orientation.vector.x
        self.orientationY = orientation.vector.y
        self.orientationZ = orientation.vector.z
        self.scale = scale
        self.layerID = layerID
        self.ownerID = ownerID
        self.anchorID = anchorID
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.comments = []
        self.syncStatus = "pending"
    }

    // MARK: - Computed Properties

    var position: SIMD3<Float> {
        get { SIMD3(positionX, positionY, positionZ) }
        set {
            positionX = newValue.x
            positionY = newValue.y
            positionZ = newValue.z
        }
    }

    var orientation: simd_quatf {
        get { simd_quatf(ix: orientationX, iy: orientationY, iz: orientationZ, r: orientationW) }
        set {
            orientationW = newValue.vector.w
            orientationX = newValue.vector.x
            orientationY = newValue.vector.y
            orientationZ = newValue.vector.z
        }
    }

    var isPendingSync: Bool {
        syncStatus == "pending"
    }

    // MARK: - Validation

    func validate() throws {
        guard !ownerID.isEmpty else {
            throw ValidationError.missingOwner
        }

        guard scale > 0 else {
            throw ValidationError.invalidScale
        }

        if let title = title, title.count > 100 {
            throw ValidationError.titleTooLong
        }
    }
}

// MARK: - Annotation Type

enum AnnotationType: String, Codable {
    case text
    case photo
    case voiceMemo
    case drawing

    var icon: String {
        switch self {
        case .text: return "note.text"
        case .photo: return "photo"
        case .voiceMemo: return "mic"
        case .drawing: return "pencil.tip"
        }
    }

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .photo: return "Photo"
        case .voiceMemo: return "Voice Memo"
        case .drawing: return "Drawing"
        }
    }
}

// MARK: - Validation Error

enum ValidationError: LocalizedError {
    case emptyContent
    case titleTooLong
    case invalidScale
    case missingOwner

    var errorDescription: String? {
        switch self {
        case .emptyContent: return "Annotation content cannot be empty"
        case .titleTooLong: return "Title must be 100 characters or less"
        case .invalidScale: return "Scale must be greater than 0"
        case .missingOwner: return "Annotation must have an owner"
        }
    }
}
