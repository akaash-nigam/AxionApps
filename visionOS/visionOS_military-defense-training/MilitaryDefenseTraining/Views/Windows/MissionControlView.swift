//
//  MissionControlView.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct MissionControlView: View {
    @Environment(AppState.self) private var appState
    @Environment(SpaceManager.self) private var spaceManager
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext

    @Query private var scenarios: [Scenario]
    @Query(sort: \TrainingSession.startTime, order: .reverse)
    private var recentSessions: [TrainingSession]

    @State private var selectedScenario: Scenario?

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Classification Banner (Top)
                ClassificationBanner(
                    classification: appState.securityContext.sessionClassification
                )

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HeaderSection()

                        // Main Content Grid
                        HStack(alignment: .top, spacing: 20) {
                            // Left Column - Scenarios
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Available Scenarios")
                                    .font(.title2)
                                    .bold()

                                if scenarios.isEmpty {
                                    EmptyScenarioView()
                                } else {
                                    ForEach(scenarios) { scenario in
                                        ScenarioCard(scenario: scenario) {
                                            selectedScenario = scenario
                                            Task {
                                                await spaceManager.openBriefing(
                                                    scenarioID: scenario.id,
                                                    openWindow
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)

                            // Right Column - Profile & Stats
                            VStack(alignment: .leading, spacing: 16) {
                                if let warrior = appState.currentUser {
                                    WarriorProfileCard(warrior: warrior)
                                }

                                RecentSessionsList(sessions: recentSessions.prefix(5))
                            }
                            .frame(width: 300)
                        }
                        .padding()
                    }
                }

                // Classification Banner (Bottom)
                ClassificationBanner(
                    classification: appState.securityContext.sessionClassification
                )
            }
        }
        .onAppear {
            loadSampleData()
        }
    }

    private func loadSampleData() {
        // Check if we need to create sample data
        if scenarios.isEmpty {
            createSampleScenarios()
        }

        // Create sample user if needed
        if appState.currentUser == nil {
            createSampleWarrior()
        }
    }

    private func createSampleScenarios() {
        let sampleScenarios = [
            Scenario(
                name: "Urban Assault",
                type: .urbanAssault,
                difficulty: .medium,
                durationMinutes: 30,
                scenarioDescription: "Clear hostile forces from urban environment",
                objectives: ["Secure Building A", "Neutralize Enemy Squad", "Establish Perimeter"],
                enemyCount: 15,
                environment: .urban,
                isDownloaded: true
            ),
            Scenario(
                name: "Desert Patrol",
                type: .desertPatrol,
                difficulty: .easy,
                durationMinutes: 20,
                scenarioDescription: "Patrol desert sector and engage enemy contacts",
                objectives: ["Complete Patrol Route", "Identify Threats", "Report Enemy Positions"],
                enemyCount: 8,
                environment: .desert,
                isDownloaded: true
            ),
            Scenario(
                name: "Building Clearance",
                type: .buildingClearance,
                difficulty: .hard,
                durationMinutes: 45,
                scenarioDescription: "Clear multi-story building of hostile forces",
                objectives: ["Clear 1st Floor", "Clear 2nd Floor", "Clear 3rd Floor", "Secure Roof"],
                enemyCount: 20,
                environment: .urban,
                isDownloaded: true
            ),
        ]

        for scenario in sampleScenarios {
            modelContext.insert(scenario)
        }
    }

    private func createSampleWarrior() {
        let warrior = Warrior(
            rank: .sergeant,
            name: "John Doe",
            unit: "1st Battalion, 75th Ranger Regiment",
            specialization: .infantry,
            clearanceLevel: .secret,
            totalTrainingHours: 24.5,
            sessionsCompleted: 15,
            averageScore: 850
        )

        modelContext.insert(warrior)
        appState.authenticate(warrior: warrior)
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Military Defense Training")
                .font(.largeTitle)
                .bold()

            Text("Immersive Combat Training Platform")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }
}

// MARK: - Scenario Card
struct ScenarioCard: View {
    let scenario: Scenario
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: scenario.type.iconName)
                        .font(.title)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading) {
                        Text(scenario.name)
                            .font(.headline)

                        Text(scenario.type.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    DifficultyBadge(difficulty: scenario.difficulty)
                }

                Text(scenario.scenarioDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack {
                    Label("\(scenario.durationMinutes) min", systemImage: "clock")
                    Spacer()
                    Label("\(scenario.enemyCount) enemies", systemImage: "person.3")
                    Spacer()
                    Label(scenario.environment.rawValue, systemImage: "map")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: DifficultyLevel

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { index in
                Image(systemName: index < difficulty.stars ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(index < difficulty.stars ? .yellow : .gray)
            }
        }
    }
}

// MARK: - Warrior Profile Card
struct WarriorProfileCard: View {
    let warrior: Warrior

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Warrior Profile")
                .font(.headline)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Rank:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(warrior.rank.rawValue)
                        .bold()
                }

                HStack {
                    Text("Name:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(warrior.name)
                }

                HStack {
                    Text("Unit:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(warrior.unit)
                        .font(.caption)
                }

                HStack {
                    Text("Specialization:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label(warrior.specialization.rawValue, systemImage: warrior.specialization.iconName)
                }

                Divider()

                HStack {
                    Text("Training Hours:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f", warrior.totalTrainingHours))
                        .bold()
                }

                HStack {
                    Text("Sessions:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(warrior.sessionsCompleted)")
                        .bold()
                }

                HStack {
                    Text("Avg Score:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(warrior.averageScore))")
                        .bold()
                        .foregroundStyle(.green)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Recent Sessions List
struct RecentSessionsList: View {
    let sessions: any Sequence<TrainingSession>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Training")
                .font(.headline)

            if Array(sessions).isEmpty {
                Text("No training sessions yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(sessions), id: \.id) { session in
                    RecentSessionRow(session: session)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct RecentSessionRow: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.missionType.rawValue)
                .font(.subheadline)
                .bold()

            HStack {
                Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if session.isCompleted {
                    Text("Score: \(session.score)")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State
struct EmptyScenarioView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Scenarios Available")
                .font(.headline)

            Text("Download scenarios from the training library")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Classification Banner
struct ClassificationBanner: View {
    let classification: ClassificationLevel

    var body: some View {
        Text(classification.displayName)
            .font(.caption)
            .bold()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(hex: classification.bannerColor))
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MissionControlView()
        .environment(AppState())
        .environment(SpaceManager())
}
