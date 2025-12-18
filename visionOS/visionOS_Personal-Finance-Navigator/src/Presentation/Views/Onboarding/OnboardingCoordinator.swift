// OnboardingCoordinator.swift
// Personal Finance Navigator
// Coordinator for managing onboarding flow

import Foundation
import SwiftUI

/// Manages the onboarding flow and state
@MainActor
@Observable
class OnboardingCoordinator {
    // MARK: - State

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case features = 1
        case privacy = 2
        case bankConnection = 3
        case budgetSetup = 4
        case completion = 5

        var progress: Double {
            Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
        }
    }

    private(set) var currentStep: OnboardingStep = .welcome
    private(set) var isComplete = false
    private(set) var canSkip = true

    // Data collected during onboarding
    var userProfile: OnboardingProfile = OnboardingProfile()

    // MARK: - Navigation

    func nextStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            complete()
            return
        }
        currentStep = nextStep
    }

    func previousStep() {
        guard currentStep.rawValue > 0 else { return }
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }

    func skip() {
        guard canSkip else { return }
        complete()
    }

    func complete() {
        isComplete = true
        saveOnboardingStatus()
    }

    func restart() {
        currentStep = .welcome
        isComplete = false
        userProfile = OnboardingProfile()
    }

    // MARK: - Validation

    func canProceed(from step: OnboardingStep) -> Bool {
        switch step {
        case .welcome, .features, .privacy:
            return true
        case .bankConnection:
            // Can skip bank connection
            return true
        case .budgetSetup:
            // Must set up at least a basic budget
            return userProfile.monthlyIncome != nil
        case .completion:
            return true
        }
    }

    // MARK: - Persistence

    private func saveOnboardingStatus() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(Date(), forKey: "onboardingCompletedDate")
    }

    static func hasCompletedOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingCompletedDate")
    }
}

// MARK: - Onboarding Profile

struct OnboardingProfile {
    var preferredCurrency: String = "USD"
    var monthlyIncome: Decimal?
    var budgetStrategy: BudgetStrategy = .fiftyThirtyTwenty
    var enableBiometric: Bool = true
    var enableNotifications: Bool = true
    var connectedBankAccount: Bool = false
    var hasCreatedBudget: Bool = false
}
