import XCTest
import SwiftData
@testable import IndustrialCADCAM

@MainActor
final class DesignProjectTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            DesignProject.self,
            Part.self,
            Assembly.self
        ])

        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Initialization Tests

    func testProjectInitialization() {
        // Given
        let name = "Test Project"
        let description = "Test Description"

        // When
        let project = DesignProject(name: name, description: description)

        // Then
        XCTAssertEqual(project.name, name)
        XCTAssertEqual(project.projectDescription, description)
        XCTAssertEqual(project.units, "metric")
        XCTAssertEqual(project.status, "draft")
        XCTAssertEqual(project.partCount, 0)
        XCTAssertEqual(project.assemblyCount, 0)
        XCTAssertNotNil(project.id)
        XCTAssertNotNil(project.createdDate)
    }

    func testProjectWithImperialUnits() {
        // Given
        let project = DesignProject(name: "Imperial Project", units: "imperial")

        // Then
        XCTAssertEqual(project.units, "imperial")
    }

    // MARK: - Part Management Tests

    func testAddPartToProject() {
        // Given
        let project = DesignProject(name: "Test Project")
        let part = Part(name: "Test Part")
        let initialModifiedDate = project.modifiedDate

        // When
        project.addPart(part)

        // Then
        XCTAssertEqual(project.partCount, 1)
        XCTAssertTrue(project.parts.contains(where: { $0.id == part.id }))
        XCTAssertGreaterThan(project.modifiedDate, initialModifiedDate)
    }

    func testRemovePartFromProject() {
        // Given
        let project = DesignProject(name: "Test Project")
        let part = Part(name: "Test Part")
        project.addPart(part)

        // When
        project.removePart(part)

        // Then
        XCTAssertEqual(project.partCount, 0)
        XCTAssertFalse(project.parts.contains(where: { $0.id == part.id }))
    }

    func testAddMultiplePartsToProject() {
        // Given
        let project = DesignProject(name: "Test Project")
        let parts = [
            Part(name: "Part 1"),
            Part(name: "Part 2"),
            Part(name: "Part 3")
        ]

        // When
        parts.forEach { project.addPart($0) }

        // Then
        XCTAssertEqual(project.partCount, 3)
    }

    // MARK: - Assembly Management Tests

    func testAddAssemblyToProject() {
        // Given
        let project = DesignProject(name: "Test Project")
        let assembly = Assembly(name: "Test Assembly")

        // When
        project.addAssembly(assembly)

        // Then
        XCTAssertEqual(project.assemblyCount, 1)
        XCTAssertTrue(project.assemblies.contains(where: { $0.id == assembly.id }))
    }

    // MARK: - Touch Method Tests

    func testTouchUpdatesModifiedDate() throws {
        // Given
        let project = DesignProject(name: "Test Project")
        let initialDate = project.modifiedDate

        // Wait a tiny bit to ensure time difference
        Thread.sleep(forTimeInterval: 0.01)

        // When
        project.touch()

        // Then
        XCTAssertGreaterThan(project.modifiedDate, initialDate)
    }
}

@MainActor
final class PartTests: XCTestCase {

    // MARK: - Initialization Tests

    func testPartInitialization() {
        // Given
        let name = "Test Part"
        let materialName = "Steel 304"

        // When
        let part = Part(name: name, materialName: materialName)

        // Then
        XCTAssertEqual(part.name, name)
        XCTAssertEqual(part.materialName, materialName)
        XCTAssertEqual(part.revision, "A")
        XCTAssertEqual(part.status, "draft")
        XCTAssertEqual(part.materialType, "metal")
        XCTAssertNotNil(part.id)
        XCTAssertFalse(part.partNumber.isEmpty)
    }

    func testPartNumberGeneration() {
        // Given & When
        let part1 = Part(name: "Part 1")
        let part2 = Part(name: "Part 2")

        // Then
        XCTAssertNotEqual(part1.partNumber, part2.partNumber)
        XCTAssertTrue(part1.partNumber.hasPrefix("PART-"))
    }

    func testCustomPartNumber() {
        // Given
        let customPartNumber = "CUSTOM-123"

        // When
        let part = Part(name: "Test", partNumber: customPartNumber)

        // Then
        XCTAssertEqual(part.partNumber, customPartNumber)
    }

    // MARK: - Mass Calculation Tests

    func testMassCalculation() {
        // Given
        let part = Part(name: "Aluminum Block")
        part.volume = 1000.0 // 1000 mm³ = 1 cm³
        part.density = 2.7 // g/cm³ (Aluminum)

        // When
        let mass = part.calculateMass()

        // Then
        XCTAssertEqual(mass, 2.7, accuracy: 0.01) // 2.7 grams
    }

    func testMassCalculationWithLargeVolume() {
        // Given
        let part = Part(name: "Steel Block")
        part.volume = 100_000.0 // 100 cm³
        part.density = 7.85 // g/cm³ (Steel)

        // When
        let mass = part.calculateMass()

        // Then
        XCTAssertEqual(mass, 785.0, accuracy: 0.1) // 785 grams
    }

    // MARK: - Geometry Update Tests

