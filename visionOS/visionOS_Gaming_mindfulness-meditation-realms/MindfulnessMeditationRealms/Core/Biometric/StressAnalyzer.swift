import Foundation
import Combine

/// Analyzes multiple signals to estimate user stress levels
actor StressAnalyzer {

    // MARK: - Types

    struct StressEstimate {
        let overallStressLevel: Float // 0.0 (calm) to 1.0 (very stressed)
        let confidence: Float // 0.0 to 1.0
        let contributors: [StressContributor]
        let timestamp: Date

        enum StressContributor {
            case movement(score: Float, weight: Float)
            case breathing(score: Float, weight: Float)
            case posture(score: Float, weight: Float)
            case fidgeting(score: Float, weight: Float)
        }
    }

    // MARK: - Private Properties

    private var movementHistory: [MovementSample] = []
    private var breathingHistory: [BreathingSample] = []
    private let maxHistorySize = 30 // Last 60 seconds at 2Hz

    private struct MovementSample {
        let variance: Float
        let timestamp: Date
    }

    private struct BreathingSample {
        let rate: Double
        let regularity: Float
        let timestamp: Date
    }

    // MARK: - Public Methods

    func analyzeStressLevel() async -> StressEstimate {
        // In a real implementation, this would analyze actual sensor data
        // For now, we simulate a multi-modal stress analysis

        let movementScore = await analyzeMovementPatterns()
        let breathingScore = await analyzeBreathingPatterns()
        let postureScore = await analyzePostureStability()
        let fidgetingScore = await analyzeFidgetingFrequency()

        // Weighted combination
        let weights: [Float] = [0.3, 0.35, 0.2, 0.15] // breathing, movement, posture, fidgeting
        let scores: [Float] = [breathingScore, movementScore, postureScore, fidgetingScore]

        let overallStress = zip(scores, weights).reduce(0.0) { $0 + $1.0 * $1.1 }

        // Confidence based on sample size and variance
        let confidence = calculateConfidence()

        return StressEstimate(
            overallStressLevel: overallStress,
            confidence: confidence,
            contributors: [
                .movement(score: movementScore, weight: weights[1]),
                .breathing(score: breathingScore, weight: weights[0]),
                .posture(score: postureScore, weight: weights[2]),
                .fidgeting(score: fidgetingScore, weight: weights[3])
            ],
            timestamp: Date()
        )
    }

    func addMovementSample(variance: Float) async {
        let sample = MovementSample(variance: variance, timestamp: Date())
        movementHistory.append(sample)

        // Keep only recent samples
        if movementHistory.count > maxHistorySize {
            movementHistory.removeFirst(movementHistory.count - maxHistorySize)
        }
    }

    func addBreathingSample(rate: Double, regularity: Float) async {
        let sample = BreathingSample(rate: rate, regularity: regularity, timestamp: Date())
        breathingHistory.append(sample)

        if breathingHistory.count > maxHistorySize {
            breathingHistory.removeFirst(breathingHistory.count - maxHistorySize)
        }
    }

    // MARK: - Private Analysis Methods

    private func analyzeMovementPatterns() async -> Float {
        guard !movementHistory.isEmpty else {
            return 0.5 // Neutral if no data
        }

        // High movement variance indicates restlessness/stress
        let recentSamples = movementHistory.suffix(10)
        let averageVariance = recentSamples.map { $0.variance }.reduce(0, +) / Float(recentSamples.count)

        // Map variance to stress (0.0-0.5 variance -> 0.0-1.0 stress)
        let stressScore = min(1.0, averageVariance * 2.0)

        return stressScore
    }

    private func analyzeBreathingPatterns() async -> Float {
        guard !breathingHistory.isEmpty else {
            return 0.5
        }

        let recentSamples = breathingHistory.suffix(10)

        // Calculate average breathing rate
        let avgRate = recentSamples.map { $0.rate }.reduce(0, +) / Double(recentSamples.count)

        // Calculate irregularity (inverse of regularity)
        let avgRegularity = recentSamples.map { $0.regularity }.reduce(0, +) / Float(recentSamples.count)
        let irregularity = 1.0 - avgRegularity

        // Fast breathing (>18 bpm) and irregular = high stress
        // Slow breathing (<12 bpm) and regular = low stress
        let rateStress: Float
        if avgRate > 18 {
            rateStress = min(1.0, Float((avgRate - 18.0) / 10.0)) // Scale 18-28 bpm to 0.0-1.0
        } else if avgRate < 12 {
            rateStress = 0.0
        } else {
            rateStress = Float((avgRate - 12.0) / 6.0) // Scale 12-18 bpm to 0.0-1.0
        }

        // Combine rate and regularity
        let breathingStress = (rateStress * 0.6) + (irregularity * 0.4)

        return breathingStress
    }

    private func analyzePostureStability() async -> Float {
        // In real implementation, would analyze head/body position variance
        // Simulated: stable posture = low stress

        guard !movementHistory.isEmpty else {
            return 0.5
        }

        // Calculate variance of movement variance (meta-variance)
        let recentSamples = movementHistory.suffix(15)
        let variances = recentSamples.map { $0.variance }

        guard variances.count > 1 else { return 0.5 }

        let mean = variances.reduce(0, +) / Float(variances.count)
        let squaredDiffs = variances.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Float(squaredDiffs.count)

        // High variance in posture = instability = stress
        let postureStress = min(1.0, variance * 5.0)

        return postureStress
    }

    private func analyzeFidgetingFrequency() async -> Float {
        // Detect rapid, small movements that indicate fidgeting

        guard movementHistory.count >= 5 else {
            return 0.5
        }

        // Count movement spikes in recent history
        let recentSamples = movementHistory.suffix(20)
        let threshold: Float = 0.3

        let spikes = recentSamples.filter { $0.variance > threshold }.count

        // More spikes = more fidgeting = higher stress
        let fidgetingStress = min(1.0, Float(spikes) / 10.0)

        return fidgetingStress
    }

    private func calculateConfidence() async -> Float {
        // Confidence increases with more data and consistent patterns

        let movementSamples = Float(movementHistory.count)
        let breathingSamples = Float(breathingHistory.count)

        // Need at least 5 samples for decent confidence
        let sampleConfidence = min(1.0, (movementSamples + breathingSamples) / Float(maxHistorySize))

        // Additional confidence factors could include:
        // - Consistency of measurements
        // - Sensor quality indicators
        // - Time since session start

        return max(0.3, sampleConfidence) // Minimum 30% confidence
    }

    // MARK: - Calibration

    func reset() async {
        movementHistory.removeAll()
        breathingHistory.removeAll()
    }

    func getBaselineStressLevel() async -> Float {
        // Return average stress over entire history (for comparison)
        guard !movementHistory.isEmpty else { return 0.5 }

        let allMovementScores = movementHistory.map { min(1.0, $0.variance * 2.0) }
        let avgMovementStress = allMovementScores.reduce(0, +) / Float(allMovementScores.count)

        return avgMovementStress
    }
}
