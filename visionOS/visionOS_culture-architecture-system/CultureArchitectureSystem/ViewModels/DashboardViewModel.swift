//
//  DashboardViewModel.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var healthScore: Double = 0
    var engagementScore: Double = 0
    var valuesAligned: Int = 0
    var recognitionCount: Int = 0
    var recentActivities: [Activity] = []
    var isLoading: Bool = false
    var error: Error?

    @MainActor
    func loadDashboardData(
        cultureService: CultureService,
        analyticsService: AnalyticsService
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load data in parallel
            async let health = cultureService.fetchHealthScore(for: UUID()) // Mock org ID
            async let engagement = analyticsService.calculateEngagementScore()
            async let activities = cultureService.fetchRecentActivities()

            let (healthResult, engagementResult, activitiesResult) = try await (health, engagement, activities)

            self.healthScore = healthResult
            self.engagementScore = engagementResult
            self.recentActivities = activitiesResult
            self.valuesAligned = 3 // Mock data
            self.recognitionCount = 12 // Mock data

        } catch {
            self.error = error
            // Use mock data on error
            self.healthScore = 85.0
            self.engagementScore = 72.0
            self.valuesAligned = 3
            self.recognitionCount = 12
            self.recentActivities = mockActivities()
        }
    }

    private func mockActivities() -> [Activity] {
        [
            Activity(type: .recognition, description: "Innovation recognized in team", timestamp: Date().addingTimeInterval(-3600)),
            Activity(type: .behavior, description: "Collaboration increased 15%", timestamp: Date().addingTimeInterval(-7200)),
            Activity(type: .ritual, description: "Weekly team ritual completed", timestamp: Date().addingTimeInterval(-14400))
        ]
    }
}
