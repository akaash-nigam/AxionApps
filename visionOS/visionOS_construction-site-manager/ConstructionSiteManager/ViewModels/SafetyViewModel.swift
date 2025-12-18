import SwiftUI
import SwiftData
import Observation

/// ViewModel for safety monitoring and compliance tracking
/// Integrates with SafetyMonitoringService for real-time safety management
@Observable
final class SafetyViewModel {
    // MARK: - Properties

    private(set) var dangerZones: [DangerZone] = []
    private(set) var activeAlerts: [SafetyAlert] = []
    private(set) var safetyScore: Double = 100.0
    private(set) var isMonitoring = false
    private(set) var errorMessage: String?

    var selectedTimeRange: TimeRange = .today
    var selectedSeverity: AlertSeverity?
    var showResolvedAlerts = false

    enum TimeRange: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case all = "All Time"

        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            case .all:
                return Date.distantPast
            }
        }
    }

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let safetyService: SafetyMonitoringService

    // MARK: - Initialization

    init(modelContext: ModelContext, safetyService: SafetyMonitoringService) {
        self.modelContext = modelContext
        self.safetyService = safetyService
    }

    // MARK: - Public Methods

    /// Start safety monitoring
    func startMonitoring() {
        isMonitoring = true
        loadDangerZones()
        updateActiveAlerts()
        calculateSafetyScore()
    }

    /// Stop safety monitoring
    func stopMonitoring() {
        isMonitoring = false
    }

    /// Load danger zones from database
    func loadDangerZones() {
        do {
            let descriptor = FetchDescriptor<DangerZone>()
            dangerZones = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load danger zones: \(error.localizedDescription)"
        }
    }

    /// Create a new danger zone
    func createDangerZone(
        name: String,
        type: DangerType,
        severity: AlertSeverity,
        boundaryPoints: [SIMD3<Float>],
        warningDistance: Float = 5.0,
        activeTimeStart: Date? = nil,
        activeTimeEnd: Date? = nil
    ) throws {
        let zone = DangerZone(
            name: name,
            type: type,
            severity: severity,
            boundaryPoints: boundaryPoints,
            warningDistance: warningDistance,
            activeTimeStart: activeTimeStart,
            activeTimeEnd: activeTimeEnd
        )

        modelContext.insert(zone)
        try modelContext.save()

        dangerZones.append(zone)
    }

    /// Update danger zone
    func updateDangerZone(_ zone: DangerZone) throws {
        try modelContext.save()
    }

    /// Delete danger zone
    func deleteDangerZone(_ zone: DangerZone) throws {
        modelContext.delete(zone)
        try modelContext.save()

        dangerZones.removeAll { $0.id == zone.id }
    }

    /// Check position for violations
    func checkPosition(_ position: SIMD3<Float>) -> SafetyAlert? {
        safetyService.checkViolation(position: position, zones: dangerZones)
    }

    /// Update active alerts from service
    func updateActiveAlerts() {
        activeAlerts = safetyService.activeAlerts
    }

    /// Calculate current safety score
    func calculateSafetyScore() {
        safetyScore = safetyService.calculateSafetyScore(alerts: activeAlerts)
    }

    /// Resolve an alert
    func resolveAlert(_ alert: SafetyAlert) {
        safetyService.resolveAlert(alert)
        updateActiveAlerts()
        calculateSafetyScore()
    }

    /// Get filtered alerts
    func filteredAlerts() -> [SafetyAlert] {
        var filtered = activeAlerts

        // Apply time range filter
        filtered = filtered.filter { $0.createdDate >= selectedTimeRange.startDate }

        // Apply severity filter
        if let severity = selectedSeverity {
            filtered = filtered.filter { $0.severity == severity }
        }

        // Apply resolved filter
        if !showResolvedAlerts {
            filtered = filtered.filter { $0.resolvedDate == nil }
        }

        return filtered.sorted { $0.createdDate > $1.createdDate }
    }

    /// Get safety statistics
    func getStatistics() -> SafetyStatistics {
        let alerts = filteredAlerts()
        let total = alerts.count
        let resolved = alerts.filter { $0.resolvedDate != nil }.count
        let critical = alerts.filter { $0.severity == .critical }.count

        let bySeverity = Dictionary(grouping: alerts) { $0.severity }
        let byType = Dictionary(grouping: alerts) { $0.type }

        // Calculate average response time
        let responseTimes = alerts.compactMap { alert -> TimeInterval? in
            guard let resolved = alert.resolvedDate else { return nil }
            return resolved.timeIntervalSince(alert.createdDate)
        }
        let avgResponseTime = responseTimes.isEmpty ? 0 :
            responseTimes.reduce(0, +) / Double(responseTimes.count)

        return SafetyStatistics(
            totalAlerts: total,
            resolvedAlerts: resolved,
            criticalAlerts: critical,
            highAlerts: bySeverity[.high]?.count ?? 0,
            mediumAlerts: bySeverity[.medium]?.count ?? 0,
            lowAlerts: bySeverity[.low]?.count ?? 0,
            proximityViolations: byType[.proximityViolation]?.count ?? 0,
            missingPPE: byType[.missingPPE]?.count ?? 0,
            unsafeConditions: byType[.unsafeCondition]?.count ?? 0,
            safetyScore: safetyScore,
            averageResponseTime: avgResponseTime
        )
    }

    /// Get alert trend data for charting
    func getAlertTrendData() -> [AlertTrendPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = selectedTimeRange.startDate

        var trendData: [AlertTrendPoint] = []

        // Group alerts by day
        let groupedByDay = Dictionary(grouping: filteredAlerts()) { alert in
            calendar.startOfDay(for: alert.createdDate)
        }

        var currentDate = startDate
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let alertsForDay = groupedByDay[dayStart] ?? []

            let bySeverity = Dictionary(grouping: alertsForDay) { $0.severity }

            trendData.append(AlertTrendPoint(
                date: dayStart,
                critical: bySeverity[.critical]?.count ?? 0,
                high: bySeverity[.high]?.count ?? 0,
                medium: bySeverity[.medium]?.count ?? 0,
                low: bySeverity[.low]?.count ?? 0
            ))

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return trendData
    }

    /// Get compliance status
    func getComplianceStatus() -> [ComplianceItem] {
        // TODO: Implement compliance tracking
        // This would pull from a compliance tracking system
        [
            ComplianceItem(
                name: "PPE Requirements",
                status: .compliant,
                lastCheck: Date().addingTimeInterval(-3600)
            ),
            ComplianceItem(
                name: "Safety Training",
                status: .compliant,
                lastCheck: Date().addingTimeInterval(-86400)
            ),
            ComplianceItem(
                name: "Equipment Inspections",
                status: .warning,
                lastCheck: Date().addingTimeInterval(-172800)
            ),
            ComplianceItem(
                name: "Emergency Drills",
                status: .overdue,
                lastCheck: Date().addingTimeInterval(-604800)
            )
        ]
    }

    /// Get days since last incident
    func getDaysSinceLastIncident() -> Int {
        // TODO: Implement incident tracking
        // This would calculate from incident history
        45 // Placeholder
    }

    /// Report a safety incident
    func reportIncident(
        title: String,
        description: String,
        severity: AlertSeverity,
        location: SIMD3<Float>? = nil
    ) throws {
        let alert = SafetyAlert(
            type: .incident,
            severity: severity,
            message: title,
            createdDate: Date()
        )

        if let location = location {
            // Associate with nearby danger zone if applicable
            for zone in dangerZones where zone.containsPoint(location) {
                alert.relatedZone = zone
                break
            }
        }

        safetyService.activeAlerts.append(alert)
        updateActiveAlerts()
        calculateSafetyScore()

        // Send notification to safety officers
        sendIncidentNotification(alert)
    }

    /// Export safety report
    func exportSafetyReport() -> Data? {
        // TODO: Generate comprehensive safety report
        return nil
    }

    // MARK: - Private Methods

    private func sendIncidentNotification(_ alert: SafetyAlert) {
        // TODO: Send notification to safety officers
        print("Safety incident reported: \(alert.message)")
    }
}

