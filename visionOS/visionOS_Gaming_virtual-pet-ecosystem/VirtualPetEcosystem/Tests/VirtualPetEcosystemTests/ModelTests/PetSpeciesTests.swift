import XCTest
@testable import VirtualPetEcosystem

final class PetSpeciesTests: XCTestCase {
    func testAllSpeciesAreAvailable() {
        XCTAssertEqual(PetSpecies.allCases.count, 5)
        XCTAssertTrue(PetSpecies.allCases.contains(.luminos))
        XCTAssertTrue(PetSpecies.allCases.contains(.fluffkins))
        XCTAssertTrue(PetSpecies.allCases.contains(.crystalites))
        XCTAssertTrue(PetSpecies.allCases.contains(.aquarians))
        XCTAssertTrue(PetSpecies.allCases.contains(.shadowlings))
    }

    func testDisplayNames() {
        XCTAssertEqual(PetSpecies.luminos.displayName, "Luminos")
        XCTAssertEqual(PetSpecies.fluffkins.displayName, "Fluffkins")
        XCTAssertEqual(PetSpecies.crystalites.displayName, "Crystalites")
        XCTAssertEqual(PetSpecies.aquarians.displayName, "Aquarians")
        XCTAssertEqual(PetSpecies.shadowlings.displayName, "Shadowlings")
    }

    func testDescriptions() {
        XCTAssertFalse(PetSpecies.luminos.description.isEmpty)
        XCTAssertFalse(PetSpecies.fluffkins.description.isEmpty)
        XCTAssertTrue(PetSpecies.luminos.description.contains("light") || PetSpecies.luminos.description.contains("Light"))
        XCTAssertTrue(PetSpecies.fluffkins.description.contains("Furry"))
    }

    func testBaseMass() {
        // Luminos should be lightest
        XCTAssertEqual(PetSpecies.shadowlings.baseMass, 0.3)

        // Fluffkins should be heavier
        XCTAssertEqual(PetSpecies.fluffkins.baseMass, 2.0)

        // Crystalites should be heaviest
        XCTAssertEqual(PetSpecies.crystalites.baseMass, 3.0)

        // All masses should be positive
        for species in PetSpecies.allCases {
            XCTAssertGreaterThan(species.baseMass, 0)
        }
    }

    func testModelNames() {
        XCTAssertEqual(PetSpecies.luminos.modelName, "Luminos_Model")
        XCTAssertEqual(PetSpecies.fluffkins.modelName, "Fluffkins_Model")

        // All model names should be non-empty
        for species in PetSpecies.allCases {
            XCTAssertFalse(species.modelName.isEmpty)
        }
    }

    func testEmojis() {
        // All species should have emoji representations
        for species in PetSpecies.allCases {
            XCTAssertFalse(species.emoji.isEmpty)
        }

        // Spot check some emojis
        XCTAssertEqual(PetSpecies.luminos.emoji, "✨")
        XCTAssertEqual(PetSpecies.aquarians.emoji, "🌊")
    }

    func testCodable() throws {
        let species = PetSpecies.luminos

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(species)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PetSpecies.self, from: data)

        XCTAssertEqual(species, decoded)
    }
}
