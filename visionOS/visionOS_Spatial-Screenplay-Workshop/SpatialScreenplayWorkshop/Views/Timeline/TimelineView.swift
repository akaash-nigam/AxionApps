//
//  TimelineView.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI

/// Main timeline view with 3D scene cards
struct TimelineView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: TimelineViewModel

    init() {
        _viewModel = State(initialValue: TimelineViewModel())
    }

    var body: some View {
        ZStack {
            // 3D Timeline view
            TimelineRealityView(viewModel: viewModel)
                .ignoresSafeArea()

            // Overlay UI
            VStack {
                // Top toolbar
                TimelineToolbar(viewModel: viewModel)
                    .padding()

                Spacer()

                // Bottom controls
                if let selectedScene = viewModel.selectedScene {
                    SceneDetailsPanel(scene: selectedScene)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding()
                }
            }

            // Floating toolbar for selected scene
            FloatingToolbarContainer(
                selectedScene: $viewModel.selectedScene,
                viewModel: viewModel
            )
        }
        .onAppear {
            viewModel.setup(appState: appState)
        }
    }
}

// MARK: - Timeline Toolbar

struct TimelineToolbar: View {
    @Bindable var viewModel: TimelineViewModel

    var body: some View {
        HStack(spacing: 16) {
            // View mode
            Picker("View", selection: $viewModel.viewMode) {
                Text("By Act").tag(TimelineViewMode.byAct)
                Text("Linear").tag(TimelineViewMode.linear)
                Text("Grid").tag(TimelineViewMode.grid)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)

            Spacer()

            // Add scene button
            Button {
                viewModel.addNewScene()
            } label: {
                Label("Add Scene", systemImage: "plus.circle")
            }
            .buttonStyle(.borderedProminent)

            // Filter
            Menu {
                Button("All Scenes") {
                    viewModel.filterStatus = nil
                }

                Divider()

                ForEach(SceneStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) {
                        viewModel.filterStatus = status
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Scene Details Panel

struct SceneDetailsPanel: View {
    let scene: Scene

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Scene header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scene \(scene.sceneNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(scene.slugLine.formatted)
                        .font(.headline)
                }

                Spacer()

                // Status badge
                Text(scene.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(scene.status).opacity(0.2))
                    .foregroundStyle(statusColor(scene.status))
                    .cornerRadius(4)
            }

            Divider()

            // Stats
            HStack(spacing: 20) {
                Label("\(String(format: "%.2f", scene.pageLength)) pages", systemImage: "doc.text")

                if let characters = scene.characters, !characters.isEmpty {
                    Label("\(characters.count) characters", systemImage: "person.2")
                }

                if let act = scene.position.act {
                    Label("Act \(act)", systemImage: "book")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // Summary if available
            if let summary = scene.metadata.summary, !summary.isEmpty {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: 500)
    }

    private func statusColor(_ status: SceneStatus) -> Color {
        switch status {
        case .draft:
            return Color(hex: "FFE5B4")
        case .revision:
            return Color(hex: "FFD700")
        case .locked:
            return Color(hex: "90EE90")
        case .final:
            return Color(hex: "87CEEB")
        }
    }
}

// MARK: - View Mode

enum TimelineViewMode {
    case byAct      // Organized by acts (3D depth)
    case linear     // Linear sequence (2D)
    case grid       // Grid layout (2D)
}

// MARK: - Preview

#Preview {
    TimelineView()
        .environment(AppState.preview)
}
