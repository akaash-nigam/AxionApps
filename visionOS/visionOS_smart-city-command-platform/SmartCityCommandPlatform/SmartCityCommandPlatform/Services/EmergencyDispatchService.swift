//
//  EmergencyDispatchService.swift
//  SmartCityCommandPlatform
//
//  Emergency dispatch and incident management service
//

import Foundation
import CoreLocation

// MARK: - Protocol

protocol EmergencyDispatchServiceProtocol {
    func fetchActiveIncidents() async throws -> [EmergencyIncident]
    func dispatchUnits(for incident: EmergencyIncident) async throws
    func updateIncidentStatus(_ incident: EmergencyIncident, status: IncidentStatus) async throws
    func calculateOptimalRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> [CLLocationCoordinate2D]
    func streamIncidents() -> AsyncStream<EmergencyIncident>
}

// MARK: - Mock Implementation

final class MockEmergencyDispatchService: EmergencyDispatchServiceProtocol {
    private var mockIncidents: [EmergencyIncident] = []
    private var mockUnits: [EmergencyResponse] = []
    private var isGeneratingIncidents = false

    init() {
        generateMockIncidents()
        generateMockUnits()
    }

    func fetchActiveIncidents() async throws -> [EmergencyIncident] {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(350))

        let active = mockIncidents.filter { $0.status != .closed && $0.status != .resolved }
        print("🚨 Fetching \(active.count) active incidents...")

