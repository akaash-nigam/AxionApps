import SwiftUI

struct GoalsTrackerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(appState.goals) { goal in
                    GoalCardView(goal: goal)
                }

                if appState.goals.isEmpty {
                    emptyStateView
                }
            }
            .padding()
        }
        .frame(width: 600, height: 800)
        .background(.regularMaterial)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Add new goal
                } label: {
                    Label("Add Goal", systemImage: "plus")
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Goals Set")
                .font(.title2)
                .fontWeight(.semibold)

            Text("You haven't created any sustainability goals yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Create Goal") {
                // Create goal action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}

struct GoalCardView: View {
    let goal: SustainabilityGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundStyle(Color(hex: goal.category.color))

                Text(goal.title)
                    .font(.headline)

                Spacer()

                statusBadge
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: goal.progress, total: 1.0)
                    .tint(Color(hex: goal.status.color))

                HStack {
                    Text("\(goal.progressPercentage)%")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(goal.daysRemaining) days remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Current vs Target
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f %@", goal.currentValue, goal.unit))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f %@", goal.targetValue, goal.unit))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Button("View Details") {
                // View details action
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: goal.status.icon)
            Text(goal.status.displayName)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: goal.status.color), in: Capsule())
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GoalsTrackerView()
        .environment(AppState())
}
