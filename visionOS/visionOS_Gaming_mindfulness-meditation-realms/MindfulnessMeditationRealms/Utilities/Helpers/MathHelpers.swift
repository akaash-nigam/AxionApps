import Foundation

/// Mathematical helper functions for meditation app
enum MathHelpers {

    // MARK: - Statistics

    /// Calculate mean (average) of values
    static func mean(_ values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Float(values.count)
    }

    /// Calculate mean for Double values
    static func mean(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    /// Calculate median of values
    static func median(_ values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }

        let sorted = values.sorted()
        let count = sorted.count

        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2
        } else {
            return sorted[count / 2]
        }
    }

    /// Calculate standard deviation
    static func standardDeviation(_ values: [Float]) -> Float {
        guard values.count > 1 else { return 0 }

        let avg = mean(values)
        let squaredDiffs = values.map { pow($0 - avg, 2) }
        let variance = squaredDiffs.reduce(0, +) / Float(values.count - 1)

        return sqrt(variance)
    }

    /// Calculate variance
    static func variance(_ values: [Float]) -> Float {
        guard values.count > 1 else { return 0 }

        let avg = mean(values)
        let squaredDiffs = values.map { pow($0 - avg, 2) }

        return squaredDiffs.reduce(0, +) / Float(values.count - 1)
    }

    // MARK: - Normalization

    /// Normalize values to 0-1 range
    static func normalize(_ values: [Float]) -> [Float] {
        guard !values.isEmpty else { return [] }

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let range = maxValue - minValue

        guard range > 0 else { return values.map { _ in 0.5 } }

        return values.map { ($0 - minValue) / range }
    }

    /// Normalize single value based on min/max
    static func normalize(_ value: Float, min: Float, max: Float) -> Float {
        let range = max - min
        guard range > 0 else { return 0.5 }

        return ((value - min) / range).clamped(min: 0, max: 1)
    }

    // MARK: - Smoothing

    /// Moving average smoothing
    static func movingAverage(_ values: [Float], windowSize: Int) -> [Float] {
        guard values.count >= windowSize else { return values }

        var smoothed: [Float] = []

        for i in 0..<values.count {
            let startIndex = max(0, i - windowSize / 2)
            let endIndex = min(values.count, i + windowSize / 2 + 1)

            let window = Array(values[startIndex..<endIndex])
            smoothed.append(mean(window))
        }

        return smoothed
    }

    /// Exponential moving average
    static func exponentialMovingAverage(_ values: [Float], alpha: Float = 0.3) -> [Float] {
        guard !values.isEmpty else { return [] }

        var smoothed: [Float] = [values[0]]

        for i in 1..<values.count {
            let ema = alpha * values[i] + (1 - alpha) * smoothed[i - 1]
            smoothed.append(ema)
        }

        return smoothed
    }

    // MARK: - Trend Detection

    /// Calculate linear trend slope
    static func trendSlope(_ values: [Float]) -> Float {
        guard values.count >= 2 else { return 0 }

        let n = Float(values.count)
        let x = Array(0..<values.count).map { Float($0) }
        let y = values

        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map { $0 * $1 }.reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)

        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)

        return slope
    }

    /// Determine if trend is improving, declining, or stable
    static func trendDirection(_ values: [Float]) -> TrendDirection {
        let slope = trendSlope(values)

        if slope > 0.01 {
            return .improving
        } else if slope < -0.01 {
            return .declining
        } else {
            return .stable
        }
    }

    enum TrendDirection {
        case improving
        case declining
        case stable
    }

    // MARK: - Quality Scoring

    /// Calculate weighted average
    static func weightedAverage(_ values: [(value: Float, weight: Float)]) -> Float {
        guard !values.isEmpty else { return 0 }

        let weightedSum = values.reduce(0) { $0 + $1.value * $1.weight }
        let totalWeight = values.reduce(0) { $0 + $1.weight }

        guard totalWeight > 0 else { return 0 }

        return weightedSum / totalWeight
    }

    /// Calculate percentile rank (0-100)
    static func percentileRank(_ value: Float, in values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }

        let count = values.filter { $0 <= value }.count
        return (Float(count) / Float(values.count)) * 100
    }

    // MARK: - Distance/Similarity

    /// Calculate Euclidean distance between two points
    static func euclideanDistance(_ point1: [Float], _ point2: [Float]) -> Float {
        guard point1.count == point2.count else { return Float.infinity }

        let squaredDiffs = zip(point1, point2).map { pow($0 - $1, 2) }
        return sqrt(squaredDiffs.reduce(0, +))
    }

    /// Calculate cosine similarity (1 = identical, 0 = orthogonal, -1 = opposite)
    static func cosineSimilarity(_ vector1: [Float], _ vector2: [Float]) -> Float {
        guard vector1.count == vector2.count, !vector1.isEmpty else { return 0 }

        let dotProduct = zip(vector1, vector2).map { $0 * $1 }.reduce(0, +)

        let magnitude1 = sqrt(vector1.map { $0 * $0 }.reduce(0, +))
        let magnitude2 = sqrt(vector2.map { $0 * $0 }.reduce(0, +))

        guard magnitude1 > 0 && magnitude2 > 0 else { return 0 }

        return dotProduct / (magnitude1 * magnitude2)
    }

    // MARK: - Curve Fitting

    /// Simple exponential growth/decay curve
    static func exponentialCurve(t: Float, initial: Float, rate: Float) -> Float {
        return initial * exp(rate * t)
    }

    /// Logistic (S-curve) for modeling learning/adaptation
    static func logisticCurve(t: Float, max: Float = 1.0, midpoint: Float = 0.5, steepness: Float = 1.0) -> Float {
        return max / (1 + exp(-steepness * (t - midpoint)))
    }

    // MARK: - XP/Level Calculations

    /// Calculate XP required for level (exponential scaling)
    static func xpForLevel(_ level: Int, baseXP: Int = 100, exponent: Float = 1.5) -> Int {
        guard level > 1 else { return 0 }

        let xp = Float(baseXP) * pow(Float(level), exponent)
        return Int(xp)
    }

    /// Calculate level from total XP
    static func levelFromXP(_ totalXP: Int, baseXP: Int = 100, exponent: Float = 1.5) -> Int {
        var level = 1
        var accumulatedXP = 0

        while accumulatedXP < totalXP {
            level += 1
            accumulatedXP += xpForLevel(level, baseXP: baseXP, exponent: exponent)

            if level > 1000 { break } // Safety limit
        }

        return level - 1
    }
}
