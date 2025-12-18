//
//  ContentView.swift
//  Reality Annotation Platform
//
//  Main 2D window view
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @EnvironmentObject private var appState: AppState

    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            // Annotations List Tab
            AnnotationListView()
                .tabItem {
                    Label("Annotations", systemImage: "note.text")
                }
                .tag(1)

            // Layers Tab
            LayerListView()
                .tabItem {
                    Label("Layers", systemImage: "square.stack.3d.up")
                }
                .tag(2)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .task {
            // Start automatic CloudKit sync when app launches
            print("🚀 Starting automatic sync...")
            await appState.startSync()
        }
        .onAppear {
            // Show onboarding on first launch
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @EnvironmentObject private var appState: AppState
    @Query(sort: \Annotation.createdAt, order: .reverse) private var annotations: [Annotation]
    @Query private var layers: [Layer]

    @State private var showCreateSheet = false

    var activeAnnotations: [Annotation] {
        annotations.filter { !$0.isDeleted }
    }

    var recentAnnotations: [Annotation] {
        Array(activeAnnotations.prefix(5))
    }

    var pendingSyncCount: Int {
        activeAnnotations.filter { $0.isPendingSync }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Hero Section
                    VStack(spacing: 16) {
                        Image(systemName: "visionpro")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)

                        Text("Reality Annotations")
                            .font(.largeTitle)
                            .bold()

                        Text("Leave notes in physical space")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 30)

                    // Action Buttons
                    HStack(spacing: 16) {
                        // AR Mode Button
                        Button {
                            Task {
                                if appState.isImmersiveSpaceActive {
                                    await dismissImmersiveSpace()
                                    appState.isImmersiveSpaceActive = false
                                } else {
                                    await openImmersiveSpace(id: "ar-space")
                                    appState.isImmersiveSpaceActive = true
                                }
                            }
                        } label: {
                            Label(
                                appState.isImmersiveSpaceActive ? "Exit AR" : "Enter AR",
                                systemImage: appState.isImmersiveSpaceActive ? "xmark.circle" : "visionpro"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        // Quick Create Button
                        Button {
                            showCreateSheet = true
                        } label: {
                            Label("Create", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }

                    // Quick Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Stats")
                            .font(.headline)

                        HStack(spacing: 20) {
                            StatCard(
                                title: "Annotations",
                                value: "\(activeAnnotations.count)",
                                icon: "note.text"
                            )
                            StatCard(
                                title: "Layers",
                                value: "\(layers.count)",
                                icon: "square.stack"
                            )
                            StatCard(
                                title: "Pending Sync",
                                value: "\(pendingSyncCount)",
                                icon: "arrow.clockwise"
                            )
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(16)

                    // Recent Annotations
                    if !recentAnnotations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Annotations")
                                    .font(.headline)
                                Spacer()
                                NavigationLink("See All") {
                                    AnnotationListView()
                                }
                                .font(.subheadline)
                            }

                            VStack(spacing: 8) {
                                ForEach(recentAnnotations) { annotation in
                                    NavigationLink(destination: AnnotationDetailView(annotation: annotation)) {
                                        RecentAnnotationRow(annotation: annotation)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(16)
                    }

                    // Sync Status
                    if appState.isSyncing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Syncing...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if let lastSync = appState.lastSyncTime {
                        Text("Last synced: \(lastSync, style: .relative) ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showCreateSheet) {
                CreateAnnotationView()
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(.blue)

            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Recent Annotation Row

struct RecentAnnotationRow: View {
    let annotation: Annotation

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: annotation.type.icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                if let title = annotation.title, !title.isEmpty {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                } else if let content = annotation.contentText {
                    Text(content)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }

                Text(annotation.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if annotation.isPendingSync {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
