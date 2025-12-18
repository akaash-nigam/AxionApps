//
// ComponentTests.swift
// Field Service AR Assistant
//
// Created by Claude on 2025-01-17.
//

import Testing
import Foundation
@testable import FieldServiceAR

@MainActor
final class ComponentTests {

    // MARK: - Initialization Tests

    @Test("Component initializes correctly")
    func testInitialization() throws {
        let component = Component(
            name: "Compressor",
            partNumber: "CMP-5000",
            type: .mechanical
        )

        #expect(component.id != nil)
        #expect(component.name == "Compressor")
        #expect(component.partNumber == "CMP-5000")
        #expect(component.type == .mechanical)
        #expect(component.status == .operational)
        #expect(component.manufacturer == nil)
        #expect(component.specifications.isEmpty)
    }

    // MARK: - Type Tests

    @Test("Mechanical component type")
    func testMechanicalType() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        #expect(component.type == .mechanical)
    }

    @Test("Electrical component type")
    func testElectricalType() {
        let component = Component(
            name: "Control Board",
            partNumber: "PCB-200",
            type: .electrical
        )

        #expect(component.type == .electrical)
    }

    @Test("Hydraulic component type")
    func testHydraulicType() {
        let component = Component(
            name: "Hydraulic Pump",
            partNumber: "HYD-300",
            type: .hydraulic
        )

        #expect(component.type == .hydraulic)
    }

    @Test("Pneumatic component type")
    func testPneumaticType() {
        let component = Component(
            name: "Air Compressor",
            partNumber: "AIR-400",
            type: .pneumatic
        )

        #expect(component.type == .pneumatic)
    }

    @Test("Electronic component type")
    func testElectronicType() {
        let component = Component(
            name: "Sensor",
            partNumber: "SNS-500",
            type: .electronic
        )

        #expect(component.type == .electronic)
    }

    // MARK: - Status Tests

    @Test("Operational status")
    func testOperationalStatus() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        #expect(component.status == .operational)
    }

    @Test("Degraded status")
    func testDegradedStatus() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.status = .degraded

        #expect(component.status == .degraded)
    }

    @Test("Failed status")
    func testFailedStatus() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.status = .failed

        #expect(component.status == .failed)
    }

    @Test("Under maintenance status")
    func testUnderMaintenanceStatus() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.status = .underMaintenance

        #expect(component.status == .underMaintenance)
    }

    // MARK: - Specification Tests

    @Test("Add specification to component")
    func testAddSpecification() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        component.specifications["Voltage"] = "240V"

        #expect(component.specifications.count == 1)
        #expect(component.specifications["Voltage"] == "240V")
    }

    @Test("Multiple specifications")
    func testMultipleSpecifications() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        component.specifications = [
            "Voltage": "240V",
            "Current": "10A",
            "Power": "2.4kW",
            "RPM": "3000",
            "Phase": "3-phase"
        ]

        #expect(component.specifications.count == 5)
        #expect(component.specifications["RPM"] == "3000")
    }

    // MARK: - Manufacturer Tests

    @Test("Set manufacturer")
    func testSetManufacturer() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        component.manufacturer = "Siemens"

        #expect(component.manufacturer == "Siemens")
    }

    // MARK: - Lifecycle Tests

    @Test("Installation date tracking")
    func testInstallationDate() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        let installDate = Date()
        component.installationDate = installDate

        #expect(component.installationDate == installDate)
    }

    @Test("Last maintenance date tracking")
    func testLastMaintenanceDate() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        let maintenanceDate = Date()
        component.lastMaintenanceDate = maintenanceDate

        #expect(component.lastMaintenanceDate == maintenanceDate)
    }

    @Test("Service life calculation")
    func testServiceLife() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )

        let installDate = Date().addingTimeInterval(-86400 * 365) // 1 year ago
        component.installationDate = installDate

        let now = Date()
        let serviceLife = now.timeIntervalSince(installDate)

        // Service life should be approximately 1 year (allow 1 minute variance)
        #expect(abs(serviceLife - (86400 * 365)) < 60)
    }

    // MARK: - Complex Component Tests

    @Test("Complete component with all properties")
    func testCompleteComponent() {
        let component = Component(
            name: "Industrial Compressor",
            partNumber: "CMP-5000-HD",
            type: .mechanical
        )

        component.manufacturer = "Atlas Copco"
        component.status = .operational
        component.installationDate = Date().addingTimeInterval(-86400 * 180) // 6 months ago
        component.lastMaintenanceDate = Date().addingTimeInterval(-86400 * 30) // 1 month ago

        component.specifications = [
            "Pressure": "150 PSI",
            "Flow Rate": "100 CFM",
            "Motor Power": "15 HP",
            "Tank Size": "80 Gallons",
            "Voltage": "230V 3-Phase",
            "Weight": "450 lbs"
        ]

        // Verify all properties
        #expect(component.name == "Industrial Compressor")
        #expect(component.partNumber == "CMP-5000-HD")
        #expect(component.type == .mechanical)
        #expect(component.manufacturer == "Atlas Copco")
        #expect(component.status == .operational)
        #expect(component.installationDate != nil)
        #expect(component.lastMaintenanceDate != nil)
        #expect(component.specifications.count == 6)
        #expect(component.specifications["Flow Rate"] == "100 CFM")
    }

    // MARK: - Health Score Tests

    @Test("Calculate health score for operational component")
    func testHealthScoreOperational() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.status = .operational

        let healthScore = component.healthScore

        #expect(healthScore >= 80)
        #expect(healthScore <= 100)
    }

    @Test("Calculate health score for degraded component")
    func testHealthScoreDegraded() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.status = .degraded

        let healthScore = component.healthScore

        #expect(healthScore >= 40)
        #expect(healthScore < 80)
    }

    @Test("Calculate health score for failed component")
    func testHealthScoreFailed() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.status = .failed

        let healthScore = component.healthScore

        #expect(healthScore < 40)
    }

    // MARK: - Maintenance Due Tests

    @Test("Maintenance not due for recently serviced component")
    func testMaintenanceNotDue() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.lastMaintenanceDate = Date() // Just maintained

        let maintenanceDue = component.isMaintenanceDue(intervalDays: 90)

        #expect(maintenanceDue == false)
    }

    @Test("Maintenance due for component past interval")
    func testMaintenanceDue() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.lastMaintenanceDate = Date().addingTimeInterval(-86400 * 100) // 100 days ago

        let maintenanceDue = component.isMaintenanceDue(intervalDays: 90)

        #expect(maintenanceDue == true)
    }

    @Test("Maintenance due for component never maintained")
    func testMaintenanceDueNeverMaintained() {
        let component = Component(
            name: "Motor",
            partNumber: "MTR-100",
            type: .mechanical
        )
        component.installationDate = Date().addingTimeInterval(-86400 * 100) // 100 days ago
        // No lastMaintenanceDate set

        let maintenanceDue = component.isMaintenanceDue(intervalDays: 90)

        #expect(maintenanceDue == true)
    }
}
