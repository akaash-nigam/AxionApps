//
//  EditorUndoManager.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Manages undo/redo operations for script editor
@Observable
final class EditorUndoManager {
    // MARK: - Properties

    private var undoStack: [EditorState] = []
    private var redoStack: [EditorState] = []
    private let maxStackSize = 50

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    var canRedo: Bool {
        !redoStack.isEmpty
    }

    // MARK: - State Management

    /// Save current state for undo
    func saveState(_ state: EditorState) {
        // Add to undo stack
        undoStack.append(state)

        // Clear redo stack when new edit is made
        redoStack.removeAll()

        // Limit stack size
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
    }

    /// Undo last change
    func undo(currentState: EditorState) -> EditorState? {
        guard !undoStack.isEmpty else { return nil }

        // Save current state to redo stack
        redoStack.append(currentState)

        // Pop from undo stack
        return undoStack.popLast()
    }

    /// Redo last undone change
    func redo(currentState: EditorState) -> EditorState? {
        guard !redoStack.isEmpty else { return nil }

        // Save current state to undo stack
        undoStack.append(currentState)

        // Pop from redo stack
        return redoStack.popLast()
    }

    /// Clear all history
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }

    /// Group sequential edits (for throttling saves)
    func beginGroup() {
        // Mark group start
    }

    func endGroup() {
        // Mark group end
    }
}

// MARK: - Editor State

/// Represents a snapshot of editor state for undo/redo
struct EditorState: Equatable {
    let text: String
    let cursorPosition: Int?
    let timestamp: Date

    init(text: String, cursorPosition: Int? = nil) {
        self.text = text
        self.cursorPosition = cursorPosition
        self.timestamp = Date()
    }

    static func == (lhs: EditorState, rhs: EditorState) -> Bool {
        lhs.text == rhs.text
    }
}

// MARK: - Undo Throttler

/// Throttles undo state saves to avoid too many snapshots
actor UndoThrottler {
    private var lastSaveTime: Date?
    private let minimumInterval: TimeInterval = 2.0  // Save at most every 2 seconds

    func shouldSave() -> Bool {
        guard let lastSave = lastSaveTime else {
            lastSaveTime = Date()
            return true
        }

        let elapsed = Date().timeIntervalSince(lastSave)
        if elapsed >= minimumInterval {
            lastSaveTime = Date()
            return true
        }

        return false
    }

    func reset() {
        lastSaveTime = nil
    }
}
