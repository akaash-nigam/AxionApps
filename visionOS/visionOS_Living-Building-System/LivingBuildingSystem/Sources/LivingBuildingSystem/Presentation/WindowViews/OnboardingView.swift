import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 0
    @State private var homeName = ""
    @State private var homeAddress = ""
    @State private var userName = ""
    @State private var isCreating = false

    @Binding var onboardingComplete: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            OnboardingProgressView(currentStep: currentStep, totalSteps: 3)
                .padding()

            Spacer()

            // Current step content
            Group {
                switch currentStep {
                case 0:
                    WelcomeStep()
                case 1:
                    HomeSetupStep(homeName: $homeName, homeAddress: $homeAddress)
                case 2:
                    UserSetupStep(userName: $userName)
                default:
                    EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer()

            // Navigation buttons
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if currentStep < 2 {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed)
                } else {
                    Button {
                        Task {
                            await completeOnboarding()
                        }
                    } label: {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Get Started")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed || isCreating)
                }
            }
            .padding()
        }
        .frame(maxWidth: 600)
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return !homeName.isEmpty
        case 2:
            return !userName.isEmpty
        default:
            return false
        }
    }

    private func completeOnboarding() async {
        Logger.shared.log("Completing onboarding", category: "Onboarding")
        isCreating = true

        // Create home
        let home = Home(name: homeName, address: homeAddress.isEmpty ? nil : homeAddress)
        modelContext.insert(home)

        // Create default rooms
        let rooms = [
            Room(name: "Living Room", roomType: .livingRoom),
            Room(name: "Kitchen", roomType: .kitchen),
            Room(name: "Bedroom", roomType: .bedroom),
            Room(name: "Bathroom", roomType: .bathroom)
        ]

        for room in rooms {
            room.home = home
            home.rooms.append(room)
            modelContext.insert(room)
        }

        // Create user
        let user = User(name: userName, role: .owner)
        user.home = home
        modelContext.insert(user)

        // Create user preferences
        let preferences = UserPreferences()
        preferences.user = user
        user.preferences = preferences
        modelContext.insert(preferences)

        do {
            try modelContext.save()
            Logger.shared.log("Onboarding completed successfully", category: "Onboarding")

            await MainActor.run {
                onboardingComplete = true
                dismiss()
            }
        } catch {
            Logger.shared.log("Failed to complete onboarding", level: .error, error: error, category: "Onboarding")
            isCreating = false
        }
    }
}

// MARK: - Progress View

struct OnboardingProgressView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.easeInOut, value: currentStep)
            }
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)

            Text("Welcome to Living Building System")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Transform your home into an intelligent, responsive environment through spatial computing")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "lightbulb.fill", title: "Smart Home Control", description: "Control your devices through spatial interface")
                FeatureRow(icon: "bolt.fill", title: "Energy Monitoring", description: "Track consumption in real-time")
                FeatureRow(icon: "view.3d", title: "Spatial Interface", description: "Immersive 3D home visualization")
            }
            .padding(.top, 24)
        }
        .padding(32)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Home Setup Step

struct HomeSetupStep: View {
    @Binding var homeName: String
    @Binding var homeAddress: String

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.gradient)

                Text("Set Up Your Home")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Give your home a name and address")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Home Name")
                        .font(.headline)

                    TextField("My Home", text: $homeName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 400)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Address (Optional)")
                        .font(.headline)

                    TextField("123 Main Street", text: $homeAddress)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 400)
                }
            }
            .padding(.horizontal, 48)
        }
        .padding(32)
    }
}

// MARK: - User Setup Step

struct UserSetupStep: View {
    @Binding var userName: String

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.gradient)

                Text("Create Your Profile")
                    .font(.title)
                    .fontWeight(.bold)

                Text("How should we address you?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Your Name")
                    .font(.headline)

                TextField("John Doe", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)

                Text("You'll be set as the home owner with full access")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 48)
        }
        .padding(32)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onboardingComplete: .constant(false))
        .modelContainer(for: [Home.self, Room.self, User.self])
}
