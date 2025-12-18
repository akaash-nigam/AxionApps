import Foundation
import SwiftData
import Logging

/// Digital Twin Service - Manages digital twin lifecycle, caching, and synchronization
@Observable
final class DigitalTwinService: @unchecked Sendable {

    // MARK: - Properties

    private let networkService: NetworkService
    private let modelContext: ModelContext
    private let logger: Logger

    // LRU Cache for frequently accessed twins
    private let twinCache: LRUCache<UUID, DigitalTwin>

    // Sync state
    private(set) var syncStatus: SyncStatus = .idle
    private(set) var lastSyncDate: Date?
    private var activeSyncTasks: [UUID: Task<Void, Never>] = [:]

    // Performance monitoring
    private let performanceMonitor: PerformanceMonitor

    // MARK: - Configuration

    struct Configuration {
        var updateFrequency: TimeInterval = 1.0  // 1 Hz for normal updates
        var criticalUpdateFrequency: TimeInterval = 0.01 // 100 Hz for critical sensors
        var maxConcurrentTwins: Int = 100
        var enablePredictions: Bool = true
        var cacheExpirationTime: TimeInterval = 300 // 5 minutes
    }

    private var config: Configuration

    // MARK: - Initialization

    init(
        networkService: NetworkService,
        modelContext: ModelContext,
        config: Configuration = Configuration(),
        logger: Logger = Logger(label: "com.twinspace.digitaltwin")
    ) {
        self.networkService = networkService
        self.modelContext = modelContext
        self.config = config
        self.logger = logger
        self.performanceMonitor = PerformanceMonitor.shared

        // Initialize LRU cache with configured capacity and expiration
        self.twinCache = LRUCache(
            capacity: config.maxConcurrentTwins,
            expirationInterval: config.cacheExpirationTime
        )
    }

    // MARK: - Digital Twin Management

    /// Load a digital twin by ID with caching
    func loadDigitalTwin(assetId: UUID) async throws -> DigitalTwin {
        logger.info("Loading digital twin: \(assetId)")

        // Check cache first (async due to actor isolation)
        if let cached = await twinCache.get(assetId) {
            logger.debug("Digital twin loaded from cache")
            return cached
        }

        // Try local database
        let descriptor = FetchDescriptor<DigitalTwin>(
            predicate: #Predicate { $0.id == assetId }
        )

        if let localTwin = try modelContext.fetch(descriptor).first {
            logger.debug("Digital twin loaded from local database")
            await twinCache.set(assetId, value: localTwin)
            return localTwin
        }

        // Fetch from backend
        logger.info("Fetching digital twin from backend")
        let twin = try await fetchFromBackend(assetId)

        // Save to local database
        modelContext.insert(twin)
        try modelContext.save()

        // Cache for quick access
        await twinCache.set(assetId, value: twin)

        // Start real-time updates
        await startRealtimeUpdates(for: twin)

        return twin
    }

    /// Load all digital twins for a facility
    func loadAllDigitalTwins(facilityId: String? = nil) async throws -> [DigitalTwin] {
        logger.info("Loading all digital twins")

        let descriptor = FetchDescriptor<DigitalTwin>(
            sortBy: [SortDescriptor(\.name)]
        )

        var twins = try modelContext.fetch(descriptor)

        // Filter by facility if specified
        if let facilityId = facilityId {
            twins = twins.filter { $0.location?.facilityName == facilityId }
        }

        // Start updates for all twins
        for twin in twins {
            await startRealtimeUpdates(for: twin)
        }

        return twins
    }

    /// Update a digital twin's state with sensor data
    func updateTwinState(
        _ twin: DigitalTwin,
        with sensorData: [SensorReading]
    ) async {
        await performanceMonitor.measure("twin_update") {
            logger.debug("Updating twin state: \(twin.name)")

            // Update sensor values
            for reading in sensorData {
                if let sensor = twin.sensors.first(where: { $0.id == reading.sensorId }) {
                    sensor.updateReading(reading.value, quality: reading.quality)
                }
            }

            // Recalculate health score
            twin.updateHealth(basedOn: twin.sensors)

            // Check for anomalies
            await checkForAnomalies(twin)

            // Trigger predictions if enabled
            if config.enablePredictions {
                await triggerPredictiveAnalysis(twin)
            }

            // Save to database
            twin.modifiedDate = Date()
            try? modelContext.save()

            // Update cache
            await cache(twin)
        }
    }

    /// Create a new digital twin
    func createDigitalTwin(
        name: String,
        assetType: AssetType,
        location: GeoLocation?,
        modelURL: URL? = nil
    ) async throws -> DigitalTwin {
        logger.info("Creating new digital twin: \(name)")

        let twin = DigitalTwin(
            name: name,
            assetType: assetType,
            location: location,
            modelURL: modelURL
        )

        // Save locally
        modelContext.insert(twin)
        try modelContext.save()

        // Sync to backend
        try await syncToBackend(twin)

        // Cache
        await cache(twin)

        return twin
    }

