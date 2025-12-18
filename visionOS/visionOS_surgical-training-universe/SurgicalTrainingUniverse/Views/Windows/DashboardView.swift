//
//  DashboardView.swift
//  Surgical Training Universe
//
//  Main dashboard interface
//

import SwiftUI
import SwiftData

/// Main dashboard view - entry point to the application
struct DashboardView: View {

    // MARK: - Environment

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    // MARK: - State

    @State private var selectedProcedure: ProcedureType?
    @State private var showingProcedureDetail = false

    // MARK: - Queries

    @Query(sort: \ProcedureSession.startTime, order: .reverse)
    private var recentSessions: [ProcedureSession]

    @Query private var surgeonProfiles: [SurgeonProfile]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // MARK: Header
                    headerSection

                    // MARK: Performance Overview
                    performanceOverviewSection

                    // MARK: Procedure Library
                    procedureLibrarySection

                    // MARK: Recent Activity
                    recentActivitySection

                    // MARK: Quick Actions
                    quickActionsSection
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
            }
            .navigationTitle("Surgical Training Universe")
            .background(.regularMaterial)
        }
        .onAppear {
            setupInitialData()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome, \(currentSurgeon?.name ?? "Surgeon")")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(currentSurgeon?.specialization.rawValue ?? "General Surgery")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    openWindow(id: "settings")
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .buttonStyle(.bordered)

                Button {
                    // Open help
                } label: {
                    Label("Help", systemImage: "questionmark.circle.fill")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Performance Overview

    private var performanceOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Overview")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                PerformanceCard(
                    title: "Accuracy",
                    score: currentSurgeon?.averageAccuracy ?? 0,
                    icon: "target",
                    color: .blue
                )

                PerformanceCard(
                    title: "Efficiency",
                    score: currentSurgeon?.averageEfficiency ?? 0,
                    icon: "gauge.high",
                    color: .green
                )

                PerformanceCard(
                    title: "Safety",
                    score: currentSurgeon?.averageSafety ?? 0,
                    icon: "checkmark.shield.fill",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Procedure Library

    private var procedureLibrarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Procedure Library")
                .font(.title2)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Array(ProcedureType.allCases.prefix(8)), id: \.self) { procedure in
                    ProcedureCard(procedure: procedure) {
                        selectedProcedure = procedure
                        showingProcedureDetail = true
                    }
                }

                // More button
                Button {
                    // Show full library
                } label: {
                    VStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 40))
                        Text("More")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(.thinMaterial)
                    .cornerRadius(16)
                }
            }
        }
        .sheet(isPresented: $showingProcedureDetail) {
            if let procedure = selectedProcedure {
                ProcedureDetailView(procedure: procedure)
            }
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                if recentSessions.isEmpty {
                    emptyStateView
                } else {
                    ForEach(Array(recentSessions.prefix(5))) { session in
                        SessionRowView(session: session)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "stethoscope")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Sessions Yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Start your first surgical procedure to begin training")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Browse Procedures") {
                // Scroll to procedure library
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: 16) {
            Button {
                // Continue last procedure
            } label: {
                Label("Continue Training", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                openWindow(id: "analytics")
            } label: {
                Label("View Analytics", systemImage: "chart.bar.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                Task {
                    await openCollaborativeSession()
                }
            } label: {
                Label("Collaborative Session", systemImage: "person.3.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                openWindow(id: "anatomy-volume")
            } label: {
                Label("Anatomy Explorer", systemImage: "cube.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    // MARK: - Computed Properties

    private var currentSurgeon: SurgeonProfile? {
        appState.currentUser ?? surgeonProfiles.first
    }

    // MARK: - Methods

    private func setupInitialData() {
        // Create default surgeon profile if none exists
        if surgeonProfiles.isEmpty {
            let defaultSurgeon = SurgeonProfile(
                name: "Dr. Jane Smith",
                email: "jane.smith@hospital.com",
                specialization: .generalSurgery,
                level: .resident2,
                institution: "Medical Training Center"
            )
            modelContext.insert(defaultSurgeon)
            appState.signIn(user: defaultSurgeon)
        } else if appState.currentUser == nil {
            appState.signIn(user: surgeonProfiles.first!)
        }
    }

    private func openCollaborativeSession() async {
        await openImmersiveSpace(id: "collaborative-theater")
    }
}

// MARK: - Supporting Views

struct PerformanceCard: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("\(Int(score))%")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (score / 100))
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}

struct ProcedureCard: View {
    let procedure: ProcedureType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)

                Text(procedure.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                HStack {
                    ForEach(0..<procedure.difficultyLevel, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Text("Start")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch procedure {
        case .appendectomy: return "bandage.fill"
        case .cholecystectomy: return "cross.case.fill"
        case .cabg, .valveReplacement: return "heart.fill"
        case .craniotomy: return "brain.head.profile"
        case .hipReplacement, .kneeReplacement: return "figure.walk"
        default: return "staroflife.fill"
        }
    }
}

struct SessionRowView: View {
    let session: ProcedureSession

    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.procedureType.rawValue)
                    .font(.headline)

                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(session.overallScore))%")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(scoreColor)

            Text(formattedDuration)
                .font(.callout)
                .foregroundStyle(.secondary)

            Button("Review") {
                // Open session review
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch session.status {
        case .completed: return .green
        case .inProgress: return .blue
        case .aborted: return .red
        case .paused: return .orange
        }
    }

    private var scoreColor: Color {
        if session.overallScore >= 90 { return .green }
        if session.overallScore >= 70 { return .orange }
        return .red
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.startTime)
    }

    private var formattedDuration: String {
        let minutes = Int(session.duration / 60)
        return "\(minutes) min"
    }
}

struct ProcedureDetailView: View {
    let procedure: ProcedureType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(procedure.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Difficulty Level: \(procedure.difficultyLevel)/5")
                    .font(.title3)

                Text("Expected Duration: \(Int(procedure.expectedDuration / 60)) minutes")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    Task {
                        await startProcedure()
                    }
                } label: {
                    Label("Start Procedure", systemImage: "play.fill")
                        .font(.title3)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(40)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func startProcedure() async {
        dismiss()
        await openImmersiveSpace(id: "surgical-theater")
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
