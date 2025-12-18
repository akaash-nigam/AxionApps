import Foundation
import Observation

protocol MarketDataService {
    func getQuote(symbol: String) async throws -> MarketData
    func getHistoricalData(symbol: String, timeframe: TimeFrame) async throws -> [OHLCV]
    func subscribeToSymbol(_ symbol: String) async throws
    func unsubscribeFromSymbol(_ symbol: String) async
}

@Observable
class MockMarketDataService: MarketDataService {
    private var subscribedSymbols: Set<String> = []
    private var quotes: [String: MarketData] = [:]

    init() {
        // Initialize with some sample data
        initializeSampleData()
    }

    private func initializeSampleData() {
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA", "AMZN", "META", "JPM"]
        let basePrices: [String: Decimal] = [
            "AAPL": 189.45,
            "GOOGL": 142.78,
            "MSFT": 412.34,
            "NVDA": 789.23,
            "TSLA": 245.67,
            "AMZN": 178.90,
            "META": 487.23,
            "JPM": 189.12
        ]

        for symbol in symbols {
            let basePrice = basePrices[symbol] ?? 100.0
            let variation = Decimal(Double.random(in: -5...5))
            let price = basePrice + variation

            quotes[symbol] = MarketData(
                symbol: symbol,
                price: price,
                volume: Int64.random(in: 1_000_000...10_000_000),
                timestamp: Date(),
                exchange: "NASDAQ",
                bidPrice: price - 0.01,
                askPrice: price + 0.01,
                bidSize: Int.random(in: 100...1000),
                askSize: Int.random(in: 100...1000),
                dayHigh: price + Decimal(Double.random(in: 1...5)),
                dayLow: price - Decimal(Double.random(in: 1...5)),
                openPrice: price - Decimal(Double.random(in: -2...2)),
                previousClose: price - Decimal(Double.random(in: -3...3))
            )
        }
    }

    func getQuote(symbol: String) async throws -> MarketData {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(10))

        if let existing = quotes[symbol] {
            // Update with small price movement
            let priceChange = Decimal(Double.random(in: -0.5...0.5))
            let newPrice = existing.price + priceChange

            let updated = MarketData(
                symbol: symbol,
                price: newPrice,
                volume: existing.volume + Int64.random(in: 1000...10000),
                timestamp: Date(),
                exchange: existing.exchange,
                bidPrice: newPrice - 0.01,
                askPrice: newPrice + 0.01,
                bidSize: Int.random(in: 100...1000),
                askSize: Int.random(in: 100...1000),
                dayHigh: max(existing.dayHigh, newPrice),
                dayLow: min(existing.dayLow, newPrice),
                openPrice: existing.openPrice,
                previousClose: existing.previousClose
            )

            quotes[symbol] = updated
            return updated
        } else {
            // Create new quote
            let price = Decimal(Double.random(in: 50...500))
            let quote = MarketData(
                symbol: symbol,
                price: price,
                volume: Int64.random(in: 1_000_000...10_000_000),
                timestamp: Date(),
                exchange: "NASDAQ",
                bidPrice: price - 0.01,
                askPrice: price + 0.01,
                bidSize: Int.random(in: 100...1000),
                askSize: Int.random(in: 100...1000),
                dayHigh: price + Decimal(Double.random(in: 1...5)),
                dayLow: price - Decimal(Double.random(in: 1...5)),
                openPrice: price - Decimal(Double.random(in: -2...2)),
                previousClose: price - Decimal(Double.random(in: -3...3))
            )
            quotes[symbol] = quote
            return quote
        }
    }

    func getHistoricalData(symbol: String, timeframe: TimeFrame) async throws -> [OHLCV] {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(50))

        let dataPoints: Int
        switch timeframe {
        case .oneDay: dataPoints = 78  // 5-minute bars
        case .oneWeek: dataPoints = 35 // Hourly bars
        case .oneMonth: dataPoints = 30 // Daily bars
        case .threeMonths: dataPoints = 90
        case .oneYear: dataPoints = 252
        case .fiveYears: dataPoints = 260
        }

        var data: [OHLCV] = []
        var currentPrice = Decimal(Double.random(in: 100...300))

        for i in 0..<dataPoints {
            let open = currentPrice
            let change = Decimal(Double.random(in: -5...5))
            let close = open + change
            let high = max(open, close) + Decimal(Double.random(in: 0...2))
            let low = min(open, close) - Decimal(Double.random(in: 0...2))

            let timestamp = Date().addingTimeInterval(Double(-dataPoints + i) * 3600)

            data.append(OHLCV(
                timestamp: timestamp,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: Int64.random(in: 1_000_000...10_000_000)
            ))

            currentPrice = close
        }

        return data
    }

    func subscribeToSymbol(_ symbol: String) async throws {
        subscribedSymbols.insert(symbol)
    }

    func unsubscribeFromSymbol(_ symbol: String) async {
        subscribedSymbols.remove(symbol)
    }
}
