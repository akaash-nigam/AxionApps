//
//  CreateAnnotationView.swift
//  Reality Annotation Platform
//
//  Form for creating annotations from 2D UI
//

import SwiftUI

struct CreateAnnotationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var creationMode: CreationMode = .withAR
    @State private var isCreating = false
    @State private var errorMessage: String?

    private let annotationService: AnnotationService
    private let layerService: LayerService

    enum CreationMode: String, CaseIterable {
        case withAR = "Place in AR"
        case withoutAR = "Add without position"

        var icon: String {
            switch self {
            case .withAR: return "arkit"
            case .withoutAR: return "note.text.badge.plus"
            }
        }

        var description: String {
            switch self {
            case .withAR: return "Enter AR mode to place annotation in space"
            case .withoutAR: return "Create annotation without spatial position"
            }
        }
    }

    init(annotationService: AnnotationService? = nil, layerService: LayerService? = nil) {
        let container = ServiceContainer.shared
        self.annotationService = annotationService ?? container.annotationService
        self.layerService = layerService ?? container.layerService
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Title field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title (optional)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter title", text: $title)
                    }

                    // Content field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                    }
                } header: {
                    Text("Annotation Details")
                }

                Section {
                    Picker("Creation Mode", selection: $creationMode) {
                        ForEach(CreationMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.inline)

                    Text(creationMode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Placement")
                } footer: {
                    if creationMode == .withoutAR {
                        Text("Annotations without spatial position can be viewed in the list but won't appear in AR mode.")
                            .font(.caption)
                    }
                }

                if isCreating {
                    Section {
                        ProgressView("Creating...")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("New Annotation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        Task {
                            await createAnnotation()
                        }
                    }
                    .disabled(content.isEmpty || isCreating)
                }
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
        }
    }

    // MARK: - Actions

    private func createAnnotation() async {
        guard !content.isEmpty else { return }

        isCreating = true
        errorMessage = nil

        do {
            // Get default layer
            let layer = try await layerService.getOrCreateDefaultLayer()

            if creationMode == .withAR {
                // Switch to AR mode and prepare for placement
                dismiss()
                appState.isImmersiveSpaceActive = true
                // Store pending annotation data in AppState
                // TODO: Add pending annotation to AppState
                print("📍 Switching to AR mode for placement")
            } else {
                // Create annotation at default position (0, 0, 0)
                let defaultPosition = SIMD3<Float>(0, 0, 0)

                let annotation = try await annotationService.createAnnotation(
                    content: content,
                    title: title.isEmpty ? nil : title,
                    type: .text,
                    position: defaultPosition,
                    layerID: layer.id
                )

                print("✅ Created annotation without AR: \(annotation.id)")
                dismiss()
            }
        } catch {
            errorMessage = "Failed to create annotation: \(error.localizedDescription)"
            print("❌ Failed to create annotation: \(error)")
            isCreating = false
        }
    }
}

// MARK: - Preview

#Preview {
    CreateAnnotationView()
        .environmentObject(AppState.shared)
}
