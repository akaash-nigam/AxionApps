//
//  AIAgent.swift
//  AI Agent Coordinator
//
//  Core data model for AI agents representing entities in various AI platforms
//  (OpenAI, AWS SageMaker, Anthropic, Azure AI, etc.)
//
//  Created by AI Agent Coordinator Team
//  Copyright © 2025 AI Agent Coordinator. All rights reserved.
//

import Foundation
import SwiftData

/// Core model representing an AI agent in the system.
///
/// An `AIAgent` encapsulates all information about an AI entity, including its configuration,
/// metrics, relationships with other agents, and spatial positioning for 3D visualization.
///
/// # Usage Example
/// ```swift
/// let agent = AIAgent(
///     name: "Production GPT-4",
///     type: .llm,
///     platform: .openai
/// )
/// modelContext.insert(agent)
/// ```
///
/// - Note: This class is marked with `@Model` for SwiftData persistence and conforms to
///   `Codable` for JSON serialization when communicating with external platforms.
@Model
final class AIAgent: Identifiable, Codable, @unchecked Sendable {
    // MARK: - Identity

    /// Unique identifier for the agent.
    /// This ID is used across the system and persisted in SwiftData.
    @Attribute(.unique) var id: UUID

    /// Human-readable name for the agent.
    /// If empty, `displayName` will generate a fallback based on ID.
    var name: String

    /// The type of agent, determining its primary function and capabilities.
    var type: AgentType

    /// Current operational status of the agent.
    var status: AgentStatus

    // MARK: - Description & Endpoint

    /// Description of the agent's purpose and capabilities
    var agentDescription: String

    /// API endpoint URL for the agent (if applicable)
    var endpoint: String?

    // MARK: - Metadata
    var createdAt: Date
    var lastActiveAt: Date
    var version: String
    var platform: AIPlatform
    var platformAgentId: String? // ID in external platform

    // MARK: - Configuration
    var configuration: AgentConfiguration
    var capabilities: [AgentCapability]
    var tags: [String]

    // MARK: - Relationships
    var connections: [AgentConnection]
    var parentAgentId: UUID?
    var childAgentIds: [UUID]

    // MARK: - Metrics
    @Relationship(deleteRule: .cascade) var currentMetrics: AgentMetrics?
    var healthScore: Double

    // MARK: - Spatial Properties
    var spatialPosition: SpatialPosition?
    var visualStyle: VisualizationStyle

    // MARK: - Computed Properties
    var isHealthy: Bool {
        healthScore > 0.7 && (status == .active || status == .idle)
    }

    var displayName: String {
        name.isEmpty ? "Agent-\(id.uuidString.prefix(8))" : name
    }

    // MARK: - Initialization

    /// Primary initializer with all configurable properties
    init(
        id: UUID = UUID(),
        name: String,
        type: AgentType,
        status: AgentStatus = .idle,
        agentDescription: String = "",
        endpoint: String? = nil,
        platform: AIPlatform = .custom,
        tags: [String] = [],
        configuration: AgentConfiguration = AgentConfiguration(),
        visualStyle: VisualizationStyle = .default
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.status = status
        self.agentDescription = agentDescription
        self.endpoint = endpoint
        self.createdAt = Date()
        self.lastActiveAt = Date()
        self.version = "1.0"
        self.platform = platform
        self.platformAgentId = nil
        self.configuration = configuration
        self.capabilities = []
        self.tags = tags
        self.connections = []
        self.parentAgentId = nil
        self.childAgentIds = []
        self.healthScore = 1.0
        self.spatialPosition = nil
        self.visualStyle = visualStyle
    }

