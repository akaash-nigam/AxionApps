//
//  DiscoveryWorkspaceView.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import SwiftUI
import SwiftData

struct DiscoveryWorkspaceView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @Query(sort: \LegalCase.lastModified, order: .reverse)
    private var cases: [LegalCase]

    @Query(sort: \Document.relevanceScore, order: .reverse)
    private var documents: [Document]

    @State private var searchText = ""
    @State private var selectedDocument: Document?

    var body: some View {
        NavigationSplitView {
            // Sidebar: Cases
            CaseListView(cases: cases)
        } detail: {
            // Main content: Documents
            VStack(spacing: 0) {
                // Header with case info
                if let activeCase = appState.activeCase {
                    CaseHeaderView(case: activeCase)
                }

                // Search and filters
                SearchFilterBar(searchText: $searchText)

                // Document list
                DocumentListView(
                    documents: filteredDocuments,
                    selectedDocument: $selectedDocument
                )
            }
        }
        .navigationTitle("Discovery Workspace")
    }

    private var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return documents
        }
        return documents.filter { document in
            document.fileName.localizedCaseInsensitiveContains(searchText) ||
            document.extractedText.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Case List View

struct CaseListView: View {
    let cases: [LegalCase]
    @Environment(AppState.self) private var appState

    var body: some View {
        List(cases) { caseItem in
            CaseRowView(case: caseItem)
                .onTapGesture {
                    appState.activeCase = caseItem
                }
        }
        .navigationTitle("Cases")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Create new case
                } label: {
                    Label("New Case", systemImage: "plus")
                }
            }
        }
    }
}

struct CaseRowView: View {
    let `case`: LegalCase

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(case.title)
                .font(.headline)

            Text(case.caseNumber)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label("\(case.documentCount)", systemImage: "doc.fill")
                Label("\(case.relevantDocumentCount)", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Case Header

struct CaseHeaderView: View {
    let `case`: LegalCase

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(case.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(case.caseNumber) • \(case.status.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    StatView(
                        value: "\(case.documentCount)",
                        label: "Documents"
                    )
                    StatView(
                        value: "\(case.relevantDocumentCount)",
                        label: "Relevant"
                    )
                    StatView(
                        value: "\(Int(case.reviewProgress * 100))%",
                        label: "Reviewed"
                    )
                }
                .font(.caption)
            }

            Spacer()

            Button {
                // Open case settings
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}

struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Search and Filter Bar

struct SearchFilterBar: View {
    @Binding var searchText: String

    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search documents...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.regularMaterial)
            .cornerRadius(8)

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Relevant", icon: "star.fill", isActive: false)
                    FilterChip(title: "Privileged", icon: "shield.fill", isActive: false)
                    FilterChip(title: "Key Evidence", icon: "key.fill", isActive: false)
                    FilterChip(title: "Reviewed", icon: "checkmark.circle.fill", isActive: false)
                }
            }
        }
        .padding()
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isActive: Bool

    var body: some View {
        Label(title, systemImage: icon)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Color.blue : Color.secondary.opacity(0.2))
            .foregroundStyle(isActive ? .white : .primary)
            .cornerRadius(16)
    }
}

// MARK: - Document List

struct DocumentListView: View {
    let documents: [Document]
    @Binding var selectedDocument: Document?
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        List(documents) { document in
            DocumentRowView(document: document)
                .onTapGesture {
                    selectedDocument = document
                    openWindow(id: "document-detail", value: document.id)
                }
        }
        .listStyle(.plain)
    }
}

struct DocumentRowView: View {
    let document: Document

    var body: some View {
        HStack(spacing: 12) {
            // File type icon
            Image(systemName: document.fileType.iconName)
                .font(.title2)
                .foregroundStyle(document.statusColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                // File name
                Text(document.fileName)
                    .font(.headline)

                // Metadata
                if let metadata = document.metadata {
                    if let from = metadata.from, let subject = metadata.subject {
                        Text("\(from) • \(subject)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                // Stats
                HStack(spacing: 12) {
                    if let date = document.documentDate {
                        Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    }

                    Label(String(format: "%.0f%%", document.relevanceScore * 100), systemImage: "chart.bar.fill")

                    if document.privilegeStatus != .notPrivileged {
                        Label(document.privilegeStatus.rawValue, systemImage: "shield.fill")
                            .foregroundStyle(.red)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Status badges
            VStack(alignment: .trailing, spacing: 4) {
                if document.isKeyEvidence {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                if document.isPrivileged {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(.red)
                }
                if document.isRelevant {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Extensions

extension FileType {
    var iconName: String {
        switch self {
        case .email: return "envelope.fill"
        case .pdf: return "doc.fill"
        case .word: return "doc.text.fill"
        case .excel: return "tablecells.fill"
        case .image: return "photo.fill"
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .other: return "doc"
        }
    }
}

extension Document {
    var statusColor: Color {
        if isKeyEvidence { return .blue }
        if isPrivileged { return .red }
        if isRelevant { return .yellow }
        return .secondary
    }
}

#Preview {
    DiscoveryWorkspaceView()
        .environment(AppState())
        .modelContainer(DataManager.shared.modelContainer)
}