// MARK: - Supporting Types

struct SafetyStatistics {
    let totalAlerts: Int
    let resolvedAlerts: Int
    let criticalAlerts: Int
    let highAlerts: Int
    let mediumAlerts: Int
    let lowAlerts: Int
    let proximityViolations: Int
    let missingPPE: Int
    let unsafeConditions: Int
    let safetyScore: Double
    let averageResponseTime: TimeInterval

    var resolutionRate: Double {
        guard totalAlerts > 0 else { return 0.0 }
        return Double(resolvedAlerts) / Double(totalAlerts) * 100
    }

    var criticalPercentage: Double {
        guard totalAlerts > 0 else { return 0.0 }
        return Double(criticalAlerts) / Double(totalAlerts) * 100
    }

    var formattedResponseTime: String {
        let hours = Int(averageResponseTime / 3600)
        let minutes = Int((averageResponseTime.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}

struct AlertTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let critical: Int
    let high: Int
    let medium: Int
    let low: Int

    var total: Int {
        critical + high + medium + low
    }
}

struct ComplianceItem: Identifiable {
    enum Status {
        case compliant, warning, overdue

        var color: Color {
            switch self {
            case .compliant: return .green
            case .warning: return .orange
            case .overdue: return .red
            }
        }
    }

    let id = UUID()
    let name: String
    let status: Status
    let lastCheck: Date
}
