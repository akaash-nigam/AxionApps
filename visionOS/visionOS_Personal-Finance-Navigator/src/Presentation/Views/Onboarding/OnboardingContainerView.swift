// OnboardingContainerView.swift
// Personal Finance Navigator
// Container for the onboarding flow

import SwiftUI

/// Main container for the onboarding flow
struct OnboardingContainerView: View {
    @State private var coordinator = OnboardingCoordinator()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                OnboardingProgressBar(progress: coordinator.currentStep.progress)
                    .padding(.horizontal)
                    .padding(.top)

                // Content
                TabView(selection: $coordinator.currentStep) {
                    WelcomeView(coordinator: coordinator)
                        .tag(OnboardingCoordinator.OnboardingStep.welcome)

                    FeaturesView(coordinator: coordinator)
                        .tag(OnboardingCoordinator.OnboardingStep.features)

                    PrivacyView(coordinator: coordinator)
                        .tag(OnboardingCoordinator.OnboardingStep.privacy)

                    BankConnectionView(coordinator: coordinator)
                        .tag(OnboardingCoordinator.OnboardingStep.bankConnection)

                    BudgetSetupOnboardingView(coordinator: coordinator)
                        .tag(OnboardingCoordinator.OnboardingStep.budgetSetup)

                    OnboardingCompletionView(coordinator: coordinator)
                        .tag(OnboardingCoordinator.OnboardingStep.completion)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: coordinator.currentStep)

                // Navigation buttons
                OnboardingNavigationBar(coordinator: coordinator)
                    .padding()
            }
        }
        .onChange(of: coordinator.isComplete) { _, isComplete in
            if isComplete {
                dismiss()
            }
        }
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Navigation Bar

struct OnboardingNavigationBar: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        HStack {
            // Back button
            if coordinator.currentStep.rawValue > 0 {
                Button(action: {
                    coordinator.previousStep()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.bordered)
            } else {
                Spacer()
            }

            Spacer()

            // Skip button
            if coordinator.canSkip && coordinator.currentStep != .completion {
                Button("Skip") {
                    coordinator.skip()
                }
                .foregroundColor(.secondary)
            }

            // Next/Continue button
            if coordinator.currentStep != .completion {
                Button(action: {
                    coordinator.nextStep()
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!coordinator.canProceed(from: coordinator.currentStep))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView()
}
