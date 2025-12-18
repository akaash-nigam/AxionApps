// OnboardingViews.swift
// Personal Finance Navigator
// Individual onboarding screen views

import SwiftUI

// MARK: - Welcome View

struct WelcomeView: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Icon/Logo
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(radius: 10)

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Personal Finance Navigator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Your financial journey in spatial computing")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // Value propositions
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "eye.fill",
                    title: "Visualize Your Money",
                    description: "See your finances in stunning 3D"
                )

                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Bank-Level Security",
                    description: "Your data is encrypted and protected"
                )

                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Smart Budgeting",
                    description: "Stay on track with intelligent insights"
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Features View

struct FeaturesView: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text("Powerful Features")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Everything you need to master your finances")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Feature cards
                VStack(spacing: 20) {
                    FeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Real-Time Tracking",
                        description: "Monitor your spending and income automatically with bank connections",
                        color: .blue
                    )

                    FeatureCard(
                        icon: "target",
                        title: "Goal-Based Budgets",
                        description: "Create budgets using proven strategies like the 50/30/20 rule",
                        color: .purple
                    )

                    FeatureCard(
                        icon: "sparkles",
                        title: "3D Visualization",
                        description: "Experience your money flow in immersive spatial computing",
                        color: .pink
                    )

                    FeatureCard(
                        icon: "bell.badge.fill",
                        title: "Smart Alerts",
                        description: "Get notified when you're approaching budget limits",
                        color: .orange
                    )

                    FeatureCard(
                        icon: "chart.pie.fill",
                        title: "Category Insights",
                        description: "Understand where your money goes with detailed breakdowns",
                        color: .green
                    )
                }
                .padding(.horizontal)

                Spacer(minLength: 100)
            }
        }
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Lock icon
            Image(systemName: "lock.shield.fill")
                .resizable()
                .frame(width: 100, height: 120)
                .foregroundColor(.blue)

            VStack(spacing: 16) {
                Text("Your Privacy Matters")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("We take your financial security seriously")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Privacy features
            VStack(alignment: .leading, spacing: 24) {
                PrivacyFeatureRow(
                    icon: "lock.fill",
                    title: "End-to-End Encryption",
                    description: "All your data is encrypted with AES-256-GCM"
                )

                PrivacyFeatureRow(
                    icon: "faceid",
                    title: "Biometric Authentication",
                    description: "Secure access with Face ID or Optic ID"
                )

                PrivacyFeatureRow(
                    icon: "icloud.fill",
                    title: "Private Cloud Sync",
                    description: "Your data syncs securely via iCloud"
                )

                PrivacyFeatureRow(
                    icon: "eye.slash.fill",
                    title: "No Tracking",
                    description: "We never sell your data or track your activity"
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Bank Connection View

struct BankConnectionView: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Bank icon
            Image(systemName: "building.columns.fill")
                .resizable()
                .frame(width: 100, height: 80)
                .foregroundColor(.green)

            VStack(spacing: 16) {
                Text("Connect Your Bank")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Link your accounts for automatic transaction syncing")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 16) {
                // Placeholder for Plaid Link
                Button(action: {
                    // TODO: Launch Plaid Link
                    coordinator.userProfile.connectedBankAccount = true
                }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Connect with Plaid")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Text("Or skip for now and add manually later")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Security badge
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Text("Bank-level 256-bit encryption")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)

            Spacer()

            // Info cards
            VStack(spacing: 12) {
                InfoRow(
                    icon: "checkmark.circle.fill",
                    text: "Read-only access to your accounts",
                    color: .green
                )

                InfoRow(
                    icon: "checkmark.circle.fill",
                    text: "We never store your bank credentials",
                    color: .green
                )

                InfoRow(
                    icon: "checkmark.circle.fill",
                    text: "Used by thousands of financial apps",
                    color: .green
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Budget Setup Onboarding View

struct BudgetSetupOnboardingView: View {
    @Bindable var coordinator: OnboardingCoordinator
    @State private var monthlyIncomeText = ""
    @State private var selectedStrategy: BudgetStrategy = .fiftyThirtyTwenty

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.purple)

                    Text("Set Up Your Budget")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Let's create a budget to help you stay on track")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Monthly Income
                VStack(alignment: .leading, spacing: 12) {
                    Text("Monthly Income")
                        .font(.headline)

                    TextField("$5,000", text: $monthlyIncomeText)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .onChange(of: monthlyIncomeText) { _, newValue in
                            if let income = Decimal(string: newValue.filter { $0.isNumber || $0 == "." }) {
                                coordinator.userProfile.monthlyIncome = income
                            }
                        }

                    Text("Enter your total monthly income after taxes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Budget Strategy
                VStack(alignment: .leading, spacing: 12) {
                    Text("Budget Strategy")
                        .font(.headline)

                    Picker("Strategy", selection: $selectedStrategy) {
                        Text("50/30/20 Rule").tag(BudgetStrategy.fiftyThirtyTwenty)
                        Text("Zero-Based").tag(BudgetStrategy.zeroBased)
                        Text("Envelope Method").tag(BudgetStrategy.envelope)
                        Text("Custom").tag(BudgetStrategy.custom)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedStrategy) { _, newValue in
                        coordinator.userProfile.budgetStrategy = newValue
                    }

                    // Strategy description
                    Group {
                        switch selectedStrategy {
                        case .fiftyThirtyTwenty:
                            StrategyCard(
                                title: "50/30/20 Rule",
                                description: "50% needs, 30% wants, 20% savings",
                                example: "Great for beginners",
                                color: .blue
                            )
                        case .zeroBased:
                            StrategyCard(
                                title: "Zero-Based Budgeting",
                                description: "Every dollar has a purpose",
                                example: "Maximize control",
                                color: .purple
                            )
                        case .envelope:
                            StrategyCard(
                                title: "Envelope Method",
                                description: "Allocate cash to categories",
                                example: "Visual spending limits",
                                color: .green
                            )
                        case .custom:
                            StrategyCard(
                                title: "Custom Budget",
                                description: "Create your own allocations",
                                example: "Maximum flexibility",
                                color: .orange
                            )
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Preferences
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preferences")
                        .font(.headline)

                    Toggle(isOn: $coordinator.userProfile.enableBiometric) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Enable Face ID")
                        }
                    }

                    Toggle(isOn: $coordinator.userProfile.enableNotifications) {
                        HStack {
                            Image(systemName: "bell.fill")
                            Text("Enable Budget Alerts")
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Spacer(minLength: 100)
            }
        }
    }
}

// MARK: - Completion View

struct OnboardingCompletionView: View {
    @Bindable var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Success animation/icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 150, height: 150)

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.green)
            }

            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Ready to start your financial journey")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("What's Next")
                    .font(.headline)
                    .padding(.bottom, 8)

                CompletionRow(
                    icon: "chart.bar.fill",
                    title: "Explore Your Dashboard",
                    description: "See your financial overview"
                )

                CompletionRow(
                    icon: "plus.circle.fill",
                    title: "Add Transactions",
                    description: "Start tracking your spending"
                )

                CompletionRow(
                    icon: "target",
                    title: "Monitor Your Budget",
                    description: "Stay on track with your goals"
                )

                CompletionRow(
                    icon: "sparkles",
                    title: "Try 3D Visualization",
                    description: "Experience your money flow"
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)

            Spacer()

            // Get Started button
            Button(action: {
                coordinator.complete()
            }) {
                HStack {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Supporting Components

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
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

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(color)
                .frame(width: 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

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

struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct StrategyCard: View {
    let title: String
    let description: String
    let example: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                Text(example)
                    .font(.caption)
            }
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CompletionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
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

// MARK: - Preview

#Preview("Welcome") {
    WelcomeView(coordinator: OnboardingCoordinator())
}

#Preview("Features") {
    FeaturesView(coordinator: OnboardingCoordinator())
}

#Preview("Privacy") {
    PrivacyView(coordinator: OnboardingCoordinator())
}

#Preview("Bank Connection") {
    BankConnectionView(coordinator: OnboardingCoordinator())
}

#Preview("Budget Setup") {
    BudgetSetupOnboardingView(coordinator: OnboardingCoordinator())
}

#Preview("Completion") {
    OnboardingCompletionView(coordinator: OnboardingCoordinator())
}