        return active.sorted { $0.reportedAt > $1.reportedAt }
    }

    func dispatchUnits(for incident: EmergencyIncident) async throws {
        // Simulate dispatch logic
        try await Task.sleep(for: .milliseconds(500))

        // Select appropriate units based on incident type
        let unitsToDispatch = selectOptimalUnits(for: incident)

        print("🚓 Dispatching \(unitsToDispatch.count) units for incident \(incident.incidentNumber)")

        // Create response entries
        for unit in unitsToDispatch {
            let response = EmergencyResponse(unitId: unit.unitId, unitType: unit.type)
            response.incident = incident
            response.status = .enRoute

            // Calculate ETA (mock)
            response.currentLocation = randomLocationNear(incident.location, radiusKm: 2)

            incident.responses.append(response)
            mockUnits.append(response)
        }

        // Update incident status
        incident.status = .dispatched
        incident.dispatchedAt = Date()

        print("✅ Units dispatched successfully")
    }

    func updateIncidentStatus(_ incident: EmergencyIncident, status: IncidentStatus) async throws {
        // Simulate update
        try await Task.sleep(for: .milliseconds(200))

        if let index = mockIncidents.firstIndex(where: { $0.id == incident.id }) {
            mockIncidents[index].status = status

            if status == .resolved {
                mockIncidents[index].resolvedAt = Date()
            }

            print("✅ Updated incident \(incident.incidentNumber) status to \(status.rawValue)")
        }
    }

    func calculateOptimalRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> [CLLocationCoordinate2D] {
        // Simulate route calculation
        try await Task.sleep(for: .milliseconds(300))

        // Generate simple route (just a few waypoints for mock)
        var route: [CLLocationCoordinate2D] = [from]

        // Add 3 waypoints
        for i in 1...3 {
            let progress = Double(i) / 4.0
            let lat = from.latitude + (to.latitude - from.latitude) * progress
            let lon = from.longitude + (to.longitude - from.longitude) * progress
            route.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        route.append(to)

        return route
    }

    func streamIncidents() -> AsyncStream<EmergencyIncident> {
        AsyncStream { continuation in
            Task {
                isGeneratingIncidents = true

                while isGeneratingIncidents && !Task.isCancelled {
                    // Randomly generate new incidents (low probability)
                    if Double.random(in: 0...1) < 0.1 { // 10% chance every cycle
                        let incident = generateRandomIncident()
                        mockIncidents.append(incident)
                        continuation.yield(incident)
                        print("🚨 NEW INCIDENT: \(incident.type.rawValue) at \(incident.address)")
                    }

                    // Wait before next check
                    try? await Task.sleep(for: .seconds(30))
                }

                continuation.finish()
            }
        }
    }

    // MARK: - Mock Data Generation

    private func generateMockIncidents() {
        let cityCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        // Generate 12 mock incidents
        let incidentTypes: [IncidentType] = [.fire, .medical, .crime, .accident, .infrastructure]
        let severities: [IncidentSeverity] = [.low, .medium, .high, .critical]
        let statuses: [IncidentStatus] = [.reported, .dispatched, .responding, .onScene]

        for i in 0..<12 {
            let type = incidentTypes.randomElement()!
            let severity = severities.randomElement()!
            let location = randomLocationNear(cityCenter, radiusKm: 8)

            let incident = EmergencyIncident(
                type: type,
                severity: severity,
                location: location,
                description: generateIncidentDescription(type: type)
            )

            incident.address = "123 \(["Main", "Market", "Mission", "Broadway", "Van Ness"].randomElement()!) St"
            incident.status = statuses.randomElement()!
            incident.affectedCitizens = Int.random(in: 1...100)
            incident.reportedAt = Date().addingTimeInterval(-Double.random(in: 0...3600))

            if incident.status != .reported {
                incident.dispatchedAt = incident.reportedAt.addingTimeInterval(Double.random(in: 60...300))
            }

            mockIncidents.append(incident)
        }

        print("✅ Generated \(mockIncidents.count) mock incidents")
    }

    private func generateMockUnits() {
        // Generate available emergency units
        let unitTypes: [(EmergencyUnitType, Int)] = [
            (.fire, 10),
            (.police, 15),
            (.ambulance, 12),
            (.rescue, 5),
            (.hazmat, 3),
            (.utility, 8)
        ]

        for (type, count) in unitTypes {
            for i in 1...count {
                let response = EmergencyResponse(
                    unitId: "\(type.rawValue.uppercased())-\(String(format: "%02d", i))",
                    unitType: type
                )
                response.status = .available
                mockUnits.append(response)
            }
        }

        print("✅ Generated \(mockUnits.count) emergency units")
    }

    private func generateRandomIncident() -> EmergencyIncident {
        let cityCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let type = IncidentType.allCases.randomElement()!
        let severity = IncidentSeverity.allCases.randomElement()!
        let location = randomLocationNear(cityCenter, radiusKm: 8)

        let incident = EmergencyIncident(
            type: type,
            severity: severity,
            location: location,
            description: generateIncidentDescription(type: type)
        )

        incident.address = "\(Int.random(in: 100...999)) \(["Main", "Market", "Mission", "Broadway", "Van Ness"].randomElement()!) St"
        incident.affectedCitizens = Int.random(in: 1...50)

        return incident
    }

    private func generateIncidentDescription(type: IncidentType) -> String {
        switch type {
        case .fire:
            return "Structure fire reported with smoke visible"
        case .medical:
            return "Medical emergency requiring immediate assistance"
        case .crime:
            return "Criminal activity reported in progress"
        case .accident:
            return "Traffic accident with possible injuries"
        case .infrastructure:
            return "Infrastructure failure affecting services"
        case .natural:
            return "Natural disaster or weather emergency"
        case .hazmat:
            return "Hazardous materials incident"
        case .civil:
            return "Civil disturbance requiring response"
        }
    }

    private func selectOptimalUnits(for incident: EmergencyIncident) -> [EmergencyResponse] {
        // Select appropriate units based on incident type
        let requiredTypes: [EmergencyUnitType]

        switch incident.type {
        case .fire:
            requiredTypes = [.fire, .ambulance]
        case .medical:
            requiredTypes = [.ambulance]
        case .crime:
            requiredTypes = [.police]
        case .accident:
            requiredTypes = [.police, .ambulance]
        case .infrastructure:
            requiredTypes = [.utility]
        case .natural:
            requiredTypes = [.fire, .police, .rescue]
        case .hazmat:
            requiredTypes = [.hazmat, .fire]
        case .civil:
            requiredTypes = [.police]
        }

        // Find available units
        var selectedUnits: [EmergencyResponse] = []
        for type in requiredTypes {
            if let unit = mockUnits.first(where: { $0.unitType == type && $0.status == .available }) {
                selectedUnits.append(unit)
            }
        }

        return selectedUnits
    }

    private func randomLocationNear(_ center: CLLocationCoordinate2D, radiusKm: Double) -> CLLocationCoordinate2D {
        let radiusDegrees = radiusKm / 111.0
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

    deinit {
        isGeneratingIncidents = false
    }
}

// MARK: - Supporting Types

struct MockEmergencyUnit {
    let unitId: String
    let type: EmergencyUnitType
    var isAvailable: Bool = true
    var currentLocation: CLLocationCoordinate2D?
}
