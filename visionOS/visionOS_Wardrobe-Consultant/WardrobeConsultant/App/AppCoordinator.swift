//
//  AppCoordinator.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import Combine

/// Main application coordinator
/// Manages app-level state and navigation
@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: UserProfile?
    @Published var isOnboardingComplete: Bool = false

    // MARK: - Dependencies
    private let userProfileRepository: UserProfileRepository
    private let persistenceController: PersistenceController

    // MARK: - Initialization
    init(
        userProfileRepository: UserProfileRepository = CoreDataUserProfileRepository.shared,
        persistenceController: PersistenceController = .shared
    ) {
        self.userProfileRepository = userProfileRepository
        self.persistenceController = persistenceController

        loadUserProfile()
    }

    // MARK: - Public Methods
    func shouldShowOnboarding() -> Bool {
        return !isOnboardingComplete || currentUser == nil
    }

    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
    }

    func loadUserProfile() {
        Task {
            do {
                currentUser = try await userProfileRepository.fetch()
                isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
            } catch {
                print("Error loading user profile: \(error)")
            }
        }
    }

    func reset() {
        currentUser = nil
        isOnboardingComplete = false
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
    }
}
