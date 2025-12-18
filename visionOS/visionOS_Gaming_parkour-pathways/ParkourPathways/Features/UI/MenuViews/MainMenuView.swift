//
//  MainMenuView.swift
//  Parkour Pathways
//
//  Main menu interface
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var gameStateManager: GameStateManager

    @State private var selectedTab: MenuTab = .play
    @State private var showingCourseSelector = false

    enum MenuTab {
        case play
        case training
        case leaderboards
        case profile
        case settings
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                header

                // Main Content
                mainContent

                // Footer Status
                playerStatus
            }
            .padding(40)
            .frame(width: 800, height: 600)
            .background(Color.black.opacity(0.8))
        }
        .sheet(isPresented: $showingCourseSelector) {
            CourseSelectorView()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Text("PARKOUR PATHWAYS")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.cyan)

            Text("Transform your environment into the ultimate obstacle course")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            playTab
                .tag(MenuTab.play)

            trainingTab
                .tag(MenuTab.training)

            leaderboardsTab
                .tag(MenuTab.leaderboards)

            profileTab
                .tag(MenuTab.profile)

            settingsTab
                .tag(MenuTab.settings)
        }
        .tabViewStyle(.page)
    }

    // MARK: - Play Tab

    private var playTab: some View {
        VStack(spacing: 20) {
            // Large Play Button
            Button(action: {
                showingCourseSelector = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: 40))
                    Text("PLAY")
                        .font(.system(size: 50, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.cyan)
                .foregroundColor(.black)
                .cornerRadius(20)
            }
            .buttonStyle(.plain)

            // Quick Actions
            HStack(spacing: 20) {
                quickActionButton(
                    icon: "book.fill",
                    title: "Training Programs",
                    action: { selectedTab = .training }
                )

                quickActionButton(
                    icon: "magnifyingglass",
                    title: "Course Browser",
                    action: { showingCourseSelector = true }
                )
            }

            HStack(spacing: 20) {
                quickActionButton(
                    icon: "chart.bar.fill",
                    title: "Leaderboards",
                    action: { selectedTab = .leaderboards }
                )

                quickActionButton(
                    icon: "person.2.fill",
                    title: "Multiplayer",
                    action: { /* Start multiplayer */ }
                )
            }
        }
    }

    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Training Tab

    private var trainingTab: some View {
        VStack {
            Text("Training Programs")
                .font(.largeTitle)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
                    trainingProgramCard(
                        title: "Beginner Basics",
                        duration: "8 weeks",
                        icon: "figure.walk"
                    )

                    trainingProgramCard(
                        title: "Strength Building",
                        duration: "6 weeks",
                        icon: "dumbbell.fill"
                    )

                    trainingProgramCard(
                        title: "Speed Development",
                        duration: "4 weeks",
                        icon: "bolt.fill"
                    )

                    trainingProgramCard(
                        title: "Advanced Techniques",
                        duration: "10 weeks",
                        icon: "star.fill"
                    )
                }
            }
        }
    }

    private func trainingProgramCard(title: String, duration: String, icon: String) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.cyan)

            Text(title)
                .font(.headline)

            Text(duration)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Leaderboards Tab

    private var leaderboardsTab: some View {
        VStack {
            Text("Global Leaderboards")
                .font(.largeTitle)

            List {
                ForEach(1...10, id: \.self) { rank in
                    HStack {
                        Text("#\(rank)")
                            .font(.headline)
                            .frame(width: 50)

                        Text("Player \(rank)")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("12:34.56")
                            .font(.system(.body, design: .monospaced))

                        Text("9,450")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                }
            }
        }
    }

    // MARK: - Profile Tab

    private var profileTab: some View {
        VStack(spacing: 20) {
            Text("Player Profile")
                .font(.largeTitle)

            // Player stats
            HStack(spacing: 40) {
                statCard(label: "Level", value: "12")
                statCard(label: "XP", value: "2,450")
                statCard(label: "Courses", value: "47")
            }

            // Achievements
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Achievements")
                    .font(.headline)

                HStack(spacing: 15) {
                    achievementBadge(icon: "🎯", name: "Precision Expert")
                    achievementBadge(icon: "⚡", name: "Speed Demon")
                    achievementBadge(icon: "🏃", name: "Vault Master")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
    }

    private func statCard(label: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.cyan)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func achievementBadge(icon: String, name: String) -> some View {
        VStack {
            Text(icon)
                .font(.system(size: 40))
            Text(name)
                .font(.caption2)
        }
        .frame(width: 80, height: 80)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Settings Tab

    private var settingsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)

            Form {
                Section("Audio") {
                    HStack {
                        Text("Volume")
                        Slider(value: .constant(0.8))
                    }
                }

                Section("Difficulty") {
                    Picker("Preferred Difficulty", selection: .constant(DifficultyLevel.medium)) {
                        ForEach([DifficultyLevel.easy, .medium, .hard, .expert], id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                }

                Section("Accessibility") {
                    Toggle("Show Tutorials", isOn: .constant(true))
                    Toggle("High Contrast Mode", isOn: .constant(false))
                    Toggle("Reduce Motion", isOn: .constant(false))
                }
            }
        }
    }

    // MARK: - Player Status

    private var playerStatus: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Level 12 - Intermediate Traceur")
                    .font(.caption)

                Spacer()

                Text("Daily Streak: 7 days 🔥")
                    .font(.caption)
            }

            ProgressView(value: 0.49)
                .tint(.cyan)

            HStack {
                Text("2,450 XP")
                    .font(.caption2)
                Spacer()
                Text("5,000 XP to Advanced")
                    .font(.caption2)
            }
            .foregroundColor(.gray)
        }
        .padding(.top, 10)
    }
}

// MARK: - Course Selector View

struct CourseSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator

    @State private var selectedDifficulty: DifficultyLevel?
    @State private var selectedCourse: CourseData?

    var body: some View {
        NavigationStack {
            VStack {
                // Filters
                HStack {
                    ForEach([DifficultyLevel.easy, .medium, .hard, .expert], id: \.self) { level in
                        Button(level.displayName) {
                            selectedDifficulty = level
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedDifficulty == level ? .cyan : .gray)
                    }
                }
                .padding()

                // Course List
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 20) {
                        // Sample courses
                        ForEach(1...6, id: \.self) { index in
                            courseCard(
                                name: "Course \(index)",
                                difficulty: .medium,
                                duration: "3-4 min",
                                obstacles: 12
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func courseCard(name: String, difficulty: DifficultyLevel, duration: String, obstacles: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Text(difficulty.displayName)
                    .font(.caption)
                    .padding(4)
                    .background(Color(difficulty.color))
                    .cornerRadius(4)
            }

            Text("\(obstacles) obstacles • \(duration)")
                .font(.caption)
                .foregroundColor(.gray)

            Button("Play") {
                // Start course
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
        .environmentObject(AppCoordinator())
        .environmentObject(GameStateManager())
}
