# Integration Tests Specification - visionOS Required

Integration tests verify that different components of the application work together correctly.

## Prerequisites

- visionOS Simulator or Apple Vision Pro
- Test SwiftData database
- Mock network services
- Test CAD files

---

## 1. Data Persistence Integration Tests

### Test: SwiftData CRUD Operations
```swift
import XCTest
import SwiftData
@testable import IndustrialCADCAM

@MainActor
class DataPersistenceIntegrationTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            DesignProject.self,
            Part.self,
            Assembly.self,
            User.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    func testCreateAndRetrieveProject() async throws {
        // Given: Design service with context
        let service = DesignService(modelContext: context)

        // When: Create project
        let project = try await service.createProject(
            name: "Integration Test Project",
            description: "Testing persistence"
        )

        // Then: Project can be retrieved
        let fetchedProjects = try await service.loadProjects()
        XCTAssertTrue(fetchedProjects.contains(where: { $0.id == project.id }))
    }

    func testCascadeDelete() async throws {
        // Given: Project with parts
        let project = DesignProject(name: "Test Project")
        let part = Part(name: "Test Part")
        project.addPart(part)

        context.insert(project)
        try context.save()

        // When: Delete project
        context.delete(project)
        try context.save()

        // Then: Associated parts are also deleted (cascade)
        let descriptor = FetchDescriptor<Part>()
        let remainingParts = try context.fetch(descriptor)
        XCTAssertEqual(remainingParts.count, 0)
    }
}
```

---

## 2. CloudKit Synchronization Tests

### Test: Cloud Sync Basic Flow
```swift
class CloudKitSyncTests: XCTestCase {
    var cloudSyncService: CloudSyncService!

    override func setUp() async throws {
        cloudSyncService = CloudSyncService()
    }

    func testSyncProjectToCloud() async throws {
        // Given: Local project
        let project = DesignProject(name: "Cloud Test Project")

        // When: Sync to cloud
        try await cloudSyncService.syncProject(project)

        // Then: Project exists in cloud
        let cloudProjects = try await cloudSyncService.fetchUpdates()
        XCTAssertTrue(cloudProjects.contains(where: { $0.id == project.id }))
    }

    func testConflictResolution() async throws {
        // Given: Same project modified on two devices
        let localProject = DesignProject(name: "Conflicted Project")
        localProject.modifiedDate = Date()

        let cloudProject = DesignProject(name: "Conflicted Project")
        cloudProject.id = localProject.id
        cloudProject.modifiedDate = Date().addingTimeInterval(-60) // 1 min ago

        // When: Sync conflict occurs
        let resolved = try await cloudSyncService.resolveConflict(
            local: localProject,
            remote: cloudProject
        )

        // Then: Latest modification wins
        XCTAssertEqual(resolved.id, localProject.id)
        XCTAssertGreaterThan(resolved.modifiedDate, cloudProject.modifiedDate)
    }
}
```

---

## 3. Service Integration Tests

### Test: Design Service → Manufacturing Service Flow
```swift
class ServiceIntegrationTests: XCTestCase {
    var designService: DesignService!
    var manufacturingService: ManufacturingService!

    func testDesignToManufacturingWorkflow() async throws {
        // Given: Part created in design service
        let part = try await designService.createPrimitive(
            type: .cube,
            dimensions: PrimitiveDimensions(width: 100, height: 100, depth: 100)
        )

        // When: Generate manufacturing process
        let process = try await manufacturingService.generateToolPath(
            for: part,
            processType: "CNC_Milling"
        )

        // Then: Process is created with valid parameters
        XCTAssertEqual(process.partID, part.id)
        XCTAssertGreaterThan(process.toolPaths.count, 0)
        XCTAssertGreaterThan(process.estimatedCost, 0)
    }
}
```

### Test: AI Service → Design Service Integration
```swift
func testAIOptimizationIntegration() async throws {
    // Given: Part from design service
    let part = try await designService.createPart(name: "Heavy Part")
    part.mass = 2000.0

    // When: AI suggests optimizations
    let recommendations = try await aiService.optimizeForManufacturing(part)

    // And: Apply first recommendation
    guard let recommendation = recommendations.first else {
        XCTFail("No recommendations")
        return
    }

    // Then: Part is modified accordingly
    // (Implementation depends on recommendation type)
    XCTAssertGreaterThan(recommendations.count, 0)
}
```

