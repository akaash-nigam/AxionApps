//
//  TreasuryService.swift
//  Financial Operations Platform
//
//  Treasury operations and cash management service
//

import Foundation
import SwiftData

@Observable
final class TreasuryService {
    // MARK: - Properties

    private let modelContext: ModelContext
    private let apiClient: APIClient

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Initialization

    init(modelContext: ModelContext, apiClient: APIClient = APIClient.shared) {
        self.modelContext = modelContext
        self.apiClient = apiClient
    }

    // MARK: - Cash Position

    func getCurrentCashPosition(
        currency: Currency? = nil,
        region: String? = nil
    ) async throws -> [CashPosition] {
        isLoading = true
        defer { isLoading = false }

        var predicate: Predicate<CashPosition>?

        if let currency = currency, let region = region {
            predicate = #Predicate<CashPosition> { position in
                position.currency.code == currency.code &&
                position.region == region
            }
        } else if let currency = currency {
            predicate = #Predicate<CashPosition> { position in
                position.currency.code == currency.code
            }
        } else if let region = region {
            predicate = #Predicate<CashPosition> { position in
                position.region == region
            }
        }

        let descriptor = FetchDescriptor<CashPosition>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        let positions = try modelContext.fetch(descriptor)

        // If no local data, generate sample data
        if positions.isEmpty {
            return generateSampleCashPositions()
        }

        return positions
    }

    func getGlobalCashPosition() async throws -> Decimal {
        let positions = try await getCurrentCashPosition()
        return positions.reduce(0) { total, position in
            // Convert to base currency (USD) if needed
            // For now, simple sum
            total + position.endingBalance
        }
    }

    // MARK: - Cash Flow Forecasting

    func forecastCashFlow(
        period: DateInterval,
        scenario: ForecastScenario = .base
    ) async throws -> CashFlowForecast {
        isLoading = true
        defer { isLoading = false }

        // Fetch historical cash flows
        let predicate = #Predicate<CashFlow> { flow in
            flow.date >= period.start &&
            flow.date <= period.end
        }

        let descriptor = FetchDescriptor<CashFlow>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date)]
        )

        let historicalFlows = try modelContext.fetch(descriptor)

        // Generate forecast based on scenario
        let projectedFlows = generateForecast(
            from: historicalFlows,
            period: period,
            scenario: scenario
        )

        let projectedEndingBalance = projectedFlows.reduce(0) { $0 + $1.amount }

        return CashFlowForecast(
            period: period,
            projectedCashFlows: projectedFlows,
            projectedEndingBalance: projectedEndingBalance,
            confidence: scenario.confidence,
            generatedAt: Date()
        )
    }

    func forecastMultipleScenarios(
        period: DateInterval
    ) async throws -> [ForecastScenario: CashFlowForecast] {
        var forecasts: [ForecastScenario: CashFlowForecast] = [:]

        for scenario in ForecastScenario.allCases {
            forecasts[scenario] = try await forecastCashFlow(period: period, scenario: scenario)
        }

        return forecasts
    }

    // MARK: - Liquidity Optimization

    func optimizeLiquidity(
        constraints: LiquidityConstraints
    ) async throws -> LiquidityOptimization {
        isLoading = true
        defer { isLoading = false }

        let currentPosition = try await getGlobalCashPosition()

        // Analyze opportunities
        let opportunities = identifyOptimizationOpportunities(
            currentPosition: currentPosition,
            constraints: constraints
        )

        return LiquidityOptimization(
            currentPosition: currentPosition,
            optimizedPosition: currentPosition + opportunities.totalPotentialSavings,
            opportunities: opportunities.list,
            estimatedImpact: opportunities.totalPotentialSavings,
            generatedAt: Date()
        )
    }

    // MARK: - Investment Recommendations

    func recommendInvestments(
        availableCash: Decimal,
        riskTolerance: RiskTolerance
    ) async throws -> [InvestmentRecommendation] {
        isLoading = true
        defer { isLoading = false }

        // Generate recommendations based on risk tolerance
        var recommendations: [InvestmentRecommendation] = []

        switch riskTolerance {
        case .conservative:
            recommendations.append(InvestmentRecommendation(
                instrumentType: "Money Market Fund",
                amount: availableCash * 0.5,
                expectedReturn: 0.045, // 4.5%
                risk: .low,
                duration: 30 // days
            ))
            recommendations.append(InvestmentRecommendation(
                instrumentType: "Short-term Treasury",
                amount: availableCash * 0.5,
                expectedReturn: 0.048, // 4.8%
                risk: .low,
                duration: 90
            ))

        case .moderate:
            recommendations.append(InvestmentRecommendation(
                instrumentType: "Commercial Paper",
                amount: availableCash * 0.4,
                expectedReturn: 0.052, // 5.2%
                risk: .medium,
                duration: 60
            ))
            recommendations.append(InvestmentRecommendation(
                instrumentType: "Corporate Bonds",
                amount: availableCash * 0.6,
                expectedReturn: 0.058, // 5.8%
                risk: .medium,
                duration: 180
            ))

        case .aggressive:
            recommendations.append(InvestmentRecommendation(
                instrumentType: "High-yield Bonds",
                amount: availableCash * 0.3,
                expectedReturn: 0.075, // 7.5%
                risk: .high,
                duration: 180
            ))
            recommendations.append(InvestmentRecommendation(
                instrumentType: "Equity Investments",
                amount: availableCash * 0.7,
                expectedReturn: 0.095, // 9.5%
                risk: .high,
                duration: 365
            ))
        }

        return recommendations
    }

    // MARK: - Cash Flow Analysis

    func analyzeCashFlowTrends(period: DateInterval) async throws -> CashFlowAnalysis {
        let predicate = #Predicate<CashFlow> { flow in
            flow.date >= period.start &&
            flow.date <= period.end &&
            flow.isActual
        }

        let descriptor = FetchDescriptor<CashFlow>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date)]
        )

        let cashFlows = try modelContext.fetch(descriptor)

        // Group by type
        let operating = cashFlows.filter { $0.flowType == .operating }
        let investing = cashFlows.filter { $0.flowType == .investing }
        let financing = cashFlows.filter { $0.flowType == .financing }

        return CashFlowAnalysis(
            period: period,
            operatingCashFlow: operating.reduce(0) { $0 + $1.amount },
            investingCashFlow: investing.reduce(0) { $0 + $1.amount },
            financingCashFlow: financing.reduce(0) { $0 + $1.amount },
            netCashFlow: cashFlows.reduce(0) { $0 + $1.amount },
            trends: analyzeTrends(cashFlows),
            generatedAt: Date()
        )
    }

    // MARK: - Private Methods

    private func generateForecast(
        from historical: [CashFlow],
        period: DateInterval,
        scenario: ForecastScenario
    ) -> [CashFlowForecast.ProjectedCashFlow] {
        var projections: [CashFlowForecast.ProjectedCashFlow] = []

        // Simple projection: use average of historical data
        guard !historical.isEmpty else { return projections }

        let avgAmount = historical.reduce(0) { $0 + $1.amount } / Decimal(historical.count)

        var currentDate = period.start
        while currentDate <= period.end {
            let adjustedAmount = avgAmount * Decimal(scenario.adjustmentFactor)

            projections.append(CashFlowForecast.ProjectedCashFlow(
                id: UUID(),
                date: currentDate,
                amount: adjustedAmount,
                flowType: .operating,
                confidence: scenario.confidence
            ))

            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return projections
    }

    private func identifyOptimizationOpportunities(
        currentPosition: Decimal,
        constraints: LiquidityConstraints
    ) -> (list: [OptimizationOpportunity], totalPotentialSavings: Decimal) {
        var opportunities: [OptimizationOpportunity] = []
        var totalSavings: Decimal = 0

        // Example opportunities
        if currentPosition > constraints.minimumCashBalance + 50_000_000 {
            let opportunity = OptimizationOpportunity(
                type: .excessCashInvestment,
                description: "Invest excess cash in short-term instruments",
                potentialSavings: 2_500_000,
                implementation: "Transfer to money market fund",
                risk: .low
            )
            opportunities.append(opportunity)
            totalSavings += opportunity.potentialSavings
        }

        opportunities.append(OptimizationOpportunity(
            type: .paymentTiming,
            description: "Optimize payment timing for vendor discounts",
            potentialSavings: 1_200_000,
            implementation: "Take early payment discounts",
            risk: .low
        ))
        totalSavings += 1_200_000

        opportunities.append(OptimizationOpportunity(
            type: .workingCapital,
            description: "Reduce days sales outstanding",
            potentialSavings: 5_000_000,
            implementation: "Implement automated collections",
            risk: .medium
        ))
        totalSavings += 5_000_000

        return (opportunities, totalSavings)
    }

    private func analyzeTrends(_ cashFlows: [CashFlow]) -> [TrendAnalysis] {
        // Simple trend analysis
        return [
            TrendAnalysis(
                category: "Operating Activities",
                direction: .stable,
                strength: 0.75,
                description: "Consistent operating cash generation"
            )
        ]
    }

    private func generateSampleCashPositions() -> [CashPosition] {
        [
            CashPosition(
                date: Date(),
                currency: .USD,
                beginningBalance: 800_000_000,
                receipts: 120_000_000,
                disbursements: 73_000_000,
                forecastedBalance: 850_000_000,
                bankAccount: "JPM-001",
                region: "North America"
            ),
            CashPosition(
                date: Date(),
                currency: .EUR,
                beginningBalance: 135_000_000,
                receipts: 15_000_000,
                disbursements: 5_000_000,
                forecastedBalance: 148_000_000,
                bankAccount: "DB-002",
                region: "Europe"
            ),
            CashPosition(
                date: Date(),
                currency: .GBP,
                beginningBalance: 82_000_000,
                receipts: 8_000_000,
                disbursements: 3_000_000,
                forecastedBalance: 89_000_000,
                bankAccount: "HSBC-003",
                region: "UK"
            )
        ]
    }
}

