//
//  EquipmentTests.swift
//  FieldServiceARTests
//
//  Unit tests for Equipment model
//

import XCTest
import SwiftData
@testable import FieldServiceAR

@MainActor
final class EquipmentTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([Equipment.self, Component.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Initialization Tests

    func testEquipmentInitialization() throws {
        // Given
        let manufacturer = "Acme Corp"
        let modelNumber = "CH-5000"
        let category = EquipmentCategory.hvac
        let name = "Industrial Chiller"

        // When
        let equipment = Equipment(
            manufacturer: manufacturer,
            modelNumber: modelNumber,
            category: category,
            name: name
        )

        // Then
        XCTAssertNotNil(equipment.id)
        XCTAssertEqual(equipment.manufacturer, manufacturer)
        XCTAssertEqual(equipment.modelNumber, modelNumber)
        XCTAssertEqual(equipment.category, category)
        XCTAssertEqual(equipment.name, name)
        XCTAssertNotNil(equipment.createdAt)
        XCTAssertNotNil(equipment.updatedAt)
        XCTAssertTrue(equipment.components.isEmpty)
    }

    func testEquipmentWithSerialNumber() throws {
        // Given
        let serialNumber = "SN-123456"

        // When
        let equipment = Equipment(
            manufacturer: "Test Mfg",
            modelNumber: "TEST-001",
            serialNumber: serialNumber,
            category: .mechanical,
            name: "Test Equipment"
        )

        // Then
        XCTAssertEqual(equipment.serialNumber, serialNumber)
    }

    // MARK: - Component Relationship Tests

    func testAddComponents() throws {
        // Given
        let equipment = Equipment(
            manufacturer: "Test",
            modelNumber: "001",
            category: .hvac,
            name: "Test"
        )

        let component1 = Component(name: "Compressor", partNumber: "COMP-001")
        let component2 = Component(name: "Condenser", partNumber: "COND-001")

        // When
        equipment.components.append(component1)
        equipment.components.append(component2)

        // Then
        XCTAssertEqual(equipment.components.count, 2)
        XCTAssertTrue(equipment.components.contains(where: { $0.name == "Compressor" }))
        XCTAssertTrue(equipment.components.contains(where: { $0.name == "Condenser" }))
    }

    // MARK: - Update Tests

    func testUpdateTimestamp() throws {
        // Given
        let equipment = Equipment(
            manufacturer: "Test",
            modelNumber: "001",
            category: .hvac,
            name: "Test"
        )
        let originalUpdateTime = equipment.updatedAt

        // Wait a tiny bit to ensure time difference
        Thread.sleep(forTimeInterval: 0.01)

        // When
        equipment.update()

        // Then
        XCTAssertGreaterThan(equipment.updatedAt, originalUpdateTime)
    }

    // MARK: - Category Tests

    func testEquipmentCategories() throws {
        let categories: [EquipmentCategory] = [
            .hvac, .electrical, .plumbing,
            .mechanical, .fireSafety, .structural
        ]

        for category in categories {
            let equipment = Equipment(
                manufacturer: "Test",
                modelNumber: "001",
                category: category,
                name: "Test \(category.rawValue)"
            )

            XCTAssertEqual(equipment.category, category)
            XCTAssertFalse(category.icon.isEmpty)
            XCTAssertFalse(category.color.isEmpty)
        }
    }

    // MARK: - Persistence Tests

    func testEquipmentPersistence() throws {
        // Given
        let equipment = Equipment(
            manufacturer: "Persistence Test",
            modelNumber: "PT-001",
            category: .hvac,
            name: "Test Equipment"
        )

        // When
        modelContext.insert(equipment)
        try modelContext.save()

        // Fetch from context
        let descriptor = FetchDescriptor<Equipment>()
        let results = try modelContext.fetch(descriptor)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.manufacturer, "Persistence Test")
        XCTAssertEqual(results.first?.modelNumber, "PT-001")
    }

    // MARK: - Recognition Configuration Tests

    func testRecognitionConfiguration() throws {
        // Given
        let equipment = Equipment(
            manufacturer: "Test",
            modelNumber: "001",
            category: .hvac,
            name: "Test"
        )

        // When
        equipment.recognitionImageNames = ["image1.jpg", "image2.jpg"]
        equipment.recognitionConfidenceThreshold = 0.9

        // Then
        XCTAssertEqual(equipment.recognitionImageNames.count, 2)
        XCTAssertEqual(equipment.recognitionConfidenceThreshold, 0.9)
    }

    // MARK: - 3D Model Tests

    func testBoundingBox() throws {
        // Given
        let equipment = Equipment(
            manufacturer: "Test",
            modelNumber: "001",
            category: .hvac,
            name: "Test"
        )

        // When
        equipment.boundingBoxMin = SIMD3<Float>(0, 0, 0)
        equipment.boundingBoxMax = SIMD3<Float>(1, 1, 1)

        // Then
        XCTAssertEqual(equipment.boundingBoxMin, SIMD3<Float>(0, 0, 0))
        XCTAssertEqual(equipment.boundingBoxMax, SIMD3<Float>(1, 1, 1))
    }
}
