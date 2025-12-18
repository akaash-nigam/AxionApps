import XCTest
import Foundation
@testable import FinancialTradingDimension

/// Unit tests for Portfolio and Position models
/// Tests business logic, calculations, and edge cases
final class PortfolioTests: XCTestCase {

    // MARK: - Position Tests

    func testPositionMarketValue() {
        // Given
        let position = Position(
            symbol: "AAPL",
            quantity: 100,
            averageCost: 150.00,
            currentPrice: 180.00
        )

        // When
        let marketValue = position.marketValue

        // Then
        XCTAssertEqual(marketValue, 18000.00, "Market value should be quantity * current price")
    }

    func testPositionUnrealizedPnL() {
        // Given
        let position = Position(
            symbol: "AAPL",
            quantity: 100,
            averageCost: 150.00,
            currentPrice: 180.00
        )

        // When
        let pnl = position.unrealizedPnL

        // Then
        XCTAssertEqual(pnl, 3000.00, "Unrealized P&L should be (current - average) * quantity")
    }

    func testPositionPercentageReturn() {
        // Given
        let position = Position(
            symbol: "AAPL",
            quantity: 100,
            averageCost: 150.00,
            currentPrice: 180.00
        )

        // When
        let percentReturn = position.percentageReturn

        // Then
        XCTAssertEqual(percentReturn, 20.0, accuracy: 0.01, "Percentage return should be 20%")
    }

    func testPositionNegativeReturn() {
        // Given
        let position = Position(
            symbol: "TSLA",
            quantity: 50,
            averageCost: 250.00,
            currentPrice: 200.00
        )

        // When
        let pnl = position.unrealizedPnL
        let percentReturn = position.percentageReturn

        // Then
        XCTAssertEqual(pnl, -2500.00, "Should show negative P&L")
        XCTAssertEqual(percentReturn, -20.0, accuracy: 0.01, "Should show negative return")
    }

    func testPositionZeroAverageCost() {
        // Given
        let position = Position(
            symbol: "TEST",
            quantity: 100,
            averageCost: 0,
            currentPrice: 100.00
        )

        // When
        let percentReturn = position.percentageReturn

        // Then
        XCTAssertEqual(percentReturn, 0, "Should handle zero average cost gracefully")
    }

    // MARK: - Portfolio Tests

    func testEmptyPortfolio() {
        // Given
        let portfolio = Portfolio(
            name: "Test Portfolio",
            cashBalance: 10000.00
        )

        // When
        let totalValue = portfolio.totalPositionsValue
        let totalPnL = portfolio.totalUnrealizedPnL
        let percentReturn = portfolio.totalPercentageReturn

        // Then
        XCTAssertEqual(totalValue, 0, "Empty portfolio should have zero positions value")
        XCTAssertEqual(totalPnL, 0, "Empty portfolio should have zero P&L")
        XCTAssertEqual(percentReturn, 0, "Empty portfolio should have zero return")
    }

    func testPortfolioWithSinglePosition() {
        // Given
        let position = Position(
            symbol: "AAPL",
            quantity: 100,
            averageCost: 150.00,
            currentPrice: 180.00
        )
        let portfolio = Portfolio(
            name: "Test Portfolio",
            cashBalance: 5000.00,
            positions: [position]
        )

        // When
        let totalValue = portfolio.totalPositionsValue
        let totalPnL = portfolio.totalUnrealizedPnL
        let percentReturn = portfolio.totalPercentageReturn

        // Then
        XCTAssertEqual(totalValue, 18000.00, "Should calculate total position value")
        XCTAssertEqual(totalPnL, 3000.00, "Should calculate total P&L")
        XCTAssertEqual(percentReturn, 20.0, accuracy: 0.01, "Should calculate percentage return")
    }

    func testPortfolioWithMultiplePositions() {
        // Given
        let position1 = Position(
            symbol: "AAPL",
            quantity: 100,
            averageCost: 150.00,
            currentPrice: 180.00
        )
        let position2 = Position(
            symbol: "GOOGL",
            quantity: 50,
            averageCost: 140.00,
            currentPrice: 150.00
        )
        let position3 = Position(
            symbol: "MSFT",
            quantity: 75,
            averageCost: 400.00,
            currentPrice: 420.00
        )
        let portfolio = Portfolio(
            name: "Diversified Portfolio",
            cashBalance: 10000.00,
            positions: [position1, position2, position3]
        )

        // When
        let totalValue = portfolio.totalPositionsValue
        let totalPnL = portfolio.totalUnrealizedPnL

        // Then
        // AAPL: 100 * 180 = 18,000
        // GOOGL: 50 * 150 = 7,500
        // MSFT: 75 * 420 = 31,500
        // Total: 57,000
        XCTAssertEqual(totalValue, 57000.00, "Should sum all position values")

        // AAPL: (180-150)*100 = 3,000
        // GOOGL: (150-140)*50 = 500
        // MSFT: (420-400)*75 = 1,500
        // Total: 5,000
        XCTAssertEqual(totalPnL, 5000.00, "Should sum all P&L")
    }

