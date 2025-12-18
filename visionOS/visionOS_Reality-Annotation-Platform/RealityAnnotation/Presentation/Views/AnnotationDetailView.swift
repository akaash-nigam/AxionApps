//
//  AnnotationDetailView.swift
//  Reality Annotation Platform
//
//  Detail view for viewing and editing annotations
//

import SwiftUI
import SwiftData

struct AnnotationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    let annotation: Annotation

    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let annotationService: AnnotationService

    init(annotation: Annotation, annotationService: AnnotationService? = nil) {
        self.annotation = annotation
        self.annotationService = annotationService ?? ServiceContainer.shared.annotationService
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isEditing {
                    editModeContent
                } else {
                    viewModeContent
                }
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Edit Annotation" : "Annotation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isEditing {
                    Button("Save") {
                        Task {
                            await saveChanges()
                        }
                    }
                    .disabled(content.isEmpty || isSaving)
                } else {
                    Button("Edit") {
                        enterEditMode()
                    }
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                if isEditing {
                    Button("Cancel") {
                        cancelEditing()
                    }
                }
            }

            ToolbarItem(placement: .destructiveAction) {
                if !isEditing {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .alert("Delete Annotation?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAnnotation()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let message = errorMessage {
                Text(message)
            }
        }
        .onAppear {
            initializeEditState()
        }
    }

    // MARK: - View Mode Content

    @ViewBuilder
    private var viewModeContent: some View {
        // Header with type icon
        HStack {
            Image(systemName: annotation.type.icon)
                .font(.largeTitle)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(annotation.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let layer = annotation.layer {
                    Label(layer.name, systemImage: layer.icon)
                        .font(.caption)
                        .foregroundStyle(layer.color.swiftUIColor)
                }
            }

            Spacer()

            if annotation.isPendingSync {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.orange)
                    Text("Syncing")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)

        // Title
        if let annotationTitle = annotation.title, !annotationTitle.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(annotationTitle)
                    .font(.title2)
                    .bold()
            }
        }

        // Content
        VStack(alignment: .leading, spacing: 8) {
            Text("Content")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let annotationContent = annotation.contentText {
                Text(annotationContent)
                    .font(.body)
                    .textSelection(.enabled)
            } else {
                Text("No content")
                    .font(.body)
                    .foregroundStyle(.tertiary)
            }
        }

        Divider()

        // Metadata section
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)

            metadataRow(label: "Created", value: annotation.createdAt.formatted(date: .abbreviated, time: .shortened))
            metadataRow(label: "Modified", value: annotation.updatedAt.formatted(date: .abbreviated, time: .shortened))
            metadataRow(label: "Position", value: formatPosition(annotation.position))

            if annotation.lastSyncedAt != nil {
                metadataRow(
                    label: "Last Synced",
                    value: annotation.lastSyncedAt!.formatted(date: .abbreviated, time: .shortened)
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)

        // AR Actions
        VStack(spacing: 12) {
            Button {
                viewInAR()
            } label: {
                Label("View in AR", systemImage: "arkit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                shareAnnotation()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Edit Mode Content

    @ViewBuilder
    private var editModeContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title field
            VStack(alignment: .leading, spacing: 8) {
                Text("Title (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }

            // Content field
            VStack(alignment: .leading, spacing: 8) {
                Text("Content")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(.regularMaterial)
                    .cornerRadius(8)
            }

            if isSaving {
                ProgressView("Saving...")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Helper Views

    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }

    // MARK: - Actions

    private func initializeEditState() {
        title = annotation.title ?? ""
        content = annotation.contentText ?? ""
    }

    private func enterEditMode() {
        initializeEditState()
        isEditing = true
    }

    private func cancelEditing() {
        initializeEditState()
        isEditing = false
    }

    private func saveChanges() async {
        guard !content.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        do {
            // Update annotation
            annotation.title = title.isEmpty ? nil : title
            annotation.contentText = content
            annotation.updatedAt = Date()
            annotation.isPendingSync = true

            // Save via service
            try await annotationService.updateAnnotation(annotation)

            isEditing = false
            print("✅ Annotation updated: \(annotation.id)")
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            print("❌ Failed to update annotation: \(error)")
        }

        isSaving = false
    }

    private func deleteAnnotation() async {
        do {
            // Delete via service
            try await annotationService.deleteAnnotation(id: annotation.id)

            print("✅ Annotation deleted: \(annotation.id)")
            dismiss()
        } catch {
            errorMessage = "Failed to delete annotation: \(error.localizedDescription)"
            print("❌ Failed to delete annotation: \(error)")
        }
    }

    private func viewInAR() {
        // Switch to AR mode and focus on this annotation
        appState.isImmersiveSpaceActive = true
        // TODO: Add focus/navigate to annotation logic
        print("🎯 View in AR: \(annotation.id)")
    }

    private func shareAnnotation() {
        // TODO: Implement sharing
        print("📤 Share annotation: \(annotation.id)")
    }

    // MARK: - Helper Methods

    private func formatPosition(_ position: SIMD3<Float>) -> String {
        return String(format: "%.2f, %.2f, %.2f", position.x, position.y, position.z)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AnnotationDetailView(
            annotation: Annotation(
                type: .text,
                title: "Sample Annotation",
                contentText: "This is a sample annotation for preview purposes.",
                position: SIMD3(0, 1, -2),
                layerID: UUID(),
                ownerID: "preview-user"
            )
        )
    }
    .environmentObject(AppState.shared)
}
