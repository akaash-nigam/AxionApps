//
//  OnboardingView.swift
//  Language Immersion Rooms
//
//  Onboarding flow for new users
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeScreen()
                .tag(0)

            LanguageSelectionScreen()
                .tag(1)

            GetStartedScreen()
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct WelcomeScreen: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("🌍")
                .font(.system(size: 100))

            VStack(spacing: 15) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Language Immersion Rooms")
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
            }

            Text("Learn languages naturally by transforming your space into immersive learning environments")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)

            Spacer()

            Text("Swipe to continue →")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(60)
    }
}

struct LanguageSelectionScreen: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 15) {
                Text("Choose Your Language")
                    .font(.system(size: 40, weight: .bold))

                Text("For MVP, we're starting with Spanish")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Language card
            VStack(spacing: 20) {
                Text("🇪🇸")
                    .font(.system(size: 80))

                Text("Spanish")
                    .font(.system(size: 32, weight: .semibold))

                Text("Learn from Maria, your friendly Spanish tutor from Madrid")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .frame(width: 500)
            .background(.ultraThinMaterial)
            .cornerRadius(20)

            Text("More languages coming soon!")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            Text("Swipe to continue →")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(60)
    }
}

struct GetStartedScreen: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 15) {
                Text("Ready to Start")
                    .font(.system(size: 40, weight: .bold))

                Text("Here's what you can do:")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 30) {
                FeatureRow(
                    icon: "tag",
                    title: "Label Objects",
                    description: "See everyday objects labeled in Spanish"
                )

                FeatureRow(
                    icon: "bubble.left.and.bubble.right",
                    title: "Practice Conversations",
                    description: "Chat with Maria, your AI Spanish tutor"
                )

                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Progress",
                    description: "Watch your vocabulary grow day by day"
                )
            }
            .padding(.horizontal, 60)

            Spacer()

            Button {
                completeOnboarding()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(width: 300)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(60)
    }

    private func completeOnboarding() {
        appState.isOnboarding = false
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)
                .frame(width: 60)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
