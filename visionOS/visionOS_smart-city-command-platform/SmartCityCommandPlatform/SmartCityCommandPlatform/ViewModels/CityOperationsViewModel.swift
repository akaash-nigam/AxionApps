//
//  CityOperationsViewModel.swift
//  SmartCityCommandPlatform
//
//  City operations command center business logic
//

import Foundation
import SwiftData
import Observation

/// City Operations View Model
///
/// Manages the state and business logic for the main city operations center,
/// coordinating between multiple city departments and real-time data sources.
@Observable
final class CityOperationsViewModel {
    // MARK: - State Properties

    /// Currently selected city
    var selectedCity: City?

    /// Active emergency incidents
    var activeIncidents: [EmergencyIncident] = []

    /// Infrastructure systems with alerts
    var infrastructureAlerts: [Infrastructure] = []

    /// IoT sensor data
    var sensorData: [IoTSensor] = []

    /// Department status information
    var departmentStatuses: [DepartmentStatus] = []

    /// City-wide metrics
    var cityMetrics: CityMetrics?

    // MARK: - UI State

    /// Loading state indicator
    var isLoading = false

    /// Error message if any
    var errorMessage: String?

    /// Selected city layer for visualization
    var selectedLayer: CityLayer = .all

    /// Last data refresh time
    var lastRefreshTime: Date?

    // MARK: - Services

    private let iotService: IoTDataServiceProtocol
    private let emergencyService: EmergencyDispatchServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let infrastructureService: InfrastructureServiceProtocol

    // MARK: - Initialization

    init(
        iotService: IoTDataServiceProtocol,
        emergencyService: EmergencyDispatchServiceProtocol,
        analyticsService: AnalyticsServiceProtocol,
        infrastructureService: InfrastructureServiceProtocol
    ) {
        self.iotService = iotService
        self.emergencyService = emergencyService
        self.analyticsService = analyticsService
        self.infrastructureService = infrastructureService
    }

    // MARK: - Convenience Initializer (Mock Services)

    convenience init() {
        self.init(
            iotService: MockIoTDataService(),
            emergencyService: MockEmergencyDispatchService(),
            analyticsService: MockAnalyticsService(),
            infrastructureService: MockInfrastructureService()
        )
    }

    // MARK: - Data Loading

    /// Load all city data from services
    func loadCityData() async throws {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            lastRefreshTime = Date()
        }

