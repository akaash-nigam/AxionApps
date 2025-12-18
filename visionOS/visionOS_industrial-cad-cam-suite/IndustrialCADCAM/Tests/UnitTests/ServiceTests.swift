import XCTest
import SwiftData
@testable import IndustrialCADCAM

@MainActor
final class DesignServiceTests: XCTestCase {
    var service: DesignService!
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
        service = DesignService(modelContext: modelContext)
    }

    override func tearDown() {
        service = nil
        modelContext = nil
        modelContainer = nil
    }

    // MARK: - Project Operations Tests

    func testCreateProject() async throws {
        // Given
        let projectName = "Test CAD Project"
        let description = "Test Description"

        // When
        let project = try await service.createProject(
            name: projectName,
            description: description
        )

        // Then
        XCTAssertEqual(project.name, projectName)
        XCTAssertEqual(project.projectDescription, description)
        XCTAssertNotNil(project.id)
    }

    func testLoadProjects() async throws {
        // Given
        _ = try await service.createProject(name: "Project 1")
        _ = try await service.createProject(name: "Project 2")
        _ = try await service.createProject(name: "Project 3")

        // When
        let projects = try await service.loadProjects()

        // Then
        XCTAssertEqual(projects.count, 3)
    }

    func testLoadProjectsSortedByModifiedDate() async throws {
        // Given
        let project1 = try await service.createProject(name: "Old Project")
        Thread.sleep(forTimeInterval: 0.02)
        let project2 = try await service.createProject(name: "New Project")

        // When
        let projects = try await service.loadProjects()

        // Then
        XCTAssertEqual(projects.first?.id, project2.id) // Newest first
        XCTAssertEqual(projects.last?.id, project1.id)
    }

    func testDeleteProject() async throws {
        // Given
        let project = try await service.createProject(name: "To Delete")
        var projects = try await service.loadProjects()
        XCTAssertEqual(projects.count, 1)

        // When
        try await service.deleteProject(project)
        projects = try await service.loadProjects()

        // Then
        XCTAssertEqual(projects.count, 0)
    }

    // MARK: - Part Operations Tests

    func testCreatePart() async throws {
        // Given
        let project = try await service.createProject(name: "Test Project")
        let partName = "Test Part"

        // When
        let part = try await service.createPart(name: partName, in: project)

        // Then
        XCTAssertEqual(part.name, partName)
        XCTAssertEqual(project.partCount, 1)
        XCTAssertTrue(project.parts.contains(where: { $0.id == part.id }))
    }

    func testCreatePrimitiveCube() async throws {
        // Given
        let dimensions = PrimitiveDimensions(
            width: 100,
            height: 100,
            depth: 100
        )

        // When
        let part = try await service.createPrimitive(
            type: .cube,
            dimensions: dimensions
        )

        // Then
        XCTAssertEqual(part.name, "Cube")
        XCTAssertEqual(part.volume, 1_000_000.0, accuracy: 0.1) // 100^3
        XCTAssertEqual(part.surfaceArea, 60_000.0, accuracy: 0.1) // 6 * 100^2
    }

    func testCreatePrimitiveCylinder() async throws {
        // Given
        let dimensions = PrimitiveDimensions(
            height: 100,
            diameter: 50
        )

        // When
        let part = try await service.createPrimitive(
            type: .cylinder,
            dimensions: dimensions
        )

        // Then
        XCTAssertEqual(part.name, "Cylinder")
        let expectedVolume = Double.pi * 25 * 25 * 100 // π * r² * h
        XCTAssertEqual(part.volume, expectedVolume, accuracy: 1.0)
    }

    func testCreatePrimitiveSphere() async throws {
        // Given
        let dimensions = PrimitiveDimensions(diameter: 60)

        // When
        let part = try await service.createPrimitive(
            type: .sphere,
            dimensions: dimensions
        )

        // Then
        XCTAssertEqual(part.name, "Sphere")
        let expectedVolume = (4.0/3.0) * Double.pi * 30 * 30 * 30
        XCTAssertEqual(part.volume, expectedVolume, accuracy: 1.0)
    }

    // MARK: - Assembly Operations Tests

    func testCreateAssembly() async throws {
        // Given
        let project = try await service.createProject(name: "Test Project")
        let assemblyName = "Test Assembly"

        // When
        let assembly = try await service.createAssembly(name: assemblyName, in: project)

        // Then
        XCTAssertEqual(assembly.name, assemblyName)
        XCTAssertEqual(project.assemblyCount, 1)
    }

    func testAddPartToAssembly() async throws {
        // Given
        let project = try await service.createProject(name: "Test Project")
        let part = try await service.createPart(name: "Part 1", in: project)
        let assembly = try await service.createAssembly(name: "Assembly 1", in: project)
        let position = Transform3D(position: Position3D(x: 100, y: 0, z: 0))

        // When
        try await service.addPartToAssembly(part, assembly: assembly, at: position)

        // Then
        XCTAssertEqual(assembly.partCount, 1)
        XCTAssertEqual(assembly.componentPositions[0].transform.position.x, 100)
    }

    // MARK: - Interference Detection Tests

    func testAnalyzeInterferenceEmptyAssembly() async throws {
        // Given
        let assembly = Assembly(name: "Empty Assembly")

        // When
        let interferences = try await service.analyzeInterference(assembly)

        // Then
        XCTAssertEqual(interferences.count, 0)
    }

    func testAnalyzeInterferenceSinglePart() async throws {
        // Given
        let assembly = Assembly(name: "Single Part Assembly")
        let part = Part(name: "Part 1")
        assembly.addPart(part)

        // When
        let interferences = try await service.analyzeInterference(assembly)

        // Then
        XCTAssertEqual(interferences.count, 0) // Single part can't interfere with itself
    }
}

