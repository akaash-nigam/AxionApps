//
//  AnalyticsDashboardView.swift
//  Institutional Memory Vault
//
//  Analytics and metrics dashboard
//

import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Query private var allKnowledge: [KnowledgeEntity]
    @Query private var allEmployees: [Employee]
    @Query private var allDepartments: [Department]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // Overview metrics
                    overviewSection

                    // Knowledge growth chart
                    growthSection

                    // Department coverage
                    coverageSection

                    // Most connected
                    topItemsSection
                }
                .padding(40)
            }
            .navigationTitle("Knowledge Analytics")
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                MetricCard(
                    value: "\(allKnowledge.count)",
                    label: "Knowledge Items",
                    icon: "doc.text.fill",
                    color: .blue
                )

                MetricCard(
                    value: "\(allEmployees.count)",
                    label: "Contributors",
                    icon: "person.3.fill",
                    color: .purple
                )

                MetricCard(
                    value: "\(allDepartments.count)",
                    label: "Departments",
                    icon: "building.2.fill",
                    color: .orange
                )

                MetricCard(
                    value: "94%",
                    label: "Active",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }

    private var growthSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Knowledge Growth")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Chart visualization would go here")
                .foregroundStyle(.secondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(.quaternary.opacity(0.3))
                .cornerRadius(12)
        }
    }

    private var coverageSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Department Coverage")
                .font(.title2)
                .fontWeight(.semibold)

            ForEach(allDepartments.prefix(5), id: \.id) { department in
                HStack {
                    Text(department.name)
                        .frame(width: 150, alignment: .leading)

                    ProgressView(value: Double.random(in: 0.7...1.0))
                        .tint(.blue)

                    Text("\(Int.random(in: 70...100))%")
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
    }

    private var topItemsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Most Connected Knowledge")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(allKnowledge.prefix(3).enumerated().map { $0 }, id: \.element.id) { index, knowledge in
                    HStack {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                            .frame(width: 30)

                        Text(knowledge.title)

                        Spacer()

                        Text("\(knowledge.connections.count) connections")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct MetricCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary.opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsDashboardView()
}
