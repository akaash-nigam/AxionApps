//
//  KeychainServiceTests.swift
//  SpatialCodeReviewerTests
//
//  Created by Claude on 2025-11-24.
//

import XCTest
@testable import SpatialCodeReviewer

final class KeychainServiceTests: XCTestCase {

    var sut: KeychainService!
    let testProvider = "test_provider"
    let testKey = "test_key"

    override func setUp() {
        super.setUp()
        sut = KeychainService.shared

        // Clean up any existing test data
        try? sut.deleteToken(for: testProvider)
        try? sut.deleteCredential(forKey: testKey)
    }

    override func tearDown() {
        // Clean up test data
        try? sut.deleteToken(for: testProvider)
        try? sut.deleteCredential(forKey: testKey)

        sut = nil
        super.tearDown()
    }

    // MARK: - Token Storage Tests

    func testStoreToken_Success() {
        // Given
        let token = Token(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token",
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo read:user"
        )

        // When/Then
        XCTAssertNoThrow(try sut.storeToken(token, for: testProvider))
    }

    func testRetrieveToken_AfterStoring_ReturnsCorrectToken() throws {
        // Given
        let originalToken = Token(
            accessToken: "test_access_token_123",
            refreshToken: "test_refresh_token_456",
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo read:user"
        )
        try sut.storeToken(originalToken, for: testProvider)

        // When
        let retrievedToken = try sut.retrieveToken(for: testProvider)

        // Then
        XCTAssertEqual(retrievedToken.accessToken, originalToken.accessToken)
        XCTAssertEqual(retrievedToken.refreshToken, originalToken.refreshToken)
        XCTAssertEqual(retrievedToken.tokenType, originalToken.tokenType)
        XCTAssertEqual(retrievedToken.scope, originalToken.scope)
    }

    func testRetrieveToken_WithoutStoring_ThrowsError() {
        // When/Then
        XCTAssertThrowsError(try sut.retrieveToken(for: "nonexistent_provider")) { error in
            XCTAssertTrue(error is KeychainError)
        }
    }

    func testDeleteToken_RemovesToken() throws {
        // Given
        let token = Token(
            accessToken: "test_token",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo"
        )
        try sut.storeToken(token, for: testProvider)

        // When
        try sut.deleteToken(for: testProvider)

        // Then
        XCTAssertThrowsError(try sut.retrieveToken(for: testProvider))
    }

    func testStoreToken_Twice_OverwritesFirst() throws {
        // Given
        let token1 = Token(
            accessToken: "token1",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo"
        )
        let token2 = Token(
            accessToken: "token2",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "read:user"
        )

        // When
        try sut.storeToken(token1, for: testProvider)
        try sut.storeToken(token2, for: testProvider)

        // Then
        let retrieved = try sut.retrieveToken(for: testProvider)
        XCTAssertEqual(retrieved.accessToken, "token2")
        XCTAssertEqual(retrieved.scope, "read:user")
    }

    // MARK: - Credential Storage Tests

    func testStoreCredential_Success() {
        // Given
        let credential = "test_credential_value"

        // When/Then
        XCTAssertNoThrow(try sut.storeCredential(credential, forKey: testKey))
    }

    func testRetrieveCredential_AfterStoring_ReturnsCorrectValue() throws {
        // Given
        let originalCredential = "my_secret_credential"
        try sut.storeCredential(originalCredential, forKey: testKey)

        // When
        let retrieved = try sut.retrieveCredential(forKey: testKey)

        // Then
        XCTAssertEqual(retrieved, originalCredential)
    }

    func testRetrieveCredential_WithoutStoring_ThrowsError() {
        // When/Then
        XCTAssertThrowsError(try sut.retrieveCredential(forKey: "nonexistent_key")) { error in
            XCTAssertTrue(error is KeychainError)
        }
    }

    func testDeleteCredential_RemovesCredential() throws {
        // Given
        try sut.storeCredential("test", forKey: testKey)

        // When
        try sut.deleteCredential(forKey: testKey)

        // Then
        XCTAssertThrowsError(try sut.retrieveCredential(forKey: testKey))
    }

    // MARK: - PKCE Verifier Storage Tests

    func testStoreCodeVerifier_AndRetrieve() {
        // Given
        let verifier = "test_verifier_123"
        let state = "test_state_456"

        // When
        sut.storeCodeVerifier(verifier, for: state)
        let retrieved = sut.retrieveCodeVerifier(for: state)

        // Then
        XCTAssertEqual(retrieved, verifier)
    }

    func testRetrieveCodeVerifier_WithoutStoring_ReturnsNil() {
        // When
        let retrieved = sut.retrieveCodeVerifier(for: "nonexistent_state")

        // Then
        XCTAssertNil(retrieved)
    }

    func testDeleteCodeVerifier_RemovesVerifier() {
        // Given
        let verifier = "test_verifier"
        let state = "test_state"
        sut.storeCodeVerifier(verifier, for: state)

        // When
        sut.deleteCodeVerifier(for: state)

        // Then
        XCTAssertNil(sut.retrieveCodeVerifier(for: state))
    }

    // MARK: - Multiple Provider Tests

    func testStoreTokens_ForMultipleProviders_StoresIndependently() throws {
        // Given
        let githubToken = Token(
            accessToken: "github_token",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo"
        )
        let gitlabToken = Token(
            accessToken: "gitlab_token",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "api"
        )

        // When
        try sut.storeToken(githubToken, for: "github")
        try sut.storeToken(gitlabToken, for: "gitlab")

        // Then
        let retrievedGithub = try sut.retrieveToken(for: "github")
        let retrievedGitlab = try sut.retrieveToken(for: "gitlab")

        XCTAssertEqual(retrievedGithub.accessToken, "github_token")
        XCTAssertEqual(retrievedGitlab.accessToken, "gitlab_token")

        // Cleanup
        try? sut.deleteToken(for: "github")
        try? sut.deleteToken(for: "gitlab")
    }

    // MARK: - Error Handling Tests

    func testKeychainError_HasDescriptiveMessages() {
        // Given
        let errors: [KeychainError] = [
            .storeFailed(status: errSecDuplicateItem),
            .retrieveFailed(status: errSecItemNotFound),
            .deleteFailed(status: errSecItemNotFound),
            .invalidData
        ]

        // When/Then
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Performance Tests

    func testStoreToken_Performance() {
        let token = Token(
            accessToken: "performance_test_token",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo"
        )

        measure {
            try? sut.storeToken(token, for: "performance_provider")
        }

        try? sut.deleteToken(for: "performance_provider")
    }

    func testRetrieveToken_Performance() throws {
        // Setup
        let token = Token(
            accessToken: "performance_test_token",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: "repo"
        )
        try sut.storeToken(token, for: "performance_provider")

        // Measure
        measure {
            _ = try? sut.retrieveToken(for: "performance_provider")
        }

        // Cleanup
        try? sut.deleteToken(for: "performance_provider")
    }
}
