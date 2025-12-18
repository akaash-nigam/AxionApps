//
//  SafetyMonitoringTests.swift
//  Construction Site Manager Tests
//
//  Unit tests for SafetyMonitoringService
//

import Testing
import Foundation
@testable import ConstructionSiteManager

@Suite("Safety Monitoring Service Tests")
struct SafetyMonitoringTests {

    @Test("Safety service initializes correctly")
    func testServiceInitialization() {
        // Arrange & Act
        let service = SafetyMonitoringService.shared

        // Assert
        #expect(!service.isMonitoring)
        #expect(service.activeAlerts.isEmpty)
    }

    @Test("Danger zone contains point correctly")
    func testDangerZoneContainsPoint() {
        // Arrange
        let zone = DangerZone(
            name: "Test Zone",
            type: .craneOperatingZone,
            severity: .high,
            boundaryPoints: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(10, 0, 0),
                SIMD3<Float>(10, 0, 10),
                SIMD3<Float>(0, 0, 10)
            ],
            responsibleParty: "Test Crew"
        )

        // Act
        let insidePoint = SIMD3<Float>(5, 0, 5)  // Middle of zone
        let outsidePoint = SIMD3<Float>(20, 0, 20)  // Outside zone

        // Assert
        #expect(zone.containsPoint(insidePoint))
        #expect(!zone.containsPoint(outsidePoint))
    }

    @Test("Danger zone distance calculation")
    func testDangerZoneDistance() {
        // Arrange
        let zone = DangerZone(
            name: "Test Zone",
            type: .fallHazard,
            severity: .critical,
            boundaryPoints: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(5, 0, 0),
                SIMD3<Float>(5, 0, 5),
                SIMD3<Float>(0, 0, 5)
            ],
            responsibleParty: "Test Crew"
        )

        // Act
        let nearPoint = SIMD3<Float>(0, 0, 0)
        let farPoint = SIMD3<Float>(100, 0, 100)

        // Assert
        let nearDistance = zone.distanceToPoint(nearPoint)
        let farDistance = zone.distanceToPoint(farPoint)

        #expect(nearDistance == 0.0)  // On boundary
        #expect(farDistance > nearDistance)
    }

    @Test("Safety violation detection for inside zone")
    func testViolationDetectionInside() {
        // Arrange
        let service = SafetyMonitoringService.shared
        let zone = DangerZone(
            name: "Restricted Area",
            type: .excavation,
            severity: .high,
            boundaryPoints: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(10, 0, 0),
                SIMD3<Float>(10, 0, 10),
                SIMD3<Float>(0, 0, 10)
            ],
            warningDistance: 2.0,
            responsibleParty: "Site Safety"
        )

        // Act
        let violationPosition = SIMD3<Float>(5, 0, 5)  // Inside zone
        let violation = service.checkViolation(
            position: violationPosition,
            zones: [zone]
        )

        // Assert
        #expect(violation != nil)
        #expect(violation?.severity == .high)
        #expect(violation?.type == .proximityViolation)
    }

    @Test("Safety violation detection for warning distance")
    func testViolationDetectionWarning() {
        // Arrange
        let service = SafetyMonitoringService.shared
        let zone = DangerZone(
            name: "Crane Zone",
            type: .craneOperatingZone,
            severity: .critical,
            boundaryPoints: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(5, 0, 0),
                SIMD3<Float>(5, 0, 5),
                SIMD3<Float>(0, 0, 5)
            ],
            warningDistance: 3.0,
            responsibleParty: "Crane Operator"
        )

        // Act
        let warningPosition = SIMD3<Float>(0.5, 0, 0)  // Close to boundary
        let violation = service.checkViolation(
            position: warningPosition,
            zones: [zone]
        )

        // Assert
        #expect(violation != nil)
        #expect(violation?.type == .proximityViolation)
    }

    @Test("No violation when outside danger zone")
    func testNoViolationOutside() {
        // Arrange
        let service = SafetyMonitoringService.shared
        let zone = DangerZone(
            name: "Test Zone",
            type: .fallHazard,
            severity: .high,
            boundaryPoints: [
                SIMD3<Float>(0, 0, 0),
                SIMD3<Float>(5, 0, 0),
                SIMD3<Float>(5, 0, 5),
                SIMD3<Float>(0, 0, 5)
            ],
            warningDistance: 1.0,
            responsibleParty: "Safety Team"
        )

        // Act
        let safePosition = SIMD3<Float>(100, 0, 100)  // Far away
        let violation = service.checkViolation(
            position: safePosition,
            zones: [zone]
        )

        // Assert
        #expect(violation == nil)
    }

    @Test("Safety score calculation with no alerts")
    func testSafetyScoreNoAlerts() {
        // Arrange
        let service = SafetyMonitoringService.shared

        // Act
        let score = service.calculateSafetyScore(alerts: [])

        // Assert
        #expect(score == 100.0)
    }

    @Test("Safety score calculation with alerts")
    func testSafetyScoreWithAlerts() {
        // Arrange
        let service = SafetyMonitoringService.shared
        let alerts = [
            SafetyAlert(
                type: .proximityViolation,
                severity: .critical,
                message: "Critical violation"
            ),
            SafetyAlert(
                type: .ppeViolation,
                severity: .medium,
                message: "Medium violation"
            )
        ]

        // Act
        let score = service.calculateSafetyScore(alerts: alerts)

        // Assert
        #expect(score < 100.0)  // Score should be reduced
        #expect(score >= 0.0)   // Score should not be negative
    }

    @Test("Danger zone is active during time window")
    func testDangerZoneActiveTime() {
        // Arrange
        let now = Date()
        let startTime = now.addingTimeInterval(-3600)  // 1 hour ago
        let endTime = now.addingTimeInterval(3600)     // 1 hour from now

        let zone = DangerZone(
            name: "Scheduled Work Zone",
            type: .hotWork,
            severity: .high,
            boundaryPoints: [SIMD3<Float>(0, 0, 0)],
            startTime: startTime,
            endTime: endTime,
            responsibleParty: "Contractor"
        )

        // Assert
        #expect(zone.isCurrentlyActive)
    }

    @Test("Danger zone is not active before start time")
    func testDangerZoneBeforeStartTime() {
        // Arrange
        let futureStart = Date().addingTimeInterval(3600)  // 1 hour from now
        let futureEnd = Date().addingTimeInterval(7200)    // 2 hours from now

        let zone = DangerZone(
            name: "Future Work Zone",
            type: .electricalWork,
            severity: .high,
            boundaryPoints: [SIMD3<Float>(0, 0, 0)],
            startTime: futureStart,
            endTime: futureEnd,
            responsibleParty: "Electrician"
        )

        // Assert
        #expect(!zone.isCurrentlyActive)
    }

    @Test("Danger zone is not active after end time")
    func testDangerZoneAfterEndTime() {
        // Arrange
        let pastStart = Date().addingTimeInterval(-7200)  // 2 hours ago
        let pastEnd = Date().addingTimeInterval(-3600)    // 1 hour ago

        let zone = DangerZone(
            name: "Past Work Zone",
            type: .heavyEquipment,
            severity: .medium,
            boundaryPoints: [SIMD3<Float>(0, 0, 0)],
            startTime: pastStart,
            endTime: pastEnd,
            responsibleParty: "Equipment Operator"
        )

        // Assert
        #expect(!zone.isCurrentlyActive)
    }
}

