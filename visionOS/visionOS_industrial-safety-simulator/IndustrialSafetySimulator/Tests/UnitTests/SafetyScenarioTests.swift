import Testing
import Foundation
@testable import IndustrialSafetySimulator

@Suite("SafetyScenario Model Tests")
struct SafetyScenarioTests {

    // MARK: - Initialization Tests

    @Test("Scenario initializes with required properties")
    func testScenarioInitialization() {
        // Arrange
        let name = "Factory Floor Hazards"
        let description = "Identify hazards in a manufacturing environment"
        let environment = EnvironmentType.factoryFloor
        let scenePath = "Scenes/FactoryFloor"

        // Act
        let scenario = SafetyScenario(
            name: name,
            description: description,
            environment: environment,
            realityKitScene: scenePath
        )

        // Assert
        #expect(scenario.name == name)
        #expect(scenario.scenarioDescription == description)
        #expect(scenario.environment == environment)
        #expect(scenario.realityKitScene == scenePath)
        #expect(scenario.passingScore == 70.0, "Default passing score should be 70%")
    }

    @Test("Scenario accepts custom passing score")
    func testCustomPassingScore() {
        // Arrange
        let customScore = 85.0

        // Act
        let scenario = SafetyScenario(
            name: "Advanced Test",
            description: "Higher difficulty",
            environment: .factoryFloor,
            realityKitScene: "Advanced",
            passingScore: customScore
        )

        // Assert
        #expect(scenario.passingScore == customScore)
    }

    // MARK: - Environment Type Tests

    @Test("All environment types have background images")
    func testEnvironmentBackgrounds() {
        let environments: [EnvironmentType] = [
            .factoryFloor,
            .constructionSite,
            .chemicalPlant,
            .warehouse,
            .laboratorychemicalLab,
            .confinedSpace,
            .heightsScaffolding,
            .electricalRoom,
            .oilAndGas,
            .miningOperation
        ]

        for env in environments {
            #expect(env.backgroundImage.isEmpty == false, "Environment \(env) should have a background image")
        }
    }

    // MARK: - Hazard Tests

    @Test("Hazard initializes with all properties")
    func testHazardInitialization() {
        // Arrange
        let type = HazardType.electrical
        let severity = SeverityLevel.high
        let name = "Exposed Wire"
        let description = "Live electrical wire exposed"
        let location = SIMD3<Float>(1.0, 0.5, 2.0)
        let radius: Float = 2.5

        // Act
        let hazard = Hazard(
            type: type,
            severity: severity,
            name: name,
            description: description,
            location: location,
            radius: radius
        )

        // Assert
        #expect(hazard.type == type)
        #expect(hazard.severity == severity)
        #expect(hazard.name == name)
        #expect(hazard.hazardDescription == description)
        #expect(hazard.location == location)
        #expect(hazard.radius == radius)
        #expect(hazard.isActive == true, "Hazard should be active by default")
        #expect(hazard.isDetected == false, "Hazard should not be detected initially")
    }

