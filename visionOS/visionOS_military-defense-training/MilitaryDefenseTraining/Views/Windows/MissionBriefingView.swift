//
//  MissionBriefingView.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct MissionBriefingView: View {
    let scenarioID: UUID

    @Environment(AppState.self) private var appState
    @Environment(SpaceManager.self) private var spaceManager
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.modelContext) private var modelContext

    @Query private var scenarios: [Scenario]

    private var scenario: Scenario? {
        scenarios.first { $0.id == scenarioID }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            if let scenario = scenario {
                VStack(spacing: 0) {
                    // Classification Banner
                    ClassificationBanner(classification: scenario.classification)

                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            BriefingHeader(scenario: scenario)

                            HStack(alignment: .top, spacing: 20) {
                                // Left Column - Mission Details
                                VStack(alignment: .leading, spacing: 16) {
                                    MissionDetails(scenario: scenario)
                                    ObjectivesList(objectives: scenario.objectives)
                                    EnemyForces(count: scenario.enemyCount)
                                }
                                .frame(maxWidth: .infinity)

                                // Right Column - Terrain & Loadout
                                VStack(spacing: 16) {
                                    TerrainPreview(environment: scenario.environment)
                                    LoadoutSelector()
                                }
                                .frame(width: 300)
                            }
                            .padding()

                            // Action Buttons
                            HStack(spacing: 16) {
                                Button("Close") {
                                    Task {
                                        await spaceManager.closeWindow(
                                            id: "briefing",
                                            dismissWindow
                                        )
                                    }
                                }
                                .buttonStyle(.bordered)

                                Button("Tactical Planning") {
                                    Task {
                                        await spaceManager.openTacticalPlanning(
                                            scenarioID: scenario.id,
                                            openWindow
                                        )
                                    }
                                }
                                .buttonStyle(.bordered)

                                Button("Start Training") {
                                    appState.startSession(scenario: scenario)
                                    Task {
                                        await spaceManager.startCombatTraining(
                                            openImmersiveSpace,
                                            dismissWindow
                                        )
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                        }
                    }

                    // Classification Banner
                    ClassificationBanner(classification: scenario.classification)
                }
            } else {
                Text("Scenario not found")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Briefing Header
struct BriefingHeader: View {
    let scenario: Scenario

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: scenario.type.iconName)
                    .font(.system(size: 40))

                VStack(alignment: .leading) {
                    Text(scenario.name)
                        .font(.largeTitle)
                        .bold()

                    Text("Mission Briefing")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                DifficultyBadge(difficulty: scenario.difficulty)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
}

// MARK: - Mission Details
struct MissionDetails: View {
    let scenario: Scenario

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mission Details")
                .font(.headline)

            Divider()

            Text(scenario.scenarioDescription)
                .font(.body)

            HStack(spacing: 24) {
                DetailItem(
                    icon: "clock",
                    label: "Duration",
                    value: "\(scenario.durationMinutes) min"
                )

                DetailItem(
                    icon: "map",
                    label: "Environment",
                    value: scenario.environment.rawValue
                )

                DetailItem(
                    icon: "calendar",
                    label: "Time",
                    value: "1400 hours"
                )
            }

            Text(scenario.environment.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct DetailItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .bold()
        }
    }
}

// MARK: - Objectives List
struct ObjectivesList: View {
    let objectives: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mission Objectives")
                .font(.headline)

            Divider()

            ForEach(Array(objectives.enumerated()), id: \.offset) { index, objective in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.blue)

                    Text(objective)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Enemy Forces
struct EnemyForces: View {
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enemy Forces")
                .font(.headline)

            Divider()

            HStack {
                Image(systemName: "person.3.fill")
                    .font(.title)
                    .foregroundStyle(.red)

                VStack(alignment: .leading) {
                    Text("\(count) Combatants")
                        .font(.subheadline)
                        .bold()

                    Text("Light Infantry")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text("Intelligence indicates light infantry with small arms. Possible sniper threat.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Terrain Preview
struct TerrainPreview: View {
    let environment: EnvironmentType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Terrain")
                .font(.headline)

            // Placeholder for 3D terrain preview
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 200)

                VStack {
                    Image(systemName: environment == .urban ? "building.2" : "mountain.2")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("Tap to explore in 3D")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .cornerRadius(12)
        }
    }
}

// MARK: - Loadout Selector
struct LoadoutSelector: View {
    @State private var selectedLoadout: String = "Standard Infantry"

    let loadouts = [
        "Standard Infantry",
        "Close Quarters",
        "Designated Marksman",
        "Heavy Weapons"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Loadout")
                .font(.headline)

            Divider()

            Picker("Loadout", selection: $selectedLoadout) {
                ForEach(loadouts, id: \.self) { loadout in
                    Text(loadout).tag(loadout)
                }
            }
            .pickerStyle(.menu)

            // Weapons for selected loadout
            VStack(alignment: .leading, spacing: 8) {
                WeaponItem(name: "M4A1 Carbine", type: "Primary")
                WeaponItem(name: "M9 Beretta", type: "Secondary")
                WeaponItem(name: "Frag Grenades (×2)", type: "Lethal")
                WeaponItem(name: "Smoke Grenades (×2)", type: "Tactical")
                WeaponItem(name: "Med Kit", type: "Equipment")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct WeaponItem: View {
    let name: String
    let type: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.caption)

                Text(type)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    MissionBriefingView(scenarioID: UUID())
        .environment(AppState())
        .environment(SpaceManager())
}
