//
//  ServiceProtocols.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Base Service Protocol

/// A protocol that defines the lifecycle of a service in the Business Operating System.
///
/// ## Overview
/// All services in the BOS application conform to this protocol to ensure consistent
/// initialization and cleanup behavior. Services are managed by the ``ServiceContainer``
/// and are initialized in parallel during app startup.
///
/// ## Implementing a Service
/// ```swift
/// final class MyServiceImpl: MyService {
///     func initialize() async throws {
///         // Connect to resources, load caches, etc.
///     }
///
///     func shutdown() async {
///         // Release resources, save state
///     }
/// }
/// ```
///
/// - Important: Services should be designed to handle initialization failures gracefully
///   and clean up all resources during shutdown.
public protocol Service: Sendable {
    /// Initializes the service and prepares it for use.
    ///
    /// This method is called during app startup. Services should perform any necessary
    /// setup such as:
    /// - Establishing network connections
    /// - Loading cached data
    /// - Setting up observers
    ///
    /// - Throws: An error if initialization fails. The app will attempt to continue
    ///   with degraded functionality if a non-critical service fails.
    func initialize() async throws

    /// Shuts down the service and releases all resources.
    ///
    /// This method is called during app termination or when the service is no longer needed.
    /// Implementations should:
    /// - Cancel any pending operations
    /// - Save any cached state
    /// - Release network connections
    func shutdown() async
}

// MARK: - Authentication Service

/// A service responsible for user authentication and session management.
///
/// ## Overview
/// The authentication service handles user identity verification using biometric
/// authentication (Face ID, Optic ID) and maintains the current user session.
///
/// ## Usage
/// ```swift
/// let user = try await authService.authenticateUser()
/// // User is now authenticated
///
/// // Later...
/// await authService.logout()
/// ```
///
/// ## Topics
/// ### Authentication
/// - ``authenticateUser()``
/// - ``logout()``
///
/// ### Session State
/// - ``currentUser``
public protocol AuthenticationService: Service {
    /// Authenticates the current user using available biometric methods.
    ///
    /// On visionOS, this typically uses Optic ID or falls back to device passcode.
    /// The method presents the system authentication UI and waits for user input.
    ///
    /// - Returns: The authenticated ``User`` instance with profile information.
    /// - Throws: ``BOSError/authenticationFailed`` if authentication is cancelled or fails.
    /// - Throws: ``BOSError/biometricsNotAvailable`` if no biometric method is available.
    func authenticateUser() async throws -> User

    /// Logs out the current user and clears the session.
    ///
    /// After calling this method, ``currentUser`` will return `nil` and any
    /// authenticated API calls will fail until re-authentication.
    func logout() async

    /// The currently authenticated user, if any.
    ///
    /// This property returns `nil` if no user is authenticated.
    /// Use this to check authentication state before making protected API calls.
    var currentUser: User? { get async }
}

// MARK: - Business Data Repository

/// A repository for fetching and observing business data entities.
///
/// ## Overview
/// The business data repository provides access to all core business entities
/// including organizations, departments, KPIs, and employees. It supports both
/// one-time fetches and real-time updates via async streams.
///
/// ## Fetching Data
/// ```swift
/// // Fetch organization
/// let org = try await repository.fetchOrganization()
///
/// // Fetch departments
/// let departments = try await repository.fetchDepartments()
///
/// // Fetch KPIs for a specific department
/// let kpis = try await repository.fetchKPIs(for: department.id)
/// ```
///
/// ## Real-time Updates
/// ```swift
/// for await update in repository.observeRealtimeUpdates() {
///     switch update.entityType {
///     case .kpi:
///         // Handle KPI update
///     case .department:
///         // Handle department update
///     default:
///         break
///     }
/// }
/// ```
public protocol BusinessDataRepository: Service, Sendable {
    /// Fetches the current user's organization.
    ///
    /// - Returns: The ``Organization`` entity with all top-level departments.
    /// - Throws: ``BOSError/dataNotFound`` if no organization is associated with the user.
    /// - Throws: ``BOSError/networkUnavailable`` if the network is unavailable and no cache exists.
    func fetchOrganization() async throws -> Organization

    /// Fetches all departments in the organization.
    ///
    /// - Returns: An array of ``Department`` entities.
    /// - Throws: ``BOSError/fetchFailed(_:)`` if the fetch operation fails.
    func fetchDepartments() async throws -> [Department]