    /// Delete a digital twin
    func deleteDigitalTwin(_ twin: DigitalTwin) async throws {
        logger.info("Deleting digital twin: \(twin.name)")

        // Stop updates
        stopRealtimeUpdates(for: twin)

        // Remove from cache
        await twinCache.remove(twin.id)

        // Delete from backend
        try await deleteFromBackend(twin.id)

        // Delete locally (cascade will handle relationships)
        modelContext.delete(twin)
        try modelContext.save()
    }

    // MARK: - Real-Time Updates

    private func startRealtimeUpdates(for twin: DigitalTwin) async {
        // Prevent duplicate tasks
        guard activeSyncTasks[twin.id] == nil else { return }

        logger.info("Starting real-time updates for: \(twin.name)")

        let task = Task {
            while !Task.isCancelled {
                do {
                    // Fetch latest sensor data
                    let readings = try await fetchSensorData(for: twin.id)

                    // Update twin state
                    await updateTwinState(twin, with: readings)

                    // Determine update frequency based on status
                    let frequency = twin.operationalStatus == .critical
                        ? config.criticalUpdateFrequency
                        : config.updateFrequency

                    try await Task.sleep(for: .seconds(frequency))
                } catch {
                    logger.error("Error updating twin: \(error)")
                    try? await Task.sleep(for: .seconds(config.updateFrequency))
                }
            }
        }

        activeSyncTasks[twin.id] = task
    }

    private func stopRealtimeUpdates(for twin: DigitalTwin) {
        activeSyncTasks[twin.id]?.cancel()
        activeSyncTasks.removeValue(forKey: twin.id)
        logger.info("Stopped real-time updates for: \(twin.name)")
    }

    // MARK: - Health Monitoring

    private func checkForAnomalies(_ twin: DigitalTwin) async {
        // Check if health score dropped significantly
        if twin.healthScore < 70 && twin.operationalStatus != .critical {
            logger.warning("Health degradation detected for \(twin.name): \(twin.healthScore)%")

            // Create alert
            let alert = Alert(
                id: UUID(),
                twinId: twin.id,
                severity: twin.healthScore < 50 ? .critical : .warning,
                title: "Health Degradation Detected",
                message: "Health score: \(Int(twin.healthScore))%",
                timestamp: Date()
            )

            // In a real app, this would notify the user
            logger.info("Alert created: \(alert.title)")
        }

        // Check individual sensors for out-of-range values
        for sensor in twin.sensors {
            if sensor.status == .critical {
                logger.warning("Critical sensor reading: \(sensor.name) = \(sensor.currentValue) \(sensor.unit)")
            }
        }
    }

    private func triggerPredictiveAnalysis(_ twin: DigitalTwin) async {
        // This would integrate with PredictiveAnalyticsService
        // For now, just log
        if twin.healthScore < 80 && twin.predictions.isEmpty {
            logger.info("Triggering predictive analysis for \(twin.name)")
            // await predictiveAnalyticsService.analyzeTwin(twin)
        }
    }

    // MARK: - Caching

    /// Cache a digital twin (LRU eviction handled automatically)
    private func cache(_ twin: DigitalTwin) async {
        await twinCache.set(twin.id, value: twin)
    }

    /// Clear all cached twins
    func clearCache() async {
        await twinCache.clear()
        logger.info("Cache cleared")
    }

    /// Get cache statistics for monitoring
    func getCacheStats() async -> (count: Int, hitRatio: Double) {
        let count = await twinCache.count
        let hitRatio = await twinCache.hitRatio
        return (count, hitRatio)
    }

    /// Prune expired entries from cache
    func pruneExpiredCacheEntries() async {
        await twinCache.pruneExpired()
        logger.debug("Pruned expired cache entries")
    }

    // MARK: - Backend Communication

    private func fetchFromBackend(_ assetId: UUID) async throws -> DigitalTwin {
        // For now, create a mock twin since backend integration is not yet implemented
        // In production, this would fetch from the actual API
        logger.warning("Using mock data - backend API not yet implemented")

        let twin = DigitalTwin(
            name: "Mock Twin",
            assetType: .turbine,
            location: GeoLocation(
                latitude: 37.7749,
                longitude: -122.4194,
                facilityName: "Mock Facility"
            )
        )

        return twin
    }

    private func fetchSensorData(for twinId: UUID) async throws -> [SensorReading] {
        let endpoint = DigitalTwinEndpoint.fetchSensorData(twinId)
        let response: [SensorReading] = try await networkService.request(endpoint)
        return response
    }

    private func syncToBackend(_ twin: DigitalTwin) async throws {
        let endpoint = DigitalTwinEndpoint.createTwin(twin)
        let _: EmptyResponse = try await networkService.request(endpoint)
        logger.info("Twin synced to backend: \(twin.name)")
    }

