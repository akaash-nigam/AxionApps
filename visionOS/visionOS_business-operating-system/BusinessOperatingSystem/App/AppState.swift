//
//  AppState.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import Observation

/// Global application state
@Observable
final class AppState: @unchecked Sendable {
    // MARK: - User & Authentication

    var user: User?
    var isAuthenticated: Bool {
        user != nil
    }

    // MARK: - Organization Data

    var organization: Organization?
    var hasOrganizationData: Bool {
        organization != nil && !(organization?.departments.isEmpty ?? true)
    }

    // MARK: - Navigation

    var currentPresentationMode: BOSPresentationMode = .dashboard
    var selectedDepartment: Department?
    var activeKPIs: [KPI] = []

    // MARK: - UI State

    var isLoading: Bool = false
    var error: (any Error)?
    var lastError: ErrorAlertConfig?
    var showingSettings: Bool = false
    var isUsingFallbackStorage: Bool = false

    // MARK: - Initialization

    init() {
        // Initialize with defaults
    }

    // MARK: - Methods

    func reset() {
        user = nil
        organization = nil
        selectedDepartment = nil
        activeKPIs = []
        isLoading = false
        error = nil
        lastError = nil
    }

    func clearError() {
        lastError = nil
        error = nil
    }
}

// MARK: - Presentation Mode

enum BOSPresentationMode {
    case dashboard
    case departmentWindow(Department.ID)
    case departmentVolume(Department.ID)
    case businessUniverse
    case focusMode
}
