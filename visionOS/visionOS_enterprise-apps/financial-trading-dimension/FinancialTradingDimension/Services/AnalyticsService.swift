import Foundation
import Observation

@Observable
class AnalyticsService {
    func calculateTechnicalIndicators(symbol: String, data: [OHLCV]) async -> TechnicalIndicators {
        await Task.yield()

        // Calculate simple moving averages
        let sma20 = calculateSMA(data: data, period: 20)
        let sma50 = calculateSMA(data: data, period: 50)
        let sma200 = calculateSMA(data: data, period: 200)

        // Calculate RSI
        let rsi = calculateRSI(data: data, period: 14)

        // Calculate MACD
        let macd = calculateMACD(data: data)

        return TechnicalIndicators(
            sma20: sma20,
            sma50: sma50,
            sma200: sma200,
            rsi: rsi,
            macd: macd,
            signal: macd.signal,
            histogram: macd.histogram
        )
    }

    private func calculateSMA(data: [OHLCV], period: Int) -> Decimal {
        guard data.count >= period else { return 0 }

        let recentData = data.suffix(period)
        let sum = recentData.reduce(Decimal(0)) { $0 + $1.close }
        return sum / Decimal(period)
    }

    private func calculateRSI(data: [OHLCV], period: Int) -> Double {
        guard data.count > period else { return 50.0 }

        var gains: [Double] = []
        var losses: [Double] = []

        for i in 1..<data.count {
            let change = Double(truncating: (data[i].close - data[i-1].close) as NSNumber)
            if change > 0 {
                gains.append(change)
                losses.append(0)
            } else {
                gains.append(0)
                losses.append(abs(change))
            }
        }

        let avgGain = gains.suffix(period).reduce(0, +) / Double(period)
        let avgLoss = losses.suffix(period).reduce(0, +) / Double(period)

        guard avgLoss != 0 else { return 100 }

        let rs = avgGain / avgLoss
        let rsi = 100 - (100 / (1 + rs))

        return rsi
    }

    private func calculateMACD(data: [OHLCV]) -> MACDResult {
        let ema12 = calculateEMA(data: data, period: 12)
        let ema26 = calculateEMA(data: data, period: 26)
        let macdLine = Double(truncating: (ema12 - ema26) as NSNumber)

        // Signal line is 9-period EMA of MACD
        let signal = macdLine * 0.9 // Simplified

        return MACDResult(
            macd: macdLine,
            signal: signal,
            histogram: macdLine - signal
        )
    }

    private func calculateEMA(data: [OHLCV], period: Int) -> Decimal {
        guard data.count >= period else { return 0 }

        let multiplier = Decimal(2.0 / Double(period + 1))
        var ema = data.prefix(period).reduce(Decimal(0)) { $0 + $1.close } / Decimal(period)

        for i in period..<data.count {
            ema = (data[i].close - ema) * multiplier + ema
        }

        return ema
    }

    func performCorrelationAnalysis(symbols: [String]) async -> CorrelationResult {
        await Task.yield()

        // Mock correlation data
        let correlations: [(String, String, Double)] = [
            ("AAPL", "MSFT", 0.75),
            ("AAPL", "GOOGL", 0.68),
            ("MSFT", "GOOGL", 0.82),
            ("NVDA", "TSLA", 0.45),
            ("AAPL", "NVDA", 0.55)
        ]

        return CorrelationResult(
            symbols: symbols,
            correlations: correlations,
            calculatedAt: Date()
        )
    }

    func identifyTradingPatterns(symbol: String, data: [OHLCV]) async -> [TradingPattern] {
        await Task.yield()

        // Simplified pattern recognition
        var patterns: [TradingPattern] = []

        // Head and shoulders detection (simplified)
        if data.count > 50 {
            patterns.append(TradingPattern(
                name: "Potential Head and Shoulders",
                type: .bearish,
                confidence: 0.65,
                timeframe: .oneMonth
            ))
        }

        // Moving average crossover
        let sma20 = calculateSMA(data: data, period: 20)
        let sma50 = calculateSMA(data: data, period: 50)

        if sma20 > sma50 {
            patterns.append(TradingPattern(
                name: "Golden Cross (SMA 20/50)",
                type: .bullish,
                confidence: 0.80,
                timeframe: .threeMonths
            ))
        }

        return patterns
    }
}

struct TechnicalIndicators {
    var sma20: Decimal
    var sma50: Decimal
    var sma200: Decimal
    var rsi: Double
    var macd: MACDResult
    var signal: Double
    var histogram: Double
}

struct MACDResult {
    var macd: Double
    var signal: Double
    var histogram: Double
}

struct CorrelationResult {
    var symbols: [String]
    var correlations: [(String, String, Double)]
    var calculatedAt: Date
}

struct TradingPattern {
    var name: String
    var type: PatternType
    var confidence: Double
    var timeframe: TimeFrame

    enum PatternType {
        case bullish
        case bearish
        case neutral
    }
}
