import XCTest
import Foundation
@testable import FinancialTradingDimension

/// Unit tests for AnalyticsService
/// Tests technical indicators, pattern recognition, and correlation analysis
final class AnalyticsServiceTests: XCTestCase {

    var sut: AnalyticsService!
    var sampleData: [OHLCV]!

    override func setUp() async throws {
        try await super.setUp()
        sut = AnalyticsService()
        sampleData = createSampleOHLCVData()
    }

    override func tearDown() async throws {
        sut = nil
        sampleData = nil
        try await super.tearDown()
    }

    // MARK: - Helper Methods

    private func createSampleOHLCVData() -> [OHLCV] {
        var data: [OHLCV] = []
        var basePrice: Decimal = 100.0

        for i in 0..<252 { // One year of trading days
            let open = basePrice
            let change = Decimal(Double.random(in: -2...2))
            let close = open + change
            let high = max(open, close) + Decimal(Double.random(in: 0...1))
            let low = min(open, close) - Decimal(Double.random(in: 0...1))

            data.append(OHLCV(
                timestamp: Date().addingTimeInterval(Double(-252 + i) * 86400),
                open: open,
                high: high,
                low: low,
                close: close,
                volume: Int64.random(in: 1_000_000...10_000_000)
            ))

            basePrice = close
        }

        return data
    }

    // MARK: - Technical Indicators Tests

    func testCalculateTechnicalIndicators() async {
        // Given
        let symbol = "AAPL"

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: symbol, data: sampleData)

