//
//  OnboardingView.swift
//  Reality Annotation Platform
//
//  First-run onboarding experience for new users
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "visionpro",
            title: "Welcome to\nReality Annotations",
            description: "Leave notes in physical space that persist across time and devices.",
            color: .blue
        ),
        OnboardingPage(
            icon: "note.text",
            title: "Create Annotations",
            description: "Tap in space to place text annotations. They'll stay exactly where you left them.",
            color: .green
        ),
        OnboardingPage(
            icon: "square.stack.3d.up",
            title: "Organize with Layers",
            description: "Group related annotations in layers. Show or hide them as needed.",
            color: .purple
        ),
        OnboardingPage(
            icon: "icloud",
            title: "Sync Across Devices",
            description: "Your annotations automatically sync with iCloud and appear on all your devices.",
            color: .cyan
        ),
        OnboardingPage(
            icon: "hand.point.up.left.fill",
            title: "Get Started",
            description: "Enter AR mode to start creating your first annotation in physical space.",
            color: .orange
        )
    ]

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Bottom Controls
                VStack(spacing: 24) {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .padding(.bottom, 8)

                    // Action Buttons
                    HStack(spacing: 16) {
                        if currentPage < pages.count - 1 {
                            // Skip Button
                            Button("Skip") {
                                completeOnboarding()
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)

                            // Next Button
                            Button("Next") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        } else {
                            // Get Started Button
                            Button {
                                completeOnboarding()
                            } label: {
                                Text("Get Started")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                }
                .padding(32)
                .background(.regularMaterial)
            }
        }
        .interactiveDismissDisabled()
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 120))
                .foregroundStyle(page.color.gradient)
                .shadow(color: page.color.opacity(0.3), radius: 20)

            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(page.description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 600)
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Wrapper

struct OnboardingWrapper<Content: View>: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .onAppear {
                if !hasCompletedOnboarding {
                    showOnboarding = true
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
