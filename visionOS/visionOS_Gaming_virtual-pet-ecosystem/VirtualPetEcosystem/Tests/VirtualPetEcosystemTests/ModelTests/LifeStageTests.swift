import XCTest
@testable import VirtualPetEcosystem

final class LifeStageTests: XCTestCase {
    func testAgeRanges() {
        XCTAssertTrue(LifeStage.baby.ageRange.contains(0))
        XCTAssertTrue(LifeStage.baby.ageRange.contains(29))
        XCTAssertFalse(LifeStage.baby.ageRange.contains(30))

        XCTAssertTrue(LifeStage.youth.ageRange.contains(30))
        XCTAssertTrue(LifeStage.youth.ageRange.contains(89))
        XCTAssertFalse(LifeStage.youth.ageRange.contains(90))

        XCTAssertTrue(LifeStage.adult.ageRange.contains(90))
        XCTAssertTrue(LifeStage.adult.ageRange.contains(364))
        XCTAssertFalse(LifeStage.adult.ageRange.contains(365))

        XCTAssertTrue(LifeStage.elder.ageRange.contains(365))
        XCTAssertTrue(LifeStage.elder.ageRange.contains(1000))
    }

    func testStageForAge() {
        XCTAssertEqual(LifeStage.stage(for: 0), .baby)
        XCTAssertEqual(LifeStage.stage(for: 15), .baby)
        XCTAssertEqual(LifeStage.stage(for: 29), .baby)

        XCTAssertEqual(LifeStage.stage(for: 30), .youth)
        XCTAssertEqual(LifeStage.stage(for: 60), .youth)
        XCTAssertEqual(LifeStage.stage(for: 89), .youth)

        XCTAssertEqual(LifeStage.stage(for: 90), .adult)
        XCTAssertEqual(LifeStage.stage(for: 200), .adult)
        XCTAssertEqual(LifeStage.stage(for: 364), .adult)

        XCTAssertEqual(LifeStage.stage(for: 365), .elder)
        XCTAssertEqual(LifeStage.stage(for: 500), .elder)
    }

    func testSizeMultiplier() {
        XCTAssertEqual(LifeStage.baby.sizeMultiplier, 0.6)
        XCTAssertEqual(LifeStage.youth.sizeMultiplier, 0.8)
        XCTAssertEqual(LifeStage.adult.sizeMultiplier, 1.0)
        XCTAssertEqual(LifeStage.elder.sizeMultiplier, 0.95)

        // All multipliers should be positive
        for stage in LifeStage.allCases {
            XCTAssertGreaterThan(stage.sizeMultiplier, 0)
        }
    }

    func testBreedingCapability() {
        XCTAssertFalse(LifeStage.baby.canBreed)
        XCTAssertFalse(LifeStage.youth.canBreed)
        XCTAssertTrue(LifeStage.adult.canBreed)
        XCTAssertFalse(LifeStage.elder.canBreed)
    }

    func testCodable() throws {
        let stage = LifeStage.adult

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(stage)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LifeStage.self, from: data)

        XCTAssertEqual(stage, decoded)
    }
}
