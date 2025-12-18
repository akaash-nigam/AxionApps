import Foundation
import Combine

/// Monitors biometric signals and estimates wellness metrics
@MainActor
class BiometricMonitor: ObservableObject {

    // MARK: - Published Properties

    @Published var currentSnapshot: BiometricSnapshot
    @Published var isMonitoring: Bool = false

    // MARK: - Private Properties

    private var monitoringTask: Task<Void, Never>?
    private let stressAnalyzer: StressAnalyzer
    private let breathingAnalyzer: BreathingAnalyzer
    private var snapshots: [BiometricSnapshot] = []

    // MARK: - Initialization

    init() {
        self.stressAnalyzer = StressAnalyzer()
        self.breathingAnalyzer = BreathingAnalyzer()
        self.currentSnapshot = BiometricSnapshot.neutral()
    }

    // MARK: - Public Methods

    func startMonitoring() async {
        guard !isMonitoring else { return }

        isMonitoring = true

        monitoringTask = Task {
            await monitorLoop()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    func getCurrentSnapshot() -> BiometricSnapshot {
        return currentSnapshot
    }

    func getRecentSnapshots(count: Int = 10) -> [BiometricSnapshot] {
        return Array(snapshots.suffix(count))
    }

    // MARK: - Private Methods

    private func monitorLoop() async {
        while !Task.isCancelled && isMonitoring {
            // Collect biometric data
            let snapshot = await collectBiometricData()

            currentSnapshot = snapshot
            snapshots.append(snapshot)

            // Keep only recent snapshots
            if snapshots.count > 100 {
                snapshots.removeFirst(snapshots.count - 100)
            }

            // Wait before next collection (every 2 seconds)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    private func collectBiometricData() async -> BiometricSnapshot {
        // Estimate stress level
        let stressLevel = await stressAnalyzer.analyzeStressLevel()

        // Estimate breathing
        let breathingRate = await breathingAnalyzer.estimateBreathingRate()

        // Movement stillness (simulated for now)
        let stillness = await estimateStillness()

        // Focus level (simulated)
        let focus = await estimateFocus()

        // Calm level is inverse of stress
        let calmLevel = 1.0 - stressLevel.overallStressLevel

        return BiometricSnapshot(
            estimatedStressLevel: stressLevel.overallStressLevel,
            estimatedCalmLevel: calmLevel,
            breathingRate: breathingRate,
            movementStillness: stillness,
            focusLevel: focus
        )
    }

    private func estimateStillness() async -> Float {
        // In real implementation, would analyze movement variance
        // For now, simulate increasing stillness over time
        let sessionDuration = Double(snapshots.count) * 2.0 // seconds
        let maxStillness: Float = 0.95
        let growthRate: Float = 0.01

        let stillness = min(maxStillness, 0.5 + Float(sessionDuration) * growthRate)
        return stillness
    }

    private func estimateFocus() async -> Float {
        // In real implementation, would analyze eye movement and attention
        // For now, correlate with stillness
        let stillness = await estimateStillness()
        let baseFocus: Float = 0.6
        let focusBonus = stillness * 0.3

        return min(0.95, baseFocus + focusBonus)
    }
}