@MainActor
final class ManufacturingServiceTests: XCTestCase {
    var service: ManufacturingService!

    override func setUp() {
        service = ManufacturingService()
    }

    override func tearDown() {
        service = nil
    }

    // MARK: - Tool Path Generation Tests

    func testGenerateMillingToolPath() async throws {
        // Given
        let part = Part(name: "Milled Part")
        part.volume = 50_000.0

        // When
        let process = try await service.generateToolPath(
            for: part,
            processType: "CNC_Milling"
        )

        // Then
        XCTAssertEqual(process.processType, "CNC_Milling")
        XCTAssertEqual(process.partID, part.id)
        XCTAssertGreaterThan(process.toolPaths.count, 0) // Should have roughing + finishing
        XCTAssertGreaterThan(process.cycleTime, 0)
        XCTAssertGreaterThan(process.setupTime, 0)
    }

    func testGenerateTurningToolPath() async throws {
        // Given
        let part = Part(name: "Turned Part")

        // When
        let process = try await service.generateToolPath(
            for: part,
            processType: "CNC_Turning"
        )

        // Then
        XCTAssertEqual(process.processType, "CNC_Turning")
        XCTAssertGreaterThan(process.toolPaths.count, 0)
    }

    func testGenerate3DPrintingPath() async throws {
        // Given
        let part = Part(name: "3D Printed Part")

        // When
        let process = try await service.generateToolPath(
            for: part,
            processType: "3D_Printing"
        )

        // Then
        XCTAssertEqual(process.processType, "3D_Printing")
        XCTAssertGreaterThan(process.cycleTime, 0) // 3D printing takes time
    }

    // MARK: - Cost Estimation Tests

    func testEstimateCost() async throws {
        // Given
        let process = ManufacturingProcess(
            processName: "Test Process",
            processType: "CNC_Milling",
            partID: UUID()
        )
        process.setupTime = 15.0 // minutes
        process.cycleTime = 30.0 // minutes

        // When
        let costBreakdown = try await service.estimateCost(process)

        // Then
        XCTAssertGreaterThan(costBreakdown.labor, 0)
        XCTAssertGreaterThan(costBreakdown.machine, 0)
        XCTAssertGreaterThan(costBreakdown.overhead, 0)
        XCTAssertGreaterThan(costBreakdown.total, 0)
    }

