import Foundation
import Combine

/// Analyzes body movement patterns to estimate breathing rate and quality
actor BreathingAnalyzer {

    // MARK: - Types

    struct BreathingEstimate {
        let rate: Double // Breaths per minute
        let regularity: Float // 0.0 (irregular) to 1.0 (very regular)
        let depth: BreathDepth
        let pattern: BreathingPattern
        let timestamp: Date

        enum BreathDepth {
            case shallow
            case normal
            case deep
        }

        enum BreathingPattern {
            case normal
            case rapid // Tachypnea
            case slow // Bradypnea
            case irregular
            case rhythmic
        }
    }

    // MARK: - Private Properties

    private var breathCycles: [BreathCycle] = []
    private var movementSamples: [MovementSample] = []
    private let maxHistorySize = 60 // 2 minutes at 2Hz

    private struct BreathCycle {
        let duration: TimeInterval // Seconds per breath
        let amplitude: Float // Estimated depth
        let timestamp: Date
    }

    private struct MovementSample {
        let chestExpansion: Float // Estimated from body tracking
        let timestamp: Date
    }

    // MARK: - Public Methods

    func estimateBreathingRate() async -> Double {
        let estimate = await analyzeBreathing()
        return estimate.rate
    }

    func analyzeBreathing() async -> BreathingEstimate {
        // In real implementation, would use torso movement tracking
        // Simulate breathing analysis based on movement patterns

        let rate = await calculateBreathingRate()
        let regularity = await calculateRegularity()
        let depth = await estimateBreathDepth()
        let pattern = await identifyPattern(rate: rate, regularity: regularity)

        return BreathingEstimate(
            rate: rate,
            regularity: regularity,
            depth: depth,
            pattern: pattern,
            timestamp: Date()
        )
    }

    func addMovementSample(chestExpansion: Float) async {
        let sample = MovementSample(chestExpansion: chestExpansion, timestamp: Date())
        movementSamples.append(sample)

        if movementSamples.count > maxHistorySize {
            movementSamples.removeFirst(movementSamples.count - maxHistorySize)
        }

        // Detect breath cycles from movement
        await detectBreathCycle(from: sample)
    }

    // MARK: - Private Analysis Methods

    private func calculateBreathingRate() async -> Double {
        guard breathCycles.count >= 3 else {
            return 16.0 // Default normal breathing rate
        }

        // Use recent cycles (last 30 seconds)
        let recentCycles = breathCycles.suffix(15)

        // Calculate average cycle duration
        let avgDuration = recentCycles.map { $0.duration }.reduce(0, +) / Double(recentCycles.count)

        // Convert to breaths per minute
        let rate = 60.0 / avgDuration

        // Clamp to physiologically reasonable range
        return max(4.0, min(30.0, rate))
    }

    private func calculateRegularity() async -> Float {
        guard breathCycles.count >= 5 else {
            return 0.5 // Neutral if not enough data
        }

        let recentCycles = breathCycles.suffix(10)
        let durations = recentCycles.map { $0.duration }

        // Calculate coefficient of variation (lower = more regular)
        let mean = durations.reduce(0, +) / Double(durations.count)
        let squaredDiffs = durations.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(squaredDiffs.count)
        let stdDev = sqrt(variance)

        let coefficientOfVariation = stdDev / mean

        // Map CV to regularity score (0.0-0.3 CV -> 1.0-0.0 regularity)
        let regularity = max(0.0, min(1.0, 1.0 - Float(coefficientOfVariation * 3.0)))

        return regularity
    }

    private func estimateBreathDepth() async -> BreathingEstimate.BreathDepth {
        guard breathCycles.count >= 3 else {
            return .normal
        }

        let recentCycles = breathCycles.suffix(10)
        let avgAmplitude = recentCycles.map { $0.amplitude }.reduce(0, +) / Float(recentCycles.count)

        if avgAmplitude > 0.7 {
            return .deep
        } else if avgAmplitude < 0.4 {
            return .shallow
        } else {
            return .normal
        }
    }

    private func identifyPattern(rate: Double, regularity: Float) async -> BreathingEstimate.BreathingPattern {
        // Classify breathing pattern based on rate and regularity

        if regularity < 0.5 {
            return .irregular
        }

        if regularity > 0.8 {
            return .rhythmic
        }

        if rate > 20 {
            return .rapid
        } else if rate < 10 {
            return .slow
        } else {
            return .normal
        }
    }

    private func detectBreathCycle(from sample: MovementSample) async {
        // Detect complete breath cycles using peak detection
        // In real implementation, would use proper signal processing

        guard movementSamples.count >= 3 else { return }

        let recent = movementSamples.suffix(3)
        let values = recent.map { $0.chestExpansion }

        // Simple peak detection: middle value is peak
        if values[1] > values[0] && values[1] > values[2] {
            // Peak detected - complete breath cycle

            if let lastCycle = breathCycles.last {
                let duration = sample.timestamp.timeIntervalSince(lastCycle.timestamp)

                // Only accept cycles between 1.5 and 15 seconds (4-40 bpm)
                if duration >= 1.5 && duration <= 15.0 {
                    let cycle = BreathCycle(
                        duration: duration,
                        amplitude: values[1],
                        timestamp: sample.timestamp
                    )
                    breathCycles.append(cycle)

                    if breathCycles.count > 30 {
                        breathCycles.removeFirst(breathCycles.count - 30)
                    }
                }
            } else {
                // First cycle
                let cycle = BreathCycle(
                    duration: 4.0, // Assume normal
                    amplitude: values[1],
                    timestamp: sample.timestamp
                )
                breathCycles.append(cycle)
            }
        }
    }

    // MARK: - Guided Breathing Support

    func startGuidedBreathing(targetRate: Double) async {
        // Reset to baseline for guided session
        await reset()
    }

    func getBreathingCoherence() async -> Float {
        // Coherence measures alignment with ideal breathing patterns
        // Higher coherence = better HRV and stress reduction

        guard breathCycles.count >= 5 else {
            return 0.5
        }

        let regularity = await calculateRegularity()
        let rate = await calculateBreathingRate()

        // Optimal coherence around 6 breaths per minute
        let optimalRate = 6.0
        let rateDiff = abs(rate - optimalRate)
        let rateCoherence = max(0.0, 1.0 - Float(rateDiff / 10.0))

        // Combine regularity and rate alignment
        let coherence = (regularity * 0.6) + (rateCoherence * 0.4)

        return coherence
    }

    // MARK: - Calibration

    func reset() async {
        breathCycles.removeAll()
        movementSamples.removeAll()
    }

    func calibrate(restingRate: Double) async {
        // Store baseline breathing rate for comparison
        // In real implementation, would use this for personalized analysis
    }

    // MARK: - Statistics

    func getBreathingStatistics() async -> BreathingStatistics {
        let rate = await calculateBreathingRate()
        let regularity = await calculateRegularity()
        let depth = await estimateBreathDepth()
        let coherence = await getBreathingCoherence()

        return BreathingStatistics(
            averageRate: rate,
            regularity: regularity,
            depth: depth,
            coherence: coherence,
            totalCycles: breathCycles.count
        )
    }

    struct BreathingStatistics {
        let averageRate: Double
        let regularity: Float
        let depth: BreathingEstimate.BreathDepth
        let coherence: Float
        let totalCycles: Int
    }
}
