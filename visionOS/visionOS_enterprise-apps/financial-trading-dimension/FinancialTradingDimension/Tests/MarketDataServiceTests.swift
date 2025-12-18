import XCTest
import Foundation
@testable import FinancialTradingDimension

/// Unit tests for MarketDataService
/// Tests data retrieval, subscriptions, and mock service behavior
final class MarketDataServiceTests: XCTestCase {

    var sut: MockMarketDataService!

    override func setUp() async throws {
        try await super.setUp()
        sut = MockMarketDataService()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Quote Retrieval Tests

    func testGetQuoteReturnsValidData() async throws {
        // Given
        let symbol = "AAPL"

        // When
        let quote = try await sut.getQuote(symbol: symbol)

        // Then
        XCTAssertEqual(quote.symbol, symbol, "Quote should have correct symbol")
        XCTAssertGreaterThan(quote.price, 0, "Price should be positive")
        XCTAssertGreaterThan(quote.volume, 0, "Volume should be positive")
        XCTAssertLessThan(quote.bidPrice, quote.askPrice, "Bid should be less than ask")
    }

    func testGetQuoteForMultipleSymbols() async throws {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT"]

        // When
        let quotes = try await withThrowingTaskGroup(of: MarketData.self) { group in
            for symbol in symbols {
                group.addTask {
                    try await self.sut.getQuote(symbol: symbol)
                }
            }

            var results: [MarketData] = []
            for try await quote in group {
                results.append(quote)
            }
            return results
        }

        // Then
        XCTAssertEqual(quotes.count, 3, "Should return quotes for all symbols")
        let returnedSymbols = Set(quotes.map { $0.symbol })
        XCTAssertEqual(returnedSymbols, Set(symbols), "Should return correct symbols")
    }

    func testGetQuoteConsecutiveCallsShowPriceMovement() async throws {
        // Given
        let symbol = "AAPL"

        // When
        let quote1 = try await sut.getQuote(symbol: symbol)
        let quote2 = try await sut.getQuote(symbol: symbol)

        // Then
        XCTAssertNotEqual(quote1.timestamp, quote2.timestamp, "Timestamps should differ")
        // Price should change but be within reasonable range
        let priceDiff = abs(quote2.price - quote1.price)
        XCTAssertLessThan(priceDiff, 1.0, "Price change should be small for consecutive calls")
    }

    func testGetQuoteBidAskSpread() async throws {
        // Given
        let symbol = "TSLA"

        // When
        let quote = try await sut.getQuote(symbol: symbol)

        // Then
        let spread = quote.askPrice - quote.bidPrice
        XCTAssertGreaterThan(spread, 0, "Spread should be positive")
        XCTAssertLessThanOrEqual(spread, 0.10, "Spread should be reasonable")
    }

    func testGetQuoteDayHighLowConsistency() async throws {
        // Given
        let symbol = "NVDA"

        // When
        let quote = try await sut.getQuote(symbol: symbol)

        // Then
        XCTAssertGreaterThanOrEqual(quote.dayHigh, quote.price, "Day high should be >= current price")
        XCTAssertLessThanOrEqual(quote.dayLow, quote.price, "Day low should be <= current price")
        XCTAssertGreaterThan(quote.dayHigh, quote.dayLow, "Day high should be > day low")
    }

    // MARK: - Historical Data Tests

    func testGetHistoricalDataOneDayTimeframe() async throws {
        // Given
        let symbol = "AAPL"
        let timeframe = TimeFrame.oneDay

        // When
        let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)

        // Then
        XCTAssertEqual(data.count, 78, "One day should return 78 5-minute bars")
        XCTAssertTrue(data.allSatisfy { $0.high >= $0.low }, "High should be >= low for all bars")
        XCTAssertTrue(data.allSatisfy { $0.high >= $0.open }, "High should be >= open")
        XCTAssertTrue(data.allSatisfy { $0.high >= $0.close }, "High should be >= close")
        XCTAssertTrue(data.allSatisfy { $0.low <= $0.open }, "Low should be <= open")
        XCTAssertTrue(data.allSatisfy { $0.low <= $0.close }, "Low should be <= close")
    }

    func testGetHistoricalDataOneWeekTimeframe() async throws {
        // Given
        let symbol = "GOOGL"
        let timeframe = TimeFrame.oneWeek

        // When
        let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)

