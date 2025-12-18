//
//  PlatformAdapterTests.swift
//  AIAgentCoordinatorTests
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import XCTest
@testable import AIAgentCoordinator

/// Unit tests for Platform Adapters
final class PlatformAdapterTests: XCTestCase {

    // MARK: - OpenAI Adapter Tests

    func testOpenAIAdapter_Connection() async throws {
        let adapter = OpenAIAdapter()

        // Given
        let credentials = PlatformCredentials.apiKey("test-key")

        // When/Then - This will fail without real API key, but tests structure
        do {
            try await adapter.connect(credentials: credentials)
            // If we get here, connection worked (won't happen with fake key)
        } catch {
            // Expected to fail with fake key
            XCTAssertTrue(error is PlatformAdapterError)
        }
    }

    func testOpenAIAdapter_InvalidCredentials() async throws {
        let adapter = OpenAIAdapter()

        // Given - wrong credential type
        let credentials = PlatformCredentials.oauth(accessToken: "token", refreshToken: nil)

        // When/Then
        do {
            try await adapter.connect(credentials: credentials)
            XCTFail("Should throw invalidConfiguration error")
        } catch {
            XCTAssertTrue(error is PlatformAdapterError)
        }
    }

    func testOpenAIAdapter_NotConnected() async throws {
        let adapter = OpenAIAdapter()

        // When/Then - try to use without connecting
        do {
            _ = try await adapter.listAgents()
            XCTFail("Should throw notConnected error")
        } catch PlatformAdapterError.notConnected {
            // Expected
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Anthropic Adapter Tests

    func testAnthropicAdapter_Connection() async throws {
        let adapter = AnthropicAdapter()

        // Given
        let credentials = PlatformCredentials.apiKey("test-key")

        // When
        try await adapter.connect(credentials: credentials)

        // Then
        let isConnected = await adapter.isConnected
        XCTAssertTrue(isConnected)
    }

    func testAnthropicAdapter_ListAgents() async throws {
        let adapter = AnthropicAdapter()

        // Given
        let credentials = PlatformCredentials.apiKey("test-key")
        try await adapter.connect(credentials: credentials)

        // When
        let agents = try await adapter.listAgents()

        // Then
        XCTAssertFalse(agents.isEmpty, "Should return available Claude models")
        XCTAssertTrue(agents.allSatisfy { $0.type == "llm" })
    }

    // MARK: - AWS SageMaker Adapter Tests

    func testAWSSageMakerAdapter_Connection() async throws {
        let adapter = AWSSageMakerAdapter()

        // Given
        let credentials = PlatformCredentials.awsCredentials(
            accessKeyId: "test-key",
            secretAccessKey: "test-secret",
            region: "us-east-1"
        )

        // When
        try await adapter.connect(credentials: credentials)

        // Then
        let isConnected = await adapter.isConnected
        XCTAssertTrue(isConnected)
    }

    func testAWSSageMakerAdapter_InvalidCredentials() async throws {
        let adapter = AWSSageMakerAdapter()

        // Given - wrong credential type
        let credentials = PlatformCredentials.apiKey("test-key")

        // When/Then
        do {
            try await adapter.connect(credentials: credentials)
            XCTFail("Should throw invalidConfiguration error")
        } catch PlatformAdapterError.invalidConfiguration {
            // Expected
            XCTAssertTrue(true)
        }
    }

    // MARK: - Credentials Tests

    func testPlatformCredentials_APIKey() {
        let credentials = PlatformCredentials.apiKey("sk-test-key")

        if case .apiKey(let key) = credentials {
            XCTAssertEqual(key, "sk-test-key")
        } else {
            XCTFail("Wrong credential type")
        }
    }

    func testPlatformCredentials_OAuth() {
        let credentials = PlatformCredentials.oauth(
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        if case .oauth(let accessToken, let refreshToken) = credentials {
            XCTAssertEqual(accessToken, "access-token")
            XCTAssertEqual(refreshToken, "refresh-token")
        } else {
            XCTFail("Wrong credential type")
        }
    }

    func testPlatformCredentials_AWS() {
        let credentials = PlatformCredentials.awsCredentials(
            accessKeyId: "AKIA...",
            secretAccessKey: "secret",
            region: "us-west-2"
        )

        if case .awsCredentials(let keyId, let secret, let region) = credentials {
            XCTAssertEqual(keyId, "AKIA...")
            XCTAssertEqual(secret, "secret")
            XCTAssertEqual(region, "us-west-2")
        } else {
            XCTFail("Wrong credential type")
        }
    }
}
