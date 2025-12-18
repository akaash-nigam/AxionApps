//
//  DocumentViewerView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import PDFKit
import SwiftData

struct DocumentViewerView: View {
    let documentID: UUID

    @Environment(\.modelContext) private var modelContext
    @Query private var documents: [LegalDocument]

    @State private var currentPage: Int = 0
    @State private var showingAnnotations = true

    var body: some View {
        Group {
            if let document = documents.first(where: { $0.id == documentID }) {
                documentContent(for: document)
            } else {
                ContentUnavailableView(
                    "Document Not Found",
                    systemImage: "doc.questionmark",
                    description: Text("The requested document could not be found")
                )
            }
        }
        .navigationTitle("Document Viewer")
    }

    @ViewBuilder
    private func documentContent(for document: LegalDocument) -> some View {
        VStack(spacing: 0) {
            // Header
            documentHeader(for: document)

            Divider()

            // Document content (placeholder - would use PDFKit in real implementation)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Document metadata
                    metadataSection(for: document)

                    Divider()

                    // Content preview
                    Text(document.extractedText.isEmpty ? "No text extracted" : document.extractedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }

            Divider()

            // Annotations panel
            if showingAnnotations {
                annotationsPanel(for: document)
            }
        }
    }

    private func documentHeader(for document: LegalDocument) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(document.title)
                        .font(.title2)
                        .bold()

                    HStack(spacing: 12) {
                        Label(document.fileType.rawValue, systemImage: document.fileType.iconName)
                        Label("\(document.pageCount) pages", systemImage: "doc.text")
                        Label(document.formattedFileSize, systemImage: "internaldrive")

                        if document.isPrivileged {
                            Label("Privileged", systemImage: "shield.fill")
                                .foregroundStyle(.red)
                        }

                        if document.isKeyEvidence {
                            Label("Key Evidence", systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Relevance score
                RelevanceIndicator(score: document.relevanceScore)
            }

            // Action buttons
            HStack {
                Button("Mark Relevant") {
                    document.markRelevant(score: 0.9)
                }
                .buttonStyle(.bordered)

                Button("Flag Privileged") {
                    document.markPrivileged(type: .attorneyClient, basis: "Communication with client")
                }
                .buttonStyle(.bordered)

                Button("Key Evidence") {
                    document.flagAsKeyEvidence()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Export") {
                    // Export action
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private func metadataSection(for document: LegalDocument) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            GridRow {
                Text("Author:")
                    .foregroundStyle(.secondary)
                Text(document.author ?? "Unknown")
            }

            GridRow {
                Text("Created:")
                    .foregroundStyle(.secondary)
                Text(document.createdDate?.formatted() ?? "Unknown")
            }

            GridRow {
                Text("Uploaded:")
                    .foregroundStyle(.secondary)
                Text(document.uploadDate.formatted())
            }

            if document.reviewedBy != nil {
                GridRow {
                    Text("Reviewed by:")
                        .foregroundStyle(.secondary)
                    Text(document.reviewedBy ?? "")
                }
            }

            GridRow {
                Text("AI Tags:")
                    .foregroundStyle(.secondary)
                Text(document.aiTags.joined(separator: ", "))
            }
        }
        .font(.caption)
    }

    private func annotationsPanel(for document: LegalDocument) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Annotations (\(document.annotations.count))")
                    .font(.headline)

                Spacer()

                Button {
                    showingAnnotations.toggle()
                } label: {
                    Image(systemName: "chevron.down")
                }
            }

            if document.annotations.isEmpty {
                Text("No annotations yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(document.annotations) { annotation in
                    AnnotationRow(annotation: annotation)
                }
            }
        }
        .padding()
        .frame(height: 200)
        .background(.ultraThinMaterial)
    }
}

struct RelevanceIndicator: View {
    let score: Double

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(score * 100))%")
                .font(.title2)
                .bold()
                .foregroundStyle(relevanceColor)

            Text("Relevance")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ProgressView(value: score)
                .tint(relevanceColor)
                .frame(width: 80)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var relevanceColor: Color {
        switch score {
        case 0.9...1.0: return .red
        case 0.7..<0.9: return .orange
        case 0.5..<0.7: return .yellow
        case 0.3..<0.5: return .blue
        default: return .gray
        }
    }
}

struct AnnotationRow: View {
    let annotation: Annotation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: annotation.annotationType.iconName)
                .foregroundStyle(Color(annotation.annotationType.defaultColor))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(annotation.createdBy)
                        .font(.caption)
                        .bold()

                    Text("• \(annotation.createdDate.formatted(.relative(presentation: .named)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(annotation.content)
                    .font(.caption)

                if annotation.replyCount > 0 {
                    Text("\(annotation.replyCount) replies")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            if annotation.isResolved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    DocumentViewerView(documentID: UUID())
        .modelContainer(for: [LegalDocument.self], inMemory: true)
}
