//
//  AutoSaveManager.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import SwiftData
import Observation

/// Manages automatic saving of projects
@Observable
@MainActor
final class AutoSaveManager {
    // MARK: - Properties

    var isEnabled: Bool = true
    var interval: TimeInterval = 300  // 5 minutes
    var isSaving: Bool = false
    var lastSaveTime: Date?
    var hasUnsavedChanges: Bool = false

    private var timer: Timer?
    private var projectStore: ProjectStore?
    private var currentProjectId: UUID?

    // MARK: - Initialization

    init(interval: TimeInterval = 300) {
        self.interval = interval
    }

    // MARK: - Public Methods

    /// Start auto-save timer
    func start(projectId: UUID, store: ProjectStore) {
        self.currentProjectId = projectId
        self.projectStore = store

        stopTimer()

        guard isEnabled else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.saveIfNeeded()
            }
        }

        // Fire immediately on a small delay to ensure initial state is saved
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
            await saveIfNeeded()
        }
    }

    /// Stop auto-save timer
    func stop() {
        stopTimer()
        currentProjectId = nil
        projectStore = nil
    }

    /// Manually trigger save
    func saveNow() async {
        await save()
    }

    /// Mark that changes have been made
    func markChanged() {
        hasUnsavedChanges = true
    }

    /// Clear unsaved changes flag (after manual save)
    func markSaved() {
        hasUnsavedChanges = false
        lastSaveTime = Date()
    }

    // MARK: - Private Methods

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func saveIfNeeded() async {
        guard hasUnsavedChanges else {
            return  // No changes to save
        }

        await save()
    }

    private func save() async {
        guard let projectId = currentProjectId,
              let store = projectStore else {
            return
        }

        isSaving = true

        do {
            // Fetch and save project
            if let project = try await store.fetch(id: projectId) {
                try await store.update(project)
                hasUnsavedChanges = false
                lastSaveTime = Date()
            }
        } catch {
            print("Auto-save failed: \(error.localizedDescription)")
            // Don't clear hasUnsavedChanges on error
        }

        isSaving = false
    }

    // MARK: - Status

    var statusText: String {
        if isSaving {
            return "Saving..."
        } else if let lastSave = lastSaveTime {
            return "Saved \(timeAgoText(from: lastSave))"
        } else {
            return "Not saved yet"
        }
    }

    private func timeAgoText(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Preview Support

extension AutoSaveManager {
    static var preview: AutoSaveManager {
        let manager = AutoSaveManager(interval: 10)  // 10 seconds for preview
        manager.lastSaveTime = Date().addingTimeInterval(-120)  // 2 minutes ago
        return manager
    }
}