        // Then
        XCTAssertEqual(data.count, 35, "One week should return 35 hourly bars")
    }

    func testGetHistoricalDataOneMonthTimeframe() async throws {
        // Given
        let symbol = "MSFT"
        let timeframe = TimeFrame.oneMonth

        // When
        let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)

        // Then
        XCTAssertEqual(data.count, 30, "One month should return 30 daily bars")
    }

    func testGetHistoricalDataOneYearTimeframe() async throws {
        // Given
        let symbol = "NVDA"
        let timeframe = TimeFrame.oneYear

        // When
        let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)

        // Then
        XCTAssertEqual(data.count, 252, "One year should return 252 trading days")
    }

    func testGetHistoricalDataTimestampOrder() async throws {
        // Given
        let symbol = "TSLA"
        let timeframe = TimeFrame.oneWeek

        // When
        let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)

        // Then
        for i in 1..<data.count {
            XCTAssertLessThan(
                data[i-1].timestamp,
                data[i].timestamp,
                "Timestamps should be in ascending order"
            )
        }
    }

    func testGetHistoricalDataOHLCVConsistency() async throws {
        // Given
        let symbol = "META"
        let timeframe = TimeFrame.oneMonth

        // When
        let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)

        // Then
        for bar in data {
            // High should be the highest value
            XCTAssertGreaterThanOrEqual(bar.high, bar.open, "High >= Open")
            XCTAssertGreaterThanOrEqual(bar.high, bar.close, "High >= Close")
            XCTAssertGreaterThanOrEqual(bar.high, bar.low, "High >= Low")

            // Low should be the lowest value
            XCTAssertLessThanOrEqual(bar.low, bar.open, "Low <= Open")
            XCTAssertLessThanOrEqual(bar.low, bar.close, "Low <= Close")
            XCTAssertLessThanOrEqual(bar.low, bar.high, "Low <= High")

            // Volume should be positive
            XCTAssertGreaterThan(bar.volume, 0, "Volume should be positive")
        }
    }

    // MARK: - Subscription Tests

    func testSubscribeToSymbol() async throws {
        // Given
        let symbol = "AAPL"

        // When
        try await sut.subscribeToSymbol(symbol)

        // Then
        // Verify subscription doesn't throw
        // In a real implementation, we'd check internal state
        XCTAssertNoThrow(try await sut.subscribeToSymbol(symbol))
    }

    func testUnsubscribeFromSymbol() async throws {
        // Given
        let symbol = "GOOGL"
        try await sut.subscribeToSymbol(symbol)

        // When
        await sut.unsubscribeFromSymbol(symbol)

        // Then
        // Verify unsubscription doesn't throw
        XCTAssertNoThrow(await sut.unsubscribeFromSymbol(symbol))
    }

    func testMultipleSubscriptions() async throws {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]

        // When
        for symbol in symbols {
            try await sut.subscribeToSymbol(symbol)
        }

        // Then
        // Should not throw for multiple subscriptions
        XCTAssertNoThrow(try await sut.subscribeToSymbol("AMZN"))
    }

    // MARK: - Performance Tests

    func testGetQuotePerformance() async throws {
        // Measure time to get 100 quotes
        let startTime = Date()

        for _ in 0..<100 {
            _ = try await sut.getQuote(symbol: "AAPL")
        }

        let duration = Date().timeIntervalSince(startTime)

        // Should complete 100 quotes in less than 2 seconds (avg 20ms each)
        XCTAssertLessThan(duration, 2.0, "Should get 100 quotes quickly")
    }

    func testGetHistoricalDataPerformance() async throws {
        // Measure time to get historical data
        let startTime = Date()

        _ = try await sut.getHistoricalData(symbol: "AAPL", timeframe: .oneYear)

        let duration = Date().timeIntervalSince(startTime)

        // Should complete in less than 100ms
        XCTAssertLessThan(duration, 0.1, "Should get historical data quickly")
    }

    func testConcurrentQuoteRetrieval() async throws {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA", "AMZN", "META", "JPM"]

        // When
        let startTime = Date()
        let quotes = try await withThrowingTaskGroup(of: MarketData.self) { group in
            for symbol in symbols {
                group.addTask {
                    try await self.sut.getQuote(symbol: symbol)
                }
            }

            var results: [MarketData] = []
            for try await quote in group {
                results.append(quote)
            }
            return results
        }
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertEqual(quotes.count, symbols.count, "Should retrieve all quotes")
        // Concurrent calls should be faster than sequential
        XCTAssertLessThan(duration, 0.2, "Concurrent retrieval should be fast")
    }

    // MARK: - Edge Cases

    func testGetQuoteForUnknownSymbol() async throws {
        // Given
        let symbol = "UNKNOWN_TICKER"

        // When
        let quote = try await sut.getQuote(symbol: symbol)

        // Then
        XCTAssertEqual(quote.symbol, symbol, "Should create quote for unknown symbol")
        XCTAssertGreaterThan(quote.price, 0, "Should generate valid price")
    }

    func testGetQuoteEmptySymbol() async throws {
        // Given
        let symbol = ""

        // When
        let quote = try await sut.getQuote(symbol: symbol)

        // Then
        // Mock service should handle gracefully
        XCTAssertEqual(quote.symbol, symbol)
    }

    func testHistoricalDataAllTimeframes() async throws {
        // Given
        let symbol = "AAPL"
        let timeframes: [TimeFrame] = [.oneDay, .oneWeek, .oneMonth, .threeMonths, .oneYear, .fiveYears]

        // When/Then
        for timeframe in timeframes {
            let data = try await sut.getHistoricalData(symbol: symbol, timeframe: timeframe)
            XCTAssertGreaterThan(data.count, 0, "Should return data for \(timeframe.rawValue)")
        }
    }
}
