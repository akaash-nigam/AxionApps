//
//  DashboardViewModel.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import Observation

@Observable
final class DashboardViewModel: @unchecked Sendable {
    // MARK: - Published State

    var organization: Organization?
    var departments: [Department] = []
    var kpis: [KPI] = []
    var recentActivity: [ActivityItem] = []

    var isLoading: Bool = false
    var error: (any Error)?
    var lastRefreshed: Date?

    // MARK: - Dependencies

    private let repository: any BusinessDataRepository
    private let analytics: any AnalyticsService

    // MARK: - Initialization

    init(repository: any BusinessDataRepository, analytics: any AnalyticsService) {
        self.repository = repository
        self.analytics = analytics
    }

    // MARK: - Public Methods

    @MainActor
    func loadDashboard() async {
        isLoading = true
        error = nil

        // Capture dependencies
        let repository = self.repository
        let analytics = self.analytics

        do {
            // Track analytics
            await analytics.trackScreenView("Dashboard")

            // Load organization
            let org = try await repository.fetchOrganization()
            organization = org

            // Load departments
            let depts = try await repository.fetchDepartments()
            departments = depts

            // Load KPIs from all departments
            await loadAllKPIs(from: depts)

            // Generate recent activity
            recentActivity = generateRecentActivity()

            lastRefreshed = Date()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("Error loading dashboard: \(error)")
        }
    }

    @MainActor
    func refresh() async {
        await loadDashboard()
    }

    @MainActor
    func selectDepartment(_ department: Department) async {
        let analytics = self.analytics
        await analytics.trackEvent(.departmentSelected(department.id))
    }

    @MainActor
    func selectKPI(_ kpi: KPI) async {
        let analytics = self.analytics
        await analytics.trackEvent(.kpiTapped(kpi.id))
    }

    // MARK: - Private Methods

    private func loadAllKPIs(from departments: [Department]) async {
        var allKPIs: [KPI] = []
        let repository = self.repository

        for department in departments {
            do {
                let deptKPIs = try await repository.fetchKPIs(for: department.id)
                allKPIs.append(contentsOf: deptKPIs)
            } catch {
                print("Error loading KPIs for \(department.name): \(error)")
            }
        }

        // Sort by performance status (critical first)
        kpis = allKPIs.sorted { kpi1, kpi2 in
            let priority1 = kpi1.performanceStatus.priority
            let priority2 = kpi2.performanceStatus.priority
            return priority1 > priority2
        }
    }

    private func generateRecentActivity() -> [ActivityItem] {
        // Mock recent activity
        [
            ActivityItem(
                id: UUID(),
                icon: "checkmark.circle.fill",
                title: "Q4 Budget Approved",
                color: "#34C759",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            ActivityItem(
                id: UUID(),
                icon: "person.fill",
                title: "New Hire: Engineering",
                color: "#007AFF",
                timestamp: Date().addingTimeInterval(-7200)
            ),
            ActivityItem(
                id: UUID(),
                icon: "dollarsign.circle.fill",
                title: "Deal Closed: $500K",
                color: "#34C759",
                timestamp: Date().addingTimeInterval(-10800)
            )
        ]
    }
}

// MARK: - Supporting Types

struct ActivityItem: Identifiable {
    let id: UUID
    let icon: String
    let title: String
    let color: String
    let timestamp: Date

    var timeAgo: String {
        let seconds = Date().timeIntervalSince(timestamp)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = Int(seconds / 86400)

        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Performance Status Priority

extension KPI.PerformanceStatus {
    var priority: Int {
        switch self {
        case .critical: return 4
        case .belowTarget: return 3
        case .onTrack: return 2
        case .exceeding: return 1
        }
    }
}
