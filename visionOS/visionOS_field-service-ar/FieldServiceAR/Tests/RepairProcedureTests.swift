//
// RepairProcedureTests.swift
// Field Service AR Assistant
//
// Created by Claude on 2025-01-17.
//

import Testing
import Foundation
@testable import FieldServiceAR

@MainActor
final class RepairProcedureTests {

    // MARK: - Initialization Tests

    @Test("Repair procedure initializes correctly")
    func testInitialization() throws {
        let procedure = RepairProcedure(
            title: "Replace HVAC Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        #expect(procedure.id != nil)
        #expect(procedure.title == "Replace HVAC Filter")
        #expect(procedure.category == .preventiveMaintenance)
        #expect(procedure.estimatedDuration == 1800)
        #expect(procedure.difficulty == .easy)
        #expect(procedure.steps.isEmpty)
        #expect(procedure.requiredTools.isEmpty)
        #expect(procedure.requiredParts.isEmpty)
    }

    // MARK: - Step Management Tests

    @Test("Add step to procedure")
    func testAddStep() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        let step = ProcedureStep(
            order: 1,
            title: "Open access panel",
            description: "Remove the four screws securing the access panel",
            estimatedTime: 300
        )

        procedure.steps.append(step)

        #expect(procedure.steps.count == 1)
        #expect(procedure.steps.first?.title == "Open access panel")
    }

    @Test("Steps maintain correct order")
    func testStepOrder() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        let step1 = ProcedureStep(
            order: 1,
            title: "Step 1",
            description: "First step",
            estimatedTime: 300
        )

        let step2 = ProcedureStep(
            order: 2,
            title: "Step 2",
            description: "Second step",
            estimatedTime: 300
        )

        let step3 = ProcedureStep(
            order: 3,
            title: "Step 3",
            description: "Third step",
            estimatedTime: 300
        )

        procedure.steps = [step1, step2, step3]

        #expect(procedure.steps[0].order == 1)
        #expect(procedure.steps[1].order == 2)
        #expect(procedure.steps[2].order == 3)
    }

    // MARK: - Tool Management Tests

    @Test("Add required tool to procedure")
    func testAddRequiredTool() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        procedure.requiredTools.append("Phillips screwdriver")

        #expect(procedure.requiredTools.count == 1)
        #expect(procedure.requiredTools.first == "Phillips screwdriver")
    }

    @Test("Multiple tools tracked correctly")
    func testMultipleTools() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        procedure.requiredTools = [
            "Phillips screwdriver",
            "Flathead screwdriver",
            "Adjustable wrench",
            "Flashlight"
        ]

        #expect(procedure.requiredTools.count == 4)
        #expect(procedure.requiredTools.contains("Adjustable wrench"))
    }

    // MARK: - Parts Management Tests

    @Test("Add required part to procedure")
    func testAddRequiredPart() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        procedure.requiredParts.append("HEPA Filter Model XYZ-123")

        #expect(procedure.requiredParts.count == 1)
        #expect(procedure.requiredParts.first == "HEPA Filter Model XYZ-123")
    }

    // MARK: - Category Tests

    @Test("Preventive maintenance category")
    func testPreventiveMaintenanceCategory() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        #expect(procedure.category == .preventiveMaintenance)
    }

    @Test("Repair category")
    func testRepairCategory() {
        let procedure = RepairProcedure(
            title: "Fix Compressor",
            category: .repair,
            estimatedDuration: 7200,
            difficulty: .hard
        )

        #expect(procedure.category == .repair)
    }

    @Test("Installation category")
    func testInstallationCategory() {
        let procedure = RepairProcedure(
            title: "Install New Unit",
            category: .installation,
            estimatedDuration: 10800,
            difficulty: .hard
        )

        #expect(procedure.category == .installation)
    }

    @Test("Diagnostic category")
    func testDiagnosticCategory() {
        let procedure = RepairProcedure(
            title: "Diagnose Issue",
            category: .diagnostic,
            estimatedDuration: 3600,
            difficulty: .medium
        )

        #expect(procedure.category == .diagnostic)
    }

    // MARK: - Difficulty Tests

    @Test("Easy difficulty level")
    func testEasyDifficulty() {
        let procedure = RepairProcedure(
            title: "Replace Filter",
            category: .preventiveMaintenance,
            estimatedDuration: 1800,
            difficulty: .easy
        )

        #expect(procedure.difficulty == .easy)
    }

    @Test("Medium difficulty level")
    func testMediumDifficulty() {
        let procedure = RepairProcedure(
            title: "Replace Component",
            category: .repair,
            estimatedDuration: 3600,
            difficulty: .medium
        )

        #expect(procedure.difficulty == .medium)
    }

    @Test("Hard difficulty level")
    func testHardDifficulty() {
        let procedure = RepairProcedure(
            title: "Rebuild Motor",
            category: .repair,
            estimatedDuration: 7200,
            difficulty: .hard
        )

        #expect(procedure.difficulty == .hard)
    }

    // MARK: - Duration Tests

    @Test("Short duration procedures")
    func testShortDuration() {
        let procedure = RepairProcedure(
            title: "Quick Check",
            category: .diagnostic,
            estimatedDuration: 300,
            difficulty: .easy
        )

        #expect(procedure.estimatedDuration == 300) // 5 minutes
    }

    @Test("Long duration procedures")
    func testLongDuration() {
        let procedure = RepairProcedure(
            title: "Full Rebuild",
            category: .repair,
            estimatedDuration: 14400,
            difficulty: .hard
        )

        #expect(procedure.estimatedDuration == 14400) // 4 hours
    }

    // MARK: - Complete Procedure Tests

    @Test("Complete procedure with all components")
    func testCompleteProcedure() {
        let procedure = RepairProcedure(
            title: "Replace HVAC Compressor",
            category: .repair,
            estimatedDuration: 7200,
            difficulty: .hard
        )

        // Add steps
        procedure.steps = [
            ProcedureStep(
                order: 1,
                title: "Power off system",
                description: "Turn off main breaker",
                estimatedTime: 300
            ),
            ProcedureStep(
                order: 2,
                title: "Remove old compressor",
                description: "Disconnect and remove",
                estimatedTime: 3600
            ),
            ProcedureStep(
                order: 3,
                title: "Install new compressor",
                description: "Connect and secure",
                estimatedTime: 3000
            )
        ]

        // Add tools
        procedure.requiredTools = [
            "Socket wrench set",
            "Multimeter",
            "Refrigerant recovery machine"
        ]

        // Add parts
        procedure.requiredParts = [
            "Compressor Model ABC-456",
            "Gasket set",
            "Refrigerant R-410A"
        ]

        // Verify
        #expect(procedure.steps.count == 3)
        #expect(procedure.requiredTools.count == 3)
        #expect(procedure.requiredParts.count == 3)
        #expect(procedure.category == .repair)
        #expect(procedure.difficulty == .hard)

        // Verify step ordering
        let totalStepTime = procedure.steps.reduce(0) { $0 + $1.estimatedTime }
        #expect(totalStepTime == 6900) // 300 + 3600 + 3000
    }
}
