import Foundation
import SwiftData

/// Spatial Annotation - 3D annotations in space for collaboration
@Model
final class SpatialAnnotation {
    @Attribute(.unique) var id: UUID
    var text: String
    var authorId: UUID
    var authorName: String
    var createdDate: Date

    // 3D position
    var positionX: Float
    var positionY: Float
    var positionZ: Float

    // Anchor to twin/component
    var twinId: UUID?
    var componentId: UUID?

    var isResolved: Bool
    var resolvedDate: Date?

    init(
        id: UUID = UUID(),
        text: String,
        authorId: UUID,
        authorName: String,
        position: SIMD3<Float> = SIMD3(0, 0, 0)
    ) {
        self.id = id
        self.text = text
        self.authorId = authorId
        self.authorName = authorName
        self.createdDate = Date()
        self.positionX = position.x
        self.positionY = position.y
        self.positionZ = position.z
        self.isResolved = false
    }

    var position: SIMD3<Float> {
        SIMD3(positionX, positionY, positionZ)
    }
}
