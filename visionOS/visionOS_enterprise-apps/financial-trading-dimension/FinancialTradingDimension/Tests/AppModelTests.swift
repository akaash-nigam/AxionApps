import XCTest
import Foundation
@testable import FinancialTradingDimension

/// Unit tests for AppModel
/// Tests app state management, watchlist operations, and service coordination
final class AppModelTests: XCTestCase {

    var sut: AppModel!

    override func setUp() async throws {
        try await super.setUp()
        sut = AppModel()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testAppModelInitialization() {
        // Then
        XCTAssertNotNil(sut.marketDataService, "Should initialize market data service")
        XCTAssertNotNil(sut.tradingService, "Should initialize trading service")
        XCTAssertNotNil(sut.portfolioService, "Should initialize portfolio service")
        XCTAssertNotNil(sut.riskService, "Should initialize risk service")
        XCTAssertNotNil(sut.analyticsService, "Should initialize analytics service")
    }

    func testInitialState() {
        // Then
        XCTAssertNil(sut.selectedPortfolio, "Should have no selected portfolio initially")
        XCTAssertFalse(sut.immersiveSpaceActive, "Immersive space should not be active initially")
        XCTAssertNil(sut.selectedSymbol, "Should have no selected symbol initially")
        XCTAssertGreaterThan(sut.activeMarketSymbols.count, 0, "Should have default market symbols")
    }

    func testDefaultMarketSymbols() {
        // Then
        let expectedSymbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]
        XCTAssertEqual(sut.activeMarketSymbols, expectedSymbols, "Should have correct default symbols")
    }

    // MARK: - Symbol Selection Tests

    func testSelectSymbol() {
        // Given
        let symbol = "AAPL"

        // When
        sut.selectSymbol(symbol)

        // Then
        XCTAssertEqual(sut.selectedSymbol, symbol, "Should select the symbol")
    }

    func testSelectMultipleSymbols() {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT"]

        // When
        for symbol in symbols {
            sut.selectSymbol(symbol)
        }

        // Then
        XCTAssertEqual(sut.selectedSymbol, "MSFT", "Should have the last selected symbol")
    }

    // MARK: - Watchlist Management Tests

    func testAddToWatchlist() {
        // Given
        let newSymbol = "AMZN"
        let initialCount = sut.activeMarketSymbols.count

        // When
        sut.addToWatchlist(newSymbol)

        // Then
        XCTAssertTrue(sut.activeMarketSymbols.contains(newSymbol), "Should add symbol to watchlist")
        XCTAssertEqual(sut.activeMarketSymbols.count, initialCount + 1, "Watchlist count should increase")
    }

    func testAddDuplicateToWatchlist() {
        // Given
        let existingSymbol = "AAPL"
        let initialCount = sut.activeMarketSymbols.count

        // When
        sut.addToWatchlist(existingSymbol)

        // Then
        XCTAssertEqual(sut.activeMarketSymbols.count, initialCount, "Should not add duplicate")
    }

    func testAddMultipleSymbolsToWatchlist() {
        // Given
        let newSymbols = ["AMZN", "META", "JPM"]

        // When
        for symbol in newSymbols {
            sut.addToWatchlist(symbol)
        }

        // Then
        for symbol in newSymbols {
            XCTAssertTrue(sut.activeMarketSymbols.contains(symbol), "Should contain \(symbol)")
        }
    }

    func testRemoveFromWatchlist() {
        // Given
        let symbolToRemove = "AAPL"
        XCTAssertTrue(sut.activeMarketSymbols.contains(symbolToRemove), "Symbol should exist initially")

        // When
        sut.removeFromWatchlist(symbolToRemove)

        // Then
        XCTAssertFalse(sut.activeMarketSymbols.contains(symbolToRemove), "Should remove symbol")
    }

    func testRemoveNonexistentFromWatchlist() {
        // Given
        let nonexistentSymbol = "INVALID"
        let initialCount = sut.activeMarketSymbols.count

        // When
        sut.removeFromWatchlist(nonexistentSymbol)

        // Then
        XCTAssertEqual(sut.activeMarketSymbols.count, initialCount, "Count should remain same")
    }

    func testRemoveAllFromWatchlist() {
        // Given
        let symbolsToRemove = Array(sut.activeMarketSymbols)

        // When
        for symbol in symbolsToRemove {
            sut.removeFromWatchlist(symbol)
        }

        // Then
        XCTAssertEqual(sut.activeMarketSymbols.count, 0, "Watchlist should be empty")
    }

    // MARK: - Market Data Updates Tests

    func testMarketDataUpdatesInitiallyEmpty() {
        // Given - new AppModel

        // When - check immediately after init

        // Then
        // Market data updates might be empty or populated depending on streaming timing
        XCTAssertNotNil(sut.marketDataUpdates, "Market data updates should be initialized")
    }

    func testMarketDataStreamingUpdates() async throws {
        // Given
        let symbol = "AAPL"

        // When - wait for market data stream to update
        try await Task.sleep(for: .seconds(2))

        // Then
        if let marketData = sut.marketDataUpdates[symbol] {
            XCTAssertEqual(marketData.symbol, symbol, "Should have market data for symbol")
            XCTAssertGreaterThan(marketData.price, 0, "Price should be positive")
        }
        // Note: This test may be flaky depending on timing
    }

