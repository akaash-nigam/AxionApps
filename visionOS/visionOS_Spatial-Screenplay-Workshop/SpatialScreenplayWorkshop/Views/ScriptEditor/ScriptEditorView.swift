//
//  ScriptEditorView.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI

struct ScriptEditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: ScriptEditorViewModel
    @State private var showingMetadataPanel = false
    @State private var showAutoComplete = false
    @State private var autoCompleteSearchText = ""

    init(scene: Scene) {
        _viewModel = State(initialValue: ScriptEditorViewModel(scene: scene))
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Toolbar
                EditorToolbar(
                    viewModel: viewModel,
                    onUndo: { viewModel.undo() },
                    onRedo: { viewModel.redo() },
                    onShowMetadata: { showingMetadataPanel = true }
                )

                Divider()

                // Editor
                ScrollView {
                    TextEditor(text: $viewModel.scriptText)
                        .font(.custom("Courier", size: 14))
                        .lineSpacing(12)
                        .padding()
                        .frame(minHeight: 600)
                        .onChange(of: viewModel.scriptText) { oldValue, newValue in
                            viewModel.handleTextChange(oldValue: oldValue, newValue: newValue)
                            appState.markChanged()

                            // Check for character auto-complete trigger
                            checkAutoComplete(newValue)
                        }
                }

                Divider()

                // Status bar
                StatusBar(viewModel: viewModel)
            }

            // Character auto-complete overlay
            if showAutoComplete {
                VStack {
                    Spacer()
                        .frame(height: 100)  // Position below toolbar

                    CharacterAutoComplete(
                        characters: viewModel.availableCharacters,
                        searchText: autoCompleteSearchText,
                        onSelect: { characterName in
                            viewModel.insertCharacterName(characterName)
                            showAutoComplete = false
                            autoCompleteSearchText = ""
                        }
                    )
                    .frame(maxWidth: 400)
                    .padding()

                    Spacer()
                }
            }
        }
        .navigationTitle(viewModel.scene.formattedSlugLine)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    Task {
                        await save()
                    }
                }
            }
        }
        .sheet(isPresented: $showingMetadataPanel) {
            SceneMetadataPanel(scene: $viewModel.scene)
        }
        .onAppear {
            viewModel.loadSceneContent()
            viewModel.loadAvailableCharacters(from: appState.currentProject)
        }
        .onDisappear {
            Task {
                await save()
            }
        }
    }

    private func save() async {
        viewModel.updateSceneFromText()
        try? await appState.saveCurrentProject()
    }

    private func checkAutoComplete(_ text: String) {
        // Get current line
        let lines = text.components(separatedBy: .newlines)
        guard let currentLine = lines.last, !currentLine.isEmpty else {
            showAutoComplete = false
            return
        }

        let trimmed = currentLine.trimmingCharacters(in: .whitespaces)

        // Check if line looks like a character name (all caps, no special chars)
        let isAllCaps = trimmed == trimmed.uppercased()
        let hasNoSpecialChars = !trimmed.contains("(") && !trimmed.contains(".")

        if isAllCaps && hasNoSpecialChars && trimmed.count >= 2 {
            autoCompleteSearchText = trimmed
            showAutoComplete = true
        } else {
            showAutoComplete = false
        }
    }
}

// MARK: - Editor Toolbar

struct EditorToolbar: View {
    @Bindable var viewModel: ScriptEditorViewModel
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onShowMetadata: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            // Undo/Redo buttons
            HStack(spacing: 8) {
                Button {
                    onUndo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!viewModel.canUndo)
                .keyboardShortcut("z", modifiers: .command)

                Button {
                    onRedo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!viewModel.canRedo)
                .keyboardShortcut("z", modifiers: [.command, .shift])
            }

            Divider()
                .frame(height: 20)