@Suite("Safety Alert Tests")
struct SafetyAlertTests {

    @Test("Safety alert initializes correctly")
    func testAlertInitialization() {
        // Arrange & Act
        let alert = SafetyAlert(
            type: .proximityViolation,
            severity: .high,
            message: "Test alert",
            location: SIMD3<Float>(1, 2, 3)
        )

        // Assert
        #expect(alert.type == .proximityViolation)
        #expect(alert.severity == .high)
        #expect(alert.message == "Test alert")
        #expect(!alert.resolved)
        #expect(!alert.isAcknowledged)
    }

    @Test("Alert acknowledgment works")
    func testAlertAcknowledgment() {
        // Arrange
        var alert = SafetyAlert(
            type: .ppeViolation,
            severity: .medium,
            message: "Missing hard hat"
        )

        // Act
        alert.acknowledgedBy = "John Doe"
        alert.acknowledgedAt = Date()

        // Assert
        #expect(alert.isAcknowledged)
        #expect(alert.acknowledgedBy == "John Doe")
        #expect(alert.acknowledgedAt != nil)
    }

    @Test("Alert response time calculation")
    func testResponseTimeCalculation() {
        // Arrange
        let timestamp = Date()
        let ackTime = timestamp.addingTimeInterval(60)  // 60 seconds later
        var alert = SafetyAlert(
            type: .emergencyAlert,
            severity: .critical,
            message: "Emergency",
            timestamp: timestamp
        )

        // Act
        alert.acknowledgedAt = ackTime

        // Assert
        let responseTime = alert.responseTime
        #expect(responseTime != nil)
        #expect(responseTime! == 60.0)  // 60 seconds
    }
}