    /// Fetches a specific department by its ID.
    ///
    /// - Parameter id: The unique identifier of the department.
    /// - Returns: The ``Department`` entity.
    /// - Throws: ``BOSError/dataNotFound`` if no department exists with the given ID.
    func fetchDepartment(id: Department.ID) async throws -> Department

    /// Fetches KPIs for a specific department.
    ///
    /// - Parameter departmentID: The ID of the department to fetch KPIs for.
    /// - Returns: An array of ``KPI`` entities associated with the department.
    /// - Throws: ``BOSError/fetchFailed(_:)`` if the fetch operation fails.
    func fetchKPIs(for departmentID: Department.ID) async throws -> [KPI]

    /// Fetches employees for a specific department.
    ///
    /// - Parameter departmentID: The ID of the department to fetch employees for.
    /// - Returns: An array of ``Employee`` entities in the department.
    /// - Throws: ``BOSError/fetchFailed(_:)`` if the fetch operation fails.
    func fetchEmployees(for departmentID: Department.ID) async throws -> [Employee]

    /// Observes real-time updates to business data.
    ///
    /// Returns an async stream that emits ``BusinessUpdate`` events whenever
    /// data changes on the server. The stream continues until cancelled or
    /// the connection is lost.
    ///
    /// - Returns: An `AsyncStream` of business update events.
    func observeRealtimeUpdates() -> AsyncStream<BusinessUpdate>
}

// MARK: - Sync Service

/// A service for synchronizing local data with the backend server.
///
/// ## Overview
/// The sync service manages bidirectional data synchronization between the local
/// cache and the remote server. It handles conflict resolution and maintains
/// data consistency across sessions.
///
/// ## Usage
/// ```swift
/// // Start background sync
/// await syncService.startSync()
///
/// // Force immediate sync
/// try await syncService.forceSyncNow()
///
/// // Monitor sync status
/// for await status in syncService.syncStatus {
///     switch status {
///     case .syncing:
///         showSyncIndicator()
///     case .synced:
///         hideSyncIndicator()
///     case .error(let error):
///         showSyncError(error)
///     }
/// }
/// ```
public protocol SyncService: Service {
    /// Starts background synchronization.
    ///
    /// Once started, the service will periodically sync data with the server.
    /// Call ``stopSync()`` to stop background syncing.
    func startSync() async

    /// Stops background synchronization.
    ///
    /// Any pending sync operations will complete, but no new syncs will be initiated.
    func stopSync() async

    /// Forces an immediate synchronization.
    ///
    /// Use this method when you need to ensure data is up-to-date, such as
    /// after returning from background or when the user explicitly requests a refresh.
    ///
    /// - Throws: ``BOSError/syncFailed`` if the sync operation fails.
    /// - Throws: ``BOSError/conflictDetected`` if there are unresolvable conflicts.
    func forceSyncNow() async throws

    /// A stream of sync status updates.
    ///
    /// Subscribe to this stream to monitor sync progress and handle errors.
    var syncStatus: AsyncStream<SyncStatus> { get }
}

/// The current status of data synchronization.
public enum SyncStatus: Sendable {
    /// No sync operation is in progress.
    case idle
    /// A sync operation is currently in progress.
    case syncing
    /// Data is fully synchronized with the server.
    case synced
    /// An error occurred during synchronization.
    case error(Error)
}

// MARK: - AI Service

/// A service for AI-powered analytics and recommendations.
///
/// ## Overview
/// The AI service provides intelligent analysis of business data, including
/// anomaly detection, trend prediction, and natural language question answering.
///
/// ## Features
/// - **Anomaly Detection**: Automatically identify unusual patterns in KPIs
/// - **Recommendations**: Get AI-generated suggestions for improving metrics
/// - **Trend Prediction**: Forecast future values based on historical data
/// - **Q&A**: Ask natural language questions about your business data
///
/// ## Usage
/// ```swift
/// // Detect anomalies
/// let anomalies = try await aiService.analyzeAnomaly(in: dataPoints)
///
/// // Get recommendations
/// let context = BusinessContext(department: deptID, timeRange: .last30Days)
/// let recommendations = try await aiService.generateRecommendation(for: context)
///
/// // Predict trends
/// let prediction = try await aiService.predictTrend(for: revenueKPI, horizon: 30 * 24 * 3600)
///
/// // Ask questions
/// let answer = try await aiService.answerQuestion("What department has the highest growth?")
/// ```
public protocol AIService: Service {
    /// Analyzes data points to detect anomalies.
    ///
    /// - Parameter data: An array of ``DataPoint`` values to analyze.
    /// - Returns: An ``AnomalyReport`` describing any detected anomalies.
    /// - Throws: An error if analysis fails.
    func analyzeAnomaly(in data: [DataPoint]) async throws -> AnomalyReport