---

## 4. File I/O Integration Tests

### Test: Import STEP File
```swift
class FileImportIntegrationTests: XCTestCase {
    func testImportSTEPFile() async throws {
        // Given: STEP file exists
        let stepFileURL = Bundle.main.url(
            forResource: "test_part",
            withExtension: "step"
        )!

        // When: Import file
        let converter = CADFormatConverter()
        let part = try await converter.import(
            file: stepFileURL,
            format: .step
        )

        // Then: Part is created with geometry
        XCTAssertNotNil(part.geometryData)
        XCTAssertGreaterThan(part.volume, 0)
        XCTAssertGreaterThan(part.surfaceArea, 0)
    }
}
```

### Test: Export to Multiple Formats
```swift
func testExportToMultipleFormats() async throws {
    // Given: Part with geometry
    let part = Part(name: "Export Test")
    part.geometryData = createTestGeometry()

    let converter = CADFormatConverter()

    // When: Export to different formats
    let stepData = try await converter.export(part, to: .step)
    let stlData = try await converter.export(part, to: .stl)

    // Then: All exports succeed
    XCTAssertGreaterThan(stepData.count, 0)
    XCTAssertGreaterThan(stlData.count, 0)
}
```

---

## 5. PLM Integration Tests

### Test: Connect to PLM System
```swift
class PLMIntegrationTests: XCTestCase {
    var plmService: PLMIntegrationService!

    func testImportFromTeamcenter() async throws {
        // Given: PLM credentials configured
        // Note: Requires test PLM server

        // When: Import design from Teamcenter
        let project = try await plmService.importDesign(
            from: .teamcenter,
            id: "TC_PART_12345"
        )

        // Then: Project imported with all data
        XCTAssertEqual(project.partCount, 5)
        XCTAssertNotNil(project.parts.first?.geometryData)
    }

    func testExportToWindchill() async throws {
        // Given: Local project
        let project = DesignProject(name: "PLM Export Test")

        // When: Export to Windchill
        try await plmService.exportDesign(project, to: .windchill)

        // Then: Project exists in PLM
        // Verify through PLM API
    }

    func testBidirectionalSync() async throws {
        // Given: Project in both local and PLM
        let localProject = DesignProject(name: "Sync Test")
        try await plmService.exportDesign(localProject, to: .teamcenter)

        // When: Modify in PLM (simulated)
        // And: Sync changes back
        let changes = try await plmService.syncChanges([])

        // Then: Local project updated
        XCTAssertGreaterThan(changes.count, 0)
    }
}
```

---

## 6. Network Integration Tests

### Test: WebSocket Collaboration Connection
```swift
class CollaborationNetworkTests: XCTestCase {
    var networkService: CollaborationNetworkService!

    func testConnectToCollaborationServer() async throws {
        // Given: Session ID
        let sessionID = UUID()

        // When: Connect to server
        try await networkService.connect(to: sessionID)

        // Then: Connection established
        XCTAssertTrue(networkService.isConnected)
    }

    func testSendAndReceiveChanges() async throws {
        // Given: Connected to server
        try await networkService.connect(to: UUID())

        // When: Send design change
        let change = DesignChange(
            type: .partAdded,
            partID: UUID(),
            timestamp: Date()
        )
        try await networkService.sendChange(change)

        // Then: Change echoed back (in test environment)
        // Real test requires separate client
    }

    func testReconnectionAfterDisconnect() async throws {
        // Given: Active connection
        let sessionID = UUID()
        try await networkService.connect(to: sessionID)

        // When: Connection drops
        await networkService.disconnect()

        // And: Reconnect
        try await networkService.connect(to: sessionID)

        // Then: Connection restored
        XCTAssertTrue(networkService.isConnected)
    }
}
```

---

## 7. Multi-Service Workflow Tests

