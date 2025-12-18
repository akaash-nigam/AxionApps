# API Reference - Spatial CRM

**Version**: 1.0
**Platform**: visionOS 2.0+
**Language**: Swift 6.0
**Last Updated**: 2025-11-17

Complete API reference for all public interfaces in Spatial CRM.

---

## Quick Navigation

- [Data Models](#data-models) - SwiftData entities
- [Services](#services) - Business logic and AI
- [Views](#views) - SwiftUI components
- [Enums](#enums--types) - Type definitions
- [Usage Examples](#usage-examples) - Code samples

---

## Data Models

All models use `@Model` macro for SwiftData persistence.

### Account

Customer account/company representation.

**Properties:**
```swift
@Attribute(.unique) var id: UUID
var name: String
var industry: String?
var revenue: Decimal
var employeeCount: Int
var healthScore: Double          // 0-100
var tier: AccountTier            // .enterprise, .corporate, .standard, .startup
var status: AccountStatus        // .active, .inactive, .prospect, .churned
var createdAt: Date
var updatedAt: Date

// Spatial positioning
var positionX, positionY, positionZ: Float
var position: SIMD3<Float> { get set }

// Relationships
@Relationship(deleteRule: .cascade) var contacts: [Contact]
@Relationship(deleteRule: .cascade) var opportunities: [Opportunity]
@Relationship(deleteRule: .cascade) var activities: [Activity]
@Relationship(deleteRule: .nullify) var territory: Territory?
```

**Methods:**
```swift
init(name: String, industry: String? = nil, revenue: Decimal = 0, ...)
func updateHealthScore()
func getOpenOpportunities() -> [Opportunity]
```

**Computed Properties:**
```swift
var totalOpportunityValue: Decimal { get }
var activeOpportunitiesCount: Int { get }
```

---

### Contact

Individual person at an account.

**Properties:**
```swift
@Attribute(.unique) var id: UUID
var firstName, lastName: String
var email: String
var phone, title: String?
var role: ContactRole            // .champion, .decisionMaker, .influencer, .user, .blocker
var influenceLevel: Int          // 1-10
var department, linkedin: String?
var createdAt, updatedAt: Date

// Relationships
@Relationship(deleteRule: .nullify) var account: Account?
@Relationship(deleteRule: .cascade) var activities: [Activity]
@Relationship(deleteRule: .nullify) var opportunities: [Opportunity]
```

**Methods:**
```swift
init(firstName: String, lastName: String, email: String, ...)
func isValidEmail() -> Bool
func recentActivities(limit: Int = 10) -> [Activity]
```

**Computed Properties:**
```swift
var fullName: String { get }
var isDecisionMaker: Bool { get }
```

---

### Opportunity

Sales deal/opportunity.

**Properties:**
```swift
@Attribute(.unique) var id: UUID
var name: String
var amount: Decimal
var stage: DealStage             // .prospecting ... .closedWon/.closedLost
var probability: Int             // 0-100
var expectedCloseDate: Date
var closeDate: Date?
var status: DealStatus           // .open, .won, .lost, .abandoned
var source: String?
var competitors: [String]
var aiScore: Double              // AI-calculated score
var createdAt, updatedAt: Date
var lastStageChangeAt: Date

// Pipeline positioning
var pipelinePositionX, pipelinePositionY, pipelinePositionZ: Float

// Relationships
@Relationship(deleteRule: .nullify) var account: Account?
@Relationship(deleteRule: .nullify) var primaryContact: Contact?
@Relationship(deleteRule: .cascade) var activities: [Activity]
```

**Methods:**
```swift
init(name: String, amount: Decimal, stage: DealStage = .prospecting, ...)
func progress(to newStage: DealStage)
func close(won: Bool)
func daysUntilClose() -> Int
func isAtRisk() -> Bool
```

**Computed Properties:**
```swift
var isOverdue: Bool { get }
var daysInStage: Int { get }
var weightedValue: Decimal { get }
```

---

### Activity

Customer interaction or task.

**Properties:**
```swift
@Attribute(.unique) var id: UUID
var type: ActivityType           // .call, .email, .meeting, .demo, etc.
var subject: String
var description: String?
var status: ActivityStatus       // .planned, .inProgress, .completed, .cancelled
var priority: ActivityPriority   // .low, .medium, .high, .urgent
var dueDate, completedDate: Date?
var duration: Int?               // minutes
var outcome: String?

// Relationships
@Relationship(deleteRule: .nullify) var account: Account?
@Relationship(deleteRule: .nullify) var contact: Contact?
@Relationship(deleteRule: .nullify) var opportunity: Opportunity?
```

**Methods:**
```swift
init(type: ActivityType, subject: String, ...)
func complete(outcome: String? = nil)
func updateStatus(_ newStatus: ActivityStatus)
```

**Computed Properties:**
```swift
var isOverdue: Bool { get }
var isCompleted: Bool { get }
```

---

### Territory

Sales territory/region.

**Properties:**
```swift
@Attribute(.unique) var id: UUID
var name, region: String
var quota, currentRevenue: Decimal
var accountCount: Int

// Relationships
@Relationship(deleteRule: .nullify) var accounts: [Account]
@Relationship(deleteRule: .nullify) var opportunities: [Opportunity]
```

**Computed Properties:**
```swift
var quotaAttainment: Double { get }
var isOnTrack: Bool { get }
```

---

### CollaborationSession

Multi-user collaborative session.

**Properties:**
```swift
@Attribute(.unique) var id: UUID
var name: String
var type: SessionType
var startedAt: Date
var endedAt: Date?
var participants: [String]       // User IDs
var accountId, opportunityId: UUID?
```

**Computed Properties:**
```swift
var isActive: Bool { get }
var duration: TimeInterval { get }
```

---

## Services

All services use `@Observable` for reactive state.

### CRMService

Main CRUD operations service.

**State:**
```swift
@Observable
final class CRMService {
    var accounts: [Account]
    var contacts: [Contact]
    var opportunities: [Opportunity]
    var activities: [Activity]
    var territories: [Territory]
    var isLoading: Bool
    var error: Error?
}
```

**Account Methods:**
```swift
func fetchAccounts() async throws -> [Account]
func createAccount(_ account: Account) async throws
func updateAccount(_ account: Account) async throws
func deleteAccount(_ account: Account) async throws
func searchAccounts(query: String) -> [Account]
```

**Contact Methods:**
```swift
func fetchContacts() async throws -> [Contact]
func createContact(_ contact: Contact) async throws
func updateContact(_ contact: Contact) async throws
func deleteContact(_ contact: Contact) async throws
func fetchContacts(for account: Account) async throws -> [Contact]
```

**Opportunity Methods:**
```swift
func fetchOpportunities() async throws -> [Opportunity]
func createOpportunity(_ opportunity: Opportunity) async throws
func updateOpportunity(_ opportunity: Opportunity) async throws
func deleteOpportunity(_ opportunity: Opportunity) async throws
func fetchOpportunities(stage: DealStage) async throws -> [Opportunity]
func fetchOpenOpportunities() async throws -> [Opportunity]
```

**Activity Methods:**
```swift
func fetchActivities() async throws -> [Activity]
func createActivity(_ activity: Activity) async throws
func updateActivity(_ activity: Activity) async throws
func deleteActivity(_ activity: Activity) async throws
func fetchActivities(for account: Account) async throws -> [Activity]
func fetchOverdueActivities() async throws -> [Activity]
```

---

### AIService

AI-powered intelligence and predictions.

**Types:**
```swift
struct AIScore {
    let value: Double              // 0-100
    let confidence: Double         // 0-1
    let factors: [String]
    let recommendations: [String]
}

struct NextAction {
    let action: String
    let reason: String
    let priority: Int
    let estimatedImpact: Double
}

struct DealInsight {
    let type: InsightType
    let message: String
    let severity: InsightSeverity
    let actionable: Bool
}
```

**Scoring Methods:**
```swift
func scoreOpportunity(_ opportunity: Opportunity) async throws -> AIScore
func predictWinProbability(_ opportunity: Opportunity) async throws -> AIScore
func predictChurnRisk(_ account: Account) async throws -> AIScore
func forecastPipeline() async throws -> AIScore
```

**Recommendation Methods:**
```swift
func suggestNextAction(for opportunity: Opportunity) async throws -> NextAction
func identifyCrossSell(for account: Account) async throws -> [NextAction]
func identifyUpsell(for account: Account) async throws -> [NextAction]
```

**Analysis Methods:**
```swift
func generateDealInsights(_ opportunity: Opportunity) async throws -> [DealInsight]
func analyzeSentiment(_ text: String) async throws -> Double
func calculateRelationshipStrength(account: Account, contact: Contact) async throws -> Double
func segmentCustomers(_ accounts: [Account]) async throws -> [String: [Account]]
func assessCompetitiveRisk(_ opportunity: Opportunity) async throws -> AIScore
func scoreEngagement(for account: Account) async throws -> Double
```

---

### SpatialService

3D layout and positioning calculations.

**Types:**
```swift
struct SpatialLayout {
    let positions: [UUID: SIMD3<Float>]
    let connections: [(UUID, UUID)]
    let bounds: BoundingBox
}

struct BoundingBox {
    let min, max, center, size: SIMD3<Float>
}
```

**Methods:**
```swift
func generateNetworkLayout(
    nodes: [UUID],
    edges: [(UUID, UUID)],
    iterations: Int = 100
) -> [UUID: SIMD3<Float>]

func calculatePipelineLayout(
    for opportunities: [Opportunity]
) -> [UUID: SIMD3<Float>]

func generateTerritoryMap(
    for territories: [Territory]
) -> SpatialLayout

func detectCollisions(
    positions: [UUID: SIMD3<Float>],
    radius: Float = 0.1
) -> [(UUID, UUID)]
```

---

## Views

### DashboardView

Main dashboard with metrics and activity.

```swift
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var accounts: [Account]
    @Query var opportunities: [Opportunity]
}
```

**Features**: Key metrics, activity feed, pipeline summary, quick actions

---

### PipelineView

Deal pipeline visualization.

```swift
struct PipelineView: View {
    @Query(sort: \Opportunity.expectedCloseDate) var opportunities: [Opportunity]
    @State private var selectedStage: DealStage?
}
```

**Features**: Stage organization, filtering, stage metrics

---

### CustomerGalaxyView

Immersive 3D customer universe.

```swift
struct CustomerGalaxyView: View {
    @Query(sort: \Account.revenue, order: .reverse) var accounts: [Account]
    @State private var selectedAccount: Account?
}
```

**Features**: Solar system layout, interactive selection, health-based coloring

---

### PipelineVolumeView

Volumetric pipeline river.

```swift
struct PipelineVolumeView: View {
    @Query var opportunities: [Opportunity]
}
```

**Features**: Flowing river visualization, stage-based positioning

---

## Enums & Types

### AccountTier
```swift
enum AccountTier: String, Codable {
    case enterprise, corporate, standard, startup
}
```

### AccountStatus
```swift
enum AccountStatus: String, Codable {
    case active, inactive, prospect, churned
}
```

### ContactRole
```swift
enum ContactRole: String, Codable {
    case champion, decisionMaker, influencer, user, blocker
}
```

### DealStage
```swift
enum DealStage: Int, Codable, CaseIterable {
    case prospecting = 0
    case qualification = 1
    case needsAnalysis = 2
    case proposal = 3
    case negotiation = 4
    case closedWon = 5
    case closedLost = 6
    
    var name: String { get }
    var color: Color { get }
    var typicalProbability: Int { get }
}
```

### DealStatus
```swift
enum DealStatus: String, Codable {
    case open, won, lost, abandoned
}
```

### ActivityType
```swift
enum ActivityType: String, Codable {
    case call, email, meeting, demo, proposal, task, note
}
```

### ActivityStatus
```swift
enum ActivityStatus: String, Codable {
    case planned, inProgress, completed, cancelled
}
```

### ActivityPriority
```swift
enum ActivityPriority: String, Codable {
    case low, medium, high, urgent
}
```

---

## Error Handling

### CRMError

```swift
enum CRMError: Error, LocalizedError {
    case notFound(String)
    case invalidData(String)
    case networkError(Error)
    case unauthorized
    case serverError(Int)
    case syncFailed(String)
    
    var errorDescription: String? { get }
}
```

**Usage:**
```swift
do {
    let accounts = try await crmService.fetchAccounts()
} catch let error as CRMError {
    switch error {
    case .notFound(let msg): print("Not found: \(msg)")
    case .networkError(let err): print("Network: \(err)")
    default: print(error.localizedDescription)
    }
}
```

---

## Usage Examples

### Creating an Account

```swift
let service = CRMService()

let account = Account(
    name: "Acme Corp",
    industry: "Technology",
    revenue: 5_000_000,
    employeeCount: 250,
    tier: .corporate
)

try await service.createAccount(account)
```

### AI Opportunity Scoring

```swift
let aiService = AIService()

let opportunity = Opportunity(
    name: "Enterprise Deal",
    amount: 500_000,
    stage: .negotiation,
    expectedCloseDate: Date().addingTimeInterval(30 * 86400)
)

let score = try await aiService.scoreOpportunity(opportunity)
print("Score: \(score.value) (confidence: \(score.confidence))")
for rec in score.recommendations {
    print("• \(rec)")
}
```

### SwiftData Queries

```swift
struct AccountListView: View {
    // All accounts, sorted by revenue
    @Query(sort: \Account.revenue, order: .reverse) 
    var accounts: [Account]
    
    // Only active accounts
    @Query(filter: #Predicate<Account> { $0.status == .active })
    var activeAccounts: [Account]
    
    var body: some View {
        List(accounts) { account in
            Text(account.name)
        }
    }
}
```

### Generating Spatial Layout

```swift
let spatialService = SpatialService()
let accountIds = accounts.map { $0.id }
let edges: [(UUID, UUID)] = /* connections */

let positions = spatialService.generateNetworkLayout(
    nodes: accountIds,
    edges: edges,
    iterations: 150
)

for account in accounts {
    if let position = positions[account.id] {
        account.position = position
    }
}
```

---

## Best Practices

### 1. Async/Await

```swift
// ✅ Good
Task {
    do {
        let accounts = try await service.fetchAccounts()
    } catch {
        // Handle error
    }
}

// ❌ Bad - don't block main thread
```

### 2. SwiftData Delete Rules

```swift
// Cascade - delete children with parent
@Relationship(deleteRule: .cascade) var contacts: [Contact]

// Nullify - set to nil when parent deleted
@Relationship(deleteRule: .nullify) var account: Account?

// Deny - prevent deletion if children exist
@Relationship(deleteRule: .deny) var owner: User?
```

### 3. Observable State in Views

```swift
struct ContentView: View {
    @State private var service = CRMService()
    
    var body: some View {
        if service.isLoading {
            ProgressView()
        } else {
            AccountList(accounts: service.accounts)
        }
    }
}
```

### 4. Error Handling

```swift
do {
    let data = try await service.fetchAccounts()
    self.accounts = data
} catch let error as CRMError {
    showError(error.localizedDescription)
} catch {
    showError("Unexpected error occurred")
}
```

---

## Additional Resources

- [Architecture Guide](../ARCHITECTURE.md)
- [Technical Specifications](../TECHNICAL_SPEC.md)
- [Implementation Plan](../IMPLEMENTATION_PLAN.md)
- [Testing Guide](../TESTING.md)

---

**Version**: 1.0 | **Last Updated**: 2025-11-17
