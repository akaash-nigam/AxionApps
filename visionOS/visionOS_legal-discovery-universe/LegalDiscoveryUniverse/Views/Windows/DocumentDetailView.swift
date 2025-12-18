//
//  DocumentDetailView.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import SwiftUI
import SwiftData

struct DocumentDetailView: View {
    let documentId: UUID

    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @Query private var documents: [Document]

    private var document: Document? {
        documents.first { $0.id == documentId }
    }

    var body: some View {
        ScrollView {
            if let document {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    DocumentDetailHeader(document: document)

                    Divider()

                    // AI Analysis
                    if let analysis = document.aiAnalysis {
                        AIAnalysisView(analysis: analysis)
                        Divider()
                    }

                    // Document content
                    DocumentContentView(document: document)

                    // Action buttons
                    DocumentActionButtons(document: document)
                }
                .padding(24)
            } else {
                ContentUnavailableView(
                    "Document Not Found",
                    systemImage: "doc.questionmark",
                    description: Text("The requested document could not be loaded.")
                )
            }
        }
        .navigationTitle(document?.fileName ?? "Document")
    }
}

// MARK: - Document Detail Header

struct DocumentDetailHeader: View {
    let document: Document

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // File name and type
            HStack {
                Image(systemName: document.fileType.iconName)
                    .font(.title)
                    .foregroundStyle(document.statusColor)

                Text(document.fileName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                // Status badges
                if document.isKeyEvidence {
                    Badge(text: "Key Evidence", color: .blue, icon: "star.fill")
                }
                if document.isPrivileged {
                    Badge(text: "Privileged", color: .red, icon: "shield.fill")
                }
                if document.isRelevant {
                    Badge(text: "Relevant", color: .yellow, icon: "checkmark.circle.fill")
                }
            }

            // Metadata
            if let metadata = document.metadata {
                MetadataGrid(metadata: metadata)
            }

            // Stats
            HStack(spacing: 24) {
                StatItem(label: "Relevance", value: String(format: "%.0f%%", document.relevanceScore * 100))
                StatItem(label: "Privilege", value: document.privilegeStatus.rawValue.capitalized)
                StatItem(label: "Size", value: ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))
                if let date = document.documentDate {
                    StatItem(label: "Date", value: date.formatted(date: .abbreviated, time: .omitted))
                }
            }
            .font(.subheadline)
        }
    }
}

struct Badge: View {
    let text: String
    let color: Color
    let icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(8)
    }
}

struct MetadataGrid: View {
    let metadata: DocumentMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let from = metadata.from {
                MetadataRow(label: "From", value: from)
            }
            if !metadata.recipient.isEmpty {
                MetadataRow(label: "To", value: metadata.recipient.joined(separator: ", "))
            }
            if let subject = metadata.subject {
                MetadataRow(label: "Subject", value: subject)
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(.subheadline)
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - AI Analysis View

struct AIAnalysisView: View {
    let analysis: AIAnalysis
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("AI Analysis", systemImage: "brain")
                        .font(.headline)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Key insights
                    if !analysis.keyPhrases.isEmpty {
                        InsightSection(
                            title: "Key Phrases",
                            icon: "text.quote",
                            items: analysis.keyPhrases
                        )
                    }

                    if !analysis.entities.isEmpty {
                        InsightSection(
                            title: "Entities",
                            icon: "person.2.fill",
                            items: analysis.entities
                        )
                    }

                    if !analysis.topics.isEmpty {
                        InsightSection(
                            title: "Topics",
                            icon: "tag.fill",
                            items: analysis.topics
                        )
                    }

                    if let summary = analysis.summary {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Summary", systemImage: "text.alignleft")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(summary)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Sentiment
                    HStack {
                        Label("Sentiment", systemImage: "face.smiling")
                            .font(.subheadline)
                        Spacer()
                        SentimentIndicator(sentiment: analysis.sentiment)
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct InsightSection: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.medium)

            FlowLayout(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
    }
}

struct SentimentIndicator: View {
    let sentiment: Double

    var body: some View {
        HStack(spacing: 4) {
            if sentiment > 0.3 {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundStyle(.green)
            } else if sentiment < -0.3 {
                Image(systemName: "hand.thumbsdown.fill")
                    .foregroundStyle(.red)
            } else {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.secondary)
            }

            Text(sentiment > 0 ? "Positive" : sentiment < 0 ? "Negative" : "Neutral")
                .font(.caption)
        }
    }
}

// MARK: - Document Content

struct DocumentContentView: View {
    let document: Document

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Document Content", systemImage: "doc.text")
                .font(.headline)

            ScrollView {
                Text(document.extractedText.isEmpty ? "No text content available" : document.extractedText)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }
            .frame(minHeight: 400)
        }
    }
}

// MARK: - Action Buttons

struct DocumentActionButtons: View {
    let document: Document
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Button {
                markRelevant()
            } label: {
                Label("Mark Relevant", systemImage: "star.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(document.isRelevant)

            Button {
                markPrivileged()
            } label: {
                Label("Flag Privileged", systemImage: "shield.fill")
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .disabled(document.isPrivileged)

            Button {
                addTag()
            } label: {
                Label("Add Tag", systemImage: "tag.fill")
            }
            .buttonStyle(.bordered)

            Button {
                createConnection()
            } label: {
                Label("Connect", systemImage: "link")
            }
            .buttonStyle(.bordered)

            Spacer()

            Menu {
                Button("Export PDF", systemImage: "square.and.arrow.up") { }
                Button("Print", systemImage: "printer") { }
                Button("Share", systemImage: "square.and.arrow.up") { }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        .padding(.top, 12)
    }

    private func markRelevant() {
        document.isRelevant = true
        document.relevanceScore = max(document.relevanceScore, 0.8)
        try? modelContext.save()
    }

    private func markPrivileged() {
        document.isPrivileged = true
        document.privilegeStatus = .attorneyClient
        try? modelContext.save()
    }

    private func addTag() {
        // Show tag selection sheet
    }

    private func createConnection() {
        // Show connection interface
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    DocumentDetailView(documentId: UUID())
        .modelContainer(DataManager.shared.modelContainer)
        .environment(AppState())
}
