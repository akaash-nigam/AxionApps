//
//  Department.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Department

/// Represents a department within an organization
public struct Department: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    var name: String
    var type: DepartmentType
    var parent: Department.ID?
    var subDepartments: [Department]
    var budget: Budget
    var headcount: Int
    var kpis: [KPI]
    var position: SIMD3<Float>?
    var visualRepresentation: DepartmentVisualization

    // MARK: - Computed Properties

    var totalBudget: Decimal {
        budget.allocated + subDepartments.reduce(0) { $0 + $1.totalBudget }
    }

    var totalHeadcount: Int {
        headcount + subDepartments.reduce(0) { $0 + $1.totalHeadcount }
    }

    var averageKPIPerformance: Double {
        guard !kpis.isEmpty else { return 1.0 }
        return kpis.reduce(0.0) { $0 + $1.performance } / Double(kpis.count)
    }

    var overallStatus: KPI.PerformanceStatus {
        let avg = averageKPIPerformance
        switch avg {
        case 1.1...: return .exceeding
        case 0.9..<1.1: return .onTrack
        case 0.7..<0.9: return .belowTarget
        default: return .critical
        }
    }
}

// MARK: - Department Type

extension Department {
    public enum DepartmentType: String, Codable, Sendable {
        case executive
        case finance
        case operations
        case sales
        case marketing
        case engineering
        case hr
        case customerService
        case legal
        case custom

        var modelName: String {
            "dept_\(rawValue)"
        }

        var displayName: String {
            switch self {
            case .executive: return "Executive"
            case .finance: return "Finance"
            case .operations: return "Operations"
            case .sales: return "Sales"
            case .marketing: return "Marketing"
            case .engineering: return "Engineering"
            case .hr: return "Human Resources"
            case .customerService: return "Customer Service"
            case .legal: return "Legal"
            case .custom: return "Custom"
            }
        }

        var defaultColor: String {
            switch self {
            case .executive: return "#FFD700"
            case .finance: return "#00D084"
            case .operations: return "#FF9500"
            case .sales: return "#007AFF"
            case .marketing: return "#AF52DE"
            case .engineering: return "#5AC8FA"
            case .hr: return "#FF2D55"
            case .customerService: return "#5856D6"
            case .legal: return "#8E8E93"
            case .custom: return "#007AFF"
            }
        }

        var iconName: String {
            switch self {
            case .executive: return "crown"
            case .finance: return "dollarsign.circle"
            case .operations: return "gearshape.2"
            case .sales: return "chart.line.uptrend.xyaxis"
            case .marketing: return "megaphone"
            case .engineering: return "wrench.and.screwdriver"
            case .hr: return "person.2"
            case .customerService: return "headphones"
            case .legal: return "scale.3d"
            case .custom: return "building.2"
            }
        }
    }
}

// MARK: - Budget

public struct Budget: Codable, Hashable, Sendable {
    var allocated: Decimal
    var spent: Decimal

    var remaining: Decimal {
        allocated - spent
    }

    var utilizationPercent: Double {
        guard allocated > 0 else { return 0 }
        let utilization = Double(truncating: (spent / allocated) as NSDecimalNumber) * 100
        return min(utilization, 200)  // Cap at 200% for display purposes
    }

    var isOverBudget: Bool {
        spent > allocated
    }

    var status: BudgetStatus {
        let util = utilizationPercent
        switch util {
        case ..<70: return .healthy
        case 70..<90: return .warning
        case 90..<100: return .critical
        default: return .overBudget
        }
    }

    public enum BudgetStatus: String, Codable, Sendable {
        case healthy
        case warning
        case critical
        case overBudget

        var color: String {
            switch self {
            case .healthy: return "#34C759"
            case .warning: return "#FF9500"
            case .critical: return "#FF3B30"
            case .overBudget: return "#FF2D55"
            }
        }
    }
}

// MARK: - Department Visualization

public struct DepartmentVisualization: Codable, Hashable, Sendable {
    var geometryType: GeometryType
    var color: String  // Hex
    var scale: Float
    var animationState: AnimationState?

    public enum GeometryType: String, Codable, Sendable {
        case building
        case sphere
        case cylinder
        case custom
    }

    public enum AnimationState: String, Codable, Sendable {
        case idle
        case pulsing
        case growing
        case shrinking
    }
}

// MARK: - Mock Extension

extension Department {
    static func mock(
        name: String = "Engineering",
        type: DepartmentType = .engineering,
        headcount: Int = 125
    ) -> Department {
        Department(
            id: UUID(),
            name: name,
            type: type,
            parent: nil,
            subDepartments: [],
            budget: Budget(allocated: 5_000_000, spent: 4_200_000),
            headcount: headcount,
            kpis: [.mock()],
            position: nil,
            visualRepresentation: DepartmentVisualization(
                geometryType: .building,
                color: type.defaultColor,
                scale: 1.0,
                animationState: .pulsing
            )
        )
    }
}
