//
//  AgentRepository.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import SwiftData

/// Protocol defining agent data access operations
protocol AgentRepository: Sendable {
    func fetchAll() async throws -> [AIAgent]
    func fetch(by id: UUID) async throws -> AIAgent?
    func save(_ agent: AIAgent) async throws
    func update(_ agent: AIAgent) async throws
    func delete(_ agent: AIAgent) async throws
    func search(query: String) async throws -> [AIAgent]
    func filter(by status: AgentStatus) async throws -> [AIAgent]
}

/// SwiftData implementation of AgentRepository
@MainActor
final class SwiftDataAgentRepository: AgentRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [AIAgent] {
        let descriptor = FetchDescriptor<AIAgent>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetch(by id: UUID) async throws -> AIAgent? {
        let descriptor = FetchDescriptor<AIAgent>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func save(_ agent: AIAgent) async throws {
        modelContext.insert(agent)
        try modelContext.save()
    }

    func update(_ agent: AIAgent) async throws {
        // SwiftData automatically tracks changes
        try modelContext.save()
    }

    func delete(_ agent: AIAgent) async throws {
        modelContext.delete(agent)
        try modelContext.save()
    }

    func search(query: String) async throws -> [AIAgent] {
        let lowercasedQuery = query.lowercased()
        let descriptor = FetchDescriptor<AIAgent>(
            predicate: #Predicate { agent in
                agent.name.localizedStandardContains(lowercasedQuery) ||
                agent.agentDescription.localizedStandardContains(lowercasedQuery)
            }
        )
        return try modelContext.fetch(descriptor)
    }

    func filter(by status: AgentStatus) async throws -> [AIAgent] {
        let descriptor = FetchDescriptor<AIAgent>(
            predicate: #Predicate { $0.status == status }
        )
        return try modelContext.fetch(descriptor)
    }
}

/// In-memory implementation for testing and development
@MainActor
final class InMemoryAgentRepository: AgentRepository {

    private var agents: [UUID: AIAgent] = [:]

    init() {
        // Initialize with sample data
        Task {
            await loadSampleData()
        }
    }

    func fetchAll() async throws -> [AIAgent] {
        Array(agents.values).sorted { $0.name < $1.name }
    }

    func fetch(by id: UUID) async throws -> AIAgent? {
        agents[id]
    }

    func save(_ agent: AIAgent) async throws {
        agents[agent.id] = agent
    }

    func update(_ agent: AIAgent) async throws {
        agents[agent.id] = agent
    }

    func delete(_ agent: AIAgent) async throws {
        agents.removeValue(forKey: agent.id)
    }

    func search(query: String) async throws -> [AIAgent] {
        let lowercasedQuery = query.lowercased()
        return agents.values.filter { agent in
            agent.name.lowercased().contains(lowercasedQuery) ||
            agent.agentDescription.lowercased().contains(lowercasedQuery) ||
            agent.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }.sorted { $0.name < $1.name }
    }

    func filter(by status: AgentStatus) async throws -> [AIAgent] {
        agents.values.filter { $0.status == status }.sorted { $0.name < $1.name }
    }

    // MARK: - Sample Data

    private func loadSampleData() async {
        let sampleAgents = [
            AIAgent(
                name: "data-processor-01",
                type: .dataProcessing,
                platform: .aws,
                status: .active,
                agentDescription: "Processes incoming data streams from IoT devices",
                endpoint: "https://api.example.com/agents/data-processor-01",
                tags: ["data", "iot", "processing"]
            ),
            AIAgent(
                name: "ml-trainer-05",
                type: .mlTraining,
                platform: .azure,
                status: .learning,
                agentDescription: "Training recommendation model",
                endpoint: "https://api.example.com/agents/ml-trainer-05",
                tags: ["ml", "training", "recommendations"]
            ),
            AIAgent(
                name: "customer-svc-08",
                type: .customerService,
                platform: .openai,
                status: .active,
                agentDescription: "Handles customer support inquiries",
                endpoint: "https://api.example.com/agents/customer-svc-08",
                tags: ["customer", "support", "chatbot"]
            ),
            AIAgent(
                name: "api-gateway-12",
                type: .apiGateway,
                platform: .custom,
                status: .error,
                agentDescription: "Routes API requests to backend services",
                endpoint: "https://api.example.com/agents/api-gateway-12",
                tags: ["api", "gateway", "routing"]
            ),
            AIAgent(
                name: "sentiment-analyzer-03",
                type: .nlp,
                platform: .anthropic,
                status: .active,
                agentDescription: "Analyzes sentiment in social media posts",
                endpoint: "https://api.example.com/agents/sentiment-analyzer-03",
                tags: ["nlp", "sentiment", "social-media"]
            )
        ]

        for agent in sampleAgents {
            agents[agent.id] = agent
        }
    }
}