        do {
            // Load data concurrently
            async let incidents = emergencyService.fetchActiveIncidents()
            async let infrastructure = infrastructureService.fetchCriticalAlerts()
            async let sensors = iotService.fetchSensorData()
            async let departments = analyticsService.fetchDepartmentStatuses()
            async let metrics = analyticsService.calculateCityMetrics()

            // Await all results
            (activeIncidents, infrastructureAlerts, sensorData, departmentStatuses, cityMetrics) =
                try await (incidents, infrastructure, sensors, departments, metrics)

            print("✅ City data loaded successfully")
            print("   - \(activeIncidents.count) active incidents")
            print("   - \(infrastructureAlerts.count) infrastructure alerts")
            print("   - \(sensorData.count) sensors online")
            print("   - \(departmentStatuses.count) departments")

        } catch {
            errorMessage = "Failed to load city data: \(error.localizedDescription)"
            print("❌ Error loading city data: \(error)")
            throw error
        }
    }

    /// Start real-time updates for city data
    func startRealTimeUpdates() async {
        print("🔄 Starting real-time updates...")

        // Start streaming sensor data
        Task {
            for await reading in iotService.streamSensorReadings() {
                updateSensorReading(reading)
            }
        }

        // Start streaming incidents
        Task {
            for await incident in emergencyService.streamIncidents() {
                handleNewIncident(incident)
            }
        }

        // Periodic refresh every 30 seconds
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                try? await refreshMetrics()
            }
        }
    }

    /// Refresh city metrics
    private func refreshMetrics() async throws {
        cityMetrics = try await analyticsService.calculateCityMetrics()
    }

    // MARK: - Emergency Response

    /// Dispatch emergency response to incident
    func dispatchEmergencyResponse(to incident: EmergencyIncident) async throws {
        print("🚨 Dispatching emergency response to incident \(incident.incidentNumber)")

        do {
            try await emergencyService.dispatchUnits(for: incident)

            // Refresh incident list
            activeIncidents = try await emergencyService.fetchActiveIncidents()

            print("✅ Emergency response dispatched successfully")
        } catch {
            errorMessage = "Failed to dispatch emergency response: \(error.localizedDescription)"
            throw error
        }
    }

    /// Update incident status
    func updateIncidentStatus(_ incident: EmergencyIncident, status: IncidentStatus) async throws {
        try await emergencyService.updateIncidentStatus(incident, status: status)

        // Refresh incident list
        activeIncidents = try await emergencyService.fetchActiveIncidents()
    }

    // MARK: - Infrastructure Management

    /// Get infrastructure by type
    func getInfrastructure(type: InfrastructureType) -> [Infrastructure] {
        infrastructureAlerts.filter { $0.type == type }
    }

    /// Mark infrastructure issue as resolved
    func resolveInfrastructureIssue(_ infrastructure: Infrastructure) async throws {
        try await infrastructureService.updateStatus(infrastructure, status: .operational)

        // Refresh alerts
        infrastructureAlerts = try await infrastructureService.fetchCriticalAlerts()
    }

    // MARK: - Sensor Data

    /// Get sensors by type
    func getSensors(type: SensorType) -> [IoTSensor] {
        sensorData.filter { $0.type == type }
    }

    /// Get sensors in specific location radius
    func getSensorsNearLocation(_ location: CLLocationCoordinate2D, radius: Double) -> [IoTSensor] {
        sensorData.filter { sensor in
            let distance = calculateDistance(from: location, to: sensor.location)
            return distance <= radius
        }
    }

    // MARK: - Analytics

    /// Get critical alerts count
    var criticalAlertsCount: Int {
        activeIncidents.filter { $0.severity == .critical || $0.severity == .catastrophic }.count
    }

    /// Get operational efficiency percentage
    var operationalEfficiency: Double {
        guard !departmentStatuses.isEmpty else { return 0 }

        let operational = departmentStatuses.filter { $0.status == .operational }.count
        return Double(operational) / Double(departmentStatuses.count) * 100
    }

    /// Get average response time (in minutes)
    var averageResponseTime: Double? {
        cityMetrics?.averageResponseTime
    }

    // MARK: - Private Helpers

    private func updateSensorReading(_ reading: SensorReading) {
        // Update sensor with new reading
        if let index = sensorData.firstIndex(where: { $0.id == reading.sensor?.id }) {
            sensorData[index].lastReading = reading.timestamp
        }
    }

    private func handleNewIncident(_ incident: EmergencyIncident) {
        // Add new incident to list
        if !activeIncidents.contains(where: { $0.id == incident.id }) {
            activeIncidents.insert(incident, at: 0)
            print("🚨 New incident: \(incident.type.rawValue) at \(incident.address)")
        }
    }

    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        // Simplified distance calculation (Haversine formula)
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let radius = 6371.0 // Earth's radius in kilometers

        return radius * c
    }
}

// MARK: - Supporting Types

/// Department operational status
struct DepartmentStatus: Identifiable {
    let id = UUID()
    let name: String
    let departmentType: DepartmentType
    let status: OperationalStatus
    let activeUnits: Int
    let totalUnits: Int
    let responseTime: TimeInterval

    var efficiency: Double {
        Double(activeUnits) / Double(totalUnits) * 100
    }
}

enum DepartmentType: String, CaseIterable {
    case fire = "Fire Services"
    case police = "Police"
    case medical = "Medical Services"
    case utilities = "Utilities"
    case traffic = "Traffic Management"
    case infrastructure = "Infrastructure"
}

/// City-wide metrics
struct CityMetrics {
    let timestamp: Date
    let activeIncidents: Int
    let averageResponseTime: Double // minutes
    let infrastructureHealth: Double // percentage
    let trafficFlowEfficiency: Double // percentage
    let airQualityIndex: Double
    let citizenSatisfaction: Double // percentage
    let resourceUtilization: Double // percentage

    init(
        timestamp: Date = Date(),
        activeIncidents: Int = 0,
        averageResponseTime: Double = 0,
        infrastructureHealth: Double = 100,
        trafficFlowEfficiency: Double = 100,
        airQualityIndex: Double = 50,
        citizenSatisfaction: Double = 85,
        resourceUtilization: Double = 75
    ) {
        self.timestamp = timestamp
        self.activeIncidents = activeIncidents
        self.averageResponseTime = averageResponseTime
        self.infrastructureHealth = infrastructureHealth
        self.trafficFlowEfficiency = trafficFlowEfficiency
        self.airQualityIndex = airQualityIndex
        self.citizenSatisfaction = citizenSatisfaction
        self.resourceUtilization = resourceUtilization
    }
}

enum CityLayer {
    case all
    case infrastructure
    case emergency
    case transportation
    case environment
    case buildings
}

// Import for CLLocationCoordinate2D
import CoreLocation