### Test: Complete Product Development Flow
```swift
class EndToEndWorkflowTests: XCTestCase {
    var designService: DesignService!
    var manufacturingService: ManufacturingService!
    var aiService: AIDesignService!

    func testCompleteProductDevelopmentWorkflow() async throws {
        // Step 1: Create project
        let project = try await designService.createProject(
            name: "Complete Workflow Test"
        )

        // Step 2: Design part
        let part = try await designService.createPrimitive(
            type: .cylinder,
            dimensions: PrimitiveDimensions(diameter: 50, height: 100)
        )
        project.addPart(part)

        // Step 3: AI optimization
        let optimizations = try await aiService.optimizeForManufacturing(part)
        XCTAssertGreaterThan(optimizations.count, 0)

        // Step 4: Manufacturing planning
        let process = try await manufacturingService.generateToolPath(
            for: part,
            processType: "CNC_Turning"
        )

        // Step 5: Simulate manufacturing
        let simulation = try await manufacturingService.simulateMachining(process)
        XCTAssertTrue(simulation.completed)

        // Step 6: Cost estimation
        let cost = try await manufacturingService.estimateCost(process)
        XCTAssertGreaterThan(cost.total, 0)

        // Then: Complete workflow succeeds
        XCTAssertEqual(project.partCount, 1)
        XCTAssertNotNil(simulation)
    }
}
```

---

## 8. Background Task Integration Tests

### Test: Background Simulation Processing
```swift
class BackgroundProcessingTests: XCTestCase {
    func testBackgroundSimulationProcessing() async throws {
        // Given: Heavy simulation task
        let part = createComplexPart()
        let simulationTask = SimulationTask(
            part: part,
            type: .stress,
            complexity: .high
        )

        // When: Start background processing
        let processor = BackgroundProcessor()
        let result = try await processor.processSimulation(simulationTask)

        // Then: Simulation completes without blocking main thread
        XCTAssertNotNil(result)
        XCTAssertTrue(result.passed)
    }
}
```

---

## 9. State Synchronization Tests

### Test: State Sync Across Services
```swift
class StateSyncTests: XCTestCase {
    func testAppStateConsistency() async throws {
        // Given: Multiple services accessing app state
        let appState = AppState()
        let designService = DesignService()
        let manufacturingService = ManufacturingService()

        // When: Create part in design service
        let part = try await designService.createPart(name: "Sync Test")

        // And: Select in app state
        appState.selectPart(part.id)

        // Then: Manufacturing service sees selection
        XCTAssertTrue(appState.selectedParts.contains(part.id))
    }
}
```

---

## 10. Error Recovery Integration Tests

### Test: Recover from Database Error
```swift
class ErrorRecoveryTests: XCTestCase {
    func testRecoverFromDatabaseError() async throws {
        // Given: Database becomes corrupted
        // Simulate by closing context

        // When: Attempt operation
        // Then: Graceful error handling and recovery
        // Creates new context automatically
    }

    func testRecoverFromNetworkError() async throws {
        // Given: Network operation in progress

        // When: Network fails mid-operation

        // Then: Operation queued for retry
        // Succeeds when network restored
    }
}
```

---

## Test Execution

### Run Integration Tests
```bash
# All integration tests
xcodebuild test -scheme IndustrialCADCAM \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:IndustrialCADCAMIntegrationTests

# Specific test class
xcodebuild test -scheme IndustrialCADCAM \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:IndustrialCADCAMIntegrationTests/DataPersistenceIntegrationTests
```

---

## Test Data Setup

### Required Test Assets
- Sample STEP files (simple, medium, complex)
- Sample IGES files
- Sample STL files
- Mock PLM responses
- Test user credentials
- Sample assemblies (10, 100, 1000 parts)

### Test Database
- Pre-populated with sample data
- Reset between test runs
- Isolated from production

---

## Coverage Goals

- [ ] Data persistence: 90%
- [ ] Cloud sync: 80%
- [ ] Service integration: 85%
- [ ] File I/O: 90%
- [ ] PLM integration: 70%
- [ ] Network operations: 80%
- [ ] Error recovery: 90%

---

**Status**: Specification complete
**Estimated Test Count**: 40+ integration tests
**Estimated Execution Time**: 15-20 minutes
