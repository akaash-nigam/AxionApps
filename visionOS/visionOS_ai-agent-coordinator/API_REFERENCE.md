# API Reference - AI Agent Coordinator

## Document Information
- **Version**: 1.0.0
- **Last Updated**: 2025-01-20
- **Status**: Production Ready
- **Platform**: visionOS 2.0+

## Table of Contents
1. [Service APIs](#service-apis)
2. [Platform Adapter APIs](#platform-adapter-apis)
3. [View Model APIs](#view-model-apis)
4. [Data Models](#data-models)
5. [Network APIs](#network-apis)
6. [Utility APIs](#utility-apis)

---

## Service APIs

### AgentCoordinator

Central service for managing AI agents and their lifecycle.

#### Class Definition
```swift
@Observable
class AgentCoordinator {
    private let repository: AgentRepository
    private let metricsCollector: MetricsCollector
    private let visualizationEngine: VisualizationEngine

    var agents: [UUID: AIAgent]
    var activeConnections: [AgentConnection]
}
```

#### Methods

##### loadAgents()
Loads all agents from the repository.

```swift
func loadAgents() async throws -> [AIAgent]
```

**Returns**: Array of all available AI agents

**Throws**:
- `AgentError.loadFailed` - Failed to load agents from repository
- `AgentError.networkError` - Network connection failed

**Example**:
```swift
do {
    let agents = try await coordinator.loadAgents()
    print("Loaded \(agents.count) agents")
} catch {
    print("Failed to load agents: \(error)")
}
```

##### startAgent(_:)
Starts a specific agent by ID.

```swift
func startAgent(_ agentId: UUID) async throws
```

**Parameters**:
- `agentId`: UUID of the agent to start

**Throws**:
- `AgentError.notFound` - Agent with specified ID not found
- `AgentError.alreadyRunning` - Agent is already active
- `AgentError.startFailed` - Failed to start agent

**Example**:
```swift
try await coordinator.startAgent(myAgentId)
```

##### stopAgent(_:)
Stops a running agent.

```swift
func stopAgent(_ agentId: UUID) async throws
```

**Parameters**:
- `agentId`: UUID of the agent to stop

**Throws**:
- `AgentError.notFound` - Agent with specified ID not found
- `AgentError.notRunning` - Agent is not currently active
- `AgentError.stopFailed` - Failed to stop agent

##### createConnection(from:to:type:)
Creates a connection between two agents.

```swift
func createConnection(
    from sourceId: UUID,
    to targetId: UUID,
    type: ConnectionType = .synchronous
) async throws -> AgentConnection
```

**Parameters**:
- `sourceId`: UUID of source agent
- `targetId`: UUID of target agent
- `type`: Type of connection (default: .synchronous)

**Returns**: The created AgentConnection

**Throws**:
- `AgentError.connectionFailed` - Failed to establish connection

##### startMonitoring(updateInterval:)
Starts real-time monitoring of all agents.

```swift
func startMonitoring(updateInterval: TimeInterval = 5.0)
```

**Parameters**:
- `updateInterval`: How often to poll for updates (in seconds)

---

### MetricsCollector

Service for collecting and aggregating agent metrics.

#### Class Definition
```swift
actor MetricsCollector {
    private var collectors: [UUID: AgentMetricsStream]
}
```

#### Methods

##### startCollecting(agentId:interval:)
Starts collecting metrics for a specific agent.

```swift
func startCollecting(agentId: UUID, interval: TimeInterval) async
```

**Parameters**:
- `agentId`: UUID of the agent to monitor
- `interval`: Collection interval in seconds

**Example**:
```swift
await metricsCollector.startCollecting(
    agentId: myAgent.id,
    interval: 10.0
)
```

##### stopCollecting(agentId:)
Stops collecting metrics for a specific agent.

```swift
func stopCollecting(agentId: UUID) async
```

##### getLatestMetrics(agentId:)
Retrieves the most recent metrics for an agent.

```swift
func getLatestMetrics(agentId: UUID) async -> AgentMetrics?
```

**Returns**: Latest metrics or nil if not available

##### getHistoricalMetrics(agentId:from:to:)
Retrieves historical metrics for a time range.

```swift
func getHistoricalMetrics(
    agentId: UUID,
    from startDate: Date,
    to endDate: Date
) async -> [AgentMetrics]
```

**Returns**: Array of metrics within the specified time range

**Example**:
```swift
let yesterday = Date().addingTimeInterval(-86400)
let metrics = await metricsCollector.getHistoricalMetrics(
    agentId: myAgent.id,
    from: yesterday,
    to: Date()
)
```

---

### VisualizationEngine

Service for generating 3D visualizations of agent networks.

#### Class Definition
```swift
class VisualizationEngine {
    private let layoutCache: NSCache<NSString, GalaxyLayout>
}
```

#### Methods

##### generateGalaxyLayout(agents:connections:)
Generates a galaxy-style 3D layout for agents.

```swift
func generateGalaxyLayout(
    agents: [AIAgent],
    connections: [AgentConnection]
) -> GalaxyLayout
```

**Parameters**:
- `agents`: Array of agents to visualize
- `connections`: Array of connections between agents

**Returns**: GalaxyLayout containing 3D positions and styles

**Example**:
```swift
let layout = visualizationEngine.generateGalaxyLayout(
    agents: allAgents,
    connections: allConnections
)
```

##### generatePerformanceLandscape(metrics:)
Generates a 3D landscape based on performance metrics.

```swift
func generatePerformanceLandscape(
    metrics: [AgentMetrics]
) -> LandscapeLayout
```

**Returns**: LandscapeLayout with height based on performance

##### updateSpatialPositions(agents:layout:)
Updates agent positions in 3D space using specified algorithm.

```swift
func updateSpatialPositions(
    agents: [AIAgent],
    layout: LayoutAlgorithm
) async
```

**Parameters**:
- `agents`: Agents to reposition
- `layout`: Algorithm to use (galaxy, grid, cluster, etc.)

---

### AgentRepository

Data access layer for agent persistence.

#### Class Definition
```swift
class AgentRepository {
    private let modelContext: ModelContext
    private let cache: NSCache<NSUUID, AIAgent>
}
```

#### Methods

##### fetchAll()
Fetches all agents from persistent storage.

```swift
func fetchAll() async throws -> [AIAgent]
```

**Returns**: Array of all stored agents

##### fetch(id:)
Fetches a specific agent by ID.

```swift
func fetch(id: UUID) async throws -> AIAgent
```

**Throws**:
- `RepositoryError.notFound` - Agent not found

##### save(_:)
Saves an agent to persistent storage.

```swift
func save(_ agent: AIAgent) async throws
```

##### delete(id:)
Deletes an agent from storage.

```swift
func delete(id: UUID) async throws
```

##### search(query:filter:)
Searches agents with optional filters.

```swift
func search(
    query: String?,
    filter: AgentFilter?
) async throws -> [AIAgent]
```

**Parameters**:
- `query`: Search string (searches name, tags)
- `filter`: Optional filter criteria

**Returns**: Matching agents

---

### CollaborationManager

Service for multi-user collaboration via SharePlay.

#### Class Definition
```swift
@Observable
class CollaborationManager {
    var isSessionActive: Bool
    var participants: [Participant]
    var sharedWorkspace: SharedWorkspace?
}
```

#### Methods

##### startSession()
Starts a new collaboration session.

```swift
func startSession() async throws
```

**Throws**:
- `CollaborationError.sharePlayNotAvailable`
- `CollaborationError.startFailed`

##### endSession()
Ends the current collaboration session.

```swift
func endSession() async
```

##### shareAgentSelection(_:)
Shares selected agents with all participants.

```swift
func shareAgentSelection(_ agentIds: [UUID]) async throws
```

##### syncWorkspace()
Synchronizes workspace state across all participants.

```swift
func syncWorkspace() async throws
```

---

## Platform Adapter APIs

### PlatformAdapter Protocol

Base protocol for all AI platform integrations.

```swift
protocol AIPlatformAdapter {
    var platform: AIPlatform { get }

    func connect(credentials: PlatformCredentials) async throws
    func disconnect() async throws
    func isConnected() -> Bool

    func listAgents() async throws -> [ExternalAgent]
    func getAgentMetrics(agentId: String) async throws -> [MetricDataPoint]
    func invokeAgent(agentId: String, input: AgentInput) async throws -> AgentOutput

    func subscribeToMetrics(agentId: String) -> AsyncStream<MetricDataPoint>
    func subscribeToLogs(agentId: String) -> AsyncStream<LogEntry>
}
```

### OpenAIAdapter

Adapter for OpenAI platform integration.

#### Methods

##### connect(credentials:)
Connects to OpenAI API.

```swift
func connect(credentials: PlatformCredentials) async throws
```

**Parameters**:
- `credentials`: Must be `.apiKey(String)`

**Throws**:
- `AdapterError.invalidCredentials`
- `AdapterError.connectionFailed`

**Example**:
```swift
let adapter = OpenAIAdapter()
try await adapter.connect(
    credentials: .apiKey("sk-...")
)
```

##### listAgents()
Lists available OpenAI models and assistants.

```swift
func listAgents() async throws -> [ExternalAgent]
```

**Returns**: Array of available models and assistants

### AWSSageMakerAdapter

Adapter for AWS SageMaker integration.

#### Methods

##### connect(credentials:)
Connects to AWS SageMaker.

```swift
func connect(credentials: PlatformCredentials) async throws
```

**Parameters**:
- `credentials`: Must be `.aws(accessKey, secretKey, region)`

**Example**:
```swift
let adapter = AWSSageMakerAdapter()
try await adapter.connect(
    credentials: .aws(
        accessKey: "AKIA...",
        secretKey: "...",
        region: "us-west-2"
    )
)
```

##### listAgents()
Lists SageMaker endpoints.

```swift
func listAgents() async throws -> [ExternalAgent]
```

##### getAgentMetrics(agentId:)
Retrieves CloudWatch metrics for an endpoint.

```swift
func getAgentMetrics(agentId: String) async throws -> [MetricDataPoint]
```

---

## View Model APIs

### AgentNetworkViewModel

View model for agent network visualization.

#### Class Definition
```swift
@Observable
@MainActor
class AgentNetworkViewModel {
    var agents: [AIAgent]
    var connections: [AgentConnection]
    var layout: GalaxyLayout?
    var isLoading: Bool
    var error: Error?

    var searchQuery: String
    var statusFilter: Set<AgentStatus>
    var typeFilter: Set<AgentType>
}
```

#### Computed Properties

##### filteredAgents
Returns agents matching current filters.

```swift
var filteredAgents: [AIAgent] { get }
```

##### healthyAgentsCount
Count of healthy agents.

```swift
var healthyAgentsCount: Int { get }
```

##### errorAgentsCount
Count of agents in error state.

```swift
var errorAgentsCount: Int { get }
```

#### Methods

##### loadAgents()
Loads agents from coordinator.

```swift
func loadAgents() async
```

##### selectAgent(_:)
Selects an agent for detailed view.

```swift
func selectAgent(_ agentId: UUID)
```

##### startMonitoring()
Starts real-time updates.

```swift
func startMonitoring()
```

---

### PerformanceViewModel

View model for performance monitoring.

#### Class Definition
```swift
@Observable
@MainActor
class PerformanceViewModel {
    var allMetrics: [UUID: [AgentMetrics]]
    var aggregateStats: AggregateStats?
    var timeRange: TimeRange
}
```

#### Methods

##### loadMetrics()
Loads performance metrics.

```swift
func loadMetrics() async
```

##### updateTimeRange(_:)
Updates the time range for metrics display.

```swift
func updateTimeRange(_ range: TimeRange)
```

##### exportMetrics()
Exports metrics to CSV.

```swift
func exportMetrics() async throws -> URL
```

---

## Data Models

### AIAgent

Core model for AI agents.

```swift
@Model
class AIAgent: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: AgentType
    var status: AgentStatus
    var createdAt: Date
    var lastActiveAt: Date
    var configuration: AgentConfiguration
    var capabilities: [AgentCapability]
    var connections: [AgentConnection]
    var currentMetrics: AgentMetrics?
    var healthScore: Double
    var spatialPosition: SpatialPosition?
}
```

#### Properties

- **id**: Unique identifier
- **name**: Display name
- **type**: Agent type (llm, taskSpecific, autonomous, etc.)
- **status**: Current status (active, idle, error, etc.)
- **healthScore**: Overall health (0.0 to 1.0)

#### Enumerations

##### AgentType
```swift
enum AgentType: String, Codable {
    case llm
    case taskSpecific
    case autonomous
    case monitoring
    case orchestration
    case dataProcessing
    case security
    case custom
}
```

##### AgentStatus
```swift
enum AgentStatus: String, Codable {
    case active
    case idle
    case learning
    case error
    case optimizing
    case paused
    case terminated
}
```

---

### AgentMetrics

Performance metrics for an agent.

```swift
@Model
class AgentMetrics: Identifiable {
    @Attribute(.unique) var id: UUID
    var agentId: UUID
    var timestamp: Date

    // Performance
    var requestsPerSecond: Double
    var averageLatency: TimeInterval
    var p95Latency: TimeInterval
    var p99Latency: TimeInterval
    var errorRate: Double

    // Resources
    var cpuUsage: Double
    var memoryUsage: Int64
    var networkBytesIn: Int64
    var networkBytesOut: Int64

    // Quality
    var successRate: Double
    var accuracyScore: Double?
    var throughput: Double

    // Cost
    var apiCallsCount: Int
    var estimatedCost: Decimal
}
```

---

### AgentConnection

Connection between two agents.

```swift
struct AgentConnection: Codable, Identifiable {
    var id: UUID
    var sourceAgentId: UUID
    var targetAgentId: UUID
    var connectionType: ConnectionType
    var dataFlow: DataFlowMetrics
    var protocol: CommunicationProtocol
    var health: ConnectionHealth
}
```

#### Enumerations

##### ConnectionType
```swift
enum ConnectionType: String, Codable {
    case synchronous
    case asynchronous
    case streaming
    case batch
}
```

##### CommunicationProtocol
```swift
enum CommunicationProtocol: String, Codable {
    case rest
    case grpc
    case websocket
    case messageQueue
    case custom
}
```

---

## Network APIs

### NetworkClient

HTTP client for backend communication.

```swift
class NetworkClient {
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T
}
```

#### Methods

##### request(_:method:body:)
Makes an HTTP request.

**Parameters**:
- `endpoint`: API endpoint
- `method`: HTTP method (GET, POST, PUT, DELETE)
- `body`: Optional request body

**Returns**: Decoded response

**Throws**:
- `NetworkError.invalidResponse`
- `NetworkError.decodingFailed`
- `NetworkError.unauthorized`

**Example**:
```swift
struct AgentResponse: Decodable {
    let agents: [AIAgent]
}

let response: AgentResponse = try await networkClient.request(
    .listAgents,
    method: .get
)
```

---

### WebSocketManager

WebSocket manager for real-time updates.

```swift
actor WebSocketManager {
    func connect(to url: URL) async throws -> UUID
    func disconnect(_ connectionId: UUID) async
    func subscribe(connectionId: UUID, to channel: String) async throws
}
```

---

## Utility APIs

### Logger

Logging utility with multiple severity levels.

```swift
class Logger {
    static func debug(_ message: String, file: String = #file, line: Int = #line)
    static func info(_ message: String)
    static func warning(_ message: String)
    static func error(_ message: String, error: Error? = nil)
}
```

**Example**:
```swift
Logger.info("Agent started successfully")
Logger.error("Failed to load agents", error: loadError)
```

---

## Error Handling

### Common Error Types

#### AgentError
```swift
enum AgentError: Error {
    case notFound(UUID)
    case alreadyRunning(UUID)
    case notRunning(UUID)
    case startFailed(Error)
    case stopFailed(Error)
    case loadFailed(Error)
    case connectionFailed(Error)
    case networkError(Error)
}
```

#### NetworkError
```swift
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case decodingFailed(Error)
    case encodingFailed(Error)
    case timeout
    case noConnection
}
```

#### AdapterError
```swift
enum AdapterError: Error {
    case notConnected
    case invalidCredentials
    case connectionFailed(Error)
    case unsupportedOperation
}
```

---

## Best Practices

### Async/Await Usage

Always use async/await for asynchronous operations:

```swift
// Good
func loadData() async {
    do {
        let agents = try await coordinator.loadAgents()
        // Process agents
    } catch {
        Logger.error("Failed to load agents", error: error)
    }
}

// Avoid
func loadDataOld(completion: @escaping ([AIAgent]?, Error?) -> Void) {
    // Old-style completion handlers
}
```

### Actor Isolation

Use actors for thread-safe mutable state:

```swift
actor MetricsCache {
    private var cache: [UUID: AgentMetrics] = [:]

    func get(_ id: UUID) -> AgentMetrics? {
        cache[id]
    }

    func set(_ id: UUID, metrics: AgentMetrics) {
        cache[id] = metrics
    }
}
```

### Error Propagation

Use Result type for operations that can fail:

```swift
func loadAgent(_ id: UUID) async -> Result<AIAgent, AgentError> {
    do {
        let agent = try await repository.fetch(id: id)
        return .success(agent)
    } catch {
        return .failure(.notFound(id))
    }
}
```

---

## Version History

### 1.0.0 (2025-01-20)
- Initial API documentation
- Core service APIs
- Platform adapter interfaces
- View model APIs
- Data model documentation

---

## Support

For API questions or issues:
- GitHub Issues: [visionOS_ai-agent-coordinator/issues](https://github.com/yourusername/visionOS_ai-agent-coordinator/issues)
- Email: support@aiagentcoordinator.dev
- Documentation: [https://docs.aiagentcoordinator.dev](https://docs.aiagentcoordinator.dev)
