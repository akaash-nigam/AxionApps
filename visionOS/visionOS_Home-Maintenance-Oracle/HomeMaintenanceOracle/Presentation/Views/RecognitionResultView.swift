//
//  RecognitionResultView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Detailed view for recognition results
//

import SwiftUI

struct RecognitionResultView: View {

    // MARK: - Properties

    let result: RecognitionResult
    let onSave: () -> Void
    let onRetry: () -> Void
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with primary result
                primaryResultSection

                Divider()

                // Confidence score
                confidenceSection

                // Alternative predictions
                if !result.alternatives.isEmpty {
                    Divider()
                    alternativesSection
                }

                Divider()

                // Actions
                actionsSection
            }
            .padding()
        }
        .frame(maxWidth: 500)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - View Components

    private var primaryResultSection: some View {
        HStack(spacing: 16) {
            Image(systemName: result.categoryIcon)
                .font(.system(size: 50))
                .foregroundStyle(.blue)
                .frame(width: 70, height: 70)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(result.category.capitalized)
                    .font(.title2)
                    .fontWeight(.semibold)

                if let brand = result.brand {
                    Text(brand)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if let model = result.model {
                    Text("Model: \(model)")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
    }

    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confidence")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            HStack {
                ProgressView(value: Double(result.confidence))
                    .progressViewStyle(.linear)
                    .tint(confidenceColor)

                Text("\(Int(result.confidence * 100))%")
                    .font(.headline)
                    .foregroundStyle(confidenceColor)
                    .frame(width: 50, alignment: .trailing)
            }

            Text(confidenceLabel)
                .font(.caption)
                .foregroundStyle(confidenceColor)
        }
    }

    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Other Possibilities")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            ForEach(result.alternatives.prefix(3), id: \.category) { alternative in
                alternativeRow(alternative)
            }
        }
    }

    private func alternativeRow(_ alternative: RecognitionAlternative) -> some View {
        HStack {
            Image(systemName: alternative.categoryIcon)
                .foregroundStyle(.secondary)

            Text(alternative.category.capitalized)
                .font(.subheadline)

            Spacer()

            Text("\(Int(alternative.confidence * 100))%")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: onSave) {
                Label("Save to Inventory", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 12) {
                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button(action: onDismiss) {
                    Label("Cancel", systemImage: "xmark")
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Computed Properties

    private var confidenceColor: Color {
        switch result.confidence {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .orange
        default:
            return .red
        }
    }

    private var confidenceLabel: String {
        switch result.confidence {
        case 0.8...1.0:
            return "High confidence"
        case 0.6..<0.8:
            return "Moderate confidence"
        default:
            return "Low confidence - verify result"
        }
    }
}

// MARK: - Recognition Result Extension

extension RecognitionResult {
    var categoryIcon: String {
        guard let applianceCategory = ApplianceCategory(rawValue: category) else {
            return "questionmark.circle"
        }
        return applianceCategory.icon
    }
}

extension RecognitionAlternative {
    var categoryIcon: String {
        guard let applianceCategory = ApplianceCategory(rawValue: category) else {
            return "questionmark.circle"
        }
        return applianceCategory.icon
    }
}

// MARK: - Preview

#Preview {
    RecognitionResultView(
        result: RecognitionResult(
            category: "refrigerator",
            brand: "Samsung",
            model: "RF28R7351SR",
            confidence: 0.92,
            alternatives: [
                .init(category: "freezer", confidence: 0.05),
                .init(category: "washer", confidence: 0.02),
                .init(category: "dishwasher", confidence: 0.01)
            ]
        ),
        onSave: {},
        onRetry: {},
        onDismiss: {}
    )
}
