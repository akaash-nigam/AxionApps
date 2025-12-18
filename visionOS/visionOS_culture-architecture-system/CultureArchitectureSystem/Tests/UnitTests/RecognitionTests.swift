//
//  RecognitionTests.swift
//  CultureArchitectureSystemTests
//
//  Created on 2025-01-20
//

import XCTest
@testable import CultureArchitectureSystem

final class RecognitionTests: XCTestCase {

    func testRecognitionCreation() {
        // Given
        let giverId = UUID()
        let receiverId = UUID()
        let valueId = UUID()
        let message = "Great work on the project!"

        // When
        let recognition = Recognition(
            giverAnonymousId: giverId,
            receiverAnonymousId: receiverId,
            valueId: valueId,
            message: message
        )

        // Then
        XCTAssertNotNil(recognition.id)
        XCTAssertEqual(recognition.giverAnonymousId, giverId)
        XCTAssertEqual(recognition.receiverAnonymousId, receiverId)
        XCTAssertEqual(recognition.valueId, valueId)
        XCTAssertEqual(recognition.message, message)
        XCTAssertEqual(recognition.visibility, .team) // Default
        XCTAssertFalse(recognition.isSynced)
        XCTAssertNotNil(recognition.timestamp)
    }

    func testRecognitionVisibility() {
        // Test all visibility levels
        let visibilities: [RecognitionVisibility] = [.private_, .team, .organization]

        for visibility in visibilities {
            // When
            let recognition = Recognition(
                giverAnonymousId: UUID(),
                receiverAnonymousId: UUID(),
                valueId: UUID(),
                message: "Test",
                visibility: visibility
            )

            // Then
            XCTAssertEqual(recognition.visibility, visibility)
        }
    }

    func testRecognitionMock() {
        // When
        let mockRecognition = Recognition.mock()

        // Then
        XCTAssertNotNil(mockRecognition.id)
        XCTAssertNotNil(mockRecognition.giverAnonymousId)
        XCTAssertNotNil(mockRecognition.receiverAnonymousId)
        XCTAssertNotNil(mockRecognition.valueId)
        XCTAssertFalse(mockRecognition.message.isEmpty)
        XCTAssertEqual(mockRecognition.visibility, .team)
    }

    func testRecognitionCodable() throws {
        // Given
        let recognition = Recognition(
            giverAnonymousId: UUID(),
            receiverAnonymousId: UUID(),
            valueId: UUID(),
            message: "Excellent collaboration!",
            visibility: .organization
        )

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(recognition)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Recognition.self, from: data)

        // Then
        XCTAssertEqual(decoded.message, recognition.message)
        XCTAssertEqual(decoded.visibility, recognition.visibility)
    }
}
