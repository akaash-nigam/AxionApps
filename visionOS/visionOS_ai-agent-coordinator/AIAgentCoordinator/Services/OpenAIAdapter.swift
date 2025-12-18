//
//  OpenAIAdapter.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation

/// Adapter for OpenAI platform
/// Connects to OpenAI API and manages assistants/models
actor OpenAIAdapter: PlatformAdapter {

    // MARK: - Properties

    let platformName = "OpenAI"

    private var apiKey: String?
    private let baseURL = "https://api.openai.com/v1"
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

        // Verify connection by listing models
        _ = try await listModels()

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

        let models = try await listModels()

        return models.map { model in
            PlatformAgent(
                id: model.id,
                name: model.id,
                type: "llm",
                status: "available",
                endpoint: "\(baseURL)/chat/completions",
                metadata: [
                    "owned_by": model.ownedBy,
                    "created": "\(model.created)"
                ]
            )
        }
    }

    func getAgentDetails(id: String) async throws -> PlatformAgent {
        guard isConnected else {
            throw PlatformAdapterError.notConnected
        }

        let model = try await getModel(id: id)

        return PlatformAgent(
            id: model.id,
            name: model.id,
            type: "llm",
            status: "available",
            endpoint: "\(baseURL)/chat/completions",
            metadata: [
                "owned_by": model.ownedBy,
                "created": "\(model.created)"
            ]
        )
    }

    func getMetrics(agentId: String) async throws -> PlatformMetrics {
        // OpenAI doesn't provide built-in metrics via API
        // Would need to track usage separately
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
        // OpenAI models are always available, no start needed
    }

    func stopAgent(id: String) async throws {
        // OpenAI models can't be stopped
    }

    func sendRequest(agentId: String, payload: Data) async throws -> Data {
        guard isConnected, let apiKey = apiKey else {
            throw PlatformAdapterError.notConnected
        }

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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

    // MARK: - Private API Methods

    private func listModels() async throws -> [OpenAIModel] {
        guard let apiKey = apiKey else {
            throw PlatformAdapterError.notConnected
        }

        let url = URL(string: "\(baseURL)/models")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PlatformAdapterError.authenticationFailed
        }

        let modelList = try JSONDecoder().decode(OpenAIModelList.self, from: data)
        return modelList.data
    }

    private func getModel(id: String) async throws -> OpenAIModel {
        guard let apiKey = apiKey else {
            throw PlatformAdapterError.notConnected
        }

        let url = URL(string: "\(baseURL)/models/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PlatformAdapterError.agentNotFound(id)
        }

        return try JSONDecoder().decode(OpenAIModel.self, from: data)
    }
}

// MARK: - OpenAI API Models

private struct OpenAIModelList: Codable {
    let data: [OpenAIModel]
}

private struct OpenAIModel: Codable {
    let id: String
    let object: String
    let created: Int
    let ownedBy: String

    enum CodingKeys: String, CodingKey {
        case id, object, created
        case ownedBy = "owned_by"
    }
}