    // MARK: - Manufacturability Analysis Tests

    func testAnalyzeManufacturabilityPrecisionPart() async throws {
        // Given
        let part = Part(name: "High Precision Part")
        part.tolerance = 0.005 // Very tight tolerance

        // When
        let report = try await service.analyzeManufacturability(part)

        // Then
        XCTAssertLessThan(report.score, 100) // Should have warnings
        XCTAssertGreaterThan(report.issues.count, 0)
        XCTAssertTrue(report.issues.contains(where: { $0.category == "Tolerance" }))
    }

    func testAnalyzeManufacturabilityStandardPart() async throws {
        // Given
        let part = Part(name: "Standard Part")
        part.tolerance = 0.1 // Standard tolerance

        // When
        let report = try await service.analyzeManufacturability(part)

        // Then
        XCTAssertGreaterThanOrEqual(report.score, 90)
        XCTAssertEqual(report.issues.count, 0)
        XCTAssertEqual(report.estimatedComplexity, "Low")
    }

    // MARK: - Process Optimization Tests

    func testOptimizeProcess() async throws {
        // Given
        let process = ManufacturingProcess(
            processName: "Unoptimized Process",
            processType: "CNC_Milling",
            partID: UUID()
        )
        process.cycleTime = 100.0
        process.isOptimized = false

        // When
        let optimized = try await service.optimizeProcess(process)

        // Then
        XCTAssertTrue(optimized.isOptimized)
        XCTAssertLessThan(optimized.cycleTime, 100.0) // Should be faster
        XCTAssertGreaterThan(optimized.optimizationScore, 0)
    }

    // MARK: - Simulation Tests

    func testSimulateMachining() async throws {
        // Given
        let process = ManufacturingProcess(
            processName: "Test Machining",
            processType: "CNC_Milling",
            partID: UUID()
        )
        let toolPath1 = ToolPathData(
            name: "Roughing",
            toolType: "EndMill",
            toolDiameter: 12.0,
            feedRate: 1000,
            spindleSpeed: 8000,
            depthOfCut: 2.0,
            coordinates: [],
            estimatedTime: 15
        )
        let toolPath2 = ToolPathData(
            name: "Finishing",
            toolType: "EndMill",
            toolDiameter: 6.0,
            feedRate: 500,
            spindleSpeed: 12000,
            depthOfCut: 0.5,
            coordinates: [],
            estimatedTime: 25
        )
        process.addToolPath(toolPath1)
        process.addToolPath(toolPath2)

        // When
        let simulation = try await service.simulateMachining(process)

        // Then
        XCTAssertEqual(simulation.steps.count, 2)
        XCTAssertTrue(simulation.completed)
        XCTAssertGreaterThan(simulation.totalTime, 0)
    }
}

@MainActor
final class AIServiceTests: XCTestCase {
    var service: AIDesignService!

    override func setUp() {
        service = AIDesignService()
    }

    override func tearDown() {
        service = nil
    }

    // MARK: - Generative Design Tests

    func testGenerateDesignOptions() async throws {
        // Given
        let requirements = DesignRequirements(
            targetWeight: 500.0,
            targetStrength: 200.0,
            targetCost: 100.0,
            constraints: ["Must fit in 100x100x50mm envelope"]
        )

        // When
        let options = try await service.generateDesignOptions(from: requirements)

        // Then
        XCTAssertGreaterThan(options.count, 0)
        XCTAssertLessThanOrEqual(options.count, 5)
        XCTAssertTrue(options.allSatisfy { $0.score > 0 })
        // Options should be sorted by score (best first)
        if options.count > 1 {
            XCTAssertGreaterThanOrEqual(options[0].score, options[1].score)
        }
    }

