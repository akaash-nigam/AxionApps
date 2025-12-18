//
//  CalculationHelpers.swift
//  SurgicalTrainingUniverse
//
//  Mathematical and statistical calculation utilities
//

import Foundation

enum CalculationHelpers {

    // MARK: - Statistical Calculations

    /// Calculate average of doubles
    static func average(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    /// Calculate median of doubles
    static func median(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let count = sorted.count

        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            return sorted[count / 2]
        }
    }

    /// Calculate standard deviation
    static func standardDeviation(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean = average(of: values)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let variance = average(of: squaredDifferences)
        return sqrt(variance)
    }

    /// Calculate variance
    static func variance(of values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean = average(of: values)
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        return average(of: squaredDifferences)
    }

    /// Calculate percentile
    static func percentile(_ p: Double, of values: [Double]) -> Double {
        guard !values.isEmpty, p >= 0, p <= 100 else { return 0 }
        let sorted = values.sorted()
        let index = (p / 100.0) * Double(sorted.count - 1)
        let lower = Int(floor(index))
        let upper = Int(ceil(index))

        if lower == upper {
            return sorted[lower]
        }

        let fraction = index - Double(lower)
        return sorted[lower] * (1 - fraction) + sorted[upper] * fraction
    }

    // MARK: - Performance Score Calculations

    /// Calculate overall score from accuracy, efficiency, and safety
    static func calculateOverallScore(
        accuracy: Double,
        efficiency: Double,
        safety: Double,
        weights: (accuracy: Double, efficiency: Double, safety: Double) = (0.4, 0.3, 0.3)
    ) -> Double {
        let weightedSum = accuracy * weights.accuracy +
                         efficiency * weights.efficiency +
                         safety * weights.safety
        return weightedSum.clamped(to: 0...100)
    }

    /// Calculate performance grade (A-F) from score
    static func calculateGrade(from score: Double) -> String {
        switch score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }

    /// Calculate detailed grade with plus/minus
    static func calculateDetailedGrade(from score: Double) -> String {
        switch score {
        case 97...100: return "A+"
        case 93..<97: return "A"
        case 90..<93: return "A-"
        case 87..<90: return "B+"
        case 83..<87: return "B"
        case 80..<83: return "B-"
        case 77..<80: return "C+"
        case 73..<77: return "C"
        case 70..<73: return "C-"
        case 67..<70: return "D+"
        case 63..<67: return "D"
        case 60..<63: return "D-"
        default: return "F"
        }
    }

    // MARK: - Precision Calculations

    /// Calculate precision score from velocity and force
    static func calculatePrecisionScore(velocity: Float, force: Float) -> Double {
        // Lower velocity and appropriate force = higher precision
        let velocityScore = max(0, 100 - Double(velocity * 100))
        let forceScore = 100 - abs(Double(force - 0.5) * 100) // Optimal force around 0.5
        return (velocityScore + forceScore) / 2.0
    }

    /// Calculate efficiency score from time and movements
    static func calculateEfficiencyScore(
        actualTime: TimeInterval,
        expectedTime: TimeInterval,
        actualMovements: Int,
        expectedMovements: Int
    ) -> Double {
        let timeRatio = expectedTime / max(actualTime, 1.0)
        let movementRatio = Double(expectedMovements) / max(Double(actualMovements), 1.0)
        let efficiency = (timeRatio + movementRatio) / 2.0
        return (efficiency * 100).clamped(to: 0...100)
    }

    // MARK: - Trend Calculations

    /// Calculate trend direction from two sets of values
    static func calculateTrend(recent: [Double], older: [Double]) -> TrendDirection {
        guard !recent.isEmpty && !older.isEmpty else { return .stable }

        let recentAvg = average(of: recent)
        let olderAvg = average(of: older)
        let difference = recentAvg - olderAvg

        if difference > 2.0 {
            return .improving
        } else if difference < -2.0 {
            return .declining
        } else {
            return .stable
        }
    }

