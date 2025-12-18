//
//  AnalyticsViewModel.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import Observation
import SwiftUI

@Observable
final class AnalyticsViewModel {
    var engagementData: [EngagementDataPoint] = []
    var valueBreakdown: [ValueAlignment] = []
    var teamComparisons: [TeamHealthData] = []
    var isLoading: Bool = false
    var error: Error?

    @MainActor
    func loadAnalytics(service: AnalyticsService, range: TimeRange) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load analytics data
            let engagement = try await service.calculateEngagementTrend(days: range.days)
            self.engagementData = engagement

            // Mock data for other sections
            self.valueBreakdown = mockValueBreakdown()
            self.teamComparisons = mockTeamComparisons()

        } catch {
            self.error = error
            // Use mock data
            self.engagementData = mockEngagementData(days: range.days)
            self.valueBreakdown = mockValueBreakdown()
            self.teamComparisons = mockTeamComparisons()
        }
    }

    private func mockEngagementData(days: Int) -> [EngagementDataPoint] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<days).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let score = Double.random(in: 60...90)
            return EngagementDataPoint(date: date, score: score)
        }.reversed()
    }

    private func mockValueBreakdown() -> [ValueAlignment] {
        [
            ValueAlignment(name: "Innovation", score: 82, color: Color(hex: "#8B5CF6")),
            ValueAlignment(name: "Collaboration", score: 95, color: Color(hex: "#3B82F6")),
            ValueAlignment(name: "Trust", score: 78, color: Color(hex: "#F59E0B")),
            ValueAlignment(name: "Transparency", score: 88, color: Color(hex: "#FFFFFF")),
            ValueAlignment(name: "Growth", score: 85, color: Color(hex: "#10B981"))
        ]
    }

    private func mockTeamComparisons() -> [TeamHealthData] {
        [
            TeamHealthData(name: "Engineering", healthScore: 87),
            TeamHealthData(name: "Product", healthScore: 92),
            TeamHealthData(name: "Design", healthScore: 85),
            TeamHealthData(name: "Sales", healthScore: 79),
            TeamHealthData(name: "Marketing", healthScore: 88)
        ]
    }
}
