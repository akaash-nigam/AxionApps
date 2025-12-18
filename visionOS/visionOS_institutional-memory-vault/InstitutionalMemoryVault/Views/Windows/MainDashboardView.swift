//
//  MainDashboardView.swift
//  Institutional Memory Vault
//
//  Main dashboard - entry point for the application
//

import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @Query private var recentKnowledge: [KnowledgeEntity]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // MARK: Header
                    headerSection

                    // MARK: Quick Actions
                    quickActionsSection

                    // MARK: Recent Knowledge
                    recentKnowledgeSection

                    // MARK: Quick Access
                    quickAccessSection

                    // MARK: Knowledge Health Metrics
                    metricsSection
                }
                .padding(40)
            }
            .navigationTitle("Institutional Memory Vault")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        openWindow(id: "settings")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome back")
                .font(.title3)
                .foregroundStyle(.secondary)

            if let user = appState.currentUser {
                Text(user.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                Text("Knowledge Explorer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Text("Your organizational memory, preserved and accessible")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: 20) {
            ActionCard(
                title: "Recent Knowledge",
                icon: "clock.arrow.circlepath",
                color: .blue
            ) {
                // Show recent knowledge
            }

            ActionCard(
                title: "Search & Find",
                icon: "magnifyingglass",
                color: .purple
            ) {
                openWindow(id: "search")
            }

            ActionCard(
                title: "Capture New",
                icon: "plus.circle.fill",
                color: .green
            ) {
                Task {
                    await openCaptureStudio()
                }
            }
        }
    }

    // MARK: - Recent Knowledge

    private var recentKnowledgeSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Knowledge Activity")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    openWindow(id: "search")
                }
            }

            if recentKnowledge.isEmpty {
                emptyKnowledgeView
            } else {
                knowledgeList
            }
        }
    }

    private var emptyKnowledgeView: some View {
        VStack(spacing: 15) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No knowledge items yet")
                .font(.headline)

            Text("Start by capturing your first piece of organizational wisdom")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Get Started") {
                Task {
                    await openCaptureStudio()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(.quaternary.opacity(0.5))
        .cornerRadius(12)
    }

    private var knowledgeList: some View {
        VStack(spacing: 10) {
            ForEach(recentKnowledge.prefix(5)) { knowledge in
                KnowledgeRowView(knowledge: knowledge)
                    .onTapGesture {
                        openWindow(id: "detail", value: knowledge.id)
                    }
            }
        }
    }

    // MARK: - Quick Access

    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Access")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 15) {
                QuickAccessButton(
                    title: "Departments",
                    icon: "building.2",
                    color: .orange
                ) {
                    openWindow(id: "org-chart-3d")
                }

                QuickAccessButton(
                    title: "Experts",
                    icon: "person.3",
                    color: .cyan
                ) {
                    // Open experts view
                }

                QuickAccessButton(
                    title: "Timeline",
                    icon: "clock",
                    color: .indigo
                ) {
                    openWindow(id: "timeline-3d")
                }

                QuickAccessButton(
                    title: "Memory Palace",
                    icon: "building.columns",
                    color: .purple
                ) {
                    Task {
                        await openMemoryPalace()
                    }
                }
            }
        }
    }

    // MARK: - Metrics

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Knowledge Health")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                MetricView(
                    title: "Total Items",
                    value: "\(recentKnowledge.count)",
                    icon: "doc.text.fill",
                    color: .blue
                )

                MetricView(
                    title: "Coverage",
                    value: "87%",
                    icon: "chart.bar.fill",
                    color: .green
                )

                MetricView(
                    title: "Connections",
                    value: "2.4k",
                    icon: "link",
                    color: .purple
                )

                MetricView(
                    title: "Active",
                    value: "93%",
                    icon: "checkmark.circle.fill",
                    color: .cyan
                )
            }
        }
    }

    // MARK: - Actions

    private func openCaptureStudio() async {
        do {
            try await openImmersiveSpace(id: "capture-studio")
        } catch {
            print("Failed to open capture studio: \(error)")
        }
    }

    private func openMemoryPalace() async {
        do {
            try await openImmersiveSpace(id: "memory-palace")
        } catch {
            print("Failed to open memory palace: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(color)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(.quaternary.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct QuickAccessButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.quaternary.opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary.opacity(0.5))
        .cornerRadius(8)
    }
}

struct KnowledgeRowView: View {
    let knowledge: KnowledgeEntity

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconForContentType(knowledge.contentType))
                .font(.title2)
                .foregroundStyle(colorForContentType(knowledge.contentType))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(knowledge.title)
                    .font(.headline)

                HStack {
                    Text(knowledge.contentType.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(knowledge.createdDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .cornerRadius(8)
    }

    private func iconForContentType(_ type: KnowledgeContentType) -> String {
        switch type {
        case .document: return "doc.text"
        case .expertise: return "brain"
        case .decision: return "bolt.circle"
        case .process: return "arrow.triangle.2.circlepath"
        case .story: return "book"
        case .lesson: return "graduationcap"
        case .innovation: return "lightbulb"
        }
    }

    private func colorForContentType(_ type: KnowledgeContentType) -> Color {
        switch type {
        case .document: return .gray
        case .expertise: return .orange
        case .decision: return .purple
        case .process: return .blue
        case .story: return .pink
        case .lesson: return .yellow
        case .innovation: return .cyan
        }
    }
}

#Preview {
    MainDashboardView()
        .environment(AppState())
}
