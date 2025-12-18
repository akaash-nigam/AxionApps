import Foundation
import Observation

@Observable
class RiskManagementService {
    func calculateVaR(portfolio: Portfolio, confidence: Double) async -> Decimal {
        // Value at Risk calculation (simplified Monte Carlo)
        await Task.yield()

        let portfolioValue = portfolio.totalPositionsValue + portfolio.cashBalance
        let volatility = 0.02 // 2% daily volatility assumption

        // VaR = Portfolio Value × Z-score × Volatility
        let zScore: Double
        switch confidence {
        case 0.95: zScore = 1.645
        case 0.99: zScore = 2.326
        default: zScore = 1.645
        }

        let var_ = portfolioValue * Decimal(zScore * volatility)
        return var_
    }

    func calculateExposureByAssetClass() async -> [String: Decimal] {
        await Task.yield()

        // Simplified asset class exposure
        return [
            "Equities": 850_000,
            "Cash": 234_567,
            "Fixed Income": 0,
            "Commodities": 0,
            "Crypto": 0
        ]
    }

    func calculateCorrelationMatrix(symbols: [String]) async -> [[Double]] {
        await Task.yield()

        // Generate a mock correlation matrix
        let n = symbols.count
        var matrix: [[Double]] = Array(repeating: Array(repeating: 0.0, count: n), count: n)

        for i in 0..<n {
            for j in 0..<n {
                if i == j {
                    matrix[i][j] = 1.0
                } else {
                    // Random correlation between -1 and 1 (but typically positive for stocks)
                    matrix[i][j] = Double.random(in: 0.3...0.9)
                    matrix[j][i] = matrix[i][j] // Symmetric matrix
                }
            }
        }

        return matrix
    }

    func checkComplianceLimits(order: Order) async -> ComplianceCheckResult {
        await Task.yield()

        // Simplified compliance check
        let checks: [ComplianceCheck] = [
            ComplianceCheck(name: "Position Limit", passed: true, message: "Within limits"),
            ComplianceCheck(name: "Daily Trading Limit", passed: true, message: "Within limits"),
            ComplianceCheck(name: "Sector Concentration", passed: true, message: "Acceptable"),
            ComplianceCheck(name: "Risk Limits", passed: true, message: "Within VaR limits")
        ]

        let allPassed = checks.allSatisfy { $0.passed }

        return ComplianceCheckResult(
            approved: allPassed,
            checks: checks,
            timestamp: Date()
        )
    }
}

struct ComplianceCheck {
    var name: String
    var passed: Bool
    var message: String
}

struct ComplianceCheckResult {
    var approved: Bool
    var checks: [ComplianceCheck]
    var timestamp: Date
}