    /// Generates recommendations based on business context.
    ///
    /// - Parameter context: The ``BusinessContext`` to analyze.
    /// - Returns: A ``Recommendation`` with suggested actions.
    /// - Throws: An error if recommendation generation fails.
    func generateRecommendation(for context: BusinessContext) async throws -> Recommendation

    /// Predicts future values for a KPI.
    ///
    /// - Parameters:
    ///   - metric: The ``KPI`` to predict.
    ///   - horizon: The time horizon in seconds for the prediction.
    /// - Returns: A ``TrendPrediction`` with forecasted values and confidence.
    /// - Throws: An error if prediction fails.
    func predictTrend(for metric: KPI, horizon: TimeInterval) async throws -> TrendPrediction

    /// Answers a natural language question about business data.
    ///
    /// - Parameter question: The question to answer.
    /// - Returns: A natural language response.
    /// - Throws: An error if the question cannot be answered.
    func answerQuestion(_ question: String) async throws -> String
}

/// A single data point for time-series analysis.
public struct DataPoint: Codable, Sendable {
    /// The timestamp of the data point.
    public var timestamp: Date
    /// The numeric value at this timestamp.
    public var value: Double
    /// Additional metadata associated with this data point.
    public var metadata: [String: String]
}

/// A report of detected anomalies in data.
public struct AnomalyReport: Codable, Sendable {
    /// When the anomaly was detected.
    public var detectedAt: Date
    /// The severity level of the anomaly.
    public var severity: Severity
    /// A human-readable description of the anomaly.
    public var description: String
    /// IDs of entities affected by this anomaly.
    public var affectedEntities: [UUID]
    /// Suggested actions to address the anomaly.
    public var recommendedActions: [String]

    /// The severity level of an anomaly.
    public enum Severity: String, Codable, Sendable {
        case low
        case medium
        case high
        case critical
    }
}

/// Context for generating business recommendations.
public struct BusinessContext: Codable, Sendable {
    /// The department to analyze, or nil for organization-wide.
    public var department: Department.ID?
    /// The time range to consider.
    public var timeRange: TimeRange
    /// Additional filters to apply.
    public var filters: [String: String]
}

/// A time range for data queries.
public enum TimeRange: String, Codable, Sendable {
    case last7Days
    case last30Days
    case last90Days
    case yearToDate
    case custom
}

/// An AI-generated recommendation.
public struct Recommendation: Codable, Sendable {
    public var id: UUID
    public var title: String
    public var description: String
    public var priority: Priority
    public var estimatedImpact: String
    public var actions: [RecommendedAction]

    public enum Priority: String, Codable, Sendable {
        case low
        case medium
        case high
        case urgent
    }
}

/// A specific action recommended by the AI.
public struct RecommendedAction: Codable, Sendable {
    public var description: String
    public var estimatedCost: Decimal?
    public var estimatedTime: String
}

/// A prediction for future KPI values.
public struct TrendPrediction: Codable, Sendable {
    public var metric: String
    public var currentValue: Decimal
    public var predictedValue: Decimal
    /// Confidence level from 0.0 to 1.0.
    public var confidence: Double
    public var timeHorizon: String
    public var factors: [String]
}

// MARK: - Collaboration Service

/// A service for real-time collaboration in spatial environments.
///
/// ## Overview
/// The collaboration service enables multiple users to share the same spatial
/// workspace, see each other's positions, and share annotations on 3D objects.
///
/// ## Starting a Session
/// ```swift
/// let session = CollaborationSession(
///     id: UUID(),
///     title: "Q4 Planning",
///     hostID: currentUser.id,
///     participants: [],
///     createdAt: Date(),
///     activeSpace: "business-universe"
/// )
/// try await collaborationService.startSession(session)
/// ```
///
/// ## Joining a Session
/// ```swift
/// try await collaborationService.joinSession(sessionID)
///
/// for await update in collaborationService.participantUpdates {
///     // Handle participant movements and actions
/// }
/// ```
public protocol CollaborationService: Service {
    /// Starts a new collaboration session as host.
    ///
    /// - Parameter session: The session configuration.
    /// - Throws: An error if the session cannot be created.
    func startSession(_ session: CollaborationSession) async throws

    /// Joins an existing collaboration session.
    ///
    /// - Parameter sessionID: The ID of the session to join.
    /// - Throws: An error if the session doesn't exist or cannot be joined.
    func joinSession(_ sessionID: UUID) async throws

