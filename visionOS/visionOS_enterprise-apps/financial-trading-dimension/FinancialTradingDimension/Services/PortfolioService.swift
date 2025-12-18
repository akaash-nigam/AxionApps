import Foundation
import SwiftData
import Observation

@Observable
class PortfolioService {
    func createSamplePortfolio() -> Portfolio {
        let positions = [
            Position(symbol: "AAPL", quantity: 500, averageCost: 175.00, currentPrice: 189.45),
            Position(symbol: "GOOGL", quantity: 200, averageCost: 138.50, currentPrice: 142.78),
            Position(symbol: "MSFT", quantity: 300, averageCost: 420.00, currentPrice: 412.34),
            Position(symbol: "NVDA", quantity: 100, averageCost: 720.00, currentPrice: 789.23),
            Position(symbol: "TSLA", quantity: 150, averageCost: 250.00, currentPrice: 245.67)
        ]

        let totalValue = positions.reduce(0) { $0 + $1.marketValue }

        return Portfolio(
            name: "My Portfolio",
            totalValue: totalValue,
            cashBalance: 234_567.00,
            positions: positions
        )
    }

    func calculatePortfolioMetrics(_ portfolio: Portfolio) async throws -> RiskMetrics {
        try await Task.sleep(for: .milliseconds(50))

        let totalValue = portfolio.totalPositionsValue + portfolio.cashBalance
        let totalExposure = portfolio.totalPositionsValue

        // Simple risk calculations (in real app, these would be more sophisticated)
        let var95 = totalValue * Decimal(0.05) // 5% VaR
        let var99 = totalValue * Decimal(0.10) // 10% VaR
        let sharpeRatio = 1.5 // Simplified
        let beta = 1.2
        let maxDrawdown = 0.15
        let volatility = 0.18

        return RiskMetrics(
            portfolioValue: totalValue,
            totalExposure: totalExposure,
            var95: var95,
            var99: var99,
            sharpeRatio: sharpeRatio,
            beta: beta,
            maxDrawdown: maxDrawdown,
            volatility: volatility
        )
    }

    func updatePositionPrices(_ portfolio: Portfolio, marketData: [String: MarketData]) {
        for position in portfolio.positions {
            if let data = marketData[position.symbol] {
                position.currentPrice = data.price
            }
        }
        portfolio.totalValue = portfolio.totalPositionsValue + portfolio.cashBalance
        portfolio.lastUpdated = Date()
    }
}
