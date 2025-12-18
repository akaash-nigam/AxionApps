//
//  SpaceManager.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import Observation
import SwiftUI

@Observable
class SpaceManager {
    var openWindows: Set<String> = []
    var activeImmersiveSpace: String?
    var isTransitioning: Bool = false

    init() {}

    @MainActor
    func openMissionControl(_ openWindow: OpenWindowAction) async {
        await openWindow(id: "mission-control")
        openWindows.insert("mission-control")
    }

    @MainActor
    func openBriefing(
        scenarioID: UUID,
        _ openWindow: OpenWindowAction
    ) async {
        await openWindow(id: "briefing", value: scenarioID)
        openWindows.insert("briefing")
    }

    @MainActor
    func openTacticalPlanning(
        scenarioID: UUID,
        _ openWindow: OpenWindowAction
    ) async {
        await openWindow(id: "tactical-planning", value: scenarioID)
        openWindows.insert("tactical-planning")
    }

    @MainActor
    func startCombatTraining(
        _ openImmersiveSpace: OpenImmersiveSpaceAction,
        _ dismissWindow: DismissWindowAction
    ) async {
        isTransitioning = true

        // Close other windows first
        for windowID in openWindows {
            await dismissWindow(id: windowID)
        }
        openWindows.removeAll()

        // Open immersive space
        switch await openImmersiveSpace(id: "combat-zone") {
        case .opened:
            activeImmersiveSpace = "combat-zone"
        case .error:
            print("Failed to open combat zone")
        case .userCancelled:
            print("User cancelled combat zone")
        @unknown default:
            break
        }

        isTransitioning = false
    }

    @MainActor
    func exitCombat(
        sessionID: UUID,
        _ dismissImmersiveSpace: DismissImmersiveSpaceAction,
        _ openWindow: OpenWindowAction
    ) async {
        isTransitioning = true

        // Dismiss immersive space
        await dismissImmersiveSpace()
        activeImmersiveSpace = nil

        // Open after-action review
        await openWindow(id: "after-action", value: sessionID)
        openWindows.insert("after-action")

        isTransitioning = false
    }

    @MainActor
    func openSettings(_ openWindow: OpenWindowAction) async {
        await openWindow(id: "settings")
        openWindows.insert("settings")
    }

    @MainActor
    func closeWindow(
        id: String,
        _ dismissWindow: DismissWindowAction
    ) async {
        await dismissWindow(id: id)
        openWindows.remove(id)
    }

    @MainActor
    func closeAllWindows(_ dismissWindow: DismissWindowAction) async {
        for windowID in openWindows {
            await dismissWindow(id: windowID)
        }
        openWindows.removeAll()
    }

    var isImmersive: Bool {
        activeImmersiveSpace != nil
    }

    var hasOpenWindows: Bool {
        !openWindows.isEmpty
    }
}
