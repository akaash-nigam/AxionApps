//
//  LayerListView.swift
//  Reality Annotation Platform
//
//  Layer management view
//

import SwiftUI
import SwiftData

struct LayerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Layer.name) private var layers: [Layer]
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                if layers.isEmpty {
                    ContentUnavailableView(
                        "No Layers",
                        systemImage: "square.stack",
                        description: Text("Layers help organize your annotations")
                    )
                } else {
                    ForEach(layers.filter { !$0.isDeleted }) { layer in
                        LayerRow(layer: layer)
                    }
                }
            }
            .navigationTitle("Layers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createDefaultLayer()
                    } label: {
                        Label("Create Layer", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func createDefaultLayer() {
        // Create default layer for MVP
        let layer = Layer(
            name: "My Notes",
            icon: "note.text",
            color: .blue,
            ownerID: "current-user" // TODO: Get from auth
        )
        modelContext.insert(layer)
        try? modelContext.save()
    }
}

// MARK: - Layer Row

struct LayerRow: View {
    let layer: Layer
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack {
            // Visibility toggle
            Button {
                appState.toggleLayer(layer.id)
            } label: {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundStyle(layer.isVisible ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            // Layer info
            Image(systemName: layer.icon)
                .foregroundStyle(layer.color.swiftUIColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(layer.name)
                    .font(.headline)

                Text("\(layer.annotationCount) annotations")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    LayerListView()
        .environmentObject(AppState.shared)
}
