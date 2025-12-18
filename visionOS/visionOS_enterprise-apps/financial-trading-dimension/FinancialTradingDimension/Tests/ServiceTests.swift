import XCTest
import Foundation
@testable import FinancialTradingDimension

/// Unit tests for Trading, Portfolio, and Risk Management Services
final class ServiceTests: XCTestCase {

    // MARK: - Trading Service Tests

    func testSubmitMarketOrder() async throws {
        // Given
        let sut = MockTradingService()
        let order = Order(
            symbol: "AAPL",
            orderType: "Market",
            side: "Buy",
            quantity: 100
        )

        // When
        let confirmation = try await sut.submitOrder(order)

        // Then
        XCTAssertEqual(confirmation.status, "Accepted", "Order should be accepted")
        XCTAssertEqual(confirmation.orderId, order.id, "Confirmation should have correct order ID")
    }

    func testSubmitLimitOrder() async throws {
        // Given
        let sut = MockTradingService()
        let order = Order(
            symbol: "GOOGL",
            orderType: "Limit",
            side: "Buy",
            quantity: 50,
            limitPrice: 140.00
        )

        // When
        let confirmation = try await sut.submitOrder(order)

        // Then
        XCTAssertEqual(confirmation.status, "Accepted")
        XCTAssertNotNil(confirmation.timestamp)
    }

    func testGetOrderStatus() async throws {
        // Given
        let sut = MockTradingService()
        let order = Order(
            symbol: "MSFT",
            orderType: "Market",
            side: "Sell",
            quantity: 75
        )
        _ = try await sut.submitOrder(order)

        // When
        let status = try await sut.getOrderStatus(orderId: order.id)

        // Then
        XCTAssertEqual(status, "Pending", "Newly submitted order should be pending")
    }

    func testGetOrderStatusForNonexistentOrder() async throws {
        // Given
        let sut = MockTradingService()
        let randomOrderId = UUID()

        // When/Then
        do {
            _ = try await sut.getOrderStatus(orderId: randomOrderId)
            XCTFail("Should throw orderNotFound error")
        } catch {
            XCTAssertTrue(error is TradingError, "Should throw TradingError")
        }
    }

    func testCancelPendingOrder() async throws {
        // Given
        let sut = MockTradingService()
        let order = Order(
            symbol: "TSLA",
            orderType: "Limit",
            side: "Buy",
            quantity: 25,
            limitPrice: 240.00
        )
        _ = try await sut.submitOrder(order)

        // When
        try await sut.cancelOrder(orderId: order.id)

        // Then
        let status = try await sut.getOrderStatus(orderId: order.id)
        XCTAssertEqual(status, "Cancelled", "Order should be cancelled")
    }

