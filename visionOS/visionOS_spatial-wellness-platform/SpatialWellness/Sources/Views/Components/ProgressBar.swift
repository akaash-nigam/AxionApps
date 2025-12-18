//
// ProgressBar.swift
// Spatial Wellness Platform
//
// Created on November 17, 2025
//

import SwiftUI

/// A customizable progress bar component with animations and accessibility support
struct ProgressBar: View {
    // MARK: - Properties

    let value: Double // 0.0 to 1.0
    let total: Double // For display purposes
    let color: Color
    let backgroundColor: Color
    let height: CGFloat
    let showPercentage: Bool
    let animated: Bool
    let cornerRadius: CGFloat

    // MARK: - Initialization

    init(
        value: Double,
        total: Double = 100,
        color: Color = .blue,
        backgroundColor: Color = Color.gray.opacity(0.2),
        height: CGFloat = 8,
        showPercentage: Bool = false,
        animated: Bool = true,
        cornerRadius: CGFloat = 4
    ) {
        self.value = min(max(value, 0), total)
        self.total = total
        self.color = color
        self.backgroundColor = backgroundColor
        self.height = height
        self.showPercentage = showPercentage
        self.animated = animated
        self.cornerRadius = cornerRadius
    }

    // MARK: - Computed Properties

    private var progress: Double {
        guard total > 0 else { return 0 }
        return value / total
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    private var accessibilityLabel: String {
        "Progress: \(percentage) percent"
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showPercentage {
                HStack {
                    Text("\(percentage)%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(value)) / \(Int(total))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .frame(width: geometry.size.width, height: height)

                    // Progress
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * progress,
                            height: height
                        )
                        .animation(
                            animated ? .spring(response: 0.6, dampingFraction: 0.8) : .none,
                            value: progress
                        )
                }
            }
            .frame(height: height)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(Int(value)) of \(Int(total))")
    }
}

// MARK: - Circular Progress Variant

struct CircularProgressBar: View {
    let value: Double
    let total: Double
    let lineWidth: CGFloat
    let color: Color
    let backgroundColor: Color

    init(
        value: Double,
        total: Double = 100,
        lineWidth: CGFloat = 12,
        color: Color = .blue,
        backgroundColor: Color = Color.gray.opacity(0.2)
    ) {
        self.value = min(max(value, 0), total)
        self.total = total
        self.lineWidth = lineWidth
        self.color = color
        self.backgroundColor = backgroundColor
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return value / total
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

            // Percentage text
            VStack(spacing: 4) {
                Text("\(percentage)%")
                    .font(.title.bold())
                    .foregroundColor(color)

                Text("\(Int(value))/\(Int(total))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Circular progress: \(percentage) percent")
        .accessibilityValue("\(Int(value)) of \(Int(total))")
    }
}

// MARK: - Segmented Progress Bar

struct SegmentedProgressBar: View {
    let segments: [ProgressSegment]
    let height: CGFloat
    let spacing: CGFloat

    struct ProgressSegment: Identifiable {
        let id = UUID()
        let value: Double
        let color: Color
        let label: String?

        init(value: Double, color: Color, label: String? = nil) {
            self.value = value
            self.color = color
            self.label = label
        }
    }

    init(segments: [ProgressSegment], height: CGFloat = 8, spacing: CGFloat = 2) {
        self.segments = segments
        self.height = height
        self.spacing = spacing
    }

    private var totalValue: Double {
        segments.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(segments) { segment in
                    let width = (segment.value / totalValue) * geometry.size.width

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(segment.color)
                        .frame(width: max(width - spacing, 0), height: height)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview Provider

#Preview("Linear Progress Bar") {
    VStack(spacing: 30) {
        ProgressBar(
            value: 75,
            total: 100,
            color: .blue,
            showPercentage: true
        )

        ProgressBar(
            value: 6500,
            total: 10000,
            color: .green,
            showPercentage: true
        )

        ProgressBar(
            value: 42,
            total: 100,
            color: .orange,
            height: 12,
            showPercentage: true
        )
    }
    .padding()
}

#Preview("Circular Progress") {
    HStack(spacing: 40) {
        CircularProgressBar(
            value: 75,
            total: 100,
            color: .blue
        )
        .frame(width: 100, height: 100)

        CircularProgressBar(
            value: 6500,
            total: 10000,
            lineWidth: 16,
            color: .green
        )
        .frame(width: 120, height: 120)

        CircularProgressBar(
            value: 42,
            total: 100,
            lineWidth: 8,
            color: .orange
        )
        .frame(width: 80, height: 80)
    }
    .padding()
}

#Preview("Segmented Progress") {
    VStack(spacing: 20) {
        SegmentedProgressBar(
            segments: [
                .init(value: 30, color: .blue, label: "Steps"),
                .init(value: 50, color: .green, label: "Exercise"),
                .init(value: 20, color: .orange, label: "Standing")
            ],
            height: 12
        )

        SegmentedProgressBar(
            segments: [
                .init(value: 8, color: .purple, label: "Sleep"),
                .init(value: 16, color: .blue, label: "Awake")
            ],
            height: 8
        )
    }
    .padding()
}