    /// Calculate slope (rate of change) from data points
    static func calculateSlope(dataPoints: [(x: Double, y: Double)]) -> Double {
        guard dataPoints.count >= 2 else { return 0 }

        let n = Double(dataPoints.count)
        let sumX = dataPoints.reduce(0.0) { $0 + $1.x }
        let sumY = dataPoints.reduce(0.0) { $0 + $1.y }
        let sumXY = dataPoints.reduce(0.0) { $0 + ($1.x * $1.y) }
        let sumX2 = dataPoints.reduce(0.0) { $0 + ($1.x * $1.x) }

        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        return slope
    }

    // MARK: - Learning Curve Calculations

    /// Calculate learning curve progression
    static func calculateLearningCurve(sessions: [(sessionNumber: Int, score: Double)]) -> [Double] {
        guard !sessions.isEmpty else { return [] }

        // Calculate moving average for smoothing
        return sessions.enumerated().map { index, session in
            let start = max(0, index - 2) // Look at last 3 sessions
            let end = index + 1
            let window = sessions[start..<end]
            return average(of: window.map { $0.score })
        }
    }

    /// Calculate improvement rate (percentage change)
    static func calculateImprovementRate(initial: Double, current: Double) -> Double {
        guard initial != 0 else { return 0 }
        return ((current - initial) / initial) * 100
    }

    // MARK: - Distance Calculations

    /// Calculate 3D distance between two points
    static func distance(from point1: SIMD3<Float>, to point2: SIMD3<Float>) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    /// Calculate total path length from movement positions
    static func totalPathLength(positions: [SIMD3<Float>]) -> Float {
        guard positions.count >= 2 else { return 0 }

        var total: Float = 0
        for i in 0..<(positions.count - 1) {
            total += distance(from: positions[i], to: positions[i + 1])
        }
        return total
    }

    // MARK: - Normalization

    /// Normalize value to 0-1 range
    static func normalize(_ value: Double, min: Double, max: Double) -> Double {
        guard max != min else { return 0 }
        return ((value - min) / (max - min)).clamped(to: 0...1)
    }

    /// Denormalize value from 0-1 range
    static func denormalize(_ normalized: Double, min: Double, max: Double) -> Double {
        (normalized * (max - min) + min).clamped(to: min...max)
    }

    // MARK: - Weighted Average

    /// Calculate weighted average
    static func weightedAverage(values: [Double], weights: [Double]) -> Double {
        guard values.count == weights.count, !values.isEmpty else { return 0 }

        let weightedSum = zip(values, weights).reduce(0.0) { $0 + ($1.0 * $1.1) }
        let totalWeight = weights.reduce(0, +)

        guard totalWeight > 0 else { return 0 }
        return weightedSum / totalWeight
    }

    // MARK: - Percentile Rank

    /// Calculate percentile rank (what percentage of values are below this value)
    static func percentileRank(of value: Double, in values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }

        let belowCount = values.filter { $0 < value }.count
        return (Double(belowCount) / Double(values.count)) * 100
    }

    // MARK: - Correlation

    /// Calculate Pearson correlation coefficient
    static func correlation(between x: [Double], and y: [Double]) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0 }

        let n = Double(x.count)
        let meanX = average(of: x)
        let meanY = average(of: y)

        let numerator = zip(x, y).reduce(0.0) { $0 + (($1.0 - meanX) * ($1.1 - meanY)) }
        let denominatorX = x.reduce(0.0) { $0 + pow($1 - meanX, 2) }
        let denominatorY = y.reduce(0.0) { $0 + pow($1 - meanY, 2) }

        let denominator = sqrt(denominatorX * denominatorY)
        guard denominator > 0 else { return 0 }

        return numerator / denominator
    }

    // MARK: - Exponential Moving Average

    /// Calculate exponential moving average (for smoothing trends)
    static func exponentialMovingAverage(values: [Double], alpha: Double = 0.3) -> [Double] {
        guard !values.isEmpty else { return [] }

        var ema: [Double] = [values[0]]

        for i in 1..<values.count {
            let newEma = alpha * values[i] + (1 - alpha) * ema[i - 1]
            ema.append(newEma)
        }

        return ema
    }
}

// MARK: - Trend Direction

enum TrendDirection {
    case improving
    case stable
    case declining

    var description: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }
}
