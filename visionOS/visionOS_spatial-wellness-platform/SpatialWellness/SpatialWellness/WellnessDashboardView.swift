import SwiftUI

struct WellnessDashboardView: View {
    @State private var userName = ""
    @State private var selectedWorkout: WorkoutType = .cardio
    @State private var showWorkout = false
    @State private var todaySteps = 8234
    @State private var caloriesBurned = 542
    @State private var activeMinutes = 45
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Spatial Wellness")
                    .font(.system(size: 65, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Your Personal Fitness in 3D Space")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                // Daily stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    StatCard(icon: "figure.walk", title: "Steps", value: "\(todaySteps)", color: .blue)
                    StatCard(icon: "flame.fill", title: "Calories", value: "\(caloriesBurned)", color: .orange)
                    StatCard(icon: "clock.fill", title: "Active", value: "\(activeMinutes)m", color: .green)
                }
                .padding()

                VStack(alignment: .leading, spacing: 20) {
                    Text("Start Workout")
                        .font(.title3)
                        .fontWeight(.semibold)

                    TextField("Your Name", text: $userName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)

                    Picker("Workout Type", selection: $selectedWorkout) {
                        ForEach(WorkoutType.allCases) { type in
                            HStack {
                                Text(type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)

                // Workout programs
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    WorkoutCard(name: "Morning Yoga", duration: "20 min", difficulty: "Easy", color: .purple)
                    WorkoutCard(name: "HIIT Training", duration: "15 min", difficulty: "Hard", color: .red)
                    WorkoutCard(name: "Meditation", duration: "10 min", difficulty: "Easy", color: .blue)
                    WorkoutCard(name: "Strength", duration: "30 min", difficulty: "Medium", color: .orange)
                }
                .padding()

                Button(action: startWorkout) {
                    Label("Start Immersive Workout", systemImage: "figure.run")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(userName.isEmpty)
            }
            .padding(60)
        }
    }

    func startWorkout() {
        Task {
            if showWorkout {
                await dismissImmersiveSpace()
                showWorkout = false
            } else {
                await openImmersiveSpace(id: "WorkoutSpace")
                showWorkout = true
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}

struct WorkoutCard: View {
    let name: String
    let duration: String
    let difficulty: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }

            HStack {
                Label(duration, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(difficulty)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

enum WorkoutType: String, CaseIterable, Identifiable {
    case cardio = "Cardio"
    case strength = "Strength"
    case yoga = "Yoga"
    case meditation = "Meditation"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cardio: return "🏃"
        case .strength: return "💪"
        case .yoga: return "🧘"
        case .meditation: return "🧠"
        }
    }
}

#Preview {
    WellnessDashboardView()
}