    func testPortfolioWithMixedPositions() {
        // Given - portfolio with winners and losers
        let winner = Position(
            symbol: "NVDA",
            quantity: 100,
            averageCost: 500.00,
            currentPrice: 700.00
        )
        let loser = Position(
            symbol: "TSLA",
            quantity: 50,
            averageCost: 300.00,
            currentPrice: 200.00
        )
        let portfolio = Portfolio(
            name: "Mixed Portfolio",
            cashBalance: 5000.00,
            positions: [winner, loser]
        )

        // When
        let totalPnL = portfolio.totalUnrealizedPnL

        // Then
        // NVDA: (700-500)*100 = 20,000
        // TSLA: (200-300)*50 = -5,000
        // Total: 15,000
        XCTAssertEqual(totalPnL, 15000.00, "Should correctly sum positive and negative P&L")
    }

    func testPortfolioPercentageReturnCalculation() {
        // Given
        let position1 = Position(
            symbol: "AAPL",
            quantity: 100,
            averageCost: 100.00,
            currentPrice: 120.00
        )
        let position2 = Position(
            symbol: "GOOGL",
            quantity: 100,
            averageCost: 100.00,
            currentPrice: 110.00
        )
        let portfolio = Portfolio(
            name: "Test Portfolio",
            positions: [position1, position2]
        )

        // When
        let percentReturn = portfolio.totalPercentageReturn

        // Then
        // Total cost: 100*100 + 100*100 = 20,000
        // Total value: 100*120 + 100*110 = 23,000
        // Return: (23,000/20,000 - 1) * 100 = 15%
        XCTAssertEqual(percentReturn, 15.0, accuracy: 0.01, "Should calculate weighted average return")
    }

    // MARK: - Order Tests

    func testOrderInitialization() {
        // Given/When
        let order = Order(
            symbol: "AAPL",
            orderType: "Market",
            side: "Buy",
            quantity: 100
        )

        // Then
        XCTAssertEqual(order.status, "Pending", "New orders should have Pending status")
        XCTAssertEqual(order.filledQuantity, 0, "New orders should have zero filled quantity")
        XCTAssertNil(order.averageFillPrice, "New orders should have nil fill price")
        XCTAssertNil(order.filledTime, "New orders should have nil filled time")
    }

    func testLimitOrder() {
        // Given/When
        let limitOrder = Order(
            symbol: "GOOGL",
            orderType: "Limit",
            side: "Buy",
            quantity: 50,
            limitPrice: 140.00
        )

        // Then
        XCTAssertEqual(limitOrder.orderType, "Limit")
        XCTAssertEqual(limitOrder.limitPrice, 140.00)
        XCTAssertNil(limitOrder.stopPrice, "Limit order should not have stop price")
    }

    func testStopOrder() {
        // Given/When
        let stopOrder = Order(
            symbol: "TSLA",
            orderType: "Stop",
            side: "Sell",
            quantity: 25,
            stopPrice: 230.00
        )

        // Then
        XCTAssertEqual(stopOrder.orderType, "Stop")
        XCTAssertEqual(stopOrder.stopPrice, 230.00)
        XCTAssertNil(stopOrder.limitPrice, "Stop order should not have limit price")
    }

    // MARK: - MarketData Tests

    func testMarketDataDayChange() {
        // Given
        let marketData = MarketData(
            symbol: "AAPL",
            price: 180.50,
            bidPrice: 180.48,
            askPrice: 180.52,
            dayHigh: 185.00,
            dayLow: 178.00,
            openPrice: 179.00,
            previousClose: 178.50
        )

        // When
        let dayChange = marketData.dayChange
        let dayChangePercent = marketData.dayChangePercent

        // Then
        XCTAssertEqual(dayChange, 2.00, accuracy: 0.01, "Day change should be current - previous close")
        XCTAssertEqual(dayChangePercent, 1.12, accuracy: 0.01, "Day change percent should be ~1.12%")
    }

    func testMarketDataNegativeChange() {
        // Given
        let marketData = MarketData(
            symbol: "TSLA",
            price: 240.00,
            bidPrice: 239.98,
            askPrice: 240.02,
            dayHigh: 250.00,
            dayLow: 238.00,
            openPrice: 248.00,
            previousClose: 250.00
        )

        // When
        let dayChange = marketData.dayChange
        let dayChangePercent = marketData.dayChangePercent

        // Then
        XCTAssertEqual(dayChange, -10.00, "Should show negative day change")
        XCTAssertEqual(dayChangePercent, -4.0, accuracy: 0.01, "Should show negative percentage")
    }

    func testMarketDataZeroPreviousClose() {
        // Given
        let marketData = MarketData(
            symbol: "TEST",
            price: 100.00,
            bidPrice: 99.98,
            askPrice: 100.02,
            dayHigh: 105.00,
            dayLow: 95.00,
            openPrice: 98.00,
            previousClose: 0
        )

        // When
        let dayChangePercent = marketData.dayChangePercent

        // Then
        XCTAssertEqual(dayChangePercent, 0, "Should handle zero previous close gracefully")
    }
}
