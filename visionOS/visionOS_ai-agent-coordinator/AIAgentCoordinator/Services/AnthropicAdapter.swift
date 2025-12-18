//
//  AnthropicAdapter.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation

/// Adapter for Anthropic platform (Claude)
/// Connects to Anthropic API
actor AnthropicAdapter: PlatformAdapter {

    // MARK: - Properties

    let platformName = "Anthropic"

    private var apiKey: String?
    private let baseURL = "https://api.anthropic.com/v1"
    private var urlSession: URLSession

    private(set) var isConnected = false

    // MARK: - Initialization

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Connection

    func connect(credentials: PlatformCredentials) async throws {
        guard case .apiKey(let key) = credentials else {
            throw PlatformAdapterError.invalidConfiguration
        }

        self.apiKey = key

        // Verify connection
        // Anthropic doesn't have a models list endpoint, so we just validate the key format
        guard !key.isEmpty else {
            throw PlatformAdapterError.authenticationFailed
        }

        isConnected = true
    }

    func disconnect() async {
        apiKey = nil
        isConnected = false
    }

    // MARK: - Agents/Models

    func listAgents() async throws -> [PlatformAgent] {
        guard isConnected else {
            throw PlatformAdapterError.notConnected
        }

        // Anthropic available models (as of 2024)
        let models = [
            "claude-3-opus-20240229",
            "claude-3-sonnet-20240229",
            "claude-3-haiku-20240307",
            "claude-2.1",
            "claude-2.0"
        ]

        return models.map { modelId in
            PlatformAgent(
                id: modelId,
                name: modelId,
                type: "llm",
                status: "available",
                endpoint: "\(baseURL)/messages",
                metadata: [
                    "provider": "anthropic"
                ]
            )
        }
    }

    func getAgentDetails(id: String) async throws -> PlatformAgent {
        guard isConnected else {
            throw PlatformAdapterError.notConnected
        }

        return PlatformAgent(
            id: id,
            name: id,
            type: "llm",
            status: "available",
            endpoint: "\(baseURL)/messages",
            metadata: [
                "provider": "anthropic",
                "model": id
            ]
        )
    }

    func getMetrics(agentId: String) async throws -> PlatformMetrics {
        // Anthropic doesn't provide built-in metrics via API
        return PlatformMetrics(
            agentId: agentId,
            timestamp: Date(),
            requestCount: nil,
            errorCount: nil,
            averageLatencyMs: nil,
            customMetrics: [:]
        )
    }

    func startAgent(id: String, configuration: [String: String]?) async throws {
        // Models are always available
    }

    func stopAgent(id: String) async throws {
        // Models can't be stopped
    }

    func sendRequest(agentId: String, payload: Data) async throws -> Data {
        guard isConnected, let apiKey = apiKey else {
            throw PlatformAdapterError.notConnected
        }

        let url = URL(string: "\(baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = payload

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlatformAdapterError.requestFailed("Invalid response")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw PlatformAdapterError.requestFailed("HTTP \(httpResponse.statusCode)")
        }

        return data
    }
}
