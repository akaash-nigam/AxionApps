import SwiftUI
import RealityKit

/// SwiftUI view for presenting player choices in 3D space
struct ChoiceView: View {
    let choice: Choice
    let onSelect: (ChoiceOption) -> Void

    @State private var hoveredOption: UUID?
    @State private var timeRemaining: TimeInterval?

    var body: some View {
        VStack(spacing: 20) {
            // Choice prompt
            if !choice.prompt.isEmpty {
                Text(choice.prompt)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            // Time limit indicator
            if let timeLimit = choice.timeLimit, let remaining = timeRemaining {
                TimeRemainingIndicator(remaining: remaining, total: timeLimit)
            }

            // Choice options
            HStack(spacing: 16) {
                ForEach(choice.options) { option in
                    ChoiceOptionButton(
                        option: option,
                        isHovered: hoveredOption == option.id,
                        onSelect: {
                            onSelect(option)
                        }
                    )
                }
            }
        }
        .padding(24)
        .task {
            if let timeLimit = choice.timeLimit {
                await startTimer(duration: timeLimit)
            }
        }
    }

    // MARK: - Timer

    private func startTimer(duration: TimeInterval) async {
        timeRemaining = duration

        let startTime = Date()
        while let remaining = timeRemaining, remaining > 0 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

            let elapsed = Date().timeIntervalSince(startTime)
            timeRemaining = max(0, duration - elapsed)

            if timeRemaining == 0 {
                // Time's up - auto-select first option
                if let firstOption = choice.options.first {
                    onSelect(firstOption)
                }
            }
        }
    }
}

/// Individual choice option button
struct ChoiceOptionButton: View {
    let option: ChoiceOption
    let isHovered: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Icon
                if let iconName = option.icon {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundStyle(styleColor)
                }

                // Text
                Text(option.text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // Relationship impact indicator
                if !option.relationshipImpacts.isEmpty {
                    RelationshipIndicator(impacts: option.relationshipImpacts)
                }
            }
            .padding(16)
            .frame(minWidth: 120, maxWidth: 200)
            .background(backgroundMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(styleColor, lineWidth: isHovered ? 3 : 1)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
    }

    private var styleColor: Color {
        switch option.visualStyle {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .gray
        case .standard: return .blue
        }
    }

    private var backgroundMaterial: Material {
        switch option.visualStyle {
        case .positive: return .ultraThinMaterial
        case .negative: return .ultraThinMaterial
        case .neutral: return .thin
        case .standard: return .regular
        }
    }
}

/// Time remaining progress indicator
struct TimeRemainingIndicator: View {
    let remaining: TimeInterval
    let total: TimeInterval

    var body: some View {
        VStack(spacing: 4) {
            Text("Time: \(Int(remaining))s")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: remaining, total: total)
                .tint(progressColor)
                .frame(width: 200)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }

    private var progressColor: Color {
        let ratio = remaining / total
        if ratio > 0.5 {
            return .green
        } else if ratio > 0.25 {
            return .orange
        } else {
            return .red
        }
    }
}

/// Relationship impact indicator
struct RelationshipIndicator: View {
    let impacts: [UUID: Float]

    var body: some View {
        HStack(spacing: 4) {
            let totalImpact = impacts.values.reduce(0, +)

            if totalImpact > 0 {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.green)
                Text("+Relationship")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else if totalImpact < 0 {
                Image(systemName: "heart.slash")
                    .foregroundStyle(.red)
                Text("-Relationship")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .font(.caption)
    }
}

// MARK: - Preview

#Preview {
    let sampleChoice = Choice(
        id: UUID(),
        prompt: "How do you respond?",
        options: [
            ChoiceOption(
                id: UUID(),
                text: "Tell the truth",
                icon: "checkmark.circle",
                storyBranchID: nil,
                relationshipImpacts: [UUID(): 0.2],
                flagsSet: [],
                emotionalTone: .happy,
                spatialPosition: .left,
                visualStyle: .positive
            ),
            ChoiceOption(
                id: UUID(),
                text: "Lie to protect them",
                icon: "exclamationmark.triangle",
                storyBranchID: nil,
                relationshipImpacts: [UUID(): -0.1],
                flagsSet: [],
                emotionalTone: .fearful,
                spatialPosition: .center,
                visualStyle: .negative
            ),
            ChoiceOption(
                id: UUID(),
                text: "Stay silent",
                icon: "ellipsis.circle",
                storyBranchID: nil,
                relationshipImpacts: [:],
                flagsSet: [],
                emotionalTone: .neutral,
                spatialPosition: .right,
                visualStyle: .neutral
            )
        ],
        timeLimit: 30.0,
        emotionalContext: .tense
    )

    return ChoiceView(choice: sampleChoice) { option in
        print("Selected: \(option.text)")
    }
    .frame(width: 800, height: 400)
}
