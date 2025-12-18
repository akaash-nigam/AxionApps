//
//  AgentListView.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import SwiftUI
import SwiftData

/// Complete agent list view with search, filter, and actions
struct AgentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AIAgent.name) private var agents: [AIAgent]

    @State private var searchText = ""
    @State private var selectedStatus: AgentStatus?
    @State private var selectedPlatform: AIPlatform?
    @State private var selectedAgent: AIAgent?
    @State private var showingDetail = false

    var filteredAgents: [AIAgent] {
        var filtered = agents

        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { agent in
                agent.name.localizedCaseInsensitiveContains(searchText) ||
                agent.agentDescription.localizedCaseInsensitiveContains(searchText) ||
                agent.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        // Status filter
        if let status = selectedStatus {
            filtered = filtered.filter { $0.status == status }
        }

        // Platform filter
        if let platform = selectedPlatform {
            filtered = filtered.filter { $0.platform == platform }
        }

        return filtered
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedAgent) {
                Section {
                    ForEach(filteredAgents) { agent in
                        AgentRow(agent: agent)
                            .tag(agent)
                            .contextMenu {
                                agentContextMenu(for: agent)
                            }
                    }
                } header: {
                    HStack {
                        Text("\(filteredAgents.count) Agents")
                        Spacer()
                        Text(statisticsText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search agents...")
            .navigationTitle("Agents")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        filterMenu
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        createNewAgent()
                    } label: {
                        Label("New Agent", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let agent = selectedAgent {
                AgentDetailView(agent: agent)
            } else {
                ContentUnavailableView(
                    "No Agent Selected",
                    systemImage: "tray",
                    description: Text("Select an agent from the list")
                )
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var filterMenu: some View {
        Menu("Status") {
            Button(selectedStatus == nil ? "✓ All" : "All") {
                selectedStatus = nil
            }

            ForEach([AgentStatus.active, .idle, .error, .learning], id: \.self) { status in
                Button(selectedStatus == status ? "✓ \(status.rawValue.capitalized)" : status.rawValue.capitalized) {
                    selectedStatus = status
                }
            }
        }

        Menu("Platform") {
            Button(selectedPlatform == nil ? "✓ All" : "All") {
                selectedPlatform = nil
            }

            ForEach([AIPlatform.openai, .anthropic, .aws, .azure, .googleVertexAI], id: \.self) { platform in
                Button(selectedPlatform == platform ? "✓ \(platform.rawValue)" : platform.rawValue) {
                    selectedPlatform = platform
                }
            }
        }

        Divider()

        Button("Clear Filters") {
            selectedStatus = nil
            selectedPlatform = nil
        }
    }

    @ViewBuilder
    private func agentContextMenu(for agent: AIAgent) -> some View {
        Button {
            Task {
                await startAgent(agent)
            }
        } label: {
            Label("Start", systemImage: "play.fill")
        }
        .disabled(agent.status == .active)

        Button {
            Task {
                await stopAgent(agent)
            }
        } label: {
            Label("Stop", systemImage: "stop.fill")
        }
        .disabled(agent.status != .active)

        Button {
            Task {
                await restartAgent(agent)
            }
        } label: {
            Label("Restart", systemImage: "arrow.clockwise")
        }

        Divider()

        Button {
            showingDetail = true
        } label: {
            Label("View Details", systemImage: "info.circle")
        }

        Button(role: .destructive) {
            deleteAgent(agent)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private var statisticsText: String {
        let active = agents.filter { $0.status == .active }.count
        let error = agents.filter { $0.status == .error }.count
        return "\(active) active • \(error) errors"
    }

    // MARK: - Actions

    private func createNewAgent() {
        let newAgent = AIAgent(
            name: "New Agent",
            type: .general,
            platform: .custom,
            status: .idle,
            agentDescription: "New agent description",
            endpoint: nil,
            tags: []
        )

        modelContext.insert(newAgent)
        selectedAgent = newAgent
    }

    private func startAgent(_ agent: AIAgent) async {
        agent.status = .active
        agent.lastActiveAt = Date()
    }

    private func stopAgent(_ agent: AIAgent) async {
        var updatedAgent = agent
        updatedAgent.status = .idle
    }

    private func restartAgent(_ agent: AIAgent) async {
        await stopAgent(agent)
        try? await Task.sleep(for: .milliseconds(500))
        await startAgent(agent)
    }

    private func deleteAgent(_ agent: AIAgent) {
        modelContext.delete(agent)
    }
}

// MARK: - Agent Row

struct AgentRow: View {
    let agent: AIAgent

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(agent.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(agent.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let metrics = agent.currentMetrics {
                        Text("CPU: \(Int(metrics.cpuUsage * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Platform badge
            Text(agent.platform.rawValue)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch agent.status {
        case .active: .green
        case .idle: .gray
        case .error: .red
        case .learning: .yellow
        case .optimizing: .blue
        case .paused: .orange
        case .terminated: .gray
        }
    }
}

// MARK: - Agent Detail View

struct AgentDetailView: View {
    let agent: AIAgent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(agent.name)
                            .font(.title)

                        Spacer()

                        statusBadge
                    }

                    Text(agent.agentDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Metadata
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    GridRow {
                        Text("Type:")
                            .foregroundStyle(.secondary)
                        Text(agent.type.rawValue.capitalized)
                    }

                    GridRow {
                        Text("Platform:")
                            .foregroundStyle(.secondary)
                        Text(agent.platform.rawValue)
                    }

                    if let endpoint = agent.endpoint {
                        GridRow {
                            Text("Endpoint:")
                                .foregroundStyle(.secondary)
                            Text(endpoint)
                                .font(.system(.body, design: .monospaced))
                        }
                    }

                    GridRow {
                        Text("Created:")
                            .foregroundStyle(.secondary)
                        Text(agent.createdAt, style: .relative)
                    }

                    GridRow {
                        Text("Last Active:")
                            .foregroundStyle(.secondary)
                        Text(agent.lastActiveAt, style: .relative)
                    }
                }

                Divider()

                // Current Metrics
                if let metrics = agent.currentMetrics {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Metrics")
                            .font(.headline)

                        MetricsGrid(metrics: metrics)
                    }
                }

                // Tags
                if !agent.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(agent.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.tertiary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Agent Details")
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(agent.status.rawValue.uppercased())
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }

    private var statusColor: Color {
        switch agent.status {
        case .active: .green
        case .idle: .gray
        case .error: .red
        case .learning: .yellow
        case .optimizing: .blue
        case .paused: .orange
        case .terminated: .gray
        }
    }
}

// MARK: - Metrics Grid

struct MetricsGrid: View {
    let metrics: AgentMetrics

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
            GridRow {
                metricCell("CPU", value: "\(Int(metrics.cpuUsage * 100))%")
                metricCell("Memory", value: "\(Int(Double(metrics.memoryUsage) / (1024 * 1024))) MB")
            }

            GridRow {
                metricCell("Requests/s", value: String(format: "%.1f", metrics.requestsPerSecond))
                metricCell("Latency", value: "\(Int(metrics.averageLatency * 1000)) ms")
            }

            GridRow {
                metricCell("Success Rate", value: String(format: "%.1f%%", metrics.successRate * 100))
                metricCell("Health", value: String(format: "%.1f%%", metrics.healthScore * 100))
            }
        }
    }

    @ViewBuilder
    private func metricCell(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary)
        .cornerRadius(8)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + lineHeight)
        }
    }
}

#Preview {
    AgentListView()
        .modelContainer(for: AIAgent.self, inMemory: true)
}
