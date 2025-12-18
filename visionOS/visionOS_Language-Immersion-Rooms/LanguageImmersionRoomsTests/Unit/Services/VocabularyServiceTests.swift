//
//  VocabularyServiceTests.swift
//  Language Immersion Rooms Tests
//
//  Unit tests for vocabulary service
//

import XCTest
@testable import LanguageImmersionRooms

final class VocabularyServiceTests: XCTestCase {

    var service: VocabularyService!

    override func setUp() {
        super.setUp()
        service = VocabularyService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Translation Tests

    func testTranslateKnownWord() {
        let translation = service.translate("table", to: .spanish)
        XCTAssertEqual(translation, "mesa")
    }

    func testTranslateCaseInsensitive() {
        let translation1 = service.translate("TABLE", to: .spanish)
        let translation2 = service.translate("table", to: .spanish)
        XCTAssertEqual(translation1, translation2)
    }

    func testTranslateUnknownWord() {
        let translation = service.translate("unknownword", to: .spanish)
        XCTAssertNil(translation)
    }

    func testTranslateChair() {
        let translation = service.translate("chair", to: .spanish)
        XCTAssertEqual(translation, "silla")
    }

    func testTranslateDoor() {
        let translation = service.translate("door", to: .spanish)
        XCTAssertEqual(translation, "puerta")
    }

    func testTranslateWindow() {
        let translation = service.translate("window", to: .spanish)
        XCTAssertEqual(translation, "ventana")
    }

    // MARK: - Word Retrieval Tests

    func testGetWordForTranslation() {
        let word = service.getWord(for: "table", language: .spanish)

        XCTAssertNotNil(word)
        XCTAssertEqual(word?.word, "mesa")
        XCTAssertEqual(word?.translation, "table")
        XCTAssertEqual(word?.language, .spanish)
    }

    func testGetWordForUnknownTranslation() {
        let word = service.getWord(for: "unknownword", language: .spanish)
        XCTAssertNil(word)
    }

    func testGetWordProperties() {
        let word = service.getWord(for: "refrigerator", language: .spanish)

        XCTAssertNotNil(word)
        XCTAssertEqual(word?.word, "refrigerador")
        XCTAssertEqual(word?.category, .kitchen)
        XCTAssertNotNil(word?.id)
    }

    // MARK: - Category Tests

    func testGetWordsByKitchenCategory() {
        let kitchenWords = service.getWords(for: .kitchen, language: .spanish)

        XCTAssertEqual(kitchenWords.count, 20)
        XCTAssertTrue(kitchenWords.allSatisfy { $0.category == .kitchen })
        XCTAssertTrue(kitchenWords.allSatisfy { $0.language == .spanish })
    }

    func testGetWordsByLivingRoomCategory() {
        let livingRoomWords = service.getWords(for: .livingRoom, language: .spanish)

        XCTAssertEqual(livingRoomWords.count, 20)
        XCTAssertTrue(livingRoomWords.allSatisfy { $0.category == .livingRoom })
    }

    func testGetWordsByBedroomCategory() {
        let bedroomWords = service.getWords(for: .bedroom, language: .spanish)

        XCTAssertEqual(bedroomWords.count, 15)
        XCTAssertTrue(bedroomWords.allSatisfy { $0.category == .bedroom })
    }

    func testGetWordsByBathroomCategory() {
        let bathroomWords = service.getWords(for: .bathroom, language: .spanish)

        XCTAssertEqual(bathroomWords.count, 15)
        XCTAssertTrue(bathroomWords.allSatisfy { $0.category == .bathroom })
    }

    func testGetWordsByOfficeCategory() {
        let officeWords = service.getWords(for: .office, language: .spanish)

        XCTAssertEqual(officeWords.count, 15)
        XCTAssertTrue(officeWords.allSatisfy { $0.category == .office })
    }

    func testGetWordsByGeneralCategory() {
        let generalWords = service.getWords(for: .general, language: .spanish)

        XCTAssertEqual(generalWords.count, 15)
        XCTAssertTrue(generalWords.allSatisfy { $0.category == .general })
    }

    // MARK: - All Words Tests

    func testGetAllWords() {
        let allWords = service.getAllWords(language: .spanish)

        XCTAssertEqual(allWords.count, 100)
        XCTAssertTrue(allWords.allSatisfy { $0.language == .spanish })
    }

    func testGetAllWordsUnique() {
        let allWords = service.getAllWords(language: .spanish)
        let uniqueTranslations = Set(allWords.map { $0.translation })

        XCTAssertEqual(uniqueTranslations.count, 100, "All words should have unique translations")
    }

    func testGetAllWordsCategories() {
        let allWords = service.getAllWords(language: .spanish)

        let kitchenCount = allWords.filter { $0.category == .kitchen }.count
        let livingRoomCount = allWords.filter { $0.category == .livingRoom }.count
        let bedroomCount = allWords.filter { $0.category == .bedroom }.count
        let bathroomCount = allWords.filter { $0.category == .bathroom }.count
        let officeCount = allWords.filter { $0.category == .office }.count
        let generalCount = allWords.filter { $0.category == .general }.count

        XCTAssertEqual(kitchenCount, 20)
        XCTAssertEqual(livingRoomCount, 20)
        XCTAssertEqual(bedroomCount, 15)
        XCTAssertEqual(bathroomCount, 15)
        XCTAssertEqual(officeCount, 15)
        XCTAssertEqual(generalCount, 15)
    }

    // MARK: - Specific Word Tests

    func testKitchenWords() {
        let expectedWords = [
            ("table", "mesa"),
            ("chair", "silla"),
            ("refrigerator", "refrigerador"),
            ("stove", "estufa"),
            ("oven", "horno")
        ]

        for (english, spanish) in expectedWords {
            let translation = service.translate(english, to: .spanish)
            XCTAssertEqual(translation, spanish, "Translation for '\(english)' should be '\(spanish)'")
        }
    }

    func testLivingRoomWords() {
        let expectedWords = [
            ("sofa", "sofá"),
            ("television", "televisión"),
            ("lamp", "lámpara")
        ]

        for (english, spanish) in expectedWords {
            let translation = service.translate(english, to: .spanish)
            XCTAssertEqual(translation, spanish, "Translation for '\(english)' should be '\(spanish)'")
        }
    }

    func testBedroomWords() {
        let expectedWords = [
            ("bed", "cama"),
            ("pillow", "almohada"),
            ("blanket", "manta")
        ]

        for (english, spanish) in expectedWords {
            let translation = service.translate(english, to: .spanish)
            XCTAssertEqual(translation, spanish, "Translation for '\(english)' should be '\(spanish)'")
        }
    }

    // MARK: - Edge Cases

    func testEmptyString() {
        let translation = service.translate("", to: .spanish)
        XCTAssertNil(translation)
    }

    func testWhitespaceString() {
        let translation = service.translate("   ", to: .spanish)
        XCTAssertNil(translation)
    }

    func testSpecialCharacters() {
        let translation = service.translate("@#$%", to: .spanish)
        XCTAssertNil(translation)
    }

    // MARK: - Performance Tests

    func testTranslationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = service.translate("table", to: .spanish)
            }
        }
    }

    func testGetAllWordsPerformance() {
        measure {
            _ = service.getAllWords(language: .spanish)
        }
    }

    func testGetWordsByCategoryPerformance() {
        measure {
            for _ in 0..<100 {
                _ = service.getWords(for: .kitchen, language: .spanish)
            }
        }
    }
}
