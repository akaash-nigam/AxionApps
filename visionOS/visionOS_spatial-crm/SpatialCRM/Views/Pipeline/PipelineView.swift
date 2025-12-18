//
//  PipelineView.swift
//  SpatialCRM
//
//  Pipeline/Opportunities view
//

import SwiftUI
import SwiftData

struct PipelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @State private var viewMode: ViewMode = .kanban
    @State private var opportunities: [Opportunity] = []

    enum ViewMode {
        case list
        case kanban
        case volume3D
    }

    var body: some View {
        VStack {
            // View mode picker
            Picker("View Mode", selection: $viewMode) {
                Label("List", systemImage: "list.bullet").tag(ViewMode.list)
                Label("Kanban", systemImage: "rectangle.grid.2x2").tag(ViewMode.kanban)
                Label("3D River", systemImage: "water.waves").tag(ViewMode.volume3D)
            }
            .pickerStyle(.segmented)
            .padding()

            if viewMode == .volume3D {
                Button("Open 3D Pipeline") {
                    openWindow(id: "pipeline-volume")
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else if viewMode == .kanban {
                kanbanView
            } else {
                listView
            }
        }
        .navigationTitle("Pipeline")
        .onAppear {
            loadOpportunities()
        }
    }

    private var kanbanView: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(DealStage.allCases.filter { $0 != .closedWon && $0 != .closedLost }, id: \.self) { stage in
                    StageColumn(stage: stage, opportunities: opportunities.filter { $0.stage == stage })
                }
            }
            .padding()
        }
    }

    private var listView: some View {
        List(opportunities) { opp in
            OpportunityRow(opportunity: opp)
        }
    }

    private func loadOpportunities() {
        let descriptor = FetchDescriptor<Opportunity>(
            predicate: #Predicate { $0.status == .active },
            sortBy: [SortDescriptor(\.amount, order: .reverse)]
        )
        opportunities = (try? modelContext.fetch(descriptor)) ?? []
    }
}

struct StageColumn: View {
    let stage: DealStage
    let opportunities: [Opportunity]

    var body: some View {
        VStack(alignment: .leading) {
            Text(stage.displayName)
                .font(.headline)
                .padding(.bottom, 8)

            Text("\(opportunities.count) deals")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(totalValue.formatted(.currency(code: "USD")))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)

            ForEach(opportunities) { opp in
                OpportunityCard(opportunity: opp)
            }
        }
        .frame(width: 250)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var totalValue: Decimal {
        opportunities.reduce(0) { $0 + $1.amount }
    }
}

struct OpportunityCard: View {
    let opportunity: Opportunity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(opportunity.name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(opportunity.account?.name ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Text(opportunity.amount.formatted(.currency(code: "USD")))
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(Int(opportunity.probability))%")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

#Preview {
    PipelineView()
}