    /// Convenience initializer for testing purposes
    /// Provides a simplified interface matching test requirements
    convenience init(
        name: String,
        type: AgentType,
        platform: AIPlatform,
        status: AgentStatus,
        agentDescription: String,
        endpoint: String?,
        tags: [String]
    ) {
        self.init(
            name: name,
            type: type,
            status: status,
            agentDescription: agentDescription,
            endpoint: endpoint,
            platform: platform,
            tags: tags
        )
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, type, status
        case agentDescription, endpoint
        case createdAt, lastActiveAt, version, platform, platformAgentId
        case configuration, capabilities, tags
        case connections, parentAgentId, childAgentIds
        case healthScore, spatialPosition, visualStyle
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(AgentType.self, forKey: .type)
        status = try container.decode(AgentStatus.self, forKey: .status)
        agentDescription = try container.decodeIfPresent(String.self, forKey: .agentDescription) ?? ""
        endpoint = try container.decodeIfPresent(String.self, forKey: .endpoint)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastActiveAt = try container.decode(Date.self, forKey: .lastActiveAt)
        version = try container.decode(String.self, forKey: .version)
        platform = try container.decode(AIPlatform.self, forKey: .platform)
        platformAgentId = try container.decodeIfPresent(String.self, forKey: .platformAgentId)
        configuration = try container.decode(AgentConfiguration.self, forKey: .configuration)
        capabilities = try container.decode([AgentCapability].self, forKey: .capabilities)
        tags = try container.decode([String].self, forKey: .tags)
        connections = try container.decode([AgentConnection].self, forKey: .connections)
        parentAgentId = try container.decodeIfPresent(UUID.self, forKey: .parentAgentId)
        childAgentIds = try container.decode([UUID].self, forKey: .childAgentIds)
        healthScore = try container.decode(Double.self, forKey: .healthScore)
        spatialPosition = try container.decodeIfPresent(SpatialPosition.self, forKey: .spatialPosition)
        visualStyle = try container.decode(VisualizationStyle.self, forKey: .visualStyle)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(status, forKey: .status)
        try container.encode(agentDescription, forKey: .agentDescription)
        try container.encodeIfPresent(endpoint, forKey: .endpoint)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastActiveAt, forKey: .lastActiveAt)
        try container.encode(version, forKey: .version)
        try container.encode(platform, forKey: .platform)
        try container.encodeIfPresent(platformAgentId, forKey: .platformAgentId)
        try container.encode(configuration, forKey: .configuration)
        try container.encode(capabilities, forKey: .capabilities)
        try container.encode(tags, forKey: .tags)
        try container.encode(connections, forKey: .connections)
        try container.encodeIfPresent(parentAgentId, forKey: .parentAgentId)
        try container.encode(childAgentIds, forKey: .childAgentIds)
        try container.encode(healthScore, forKey: .healthScore)
        try container.encodeIfPresent(spatialPosition, forKey: .spatialPosition)
        try container.encode(visualStyle, forKey: .visualStyle)
    }
}

// MARK: - Agent Type

enum AgentType: String, Codable, CaseIterable {
    case general = "General"
    case llm = "LLM"
    case taskSpecific = "Task Specific"
    case autonomous = "Autonomous"
    case monitoring = "Monitoring"
    case orchestration = "Orchestration"
    case dataProcessing = "Data Processing"
    case mlTraining = "ML Training"
    case customerService = "Customer Service"
    case apiGateway = "API Gateway"
    case nlp = "NLP"
    case security = "Security"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .general: return "cpu"
        case .llm: return "brain"
        case .taskSpecific: return "gearshape.2"
        case .autonomous: return "wand.and.stars"
        case .monitoring: return "chart.line.uptrend.xyaxis"
        case .orchestration: return "network"
        case .dataProcessing: return "server.rack"
        case .mlTraining: return "brain.head.profile"
        case .customerService: return "person.bubble"
        case .apiGateway: return "arrow.triangle.branch"
        case .nlp: return "text.bubble"
        case .security: return "lock.shield"
        case .custom: return "cube.box"
        }
    }
}

// MARK: - Agent Status

enum AgentStatus: String, Codable, CaseIterable {
    case active = "Active"
    case idle = "Idle"
    case learning = "Learning"
    case error = "Error"
    case optimizing = "Optimizing"
    case paused = "Paused"
    case terminated = "Terminated"

    var color: String {
        switch self {
        case .active: return "#00A3FF"      // Bright blue
        case .idle: return "#8E8E93"        // Gray
        case .learning: return "#BF5AF2"    // Purple
        case .error: return "#FF3B30"       // Red
        case .optimizing: return "#34C759"  // Green
        case .paused: return "#FF9500"      // Orange
        case .terminated: return "#636366"  // Dark gray
        }
    }
}

// MARK: - AI Platform

enum AIPlatform: String, Codable, CaseIterable {
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case aws = "AWS"
    case awsSageMaker = "AWS SageMaker"
    case azure = "Azure"
    case azureAI = "Azure AI"
    case googleVertexAI = "Google Vertex AI"
    case huggingFace = "Hugging Face"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .openai: return "o.circle.fill"
        case .anthropic: return "a.circle.fill"
        case .aws: return "cloud.fill"
        case .awsSageMaker: return "cloud.fill"
        case .azure: return "cloud.bolt.fill"
        case .azureAI: return "cloud.bolt.fill"
        case .googleVertexAI: return "g.circle.fill"
        case .huggingFace: return "face.smiling"
        case .custom: return "wrench.and.screwdriver"
        }
    }
}

// MARK: - Agent Configuration

struct AgentConfiguration: Codable {
    var maxConcurrency: Int
    var timeout: TimeInterval
    var retryPolicy: RetryPolicy
    var rateLimits: RateLimitConfig?
    var customParameters: [String: String] // Simplified for Codable

    init(
        maxConcurrency: Int = 10,
        timeout: TimeInterval = 30,
        retryPolicy: RetryPolicy = .exponential,
        rateLimits: RateLimitConfig? = nil,
        customParameters: [String: String] = [:]
    ) {
        self.maxConcurrency = maxConcurrency
        self.timeout = timeout
        self.retryPolicy = retryPolicy
        self.rateLimits = rateLimits
        self.customParameters = customParameters
    }
}