    /// Leaves the current collaboration session.
    func leaveSession() async

    /// Shares a spatial annotation with other participants.
    ///
    /// - Parameter annotation: The annotation to share.
    /// - Throws: An error if not in an active session.
    func shareAnnotation(_ annotation: SpatialAnnotation) async throws

    /// A stream of participant updates in the current session.
    var participantUpdates: AsyncStream<ParticipantUpdate> { get }
}

/// Configuration for a collaboration session.
public struct CollaborationSession: Codable, Sendable {
    public var id: UUID
    public var title: String
    public var hostID: User.ID
    public var participants: [User.ID]
    public var createdAt: Date
    /// The identifier of the spatial scene being shared.
    public var activeSpace: String
}

/// A spatial annotation placed in 3D space.
public struct SpatialAnnotation: Codable, Sendable {
    public var id: UUID
    public var authorID: User.ID
    public var position: SIMD3<Float>
    public var content: String
    public var createdAt: Date
}

/// An update about a participant in a collaboration session.
public struct ParticipantUpdate: Codable, Sendable {
    public var userID: User.ID
    public var action: ParticipantAction
    public var timestamp: Date

    public enum ParticipantAction: String, Codable, Sendable {
        case joined
        case left
        case movedTo
        case selectedEntity
        case annotated
    }
}

// MARK: - Network Service

/// A low-level service for making HTTP requests to the API.
///
/// ## Overview
/// The network service handles all HTTP communication with the backend API,
/// including authentication headers, request encoding, and response decoding.
///
/// ## Usage
/// ```swift
/// // GET request
/// let org: Organization = try await networkService.request(.organization)
///
/// // POST request
/// let response: CreateResponse = try await networkService.post(.reports, body: newReport)
/// ```
public protocol NetworkService: Service {
    /// Performs a GET request to the specified endpoint.
    ///
    /// - Parameter endpoint: The ``APIEndpoint`` to request.
    /// - Returns: The decoded response.
    /// - Throws: ``BOSError/networkUnavailable`` if offline.
    /// - Throws: ``BOSError/serverError(_:)`` for server errors.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T

    /// Performs a POST request to the specified endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: The ``APIEndpoint`` to post to.
    ///   - body: The request body to encode.
    /// - Returns: The decoded response.
    /// - Throws: ``BOSError/networkUnavailable`` if offline.
    /// - Throws: ``BOSError/serverError(_:)`` for server errors.
    func post<T: Codable, R: Decodable>(_ endpoint: APIEndpoint, body: T) async throws -> R
}

/// API endpoints available in the system.
public enum APIEndpoint {
    case organization
    case departments
    case kpis(departmentID: UUID)
    case employees(departmentID: UUID)
    case reports

    /// The URL path for this endpoint.
    public var path: String {
        switch self {
        case .organization:
            return "/api/v1/organization"
        case .departments:
            return "/api/v1/departments"
        case .kpis(let deptID):
            return "/api/v1/departments/\(deptID.uuidString)/kpis"
        case .employees(let deptID):
            return "/api/v1/departments/\(deptID.uuidString)/employees"
        case .reports:
            return "/api/v1/reports"
        }
    }
}

// MARK: - Analytics Service

/// A service for tracking user analytics and events.
///
/// ## Overview
/// The analytics service tracks user interactions and screen views to help
/// understand usage patterns and improve the application.
///
/// ## Usage
/// ```swift
/// // Track events
/// await analyticsService.trackEvent(.departmentSelected(deptID))
///
/// // Track screen views
/// await analyticsService.trackScreenView("dashboard")
/// ```
///
/// - Note: All analytics data is anonymized and complies with privacy regulations.
public protocol AnalyticsService: Service, Sendable {
    /// Tracks a specific event.
    ///
    /// - Parameter event: The ``AnalyticsEvent`` to track.
    func trackEvent(_ event: AnalyticsEvent) async

    /// Tracks a screen view.
    ///
    /// - Parameter screen: The name of the screen being viewed.
    func trackScreenView(_ screen: String) async
}

/// Events that can be tracked for analytics.
public enum AnalyticsEvent: Sendable {
    /// The app was launched.
    case appLaunched
    /// The dashboard was viewed.
    case dashboardViewed
    /// A department was selected.
    case departmentSelected(Department.ID)
    /// A KPI was tapped for details.
    case kpiTapped(KPI.ID)
    /// A report was generated.
    case reportGenerated(Report.ReportType)
    /// User entered an immersive space.
    case immersiveSpaceEntered
    /// An error occurred.
    case errorOccurred(Error)
}
