import Foundation
import SwiftData

@Model
class Portfolio {
    var id: UUID
    var name: String
    var totalValue: Decimal
    var cashBalance: Decimal
    @Relationship(deleteRule: .cascade) var positions: [Position]
    var createdDate: Date
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        totalValue: Decimal = 0,
        cashBalance: Decimal = 0,
        positions: [Position] = [],
        createdDate: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.totalValue = totalValue
        self.cashBalance = cashBalance
        self.positions = positions
        self.createdDate = createdDate
        self.lastUpdated = lastUpdated
    }

    var totalPositionsValue: Decimal {
        positions.reduce(0) { $0 + $1.marketValue }
    }

    var totalUnrealizedPnL: Decimal {
        positions.reduce(0) { $0 + $1.unrealizedPnL }
    }

    var totalPercentageReturn: Double {
        let totalCost = positions.reduce(0.0) { $0 + ($1.averageCost * $1.quantity) }
        guard totalCost > 0 else { return 0 }
        return Double(truncating: (totalPositionsValue / Decimal(totalCost) - 1) as NSNumber) * 100
    }
}

@Model
class Position {
    var symbol: String
    var quantity: Decimal
    var averageCost: Decimal
    var currentPrice: Decimal
    var positionDate: Date

    init(
        symbol: String,
        quantity: Decimal,
        averageCost: Decimal,
        currentPrice: Decimal,
        positionDate: Date = Date()
    ) {
        self.symbol = symbol
        self.quantity = quantity
        self.averageCost = averageCost
        self.currentPrice = currentPrice
        self.positionDate = positionDate
    }

    var marketValue: Decimal {
        quantity * currentPrice
    }

    var unrealizedPnL: Decimal {
        (currentPrice - averageCost) * quantity
    }

    var percentageReturn: Double {
        guard averageCost > 0 else { return 0 }
        return Double(truncating: ((currentPrice - averageCost) / averageCost * 100) as NSNumber)
    }
}

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

    init(
        id: UUID = UUID(),
        symbol: String,
        orderType: String,
        side: String,
        quantity: Decimal,
        limitPrice: Decimal? = nil,
        stopPrice: Decimal? = nil,
        status: String = "Pending",
        filledQuantity: Decimal = 0,
        averageFillPrice: Decimal? = nil,
        submittedTime: Date = Date(),
        filledTime: Date? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.orderType = orderType
        self.side = side
        self.quantity = quantity
        self.limitPrice = limitPrice
        self.stopPrice = stopPrice
        self.status = status
        self.filledQuantity = filledQuantity
        self.averageFillPrice = averageFillPrice
        self.submittedTime = submittedTime
        self.filledTime = filledTime
    }
}

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

    init(
        symbol: String,
        price: Decimal,
        volume: Int64 = 0,
        timestamp: Date = Date(),
        exchange: String = "NASDAQ",
        bidPrice: Decimal,
        askPrice: Decimal,
        bidSize: Int = 100,
        askSize: Int = 100,
        dayHigh: Decimal,
        dayLow: Decimal,
        openPrice: Decimal,
        previousClose: Decimal
    ) {
        self.symbol = symbol
        self.price = price
        self.volume = volume
        self.timestamp = timestamp
        self.exchange = exchange
        self.bidPrice = bidPrice
        self.askPrice = askPrice
        self.bidSize = bidSize
        self.askSize = askSize
        self.dayHigh = dayHigh
        self.dayLow = dayLow
        self.openPrice = openPrice
        self.previousClose = previousClose
    }

    var dayChange: Decimal {
        price - previousClose
    }

    var dayChangePercent: Double {
        guard previousClose > 0 else { return 0 }
        return Double(truncating: ((price - previousClose) / previousClose * 100) as NSNumber)
    }
}

// Supporting structs for market data
struct MarketCorrelation: Codable {
    var assetPairs: [(String, String)]
    var correlationMatrix: [[Double]]
    var timeframe: TimeFrame
    var calculatedDate: Date
}

struct RiskMetrics: Codable {
    var portfolioValue: Decimal
    var totalExposure: Decimal
    var var95: Decimal  // Value at Risk 95%
    var var99: Decimal  // Value at Risk 99%
    var sharpeRatio: Double
    var beta: Double
    var maxDrawdown: Double
    var volatility: Double
}

enum TimeFrame: String, Codable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    case fiveYears = "5Y"
}

struct OHLCV: Codable {
    var timestamp: Date
    var open: Decimal
    var high: Decimal
    var low: Decimal
    var close: Decimal
    var volume: Int64
}
