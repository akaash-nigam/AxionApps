import SwiftUI

/// Statistics panel showing city metrics
struct StatisticsPanelView: View {
    @Environment(GameCoordinator.self) private var coordinator

    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("City Statistics")
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                Divider()

                // Population
                StatRow(
                    icon: "person.2.fill",
                    label: "Population",
                    value: "\(coordinator.gameState.cityData.population)"
                )

                // Happiness
                StatRow(
                    icon: "face.smiling",
                    label: "Happiness",
                    value: String(format: "%.0f%%", coordinator.gameState.cityData.statistics.averageHappiness * 100)
                )

                // Treasury
                StatRow(
                    icon: "dollarsign.circle",
                    label: "Treasury",
                    value: String(format: "$%.0f", coordinator.gameState.cityData.economy.treasury)
                )

                // Employment
                StatRow(
                    icon: "briefcase.fill",
                    label: "Employment",
                    value: String(format: "%.0f%%", (1.0 - coordinator.gameState.cityData.economy.unemployment) * 100)
                )

                // Buildings
                StatRow(
                    icon: "building.2.fill",
                    label: "Buildings",
                    value: "\(coordinator.gameState.cityData.buildingCount)"
                )

                Divider()

                // Income/Expense
                HStack {
                    VStack(alignment: .leading) {
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.0f", coordinator.gameState.cityData.economy.income))
                            .font(.body)
                            .foregroundStyle(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.0f", coordinator.gameState.cityData.economy.expenses))
                            .font(.body)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding()
        .frame(width: isExpanded ? 300 : 200)
        .glassBackgroundEffect()
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)

            Text(label)
                .font(.caption)

            Spacer()

            Text(value)
                .font(.body)
                .bold()
        }
    }
}

#Preview {
    StatisticsPanelView()
        .environment(GameCoordinator())
}
