//
//  HealthBadge.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI

struct HealthBadge: View {
    let score: Double
    let size: CGFloat

    init(score: Double, size: CGFloat = 40) {
        self.score = score
        self.size = size
    }

    var healthColor: Color {
        HealthColor.color(for: score)
    }

    var healthStatus: HealthStatus {
        switch score {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .moderate
        case 20..<40: return .poor
        default: return .critical
        }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)

            // Health arc
            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(
                    healthColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Percentage
            Text("\(Int(score))%")
                .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                .foregroundStyle(healthColor)
        }
        .frame(width: size, height: size)
    }
}

struct HealthProgressBar: View {
    let score: Double

    var healthColor: Color {
        HealthColor.color(for: score)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                // Progress
                RoundedRectangle(cornerRadius: 4)
                    .fill(healthColor)
                    .frame(width: geometry.size.width * (score / 100), height: 8)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Preview

#Preview("Excellent Health") {
    VStack(spacing: 20) {
        HealthBadge(score: 92)
        HealthProgressBar(score: 92)
            .frame(width: 200)
    }
    .padding()
}

#Preview("Poor Health") {
    VStack(spacing: 20) {
        HealthBadge(score: 35)
        HealthProgressBar(score: 35)
            .frame(width: 200)
    }
    .padding()
}
