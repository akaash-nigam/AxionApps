//
//  TreasuryViewModel.swift
//  Financial Operations Platform
//
//  Treasury operations view model
//

import Foundation
import SwiftData

@Observable
final class TreasuryViewModel {
    // MARK: - Published State

    var cashPositions: [CashPosition] = []
    var cashFlowForecast: CashFlowForecast?
    var liquidityMetrics: LiquidityMetrics?
    var optimizationOpportunities: [OptimizationOpportunity] = []
    var investmentRecommendations: [InvestmentRecommendation] = []

    var isLoading: Bool = false
    var errorMessage: String?

    // Filters
    var selectedCurrency: Currency?
    var selectedRegion: String?
    var forecastPeriod: DateInterval = DateInterval(
        start: Date(),
        end: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    )

    // MARK: - Dependencies

    private let treasuryService: TreasuryService

    // MARK: - Initialization

    init(treasuryService: TreasuryService) {
        self.treasuryService = treasuryService
    }

    // MARK: - Public Methods

    @MainActor
    func loadTreasuryData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Load data in parallel
            async let positionsFetch = treasuryService.getCurrentCashPosition(
                currency: selectedCurrency,
                region: selectedRegion
            )
            async let forecastFetch = treasuryService.forecastCashFlow(
                period: forecastPeriod,
                scenario: .base
            )
            async let optimizationFetch = loadOptimization()

            self.cashPositions = try await positionsFetch
            self.cashFlowForecast = try await forecastFetch
            self.optimizationOpportunities = try await optimizationFetch

        } catch {
            errorMessage = error.localizedDescription
            print("Treasury load error: \(error)")
        }
    }

    @MainActor
    func loadForecastScenarios() async throws -> [ForecastScenario: CashFlowForecast] {
        return try await treasuryService.forecastMultipleScenarios(period: forecastPeriod)
    }

    @MainActor
    func loadInvestmentRecommendations(
        availableCash: Decimal,
        riskTolerance: RiskTolerance
    ) async {
        do {
            investmentRecommendations = try await treasuryService.recommendInvestments(
                availableCash: availableCash,
                riskTolerance: riskTolerance
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func refresh() async {
        await loadTreasuryData()
    }

    // MARK: - Computed Properties

    var totalCashPosition: Decimal {
        cashPositions.reduce(0) { $0 + $1.endingBalance }
    }

    var formattedTotalCash: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: totalCashPosition as NSDecimalNumber) ?? "$0"
    }

    var forecastVariance: Decimal? {
        guard let forecast = cashFlowForecast else { return nil }
        return forecast.projectedEndingBalance - totalCashPosition
    }

    var totalOptimizationPotential: Decimal {
        optimizationOpportunities.reduce(0) { $0 + $1.potentialSavings }
    }

    // MARK: - Private Methods

    private func loadOptimization() async throws -> [OptimizationOpportunity] {
        let constraints = LiquidityConstraints(
            minimumCashBalance: 500_000_000,
            maximumCashBalance: 1_000_000_000,
            targetWorkingCapital: 450_000_000,
            minimumCurrentRatio: 1.5
        )

        let optimization = try await treasuryService.optimizeLiquidity(constraints: constraints)
        return optimization.opportunities
    }
}
