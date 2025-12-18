import Foundation
import Observation

@Observable
final class DashboardViewModel {
    // MARK: - Dependencies

    private let sustainabilityService: SustainabilityService
    private let carbonTrackingService: CarbonTrackingService

    // MARK: - State

    var footprint: CarbonFootprint?
    var facilities: [Facility] = []
    var goals: [SustainabilityGoal] = []

    var isLoading = false
    var error: Error?

    // MARK: - Computed Properties

    var totalEmissions: Double {
        footprint?.totalEmissions ?? 0
    }

    var emissionsChange: Double {
        // Calculate change from previous period
        // Placeholder: -5.2% reduction
        -5.2
    }

    var goalsOnTrack: Int {
        goals.filter { $0.status == .onTrack || $0.status == .achieved }.count
    }

    var chartData: [EmissionChartData] {
        guard let footprint = footprint else { return [] }

        return footprint.emissionSources.map { source in
            EmissionChartData(
                category: source.category.rawValue,
                emissions: source.emissions,
                percentage: source.percentage
            )
        }.sorted { $0.emissions > $1.emissions }
    }

    var alerts: [DashboardAlert] {
        var alerts: [DashboardAlert] = []

        // Check facilities over target
        let overTargetFacilities = facilities.filter { $0.emissions > Constants.Thresholds.highEmissions }
        if !overTargetFacilities.isEmpty {
            alerts.append(
                DashboardAlert(
                    icon: "exclamationmark.triangle.fill",
                    text: "\(overTargetFacilities.count) facilities over target",
                    severity: .warning
                )
            )
        }

        // Check goals at risk
        let atRiskGoals = goals.filter { $0.status == .atRisk || $0.status == .behind }
        if !atRiskGoals.isEmpty {
            alerts.append(
                DashboardAlert(
                    icon: "flag.fill",
                    text: "\(atRiskGoals.count) goals at risk",
                    severity: .warning
                )
            )
        }

        return alerts
    }

    // MARK: - Initialization

    init(
        sustainabilityService: SustainabilityService,
        carbonTrackingService: CarbonTrackingService
    ) {
        self.sustainabilityService = sustainabilityService
        self.carbonTrackingService = carbonTrackingService
    }

    // MARK: - Actions

    @MainActor
    func loadData() async {
        isLoading = true
        error = nil

        do {
            async let footprintTask = sustainabilityService.fetchCurrentFootprint()
            async let facilitiesTask = sustainabilityService.fetchFacilities()
            async let goalsTask = sustainabilityService.fetchGoals()

            (footprint, facilities, goals) = try await (footprintTask, facilitiesTask, goalsTask)

        } catch {
            self.error = error
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }

    func calculateReductionPercentage(from baseline: Double) -> Double {
        guard let current = footprint?.totalEmissions, baseline > 0 else { return 0 }
        return ((baseline - current) / baseline) * 100
    }

    func emissionsByCategory() -> [EmissionCategory: Double] {
        guard let footprint = footprint else { return [:] }

        var result: [EmissionCategory: Double] = [:]
        for source in footprint.emissionSources {
            result[source.category, default: 0] += source.emissions
        }
        return result
    }
}

// MARK: - Supporting Types

struct EmissionChartData: Identifiable {
    let id = UUID()
    let category: String
    let emissions: Double
    let percentage: Double
}

struct DashboardAlert: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let severity: AlertSeverity
}

enum AlertSeverity {
    case info
    case warning
    case critical

    var color: String {
        switch self {
        case .info: return "#2D9CDB"
        case .warning: return "#F2C94C"
        case .critical: return "#E34034"
        }
    }
}
