//
//  ContentView.swift
//  Construction Site Manager
//
//  Main content view (2D window)
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var sites: [Site]

    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        @Bindable var appState = appState

        NavigationSplitView {
            // Sidebar
            List(selection: $selectedTab) {
                Section("Main") {
                    NavigationLink(value: Tab.dashboard) {
                        Label("Dashboard", systemImage: "house.fill")
                    }

                    NavigationLink(value: Tab.sites) {
                        Label("Sites", systemImage: "building.2.fill")
                    }

                    NavigationLink(value: Tab.progress) {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }

                    NavigationLink(value: Tab.safety) {
                        Label("Safety", systemImage: "shield.fill")
                    }

                    NavigationLink(value: Tab.issues) {
                        Label("Issues", systemImage: "exclamationmark.triangle")
                    }

                    NavigationLink(value: Tab.team) {
                        Label("Team", systemImage: "person.3.fill")
                    }
                }

                Section("Views") {
                    Button {
                        // Open AR overlay
                    } label: {
                        Label("AR View", systemImage: "view.3d")
                    }

                    Button {
                        // Open site volume
                    } label: {
                        Label("3D Model", systemImage: "cube.fill")
                    }
                }

                Section("Reports") {
                    NavigationLink(value: Tab.reports) {
                        Label("Reports", systemImage: "doc.text.fill")
                    }
                }

                Section {
                    NavigationLink(value: Tab.settings) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            .navigationTitle("Construction Site Manager")
        } detail: {
            // Detail view based on selected tab
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .sites:
                    SitesListView()
                case .progress:
                    ProgressView()
                case .safety:
                    SafetyView()
                case .issues:
                    IssuesListView()
                case .team:
                    TeamView()
                case .reports:
                    ReportsView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }

    enum Tab: Hashable {
        case dashboard
        case sites
        case progress
        case safety
        case issues
        case team
        case reports
        case settings
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Query private var sites: [Site]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                if let site = appState.currentSite {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(site.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(site.address.formatted)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No Site Selected")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Select a site to get started")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Metrics
                if let site = appState.currentSite {
                    HStack(spacing: 16) {
                        MetricCard(
                            title: "Progress",
                            value: "\(Int(site.overallProgress * 100))%",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue,
                            trend: nil
                        )

                        MetricCard(
                            title: "Safety Score",
                            value: "95",
                            icon: "shield.fill",
                            color: .green,
                            trend: nil
                        )

                        MetricCard(
                            title: "Open Issues",
                            value: "\(appState.currentProject?.issues.filter { $0.status == .open }.count ?? 0)",
                            icon: "exclamationmark.triangle",
                            color: .orange,
                            trend: nil
                        )
                    }
                }

                // Quick actions
                if appState.currentSite != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ActionButton(title: "AR View", icon: "view.3d") {
                                // Open AR view
                            }

                            ActionButton(title: "Create Issue", icon: "plus.circle") {
                                // Create issue
                            }

                            ActionButton(title: "Update Progress", icon: "checkmark.circle") {
                                // Update progress
                            }
                        }
                    }
                }

                // Recent activity placeholder
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.headline)

                    Text("No recent activity")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Placeholder Views

struct SitesListView: View {
    @Query private var sites: [Site]

    var body: some View {
        ScrollView {
            if sites.isEmpty {
                ContentUnavailableView(
                    "No Sites",
                    systemImage: "building.2",
                    description: Text("Add your first construction site to get started")
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(sites) { site in
                        SiteCard(site: site)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Sites")
        .toolbar {
            Button("Add Site", systemImage: "plus") {
                // Add new site
            }
        }
    }
}

struct SiteCard: View {
    let site: Site

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(site.name)
                        .font(.headline)

                    Text(site.address.city + ", " + site.address.state)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(site.overallProgress * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: site.overallProgress)
                .tint(.blue)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProgressView: View {
    var body: some View {
        Text("Progress View - Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Progress")
    }
}

struct SafetyView: View {
    var body: some View {
        Text("Safety View - Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Safety")
    }
}

struct IssuesListView: View {
    var body: some View {
        Text("Issues View - Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Issues")
    }
}

struct TeamView: View {
    var body: some View {
        Text("Team View - Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Team")
    }
}

struct ReportsView: View {
    var body: some View {
        Text("Reports View - Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Reports")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View - Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Settings")
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
