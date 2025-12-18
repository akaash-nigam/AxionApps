import XCTest
@testable import HideAndSeekEvolved

final class AbilityTests: XCTestCase {

    // MARK: - Cooldown Duration Tests

    func testAbility_camouflage_cooldown() {
        // Given
        let ability = Ability.camouflage(opacity: 0.1)

        // Then
        XCTAssertEqual(ability.cooldownDuration, 30)
    }

    func testAbility_sizeManipulation_cooldown() {
        // Given
        let ability = Ability.sizeManipulation(scale: 0.5)

        // Then
        XCTAssertEqual(ability.cooldownDuration, 45)
    }

    func testAbility_thermalVision_cooldown() {
        // Given
        let ability = Ability.thermalVision(range: 5.0)

        // Then
        XCTAssertEqual(ability.cooldownDuration, 20)
    }

    func testAbility_clueDetection_cooldown() {
        // Given
        let ability = Ability.clueDetection(sensitivity: 1.5)

        // Then
        XCTAssertEqual(ability.cooldownDuration, 15)
    }

    func testAbility_soundMasking_cooldown() {
        // Given
        let ability = Ability.soundMasking(effectiveness: 0.8)

        // Then
        XCTAssertEqual(ability.cooldownDuration, 25)
    }

    // MARK: - Display Name Tests

    func testAbility_displayNames() {
        XCTAssertEqual(Ability.camouflage(opacity: 0.1).displayName, "Camouflage")
        XCTAssertEqual(Ability.sizeManipulation(scale: 0.5).displayName, "Size Manipulation")
        XCTAssertEqual(Ability.thermalVision(range: 5.0).displayName, "Thermal Vision")
        XCTAssertEqual(Ability.clueDetection(sensitivity: 1.0).displayName, "Clue Detection")
        XCTAssertEqual(Ability.soundMasking(effectiveness: 0.5).displayName, "Sound Masking")
    }

    // MARK: - Description Tests

    func testAbility_camouflage_description() {
        // Given
        let ability = Ability.camouflage(opacity: 0.1)

        // When
        let description = ability.description

        // Then
        XCTAssertTrue(description.contains("90%"))
        XCTAssertTrue(description.contains("invisible"))
    }

    func testAbility_sizeManipulation_description() {
        // Given
        let ability = Ability.sizeManipulation(scale: 0.5)

        // When
        let description = ability.description

        // Then
        XCTAssertTrue(description.contains("50%"))
    }

    func testAbility_thermalVision_description() {
        // Given
        let ability = Ability.thermalVision(range: 5.0)

        // When
        let description = ability.description

        // Then
        XCTAssertTrue(description.contains("5m"))
    }

    // MARK: - Icon Tests

    func testAbility_icons() {
        XCTAssertEqual(Ability.camouflage(opacity: 0.1).icon, "eye.slash")
        XCTAssertEqual(Ability.sizeManipulation(scale: 0.5).icon, "arrow.up.and.down")
        XCTAssertEqual(Ability.thermalVision(range: 5.0).icon, "eye")
        XCTAssertEqual(Ability.clueDetection(sensitivity: 1.0).icon, "magnifyingglass")
        XCTAssertEqual(Ability.soundMasking(effectiveness: 0.5).icon, "speaker.slash")
    }

    // MARK: - Codable Tests

    func testAbility_encodingAndDecoding_camouflage() throws {
        // Given
        let original = Ability.camouflage(opacity: 0.2)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Ability.self, from: data)

        // Then
        XCTAssertEqual(original, decoded)
    }

    func testAbility_encodingAndDecoding_sizeManipulation() throws {
        // Given
        let original = Ability.sizeManipulation(scale: 1.5)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Ability.self, from: data)

        // Then
        XCTAssertEqual(original, decoded)
    }

    // MARK: - Equality Tests

    func testAbility_equality_same() {
        // Given
        let ability1 = Ability.camouflage(opacity: 0.1)
        let ability2 = Ability.camouflage(opacity: 0.1)

        // Then
        XCTAssertEqual(ability1, ability2)
    }

    func testAbility_equality_different() {
        // Given
        let ability1 = Ability.camouflage(opacity: 0.1)
        let ability2 = Ability.camouflage(opacity: 0.2)
        let ability3 = Ability.thermalVision(range: 5.0)

        // Then
        XCTAssertNotEqual(ability1, ability2)
        XCTAssertNotEqual(ability1, ability3)
    }

    // MARK: - Achievement Tests

    func testAchievement_descriptions() {
        XCTAssertFalse(Achievement.ghost.description.isEmpty)
        XCTAssertFalse(Achievement.eagleEye.description.isEmpty)
        XCTAssertFalse(Achievement.familyNight.description.isEmpty)
    }

    func testAchievement_icons() {
        XCTAssertFalse(Achievement.ghost.icon.isEmpty)
        XCTAssertFalse(Achievement.speedDemon.icon.isEmpty)
        XCTAssertFalse(Achievement.partyHost.icon.isEmpty)
    }

    func testAchievement_rawValues() {
        XCTAssertEqual(Achievement.ghost.rawValue, "Ghost")
        XCTAssertEqual(Achievement.detective.rawValue, "Detective")
        XCTAssertEqual(Achievement.helpful.rawValue, "Helpful")
    }

    func testAchievement_allCategories() {
        // Test stealth master
        XCTAssertNotNil(Achievement.ghost)
        XCTAssertNotNil(Achievement.invisible)

        // Test seeking expert
        XCTAssertNotNil(Achievement.eagleEye)
        XCTAssertNotNil(Achievement.detective)

        // Test family fun
        XCTAssertNotNil(Achievement.familyNight)
        XCTAssertNotNil(Achievement.marathon)

        // Test creative
        XCTAssertNotNil(Achievement.innovator)
        XCTAssertNotNil(Achievement.comboMaster)

        // Test social
        XCTAssertNotNil(Achievement.partyHost)
        XCTAssertNotNil(Achievement.coach)
    }
}