    private func deleteFromBackend(_ twinId: UUID) async throws {
        let endpoint = DigitalTwinEndpoint.deleteTwin(twinId)
        let _: EmptyResponse = try await networkService.request(endpoint)
        logger.info("Twin deleted from backend: \(twinId)")
    }

    // MARK: - Bulk Operations

    /// Sync all local twins to backend
    func syncAllToBackend() async throws {
        syncStatus = .syncing

        let descriptor = FetchDescriptor<DigitalTwin>()
        let twins = try modelContext.fetch(descriptor)

        logger.info("Syncing \(twins.count) twins to backend")

        var successCount = 0
        var failureCount = 0

        for twin in twins {
            do {
                try await syncToBackend(twin)
                successCount += 1
            } catch {
                logger.error("Failed to sync twin \(twin.name): \(error)")
                failureCount += 1
            }
        }

        lastSyncDate = Date()
        syncStatus = .idle

        logger.info("Sync complete: \(successCount) success, \(failureCount) failed")
    }

    /// Calculate aggregate metrics across all twins
    func calculateAggregateMetrics() async throws -> AggregateMetrics {
        let descriptor = FetchDescriptor<DigitalTwin>()
        let twins = try modelContext.fetch(descriptor)

        let totalTwins = twins.count
        let activeTwins = twins.filter { $0.operationalStatus != .offline }.count
        let averageHealth = twins.map { $0.healthScore }.reduce(0, +) / Double(max(totalTwins, 1))
        let criticalCount = twins.filter { $0.operationalStatus == .critical }.count
        let warningCount = twins.filter { $0.operationalStatus == .warning }.count

        return AggregateMetrics(
            totalTwins: totalTwins,
            activeTwins: activeTwins,
            averageHealth: averageHealth,
            criticalCount: criticalCount,
            warningCount: warningCount
        )
    }
}

// MARK: - Supporting Types

enum SyncStatus {
    case idle
    case syncing
    case error(Error)
}

struct AggregateMetrics {
    let totalTwins: Int
    let activeTwins: Int
    let averageHealth: Double
    let criticalCount: Int
    let warningCount: Int

    var healthColor: String {
        switch averageHealth {
        case 90...100: return "green"
        case 70..<90: return "yellow"
        case 0..<70: return "red"
        default: return "gray"
        }
    }
}

struct Alert: Identifiable {
    let id: UUID
    let twinId: UUID
    let severity: AlertSeverity
    let title: String
    let message: String
    let timestamp: Date

    enum AlertSeverity {
        case info
        case warning
        case critical
    }
}

// MARK: - API Endpoints

enum DigitalTwinEndpoint: APIEndpoint {
    case fetchTwin(UUID)
    case createTwin(DigitalTwin)
    case updateTwin(UUID, DigitalTwin)
    case deleteTwin(UUID)
    case fetchSensorData(UUID)
    case fetchAllTwins

    var path: String {
        switch self {
        case .fetchTwin(let id):
            return "/api/v1/twins/\(id.uuidString)"
        case .createTwin:
            return "/api/v1/twins"
        case .updateTwin(let id, _):
            return "/api/v1/twins/\(id.uuidString)"
        case .deleteTwin(let id):
            return "/api/v1/twins/\(id.uuidString)"
        case .fetchSensorData(let id):
            return "/api/v1/twins/\(id.uuidString)/sensors"
        case .fetchAllTwins:
            return "/api/v1/twins"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchTwin, .fetchSensorData, .fetchAllTwins:
            return .GET
        case .createTwin:
            return .POST
        case .updateTwin:
            return .PUT
        case .deleteTwin:
            return .DELETE
        }
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    var body: Encodable? {
        switch self {
        case .createTwin, .updateTwin:
            // For now return nil, as we need to create proper DTOs for network serialization
            // In production, convert DigitalTwin to a Codable DTO
            return nil
        default:
            return nil
        }
    }
}

// MARK: - Performance Monitor

class PerformanceMonitor: @unchecked Sendable {
    static let shared = PerformanceMonitor()

    private var metrics: [String: [TimeInterval]] = [:]

    func measure<T>(_ label: String, operation: () async -> T) async -> T {
        let start = Date()
        let result = await operation()
        let duration = Date().timeIntervalSince(start)

        if metrics[label] == nil {
            metrics[label] = []
        }
        metrics[label]?.append(duration)

        // Log if slow
        if duration > 0.1 {
            print("⚠️ Performance warning: \(label) took \(String(format: "%.3f", duration))s")
        }

        return result
    }

    func getMetrics(for label: String) -> (avg: TimeInterval, max: TimeInterval, count: Int)? {
        guard let durations = metrics[label], !durations.isEmpty else {
            return nil
        }

        let avg = durations.reduce(0, +) / Double(durations.count)
        let max = durations.max() ?? 0

        return (avg, max, durations.count)
    }
}
