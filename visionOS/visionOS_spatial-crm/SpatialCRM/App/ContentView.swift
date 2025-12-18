//
//  ContentView.swift
//  SpatialCRM
//
//  Main content view with tab-based navigation
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties

    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppView = .dashboard
    @State private var showingQuickActions = false

    // MARK: - Body

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                .tag(AppView.dashboard)

            // Pipeline Tab
            PipelineView()
                .tabItem {
                    Label("Pipeline", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppView.pipeline)

            // Accounts Tab
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "building.2")
                }
                .tag(AppView.accounts)

            // Analytics Tab
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(AppView.analytics)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            appState.activeView = newValue
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingQuickActions.toggle()
                } label: {
                    Label("Quick Actions", systemImage: "bolt.circle.fill")
                }
            }

            ToolbarItem(placement: .automatic) {
                SearchButton()
            }

            ToolbarItem(placement: .automatic) {
                NotificationButton()
            }

            ToolbarItem(placement: .automatic) {
                UserAvatarButton()
            }
        }
        .sheet(isPresented: $showingQuickActions) {
            QuickActionsView()
        }
    }
}

// MARK: - Toolbar Components

struct SearchButton: View {
    @State private var searchQuery = ""
    @State private var isSearching = false

    var body: some View {
        Button {
            isSearching.toggle()
        } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
        .popover(isPresented: $isSearching) {
            SearchView(query: $searchQuery)
                .frame(width: 500, height: 400)
        }
    }
}

struct NotificationButton: View {
    @State private var hasNotifications = true
    @State private var showingNotifications = false

    var body: some View {
        Button {
            showingNotifications.toggle()
        } label: {
            Label("Notifications", systemImage: hasNotifications ? "bell.badge.fill" : "bell")
        }
        .badge(hasNotifications ? 3 : 0)
    }
}

struct UserAvatarButton: View {
    @State private var showingProfile = false

    var body: some View {
        Button {
            showingProfile.toggle()
        } label: {
            Image(systemName: "person.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .blue.opacity(0.3))
        }
        .popover(isPresented: $showingProfile) {
            UserProfileView()
                .frame(width: 300, height: 400)
        }
    }
}

// MARK: - Placeholder Views

struct SearchView: View {
    @Binding var query: String

    var body: some View {
        VStack {
            TextField("Search customers, deals, contacts...", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()

            if query.isEmpty {
                ContentUnavailableView(
                    "Search CRM",
                    systemImage: "magnifyingglass",
                    description: Text("Enter a search term to find customers, opportunities, and contacts")
                )
            } else {
                List {
                    Section("Accounts") {
                        Text("Search results for '\(query)'")
                    }
                    Section("Opportunities") {
                        Text("Search results...")
                    }
                    Section("Contacts") {
                        Text("Search results...")
                    }
                }
            }
        }
    }
}

struct UserProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("John Sales")
                .font(.title2)
            Text("Sales Representative")
                .font(.callout)
                .foregroundStyle(.secondary)

            Divider()
                .padding(.vertical)

            VStack(alignment: .leading, spacing: 12) {
                ProfileRow(icon: "dollarsign.circle", title: "Quota", value: "$2.5M")
                ProfileRow(icon: "chart.line.uptrend.xyaxis", title: "Achieved", value: "$1.8M (72%)")
                ProfileRow(icon: "trophy", title: "Win Rate", value: "68%")
            }

            Spacer()

            Button("Settings") {
                // Open settings
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(AppState())
}
