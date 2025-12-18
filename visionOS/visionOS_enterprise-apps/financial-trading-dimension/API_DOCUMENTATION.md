# API Documentation - Financial Trading Dimension

## Overview

This document provides comprehensive API documentation for all services, models, and public interfaces in the Financial Trading Dimension application.

## Table of Contents

1. [Models](#models)
2. [Services](#services)
3. [App State](#app-state)
4. [Data Structures](#data-structures)
5. [Error Handling](#error-handling)
6. [Usage Examples](#usage-examples)

---

## Models

### Portfolio

Represents a financial portfolio containing positions and cash.

```swift
@Model
class Portfolio {
    var id: UUID
    var name: String
    var totalValue: Decimal
    var cashBalance: Decimal
    var positions: [Position]
    var createdDate: Date
    var lastUpdated: Date

    // Computed Properties
    var totalPositionsValue: Decimal { get }
    var totalUnrealizedPnL: Decimal { get }
    var totalPercentageReturn: Double { get }
}
```

**Properties**
- `id`: Unique identifier for the portfolio
- `name`: Display name
- `totalValue`: Total portfolio value (positions + cash)
- `cashBalance`: Available cash
- `positions`: Array of Position objects
- `createdDate`: Portfolio creation timestamp
- `lastUpdated`: Last update timestamp

**Computed Properties**
- `totalPositionsValue`: Sum of all position market values
- `totalUnrealizedPnL`: Total unrealized profit/loss
- `totalPercentageReturn`: Weighted average return percentage

**Example**
```swift
let portfolio = Portfolio(
    name: "My Portfolio",
    cashBalance: 10000.00,
    positions: [/* positions */]
)
print("Total Value: \(portfolio.totalValue)")
print("P&L: \(portfolio.totalUnrealizedPnL)")
```

---

### Position

Represents a single position in a portfolio.

```swift
@Model
class Position {
    var symbol: String
    var quantity: Decimal
    var averageCost: Decimal
    var currentPrice: Decimal
    var positionDate: Date

    // Computed Properties
    var marketValue: Decimal { get }
    var unrealizedPnL: Decimal { get }
    var percentageReturn: Double { get }
}
```

**Properties**
- `symbol`: Stock ticker symbol
- `quantity`: Number of shares
- `averageCost`: Average cost per share
- `currentPrice`: Current market price
- `positionDate`: Position establishment date

**Computed Properties**
- `marketValue`: quantity × currentPrice
- `unrealizedPnL`: (currentPrice - averageCost) × quantity
- `percentageReturn`: ((currentPrice - averageCost) / averageCost) × 100

**Example**
```swift
let position = Position(
    symbol: "AAPL",
    quantity: 100,
    averageCost: 150.00,
    currentPrice: 180.00
)
print("Market Value: \(position.marketValue)")  // 18000.00
print("P&L: \(position.unrealizedPnL)")         // 3000.00
print("Return: \(position.percentageReturn)%")  // 20.0%
```

---

### Order

Represents a trading order.

```swift
@Model
class Order {
    var id: UUID
    var symbol: String
    var orderType: String  // "Market", "Limit", "Stop"
    var side: String       // "Buy", "Sell"
    var quantity: Decimal
    var limitPrice: Decimal?
    var stopPrice: Decimal?
    var status: String     // "Pending", "Filled", "Cancelled", "Rejected"
    var filledQuantity: Decimal
    var averageFillPrice: Decimal?
    var submittedTime: Date
    var filledTime: Date?
}
```

**Order Types**
- `Market`: Execute at current market price
- `Limit`: Execute at specified price or better
- `Stop`: Execute when price reaches stop price

**Order Status**
- `Pending`: Awaiting execution
- `Accepted`: Accepted by broker
- `Filled`: Fully executed
- `Cancelled`: Cancelled by user
- `Rejected`: Rejected by system

**Example**
```swift
// Market Order
let marketOrder = Order(
    symbol: "GOOGL",
    orderType: "Market",
    side: "Buy",
    quantity: 100
)

// Limit Order
let limitOrder = Order(
    symbol: "AAPL",
    orderType: "Limit",
    side: "Buy",
    quantity: 50,
    limitPrice: 175.00
)
```

---

### MarketData

Represents real-time market data for a symbol.

```swift
@Model
class MarketData {
    var symbol: String
    var price: Decimal
    var volume: Int64
    var timestamp: Date
    var exchange: String
    var bidPrice: Decimal
    var askPrice: Decimal
    var bidSize: Int
    var askSize: Int
    var dayHigh: Decimal
    var dayLow: Decimal
    var openPrice: Decimal
    var previousClose: Decimal

    // Computed Properties
    var dayChange: Decimal { get }
    var dayChangePercent: Double { get }
}
```

**Computed Properties**
- `dayChange`: price - previousClose
- `dayChangePercent`: ((price - previousClose) / previousClose) × 100

**Example**
```swift
let quote = marketData["AAPL"]
print("\(quote.symbol): \(quote.price)")
print("Change: \(quote.dayChange) (\(quote.dayChangePercent)%)")
print("Bid/Ask: \(quote.bidPrice)/\(quote.askPrice)")
```

---

## Services

### MarketDataService

Protocol for market data operations.

```swift
protocol MarketDataService {
    func getQuote(symbol: String) async throws -> MarketData
    func getHistoricalData(symbol: String, timeframe: TimeFrame) async throws -> [OHLCV]
    func subscribeToSymbol(_ symbol: String) async throws
    func unsubscribeFromSymbol(_ symbol: String) async
}
```

**Methods**

#### `getQuote(symbol:)`
Retrieves current market data for a symbol.

```swift
let quote = try await marketDataService.getQuote(symbol: "AAPL")
```

**Parameters**
- `symbol`: Stock ticker symbol

**Returns**: `MarketData` object with current quote

**Throws**: Network or data errors

---

#### `getHistoricalData(symbol:timeframe:)`
Retrieves historical OHLCV data.

```swift
let data = try await marketDataService.getHistoricalData(
    symbol: "AAPL",
    timeframe: .oneMonth
)
```

**Parameters**
- `symbol`: Stock ticker symbol
- `timeframe`: TimeFrame enum (.oneDay, .oneWeek, .oneMonth, etc.)

**Returns**: Array of `OHLCV` objects

**Throws**: Network or data errors

---

#### `subscribeToSymbol(_:)`
Subscribes to real-time updates for a symbol.

```swift
try await marketDataService.subscribeToSymbol("AAPL")
```

---

#### `unsubscribeFromSymbol(_:)`
Unsubscribes from real-time updates.

```swift
await marketDataService.unsubscribeFromSymbol("AAPL")
```

---

### TradingService

Protocol for trading operations.

```swift
protocol TradingService {
    func submitOrder(_ order: Order) async throws -> OrderConfirmation
    func cancelOrder(orderId: UUID) async throws
    func getOrderStatus(orderId: UUID) async throws -> String
    func getOpenOrders() async throws -> [Order]
}
```

**Methods**

#### `submitOrder(_:)`
Submits a new order.

```swift
let order = Order(symbol: "AAPL", orderType: "Market", side: "Buy", quantity: 100)
let confirmation = try await tradingService.submitOrder(order)
```

**Parameters**
- `order`: Order object to submit

**Returns**: `OrderConfirmation` with order ID and status

**Throws**: `TradingError` if order is invalid or fails

---

#### `cancelOrder(orderId:)`
Cancels a pending order.

```swift
try await tradingService.cancelOrder(orderId: order.id)
```

**Parameters**
- `orderId`: UUID of order to cancel

**Throws**: `TradingError.orderNotFound` or `TradingError.cannotCancelOrder`

---

#### `getOrderStatus(orderId:)`
Retrieves current status of an order.

```swift
let status = try await tradingService.getOrderStatus(orderId: order.id)
```

**Returns**: Status string ("Pending", "Filled", "Cancelled", etc.)

---

#### `getOpenOrders()`
Retrieves all open orders.

```swift
let openOrders = try await tradingService.getOpenOrders()
```

**Returns**: Array of `Order` objects with status "Pending" or "Accepted"

---

### PortfolioService

Service for portfolio management operations.

```swift
@Observable
class PortfolioService {
    func createSamplePortfolio() -> Portfolio
    func calculatePortfolioMetrics(_ portfolio: Portfolio) async throws -> RiskMetrics
    func updatePositionPrices(_ portfolio: Portfolio, marketData: [String: MarketData])
}
```

**Methods**

#### `createSamplePortfolio()`
Creates a sample portfolio for demonstration.

```swift
let portfolio = portfolioService.createSamplePortfolio()
```

**Returns**: Portfolio with sample positions and cash

---

#### `calculatePortfolioMetrics(_:)`
Calculates risk metrics for a portfolio.

```swift
let metrics = try await portfolioService.calculatePortfolioMetrics(portfolio)
print("VaR 95%: \(metrics.var95)")
print("Sharpe Ratio: \(metrics.sharpeRatio)")
```

**Parameters**
- `portfolio`: Portfolio to analyze

**Returns**: `RiskMetrics` object

---

#### `updatePositionPrices(_:marketData:)`
Updates position prices from market data.

```swift
portfolioService.updatePositionPrices(portfolio, marketData: currentQuotes)
```

**Parameters**
- `portfolio`: Portfolio to update
- `marketData`: Dictionary of symbol → MarketData

---

### RiskManagementService

Service for risk analysis and compliance.

```swift
@Observable
class RiskManagementService {
    func calculateVaR(portfolio: Portfolio, confidence: Double) async -> Decimal
    func calculateExposureByAssetClass() async -> [String: Decimal]
    func calculateCorrelationMatrix(symbols: [String]) async -> [[Double]]
    func checkComplianceLimits(order: Order) async -> ComplianceCheckResult
}
```

**Methods**

#### `calculateVaR(portfolio:confidence:)`
Calculates Value at Risk.

```swift
let var95 = await riskService.calculateVaR(portfolio: portfolio, confidence: 0.95)
let var99 = await riskService.calculateVaR(portfolio: portfolio, confidence: 0.99)
```

**Parameters**
- `portfolio`: Portfolio to analyze
- `confidence`: Confidence level (0.95 for 95%, 0.99 for 99%)

**Returns**: VaR amount in portfolio currency

---

#### `calculateExposureByAssetClass()`
Calculates exposure breakdown by asset class.

```swift
let exposure = await riskService.calculateExposureByAssetClass()
print("Equities: \(exposure["Equities"] ?? 0)")
```

**Returns**: Dictionary of asset class → exposure amount

---

#### `calculateCorrelationMatrix(symbols:)`
Calculates correlation matrix for symbols.

```swift
let matrix = await riskService.calculateCorrelationMatrix(
    symbols: ["AAPL", "GOOGL", "MSFT"]
)
```

**Parameters**
- `symbols`: Array of symbols

**Returns**: 2D array of correlation coefficients (-1.0 to 1.0)

---

#### `checkComplianceLimits(order:)`
Checks if order meets compliance requirements.

```swift
let result = await riskService.checkComplianceLimits(order: order)
if result.approved {
    try await tradingService.submitOrder(order)
}
```

**Parameters**
- `order`: Order to check

**Returns**: `ComplianceCheckResult` with approval status and check details

---

### AnalyticsService

Service for technical analysis and pattern recognition.

```swift
@Observable
class AnalyticsService {
    func calculateTechnicalIndicators(symbol: String, data: [OHLCV]) async -> TechnicalIndicators
    func performCorrelationAnalysis(symbols: [String]) async -> CorrelationResult
    func identifyTradingPatterns(symbol: String, data: [OHLCV]) async -> [TradingPattern]
}
```

**Methods**

#### `calculateTechnicalIndicators(symbol:data:)`
Calculates technical indicators.

```swift
let indicators = await analyticsService.calculateTechnicalIndicators(
    symbol: "AAPL",
    data: historicalData
)
print("SMA 20: \(indicators.sma20)")
print("RSI: \(indicators.rsi)")
print("MACD: \(indicators.macd.macd)")
```

**Parameters**
- `symbol`: Stock symbol
- `data`: Historical OHLCV data

**Returns**: `TechnicalIndicators` with SMA, RSI, MACD values

---

#### `performCorrelationAnalysis(symbols:)`
Analyzes correlations between symbols.

```swift
let result = await analyticsService.performCorrelationAnalysis(
    symbols: ["AAPL", "GOOGL", "MSFT"]
)
```

**Returns**: `CorrelationResult` with correlation pairs

---

#### `identifyTradingPatterns(symbol:data:)`
Identifies chart patterns.

```swift
let patterns = await analyticsService.identifyTradingPatterns(
    symbol: "AAPL",
    data: historicalData
)
for pattern in patterns {
    print("\(pattern.name): \(pattern.type) - \(pattern.confidence)")
}
```

**Returns**: Array of `TradingPattern` objects

---

## App State

### AppModel

Global application state management.

```swift
@Observable
class AppModel {
    // State
    var selectedPortfolio: Portfolio?
    var activeMarketSymbols: [String]
    var immersiveSpaceActive: Bool
    var selectedSymbol: String?
    var marketDataUpdates: [String: MarketData]
    var orderUpdates: [Order]

    // Services
    let marketDataService: MarketDataService
    let tradingService: TradingService
    let portfolioService: PortfolioService
    let riskService: RiskManagementService
    let analyticsService: AnalyticsService

    // Methods
    func selectSymbol(_ symbol: String)
    func addToWatchlist(_ symbol: String)
    func removeFromWatchlist(_ symbol: String)
}
```

**Usage in Views**

```swift
struct MarketOverviewView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        List(appModel.activeMarketSymbols, id: \.self) { symbol in
            if let quote = appModel.marketDataUpdates[symbol] {
                QuoteRow(quote: quote)
            }
        }
    }
}
```

---

## Data Structures

### OHLCV

Historical price data.

```swift
struct OHLCV: Codable {
    var timestamp: Date
    var open: Decimal
    var high: Decimal
    var low: Decimal
    var close: Decimal
    var volume: Int64
}
```

---

### RiskMetrics

Portfolio risk metrics.

```swift
struct RiskMetrics: Codable {
    var portfolioValue: Decimal
    var totalExposure: Decimal
    var var95: Decimal        // 95% VaR
    var var99: Decimal        // 99% VaR
    var sharpeRatio: Double
    var beta: Double
    var maxDrawdown: Double
    var volatility: Double
}
```

---

### TechnicalIndicators

Technical analysis indicators.

```swift
struct TechnicalIndicators {
    var sma20: Decimal        // 20-period SMA
    var sma50: Decimal        // 50-period SMA
    var sma200: Decimal       // 200-period SMA
    var rsi: Double           // 14-period RSI
    var macd: MACDResult      // MACD values
    var signal: Double        // Signal line
    var histogram: Double     // MACD histogram
}
```

---

### TimeFrame

Enum for time period selection.

```swift
enum TimeFrame: String, Codable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    case fiveYears = "5Y"
}
```

---

## Error Handling

### TradingError

```swift
enum TradingError: Error {
    case orderNotFound
    case cannotCancelOrder
    case insufficientFunds
    case invalidQuantity
    case invalidPrice
    case marketClosed
}
```

**Usage**

```swift
do {
    try await tradingService.cancelOrder(orderId: id)
} catch TradingError.orderNotFound {
    print("Order not found")
} catch TradingError.cannotCancelOrder {
    print("Order cannot be cancelled (already filled)")
} catch {
    print("Unknown error: \(error)")
}
```

---

## Usage Examples

### Complete Trading Workflow

```swift
// 1. Get market data
let quote = try await appModel.marketDataService.getQuote(symbol: "AAPL")

// 2. Create order
let order = Order(
    symbol: "AAPL",
    orderType: "Limit",
    side: "Buy",
    quantity: 100,
    limitPrice: quote.price - 1.00  // Limit price $1 below current
)

// 3. Check compliance
let compliance = await appModel.riskService.checkComplianceLimits(order: order)
guard compliance.approved else {
    print("Order failed compliance: \(compliance.checks)")
    return
}

// 4. Submit order
let confirmation = try await appModel.tradingService.submitOrder(order)
print("Order submitted: \(confirmation.orderId)")

// 5. Monitor order status
let status = try await appModel.tradingService.getOrderStatus(orderId: order.id)
print("Order status: \(status)")
```

### Portfolio Analysis

```swift
// Get portfolio
let portfolio = appModel.portfolioService.createSamplePortfolio()

// Calculate metrics
let metrics = try await appModel.portfolioService.calculatePortfolioMetrics(portfolio)
print("Total Value: \(metrics.portfolioValue)")
print("VaR 95%: \(metrics.var95)")
print("Sharpe Ratio: \(metrics.sharpeRatio)")

// Update with real-time prices
appModel.portfolioService.updatePositionPrices(
    portfolio,
    marketData: appModel.marketDataUpdates
)
print("Updated P&L: \(portfolio.totalUnrealizedPnL)")
```

### Technical Analysis

```swift
// Get historical data
let historicalData = try await appModel.marketDataService.getHistoricalData(
    symbol: "AAPL",
    timeframe: .oneMonth
)

// Calculate indicators
let indicators = await appModel.analyticsService.calculateTechnicalIndicators(
    symbol: "AAPL",
    data: historicalData
)
print("RSI: \(indicators.rsi)")
print("MACD: \(indicators.macd.macd)")

// Identify patterns
let patterns = await appModel.analyticsService.identifyTradingPatterns(
    symbol: "AAPL",
    data: historicalData
)
for pattern in patterns {
    print("\(pattern.name): \(pattern.confidence)")
}
```

---

**Last Updated**: 2025-11-17
**Version**: 1.0