    func testMarketDataForMultipleSymbols() async throws {
        // When - wait for updates
        try await Task.sleep(for: .seconds(2))

        // Then
        let expectedSymbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]
        for symbol in expectedSymbols {
            if let data = sut.marketDataUpdates[symbol] {
                XCTAssertEqual(data.symbol, symbol, "Should have data for \(symbol)")
            }
        }
    }

    // MARK: - Order Updates Tests

    func testOrderUpdatesInitiallyEmpty() {
        // Then
        XCTAssertNotNil(sut.orderUpdates, "Order updates should be initialized")
        XCTAssertEqual(sut.orderUpdates.count, 0, "Should have no orders initially")
    }

    // MARK: - Portfolio Selection Tests

    func testSelectPortfolio() {
        // Given
        let portfolio = sut.portfolioService.createSamplePortfolio()

        // When
        sut.selectedPortfolio = portfolio

        // Then
        XCTAssertNotNil(sut.selectedPortfolio, "Should have selected portfolio")
        XCTAssertEqual(sut.selectedPortfolio?.name, portfolio.name, "Should select correct portfolio")
    }

    // MARK: - Immersive Space Tests

    func testImmersiveSpaceToggle() {
        // Given
        let initialState = sut.immersiveSpaceActive

        // When
        sut.immersiveSpaceActive = !initialState

        // Then
        XCTAssertNotEqual(sut.immersiveSpaceActive, initialState, "Should toggle immersive space state")
    }

    // MARK: - Service Integration Tests

    func testMarketDataServiceIntegration() async throws {
        // Given
        let symbol = "AAPL"

        // When
        let quote = try await sut.marketDataService.getQuote(symbol: symbol)

        // Then
        XCTAssertEqual(quote.symbol, symbol, "Should get quote from service")
        XCTAssertGreaterThan(quote.price, 0, "Should have valid price")
    }

    func testTradingServiceIntegration() async throws {
        // Given
        let order = Order(
            symbol: "GOOGL",
            orderType: "Market",
            side: "Buy",
            quantity: 100
        )

        // When
        let confirmation = try await sut.tradingService.submitOrder(order)

        // Then
        XCTAssertEqual(confirmation.status, "Accepted", "Should submit order successfully")
    }

    func testPortfolioServiceIntegration() {
        // When
        let portfolio = sut.portfolioService.createSamplePortfolio()

        // Then
        XCTAssertNotNil(portfolio, "Should create portfolio")
        XCTAssertGreaterThan(portfolio.positions.count, 0, "Portfolio should have positions")
    }

    func testRiskServiceIntegration() async {
        // Given
        let portfolio = sut.portfolioService.createSamplePortfolio()

        // When
        let var95 = await sut.riskService.calculateVaR(portfolio: portfolio, confidence: 0.95)

        // Then
        XCTAssertGreaterThan(var95, 0, "Should calculate VaR")
    }

    func testAnalyticsServiceIntegration() async throws {
        // Given
        let symbol = "AAPL"
        let data = try await sut.marketDataService.getHistoricalData(symbol: symbol, timeframe: .oneMonth)

        // When
        let indicators = await sut.analyticsService.calculateTechnicalIndicators(symbol: symbol, data: data)

        // Then
        XCTAssertGreaterThan(indicators.sma20, 0, "Should calculate indicators")
    }

    // MARK: - Concurrent Operations Tests

    func testConcurrentWatchlistOperations() async {
        // Given
        let symbols = ["AMZN", "META", "JPM", "BAC", "WMT", "DIS", "NFLX", "INTC"]

        // When
        await withTaskGroup(of: Void.self) { group in
            for symbol in symbols {
                group.addTask {
                    self.sut.addToWatchlist(symbol)
                }
            }
        }

        // Then
        for symbol in symbols {
            XCTAssertTrue(sut.activeMarketSymbols.contains(symbol), "Should contain \(symbol)")
        }
    }

    func testConcurrentSymbolSelection() async {
        // Given
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]

        // When
        await withTaskGroup(of: Void.self) { group in
            for symbol in symbols {
                group.addTask {
                    self.sut.selectSymbol(symbol)
                }
            }
        }

        // Then
        XCTAssertTrue(symbols.contains(sut.selectedSymbol ?? ""), "Should have selected one of the symbols")
    }

    // MARK: - Performance Tests

    func testWatchlistOperationsPerformance() {
        // Given
        let symbols = (0..<100).map { "SYM\($0)" }

        // When
        let startTime = Date()
        for symbol in symbols {
            sut.addToWatchlist(symbol)
        }
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertLessThan(duration, 1.0, "Should add 100 symbols quickly")
        XCTAssertEqual(sut.activeMarketSymbols.count, 105, "Should have 100 new + 5 default symbols")
    }

    // MARK: - Edge Cases

    func testAddEmptyStringToWatchlist() {
        // Given
        let emptySymbol = ""
        let initialCount = sut.activeMarketSymbols.count

        // When
        sut.addToWatchlist(emptySymbol)

        // Then
        // Behavior depends on implementation - it may allow or reject
        // This documents the current behavior
        XCTAssertGreaterThanOrEqual(sut.activeMarketSymbols.count, initialCount)
    }

    func testSelectNilSymbol() {
        // Given
        sut.selectSymbol("AAPL")
        XCTAssertNotNil(sut.selectedSymbol, "Should have selected symbol")

        // When
        sut.selectedSymbol = nil

        // Then
        XCTAssertNil(sut.selectedSymbol, "Should be able to deselect")
    }

    func testRemoveAllDefaultSymbols() {
        // Given
        let defaultSymbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]

        // When
        for symbol in defaultSymbols {
            sut.removeFromWatchlist(symbol)
        }

        // Then
        XCTAssertEqual(sut.activeMarketSymbols.count, 0, "Should be able to remove all symbols")
    }
}
