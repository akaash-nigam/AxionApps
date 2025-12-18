import Foundation
import SwiftData

// MARK: - Financial Service Protocol
protocol FinancialServiceProtocol {
    func fetchGeneralLedger(for period: FiscalPeriod) async throws -> [GeneralLedgerEntry]
    func fetchCostCenters() async throws -> [CostCenter]
    func calculateVariance(for costCenter: CostCenter) async throws -> BudgetAnalysis.CostCenterVariance
    func fetchBudgetAnalysis(for period: FiscalPeriod) async throws -> BudgetAnalysis
    func generateProfitAndLoss(for period: FiscalPeriod) async throws -> ProfitAndLoss
    func fetchKPIs() async throws -> FinancialKPIs
}

// MARK: - Financial Service Implementation
actor FinancialService: FinancialServiceProtocol {
    private let modelContext: ModelContext
    private let apiClient: APIClient?
    private let cache: CacheManager

    init(modelContext: ModelContext, apiClient: APIClient? = nil, cache: CacheManager = .shared) {
        self.modelContext = modelContext
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetchGeneralLedger(for period: FiscalPeriod) async throws -> [GeneralLedgerEntry] {
        // Check cache first
        let cacheKey = "gl_\(period.rawValue)"
        if let cached: [GeneralLedgerEntry] = await cache.get(cacheKey) {
            return cached
        }

        // Fetch from API if available, otherwise use local data
        if let api = apiClient {
            let entries = try await api.fetchGeneralLedger(period: period)
            await cache.set(entries, for: cacheKey, ttl: 300) // 5 minutes
            return entries
        }

        // Fetch from local SwiftData
        let descriptor = FetchDescriptor<GeneralLedgerEntry>(
            predicate: #Predicate { $0.fiscalPeriod == period.rawValue }
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchCostCenters() async throws -> [CostCenter] {
        let cacheKey = "cost_centers"
        if let cached: [CostCenter] = await cache.get(cacheKey) {
            return cached
        }

        if let api = apiClient {
            let centers = try await api.fetchCostCenters()
            await cache.set(centers, for: cacheKey, ttl: 600)
            return centers
        }

        let descriptor = FetchDescriptor<CostCenter>()
        return try modelContext.fetch(descriptor)
    }

    func calculateVariance(for costCenter: CostCenter) async throws -> BudgetAnalysis.CostCenterVariance {
        let variance = costCenter.variance
        let variancePercentage = costCenter.variancePercentage

        return BudgetAnalysis.CostCenterVariance(
            code: costCenter.code,
            name: costCenter.name,
            variance: variance,
            variancePercentage: variancePercentage
        )
    }

    func fetchBudgetAnalysis(for period: FiscalPeriod) async throws -> BudgetAnalysis {
        let costCenters = try await fetchCostCenters()

        let totalBudget = costCenters.reduce(Decimal(0)) { $0 + $1.budget }
        let totalSpend = costCenters.reduce(Decimal(0)) { $0 + $1.actualSpend }
        let variance = totalSpend - totalBudget
        let variancePercentage = Double(truncating: ((variance / totalBudget) * 100) as NSNumber)

        let overBudget = costCenters
            .filter { $0.isOverBudget }
            .sorted { $0.variance > $1.variance }
            .prefix(5)
            .map { BudgetAnalysis.CostCenterVariance(
                code: $0.code,
                name: $0.name,
                variance: $0.variance,
                variancePercentage: $0.variancePercentage
            )}

        let underBudget = costCenters
            .filter { !$0.isOverBudget && $0.variance < 0 }
            .sorted { $0.variance < $1.variance }
            .prefix(5)
            .map { BudgetAnalysis.CostCenterVariance(
                code: $0.code,
                name: $0.name,
                variance: $0.variance,
                variancePercentage: $0.variancePercentage
            )}

        return BudgetAnalysis(
            period: period.rawValue,
            totalBudget: totalBudget,
            totalSpend: totalSpend,
            variance: variance,
            variancePercentage: variancePercentage,
            topOverBudget: Array(overBudget),
            topUnderBudget: Array(underBudget)
        )
    }

    func generateProfitAndLoss(for period: FiscalPeriod) async throws -> ProfitAndLoss {
        // This would typically fetch from API or calculate from GL entries
        // For now, return mock data
        return ProfitAndLoss(
            period: period.rawValue,
            revenue: Decimal(42_300_000),
            costOfSales: Decimal(28_400_000),
            grossProfit: Decimal(13_900_000),
            operatingExpenses: Decimal(8_200_000),
            ebitda: Decimal(5_700_000),
            interestExpense: Decimal(500_000),
            taxExpense: Decimal(1_400_000),
            netIncome: Decimal(3_800_000)
        )
    }

    func fetchKPIs() async throws -> FinancialKPIs {
        let cacheKey = "financial_kpis"
        if let cached: FinancialKPIs = await cache.get(cacheKey) {
            return cached
        }

        // Calculate or fetch KPIs
        let kpis = FinancialKPIs(
            revenue: Decimal(4_200_000),
            revenueChange: 12.3,
            profit: Decimal(890_000),
            profitMargin: 21.2,
            cashPosition: Decimal(2_500_000),
            daysPayableOutstanding: 45,
            daysReceivableOutstanding: 38
        )

        await cache.set(kpis, for: cacheKey, ttl: 60)
        return kpis
    }
}

// MARK: - Mock API Client
class APIClient {
    func fetchGeneralLedger(period: FiscalPeriod) async throws -> [GeneralLedgerEntry] {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(100))
        return [GeneralLedgerEntry.mock()]
    }

    func fetchCostCenters() async throws -> [CostCenter] {
        try await Task.sleep(for: .milliseconds(100))
        return [CostCenter.mock()]
    }
}

// MARK: - Cache Manager
actor CacheManager {
    static let shared = CacheManager()

    private var memoryCache: [String: CacheEntry] = [:]

    struct CacheEntry {
        let value: Any
        let expiry: Date
    }

    func get<T>(_ key: String) -> T? {
        guard let entry = memoryCache[key],
              entry.expiry > Date() else {
            memoryCache.removeValue(forKey: key)
            return nil
        }
        return entry.value as? T
    }

    func set<T>(_ value: T, for key: String, ttl: TimeInterval) {
        let expiry = Date().addingTimeInterval(ttl)
        memoryCache[key] = CacheEntry(value: value, expiry: expiry)
    }

    func invalidate(_ key: String) {
        memoryCache.removeValue(forKey: key)
    }

    func clearAll() {
        memoryCache.removeAll()
    }
}