    func testCannotCancelFilledOrder() async throws {
        // Given
        let sut = MockTradingService()
        let order = Order(
            symbol: "NVDA",
            orderType: "Market",
            side: "Buy",
            quantity: 10
        )
        _ = try await sut.submitOrder(order)

        // Wait for order to fill (mock service fills after 500ms)
        try await Task.sleep(for: .milliseconds(600))

        // When/Then
        do {
            try await sut.cancelOrder(orderId: order.id)
            XCTFail("Should not be able to cancel filled order")
        } catch TradingError.cannotCancelOrder {
            // Expected error
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testGetOpenOrders() async throws {
        // Given
        let sut = MockTradingService()
        let order1 = Order(symbol: "AAPL", orderType: "Limit", side: "Buy", quantity: 100, limitPrice: 180.00)
        let order2 = Order(symbol: "GOOGL", orderType: "Limit", side: "Buy", quantity: 50, limitPrice: 140.00)
        let order3 = Order(symbol: "MSFT", orderType: "Market", side: "Sell", quantity: 75)

        _ = try await sut.submitOrder(order1)
        _ = try await sut.submitOrder(order2)
        _ = try await sut.submitOrder(order3)

        // When
        let openOrders = try await sut.getOpenOrders()

        // Then
        XCTAssertGreaterThanOrEqual(openOrders.count, 3, "Should have at least 3 open orders")
    }

    func testMultipleConcurrentOrderSubmissions() async throws {
        // Given
        let sut = MockTradingService()
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]

        // When
        let confirmations = try await withThrowingTaskGroup(of: OrderConfirmation.self) { group in
            for symbol in symbols {
                group.addTask {
                    let order = Order(symbol: symbol, orderType: "Market", side: "Buy", quantity: 100)
                    return try await sut.submitOrder(order)
                }
            }

            var results: [OrderConfirmation] = []
            for try await confirmation in group {
                results.append(confirmation)
            }
            return results
        }

        // Then
        XCTAssertEqual(confirmations.count, 5, "All orders should be submitted successfully")
        XCTAssertTrue(confirmations.allSatisfy { $0.status == "Accepted" }, "All orders should be accepted")
    }

    // MARK: - Portfolio Service Tests

    func testCreateSamplePortfolio() {
        // Given
        let sut = PortfolioService()

        // When
        let portfolio = sut.createSamplePortfolio()

        // Then
        XCTAssertEqual(portfolio.name, "My Portfolio")
        XCTAssertEqual(portfolio.positions.count, 5, "Should have 5 positions")
        XCTAssertGreaterThan(portfolio.cashBalance, 0, "Should have cash balance")
        XCTAssertGreaterThan(portfolio.totalValue, 0, "Should have positive total value")
    }

    func testCalculatePortfolioMetrics() async throws {
        // Given
        let sut = PortfolioService()
        let portfolio = sut.createSamplePortfolio()

        // When
        let metrics = try await sut.calculatePortfolioMetrics(portfolio)

        // Then
        XCTAssertGreaterThan(metrics.portfolioValue, 0, "Portfolio value should be positive")
        XCTAssertGreaterThan(metrics.totalExposure, 0, "Exposure should be positive")
        XCTAssertGreaterThan(metrics.var95, 0, "VaR 95% should be positive")
        XCTAssertGreaterThan(metrics.var99, metrics.var95, "VaR 99% should be greater than VaR 95%")
        XCTAssertGreaterThan(metrics.sharpeRatio, 0, "Sharpe ratio should be positive")
    }

    func testUpdatePositionPrices() {
        // Given
        let sut = PortfolioService()
        let portfolio = sut.createSamplePortfolio()
        let initialTotalValue = portfolio.totalValue

        let newMarketData: [String: MarketData] = [
            "AAPL": MarketData(
                symbol: "AAPL",
                price: 200.00,
                bidPrice: 199.98,
                askPrice: 200.02,
                dayHigh: 205.00,
                dayLow: 195.00,
                openPrice: 198.00,
                previousClose: 197.00
            )
        ]

        // When
        sut.updatePositionPrices(portfolio, marketData: newMarketData)

        // Then
        let aaplPosition = portfolio.positions.first { $0.symbol == "AAPL" }
        XCTAssertNotNil(aaplPosition)
        XCTAssertEqual(aaplPosition?.currentPrice, 200.00, "AAPL price should be updated")
        XCTAssertNotEqual(portfolio.totalValue, initialTotalValue, "Total value should change")
    }

    func testUpdatePositionPricesWithMultipleAssets() {
        // Given
        let sut = PortfolioService()
        let portfolio = sut.createSamplePortfolio()

        let marketData: [String: MarketData] = [
            "AAPL": MarketData(symbol: "AAPL", price: 200.00, bidPrice: 199.98, askPrice: 200.02,
                             dayHigh: 205.00, dayLow: 195.00, openPrice: 198.00, previousClose: 197.00),
            "GOOGL": MarketData(symbol: "GOOGL", price: 150.00, bidPrice: 149.98, askPrice: 150.02,
                              dayHigh: 152.00, dayLow: 148.00, openPrice: 149.00, previousClose: 148.50),
            "MSFT": MarketData(symbol: "MSFT", price: 425.00, bidPrice: 424.98, askPrice: 425.02,
                             dayHigh: 430.00, dayLow: 420.00, openPrice: 422.00, previousClose: 421.00)
        ]

        // When
        sut.updatePositionPrices(portfolio, marketData: marketData)

        // Then
        XCTAssertEqual(portfolio.positions.first { $0.symbol == "AAPL" }?.currentPrice, 200.00)
        XCTAssertEqual(portfolio.positions.first { $0.symbol == "GOOGL" }?.currentPrice, 150.00)
        XCTAssertEqual(portfolio.positions.first { $0.symbol == "MSFT" }?.currentPrice, 425.00)
    }

    // MARK: - Risk Management Service Tests

    func testCalculateVaR95() async {
        // Given
        let sut = RiskManagementService()
        let portfolio = PortfolioService().createSamplePortfolio()

        // When
        let var95 = await sut.calculateVaR(portfolio: portfolio, confidence: 0.95)

        // Then
        XCTAssertGreaterThan(var95, 0, "VaR should be positive")
        let portfolioValue = portfolio.totalPositionsValue + portfolio.cashBalance
        XCTAssertLessThan(var95, portfolioValue, "VaR should be less than portfolio value")
    }

    func testCalculateVaR99() async {
        // Given
        let sut = RiskManagementService()
        let portfolio = PortfolioService().createSamplePortfolio()

        // When
        let var99 = await sut.calculateVaR(portfolio: portfolio, confidence: 0.99)
        let var95 = await sut.calculateVaR(portfolio: portfolio, confidence: 0.95)

        // Then
        XCTAssertGreaterThan(var99, var95, "VaR 99% should be greater than VaR 95%")
    }

    func testCalculateExposureByAssetClass() async {
        // Given
        let sut = RiskManagementService()

        // When
        let exposure = await sut.calculateExposureByAssetClass()

        // Then
        XCTAssertGreaterThan(exposure.count, 0, "Should have exposure data")
        XCTAssertNotNil(exposure["Equities"], "Should have equities exposure")
        XCTAssertNotNil(exposure["Cash"], "Should have cash exposure")
    }

    func testCalculateCorrelationMatrix() async {
        // Given
        let sut = RiskManagementService()
        let symbols = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]

        // When
        let matrix = await sut.calculateCorrelationMatrix(symbols: symbols)

        // Then
        XCTAssertEqual(matrix.count, symbols.count, "Matrix should have correct dimensions")
        XCTAssertEqual(matrix[0].count, symbols.count, "Matrix should be square")

        // Check diagonal is all 1.0
        for i in 0..<symbols.count {
            XCTAssertEqual(matrix[i][i], 1.0, "Diagonal should be 1.0")
        }

        // Check symmetry
        for i in 0..<symbols.count {
            for j in 0..<symbols.count {
                XCTAssertEqual(matrix[i][j], matrix[j][i], accuracy: 0.001, "Matrix should be symmetric")
            }
        }

        // Check correlation values are in valid range
        for i in 0..<symbols.count {
            for j in 0..<symbols.count {
                XCTAssertGreaterThanOrEqual(matrix[i][j], -1.0, "Correlation should be >= -1")
                XCTAssertLessThanOrEqual(matrix[i][j], 1.0, "Correlation should be <= 1")
            }
        }
    }

