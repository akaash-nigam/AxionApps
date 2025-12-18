import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @Query(sort: \\InnovationIdea.createdDate, order: .reverse)
    private var allIdeas: [InnovationIdea]

    @State private var selectedTab: DashboardTab = .home
    @State private var showingIdeaCapture = false

    var body: some View {
        NavigationSplitView {
            // Sidebar
            sidebar
        } detail: {
            // Main Content
            mainContent
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                quickActionButtons
            }
        }
        .sheet(isPresented: $showingIdeaCapture) {
            IdeaCaptureView()
        }
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        List(selection: $selectedTab) {
            Section("Innovation Lab") {
                ForEach(DashboardTab.allCases) { tab in
                    Label(tab.title, systemImage: tab.icon)
                        .tag(tab)
                }
            }

            Section("Quick Stats") {
                statsSection
            }
        }
        .navigationTitle("Innovation Laboratory")
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            StatRow(
                title: "Total Ideas",
                value: "\\(allIdeas.count)",
                icon: "lightbulb.fill",
                color: .blue
            )

            StatRow(
                title: "Active Projects",
                value: "\\(activeIdeasCount)",
                icon: "hammer.fill",
                color: .purple
            )

            StatRow(
                title: "Prototypes",
                value: "\\(totalPrototypesCount)",
                icon: "cube.fill",
                color: .green
            )
        }
        .padding(.vertical, 8)
    }

    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .home:
            homeView
        case .ideas:
            ideasView
        case .prototypes:
            prototypesView
        case .analytics:
            analyticsView
        case .collaboration:
            collaborationView
        }
    }

    // MARK: - Home View
    private var homeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                welcomeHeader

                recentIdeasSection

                innovationPipelineSection

                teamCollaborationSection
            }
            .padding()
        }
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Innovation Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Transform ideas into breakthrough innovations")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var recentIdeasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Recent Ideas", systemImage: "lightbulb.fill")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showingIdeaCapture = true
                } label: {
                    Label("New Idea", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            if allIdeas.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(allIdeas.prefix(6)) { idea in
                        IdeaCard(idea: idea)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb.slash")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No ideas yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start innovating by creating your first idea")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingIdeaCapture = true
            } label: {
                Label("Create First Idea", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private var innovationPipelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Innovation Pipeline", systemImage: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ForEach(IdeaStatus.allCases.dropLast(), id: \\.self) { status in
                    PipelineRow(status: status, count: countIdeas(with: status))
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var teamCollaborationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Team Collaboration", systemImage: "person.3.fill")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                Button {
                    Task {
                        await openCollaborationSpace()
                    }
                } label: {
                    VStack {
                        Image(systemName: "person.2.wave.2.fill")
                            .font(.title)
                        Text("Start Session")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)

                Button {
                    openWindow(id: "prototypeStudio")
                } label: {
                    VStack {
                        Image(systemName: "cube.3d.fill")
                            .font(.title)
                        Text("Prototype Studio")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)

                Button {
                    openWindow(id: "analyticsVolume")
                } label: {
                    VStack {
                        Image(systemName: "chart.bar.3d")
                            .font(.title)
                        Text("Analytics")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Ideas View
    private var ideasView: some View {
        IdeasListView()
    }

    // MARK: - Prototypes View
    private var prototypesView: some View {
        PrototypesListView()
    }

    // MARK: - Analytics View
    private var analyticsView: some View {
        AnalyticsDashboardView()
    }

    // MARK: - Collaboration View
    private var collaborationView: some View {
        CollaborationDashboardView()
    }

    // MARK: - Quick Action Buttons
    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showingIdeaCapture = true
            } label: {
                Label("New Idea", systemImage: "plus.circle.fill")
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button {
                Task {
                    await enterInnovationUniverse()
                }
            } label: {
                Label("Enter Universe", systemImage: "globe")
            }
            .keyboardShortcut("u", modifiers: [.command])
        }
    }

    // MARK: - Helper Methods
    private var activeIdeasCount: Int {
        allIdeas.filter { $0.status != .archived && $0.status != .launched }.count
    }

    private var totalPrototypesCount: Int {
        allIdeas.reduce(0) { $0 + $1.prototypes.count }
    }

    private func countIdeas(with status: IdeaStatus) -> Int {
        allIdeas.filter { $0.status == status }.count
    }

    private func openCollaborationSpace() async {
        // Start collaboration session
        let collaborationService = CollaborationService()
        let teamID = UUID() // Get actual team ID

        do {
            let session = try await collaborationService.startSession(teamID: teamID)
            appState.collaborationSession = session
            openWindow(id: "innovationUniverse")
        } catch {
            print("Failed to start collaboration: \\(error)")
        }
    }

    private func enterInnovationUniverse() async {
        appState.isImmersed = true
        await openImmersiveSpace(id: "innovationUniverse")
    }
}

// MARK: - Dashboard Tab
enum DashboardTab: String, CaseIterable, Identifiable {
    case home
    case ideas
    case prototypes
    case analytics
    case collaboration

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .ideas: return "Ideas"
        case .prototypes: return "Prototypes"
        case .analytics: return "Analytics"
        case .collaboration: return "Collaboration"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .ideas: return "lightbulb.fill"
        case .prototypes: return "cube.fill"
        case .analytics: return "chart.bar.fill"
        case .collaboration: return "person.3.fill"
        }
    }
}

// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PipelineRow: View {
    let status: IdeaStatus
    let count: Int

    var body: some View {
        HStack {
            Label(status.rawValue, systemImage: status.icon)
                .font(.body)

            Spacer()

            Text("\\(count)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ProgressView(value: Double(count), total: 20)
                .frame(width: 100)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
