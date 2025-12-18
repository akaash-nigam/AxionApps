import SwiftUI

struct AnalyticsDashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Innovation Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                metricsGrid

                chartSection
            }
            .padding()
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCard(
                title: "Total Ideas",
                value: "42",
                trend: "+12%",
                icon: "lightbulb.fill",
                color: .blue
            )

            MetricCard(
                title: "Prototypes",
                value: "18",
                trend: "+8%",
                icon: "cube.fill",
                color: .purple
            )

            MetricCard(
                title: "Success Rate",
                value: "73%",
                trend: "+5%",
                icon: "checkmark.seal.fill",
                color: .green
            )

            MetricCard(
                title: "Avg Time to Market",
                value: "4.2mo",
                trend: "-15%",
                icon: "clock.fill",
                color: .orange
            )
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Innovation Pipeline")
                .font(.title2)
                .fontWeight(.semibold)

            // Placeholder for charts
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .frame(height: 300)
                .overlay(
                    Text("3D Charts in Volume View")
                        .foregroundStyle(.secondary)
                )
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
                Text(trend)
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CollaborationDashboardView: View {
    var body: some View {
        ContentUnavailableView(
            "Collaboration Features",
            systemImage: "person.3.fill",
            description: Text("Multi-user collaboration with SharePlay")
        )
    }
}

#Preview {
    AnalyticsDashboardView()
}