    func testCheckComplianceLimits() async {
        // Given
        let sut = RiskManagementService()
        let order = Order(
            symbol: "AAPL",
            orderType: "Market",
            side: "Buy",
            quantity: 100
        )

        // When
        let result = await sut.checkComplianceLimits(order: order)

        // Then
        XCTAssertTrue(result.approved, "Order should be approved in mock service")
        XCTAssertGreaterThan(result.checks.count, 0, "Should have compliance checks")
        XCTAssertTrue(result.checks.allSatisfy { $0.passed }, "All checks should pass")
    }

    func testComplianceCheckResult() async {
        // Given
        let sut = RiskManagementService()
        let order = Order(
            symbol: "GOOGL",
            orderType: "Limit",
            side: "Buy",
            quantity: 500,
            limitPrice: 150.00
        )

        // When
        let result = await sut.checkComplianceLimits(order: order)

        // Then
        XCTAssertNotNil(result.timestamp, "Should have timestamp")
        XCTAssertTrue(result.checks.contains { $0.name == "Position Limit" })
        XCTAssertTrue(result.checks.contains { $0.name == "Risk Limits" })
    }

    // MARK: - Integration Tests

    func testPortfolioMetricsWithRiskCalculation() async throws {
        // Given
        let portfolioService = PortfolioService()
        let riskService = RiskManagementService()
        let portfolio = portfolioService.createSamplePortfolio()

        // When
        let metrics = try await portfolioService.calculatePortfolioMetrics(portfolio)
        let var95 = await riskService.calculateVaR(portfolio: portfolio, confidence: 0.95)

        // Then
        XCTAssertGreaterThan(metrics.var95, 0, "Metrics should include VaR 95%")
        XCTAssertGreaterThan(var95, 0, "Risk service should calculate VaR 95%")
    }

    func testEndToEndTradingWorkflow() async throws {
        // Given
        let tradingService = MockTradingService()
        let riskService = RiskManagementService()

        let order = Order(
            symbol: "AAPL",
            orderType: "Market",
            side: "Buy",
            quantity: 100
        )

        // When
        // 1. Check compliance
        let complianceResult = await riskService.checkComplianceLimits(order: order)
        XCTAssertTrue(complianceResult.approved, "Order should pass compliance")

        // 2. Submit order
        let confirmation = try await tradingService.submitOrder(order)
        XCTAssertEqual(confirmation.status, "Accepted", "Order should be accepted")

        // 3. Check order status
        let status = try await tradingService.getOrderStatus(orderId: order.id)
        XCTAssertEqual(status, "Pending", "Order should be pending")

        // 4. Get open orders
        let openOrders = try await tradingService.getOpenOrders()
        XCTAssertTrue(openOrders.contains { $0.id == order.id }, "Order should be in open orders")
    }
}
