//
//  ServiceContainer.swift
//  CorporateUniversity
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import Foundation

/// Dependency injection container for all services
@Observable
@MainActor
class ServiceContainer {
    // MARK: - Core Infrastructure

    let networkClient: NetworkClient
    let cacheManager: CacheManager
    let errorHandler: ErrorHandler

    // MARK: - Services

    var authenticationService: AuthenticationService
    var learningService: LearningService
    var assessmentService: AssessmentService
    var analyticsService: AnalyticsService
    var contentManagementService: ContentManagementService

    // MARK: - Initialization

    init() {
        self.networkClient = NetworkClient()
        self.cacheManager = CacheManager()
        self.errorHandler = ErrorHandler()

        // Initialize services
        self.authenticationService = AuthenticationService(networkClient: networkClient)
        self.learningService = LearningService(
            networkClient: networkClient,
            cacheManager: cacheManager
        )
        self.assessmentService = AssessmentService(networkClient: networkClient)
        self.analyticsService = AnalyticsService(networkClient: networkClient)
        self.contentManagementService = ContentManagementService(networkClient: networkClient)
    }
}

// MARK: - Error Handler

class ErrorHandler {
    func handle(_ error: Error) {
        // Log error, show alert, etc.
        print("Error: \(error.localizedDescription)")
    }
}
