//
//  PlatformAdapter.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation

/// Protocol for AI platform integrations
/// Defines interface for connecting to different AI platforms
protocol PlatformAdapter: Sendable {
    /// Platform name
    var platformName: String { get async }

    /// Connect to the platform with credentials
    func connect(credentials: PlatformCredentials) async throws

    /// Disconnect from the platform
    func disconnect() async

    /// Check if currently connected
    var isConnected: Bool { get async }

    /// List all agents/models available on the platform
    func listAgents() async throws -> [PlatformAgent]

    /// Get details for a specific agent
    func getAgentDetails(id: String) async throws -> PlatformAgent

    /// Get current metrics for an agent
    func getMetrics(agentId: String) async throws -> PlatformMetrics

    /// Start an agent/model
    func startAgent(id: String, configuration: [String: String]?) async throws

    /// Stop an agent/model
    func stopAgent(id: String) async throws

    /// Send a request to an agent
    func sendRequest(agentId: String, payload: Data) async throws -> Data
}

// MARK: - Supporting Types

/// Platform credentials
enum PlatformCredentials: Sendable {
    case apiKey(String)
    case oauth(accessToken: String, refreshToken: String?)
    case awsCredentials(accessKeyId: String, secretAccessKey: String, region: String)
    case azureCredentials(subscriptionId: String, tenantId: String, clientId: String, clientSecret: String)
    case custom([String: String])
}

/// Platform agent representation
struct PlatformAgent: Sendable, Identifiable {
    let id: String
    let name: String
    let type: String
    let status: String
    let endpoint: String?
    let metadata: [String: String]
}

/// Platform metrics
struct PlatformMetrics: Sendable {
    let agentId: String
    let timestamp: Date
    let requestCount: Int?
    let errorCount: Int?
    let averageLatencyMs: Double?
    let customMetrics: [String: Double]
}

/// Platform adapter errors
enum PlatformAdapterError: Error, LocalizedError {
    case notConnected
    case authenticationFailed
    case agentNotFound(String)
    case requestFailed(String)
    case invalidConfiguration
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to platform"
        case .authenticationFailed:
            return "Authentication failed"
        case .agentNotFound(let id):
            return "Agent not found: \(id)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .invalidConfiguration:
            return "Invalid configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
