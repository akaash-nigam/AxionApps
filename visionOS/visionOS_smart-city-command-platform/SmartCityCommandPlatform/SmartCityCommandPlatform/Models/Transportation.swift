//
//  Transportation.swift
//  SmartCityCommandPlatform
//
//  Transportation and mobility models
//

import SwiftData
import Foundation
import CoreLocation

// MARK: - Transportation Asset

@Model
final class TransportationAsset {
    @Attribute(.unique) var id: UUID
    var assetId: String
    var type: TransportAssetType
    var route: String?

    var currentLocation: CLLocationCoordinate2D?
    var heading: Double
    var speed: Double // km/h
    var capacity: Int
    var occupancy: Int

    var status: AssetStatus
    var lastUpdated: Date

    init(assetId: String, type: TransportAssetType, capacity: Int) {
        self.id = UUID()
        self.assetId = assetId
        self.type = type
        self.capacity = capacity
        self.occupancy = 0
        self.status = .active
        self.heading = 0
        self.speed = 0
        self.lastUpdated = Date()
    }
}

enum TransportAssetType: String, Codable {
    case bus
    case metro
    case tram
    case ferry
    case bikeshare
    case scooter
}

enum AssetStatus: String, Codable {
    case active
    case idle
    case maintenance
    case outOfService
}
