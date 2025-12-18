//
//  CaseDashboardView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import SwiftData

struct CaseDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @Query(sort: \LegalCase.lastModified, order: .reverse) private var cases: [LegalCase]

    @State private var searchText = ""
    @State private var showingNewCaseSheet = false

    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                // Statistics Cards
                statsSection

                // Search
                searchBar

                // Case List
                caseList
            }
            .padding()
            .navigationTitle("Cases")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewCaseSheet = true
                    } label: {
                        Label("New Case", systemImage: "plus")
                    }
                }
            }
        } detail: {
            // Detail view
            if let currentCase = appState.currentCase {
                CaseDetailView(legalCase: currentCase)
            } else {
                ContentUnavailableView(
                    "No Case Selected",
                    systemImage: "folder",
                    description: Text("Select a case from the sidebar to get started")
                )
            }
        }
        .sheet(isPresented: $showingNewCaseSheet) {
            NewCaseSheet()
        }
    }

    // MARK: - View Components

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Active Cases",
                value: "\(activeCases.count)",
                icon: "folder.fill",
                color: .blue
            )

            StatCard(
                title: "Recent Activity",
                value: "\(recentActivity)",
                icon: "clock.fill",
                color: .orange
            )

            StatCard(
                title: "Starred",
                value: "\(starredCases.count)",
                icon: "star.fill",
                color: .yellow
            )
        }
        .frame(height: 100)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search cases, documents, entities...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var caseList: some View {
        List(filteredCases, selection: Binding(
            get: { appState.currentCase },
            set: { appState.currentCase = $0 }
        )) { legalCase in
            CaseRow(legalCase: legalCase)
                .tag(legalCase)
                .contextMenu {
                    Button("Open in 3D", systemImage: "cube.fill") {
                        openEvidenceUniverse(for: legalCase)
                    }
                    Button("View Timeline", systemImage: "calendar") {
                        openTimeline(for: legalCase)
                    }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteCase(legalCase)
                    }
                }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Computed Properties

    private var filteredCases: [LegalCase] {
        if searchText.isEmpty {
            return cases
        } else {
            return cases.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.caseNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var activeCases: [LegalCase] {
        cases.filter { $0.status == .active }
    }

    private var starredCases: [LegalCase] {
        cases.filter { $0.tags.contains("starred") }
    }

    private var recentActivity: Int {
        // Count of documents modified in last 24 hours
        let yesterday = Date().addingTimeInterval(-24 * 60 * 60)
        return cases.flatMap { $0.documents }.filter { $0.lastModified ?? $0.uploadDate > yesterday }.count
    }

    // MARK: - Actions

    private func openEvidenceUniverse(for legalCase: LegalCase) {
        appState.currentCase = legalCase
        Task {
            await openImmersiveSpace(id: ImmersiveSpaceIdentifier.evidenceUniverse.rawValue)
        }
    }

    private func openTimeline(for legalCase: LegalCase) {
        appState.currentCase = legalCase
        Task {
            await openImmersiveSpace(id: ImmersiveSpaceIdentifier.timeline.rawValue)
        }
    }

    private func deleteCase(_ legalCase: LegalCase) {
        modelContext.delete(legalCase)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title2)
                    .bold()
            }

            Spacer()

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct CaseRow: View {
    let legalCase: LegalCase

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(legalCase.priority.color)

                Text(legalCase.title)
                    .font(.headline)

                Spacer()

                StatusBadge(status: legalCase.status)
            }

            Text(legalCase.caseDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Label("\(legalCase.totalDocuments) docs", systemImage: "doc.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Divider()
                    .frame(height: 12)

                Label("Updated \(legalCase.lastModified.formatted(.relative(presentation: .named)))", systemImage: "clock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: CaseStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2), in: Capsule())
            .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch status {
        case .active: return .green
        case .review: return .orange
        case .complete: return .blue
        case .archived: return .gray
        case .onHold: return .yellow
        }
    }
}

// MARK: - New Case Sheet

struct NewCaseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var caseNumber = ""
    @State private var description = ""
    @State private var jurisdiction = "Federal"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Case Title", text: $title)
                TextField("Case Number", text: $caseNumber)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                Picker("Jurisdiction", selection: $jurisdiction) {
                    Text("Federal").tag("Federal")
                    Text("State").tag("State")
                    Text("International").tag("International")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createCase()
                    }
                    .disabled(title.isEmpty || caseNumber.isEmpty)
                }
            }
        }
    }

    private func createCase() {
        let newCase = LegalCase(
            caseNumber: caseNumber,
            title: title,
            description: description,
            jurisdiction: jurisdiction
        )

        modelContext.insert(newCase)
        dismiss()
    }
}

// MARK: - Case Detail View

struct CaseDetailView: View {
    let legalCase: LegalCase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(legalCase.title)
                        .font(.largeTitle)
                        .bold()

                    HStack {
                        Label(legalCase.caseNumber, systemImage: "number")
                        Divider().frame(height: 12)
                        Label(legalCase.jurisdiction, systemImage: "mappin.circle")
                        Divider().frame(height: 12)
                        StatusBadge(status: legalCase.status)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // Statistics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatBox(title: "Total Documents", value: "\(legalCase.totalDocuments)", icon: "doc.fill")
                    StatBox(title: "Reviewed", value: "\(Int(legalCase.reviewProgress * 100))%", icon: "checkmark.circle.fill")
                    StatBox(title: "Privileged", value: "\(legalCase.privilegedDocuments)", icon: "shield.fill")
                }

                Divider()

                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ActionButton(title: "Upload Documents", icon: "arrow.up.doc", action: {})
                        ActionButton(title: "Search Documents", icon: "magnifyingglass", action: {})
                        ActionButton(title: "View in 3D", icon: "cube.fill", action: {})
                        ActionButton(title: "Generate Timeline", icon: "calendar", action: {})
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Case Details")
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(value)
                .font(.title)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.caption)
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Extensions

extension CasePriority {
    var color: Color {
        switch self {
        case .low: return .gray
        case .normal: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

#Preview {
    CaseDashboardView()
        .environment(AppState())
        .modelContainer(for: [LegalCase.self], inMemory: true)
}
