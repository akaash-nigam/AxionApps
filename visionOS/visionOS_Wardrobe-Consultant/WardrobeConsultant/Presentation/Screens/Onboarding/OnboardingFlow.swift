//
//  OnboardingFlow.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            TabView(selection: $viewModel.currentStep) {
                WelcomeScreen()
                    .tag(OnboardingStep.welcome)

                StyleProfileScreen(viewModel: viewModel)
                    .tag(OnboardingStep.styleProfile)

                SizePreferencesScreen(viewModel: viewModel)
                    .tag(OnboardingStep.sizePreferences)

                ColorPreferencesScreen(viewModel: viewModel)
                    .tag(OnboardingStep.colorPreferences)

                IntegrationsScreen(viewModel: viewModel)
                    .tag(OnboardingStep.integrations)

                FirstItemScreen(viewModel: viewModel)
                    .tag(OnboardingStep.firstItem)

                CompletionScreen(onComplete: {
                    Task {
                        if await viewModel.complete() {
                            dismiss()
                        }
                    }
                })
                .tag(OnboardingStep.completion)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Welcome Screen
struct WelcomeScreen: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "hanger")
                .font(.system(size: 100))
                .foregroundStyle(.blue)

            Text("Welcome to\nWardrobe Consultant")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Your personal AI-powered wardrobe assistant")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                Feature(icon: "sparkles", text: "AI outfit suggestions")
                Feature(icon: "cube.fill", text: "Virtual try-on with AR")
                Feature(icon: "cloud.sun.fill", text: "Weather-based recommendations")
            }
            .padding()

            Spacer()

            Text("Swipe to continue")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct Feature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

// MARK: - Style Profile Screen
struct StyleProfileScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("What's Your Style?")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Help us understand your personal style")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(StyleProfile.allCases, id: \.self) { style in
                        Button {
                            viewModel.primaryStyle = style
                        } label: {
                            StyleCard(
                                style: style,
                                isSelected: viewModel.primaryStyle == style
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

struct StyleCard: View {
    let style: StyleProfile
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(style.rawValue.capitalized)
                    .font(.headline)

                Text(descriptionFor(style))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
            }
        }
        .padding()
        .background(isSelected ? .blue.opacity(0.2) : .ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func descriptionFor(_ style: StyleProfile) -> String {
        switch style {
        case .casual: return "Comfortable and relaxed everyday wear"
        case .formal: return "Elegant and sophisticated attire"
        case .business: return "Professional and polished look"
        case .bohemian: return "Free-spirited and artistic style"
        case .minimalist: return "Clean, simple, and refined"
        case .streetwear: return "Urban and trendy fashion"
        case .preppy: return "Classic and collegiate style"
        case .athletic: return "Sporty and functional clothing"
        case .vintage: return "Retro and timeless pieces"
        case .classic: return "Timeless and traditional style"
        }
    }
}

// MARK: - Size Preferences Screen
struct SizePreferencesScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Your Sizes")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Tell us your typical sizes")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Form {
                Section {
                    TextField("Top Size (e.g., M, L)", text: $viewModel.topSize)
                    TextField("Bottom Size (e.g., 32, 34)", text: $viewModel.bottomSize)
                    TextField("Shoe Size (e.g., 9, 10)", text: $viewModel.shoeSize)
                }

                Section {
                    Picker("Fit Preference", selection: $viewModel.fitPreference) {
                        ForEach(FitPreference.allCases, id: \.self) { fit in
                            Text(fit.rawValue.capitalized).tag(fit)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .padding()
    }
}

// MARK: - Color Preferences Screen
struct ColorPreferencesScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let commonColors = [
        ("Black", "#000000"),
        ("White", "#FFFFFF"),
        ("Navy", "#000080"),
        ("Gray", "#808080"),
        ("Red", "#FF0000"),
        ("Blue", "#0000FF"),
        ("Green", "#008000"),
        ("Pink", "#FFC0CB"),
        ("Purple", "#800080"),
        ("Brown", "#8B4513")
    ]

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Favorite Colors")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Select colors you love to wear")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(commonColors, id: \.1) { name, hex in
                    Button {
                        toggleColor(hex)
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: hex) ?? .gray)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    if viewModel.favoriteColors.contains(hex) {
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.title3)
                                    }
                                }

                            Text(name)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    private func toggleColor(_ hex: String) {
        if viewModel.favoriteColors.contains(hex) {
            viewModel.favoriteColors.removeAll { $0 == hex }
        } else {
            viewModel.favoriteColors.append(hex)
        }
    }
}

// MARK: - Integrations Screen
struct IntegrationsScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Smart Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enable integrations for better recommendations")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 20) {
                IntegrationToggle(
                    icon: "cloud.sun.fill",
                    title: "Weather Integration",
                    description: "Get outfit suggestions based on the weather",
                    isOn: $viewModel.enableWeather
                )

                IntegrationToggle(
                    icon: "calendar",
                    title: "Calendar Integration",
                    description: "Plan outfits for upcoming events",
                    isOn: $viewModel.enableCalendar
                )

                IntegrationToggle(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Daily outfit reminders and suggestions",
                    isOn: $viewModel.enableNotifications
                )
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct IntegrationToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - First Item Screen
struct FirstItemScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Add Your First Item")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Start building your digital wardrobe")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.opacity(0.6))

                Text("You can skip this for now and add items later from the wardrobe tab")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Completion Screen
struct CompletionScreen: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.green)

            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your wardrobe consultant is ready to help you look your best")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                onComplete()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Onboarding ViewModel
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var primaryStyle: StyleProfile = .casual
    @Published var topSize = ""
    @Published var bottomSize = ""
    @Published var shoeSize = ""
    @Published var fitPreference: FitPreference = .regular
    @Published var favoriteColors: [String] = []
    @Published var enableWeather = true
    @Published var enableCalendar = true
    @Published var enableNotifications = true
    @Published var errorMessage: String?

    private let userProfileRepository: UserProfileRepository

    init(userProfileRepository: UserProfileRepository = CoreDataUserProfileRepository.shared) {
        self.userProfileRepository = userProfileRepository
    }

    func complete() async -> Bool {
        do {
            var profile = try await userProfileRepository.fetch()

            profile.primaryStyle = primaryStyle
            profile.topSize = topSize.isEmpty ? nil : topSize
            profile.bottomSize = bottomSize.isEmpty ? nil : bottomSize
            profile.shoeSize = shoeSize.isEmpty ? nil : shoeSize
            profile.fitPreference = fitPreference
            profile.favoriteColors = favoriteColors
            profile.enableWeatherIntegration = enableWeather
            profile.enableCalendarIntegration = enableCalendar
            profile.enableNotifications = enableNotifications

            try await userProfileRepository.update(profile)

            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

            return true
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case styleProfile
    case sizePreferences
    case colorPreferences
    case integrations
    case firstItem
    case completion
}

// MARK: - Preview
#Preview {
    OnboardingFlow()
}
