import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.modelContext) private var modelContext

    @Query private var trainingModules: [TrainingModule]
    @Query private var trainingSession: [TrainingSession]

    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    header

                    // Progress Overview
                    progressSection

                    // Quick Actions
                    quickActions

                    // Assigned Training Modules
                    assignedTrainingSection

                    // Recent Achievements
                    achievementsSection
                }
                .padding(40)
            }
            .navigationTitle("Industrial Safety Simulator")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Analytics", systemImage: "chart.bar.fill") {
                            openWindow(id: "analytics")
                        }
                        Button("Settings", systemImage: "gearshape.fill") {
                            openWindow(id: "settings")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back, \(appState.currentUser?.name ?? "User")")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(appState.currentUser?.roleDescription ?? "Operator")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // User avatar placeholder
            Circle()
                .fill(.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay {
                    Text(appState.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Training Progress")
                .font(.title2)
                .fontWeight(.semibold)

            ProgressCard(
                completed: viewModel.completedToday,
                total: viewModel.totalAssigned,
                percentage: viewModel.completionPercentage
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                ActionCard(
                    title: "Start Training",
                    icon: "play.circle.fill",
                    color: .green
                ) {
                    startTraining()
                }

                ActionCard(
                    title: "Analytics",
                    icon: "chart.bar.fill",
                    color: .blue
                ) {
                    openWindow(id: "analytics")
                }

                ActionCard(
                    title: "Progress Reports",
                    icon: "doc.text.fill",
                    color: .purple
                ) {
                    // Show progress reports
                }
            }
        }
    }

    // MARK: - Assigned Training Section

    private var assignedTrainingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Assigned Training Modules")
                .font(.title2)
                .fontWeight(.semibold)

            if trainingModules.isEmpty {
                EmptyTrainingView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(trainingModules.prefix(5)) { module in
                        TrainingModuleCard(module: module) {
                            selectModule(module)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                AchievementRow(
                    icon: "star.fill",
                    title: "Perfect Score - Lockout/Tagout",
                    timeAgo: "2 days ago",
                    color: .yellow
                )

                AchievementRow(
                    icon: "flame.fill",
                    title: "Expert Level Unlocked",
                    timeAgo: "1 week ago",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Actions

    private func startTraining() {
        if let firstModule = trainingModules.first {
            selectModule(firstModule)
        }
    }

    private func selectModule(_ module: TrainingModule) {
        Task {
            await openImmersiveSpace(id: "training-environment")
            appState.startTrainingSession(module)
        }
    }
}

// MARK: - Progress Card

struct ProgressCard: View {
    let completed: Int
    let total: Int
    let percentage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ProgressView(value: percentage, total: 100)
                    .progressViewStyle(.linear)
                    .tint(.green)

                Text("\(Int(percentage))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }

            Text("\(completed) of \(total) scenarios complete")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Action Card

struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(color)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

// MARK: - Training Module Card

struct TrainingModuleCard: View {
    let module: TrainingModule
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: module.category.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(categoryColor(module.category), in: RoundedRectangle(cornerRadius: 12))

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: module.category.icon)
                            .font(.caption)

                        Text(module.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }

                    Text("Progress: \(Int(module.completionPercentage))% | Est. \(formatDuration(module.estimatedDuration)) remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Action button
                Text(module.isCompleted ? "Review" : "Continue")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(module.isCompleted ? Color.blue : Color.green, in: Capsule())
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }

    private func categoryColor(_ category: SafetyCategory) -> Color {
        switch category {
        case .hazardRecognition: return .orange
        case .emergencyResponse: return .red
        case .equipmentSafety: return .blue
        case .chemicalHandling: return .purple
        case .fireEvacuation: return .red
        case .lockoutTagout: return .yellow
        default: return .gray
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let icon: String
    let title: String
    let timeAgo: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)

                Text(timeAgo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Empty Training View

struct EmptyTrainingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Training Assigned")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Contact your safety manager to get started with training modules.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