    func testUpdateGeometry() {
        // Given
        let part = Part(name: "Test Part")
        let geometryData = Data([0x01, 0x02, 0x03])
        let initialModifiedDate = part.modifiedDate

        Thread.sleep(forTimeInterval: 0.01)

        // When
        part.updateGeometry(geometryData)

        // Then
        XCTAssertEqual(part.geometryData, geometryData)
        XCTAssertGreaterThan(part.modifiedDate, initialModifiedDate)
    }

    // MARK: - Property Validation Tests

    func testDefaultTolerance() {
        // Given & When
        let part = Part(name: "Precision Part")

        // Then
        XCTAssertEqual(part.tolerance, 0.05) // Default ±0.05mm
    }

    func testDefaultSurfaceFinish() {
        // Given & When
        let part = Part(name: "Machined Part")

        // Then
        XCTAssertEqual(part.surfaceFinish, "Ra 1.6 μm")
    }

    func testDefaultDensity() {
        // Given & When
        let part = Part(name: "Aluminum Part", materialName: "Aluminum 6061-T6")

        // Then
        XCTAssertEqual(part.density, 2.7, accuracy: 0.01) // Aluminum density
    }
}

@MainActor
final class AssemblyTests: XCTestCase {

    // MARK: - Initialization Tests

    func testAssemblyInitialization() {
        // Given
        let name = "Test Assembly"

        // When
        let assembly = Assembly(name: name)

        // Then
        XCTAssertEqual(assembly.name, name)
        XCTAssertEqual(assembly.revision, "A")
        XCTAssertEqual(assembly.status, "draft")
        XCTAssertEqual(assembly.partCount, 0)
        XCTAssertFalse(assembly.hasInterferences)
        XCTAssertEqual(assembly.interferenceCount, 0)
        XCTAssertNotNil(assembly.id)
        XCTAssertTrue(assembly.assemblyNumber.hasPrefix("ASSY-"))
    }

    // MARK: - Component Management Tests

    func testAddPartToAssembly() {
        // Given
        let assembly = Assembly(name: "Test Assembly")
        let part = Part(name: "Test Part")
        let transform = Transform3D(
            position: Position3D(x: 10, y: 20, z: 30)
        )

        // When
        assembly.addPart(part, at: transform)

        // Then
        XCTAssertEqual(assembly.partCount, 1)
        XCTAssertEqual(assembly.componentPositions.count, 1)
        XCTAssertEqual(assembly.componentPositions[0].partID, part.id)
        XCTAssertEqual(assembly.componentPositions[0].transform.position.x, 10)
    }

    func testAddMultiplePartsToAssembly() {
        // Given
        let assembly = Assembly(name: "Complex Assembly")
        let parts = [
            Part(name: "Part 1"),
            Part(name: "Part 2"),
            Part(name: "Part 3")
        ]

        // When
        parts.forEach { assembly.addPart($0) }

        // Then
        XCTAssertEqual(assembly.partCount, 3)
        XCTAssertEqual(assembly.componentPositions.count, 3)
    }

    func testRemovePartFromAssembly() {
        // Given
        let assembly = Assembly(name: "Test Assembly")
        let part = Part(name: "Test Part")
        assembly.addPart(part)

        // When
        assembly.removePart(part)

        // Then
        XCTAssertEqual(assembly.partCount, 0)
        XCTAssertEqual(assembly.componentPositions.count, 0)
    }

    // MARK: - Transform Tests

    func testDefaultTransform() {
        // Given & When
        let transform = Transform3D()

        // Then
        XCTAssertEqual(transform.position.x, 0)
        XCTAssertEqual(transform.position.y, 0)
        XCTAssertEqual(transform.position.z, 0)
        XCTAssertEqual(transform.rotation.x, 0)
        XCTAssertEqual(transform.rotation.y, 0)
        XCTAssertEqual(transform.rotation.z, 0)
        XCTAssertEqual(transform.scale.x, 1.0)
        XCTAssertEqual(transform.scale.y, 1.0)
        XCTAssertEqual(transform.scale.z, 1.0)
    }

    func testCustomTransform() {
        // Given & When
        let transform = Transform3D(
            position: Position3D(x: 100, y: 200, z: 300),
            rotation: Rotation3D(x: 0.5, y: 1.0, z: 1.5),
            scale: Scale3D(x: 2.0, y: 2.0, z: 2.0)
        )

        // Then
        XCTAssertEqual(transform.position.x, 100)
        XCTAssertEqual(transform.position.y, 200)
        XCTAssertEqual(transform.position.z, 300)
        XCTAssertEqual(transform.rotation.x, 0.5)
        XCTAssertEqual(transform.scale.x, 2.0)
    }

    // MARK: - Modified Date Tests

    func testTouchUpdatesModifiedDate() {
        // Given
        let assembly = Assembly(name: "Test Assembly")
        let initialDate = assembly.modifiedDate

        Thread.sleep(forTimeInterval: 0.01)

        // When
        assembly.touch()

        // Then
        XCTAssertGreaterThan(assembly.modifiedDate, initialDate)
    }
}

// MARK: - Run Tests
// These tests can be run with: swift test
// Or in Xcode: Cmd+U
