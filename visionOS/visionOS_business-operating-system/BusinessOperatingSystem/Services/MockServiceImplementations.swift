//
//  MockServiceImplementations.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Mock Authentication Service

final class AuthenticationServiceImpl: AuthenticationService, @unchecked Sendable {
    private var _currentUser: User?

    var currentUser: User? {
        get async { _currentUser }
    }

    func initialize() async throws {
        print("AuthenticationService initialized")
    }

    func shutdown() async {
        print("AuthenticationService shutdown")
    }

    func authenticateUser() async throws -> User {
        // Mock biometric authentication
        try await Task.sleep(for: .seconds(0.5))

        let mockUser = User(
            id: UUID(),
            email: "ceo@acme.com",
            name: "John Smith",
            role: .executive,
            department: nil
        )

        _currentUser = mockUser
        return mockUser
    }

    func logout() async {
        _currentUser = nil
    }
}

// MARK: - Mock Business Data Repository

final class BusinessDataRepositoryImpl: BusinessDataRepository {
    func initialize() async throws {
        print("BusinessDataRepository initialized")
    }

    func shutdown() async {
        print("BusinessDataRepository shutdown")
    }

    func fetchOrganization() async throws -> Organization {
        try await Task.sleep(for: .milliseconds(500))
        return .mock()
    }

    func fetchDepartments() async throws -> [Department] {
        try await Task.sleep(for: .milliseconds(300))
        return [
            .mock(name: "Engineering", type: .engineering),
            .mock(name: "Sales", type: .sales),
            .mock(name: "Marketing", type: .marketing),
            .mock(name: "Finance", type: .finance),
            .mock(name: "Operations", type: .operations)
        ]
    }

    func fetchDepartment(id: Department.ID) async throws -> Department {
        try await Task.sleep(for: .milliseconds(200))
        return .mock()
    }

    func fetchKPIs(for departmentID: Department.ID) async throws -> [KPI] {
        try await Task.sleep(for: .milliseconds(200))
        return [
            .mock(name: "Revenue", value: 1_250_000),
            .mock(name: "Profit Margin", value: 18.5),
            .mock(name: "Customer Count", value: 1_524),
            .mock(name: "Employee Satisfaction", value: 4.2)
        ]
    }

    func fetchEmployees(for departmentID: Department.ID) async throws -> [Employee] {
        try await Task.sleep(for: .milliseconds(200))
        return (0..<10).map { _ in .mock() }
    }

    func observeRealtimeUpdates() -> AsyncStream<BusinessUpdate> {
        AsyncStream { continuation in
            // Mock real-time updates every 5 seconds
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(5))

                    let update = BusinessUpdate(
                        id: UUID(),
                        timestamp: Date(),
                        entityType: .kpi,
                        entityID: UUID(),
                        changeType: .updated,
                        data: Data()
                    )

                    continuation.yield(update)
                }
            }
        }
    }
}

// MARK: - Mock Sync Service

final class SyncServiceImpl: SyncService, @unchecked Sendable {
    private var isSyncing = false

    var syncStatus: AsyncStream<SyncStatus> {
        AsyncStream { continuation in
            continuation.yield(.idle)
        }
    }

    func initialize() async throws {
        print("SyncService initialized")
    }

    func shutdown() async {
        isSyncing = false
        print("SyncService shutdown")
    }

    func startSync() async {
        isSyncing = true
        print("Sync started")
    }

    func stopSync() async {
        isSyncing = false
        print("Sync stopped")
    }

    func forceSyncNow() async throws {
        print("Force sync initiated")
        try await Task.sleep(for: .seconds(1))
        print("Force sync completed")
    }
}

// MARK: - Mock AI Service

final class AIServiceImpl: AIService {
    func initialize() async throws {
        print("AIService initialized")
    }

    func shutdown() async {
        print("AIService shutdown")
    }

    func analyzeAnomaly(in data: [DataPoint]) async throws -> AnomalyReport {
        try await Task.sleep(for: .seconds(1))

        return AnomalyReport(
            detectedAt: Date(),
            severity: .medium,
            description: "Revenue dip detected in Q3",
            affectedEntities: [UUID()],
            recommendedActions: ["Investigate sales pipeline", "Review marketing campaigns"]
        )
    }

    func generateRecommendation(for context: BusinessContext) async throws -> Recommendation {
        try await Task.sleep(for: .seconds(0.8))

        return Recommendation(
            id: UUID(),
            title: "Optimize Budget Allocation",
            description: "Based on current performance, reallocating 15% of marketing budget to product development could yield 20% higher ROI.",
            priority: .high,
            estimatedImpact: "+$2.5M annual revenue",
            actions: [
                RecommendedAction(
                    description: "Reduce social media ad spend by $500K",
                    estimatedCost: -500_000,
                    estimatedTime: "1 quarter"
                ),
                RecommendedAction(
                    description: "Invest in product feature X",
                    estimatedCost: 300_000,
                    estimatedTime: "2 quarters"
                )
            ]
        )
    }

    func predictTrend(for metric: KPI, horizon: TimeInterval) async throws -> TrendPrediction {
        try await Task.sleep(for: .milliseconds(600))

        let predictedValue = metric.value * Decimal(1.15)  // 15% increase prediction

        return TrendPrediction(
            metric: metric.name,
            currentValue: metric.value,
            predictedValue: predictedValue,
            confidence: 0.82,
            timeHorizon: "Next Quarter",
            factors: ["Seasonal trends", "Historical growth", "Market conditions"]
        )
    }

    func answerQuestion(_ question: String) async throws -> String {
        try await Task.sleep(for: .seconds(1))

        return "Based on current data, \(question.lowercased()) shows positive trends with 85% confidence. Key factors include improved operational efficiency and strong market positioning."
    }
}

// MARK: - Mock Collaboration Service

final class CollaborationServiceImpl: CollaborationService {
    var participantUpdates: AsyncStream<ParticipantUpdate> {
        AsyncStream { continuation in
            // No updates in mock
        }
    }

    func initialize() async throws {
        print("CollaborationService initialized")
    }

    func shutdown() async {
        print("CollaborationService shutdown")
    }

    func startSession(_ session: CollaborationSession) async throws {
        print("Collaboration session started: \(session.title)")
    }

    func joinSession(_ sessionID: UUID) async throws {
        print("Joined collaboration session: \(sessionID)")
    }

    func leaveSession() async {
        print("Left collaboration session")
    }

    func shareAnnotation(_ annotation: SpatialAnnotation) async throws {
        print("Annotation shared: \(annotation.content)")
    }
}

// MARK: - Mock Network Service

final class NetworkServiceImpl: NetworkService {
    func initialize() async throws {
        print("NetworkService initialized")
    }

    func shutdown() async {
        print("NetworkService shutdown")
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Mock network request
        try await Task.sleep(for: .milliseconds(300))

        // This is a mock - in real implementation, make actual HTTP request
        throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock implementation"])
    }

    func post<T: Codable, R: Decodable>(_ endpoint: APIEndpoint, body: T) async throws -> R {
        // Mock network request
        try await Task.sleep(for: .milliseconds(400))

        // This is a mock - in real implementation, make actual HTTP request
        throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock implementation"])
    }
}

// MARK: - Mock Analytics Service

final class AnalyticsServiceImpl: AnalyticsService {
    func initialize() async throws {
        print("AnalyticsService initialized")
    }

    func shutdown() async {
        print("AnalyticsService shutdown")
    }

    func trackEvent(_ event: AnalyticsEvent) async {
        print("Analytics event: \(event)")
    }

    func trackScreenView(_ screen: String) async {
        print("Screen view: \(screen)")
    }
}