enum RetryPolicy: String, Codable {
    case none
    case exponential
    case linear
    case fixed
}

struct RateLimitConfig: Codable {
    var requestsPerSecond: Int
    var requestsPerMinute: Int
    var requestsPerHour: Int

    init(requestsPerSecond: Int = 10, requestsPerMinute: Int = 600, requestsPerHour: Int = 36000) {
        self.requestsPerSecond = requestsPerSecond
        self.requestsPerMinute = requestsPerMinute
        self.requestsPerHour = requestsPerHour
    }
}

// MARK: - Agent Capability

struct AgentCapability: Codable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var inputTypes: [DataType]
    var outputTypes: [DataType]

    init(id: UUID = UUID(), name: String, description: String, inputTypes: [DataType] = [], outputTypes: [DataType] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.inputTypes = inputTypes
        self.outputTypes = outputTypes
    }
}

enum DataType: String, Codable {
    case text
    case image
    case audio
    case video
    case json
    case binary
    case stream
}

// MARK: - Agent Connection

struct AgentConnection: Codable, Identifiable {
    var id: UUID
    var sourceAgentId: UUID
    var targetAgentId: UUID
    var connectionType: ConnectionType
    var dataFlow: DataFlowMetrics
    var `protocol`: CommunicationProtocol
    var health: ConnectionHealth

    init(
        id: UUID = UUID(),
        sourceAgentId: UUID,
        targetAgentId: UUID,
        connectionType: ConnectionType = .synchronous,
        dataFlow: DataFlowMetrics = DataFlowMetrics(),
        protocol: CommunicationProtocol = .rest,
        health: ConnectionHealth = .healthy
    ) {
        self.id = id
        self.sourceAgentId = sourceAgentId
        self.targetAgentId = targetAgentId
        self.connectionType = connectionType
        self.dataFlow = dataFlow
        self.protocol = `protocol`
        self.health = health
    }

    enum ConnectionType: String, Codable {
        case synchronous
        case asynchronous
        case streaming
        case batch
    }

    enum CommunicationProtocol: String, Codable {
        case rest
        case grpc
        case websocket
        case messageQueue
        case custom
    }

    enum ConnectionHealth: String, Codable {
        case healthy
        case degraded
        case failing
        case disconnected

        var color: String {
            switch self {
            case .healthy: return "#34C759"
            case .degraded: return "#FF9500"
            case .failing: return "#FF3B30"
            case .disconnected: return "#8E8E93"
            }
        }
    }
}

struct DataFlowMetrics: Codable {
    var messagesPerSecond: Double
    var bytesPerSecond: Int64
    var averageMessageSize: Int64
    var queueDepth: Int?

    init(messagesPerSecond: Double = 0, bytesPerSecond: Int64 = 0, averageMessageSize: Int64 = 0, queueDepth: Int? = nil) {
        self.messagesPerSecond = messagesPerSecond
        self.bytesPerSecond = bytesPerSecond
        self.averageMessageSize = averageMessageSize
        self.queueDepth = queueDepth
    }
}

// MARK: - Spatial Position

struct SpatialPosition: Codable {
    var x: Float
    var y: Float
    var z: Float
    var scale: Float
    var layoutGroup: String?
    var layoutPriority: Int

    init(x: Float = 0, y: Float = 0, z: Float = 0, scale: Float = 1.0, layoutGroup: String? = nil, layoutPriority: Int = 0) {
        self.x = x
        self.y = y
        self.z = z
        self.scale = scale
        self.layoutGroup = layoutGroup
        self.layoutPriority = layoutPriority
    }
}

// MARK: - Visualization Style

struct VisualizationStyle: Codable {
    var shape: AgentShape
    var colorScheme: ColorScheme
    var size: AgentSize
    var effects: [VisualEffect]

    init(shape: AgentShape = .sphere, colorScheme: ColorScheme = ColorScheme(), size: AgentSize = .medium, effects: [VisualEffect] = []) {
        self.shape = shape
        self.colorScheme = colorScheme
        self.size = size
        self.effects = effects
    }

    static var `default`: VisualizationStyle {
        VisualizationStyle()
    }

    enum AgentShape: String, Codable {
        case sphere
        case cube
        case pyramid
        case custom
    }

    enum AgentSize: String, Codable {
        case small
        case medium
        case large
        case xlarge

        var scale: Float {
            switch self {
            case .small: return 0.5
            case .medium: return 1.0
            case .large: return 1.5
            case .xlarge: return 2.0
            }
        }
    }

    struct ColorScheme: Codable {
        var primary: String
        var accent: String
        var status: String

        init(primary: String = "#00A3FF", accent: String = "#007AFF", status: String = "#34C759") {
            self.primary = primary
            self.accent = accent
            self.status = status
        }
    }
}

enum VisualEffect: String, Codable {
    case glow
    case pulse
    case particles
    case trail
    case shimmer
}
