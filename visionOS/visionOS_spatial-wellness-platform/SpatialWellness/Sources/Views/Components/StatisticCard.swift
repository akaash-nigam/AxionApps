//
// StatisticCard.swift
// Spatial Wellness Platform
//
// Created on November 17, 2025
//

import SwiftUI

/// A card component for displaying statistics with trend indicators
struct StatisticCard: View {
    // MARK: - Properties

    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let trend: Trend?
    let color: Color
    let style: Style

    // MARK: - Types

    enum Trend {
        case up(Double)
        case down(Double)
        case neutral

        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }

        var text: String {
            switch self {
            case .up(let value): return "+\(String(format: "%.1f", value))%"
            case .down(let value): return "-\(String(format: "%.1f", value))%"
            case .neutral: return "No change"
            }
        }
    }

    enum Style {
        case compact
        case standard
        case detailed
    }

    // MARK: - Initialization

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        trend: Trend? = nil,
        color: Color = .blue,
        style: Style = .standard
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.trend = trend
        self.color = color
        self.style = style
    }

    // MARK: - Body

    var body: some View {
        switch style {
        case .compact:
            compactLayout
        case .standard:
            standardLayout
        case .detailed:
            detailedLayout
        }
    }

    // MARK: - Layout Variants

    private var compactLayout: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }

            Spacer()

            if let trend = trend {
                trendIndicator(trend)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var standardLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                if let trend = trend {
                    trendIndicator(trend)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: color.opacity(0.1), radius: 10, y: 4)
    }

    private var detailedLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and trend
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                Spacer()

                if let trend = trend {
                    trendBadge(trend)
                }
            }

            // Value and title
            VStack(alignment: .leading, spacing: 8) {
                Text(value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }

            // Optional progress bar
            if let trend = trend, case .up(let value) = trend {
                ProgressBar(
                    value: value,
                    total: 100,
                    color: color,
                    height: 6,
                    showPercentage: false
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: color.opacity(0.15), radius: 15, y: 5)
        )
    }

    // MARK: - Helper Views

    private func trendIndicator(_ trend: Trend) -> some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.caption.weight(.semibold))

            Text(trend.text)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(trend.color)
    }

    private func trendBadge(_ trend: Trend) -> some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.caption2.weight(.bold))

            Text(trend.text)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(trend.color.opacity(0.15))
        .foregroundColor(trend.color)
        .clipShape(Capsule())
    }
}

// MARK: - Animated Statistic Card

struct AnimatedStatisticCard: View {
    let title: String
    let icon: String
    let color: Color
    @State private var currentValue: Double
    let targetValue: Double
    let unit: String
    let animationDuration: Double

    init(
        title: String,
        icon: String,
        color: Color = .blue,
        value: Double,
        unit: String = "",
        animationDuration: Double = 2.0
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self._currentValue = State(initialValue: 0)
        self.targetValue = value
        self.unit = unit
        self.animationDuration = animationDuration
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.0f%@", currentValue, unit))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText(value: currentValue))
                    .animation(.easeInOut(duration: animationDuration), value: currentValue)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            currentValue = targetValue
        }
    }
}

// MARK: - Preview Provider

#Preview("Compact Style") {
    VStack(spacing: 16) {
        StatisticCard(
            title: "Heart Rate",
            value: "72 BPM",
            icon: "heart.fill",
            trend: .up(5.2),
            color: .red,
            style: .compact
        )

        StatisticCard(
            title: "Steps Today",
            value: "8,432",
            icon: "figure.walk",
            trend: .up(12.5),
            color: .green,
            style: .compact
        )

        StatisticCard(
            title: "Stress Level",
            value: "Low",
            icon: "brain.head.profile",
            trend: .down(8.3),
            color: .blue,
            style: .compact
        )
    }
    .padding()
}

#Preview("Standard Style") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        StatisticCard(
            title: "Heart Rate",
            value: "72",
            subtitle: "BPM • Optimal",
            icon: "heart.fill",
            trend: .up(5.2),
            color: .red,
            style: .standard
        )

        StatisticCard(
            title: "Steps",
            value: "8,432",
            subtitle: "of 10,000 goal",
            icon: "figure.walk",
            trend: .up(12.5),
            color: .green,
            style: .standard
        )

        StatisticCard(
            title: "Sleep",
            value: "7.5h",
            subtitle: "Last night",
            icon: "bed.double.fill",
            trend: .neutral,
            color: .purple,
            style: .standard
        )

        StatisticCard(
            title: "Calories",
            value: "1,842",
            subtitle: "Burned today",
            icon: "flame.fill",
            trend: .up(18.2),
            color: .orange,
            style: .standard
        )
    }
    .padding()
}

#Preview("Detailed Style") {
    ScrollView {
        VStack(spacing: 20) {
            StatisticCard(
                title: "Daily Steps",
                value: "8,432",
                subtitle: "84% of daily goal achieved",
                icon: "figure.walk",
                trend: .up(84),
                color: .green,
                style: .detailed
            )

            StatisticCard(
                title: "Heart Rate",
                value: "72 BPM",
                subtitle: "Resting heart rate • Optimal range",
                icon: "heart.fill",
                trend: .down(5.2),
                color: .red,
                style: .detailed
            )

            StatisticCard(
                title: "Active Minutes",
                value: "45 min",
                subtitle: "Moderate to vigorous activity",
                icon: "flame.fill",
                trend: .up(67),
                color: .orange,
                style: .detailed
            )
        }
        .padding()
    }
}

#Preview("Animated") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        AnimatedStatisticCard(
            title: "Heart Rate",
            icon: "heart.fill",
            color: .red,
            value: 72,
            unit: " BPM"
        )

        AnimatedStatisticCard(
            title: "Steps Today",
            icon: "figure.walk",
            color: .green,
            value: 8432
        )

        AnimatedStatisticCard(
            title: "Calories",
            icon: "flame.fill",
            color: .orange,
            value: 1842,
            unit: " kcal"
        )

        AnimatedStatisticCard(
            title: "Sleep",
            icon: "bed.double.fill",
            color: .purple,
            value: 7.5,
            unit: "h"
        )
    }
    .padding()
}
