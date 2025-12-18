//
//  DashboardComponents.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI

// MARK: - Health Metric Card

struct HealthMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let status: BiometricStatus
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)

                    Spacer()

                    Text(status.emoji)
                        .font(.title3)
                }

                Spacer()

                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(status.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2), in: Capsule())
                    .foregroundStyle(statusColor)
            }
            .padding()
            .frame(height: 180)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
    }

    private var statusColor: Color {
        switch status {
        case .optimal:
            return .green
        case .normal:
            return .blue
        case .caution:
            return .yellow
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }
}

// MARK: - Goal Progress Row

struct GoalProgressRow: View {
    let goal: HealthGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.category.iconName)
                    .foregroundStyle(categoryColor)

                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(goal.progressPercentage))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(categoryColor)
                        .frame(width: geometry.size.width * (goal.progressPercentage / 100))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: goal.progressPercentage)
                }
            }
            .frame(height: 8)
        }
    }

    private var categoryColor: Color {
        switch goal.category {
        case .fitness:
            return .red
        case .nutrition:
            return .green
        case .sleep:
            return .purple
        case .stress:
            return .orange
        case .weight:
            return .blue
        case .mindfulness:
            return .indigo
        case .social:
            return .pink
        case .hydration:
            return .cyan
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: HealthInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundStyle(priorityColor)

                Text(insight.title)
                    .font(.headline)

                Spacer()

                Text(priorityBadge)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2), in: Capsule())
                    .foregroundStyle(priorityColor)
            }

            Text(insight.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if insight.actionable, let actionTitle = insight.actionTitle {
                Button(actionTitle) {
                    // Handle action
                }
                .font(.subheadline)
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var categoryIcon: String {
        switch insight.category {
        case .sleep:
            return "bed.double.fill"
        case .activity:
            return "figure.run"
        case .nutrition:
            return "fork.knife"
        case .stress:
            return "brain.head.profile"
        case .heart:
            return "heart.fill"
        case .general:
            return "lightbulb.fill"
        }
    }

    private var priorityColor: Color {
        switch insight.priority {
        case .low:
            return .blue
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .critical:
            return .red
        }
    }

    private var priorityBadge: String {
        switch insight.priority {
        case .low:
            return "Info"
        case .medium:
            return "Note"
        case .high:
            return "Important"
        case .critical:
            return "Urgent"
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
    }
}

// MARK: - Previews

#Preview("Health Metric Card") {
    HealthMetricCard(
        icon: "heart.fill",
        title: "Heart Rate",
        value: "72",
        unit: "BPM",
        status: .optimal,
        color: .red
    ) {
        print("Card tapped")
    }
    .frame(width: 200, height: 180)
}

#Preview("Goal Progress Row") {
    let sampleGoal = HealthGoal(
        userId: UUID(),
        title: "10,000 Steps",
        goalDescription: "Walk 10,000 steps today",
        category: .fitness,
        targetValue: 10000,
        currentValue: 7500,
        unit: "steps",
        targetDate: Date()
    )

    GoalProgressRow(goal: sampleGoal)
        .padding()
}

#Preview("Insight Card") {
    let sampleInsight = HealthInsight(
        title: "Sleep Improved",
        message: "Your sleep quality improved 15% this week. Consider maintaining your 10 PM bedtime.",
        category: .sleep,
        priority: .medium,
        timestamp: Date(),
        actionable: true,
        actionTitle: "View Sleep Trends"
    )

    InsightCard(insight: sampleInsight)
        .padding()
}

#Preview("Quick Action Button") {
    QuickActionButton(
        icon: "figure.mind.and.body",
        title: "Meditate",
        color: .purple
    ) {
        print("Meditate tapped")
    }
    .frame(width: 150)
}