    func testDesignOptionsPerformanceMetrics() async throws {
        // Given
        let requirements = DesignRequirements(
            targetWeight: 1000.0,
            targetStrength: 300.0,
            targetCost: 200.0,
            constraints: []
        )

        // When
        let options = try await service.generateDesignOptions(from: requirements)

        // Then
        for option in options {
            // Performance should be within reasonable range of targets
            XCTAssertGreaterThan(option.performance.weight, 0)
            XCTAssertGreaterThan(option.performance.strength, 0)
            XCTAssertGreaterThan(option.performance.cost, 0)
        }
    }

    // MARK: - Manufacturing Optimization Tests

    func testOptimizeForManufacturing() async throws {
        // Given
        let part = Part(name: "Heavy Part")
        part.mass = 2000.0 // 2kg - heavy part
        part.materialType = "metal"

        // When
        let recommendations = try await service.optimizeForManufacturing(part)

        // Then
        XCTAssertGreaterThan(recommendations.count, 0)
        // Should suggest topology optimization for heavy metal parts
        XCTAssertTrue(recommendations.contains(where: { $0.type == .weightReduction }))
    }

    func testOptimizeForManufacturingTightTolerance() async throws {
        // Given
        let part = Part(name: "Precision Part")
        part.tolerance = 0.01 // Very tight

        // When
        let recommendations = try await service.optimizeForManufacturing(part)

        // Then
        XCTAssertGreaterThan(recommendations.count, 0)
        // Should suggest cost reduction by relaxing tolerance
        XCTAssertTrue(recommendations.contains(where: { $0.type == .costReduction }))
    }

    // MARK: - Quality Prediction Tests

    func testPredictQualityIssuesHighSpeed() async throws {
        // Given
        let process = ManufacturingProcess(
            processName: "High Speed Process",
            processType: "CNC_Milling",
            partID: UUID()
        )
        let aggressiveToolPath = ToolPathData(
            name: "Aggressive Cut",
            toolType: "EndMill",
            toolDiameter: 6.0,
            feedRate: 2000,
            spindleSpeed: 15000, // Very high
            depthOfCut: 3.0, // Deep cut
            coordinates: [],
            estimatedTime: 10
        )
        process.addToolPath(aggressiveToolPath)

        // When
        let predictions = try await service.predictQualityIssues(process)

        // Then
        XCTAssertGreaterThan(predictions.count, 0)
        XCTAssertTrue(predictions.contains(where: { $0.type == "Chatter" }))
    }

    // MARK: - Material Suggestions Tests

    func testSuggestMaterialAlternatives() async throws {
        // Given
        let part = Part(name: "Test Part", materialName: "Aluminum 6061-T6")
        let requirements = MaterialRequirements(
            minStrength: 200.0,
            maxWeight: 500.0,
            maxCost: 100.0,
            environment: "normal"
        )

        // When
        let suggestions = try await service.suggestMaterialAlternatives(
            for: part,
            requirements: requirements
        )

        // Then
        XCTAssertGreaterThan(suggestions.count, 0)
        // Should not suggest current material
        XCTAssertFalse(suggestions.contains(where: { $0.materialName == part.materialName }))
        // All suggestions should have impact metrics
        XCTAssertTrue(suggestions.allSatisfy { $0.costImpact > 0 })
    }

    // MARK: - Design Analysis Tests

    func testAnalyzeDesign() async throws {
        // Given
        let part = Part(name: "Test Part")
        part.volume = 150_000.0 // 150 cm³ - large part
        part.surfaceArea = 30_000.0

        // When
        let analysis = try await service.analyzeDesign(part)

        // Then
        XCTAssertGreaterThan(analysis.overallScore, 0)
        XCTAssertLessThanOrEqual(analysis.overallScore, 100)
        XCTAssertGreaterThan(analysis.suggestions.count, 0)
        XCTAssertGreaterThan(analysis.strengths.count, 0)
    }
}

// MARK: - Run Tests
// Run with: swift test
// Or in Xcode: Cmd+U