// MARK: - Supporting Types

enum ForecastScenario: String, CaseIterable {
    case optimistic
    case base
    case pessimistic

    var adjustmentFactor: Double {
        switch self {
        case .optimistic: return 1.15 // 15% higher
        case .base: return 1.0
        case .pessimistic: return 0.85 // 15% lower
        }
    }

    var confidence: Double {
        switch self {
        case .optimistic: return 0.7
        case .base: return 0.85
        case .pessimistic: return 0.75
        }
    }
}

struct LiquidityConstraints: Codable {
    let minimumCashBalance: Decimal
    let maximumCashBalance: Decimal?
    let targetWorkingCapital: Decimal
    let minimumCurrentRatio: Double
}

struct LiquidityOptimization: Codable {
    let currentPosition: Decimal
    let optimizedPosition: Decimal
    let opportunities: [OptimizationOpportunity]
    let estimatedImpact: Decimal
    let generatedAt: Date
}

struct OptimizationOpportunity: Codable, Identifiable {
    let id: UUID = UUID()
    let type: OpportunityType
    let description: String
    let potentialSavings: Decimal
    let implementation: String
    let risk: RiskSeverity

    enum OpportunityType: String, Codable {
        case excessCashInvestment
        case paymentTiming
        case workingCapital
        case fxHedging
        case debtRefinancing
    }
}

enum RiskTolerance: String, Codable {
    case conservative
    case moderate
    case aggressive
}

struct InvestmentRecommendation: Codable, Identifiable {
    let id: UUID = UUID()
    let instrumentType: String
    let amount: Decimal
    let expectedReturn: Double
    let risk: RiskSeverity
    let duration: Int // days
}

struct CashFlowAnalysis: Codable {
    let period: DateInterval
    let operatingCashFlow: Decimal
    let investingCashFlow: Decimal
    let financingCashFlow: Decimal
    let netCashFlow: Decimal
    let trends: [TrendAnalysis]
    let generatedAt: Date
}

struct TrendAnalysis: Codable {
    let category: String
    let direction: TrendDirection
    let strength: Double // 0.0 - 1.0
    let description: String
}
