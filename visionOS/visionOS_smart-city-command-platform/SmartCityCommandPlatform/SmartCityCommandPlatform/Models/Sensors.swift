//
//  Sensors.swift
//  SmartCityCommandPlatform
//
//  IoT sensor and analytics models
//

import SwiftData
import Foundation
import CoreLocation

// MARK: - IoT Sensor

@Model
final class IoTSensor {
    @Attribute(.unique) var id: UUID
    var sensorId: String
    var type: SensorType
    var location: CLLocationCoordinate2D
    var status: SensorStatus

    @Relationship var city: City?
    @Relationship var infrastructure: Infrastructure?
    @Relationship(deleteRule: .cascade) var readings: [SensorReading]

    var lastReading: Date?
    var batteryLevel: Double? // 0-100%

    init(sensorId: String, type: SensorType, location: CLLocationCoordinate2D) {
        self.id = UUID()
        self.sensorId = sensorId
        self.type = type
        self.location = location
        self.status = .active
        self.readings = []
    }
}

enum SensorType: String, Codable, CaseIterable {
    case temperature
    case humidity
    case airQuality
    case noise
    case traffic
    case flood
    case seismic
    case camera
    case pressure
    case flow
}

enum SensorStatus: String, Codable {
    case active
    case inactive
    case maintenance
    case error
}

// MARK: - Sensor Reading

@Model
final class SensorReading {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var value: Double
    var unit: String
    var quality: DataQuality

    @Relationship var sensor: IoTSensor?

    init(value: Double, unit: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.quality = .good
    }
}

enum DataQuality: String, Codable {
    case good
    case fair
    case poor
    case invalid
}

// MARK: - Analytics Snapshot

@Model
final class AnalyticsSnapshot {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var metricType: String
    var value: Double
    var metadata: [String: String]

    init(metricType: String, value: Double, metadata: [String: String] = [:]) {
        self.id = UUID()
        self.timestamp = Date()
        self.metricType = metricType
        self.value = value
        self.metadata = metadata
    }
}
