//
//  FieldCard.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI

struct FieldCard: View {
    @Environment(FarmManager.self) private var farmManager
    let field: Field

    var body: some View {
        Button {
            farmManager.selectField(field)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Header
                HStack {
                    Image(systemName: field.cropType.iconName)
                        .foregroundStyle(.green)

                    Text(field.name)
                        .font(.headline)

                    Spacer()

                    if let health = field.currentHealthScore {
                        HealthBadge(score: health)
                    }
                }

                // MARK: - Stats
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Crop:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(field.cropType.displayName)
                            .font(.caption)
                    }

                    HStack {
                        Text("Acres:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(field.acreage))")
                            .font(.caption)
                    }

                    if let health = field.currentHealthScore {
                        HStack {
                            Text("Health:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(Int(health))%")
                                .font(.caption)
                        }
                    }
                }

                // MARK: - Health Bar
                if let health = field.currentHealthScore {
                    HealthProgressBar(score: health)
                }

                // MARK: - Warning
                if field.needsAttention {
                    Label("Needs Attention", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding(16)
            .background(.regularMaterial)
            .cornerRadius(12)
            .hoverEffect()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    FieldCard(field: .mock())
        .environment(FarmManager())
        .frame(width: 250)
}