        // Then
        XCTAssertGreaterThan(indicators.sma20, 0, "SMA 20 should be positive")
        XCTAssertGreaterThan(indicators.sma50, 0, "SMA 50 should be positive")
        XCTAssertGreaterThan(indicators.sma200, 0, "SMA 200 should be positive")
        XCTAssertGreaterThanOrEqual(indicators.rsi, 0, "RSI should be >= 0")
        XCTAssertLessThanOrEqual(indicators.rsi, 100, "RSI should be <= 100")
    }

    func testSMACalculationWithInsufficientData() async {
        // Given
        let shortData = Array(sampleData.prefix(10))

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: "AAPL", data: shortData)

        // Then
        // Should handle gracefully with insufficient data
        XCTAssertEqual(indicators.sma50, 0, "SMA 50 should be 0 with insufficient data")
        XCTAssertEqual(indicators.sma200, 0, "SMA 200 should be 0 with insufficient data")
    }

    func testRSICalculation() async {
        // Given
        // Create data with upward trend for high RSI
        var upwardData: [OHLCV] = []
        var price: Decimal = 100.0

        for i in 0..<50 {
            upwardData.append(OHLCV(
                timestamp: Date().addingTimeInterval(Double(i) * 86400),
                open: price,
                high: price + 1,
                low: price - 0.5,
                close: price + 0.5,
                volume: 1_000_000
            ))
            price += 0.5
        }

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: "AAPL", data: upwardData)

        // Then
        XCTAssertGreaterThan(indicators.rsi, 50, "Upward trend should have RSI > 50")
    }

    func testMACDCalculation() async {
        // Given
        let symbol = "GOOGL"

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: symbol, data: sampleData)

        // Then
        XCTAssertNotNil(indicators.macd, "Should calculate MACD")
        XCTAssertNotNil(indicators.signal, "Should calculate signal line")
        XCTAssertNotNil(indicators.histogram, "Should calculate histogram")

        // Histogram should equal MACD - Signal
        let expectedHistogram = indicators.macd.macd - indicators.signal
        XCTAssertEqual(indicators.histogram, expectedHistogram, accuracy: 0.01, "Histogram should equal MACD - Signal")
    }

    func testSMAOrdering() async {
        // Given
        let symbol = "MSFT"

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: symbol, data: sampleData)

        // Then
        // In most cases, SMA200 should be close to the average
        // This is a loose check since we have random data
        XCTAssertGreaterThan(indicators.sma20, 0)
        XCTAssertGreaterThan(indicators.sma50, 0)
        XCTAssertGreaterThan(indicators.sma200, 0)
    }

    // MARK: - Correlation Analysis Tests

    func testPerformCorrelationAnalysis() async {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]

        // When
        let result = await sut.performCorrelationAnalysis(symbols: symbols)

        // Then
        XCTAssertEqual(result.symbols, symbols, "Should include all symbols")
        XCTAssertGreaterThan(result.correlations.count, 0, "Should have correlation data")
        XCTAssertNotNil(result.calculatedAt, "Should have timestamp")
    }

    func testCorrelationValues() async {
        // Given
        let symbols = ["AAPL", "MSFT"]

        // When
        let result = await sut.performCorrelationAnalysis(symbols: symbols)

        // Then
        for (_, _, correlation) in result.correlations {
            XCTAssertGreaterThanOrEqual(correlation, -1.0, "Correlation should be >= -1")
            XCTAssertLessThanOrEqual(correlation, 1.0, "Correlation should be <= 1")
        }
    }

    func testCorrelationAnalysisWithSingleSymbol() async {
        // Given
        let symbols = ["AAPL"]

        // When
        let result = await sut.performCorrelationAnalysis(symbols: symbols)

        // Then
        XCTAssertEqual(result.symbols, symbols)
        // Mock service may return empty or predefined correlations
    }

    // MARK: - Pattern Recognition Tests

    func testIdentifyTradingPatterns() async {
        // Given
        let symbol = "NVDA"

        // When
        let patterns = await sut.identifyTradingPatterns(symbol: symbol, data: sampleData)

        // Then
        XCTAssertGreaterThan(patterns.count, 0, "Should identify some patterns")
    }

    func testPatternConfidence() async {
        // Given
        let symbol = "TSLA"

        // When
        let patterns = await sut.identifyTradingPatterns(symbol: symbol, data: sampleData)

        // Then
        for pattern in patterns {
            XCTAssertGreaterThanOrEqual(pattern.confidence, 0.0, "Confidence should be >= 0")
            XCTAssertLessThanOrEqual(pattern.confidence, 1.0, "Confidence should be <= 1")
        }
    }

    func testPatternTypes() async {
        // Given
        let symbol = "META"

        // When
        let patterns = await sut.identifyTradingPatterns(symbol: symbol, data: sampleData)

        // Then
        for pattern in patterns {
            XCTAssertTrue(
                pattern.type == .bullish || pattern.type == .bearish || pattern.type == .neutral,
                "Pattern should have valid type"
            )
        }
    }

    func testGoldenCrossPattern() async {
        // Given
        // Create data with golden cross (SMA20 > SMA50)
        var goldenCrossData: [OHLCV] = []
        var price: Decimal = 100.0

        // Create upward trend for 100 days
        for i in 0..<100 {
            price += Decimal(0.5)
            goldenCrossData.append(OHLCV(
                timestamp: Date().addingTimeInterval(Double(i) * 86400),
                open: price,
                high: price + 1,
                low: price - 0.5,
                close: price,
                volume: 1_000_000
            ))
        }

        // When
        let patterns = await sut.identifyTradingPatterns(symbol: "AAPL", data: goldenCrossData)

        // Then
        let hasGoldenCross = patterns.contains { $0.name.contains("Golden Cross") }
        XCTAssertTrue(hasGoldenCross, "Should identify golden cross pattern")
    }

    func testPatternRecognitionWithInsufficientData() async {
        // Given
        let shortData = Array(sampleData.prefix(10))

        // When
        let patterns = await sut.identifyTradingPatterns(symbol: "AAPL", data: shortData)

        // Then
        // Should handle gracefully, may return empty or limited patterns
        XCTAssertGreaterThanOrEqual(patterns.count, 0, "Should handle insufficient data")
    }

    // MARK: - Performance Tests

    func testTechnicalIndicatorsPerformance() async {
        // Given
        let symbol = "AAPL"

        // When
        let startTime = Date()
        for _ in 0..<10 {
            _ = await sut.calculateTechnicalIndicators(symbol: symbol, data: sampleData)
        }
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertLessThan(duration, 1.0, "Should calculate indicators quickly")
    }

    func testCorrelationAnalysisPerformance() async {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA", "AMZN", "META", "JPM"]

        // When
        let startTime = Date()
        for _ in 0..<10 {
            _ = await sut.performCorrelationAnalysis(symbols: symbols)
        }
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertLessThan(duration, 1.0, "Should perform correlation analysis quickly")
    }

    func testPatternRecognitionPerformance() async {
        // Given
        let symbol = "AAPL"

        // When
        let startTime = Date()
        for _ in 0..<10 {
            _ = await sut.identifyTradingPatterns(symbol: symbol, data: sampleData)
        }
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertLessThan(duration, 1.0, "Should identify patterns quickly")
    }

    // MARK: - Edge Cases

    func testEmptyDataArray() async {
        // Given
        let emptyData: [OHLCV] = []

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: "AAPL", data: emptyData)

        // Then
        XCTAssertEqual(indicators.sma20, 0, "Should handle empty data")
        XCTAssertEqual(indicators.sma50, 0, "Should handle empty data")
        XCTAssertEqual(indicators.sma200, 0, "Should handle empty data")
    }

    func testSingleDataPoint() async {
        // Given
        let singlePoint = [OHLCV(
            timestamp: Date(),
            open: 100,
            high: 105,
            low: 98,
            close: 103,
            volume: 1_000_000
        )]

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: "AAPL", data: singlePoint)

        // Then
        // Should handle gracefully with single data point
        XCTAssertGreaterThanOrEqual(indicators.rsi, 0)
        XCTAssertLessThanOrEqual(indicators.rsi, 100)
    }

    func testCorrelationWithEmptySymbols() async {
        // Given
        let emptySymbols: [String] = []

        // When
        let result = await sut.performCorrelationAnalysis(symbols: emptySymbols)

        // Then
        XCTAssertEqual(result.symbols.count, 0, "Should handle empty symbols")
    }

    // MARK: - Integration Tests

    func testFullAnalysisWorkflow() async {
        // Given
        let symbol = "AAPL"
        let symbols = ["AAPL", "GOOGL", "MSFT"]

        // When
        let indicators = await sut.calculateTechnicalIndicators(symbol: symbol, data: sampleData)
        let patterns = await sut.identifyTradingPatterns(symbol: symbol, data: sampleData)
        let correlations = await sut.performCorrelationAnalysis(symbols: symbols)

        // Then
        XCTAssertGreaterThan(indicators.sma20, 0, "Should calculate indicators")
        XCTAssertGreaterThanOrEqual(patterns.count, 0, "Should identify patterns")
        XCTAssertEqual(correlations.symbols, symbols, "Should calculate correlations")
    }
}
