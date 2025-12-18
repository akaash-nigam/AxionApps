//
//  ControlPanelView.swift
//  AI Agent Coordinator
//
//  Main control panel interface
//

import SwiftUI
import SwiftData

struct ControlPanelView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @Query(sort: \AIAgent.lastActiveAt, order: .reverse) private var agents: [AIAgent]
    @State private var searchText = ""
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case agents = "Agents"
        case alerts = "Alerts"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "chart.bar.fill"
            case .agents: return "cpu.fill"
            case .alerts: return "bell.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Bar
                tabBar

                // Content
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("AI Agent Coordinator")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button {
                        openWindow(id: "settings")
                    } label: {
                        Image(systemName: "gearshape")
                    }

                    Button {
                        // TODO: Show user profile
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .ornament(attachmentAnchor: .scene(.bottom)) {
                quickActionsBar
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, UIConstants.standardCornerRadius)
                    .background(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.smallCornerRadius))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.top, UIConstants.compactPadding)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .dashboard:
            dashboardView
        case .agents:
            agentsView
        case .alerts:
            alertsView
        case .settings:
            Text("Settings")
        }
    }

    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: UIConstants.sectionSpacing) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search agents...", text: $searchText)
                }
                .padding()
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.standardCornerRadius))
                .padding(.horizontal)

                // System Overview
                systemOverviewCards

                // Recent Activity
                recentActivitySection

                // Quick Actions
                quickActionsSection
            }
            .padding(.vertical)
        }
    }

    private var systemOverviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UIConstants.standardPadding) {
            StatusCard(
                title: "Active",
                count: agents.filter { $0.status == .active }.count,
                color: .blue
            )
            StatusCard(
                title: "Idle",
                count: agents.filter { $0.status == .idle }.count,
                color: .gray
            )
            StatusCard(
                title: "Error",
                count: agents.filter { $0.status == .error }.count,
                color: .red
            )
            StatusCard(
                title: "Learning",
                count: agents.filter { $0.status == .learning }.count,
                color: .purple
            )
        }
        .padding(.horizontal)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: UIConstants.standardCornerRadius) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: UIConstants.compactPadding) {
                ForEach(agents.prefix(5)) { agent in
                    AgentRowView(agent: agent)
                }
            }
            .padding()
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
            .padding(.horizontal)
        }
    }

    private var agentsView: some View {
        List(filteredAgents) { agent in
            AgentRowView(agent: agent)
                .onTapGesture {
                    openWindow(id: "agent-detail", value: agent.id)
                }
        }
        .searchable(text: $searchText, prompt: "Search agents")
    }

    private var alertsView: some View {
        List(appModel.alerts) { alert in
            HStack {
                Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" :
                      alert.severity == .warning ? "exclamationmark.circle.fill" :
                      "info.circle.fill")
                    .foregroundStyle(alert.severity == .critical ? .red :
                                    alert.severity == .warning ? .orange : .blue)

                VStack(alignment: .leading) {
                    Text(alert.title)
                        .font(.headline)
                    Text(alert.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(alert.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.standardCornerRadius) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: UIConstants.standardCornerRadius) {
                QuickActionButton(
                    title: "Galaxy View",
                    icon: "sparkles",
                    color: .blue
                ) {
                    Task {
                        await openImmersiveSpace(id: "agent-galaxy")
                    }
                }

                QuickActionButton(
                    title: "Performance",
                    icon: "chart.xyaxis.line",
                    color: .green
                ) {
                    Task {
                        await openImmersiveSpace(id: "performance-landscape")
                    }
                }

                QuickActionButton(
                    title: "Workflows",
                    icon: "arrow.triangle.branch",
                    color: .purple
                ) {
                    Task {
                        await openImmersiveSpace(id: "decision-flow")
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var quickActionsBar: some View {
        HStack {
            Button {
                // Refresh data
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }

            Button {
                // Show filter
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }

            Button {
                // Export data
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .labelStyle(.iconOnly)
        .padding()
        .glassBackgroundEffect()
    }

    private var filteredAgents: [AIAgent] {
        if searchText.isEmpty {
            return agents
        } else {
            return agents.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatusCard: View {
    let title: String
    let count: Int
    let color: Color
    var total: Int = 0

    var body: some View {
        VStack(spacing: UIConstants.compactPadding) {
            Text("\(count)")
                .font(.system(size: UIConstants.largeCountFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) agents")
        .accessibilityValue("\(count)")
        .accessibilityHint("Shows count of agents with \(title.lowercased()) status")
    }
}

struct AgentRowView: View {
    let agent: AIAgent

    var body: some View {
        HStack(spacing: UIConstants.standardCornerRadius) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: UIConstants.statusIndicatorSize, height: UIConstants.statusIndicatorSize)
                .accessibilityHidden(true)

            // Agent info
            VStack(alignment: .leading, spacing: 4) {
                Text(agent.displayName)
                    .font(.headline)

                HStack {
                    Text(agent.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let metrics = agent.currentMetrics {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("CPU: \(metrics.formattedCPU)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Status badge
            Text(agent.status.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundStyle(statusColor)
                .clipShape(Capsule())
                .accessibilityHidden(true)
        }
        .padding()
        .agentAccessibility(agent: agent, metrics: agent.currentMetrics)
    }

    private var statusColor: Color {
        switch agent.status {
        case .active: return .blue
        case .idle: return .gray
        case .learning: return .purple
        case .error: return .red
        case .optimizing: return .green
        case .paused: return .orange
        case .terminated: return .gray
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: UIConstants.compactPadding) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.standardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to open \(title.lowercased()) view")
    }
}

#Preview {
    ControlPanelView()
        .environment(AppModel())
}
