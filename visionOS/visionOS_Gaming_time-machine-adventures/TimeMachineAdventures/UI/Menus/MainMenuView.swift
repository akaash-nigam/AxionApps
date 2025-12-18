import SwiftUI
import RealityKit

struct MainMenuView: View {
    @EnvironmentObject var coordinator: GameCoordinator
    @State private var selectedEra: HistoricalEra?
    @State private var showingProgress = false
    @State private var showingSettings = false
    @State private var isAnimating = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundView

                // Main Content
                VStack(spacing: 40) {
                    // Title
                    titleView

                    // Era Selection
                    eraSelectionView

                    // Action Buttons
                    actionButtonsView

                    Spacer()

                    // Footer
                    footerView
                }
                .padding(50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showingProgress) {
            ProgressDashboardView(progress: coordinator.playerProgress)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    // MARK: - View Components
    private var backgroundView: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated particles
            TimelineEffect()
                .opacity(isAnimating ? 1.0 : 0.0)
        }
    }

    private var titleView: some View {
        VStack(spacing: 10) {
            Text("Time Machine")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            Text("Adventures")
                .font(.system(size: 56, weight: .light, design: .serif))
                .foregroundColor(.secondary)

            Text("Journey through history in your own living room")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(y: isAnimating ? 0 : -20)
    }

    private var eraSelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Your Era")
                .font(.system(size: 32, weight: .semibold))

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 220), spacing: 20)
            ], spacing: 20) {
                ForEach(coordinator.availableEras) { era in
                    EraCard(
                        era: era,
                        isSelected: selectedEra?.id == era.id,
                        isUnlocked: era.isUnlocked || era.unlockRequirements.isSatisfied(by: coordinator.playerProgress)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedEra = era
                        }
                    }
                }
            }
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(y: isAnimating ? 0 : 20)
    }

    private var actionButtonsView: some View {
        HStack(spacing: 30) {
            // Progress Button
            Button(action: { showingProgress = true }) {
                Label("Progress", systemImage: "chart.bar.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 160, height: 50)
            }
            .buttonStyle(.bordered)
            .tint(.blue)

            // Settings Button
            Button(action: { showingSettings = true }) {
                Label("Settings", systemImage: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 160, height: 50)
            }
            .buttonStyle(.bordered)
            .tint(.gray)

            // Begin Journey Button
            if let era = selectedEra,
               era.isUnlocked || era.unlockRequirements.isSatisfied(by: coordinator.playerProgress) {
                Button(action: {
                    coordinator.startJourney(era: era)
                }) {
                    Label("Begin Journey", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 200, height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .controlSize(.large)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(.spring(response: 0.3, dampingFraction: 0.6).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
    }

    private var footerView: some View {
        HStack {
            // Player Info
            HStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Level \(coordinator.playerProgress.currentLevel)")
                        .font(.system(size: 16, weight: .semibold))

                    ProgressView(value: Double(coordinator.playerProgress.experiencePoints),
                               total: Double(coordinator.playerProgress.experienceToNextLevel))
                        .frame(width: 150)
                        .tint(.purple)

                    Text("\(coordinator.playerProgress.experiencePoints) / \(coordinator.playerProgress.experienceToNextLevel) XP")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Stats
            HStack(spacing: 30) {
                StatItem(icon: "map.fill", value: "\(coordinator.playerProgress.exploredEras.count)", label: "Eras")
                StatItem(icon: "cube.fill", value: "\(coordinator.playerProgress.discoveredArtifacts.count)", label: "Artifacts")
                StatItem(icon: "questionmark.circle.fill", value: "\(coordinator.playerProgress.completedMysteries.count)", label: "Mysteries")
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

// MARK: - Era Card
struct EraCard: View {
    let era: HistoricalEra
    let isSelected: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: isUnlocked ? [.blue.opacity(0.6), .purple.opacity(0.6)] : [.gray.opacity(0.3), .gray.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 120)
                .overlay {
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Image(systemName: "pyramid.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(era.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isUnlocked ? .primary : .secondary)

                Text(era.period)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text(era.civilization)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 220, height: 240)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)

            Text(value)
                .font(.system(size: 20, weight: .bold))

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Timeline Effect (Placeholder)
struct TimelineEffect: View {
    var body: some View {
        // Animated background effect representing time travel
        GeometryReader { geometry in
            ForEach(0..<20) { i in
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 30, height: 30)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
}

// MARK: - Progress Dashboard View (Placeholder)
struct ProgressDashboardView: View {
    let progress: PlayerProgress

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Player Stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Progress")
                            .font(.system(size: 36, weight: .bold))

                        HStack(spacing: 40) {
                            ProgressStat(title: "Level", value: "\(progress.currentLevel)", icon: "star.fill")
                            ProgressStat(title: "Experience", value: "\(progress.experiencePoints)", icon: "bolt.fill")
                            ProgressStat(title: "Eras Explored", value: "\(progress.exploredEras.count)", icon: "map.fill")
                            ProgressStat(title: "Artifacts Found", value: "\(progress.discoveredArtifacts.count)", icon: "cube.fill")
                        }
                    }

                    Divider()

                    // Skills
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Skills")
                            .font(.system(size: 28, weight: .semibold))

                        SkillBar(name: "Research", level: progress.researchSkill)
                        SkillBar(name: "Observation", level: progress.observationSkill)
                        SkillBar(name: "Conversation", level: progress.conversationSkill)
                        SkillBar(name: "Deduction", level: progress.deductionSkill)
                    }
                }
                .padding(40)
            }
            .navigationTitle("Progress Dashboard")
        }
    }
}

struct ProgressStat: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text(value)
                .font(.system(size: 28, weight: .bold))

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(width: 150)
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct SkillBar: View {
    let name: String
    let level: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .medium))

                Spacer()

                Text("Level \(level)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            ProgressView(value: Double(level), total: 10.0)
                .tint(.blue)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

// MARK: - Settings View (Placeholder)
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Comfort") {
                    Toggle("Break Reminders", isOn: .constant(true))
                    Toggle("Reduced Motion", isOn: .constant(false))
                }

                Section("Accessibility") {
                    Toggle("High Contrast", isOn: .constant(false))
                    Toggle("Large Text", isOn: .constant(false))
                    Toggle("Voice Control", isOn: .constant(false))
                }

                Section("Audio") {
                    Slider(value: .constant(0.8), in: 0...1) {
                        Text("Master Volume")
                    }
                    Toggle("Spatial Audio", isOn: .constant(true))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(GameCoordinator())
}
