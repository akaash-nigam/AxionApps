//
//  SafetyMonitoringService.swift
//  Construction Site Manager
//
//  Real-time safety monitoring
//

import Foundation
import simd

/// Monitors worker safety and danger zones
@MainActor
@Observable
final class SafetyMonitoringService {
    static let shared = SafetyMonitoringService()

    private(set) var activeAlerts: [SafetyAlert] = []
    private(set) var isMonitoring: Bool = false

    private init() {}

    /// Start safety monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        print("Safety monitoring started")

        // Start monitoring loop
        Task {
            await monitoringLoop()
        }
    }

    /// Stop safety monitoring
    func stopMonitoring() {
        isMonitoring = false
        print("Safety monitoring stopped")
    }

    /// Check if a position violates any danger zones
    func checkViolation(
        position: SIMD3<Float>,
        zones: [DangerZone]
    ) -> SafetyAlert? {
        for zone in zones where zone.isCurrentlyActive {
            // Check if position is inside danger zone
            if zone.containsPoint(position) {
                return createAlert(
                    type: .proximityViolation,
                    severity: zone.severity,
                    message: "Worker inside \(zone.name)",
                    location: position,
                    dangerZoneID: zone.id
                )
            }

            // Check if position is within warning distance
            let distance = zone.distanceToPoint(position)
            if distance < zone.warningDistance {
                return createAlert(
                    type: .proximityViolation,
                    severity: .low,
                    message: "Worker approaching \(zone.name) (\(String(format: "%.1f", distance))m away)",
                    location: position,
                    dangerZoneID: zone.id
                )
            }
        }

        return nil
    }

    /// Add a safety alert
    @MainActor
    func addAlert(_ alert: SafetyAlert) {
        activeAlerts.append(alert)

        // Trigger notification
        Task {
            await notifyAlert(alert)
        }

        print("Safety alert added: \(alert.message)")
    }

    /// Acknowledge an alert
    @MainActor
    func acknowledgeAlert(_ alertId: UUID, by user: String) {
        if let index = activeAlerts.firstIndex(where: { $0.id == alertId }) {
            activeAlerts[index].acknowledgedBy = user
            activeAlerts[index].acknowledgedAt = Date()
            print("Alert acknowledged by \(user)")
        }
    }

    /// Resolve an alert
    @MainActor
    func resolveAlert(_ alertId: UUID, notes: String? = nil) {
        if let index = activeAlerts.firstIndex(where: { $0.id == alertId }) {
            activeAlerts[index].resolved = true
            activeAlerts[index].resolvedAt = Date()
            activeAlerts[index].notes = notes
            print("Alert resolved")

            // Remove from active alerts after a delay
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                await removeAlert(alertId)
            }
        }
    }

    @MainActor
    private func removeAlert(_ alertId: UUID) {
        activeAlerts.removeAll { $0.id == alertId }
    }

    // MARK: - Private Methods

    private func monitoringLoop() async {
        while isMonitoring {
            // Monitoring logic would go here
            // In production, this would:
            // - Track worker positions
            // - Check danger zone violations
            // - Analyze behavior patterns
            // - Trigger alerts

            try? await Task.sleep(nanoseconds: 1_000_000_000) // Check every second
        }
    }

    private func createAlert(
        type: SafetyAlertType,
        severity: SafetySeverity,
        message: String,
        location: SIMD3<Float>? = nil,
        dangerZoneID: UUID? = nil,
        workerID: String? = nil
    ) -> SafetyAlert {
        SafetyAlert(
            type: type,
            severity: severity,
            message: message,
            location: location,
            dangerZoneID: dangerZoneID,
            workerID: workerID
        )
    }

    private func notifyAlert(_ alert: SafetyAlert) async {
        // Send notifications to relevant personnel
        // In production:
        // - Play spatial audio warning
        // - Send push notifications
        // - Display AR overlay warning
        // - Log to safety system

        print("🚨 SAFETY ALERT: \(alert.severity.displayName) - \(alert.message)")
    }

    /// Calculate safety score based on recent alerts
    func calculateSafetyScore(alerts: [SafetyAlert]) -> Double {
        // Simple scoring algorithm
        // In production, this would be more sophisticated

        guard !alerts.isEmpty else { return 100.0 }

        let now = Date()
        let last30Days = alerts.filter { now.timeIntervalSince($0.timestamp) < 30 * 24 * 3600 }

        // Deduct points based on severity and count
        var score = 100.0
        for alert in last30Days {
            switch alert.severity {
            case .critical:
                score -= 10.0
            case .high:
                score -= 5.0
            case .medium:
                score -= 2.0
            case .low:
                score -= 1.0
            }
        }

        return max(0.0, min(100.0, score))
    }
}
