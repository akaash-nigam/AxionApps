import SwiftUI
import Observation

@Observable
class AppModel {
    // Global app state
    var selectedPortfolio: Portfolio?
    var activeMarketSymbols: [String] = ["AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"]
    var immersiveSpaceActive: Bool = false
    var selectedSymbol: String?

    // Service dependencies
    let marketDataService: MarketDataService
    let tradingService: TradingService
    let portfolioService: PortfolioService
    let riskService: RiskManagementService
    let analyticsService: AnalyticsService

    // Real-time data streams
    var marketDataUpdates: [String: MarketData] = [:]
    var orderUpdates: [Order] = []

    init() {
        // Initialize services with mock implementations
        self.marketDataService = MockMarketDataService()
        self.tradingService = MockTradingService()
        self.portfolioService = PortfolioService()
        self.riskService = RiskManagementService()
        self.analyticsService = AnalyticsService()

        // Start real-time data streaming
        startMarketDataStream()
    }

    private func startMarketDataStream() {
        Task {
            // Simulate real-time market data updates
            while !Task.isCancelled {
                for symbol in activeMarketSymbols {
                    if let data = try? await marketDataService.getQuote(symbol: symbol) {
                        marketDataUpdates[symbol] = data
                    }
                }
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func selectSymbol(_ symbol: String) {
        selectedSymbol = symbol
    }

    func addToWatchlist(_ symbol: String) {
        if !activeMarketSymbols.contains(symbol) {
            activeMarketSymbols.append(symbol)
        }
    }

    func removeFromWatchlist(_ symbol: String) {
        activeMarketSymbols.removeAll { $0 == symbol }
    }
}
