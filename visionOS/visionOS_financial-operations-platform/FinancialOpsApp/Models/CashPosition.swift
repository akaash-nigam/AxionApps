//
//  CashPosition.swift
//  Financial Operations Platform
//
//  Cash position and cash flow models
//

import Foundation
import SwiftData
import simd

@Model
final class CashPosition: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var date: Date
    var currency: Currency
    var beginningBalance: Decimal
    var receipts: Decimal
    var disbursements: Decimal
    var endingBalance: Decimal
    var forecastedBalance: Decimal?
    var bankAccount: String
    var region: String
    var updatedAt: Date

    // MARK: - Relationships

    var cashFlows: [CashFlow]

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        currency: Currency,
        beginningBalance: Decimal,
        receipts: Decimal = 0,
        disbursements: Decimal = 0,
        forecastedBalance: Decimal? = nil,
        bankAccount: String,
        region: String,
        updatedAt: Date = Date(),
        cashFlows: [CashFlow] = []
    ) {
        self.id = id
        self.date = date
        self.currency = currency
        self.beginningBalance = beginningBalance
        self.receipts = receipts
        self.disbursements = disbursements
        self.endingBalance = beginningBalance + receipts - disbursements
        self.forecastedBalance = forecastedBalance
        self.bankAccount = bankAccount
        self.region = region
        self.updatedAt = updatedAt
        self.cashFlows = cashFlows
    }

    // MARK: - Computed Properties

    var netCashFlow: Decimal {
        receipts - disbursements
    }

    var formattedEndingBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        return formatter.string(from: endingBalance as NSDecimalNumber) ?? "\(endingBalance)"
    }

    var isPositive: Bool {
        endingBalance >= 0
    }
}

// MARK: - Cash Flow

@Model
final class CashFlow: Identifiable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Decimal
    var currency: Currency
    var flowType: CashFlowType
    var category: String
    var description: String
    var isActual: Bool
    var confidence: Double? // For forecasts (0.0 - 1.0)
    var createdAt: Date

    // 3D Visualization Properties
    var spatialPositionX: Float?
    var spatialPositionY: Float?
    var spatialPositionZ: Float?
    var flowVelocityX: Float?
    var flowVelocityY: Float?
    var flowVelocityZ: Float?
    var flowColorRed: Float?
    var flowColorGreen: Float?
    var flowColorBlue: Float?
    var flowColorAlpha: Float?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        date: Date,
        amount: Decimal,
        currency: Currency,
        flowType: CashFlowType,
        category: String,
        description: String,
        isActual: Bool = true,
        confidence: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.currency = currency
        self.flowType = flowType
        self.category = category
        self.description = description
        self.isActual = isActual
        self.confidence = confidence
        self.createdAt = createdAt
    }

    // MARK: - Spatial Properties (Computed)

    var spatialPosition: SIMD3<Float>? {
        get {
            guard let x = spatialPositionX,
                  let y = spatialPositionY,
                  let z = spatialPositionZ else {
                return nil
            }
            return SIMD3<Float>(x, y, z)
        }
        set {
            spatialPositionX = newValue?.x
            spatialPositionY = newValue?.y
            spatialPositionZ = newValue?.z
        }
    }

    var flowVelocity: SIMD3<Float>? {
        get {
            guard let x = flowVelocityX,
                  let y = flowVelocityY,
                  let z = flowVelocityZ else {
                return nil
            }
            return SIMD3<Float>(x, y, z)
        }
        set {
            flowVelocityX = newValue?.x
            flowVelocityY = newValue?.y
            flowVelocityZ = newValue?.z
        }
    }

    // MARK: - Formatted Values

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

// MARK: - Cash Flow Type

enum CashFlowType: String, Codable, CaseIterable {
    case operating
    case investing
    case financing

    var displayName: String {
        rawValue.capitalized
    }

    var defaultColor: (red: Float, green: Float, blue: Float) {
        switch self {
        case .operating:
            return (0.0, 0.5, 1.0) // Blue
        case .investing:
            return (0.0, 0.8, 0.3) // Green
        case .financing:
            return (0.6, 0.3, 0.9) // Purple
        }
    }
}

// MARK: - Cash Flow Forecast

struct CashFlowForecast: Codable {
    let period: DateInterval
    let projectedCashFlows: [ProjectedCashFlow]
    let projectedEndingBalance: Decimal
    let confidence: Double
    let generatedAt: Date

    struct ProjectedCashFlow: Codable, Identifiable {
        let id: UUID
        let date: Date
        let amount: Decimal
        let flowType: CashFlowType
        let confidence: Double
    }
}

// MARK: - Liquidity Metrics

struct LiquidityMetrics: Codable {
    let currentRatio: Double
    let quickRatio: Double
    let cashRatio: Double
    let workingCapital: Decimal
    let daysSalesOutstanding: Int
    let daysPayableOutstanding: Int
    let cashConversionCycle: Int
    let calculatedAt: Date
}
