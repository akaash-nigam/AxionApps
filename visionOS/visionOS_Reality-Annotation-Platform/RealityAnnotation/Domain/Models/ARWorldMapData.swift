//
//  ARWorldMapData.swift
//  Reality Annotation Platform
//
//  AR world map persistence model
//

import Foundation
import SwiftData

@Model
final class ARWorldMapData {
    // Identity
    @Attribute(.unique) var id: UUID
    var cloudKitRecordName: String?

    // Spatial data
    var worldMapData: Data // Serialized anchor data
    var locationName: String?
    var locationDescription: String?

    // Ownership
    var ownerID: String
    var isShared: Bool

    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var lastUsedAt: Date

    // Sync
    var syncStatus: String

    init(
        id: UUID = UUID(),
        worldMapData: Data,
        ownerID: String,
        locationName: String? = nil
    ) {
        self.id = id
        self.worldMapData = worldMapData
        self.ownerID = ownerID
        self.locationName = locationName
        self.isShared = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastUsedAt = Date()
        self.syncStatus = "pending"
    }
}