    @Test("Hazard proximity detection works correctly", arguments: [
        (SIMD3<Float>(0, 0, 0), SIMD3<Float>(1, 0, 0), 2.0, true),   // Within radius
        (SIMD3<Float>(0, 0, 0), SIMD3<Float>(5, 0, 0), 2.0, false),  // Outside radius
        (SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 2, 0), 2.5, true),   // At edge
        (SIMD3<Float>(1, 1, 1), SIMD3<Float>(1, 1, 1), 1.0, true),   // Same position
    ])
    func testHazardProximityDetection(
        hazardLocation: SIMD3<Float>,
        userPosition: SIMD3<Float>,
        radius: Float,
        shouldBeNear: Bool
    ) {
        // Arrange
        let hazard = Hazard(
            type: .electrical,
            severity: .high,
            name: "Test Hazard",
            description: "Test",
            location: hazardLocation,
            radius: radius
        )

        // Act
        let isNear = hazard.isNearPosition(userPosition)

        // Assert
        #expect(isNear == shouldBeNear)
    }

    @Test("Hazard location getter and setter work correctly")
    func testHazardLocationProperty() {
        // Arrange
        let initialLocation = SIMD3<Float>(1, 2, 3)
        let newLocation = SIMD3<Float>(4, 5, 6)

        var hazard = Hazard(
            type: .chemical,
            severity: .medium,
            name: "Spill",
            description: "Chemical spill",
            location: initialLocation
        )

        // Act
        #expect(hazard.location == initialLocation)

        hazard.location = newLocation

        // Assert
        #expect(hazard.location == newLocation)
        #expect(hazard.locationX == 4.0)
        #expect(hazard.locationY == 5.0)
        #expect(hazard.locationZ == 6.0)
    }

    // MARK: - Hazard Type Tests

    @Test("All hazard types have colors")
    func testHazardTypeColors() {
        let types: [HazardType] = [
            .electrical, .chemical, .mechanical, .fall, .fire,
            .explosion, .radiation, .biological, .ergonomic, .noise,
            .heat, .cold, .slipTrip, .caughtBetween, .struckBy
        ]

        for type in types {
            #expect(type.color.isEmpty == false, "Hazard type \(type) should have a color")
        }
    }

    // MARK: - Severity Level Tests

    @Test("Severity levels are correctly ordered", arguments: [
        (SeverityLevel.low, SeverityLevel.medium, true),
        (SeverityLevel.medium, SeverityLevel.high, true),
        (SeverityLevel.high, SeverityLevel.critical, true),
        (SeverityLevel.critical, SeverityLevel.catastrophic, true),
        (SeverityLevel.catastrophic, SeverityLevel.low, false),
    ])
    func testSeverityLevelComparison(level1: SeverityLevel, level2: SeverityLevel, level1ShouldBeLess: Bool) {
        // Assert
        #expect((level1 < level2) == level1ShouldBeLess)
    }

    @Test("All severity levels have colors")
    func testSeverityLevelColors() {
        let levels: [SeverityLevel] = [.low, .medium, .high, .critical, .catastrophic]

        for level in levels {
            #expect(level.color.isEmpty == false, "Severity level \(level) should have a color")
        }
    }

    // MARK: - PPE Type Tests

    @Test("All PPE types have icons")
    func testPPETypeIcons() {
        let ppeTypes: [PPEType] = [
            .hardHat, .safetyGlasses, .hearingProtection, .respirator,
            .gloves, .safetyBoots, .harness, .vest, .faceshield, .chemicalSuit
        ]

        for ppe in ppeTypes {
            #expect(ppe.icon.isEmpty == false, "PPE type \(ppe) should have an icon")
        }
    }

    // MARK: - Edge Cases

    @Test("Hazard with zero radius")
    func testZeroRadiusHazard() {
        // Arrange
        let hazard = Hazard(
            type: .fire,
            severity: .low,
            name: "Point Hazard",
            description: "Zero radius test",
            location: SIMD3<Float>(0, 0, 0),
            radius: 0.0
        )

        // Act & Assert
        #expect(hazard.isNearPosition(SIMD3<Float>(0, 0, 0)) == true, "Same position should be near")
        #expect(hazard.isNearPosition(SIMD3<Float>(0.1, 0, 0)) == false, "Any distance should be outside zero radius")
    }

    @Test("Hazard with very large radius")
    func testLargeRadiusHazard() {
        // Arrange
        let hazard = Hazard(
            type: .explosion,
            severity: .catastrophic,
            name: "Blast Zone",
            description: "Large area hazard",
            location: SIMD3<Float>(0, 0, 0),
            radius: 1000.0
        )

        // Act & Assert
        #expect(hazard.isNearPosition(SIMD3<Float>(500, 0, 0)) == true, "Position within large radius")
        #expect(hazard.isNearPosition(SIMD3<Float>(1001, 0, 0)) == false, "Position outside large radius")
    }

    @Test("Hazard with negative coordinates")
    func testNegativeCoordinateHazard() {
        // Arrange
        let location = SIMD3<Float>(-10, -5, -15)
        let hazard = Hazard(
            type: .fall,
            severity: .high,
            name: "Underground Hazard",
            description: "Below ground level",
            location: location
        )

        // Assert
        #expect(hazard.location == location)
        #expect(hazard.locationX == -10.0)
        #expect(hazard.locationY == -5.0)
        #expect(hazard.locationZ == -15.0)
    }
}

@Suite("Scenario Collection Tests")
struct ScenarioCollectionTests {

    @Test("Scenario can have multiple hazards")
    func testMultipleHazards() {
        // Arrange
        let scenario = SafetyScenario(
            name: "Multi-Hazard Test",
            description: "Multiple hazards",
            environment: .factoryFloor,
            realityKitScene: "MultiHazard"
        )

        let hazard1 = Hazard(
            type: .electrical,
            severity: .high,
            name: "Wire",
            description: "Exposed wire",
            location: SIMD3<Float>(1, 0, 0)
        )

        let hazard2 = Hazard(
            type: .chemical,
            severity: .medium,
            name: "Spill",
            description: "Chemical spill",
            location: SIMD3<Float>(-1, 0, 0)
        )

        // Act
        scenario.hazards.append(contentsOf: [hazard1, hazard2])

        // Assert
        #expect(scenario.hazards.count == 2)
    }

    @Test("Scenario can have procedures")
    func testScenarioProcedures() {
        // Arrange
        let scenario = SafetyScenario(
            name: "Lockout/Tagout",
            description: "Energy isolation",
            environment: .factoryFloor,
            realityKitScene: "LOTO"
        )

        let procedures = [
            "Notify affected employees",
            "Shut down equipment",
            "Isolate energy sources",
            "Apply lockout devices",
            "Verify isolation"
        ]

        // Act
        scenario.correctProcedures = procedures

        // Assert
        #expect(scenario.correctProcedures.count == 5)
        #expect(scenario.correctProcedures.contains("Apply lockout devices"))
    }
}