            // Element type indicator
            Text(viewModel.currentElementType)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)

            Spacer()

            // Scene navigation
            HStack(spacing: 8) {
                Button {
                    viewModel.previousScene()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.hasPreviousScene)

                Text("Scene \(viewModel.scene.sceneNumber)")
                    .font(.headline)

                Button {
                    viewModel.nextScene()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.hasNextScene)
            }

            Spacer()

            // Statistics
            HStack(spacing: 16) {
                Label("\(viewModel.formattedPageCount)", systemImage: "doc.text")
                    .font(.caption)

                Label("\(viewModel.wordCount)", systemImage: "textformat.abc")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Divider()
                .frame(height: 20)

            // Metadata button
            Button {
                onShowMetadata()
            } label: {
                Image(systemName: "info.circle")
            }
            .keyboardShortcut("i", modifiers: .command)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
    }
}

// MARK: - Status Bar

struct StatusBar: View {
    @Bindable var viewModel: ScriptEditorViewModel

    var body: some View {
        HStack {
            // Auto-save status
            HStack(spacing: 4) {
                if viewModel.isSaving {
                    ProgressView()
                        .scaleEffect(0.7)
                }
                Text(viewModel.saveStatus)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Current position
            Text("Line \(viewModel.currentLine) of \(viewModel.totalLines)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground).opacity(0.9))
    }
}

// MARK: - View Model

@Observable
final class ScriptEditorViewModel {
    var scene: Scene
    var scriptText: String = ""
    var currentElementType: String = "Action"
    var isSaving: Bool = false
    var saveStatus: String = "Not saved"

    // Navigation
    var hasPreviousScene: Bool = false
    var hasNextScene: Bool = false

    // Statistics
    var wordCount: Int = 0
    var formattedPageCount: String = "0.0"
    var currentLine: Int = 1
    var totalLines: Int = 1

    // Undo/Redo
    private let undoManager = EditorUndoManager()
    private let undoThrottler = UndoThrottler()

    var canUndo: Bool {
        undoManager.canUndo
    }

    var canRedo: Bool {
        undoManager.canRedo
    }

    // Character auto-complete
    var availableCharacters: [Character] = []

    init(scene: Scene) {
        self.scene = scene
    }

    // MARK: - Loading

    func loadSceneContent() {
        // Convert scene content to text
        scriptText = convertToText(scene.content)
        updateStatistics()
    }

    private func convertToText(_ content: SceneContent) -> String {
        var lines: [String] = []

        // Add slug line
        lines.append(scene.slugLine.formatted)
        lines.append("")  // Blank line after slug

        // Convert elements to text
        for element in content.elements {
            switch element {
            case .action(let action):
                lines.append(action.text)
                lines.append("")  // Blank line after action

            case .dialogue(let dialogue):
                lines.append(dialogue.characterName)
                if let paren = dialogue.parenthetical {
                    lines.append("(\(paren))")
                }
                lines.append(contentsOf: dialogue.lines)
                lines.append("")  // Blank line after dialogue

            case .transition(let transition):
                lines.append(transition.displayText)
                lines.append("")

            case .shot(let shot):
                lines.append(shot.text)
                lines.append("")
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Saving

    func updateSceneFromText() {
        // Parse text into elements
        let elements = parseTextToElements(scriptText)
        scene.content = SceneContent(elements: elements)

        // Update page length
        scene.pageLength = PageCalculator.calculatePageCount(for: scene)
        scene.touch()
    }

    private func parseTextToElements(_ text: String) -> [ScriptElement] {
        var elements: [ScriptElement] = []
        let lines = text.components(separatedBy: .newlines)

        var currentDialogue: (character: String, parenthetical: String?, lines: [String])? = nil
        var skipSlugLine = true  // Skip first line (slug line)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines and slug line
            if trimmed.isEmpty || (skipSlugLine && ElementDetector.isSlugLine(trimmed)) {
                skipSlugLine = false
                continue
            }

            let type = ElementDetector.detectType(from: trimmed)

            switch type {
            case .character:
                // Save previous dialogue if exists
                if let dialogue = currentDialogue {
                    elements.append(.dialogue(DialogueElement(
                        characterName: dialogue.character,
                        parenthetical: dialogue.parenthetical,
                        lines: dialogue.lines
                    )))
                }
                // Start new dialogue
                currentDialogue = (
                    character: ElementDetector.extractCharacterName(trimmed),
                    parenthetical: nil,
                    lines: []
                )

            case .parenthetical:
                if currentDialogue != nil {
                    currentDialogue?.parenthetical = trimmed
                        .trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                }

            case .action:
                // End dialogue block
                if let dialogue = currentDialogue {
                    elements.append(.dialogue(DialogueElement(
                        characterName: dialogue.character,
                        parenthetical: dialogue.parenthetical,
                        lines: dialogue.lines
                    )))
                    currentDialogue = nil
                }
                elements.append(.action(ActionElement(text: trimmed)))

            case .transition:
                // End dialogue block
                if let dialogue = currentDialogue {
                    elements.append(.dialogue(DialogueElement(
                        characterName: dialogue.character,
                        parenthetical: dialogue.parenthetical,
                        lines: dialogue.lines
                    )))
                    currentDialogue = nil
                }
                if let transitionType = TransitionType(rawValue: trimmed) {
                    elements.append(.transition(TransitionElement(type: transitionType)))
                }

            case .dialogue:
                if currentDialogue != nil {
                    currentDialogue?.lines.append(trimmed)
                } else {
                    // Orphaned dialogue, treat as action
                    elements.append(.action(ActionElement(text: trimmed)))
                }

            default:
                break
            }
        }

        // Add final dialogue if exists
        if let dialogue = currentDialogue {
            elements.append(.dialogue(DialogueElement(
                characterName: dialogue.character,
                parenthetical: dialogue.parenthetical,
                lines: dialogue.lines
            )))
        }

        return elements
    }

    // MARK: - Text Changes

    func handleTextChange(oldValue: String, newValue: String) {
        // Save undo state if text actually changed
        if oldValue != newValue {
            Task {
                let shouldSave = await undoThrottler.shouldSave()
                if shouldSave {
                    let state = EditorState(text: oldValue)
                    undoManager.saveState(state)
                }
            }
        }

        updateStatistics()
        detectCurrentElementType()
    }

    private func detectCurrentElementType() {
        // Get current line
        // For simplicity, just show "Action" for now
        currentElementType = "Action"
    }

    // MARK: - Undo/Redo

    func undo() {
        let currentState = EditorState(text: scriptText)
        if let previousState = undoManager.undo(currentState: currentState) {
            scriptText = previousState.text
            updateStatistics()
        }
    }

    func redo() {
        let currentState = EditorState(text: scriptText)
        if let nextState = undoManager.redo(currentState: currentState) {
            scriptText = nextState.text
            updateStatistics()
        }
    }

    // MARK: - Character Management

    func loadAvailableCharacters(from project: Project?) {
        guard let project = project else { return }

        // Extract unique character names from all scenes
        var characterNames = Set<String>()

        if let scenes = project.scenes {
            for scene in scenes {
                for element in scene.content.elements {
                    if case .dialogue(let dialogue) = element {
                        characterNames.insert(dialogue.characterName)
                    }
                }
            }
        }

        // Convert to Character objects for auto-complete
        availableCharacters = characterNames.sorted().map { name in
            Character(
                name: name,
                voice: VoiceSettings(),
                appearance: AppearanceSettings()
            )
        }
    }

    func insertCharacterName(_ name: String) {
        // Replace the current line with the character name
        var lines = scriptText.components(separatedBy: .newlines)
        if !lines.isEmpty {
            lines[lines.count - 1] = name
            scriptText = lines.joined(separator: "\n")
        }
    }

    private func updateStatistics() {
        // Word count
        wordCount = scriptText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count

        // Page count
        let pageCount = PageCalculator.calculatePageCount(from: scriptText)
        formattedPageCount = String(format: "%.2f", pageCount)

        // Line count
        totalLines = scriptText.components(separatedBy: .newlines).count
    }

    // MARK: - Navigation

    func previousScene() {
        // TODO: Implement navigation
    }

    func nextScene() {
        // TODO: Implement navigation
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScriptEditorView(scene: Scene.sampleScenes()[0])
            .environment(AppState.preview)
            .modelContainer(.preview)
    }
}
