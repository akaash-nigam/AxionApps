import Foundation
import RealityKit

@MainActor
class SafetyManager: ObservableObject {
    @Published private(set) var safetyState: SafetyState = .safe
    @Published private(set) var boundaryViolations: [BoundaryViolation] = []

    private var guardianBoundaries: [SafetyBoundary] = []
    private let warningDistance: Float = 0.5  // 50cm
    private let criticalDistance: Float = 0.1 // 10cm

    enum SafetyState {
        case safe
        case warning(distance: Float)
        case critical
        case violation
    }

    struct BoundaryViolation {
        let playerId: UUID
        let position: SIMD3<Float>
        let timestamp: Date
        let severity: Severity

        enum Severity {
            case warning
            case critical
        }
    }

    // MARK: - Boundary Management

    func setupBoundaries(for roomLayout: RoomLayout) {
        guardianBoundaries = roomLayout.safetyBoundaries
    }

    func addBoundary(_ boundary: SafetyBoundary) {
        guardianBoundaries.append(boundary)
    }

    func clearBoundaries() {
        guardianBoundaries.removeAll()
    }

    // MARK: - Position Checking

    func checkPlayerPosition(_ player: Player) async -> SafetyState {
        let position = player.position

        // Check distance to all boundaries
        var minimumDistance: Float = Float.greatestFiniteMagnitude

        for boundary in guardianBoundaries {
            let distance = calculateDistanceToBoundary(position, boundary: boundary)
            minimumDistance = min(minimumDistance, distance)
        }

        // Determine safety state
        let state: SafetyState
        if minimumDistance <= criticalDistance {
            state = .critical
            recordViolation(player: player, severity: .critical)
        } else if minimumDistance <= warningDistance {
            state = .warning(distance: minimumDistance)
            recordViolation(player: player, severity: .warning)
        } else {
            state = .safe
        }

        safetyState = state
        return state
    }

    func isPositionSafe(_ position: SIMD3<Float>) async -> Bool {
        for boundary in guardianBoundaries {
            let distance = calculateDistanceToBoundary(position, boundary: boundary)
            if distance <= criticalDistance {
                return false
            }
        }
        return true
    }

    private func calculateDistanceToBoundary(
        _ position: SIMD3<Float>,
        boundary: SafetyBoundary
    ) -> Float {
        guard !boundary.points.isEmpty else { return Float.greatestFiniteMagnitude }

        var minimumDistance: Float = Float.greatestFiniteMagnitude

        // Calculate distance to boundary polygon
        for i in 0..<boundary.points.count {
            let p1 = boundary.points[i]
            let p2 = boundary.points[(i + 1) % boundary.points.count]

            let distance = distanceToLineSegment(point: position, lineStart: p1, lineEnd: p2)
            minimumDistance = min(minimumDistance, distance)
        }

        return minimumDistance
    }

    private func distanceToLineSegment(
        point: SIMD3<Float>,
        lineStart: SIMD3<Float>,
        lineEnd: SIMD3<Float>
    ) -> Float {
        let line = lineEnd - lineStart
        let lineLength = length(line)

        if lineLength == 0 {
            return length(point - lineStart)
        }

        let t = max(0, min(1, dot(point - lineStart, line) / (lineLength * lineLength)))
        let projection = lineStart + t * line

        return length(point - projection)
    }

    // MARK: - Violation Recording

    private func recordViolation(player: Player, severity: BoundaryViolation.Severity) {
        let violation = BoundaryViolation(
            playerId: player.id,
            position: player.position,
            timestamp: Date(),
            severity: severity
        )

        boundaryViolations.append(violation)

        // Emit warning event
        Task {
            await emitSafetyWarning(violation: violation)
        }
    }

    private func emitSafetyWarning(violation: BoundaryViolation) async {
        // In real implementation, would emit through event bus
        print("⚠️ Safety Warning: Player \(violation.playerId) - \(violation.severity)")
    }

    // MARK: - Emergency Stop

    func triggerEmergencyStop() async {
        safetyState = .violation

        // In real implementation, would:
        // 1. Pause game immediately
        // 2. Display emergency UI
        // 3. Alert all players
        // 4. Log incident

        print("🛑 Emergency Stop Triggered")
    }

    // MARK: - Statistics

    func getViolationCount(for playerId: UUID) -> Int {
        return boundaryViolations.filter { $0.playerId == playerId }.count
    }

    func getTotalViolations() -> Int {
        return boundaryViolations.count
    }

    func getCriticalViolations() -> Int {
        return boundaryViolations.filter { $0.severity == .critical }.count
    }

    func clearViolationHistory() {
        boundaryViolations.removeAll()
    }
}
