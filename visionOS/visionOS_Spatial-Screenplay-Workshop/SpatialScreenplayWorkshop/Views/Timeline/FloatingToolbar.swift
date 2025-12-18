//
//  FloatingToolbar.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI

/// Floating toolbar for quick actions on selected scene in timeline
struct FloatingToolbar: View {
    let scene: Scene
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onMoveToAct: (Int) -> Void

    @State private var showDeleteConfirmation = false
    @State private var showActPicker = false

    var body: some View {
        HStack(spacing: 16) {
            // Edit button
            ToolbarButton(
                icon: "pencil",
                label: "Edit",
                action: onEdit
            )
            .keyboardShortcut("e", modifiers: .command)

            Divider()
                .frame(height: 30)

            // Duplicate button
            ToolbarButton(
                icon: "plus.square.on.square",
                label: "Duplicate",
                action: onDuplicate
            )
            .keyboardShortcut("d", modifiers: .command)

            // Move to act
            Menu {
                Button("Move to Act I") {
                    onMoveToAct(1)
                }
                Button("Move to Act II") {
                    onMoveToAct(2)
                }
                Button("Move to Act III") {
                    onMoveToAct(3)
                }
            } label: {
                ToolbarButton(
                    icon: "arrow.up.arrow.down",
                    label: "Move",
                    action: { }
                )
            }

            Divider()
                .frame(height: 30)

            // Delete button
            ToolbarButton(
                icon: "trash",
                label: "Delete",
                color: .red,
                action: { showDeleteConfirmation = true }
            )
            .keyboardShortcut(.delete, modifiers: [])
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .confirmationDialog(
            "Delete Scene \(scene.sceneNumber)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone. The scene will be permanently deleted.")
        }
    }
}

// MARK: - Toolbar Button

struct ToolbarButton: View {
    let icon: String
    let label: String
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)

                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(color)
            .frame(minWidth: 60)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

// MARK: - Floating Toolbar Container

/// Container that positions floating toolbar near selected card
struct FloatingToolbarContainer: View {
    @Binding var selectedScene: Scene?
    let viewModel: TimelineViewModel

    var body: some View {
        GeometryReader { geometry in
            if let scene = selectedScene {
                FloatingToolbar(
                    scene: scene,
                    onEdit: {
                        viewModel.openEditor(for: scene)
                    },
                    onDuplicate: {
                        viewModel.duplicateScene(scene)
                    },
                    onDelete: {
                        viewModel.deleteScene(scene)
                        selectedScene = nil
                    },
                    onMoveToAct: { act in
                        moveSceneToAct(scene, act: act)
                    }
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height - 100  // 100pt from bottom
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3), value: selectedScene?.id)
            }
        }
    }

    private func moveSceneToAct(_ scene: Scene, act: Int) {
        // Update scene position
        scene.position.act = act

        // Trigger re-layout
        if let project = viewModel.appState?.currentProject {
            viewModel.timelineContainer?.loadScenes(from: project)
        }

        // Save changes
        Task {
            try? await viewModel.appState?.saveCurrentProject()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        FloatingToolbar(
            scene: Scene.sampleScenes()[0],
            onEdit: { print("Edit") },
            onDuplicate: { print("Duplicate") },
            onDelete: { print("Delete") },
            onMoveToAct: { act in print("Move to Act \(act)") }
        )
    }
}
