//
//  AppState.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import Foundation
import Observation

@Observable
class AppState {
    var currentUser: Warrior?
    var activeSession: TrainingSession?
    var appPhase: AppPhase
    var securityContext: SecurityContext
    var isAuthenticated: Bool

    init(
        currentUser: Warrior? = nil,
        activeSession: TrainingSession? = nil,
        appPhase: AppPhase = .authentication,
        isAuthenticated: Bool = false
    ) {
        self.currentUser = currentUser
        self.activeSession = activeSession
        self.appPhase = appPhase
        self.isAuthenticated = isAuthenticated
        self.securityContext = SecurityContext(
            userClearance: currentUser?.clearanceLevel ?? .unclassified
        )
    }

    func authenticate(warrior: Warrior) {
        self.currentUser = warrior
        self.isAuthenticated = true
        self.securityContext.userClearance = warrior.clearanceLevel
        self.appPhase = .missionSelect
    }

    func startSession(scenario: Scenario) {
        guard let user = currentUser else { return }

        self.activeSession = TrainingSession(
            missionType: MissionType(rawValue: scenario.type.rawValue) ?? .urbanAssault,
            scenarioID: scenario.id,
            warriorID: user.id,
            classificationLevel: scenario.classification
        )
        self.appPhase = .training
    }

    func endSession() {
        guard let session = activeSession else { return }

        // Mark session as complete
        // In real implementation, this would save to database

        self.appPhase = .afterAction
    }

    func returnToMissionSelect() {
        self.activeSession = nil
        self.appPhase = .missionSelect
    }

    func logout() {
        self.currentUser = nil
        self.activeSession = nil
        self.isAuthenticated = false
        self.appPhase = .authentication
        self.securityContext.userClearance = .unclassified
    }
}

// MARK: - App Phase
enum AppPhase {
    case authentication
    case missionSelect
    case briefing
    case planning
    case training
    case afterAction
    case settings
}

// MARK: - Security Context
struct SecurityContext {
    var userClearance: ClassificationLevel
    var sessionClassification: ClassificationLevel
    var dataMarkings: [DataMarking]

    init(
        userClearance: ClassificationLevel,
        sessionClassification: ClassificationLevel = .unclassified,
        dataMarkings: [DataMarking] = []
    ) {
        self.userClearance = userClearance
        self.sessionClassification = sessionClassification
        self.dataMarkings = dataMarkings
    }

    func canAccess(classification: ClassificationLevel) -> Bool {
        return userClearance >= classification
    }

    func getBannerText() -> String {
        return sessionClassification.displayName
    }

    func getBannerColor() -> String {
        return sessionClassification.bannerColor
    }
}

// MARK: - Data Marking
struct DataMarking {
    var type: MarkingType
    var value: String

    enum MarkingType {
        case classification
        case dissemination
        case handling
        case other
    }
}
