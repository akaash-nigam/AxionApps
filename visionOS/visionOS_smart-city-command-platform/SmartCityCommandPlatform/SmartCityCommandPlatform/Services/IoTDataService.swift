//
//  IoTDataService.swift
//  SmartCityCommandPlatform
//
//  IoT sensor data service
//

import Foundation
import CoreLocation

// MARK: - Protocol

protocol IoTDataServiceProtocol {
    func fetchSensorData() async throws -> [IoTSensor]
    func fetchInfrastructureStatus() async throws -> [Infrastructure]
    func streamSensorReadings() -> AsyncStream<SensorReading>
    func updateSensorStatus(_ sensor: IoTSensor, status: SensorStatus) async throws
}

// MARK: - Mock Implementation

final class MockIoTDataService: IoTDataServiceProtocol {
    private var mockSensors: [IoTSensor] = []
    private var mockInfrastructure: [Infrastructure] = []
    private var isGeneratingReadings = false

    init() {
        generateMockData()
    }

    func fetchSensorData() async throws -> [IoTSensor] {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(300))

        print("📡 Fetching \(mockSensors.count) sensors...")
        return mockSensors
    }

    func fetchInfrastructureStatus() async throws -> [Infrastructure] {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(400))

        print("🏗️ Fetching \(mockInfrastructure.count) infrastructure systems...")
        return mockInfrastructure
    }

    func streamSensorReadings() -> AsyncStream<SensorReading> {
        AsyncStream { continuation in
            Task {
                isGeneratingReadings = true

                while isGeneratingReadings && !Task.isCancelled {
                    // Generate random sensor reading
                    if let sensor = mockSensors.randomElement() {
                        let reading = generateRandomReading(for: sensor)
                        continuation.yield(reading)
                    }

                    // Wait between readings
                    try? await Task.sleep(for: .seconds(2))
                }

                continuation.finish()
            }
        }
    }

    func updateSensorStatus(_ sensor: IoTSensor, status: SensorStatus) async throws {
        // Simulate update
        try await Task.sleep(for: .milliseconds(200))

        if let index = mockSensors.firstIndex(where: { $0.id == sensor.id }) {
            mockSensors[index].status = status
            print("✅ Updated sensor \(sensor.sensorId) status to \(status.rawValue)")
        }
    }

    // MARK: - Mock Data Generation

    private func generateMockData() {
        // Generate 100 mock sensors across city
        let cityCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco

        for i in 0..<100 {
            let sensor = IoTSensor(
                sensorId: "SENSOR-\(String(format: "%03d", i))",
                type: SensorType.allCases.randomElement()!,
                location: randomLocationNear(cityCenter, radiusKm: 10)
            )
            sensor.status = [SensorStatus.active, .active, .active, .inactive].randomElement()!
            sensor.batteryLevel = Double.random(in: 20...100)
            sensor.lastReading = Date().addingTimeInterval(-Double.random(in: 0...3600))

            mockSensors.append(sensor)
        }

        // Generate mock infrastructure
        let infrastructureTypes: [InfrastructureType] = [.water, .power, .gas, .telecommunications, .roads]

        for (index, type) in infrastructureTypes.enumerated() {
            let infrastructure = Infrastructure(
                name: "\(type.rawValue.capitalized) System \(index + 1)",
                type: type,
                capacity: Double.random(in: 1000...10000),
                criticality: [CriticalityLevel.high, .critical].randomElement()!
            )
            infrastructure.currentLoad = infrastructure.capacity * Double.random(in: 0.5...0.95)
            infrastructure.health = Double.random(in: 75...100)
            infrastructure.status = [OperationalStatus.operational, .operational, .degraded].randomElement()!

            mockInfrastructure.append(infrastructure)
        }

        print("✅ Generated \(mockSensors.count) mock sensors")
        print("✅ Generated \(mockInfrastructure.count) mock infrastructure systems")
    }

    private func randomLocationNear(_ center: CLLocationCoordinate2D, radiusKm: Double) -> CLLocationCoordinate2D {
        // Generate random location within radius
        let radiusDegrees = radiusKm / 111.0 // Rough conversion
        let u = Double.random(in: 0...1)
        let v = Double.random(in: 0...1)
        let w = radiusDegrees * sqrt(u)
        let t = 2 * .pi * v
        let x = w * cos(t)
        let y = w * sin(t)

        return CLLocationCoordinate2D(
            latitude: center.latitude + y,
            longitude: center.longitude + x
        )
    }

    private func generateRandomReading(for sensor: IoTSensor) -> SensorReading {
        let value: Double
        let unit: String

        switch sensor.type {
        case .temperature:
            value = Double.random(in: -10...40)
            unit = "°C"
        case .humidity:
            value = Double.random(in: 0...100)
            unit = "%"
        case .airQuality:
            value = Double.random(in: 0...500)
            unit = "AQI"
        case .noise:
            value = Double.random(in: 30...100)
            unit = "dB"
        case .traffic:
            value = Double.random(in: 0...100)
            unit = "vehicles/min"
        case .flood:
            value = Double.random(in: 0...200)
            unit = "cm"
        case .seismic:
            value = Double.random(in: 0...5)
            unit = "magnitude"
        case .camera:
            value = Double.random(in: 0...1)
            unit = "active"
        case .pressure:
            value = Double.random(in: 980...1050)
            unit = "hPa"
        case .flow:
            value = Double.random(in: 0...1000)
            unit = "L/min"
        }

        let reading = SensorReading(value: value, unit: unit)
        reading.sensor = sensor
        reading.quality = [DataQuality.good, .good, .good, .fair].randomElement()!

        return reading
    }

    deinit {
        isGeneratingReadings = false
    }
}
