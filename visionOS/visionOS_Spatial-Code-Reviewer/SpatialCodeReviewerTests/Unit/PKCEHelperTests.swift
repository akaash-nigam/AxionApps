//
//  PKCEHelperTests.swift
//  SpatialCodeReviewerTests
//
//  Created by Claude on 2025-11-24.
//

import XCTest
@testable import SpatialCodeReviewer

final class PKCEHelperTests: XCTestCase {

    // MARK: - Code Verifier Tests

    func testGenerateCodeVerifier_ReturnsValidLength() {
        // Given/When
        let verifier = PKCEHelper.generateCodeVerifier()

        // Then
        XCTAssertGreaterThanOrEqual(verifier.count, 43, "Code verifier should be at least 43 characters")
        XCTAssertLessThanOrEqual(verifier.count, 128, "Code verifier should be at most 128 characters")
    }

    func testGenerateCodeVerifier_ContainsValidCharacters() {
        // Given/When
        let verifier = PKCEHelper.generateCodeVerifier()

        // Then
        let validCharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")
        let verifierCharSet = CharacterSet(charactersIn: verifier)

        XCTAssertTrue(validCharacterSet.isSuperset(of: verifierCharSet), "Code verifier should only contain URL-safe characters")
    }

    func testGenerateCodeVerifier_IsDifferentEachTime() {
        // Given/When
        let verifier1 = PKCEHelper.generateCodeVerifier()
        let verifier2 = PKCEHelper.generateCodeVerifier()
        let verifier3 = PKCEHelper.generateCodeVerifier()

        // Then
        XCTAssertNotEqual(verifier1, verifier2, "Code verifiers should be unique")
        XCTAssertNotEqual(verifier2, verifier3, "Code verifiers should be unique")
        XCTAssertNotEqual(verifier1, verifier3, "Code verifiers should be unique")
    }

    func testGenerateCodeVerifier_DoesNotContainPadding() {
        // Given/When
        let verifier = PKCEHelper.generateCodeVerifier()

        // Then
        XCTAssertFalse(verifier.contains("="), "Code verifier should not contain base64 padding")
    }

    // MARK: - Code Challenge Tests

    func testGenerateCodeChallenge_ReturnsValidLength() {
        // Given
        let verifier = PKCEHelper.generateCodeVerifier()

        // When
        let challenge = PKCEHelper.generateCodeChallenge(from: verifier)

        // Then
        XCTAssertEqual(challenge.count, 43, "SHA256 base64url should be 43 characters")
    }

    func testGenerateCodeChallenge_IsDeterministic() {
        // Given
        let verifier = "test_verifier_123456789"

        // When
        let challenge1 = PKCEHelper.generateCodeChallenge(from: verifier)
        let challenge2 = PKCEHelper.generateCodeChallenge(from: verifier)

        // Then
        XCTAssertEqual(challenge1, challenge2, "Same verifier should produce same challenge")
    }

    func testGenerateCodeChallenge_ContainsValidCharacters() {
        // Given
        let verifier = PKCEHelper.generateCodeVerifier()

        // When
        let challenge = PKCEHelper.generateCodeChallenge(from: verifier)

        // Then
        let validCharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")
        let challengeCharSet = CharacterSet(charactersIn: challenge)

        XCTAssertTrue(validCharacterSet.isSuperset(of: challengeCharSet), "Code challenge should only contain URL-safe characters")
    }

    func testGenerateCodeChallenge_DoesNotContainPadding() {
        // Given
        let verifier = PKCEHelper.generateCodeVerifier()

        // When
        let challenge = PKCEHelper.generateCodeChallenge(from: verifier)

        // Then
        XCTAssertFalse(challenge.contains("="), "Code challenge should not contain base64 padding")
    }

    func testGenerateCodeChallenge_DifferentVerifiersProduceDifferentChallenges() {
        // Given
        let verifier1 = "verifier1"
        let verifier2 = "verifier2"

        // When
        let challenge1 = PKCEHelper.generateCodeChallenge(from: verifier1)
        let challenge2 = PKCEHelper.generateCodeChallenge(from: verifier2)

        // Then
        XCTAssertNotEqual(challenge1, challenge2, "Different verifiers should produce different challenges")
    }

    // MARK: - RFC 7636 Compliance Tests

    func testPKCEFlow_RFC7636Example() {
        // Given (Example from RFC 7636)
        let verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"

        // When
        let challenge = PKCEHelper.generateCodeChallenge(from: verifier)

        // Then (Expected value from RFC)
        let expectedChallenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"
        XCTAssertEqual(challenge, expectedChallenge, "Should match RFC 7636 example")
    }

    // MARK: - Performance Tests

    func testGenerateCodeVerifier_Performance() {
        measure {
            _ = PKCEHelper.generateCodeVerifier()
        }
    }

    func testGenerateCodeChallenge_Performance() {
        let verifier = PKCEHelper.generateCodeVerifier()

        measure {
            _ = PKCEHelper.generateCodeChallenge(from: verifier)
        }
    }
}
