import SwiftUI

struct CrimeSceneHUD: View {
    let evidenceCount: Int
    let totalEvidence: Int
    let progress: Float
    @Binding var activeTool: ForensicToolType

    @State private var showToolBelt = true
    @State private var showNotes = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Top bar
            HStack {
                // Evidence progress
                evidenceProgressView

                Spacer()

                // Case progress
                caseProgressView
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding()

            // Tool belt (right side)
            VStack {
                Spacer()

                if showToolBelt {
                    ToolBeltView(activeTool: $activeTool)
                        .transition(.move(edge: .trailing))
                }
            }

            // Quick notes (left side)
            VStack {
                Spacer()

                if showNotes {
                    QuickNotesView()
                        .transition(.move(edge: .leading))
                }
            }

            // Contextual hints (bottom center)
            VStack {
                Spacer()

                contextualHintView
            }
        }
    }

    // MARK: - Components

    private var evidenceProgressView: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title2)
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Evidence")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(evidenceCount)/\(totalEvidence)")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }

    private var caseProgressView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Case Progress")
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: progress, total: 1.0)
                .tint(.green)
                .frame(width: 150)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var contextualHintView: some View {
        Group {
            if evidenceCount == 0 {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Look around to discover evidence")
                        .font(.callout)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Tool Belt View

struct ToolBeltView: View {
    @Binding var activeTool: ForensicToolType

    private let availableTools: [ForensicToolType] = [
        .magnifyingGlass,
        .cameraEvidence,
        .fingerprintKit,
        .uvLight,
        .notepad
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(availableTools, id: \.self) { tool in
                ToolButton(
                    tool: tool,
                    isActive: activeTool == tool
                ) {
                    activeTool = tool
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .padding(.trailing)
    }
}

struct ToolButton: View {
    let tool: ForensicToolType
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .yellow : .white)

                Text(tool.displayName.split(separator: " ").first.map(String.init) ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60, height: 60)
            .background(isActive ? Color.yellow.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Notes View

struct QuickNotesView: View {
    @State private var notes: [String] = []
    @State private var newNote = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Notes")
                .font(.headline)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(notes, id: \.self) { note in
                        Text("• \(note)")
                            .font(.callout)
                            .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 200)

            Divider()

            HStack {
                TextField("Add note...", text: $newNote)
                    .textFieldStyle(.roundedBorder)

                Button(action: addNote) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .disabled(newNote.isEmpty)
            }
            .padding(.horizontal)
        }
        .frame(width: 300)
        .padding(.vertical)
        .background(.regularMaterial)
        .cornerRadius(16)
        .padding(.leading)
    }

    private func addNote() {
        guard !newNote.isEmpty else { return }
        notes.append(newNote)
        newNote = ""
    }
}

// MARK: - Preview

#Preview {
    CrimeSceneHUD(
        evidenceCount: 3,
        totalEvidence: 8,
        progress: 0.4,
        activeTool: .constant(.magnifyingGlass)
    )
}
