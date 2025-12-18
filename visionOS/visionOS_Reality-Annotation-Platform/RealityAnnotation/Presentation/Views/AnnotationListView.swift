//
//  AnnotationListView.swift
//  Reality Annotation Platform
//
//  List view of all annotations
//

import SwiftUI
import SwiftData

struct AnnotationListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query(sort: \Annotation.createdAt, order: .reverse) private var annotations: [Annotation]

    @State private var showCreateSheet = false
    @State private var sortOrder: SortOrder = .dateDescending

    enum SortOrder: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case title = "Title"
    }

    var sortedAnnotations: [Annotation] {
        let filtered = annotations.filter { !$0.isDeleted }
        switch sortOrder {
        case .dateDescending:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .dateAscending:
            return filtered.sorted { $0.createdAt < $1.createdAt }
        case .title:
            return filtered.sorted { ($0.title ?? $0.contentText ?? "") < ($1.title ?? $1.contentText ?? "") }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if sortedAnnotations.isEmpty {
                    ContentUnavailableView(
                        "No Annotations",
                        systemImage: "note.text",
                        description: Text("Create your first annotation")
                    )
                } else {
                    ForEach(sortedAnnotations) { annotation in
                        NavigationLink(destination: AnnotationDetailView(annotation: annotation)) {
                            AnnotationRow(annotation: annotation)
                        }
                    }
                }
            }
            .navigationTitle("Annotations (\(sortedAnnotations.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Label("Create", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateAnnotationView()
            }
        }
    }
}

// MARK: - Annotation Row

struct AnnotationRow: View {
    let annotation: Annotation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Type icon
                Image(systemName: annotation.type.icon)
                    .font(.title3)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    if let title = annotation.title {
                        Text(title)
                            .font(.headline)
                    }

                    if let content = annotation.contentText {
                        Text(content)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Sync status indicator
                if annotation.isPendingSync {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            // Metadata
            HStack {
                Text(annotation.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let layer = annotation.layer {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Label(layer.name, systemImage: layer.icon)
                        .font(.caption)
                        .foregroundStyle(layer.color.swiftUIColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    AnnotationListView()
}
