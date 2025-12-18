//
//  SceneMetadataPanel.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI

/// Side panel for editing scene metadata
struct SceneMetadataPanel: View {
    @Binding var scene: Scene
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section("Scene Info") {
                    LabeledContent("Scene Number") {
                        Text("\(scene.sceneNumber)")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Page Length") {
                        Text(String(format: "%.2f pages", scene.pageLength))
                            .foregroundStyle(.secondary)
                    }
                }

                // Slug Line Section
                Section("Scene Heading") {
                    Picker("Setting", selection: $scene.slugLine.setting) {
                        ForEach(Setting.allCases, id: \.self) { setting in
                            Text(setting.rawValue).tag(setting)
                        }
                    }

                    TextField("Location", text: $scene.slugLine.location)
                        .textInputAutocapitalization(.characters)

                    Picker("Time of Day", selection: $scene.slugLine.timeOfDay) {
                        ForEach(TimeOfDay.allCases, id: \.self) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                }

                // Metadata Section
                Section("Details") {
                    TextField("Summary", text: Binding(
                        get: { scene.metadata.summary ?? "" },
                        set: { scene.metadata.summary = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                    .lineLimit(3...6)

                    TextField("Mood", text: Binding(
                        get: { scene.metadata.mood ?? "" },
                        set: { scene.metadata.mood = $0.isEmpty ? nil : $0 }
                    ))

                    TextField("Story Thread", text: Binding(
                        get: { scene.metadata.storyThread ?? "" },
                        set: { scene.metadata.storyThread = $0.isEmpty ? nil : $0 }
                    ))

                    Picker("Importance", selection: $scene.metadata.importance) {
                        ForEach(SceneImportance.allCases, id: \.self) { importance in
                            Text(importance.rawValue).tag(importance)
                        }
                    }
                }

                // Status Section
                Section("Status") {
                    Picker("Status", selection: $scene.status) {
                        ForEach(SceneStatus.allCases, id: \.self) { status in
                            HStack {
                                Image(systemName: status.icon)
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Position Section
                Section("Structure") {
                    Stepper("Act \(scene.position.act)", value: $scene.position.act, in: 1...5)

                    if let sequence = scene.position.sequence {
                        Stepper("Sequence \(sequence)", value: Binding(
                            get: { scene.position.sequence ?? 1 },
                            set: { scene.position.sequence = $0 }
                        ), in: 1...10)
                    }
                }

                // Characters Section
                Section("Characters") {
                    if let characters = scene.characters, !characters.isEmpty {
                        ForEach(characters) { character in
                            HStack {
                                Circle()
                                    .fill(Color(hex: character.color))
                                    .frame(width: 8, height: 8)
                                Text(character.name)
                                    .font(.body)
                            }
                        }
                    } else {
                        Text("No characters assigned")
                            .foregroundStyle(.secondary)
                    }
                }

                // Statistics Section
                Section("Statistics") {
                    LabeledContent("Word Count") {
                        Text("\(scene.wordCount)")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Est. Duration") {
                        Text(formatDuration(scene.estimatedDuration))
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Created") {
                        Text(scene.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Modified") {
                        Text(scene.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }

                // Notes Section
                Section("Notes") {
                    if scene.notes.isEmpty {
                        Button {
                            addNote()
                        } label: {
                            Label("Add Note", systemImage: "plus.circle")
                        }
                    } else {
                        ForEach(scene.notes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.text)
                                    .font(.body)

                                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            scene.notes.remove(atOffsets: indexSet)
                        }

                        Button {
                            addNote()
                        } label: {
                            Label("Add Note", systemImage: "plus.circle")
                        }
                    }
                }
            }
            .navigationTitle("Scene Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        scene.touch()
                        dismiss()
                    }
                }
            }
        }
    }

    private func addNote() {
        let note = Note(text: "New note")
        scene.notes.append(note)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(seconds)s"
    }
}

// MARK: - Metadata Quick View

/// Compact metadata view for toolbar
struct SceneMetadataQuickView: View {
    let scene: Scene

    var body: some View {
        HStack(spacing: 16) {
            // Status badge
            HStack(spacing: 4) {
                Image(systemName: scene.status.icon)
                    .font(.caption)
                Text(scene.status.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: scene.status.color).opacity(0.2))
            .foregroundStyle(Color(hex: scene.status.color))
            .cornerRadius(4)

            // Act indicator
            Text(scene.position.actName)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Importance
            if scene.metadata.importance == .critical {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SceneMetadataPanel(scene: .constant(Scene.sampleScenes()[0]))
}
