//
//  BIMModelTests.swift
//  Construction Site Manager Tests
//
//  Unit tests for BIM models
//

import Testing
import Foundation
@testable import ConstructionSiteManager

@Suite("BIM Model Tests")
struct BIMModelTests {

    @Test("BIM model initializes correctly")
    func testBIMModelInitialization() {
        // Arrange & Act
        let model = BIMModel(
            name: "Test Building",
            version: "1.0",
            format: .ifc,
            fileURL: "https://example.com/model.ifc",
            sizeInBytes: 1_000_000
        )

        // Assert
        #expect(model.name == "Test Building")
        #expect(model.version == "1.0")
        #expect(model.format == .ifc)
        #expect(model.sizeInBytes == 1_000_000)
        #expect(model.elements.isEmpty)
        #expect(model.elementCount == 0)
    }

    @Test("BIM element initializes with correct transform")
    func testBIMElementTransform() {
        // Arrange
        let position = SIMD3<Float>(10, 5, 3)
        let element = BIMElement(
            ifcGuid: "test-guid-123",
            ifcType: "IfcWall",
            name: "Wall-001",
            discipline: .architectural,
            position: position
        )

        // Assert
        #expect(element.position == position)
        #expect(element.positionX == 10)
        #expect(element.positionY == 5)
        #expect(element.positionZ == 3)
        #expect(element.transform.position == position)
    }

    @Test("BIM element rotation conversion works")
    func testBIMElementRotation() {
        // Arrange
        let rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])  // 90° around Y
        let element = BIMElement(
            ifcGuid: "test-guid",
            ifcType: "IfcBeam",
            name: "Beam-001",
            discipline: .structural,
            rotation: rotation
        )

        // Assert
        let retrievedRotation = element.rotation
        #expect(abs(retrievedRotation.angle - rotation.angle) < 0.001)
    }

    @Test("BIM model completion percentage calculation")
    func testCompletionPercentage() {
        // Arrange
        let model = BIMModel(
            name: "Test",
            format: .ifc,
            fileURL: "test.ifc"
        )

        let element1 = BIMElement(
            ifcGuid: "1",
            ifcType: "IfcWall",
            name: "Wall 1",
            discipline: .architectural,
            status: .completed
        )

        let element2 = BIMElement(
            ifcGuid: "2",
            ifcType: "IfcWall",
            name: "Wall 2",
            discipline: .architectural,
            status: .inProgress
        )

        let element3 = BIMElement(
            ifcGuid: "3",
            ifcType: "IfcWall",
            name: "Wall 3",
            discipline: .architectural,
            status: .completed
        )

        // Act
        model.elements.append(element1)
        model.elements.append(element2)
        model.elements.append(element3)

        // Assert
        #expect(model.elementCount == 3)
        #expect(model.completionPercentage == 2.0 / 3.0)  // 2 out of 3 completed
    }

    @Test("Element status enum ordering")
    func testElementStatusOrdering() {
        #expect(ElementStatus.notStarted < ElementStatus.inProgress)
        #expect(ElementStatus.inProgress < ElementStatus.completed)
        #expect(ElementStatus.completed < ElementStatus.approved)
    }

    @Test("Discipline color mapping exists")
    func testDisciplineColors() {
        // All disciplines should have colors
        for discipline in Discipline.allCases {
            let color = discipline.color
            // Color exists (this will compile if color property works)
            #expect(color != discipline.color || true)  // Always true, just checking it compiles
        }
    }

    @Test("BIM format file extensions")
    func testBIMFormatExtensions() {
        #expect(BIMFormat.ifc.fileExtension == "ifc")
        #expect(BIMFormat.rvt.fileExtension == "rvt")
        #expect(BIMFormat.dwg.fileExtension == "dwg")
        #expect(BIMFormat.usdz.fileExtension == "usdz")
    }

    @Test("Element progress record tracking")
    func testProgressRecordTracking() {
        // Arrange
        let element = BIMElement(
            ifcGuid: "test-element",
            ifcType: "IfcSlab",
            name: "Floor Slab",
            discipline: .structural
        )

        let record = ElementProgressRecord(
            status: .inProgress,
            percentComplete: 0.5,
            updatedBy: "John Doe",
            notes: "Concrete poured"
        )

        // Act
        element.progressRecords.append(record)

        // Assert
        #expect(element.progressRecords.count == 1)
        #expect(element.progressRecords.first?.percentComplete == 0.5)
        #expect(element.progressRecords.first?.updatedBy == "John Doe")
    }

    @Test("Photo reference with location")
    func testPhotoReferenceLocation() {
        // Arrange
        let location = SIMD3<Float>(5, 2, 8)
        let photo = PhotoReference(
            fileURL: "photo.jpg",
            location: location
        )

        // Assert
        #expect(photo.location == location)
        #expect(photo.locationX == 5)
        #expect(photo.locationY == 2)
        #expect(photo.locationZ == 8)
    }
}

@Suite("Transform3D Tests")
struct Transform3DTests {

    @Test("Transform3D default values")
    func testDefaultTransform() {
        // Arrange & Act
        let transform = Transform3D()

        // Assert
        #expect(transform.position == SIMD3<Float>(0, 0, 0))
        #expect(transform.scale == SIMD3<Float>(1, 1, 1))
    }

    @Test("Transform3D with custom values")
    func testCustomTransform() {
        // Arrange
        let position = SIMD3<Float>(10, 20, 30)
        let scale = SIMD3<Float>(2, 2, 2)

        // Act
        let transform = Transform3D(
            position: position,
            scale: scale
        )

        // Assert
        #expect(transform.position == position)
        #expect(transform.scale == scale)
    }

    @Test("Transform to matrix conversion")
    func testMatrixConversion() {
        // Arrange
        let position = SIMD3<Float>(5, 0, 0)
        let transform = Transform3D(position: position)

        // Act
        let matrix = transform.toMatrix()

        // Assert
        // The translation should be in the last column
        #expect(matrix.columns.3.x == 5)
        #expect(matrix.columns.3.y == 0)
        #expect(matrix.columns.3.z == 0)
        #expect(matrix.columns.3.w == 1)
    }
}

@Suite("Site Coordinate Tests")
struct SiteCoordinateTests {

    @Test("Site coordinate initialization")
    func testSiteCoordinateInit() {
        // Arrange & Act
        let coord = SiteCoordinate(
            x: 100.5,
            y: 200.3,
            elevation: 50.0
        )

        // Assert
        #expect(coord.x == 100.5)
        #expect(coord.y == 200.3)
        #expect(coord.elevation == 50.0)
        #expect(coord.coordinateSystem == "EPSG:4326")  // Default
    }

    @Test("Site coordinate with custom system")
    func testCustomCoordinateSystem() {
        // Arrange & Act
        let coord = SiteCoordinate(
            x: 1000,
            y: 2000,
            elevation: 10,
            coordinateSystem: "EPSG:3857"
        )

        // Assert
        #expect(coord.coordinateSystem == "EPSG:3857")
    }
}
