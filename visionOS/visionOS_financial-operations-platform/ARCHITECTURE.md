# Financial Operations Platform - System Architecture

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [visionOS Architecture Patterns](#visionos-architecture-patterns)
3. [System Components](#system-components)
4. [Data Models & Schemas](#data-models--schemas)
5. [Service Layer Architecture](#service-layer-architecture)
6. [RealityKit & ARKit Integration](#realitykit--arkit-integration)
7. [API Design & External Integrations](#api-design--external-integrations)
8. [State Management Strategy](#state-management-strategy)
9. [Performance Optimization](#performance-optimization)
10. [Security Architecture](#security-architecture)

---

## Architecture Overview

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    visionOS Application Layer                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Windows    │  │   Volumes    │  │ ImmersiveSpace│      │
│  │  (2D Views)  │  │ (3D Bounded) │  │ (Full Space) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                  Presentation & ViewModel Layer              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  SwiftUI Views + @Observable ViewModels (MVVM)       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     Business Logic Layer                     │
│  ┌───────────┐  ┌──────────┐  ┌────────────┐  ┌─────────┐ │
│  │ Financial │  │ Treasury │  │  Analytics │  │   AI    │ │
│  │  Services │  │ Services │  │  Services  │  │ Engine  │ │
│  └───────────┘  └──────────┘  └────────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ SwiftData│  │  Cache   │  │ Network  │  │ Real-time │  │
│  │ (Local)  │  │  Layer   │  │  Layer   │  │  Streams  │  │
│  └──────────┘  └──────────┘  └──────────┘  └───────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   External Integrations                      │
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │   ERP   │  │  Banking │  │  Market  │  │ Compliance │  │
│  │ Systems │  │   APIs   │  │   Data   │  │  Systems   │  │
│  └─────────┘  └──────────┘  └──────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Core Architectural Principles

1. **MVVM Pattern**: Clean separation between UI (SwiftUI Views), business logic (ViewModels), and data (Models)
2. **Entity Component System**: RealityKit ECS for 3D financial visualizations
3. **Reactive Architecture**: Swift Observation framework for real-time updates
4. **Microservices Integration**: Loosely coupled external system integrations
5. **Progressive Enhancement**: Start with Windows, progressively add Volumes and Immersive Spaces
6. **Offline-First**: Local data persistence with cloud synchronization

---

## visionOS Architecture Patterns

### Presentation Mode Strategy

#### WindowGroup (Primary Mode)
**Use Cases**:
- Transaction entry and processing
- Data grids and tables
- Forms and approvals
- Detailed analytics

**Implementation**:
```swift
WindowGroup {
    FinancialDashboardView()
}
.windowStyle(.automatic)
.defaultSize(width: 1200, height: 800)
```

**Key Features**:
- Multiple resizable windows
- Standard UI controls
- Familiar interaction patterns
- Optimal for data-heavy tasks

#### ImmersiveSpace (Volumetric Mode)
**Use Cases**:
- Cash Flow Universe visualization
- 3D Risk Topography
- Performance Galaxies
- Financial Close Environment

**Implementation**:
```swift
ImmersiveSpace(id: "cashflow-universe") {
    CashFlowUniverseView()
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)
```

**Key Features**:
- 3D financial landscapes
- Spatial data relationships
- Gesture-based navigation
- Immersive analysis experiences

#### Volumes (Bounded 3D)
**Use Cases**:
- KPI visualization cubes
- Mini financial models
- 3D charts and graphs
- Focused spatial content

**Implementation**:
```swift
WindowGroup(id: "kpi-volume") {
    KPIVolumeView()
}
.windowStyle(.volumetric)
.defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)
```

### Spatial Hierarchy

```
User Environment
├── Primary Window (Financial Dashboard)
│   ├── Transaction Grid
│   ├── Quick Actions Panel
│   └── Status Indicators
├── Volume: KPI Cube (Left, 0.5m away)
│   └── Real-time metrics in 3D
├── Volume: Risk Monitor (Right, 0.5m away)
│   └── Risk heat map
└── ImmersiveSpace: Cash Flow Universe (On-demand)
    ├── Revenue Rivers
    ├── Expense Valleys
    ├── Liquidity Lakes
    └── Investment Forests
```

---

## System Components

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      App Component                           │
│                 FinancialOpsApp.swift                        │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼──────┐  ┌────────▼────────┐
│   Dashboard    │  │  Treasury   │  │   Analytics     │
│   Module       │  │   Module    │  │    Module       │
└────────────────┘  └─────────────┘  └─────────────────┘
        │                   │                   │
┌───────▼──────────────────▼───────────────────▼────────┐
│              Shared Services Layer                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐    │
│  │ Financial│  │   AI     │  │  Notification    │    │
│  │  Engine  │  │ Services │  │    Service       │    │
│  └──────────┘  └──────────┘  └──────────────────┘    │
└────────────────────────────────────────────────────────┘
        │
┌───────▼──────────────────────────────────────────────┐
│              Data Management Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │SwiftData │  │  Cache   │  │   API Client     │   │
│  │ Manager  │  │ Manager  │  │    Manager       │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
└───────────────────────────────────────────────────────┘
```

### Core Modules

#### 1. Dashboard Module
- **Purpose**: Central command center for financial operations
- **Components**:
  - `DashboardView`: Main SwiftUI view
  - `DashboardViewModel`: State management and business logic
  - `KPICardComponent`: Reusable metric display
  - `TransactionListComponent`: Transaction grid
  - `QuickActionsPanel`: Common operations

#### 2. Treasury Module
- **Purpose**: Cash management and liquidity optimization
- **Components**:
  - `CashPositionView`: Real-time cash visibility
  - `LiquidityForecastView`: Predictive cash flow
  - `TreasuryViewModel`: Treasury operations logic
  - `CashFlowUniverseView`: 3D visualization (ImmersiveSpace)

#### 3. Analytics Module
- **Purpose**: Financial analysis and reporting
- **Components**:
  - `VarianceAnalysisView`: Plan vs. actual
  - `TrendAnalysisView`: Historical patterns
  - `ScenarioModelingView`: Predictive scenarios
  - `PerformanceGalaxyView`: 3D performance visualization

#### 4. Close Management Module
- **Purpose**: Period-end close orchestration
- **Components**:
  - `CloseChecklistView`: Task management
  - `ReconciliationView`: Account matching
  - `JournalEntryView`: Transaction posting
  - `CloseEnvironmentView`: 3D close workspace

#### 5. Compliance Module
- **Purpose**: Regulatory compliance and audit
- **Components**:
  - `AuditTrailView`: Transaction history
  - `ComplianceMonitorView`: SOX controls
  - `PolicyEnforcementView`: Rule management

---

## Data Models & Schemas

### Core Domain Models

#### Financial Transaction
```swift
@Model
final class FinancialTransaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var transactionDate: Date
    var postingDate: Date
    var accountCode: String
    var amount: Decimal
    var currency: Currency
    var description: String
    var transactionType: TransactionType
    var status: TransactionStatus
    var createdBy: String
    var createdAt: Date
    var approvedBy: String?
    var approvedAt: Date?
    var metadata: [String: String]

    // Relationships
    var account: Account?
    var counterpartyAccount: Account?
    var journalEntry: JournalEntry?
}

enum TransactionType: String, Codable {
    case revenue, expense, asset, liability, equity
}

enum TransactionStatus: String, Codable {
    case draft, pending, approved, posted, reconciled
}
```

#### Account
```swift
@Model
final class Account: Identifiable {
    @Attribute(.unique) var id: UUID
    var accountCode: String
    var accountName: String
    var accountType: AccountType
    var currency: Currency
    var balance: Decimal
    var isActive: Bool
    var costCenter: String?
    var department: String?
    var region: String?

    // Relationships
    var transactions: [FinancialTransaction]
    var budgets: [Budget]
}

enum AccountType: String, Codable {
    case asset, liability, equity, revenue, expense
}
```

#### Cash Position
```swift
@Model
final class CashPosition: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var currency: Currency
    var beginningBalance: Decimal
    var receipts: Decimal
    var disbursements: Decimal
    var endingBalance: Decimal
    var forecastedBalance: Decimal?
    var bankAccount: String
    var region: String

    // Relationships
    var cashFlows: [CashFlow]
}
```

#### Cash Flow
```swift
@Model
final class CashFlow: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Decimal
    var currency: Currency
    var flowType: CashFlowType
    var category: String
    var description: String
    var isActual: Bool
    var confidence: Double? // For forecasts

    // 3D Visualization Properties
    var spatialPosition: SIMD3<Float>?
    var flowVelocity: SIMD3<Float>?
    var flowColor: CodableColor?
}

enum CashFlowType: String, Codable {
    case operating, investing, financing
}
```

#### KPI (Key Performance Indicator)
```swift
@Model
final class KPI: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: KPICategory
    var currentValue: Decimal
    var targetValue: Decimal
    var previousValue: Decimal
    var unit: String
    var trend: TrendDirection
    var lastUpdated: Date
    var updateFrequency: UpdateFrequency

    // Spatial Visualization
    var displayPosition: SIMD3<Float>
    var visualizationType: VisualizationType
}

enum KPICategory: String, Codable {
    case liquidity, profitability, efficiency, risk
}

enum TrendDirection: String, Codable {
    case up, down, stable
}

enum VisualizationType: String, Codable {
    case gauge, chart, spatial3D
}
```

#### Risk Assessment
```swift
@Model
final class RiskAssessment: Identifiable {
    @Attribute(.unique) var id: UUID
    var riskType: RiskType
    var severity: RiskSeverity
    var probability: Double
    var impact: Decimal
    var description: String
    var mitigationStrategy: String?
    var owner: String
    var status: RiskStatus
    var identifiedDate: Date
    var reviewDate: Date

    // Spatial Properties for Risk Topography
    var topographyPosition: SIMD3<Float>
    var topographyElevation: Float // Higher = more severe
}

enum RiskType: String, Codable {
    case market, credit, liquidity, operational, compliance
}

enum RiskSeverity: String, Codable {
    case low, medium, high, critical
}

enum RiskStatus: String, Codable {
    case identified, assessing, mitigating, resolved
}
```

#### Close Task
```swift
@Model
final class CloseTask: Identifiable {
    @Attribute(.unique) var id: UUID
    var taskName: String
    var taskDescription: String
    var period: ClosePeriod
    var assignee: String
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date
    var completedDate: Date?
    var dependencies: [UUID] // IDs of dependent tasks
    var estimatedHours: Double
    var actualHours: Double?

    // 3D Visualization in Close Environment
    var mountainHeight: Float // Task complexity
    var spatialPosition: SIMD3<Float>
}

enum TaskStatus: String, Codable {
    case notStarted, inProgress, blocked, completed, verified
}

enum TaskPriority: String, Codable {
    case low, medium, high, critical
}
```

### Supporting Models

#### Currency
```swift
struct Currency: Codable, Hashable {
    let code: String // ISO 4217
    let symbol: String
    let name: String
}
```

#### ClosePeriod
```swift
struct ClosePeriod: Codable, Hashable {
    let year: Int
    let month: Int
    let type: PeriodType

    enum PeriodType: String, Codable {
        case monthly, quarterly, annual
    }
}
```

#### Budget
```swift
@Model
final class Budget: Identifiable {
    @Attribute(.unique) var id: UUID
    var account: Account?
    var period: ClosePeriod
    var budgetAmount: Decimal
    var actualAmount: Decimal
    var variance: Decimal
    var variancePercent: Double
}
```

---

## Service Layer Architecture

### Service Architecture Pattern

```
┌─────────────────────────────────────────────┐
│           Service Protocol Layer            │
│  (Defines contracts for all services)       │
└─────────────────────────────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
┌───▼────┐   ┌─────▼─────┐   ┌────▼────┐
│Business│   │Integration│   │Utility  │
│Services│   │ Services  │   │Services │
└────────┘   └───────────┘   └─────────┘
```

### Core Services

#### 1. FinancialDataService
**Responsibility**: Core financial data operations

```swift
@Observable
final class FinancialDataService {
    // Dependencies
    private let dataStore: SwiftDataManager
    private let apiClient: APIClient

    // Public Interface
    func fetchTransactions(
        dateRange: DateInterval,
        accounts: [String]?
    ) async throws -> [FinancialTransaction]

    func postTransaction(
        _ transaction: FinancialTransaction
    ) async throws -> FinancialTransaction

    func reconcileAccount(
        _ account: Account,
        statement: BankStatement
    ) async throws -> ReconciliationResult

    func calculateAccountBalance(
        _ account: Account,
        asOf date: Date
    ) async throws -> Decimal
}
```

#### 2. TreasuryService
**Responsibility**: Cash management and forecasting

```swift
@Observable
final class TreasuryService {
    // Cash Position Management
    func getCurrentCashPosition(
        currency: Currency?,
        region: String?
    ) async throws -> [CashPosition]

    func forecastCashFlow(
        period: DateInterval,
        scenario: ScenarioType
    ) async throws -> CashFlowForecast

    func optimizeLiquidity(
        constraints: LiquidityConstraints
    ) async throws -> LiquidityOptimization

    // Investment Management
    func recommendInvestments(
        availableCash: Decimal,
        riskTolerance: RiskTolerance
    ) async throws -> [InvestmentRecommendation]
}
```

#### 3. AIAnalyticsService
**Responsibility**: AI-powered insights and predictions

```swift
@Observable
final class AIAnalyticsService {
    func detectAnomalies(
        transactions: [FinancialTransaction]
    ) async throws -> [Anomaly]

    func predictCashFlow(
        historicalData: [CashFlow],
        horizon: Int // days
    ) async throws -> [PredictedCashFlow]

    func generateInsights(
        context: AnalysisContext
    ) async throws -> [FinancialInsight]

    func optimizeWorkingCapital(
        currentState: WorkingCapitalState
    ) async throws -> OptimizationRecommendations
}
```

#### 4. CloseManagementService
**Responsibility**: Period-end close orchestration

```swift
@Observable
final class CloseManagementService {
    func createClosePeriod(
        _ period: ClosePeriod
    ) async throws -> CloseProcess

    func getCloseTasks(
        period: ClosePeriod
    ) async throws -> [CloseTask]

    func completeTask(
        _ task: CloseTask,
        verification: TaskVerification
    ) async throws -> CloseTask

    func generateCloseReport(
        period: ClosePeriod
    ) async throws -> CloseReport
}
```

#### 5. ComplianceService
**Responsibility**: Regulatory compliance and audit

```swift
@Observable
final class ComplianceService {
    func validateTransaction(
        _ transaction: FinancialTransaction
    ) async throws -> ValidationResult

    func checkSOXControls(
        period: ClosePeriod
    ) async throws -> [ControlCheckResult]

    func generateAuditTrail(
        entity: AuditableEntity,
        dateRange: DateInterval
    ) async throws -> AuditTrail

    func enforceSegregationOfDuties(
        user: User,
        action: FinancialAction
    ) async throws -> AuthorizationResult
}
```

#### 6. IntegrationService
**Responsibility**: External system connectivity

```swift
@Observable
final class IntegrationService {
    // ERP Integration
    func syncERPData(
        system: ERPSystem
    ) async throws -> SyncResult

    // Banking Integration
    func fetchBankTransactions(
        account: BankAccount,
        dateRange: DateInterval
    ) async throws -> [BankTransaction]

    // Market Data
    func fetchExchangeRates(
        currencies: [Currency]
    ) async throws -> [ExchangeRate]

    // Real-time Streaming
    func subscribeToTransactionStream() -> AsyncStream<FinancialTransaction>
}
```

#### 7. SpatialVisualizationService
**Responsibility**: 3D data transformation for RealityKit

```swift
@Observable
final class SpatialVisualizationService {
    func generateCashFlowUniverse(
        data: [CashFlow]
    ) async -> CashFlowUniverseData

    func generateRiskTopography(
        risks: [RiskAssessment]
    ) async -> RiskTopographyData

    func generatePerformanceGalaxy(
        kpis: [KPI]
    ) async -> PerformanceGalaxyData

    func updateSpatialPositions(
        entities: [SpatialEntity],
        layout: SpatialLayout
    ) async -> [UpdatedEntity]
}
```

---

## RealityKit & ARKit Integration

### RealityKit Architecture

#### Entity Component System (ECS)

```
Financial Entities in 3D Space
├── CashFlowEntity
│   ├── ModelComponent (river mesh)
│   ├── TransformComponent (position/rotation)
│   ├── CollisionComponent (interaction)
│   └── CustomComponents
│       ├── FlowVelocityComponent
│       └── FlowAmountComponent
├── RiskEntity
│   ├── ModelComponent (terrain mesh)
│   ├── MaterialComponent (risk heat map)
│   └── CustomComponents
│       └── RiskSeverityComponent
└── KPIEntity
    ├── ModelComponent (visualization geometry)
    ├── AnimationComponent (value changes)
    └── CustomComponents
        └── KPIDataComponent
```

#### Custom Components

```swift
// Flow Velocity Component for Cash Flows
struct FlowVelocityComponent: Component {
    var velocity: SIMD3<Float>
    var magnitude: Float
    var direction: SIMD3<Float>
}

// Risk Severity Component
struct RiskSeverityComponent: Component {
    var severity: Float // 0.0 - 1.0
    var riskType: RiskType
    var impactRadius: Float
}

// KPI Data Component
struct KPIDataComponent: Component {
    var currentValue: Float
    var targetValue: Float
    var trend: TrendDirection
    var updateTimestamp: Date
}

// Interactive Component for Gestures
struct InteractableComponent: Component {
    var onTap: (() -> Void)?
    var onDrag: ((SIMD3<Float>) -> Void)?
    var isInteractive: Bool = true
}
```

#### RealityKit Systems

```swift
// Cash Flow Animation System
class CashFlowAnimationSystem: System {
    static let query = EntityQuery(
        where: .has(FlowVelocityComponent.self)
    )

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        // Animate cash flow rivers based on velocity
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var flow = entity.components[FlowVelocityComponent.self] else { continue }

            // Update position based on flow velocity
            let deltaTime = Float(context.deltaTime)
            var transform = entity.transform
            transform.translation += flow.velocity * deltaTime
            entity.transform = transform
        }
    }
}

// Risk Heat Map System
class RiskHeatMapSystem: System {
    static let query = EntityQuery(
        where: .has(RiskSeverityComponent.self)
    )

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        // Update risk visualization colors and heights
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let risk = entity.components[RiskSeverityComponent.self] else { continue }

            // Update material based on severity
            updateRiskMaterial(entity: entity, severity: risk.severity)
        }
    }

    private func updateRiskMaterial(entity: Entity, severity: Float) {
        // Gradient from green (low) to red (high)
        let color = interpolateColor(from: .green, to: .red, factor: severity)
        // Apply to entity material
    }
}
```

### ARKit Integration

#### Hand Tracking for Gestures

```swift
class HandTrackingManager: @unchecked Sendable {
    private var handTracking = HandTracking()

    func startTracking() async {
        await handTracking.start()
    }

    func detectFinancialGestures() -> AsyncStream<FinancialGesture> {
        AsyncStream { continuation in
            Task {
                for await update in handTracking.anchorUpdates {
                    if let gesture = self.interpretGesture(update) {
                        continuation.yield(gesture)
                    }
                }
            }
        }
    }

    private func interpretGesture(_ update: HandAnchor) -> FinancialGesture? {
        // Gesture recognition logic
        // - Thumbs up = Approve
        // - Swipe away = Reject
        // - Pinch and pull = Drill down
        return nil
    }
}

enum FinancialGesture {
    case approve
    case reject
    case drillDown
    case compare
    case filter
    case export
}
```

#### Spatial Audio

```swift
class SpatialAudioManager {
    func addAudioIndicator(to entity: Entity, for event: FinancialEvent) {
        let audio: AudioFileResource

        switch event {
        case .transactionProcessed:
            audio = try! AudioFileResource.load(named: "transaction_chime.wav")
        case .anomalyDetected:
            audio = try! AudioFileResource.load(named: "alert_sound.wav")
        case .goalAchieved:
            audio = try! AudioFileResource.load(named: "success.wav")
        }

        let audioComponent = AmbientAudioComponent(source: audio)
        entity.components[AmbientAudioComponent.self] = audioComponent
    }
}
```

---

## API Design & External Integrations

### API Architecture

```
┌────────────────────────────────────────┐
│      visionOS Application              │
└────────────────────────────────────────┘
                 │
                 │ HTTPS/TLS 1.3
                 ▼
┌────────────────────────────────────────┐
│       API Gateway (Enterprise)         │
│  - Authentication (OAuth 2.0)          │
│  - Rate Limiting                       │
│  - Request Routing                     │
│  - Response Caching                    │
└────────────────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
┌──────────────┐   ┌──────────────┐
│  RESTful API │   │ WebSocket    │
│  (CRUD ops)  │   │ (Real-time)  │
└──────────────┘   └──────────────┘
        │                 │
        └────────┬────────┘
                 ▼
┌────────────────────────────────────────┐
│      Backend Microservices             │
│  ┌──────────┐  ┌──────────────────┐   │
│  │Financial │  │   Integration    │   │
│  │ Service  │  │    Service       │   │
│  └──────────┘  └──────────────────┘   │
└────────────────────────────────────────┘
                 │
        ┌────────┴────────────────┐
        ▼                         ▼
┌──────────────┐         ┌──────────────┐
│  ERP Systems │         │   Banking    │
│ (SAP/Oracle) │         │     APIs     │
└──────────────┘         └──────────────┘
```

### API Client Implementation

```swift
actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenManager: AuthTokenManager

    init(configuration: APIConfiguration) {
        self.baseURL = configuration.baseURL
        self.session = URLSession(configuration: .default)
        self.tokenManager = AuthTokenManager()
    }

    // Generic Request Method
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method.rawValue

        // Add authentication
        request.setValue("Bearer \(await tokenManager.getToken())", forHTTPHeaderField: "Authorization")

        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

// Endpoint Definitions
enum APIEndpoint {
    case transactions
    case cashPosition
    case forecast(period: DateInterval)
    case closeStatus(period: ClosePeriod)

    var path: String {
        switch self {
        case .transactions: return "/api/v1/transactions"
        case .cashPosition: return "/api/v1/treasury/cash-position"
        case .forecast(let period):
            return "/api/v1/treasury/forecast?start=\(period.start)&end=\(period.end)"
        case .closeStatus(let period):
            return "/api/v1/close/\(period.year)/\(period.month)"
        }
    }
}
```

### External System Integrations

#### ERP Integration (SAP/Oracle)

```swift
protocol ERPIntegration {
    func fetchGeneralLedger(period: ClosePeriod) async throws -> [GLEntry]
    func postJournalEntry(_ entry: JournalEntry) async throws -> String
    func syncMasterData() async throws -> MasterDataSyncResult
}

class SAPIntegration: ERPIntegration {
    private let client: APIClient
    private let config: SAPConfiguration

    func fetchGeneralLedger(period: ClosePeriod) async throws -> [GLEntry] {
        // SAP-specific API calls
        let request = SAPGLRequest(
            companyCode: config.companyCode,
            fiscalYear: period.year,
            period: period.month
        )
        return try await client.request(.custom("SAP/GL"), body: request)
    }
}
```

#### Banking API Integration

```swift
protocol BankingIntegration {
    func fetchTransactions(
        account: BankAccount,
        dateRange: DateInterval
    ) async throws -> [BankTransaction]

    func getAccountBalance(
        account: BankAccount
    ) async throws -> Decimal

    func initiatePayment(
        payment: PaymentInstruction
    ) async throws -> PaymentConfirmation
}

class BankAPIClient: BankingIntegration {
    // Implementation using bank-specific APIs (SWIFT, ISO 20022, etc.)
}
```

#### Real-time Data Streaming

```swift
class RealTimeDataStream {
    private var webSocketTask: URLSessionWebSocketTask?

    func connect() async throws {
        let url = URL(string: "wss://api.finops.example.com/stream")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
    }

    func subscribeToTransactions() -> AsyncStream<FinancialTransaction> {
        AsyncStream { continuation in
            Task {
                while let message = try? await receiveMessage() {
                    if let transaction = parseTransaction(message) {
                        continuation.yield(transaction)
                    }
                }
            }
        }
    }

    private func receiveMessage() async throws -> String {
        let message = try await webSocketTask?.receive()
        switch message {
        case .string(let text):
            return text
        case .data(let data):
            return String(data: data, encoding: .utf8) ?? ""
        case .none:
            throw StreamError.connectionClosed
        @unknown default:
            throw StreamError.unknown
        }
    }
}
```

---

## State Management Strategy

### Observation Framework

Using Swift's `@Observable` macro for reactive state management:

```swift
@Observable
final class DashboardViewModel {
    // Published State
    var kpis: [KPI] = []
    var recentTransactions: [FinancialTransaction] = []
    var alerts: [Alert] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // Dependencies
    private let financialService: FinancialDataService
    private let aiService: AIAnalyticsService

    init(
        financialService: FinancialDataService,
        aiService: AIAnalyticsService
    ) {
        self.financialService = financialService
        self.aiService = aiService
    }

    @MainActor
    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let kpisFetch = financialService.fetchKPIs()
            async let transactionsFetch = financialService.fetchTransactions(
                dateRange: DateInterval.last30Days,
                accounts: nil
            )
            async let alertsFetch = aiService.detectAnomalies(
                transactions: try await transactionsFetch
            )

            self.kpis = try await kpisFetch
            self.recentTransactions = try await transactionsFetch
            self.alerts = try await alertsFetch.map { Alert(anomaly: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### Environment-based Dependency Injection

```swift
// Define environment key
struct FinancialDataServiceKey: EnvironmentKey {
    static let defaultValue: FinancialDataService = FinancialDataService()
}

extension EnvironmentValues {
    var financialService: FinancialDataService {
        get { self[FinancialDataServiceKey.self] }
        set { self[FinancialDataServiceKey.self] = newValue }
    }
}

// Usage in Views
struct DashboardView: View {
    @Environment(\.financialService) private var financialService
    @State private var viewModel: DashboardViewModel

    init() {
        _viewModel = State(initialValue: DashboardViewModel(
            financialService: financialService,
            aiService: AIAnalyticsService()
        ))
    }
}
```

### Global App State

```swift
@Observable
final class AppState {
    // User Session
    var currentUser: User?
    var isAuthenticated: Bool = false

    // Global Settings
    var preferredCurrency: Currency = .USD
    var selectedRegion: String?
    var theme: AppTheme = .automatic

    // Navigation State
    var selectedModule: AppModule = .dashboard
    var activeImmersiveSpace: String?

    // Real-time Updates
    var liveDataEnabled: Bool = true
    var lastSyncTime: Date?

    // Notifications
    var unreadAlerts: Int = 0
}
```

---

## Performance Optimization

### Optimization Strategy

#### 1. Data Loading Optimization

```swift
// Pagination for large datasets
struct PaginatedRequest {
    let page: Int
    let pageSize: Int = 50
    let sortBy: String?
}

// Incremental loading
func loadTransactionsIncrementally() async {
    var page = 1
    while true {
        let batch = try await fetchTransactions(page: page, pageSize: 100)
        if batch.isEmpty { break }

        await MainActor.run {
            transactions.append(contentsOf: batch)
        }
        page += 1
    }
}
```

#### 2. Caching Strategy

```swift
actor CacheManager {
    private var cache: [String: CachedData] = [:]
    private let maxCacheAge: TimeInterval = 300 // 5 minutes

    func get<T: Codable>(_ key: String) -> T? {
        guard let cached = cache[key],
              Date().timeIntervalSince(cached.timestamp) < maxCacheAge else {
            return nil
        }
        return cached.data as? T
    }

    func set<T: Codable>(_ key: String, value: T) {
        cache[key] = CachedData(data: value, timestamp: Date())
    }
}
```

#### 3. 3D Asset Optimization

```swift
// Level of Detail (LOD) for 3D models
class LODManager {
    func selectAppropriateModel(
        distance: Float,
        complexity: ModelComplexity
    ) -> ModelComponent {
        switch (distance, complexity) {
        case (0..<2, _):
            return highDetailModel
        case (2..<5, .high), (2..<5, .medium):
            return mediumDetailModel
        default:
            return lowDetailModel
        }
    }
}

// Object Pooling for repeated entities
class EntityPool {
    private var available: [Entity] = []
    private var inUse: Set<Entity> = []

    func acquire() -> Entity {
        if let entity = available.popLast() {
            inUse.insert(entity)
            return entity
        }
        let entity = createNewEntity()
        inUse.insert(entity)
        return entity
    }

    func release(_ entity: Entity) {
        inUse.remove(entity)
        available.append(entity)
    }
}
```

#### 4. Async/Await Optimization

```swift
// Structured concurrency for parallel operations
func loadDashboardData() async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask { try await self.loadKPIs() }
        group.addTask { try await self.loadTransactions() }
        group.addTask { try await self.loadAlerts() }
        group.addTask { try await self.loadCashPosition() }

        try await group.waitForAll()
    }
}
```

#### 5. Memory Management

```swift
// Weak references to avoid retain cycles
class TransactionProcessor {
    weak var delegate: TransactionProcessorDelegate?

    func processTransaction(_ transaction: FinancialTransaction) async {
        // Processing logic
        await delegate?.didProcessTransaction(transaction)
    }
}

// Automatic cleanup of old data
func cleanupOldData() async {
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date())!

    // Delete transactions older than 90 days from cache
    await cacheManager.removeWhere { item in
        item.timestamp < cutoffDate
    }
}
```

### Performance Targets

- **UI Responsiveness**: 60 FPS minimum, 90 FPS target
- **API Response**: < 2 seconds for queries
- **3D Rendering**: < 16ms frame time (90 FPS)
- **Memory Usage**: < 512 MB for base app, < 1 GB with immersive spaces
- **Initial Load**: < 3 seconds to interactive
- **Data Sync**: < 5 seconds for incremental updates

---

## Security Architecture

### Security Layers

```
┌────────────────────────────────────────┐
│      Application Security Layer        │
│  - Code signing                        │
│  - Secure enclave integration          │
│  - Keychain storage                    │
└────────────────────────────────────────┘
                 │
┌────────────────────────────────────────┐
│      Authentication & Authorization    │
│  - OAuth 2.0 / OpenID Connect          │
│  - Multi-factor authentication         │
│  - Biometric authentication            │
│  - Role-based access control (RBAC)    │
└────────────────────────────────────────┘
                 │
┌────────────────────────────────────────┐
│         Data Security Layer            │
│  - AES-256 encryption at rest          │
│  - TLS 1.3 in transit                  │
│  - End-to-end encryption               │
│  - Data masking                        │
└────────────────────────────────────────┘
                 │
┌────────────────────────────────────────┐
│      Compliance & Audit Layer          │
│  - SOX controls                        │
│  - GDPR compliance                     │
│  - Audit logging                       │
│  - Change tracking                     │
└────────────────────────────────────────┘
```

### Authentication Implementation

```swift
class AuthenticationManager {
    private let keychainService = KeychainService()

    func authenticate(credentials: Credentials) async throws -> AuthToken {
        // OAuth 2.0 flow
        let tokenResponse = try await performOAuthFlow(credentials)

        // Store securely in Keychain
        try await keychainService.store(
            token: tokenResponse.accessToken,
            key: "auth_token"
        )

        return AuthToken(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresAt: Date().addingTimeInterval(tokenResponse.expiresIn)
        )
    }

    func refreshToken() async throws -> AuthToken {
        guard let refreshToken = try await keychainService.retrieve(key: "refresh_token") else {
            throw AuthError.noRefreshToken
        }

        // Refresh token flow
        let tokenResponse = try await performTokenRefresh(refreshToken)

        try await keychainService.store(
            token: tokenResponse.accessToken,
            key: "auth_token"
        )

        return AuthToken(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresAt: Date().addingTimeInterval(tokenResponse.expiresIn)
        )
    }
}
```

### Data Encryption

```swift
class EncryptionService {
    private let keychain = KeychainService()

    func encryptSensitiveData(_ data: Data) throws -> Data {
        guard let key = try? keychain.getEncryptionKey() else {
            throw EncryptionError.keyNotFound
        }

        // AES-256-GCM encryption
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined ?? Data()
    }

    func decryptSensitiveData(_ encryptedData: Data) throws -> Data {
        guard let key = try? keychain.getEncryptionKey() else {
            throw EncryptionError.keyNotFound
        }

        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
```

### Role-Based Access Control

```swift
enum UserRole: String {
    case cfo
    case controller
    case treasuryManager
    case analyst
    case auditor
    case viewer
}

enum Permission: String {
    case viewTransactions
    case createTransactions
    case approveTransactions
    case deleteTransactions
    case viewCashPosition
    case manageCash
    case viewReports
    case modifyBudgets
    case accessAuditTrail
}

struct RBACManager {
    private let rolePermissions: [UserRole: Set<Permission>] = [
        .cfo: [.viewTransactions, .approveTransactions, .viewCashPosition,
               .manageCash, .viewReports, .modifyBudgets, .accessAuditTrail],
        .controller: [.viewTransactions, .createTransactions, .approveTransactions,
                      .viewReports, .modifyBudgets, .accessAuditTrail],
        .treasuryManager: [.viewTransactions, .viewCashPosition, .manageCash,
                           .viewReports],
        .analyst: [.viewTransactions, .viewCashPosition, .viewReports],
        .auditor: [.viewTransactions, .viewReports, .accessAuditTrail],
        .viewer: [.viewTransactions, .viewReports]
    ]

    func hasPermission(user: User, permission: Permission) -> Bool {
        guard let userPermissions = rolePermissions[user.role] else {
            return false
        }
        return userPermissions.contains(permission)
    }
}
```

### Audit Logging

```swift
struct AuditLog: Codable {
    let id: UUID
    let timestamp: Date
    let userId: String
    let action: AuditAction
    let entityType: String
    let entityId: String
    let changes: [String: AuditChange]
    let ipAddress: String?
    let deviceInfo: String?
}

enum AuditAction: String, Codable {
    case create, read, update, delete, approve, reject
}

struct AuditChange: Codable {
    let field: String
    let oldValue: String?
    let newValue: String?
}

class AuditLogger {
    func log(
        user: User,
        action: AuditAction,
        entity: AuditableEntity
    ) async throws {
        let log = AuditLog(
            id: UUID(),
            timestamp: Date(),
            userId: user.id,
            action: action,
            entityType: String(describing: type(of: entity)),
            entityId: entity.id.uuidString,
            changes: entity.changes,
            ipAddress: await getCurrentIPAddress(),
            deviceInfo: await getDeviceInfo()
        )

        try await persistAuditLog(log)
    }
}
```

### Compliance Controls

```swift
class ComplianceController {
    // Segregation of Duties (SOD)
    func validateSegregationOfDuties(
        user: User,
        transaction: FinancialTransaction
    ) throws {
        // Cannot approve own transactions
        if transaction.createdBy == user.id {
            throw ComplianceError.sodViolation("Cannot approve own transaction")
        }

        // Check for conflicting roles
        if hasConflictingRoles(user: user, transaction: transaction) {
            throw ComplianceError.sodViolation("Conflicting role assignment")
        }
    }

    // Data Retention Policy
    func enforceRetentionPolicy() async throws {
        let retentionPeriod = 7 * 365 // 7 years for financial data
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -retentionPeriod,
            to: Date()
        )!

        // Archive old data instead of deleting
        try await archiveDataOlderThan(cutoffDate)
    }

    // GDPR Compliance
    func handleDataSubjectRequest(
        type: DataSubjectRequestType,
        userId: String
    ) async throws {
        switch type {
        case .access:
            try await exportUserData(userId: userId)
        case .deletion:
            try await anonymizeUserData(userId: userId)
        case .portability:
            try await generateDataExport(userId: userId)
        }
    }
}
```

---

## Conclusion

This architecture provides a robust, scalable foundation for the Financial Operations Platform on visionOS. Key architectural decisions include:

1. **MVVM Pattern** for clear separation of concerns
2. **Entity Component System** for flexible 3D visualization
3. **Service-oriented architecture** for maintainability
4. **Reactive state management** with Swift Observation
5. **Comprehensive security** with multiple layers of protection
6. **Performance optimization** throughout the stack
7. **Enterprise integration** capabilities with external systems

The architecture is designed to support the demanding requirements of enterprise financial operations while leveraging the unique capabilities of visionOS and Apple Vision Pro.
