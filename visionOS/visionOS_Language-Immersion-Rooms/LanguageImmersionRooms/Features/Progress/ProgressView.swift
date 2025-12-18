//
//  ProgressView.swift
//  Language Immersion Rooms
//
//  Simple progress tracking for MVP
//

import SwiftUI

struct ProgressDashboardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    // Today's Stats
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Today's Progress")
                            .font(.title2.bold())

                        HStack(spacing: 30) {
                            StatCard(
                                value: "\(appState.wordsEncounteredToday)",
                                label: "Words",
                                icon: "book.fill",
                                color: .blue
                            )

                            StatCard(
                                value: formatTime(appState.conversationTimeToday),
                                label: "Practice Time",
                                icon: "clock.fill",
                                color: .green
                            )

                            StatCard(
                                value: "\(appState.currentStreak)",
                                label: "Day Streak",
                                icon: "flame.fill",
                                color: .orange
                            )
                        }
                    }

                    // Progress Chart
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Learning Progress")
                            .font(.title2.bold())

                        ProgressChart(progress: appState.todayProgress)
                    }

                    // Motivation Message
                    VStack(spacing: 15) {
                        Text(motivationMessage)
                            .font(.title3)
                            .multilineTextAlignment(.center)

                        Text(motivationSubtext)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)

                    Spacer()
                }
                .padding(40)
            }
            .navigationTitle("Your Progress")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        return "\(minutes)m"
    }

    private var motivationMessage: String {
        if appState.currentStreak >= 7 {
            return "🎉 Amazing! 7+ day streak!"
        } else if appState.wordsEncounteredToday >= 20 {
            return "⭐ Great job today!"
        } else if appState.wordsEncounteredToday >= 10 {
            return "💪 Keep it up!"
        } else {
            return "🌱 Just getting started!"
        }
    }

    private var motivationSubtext: String {
        if appState.wordsEncounteredToday < 20 {
            return "Goal: 20 words per day"
        } else {
            return "You've hit your daily goal!"
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 36, weight: .bold))

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct ProgressChart: View {
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.2))

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 40)

            HStack {
                Text("\(Int(progress * 100))% of daily goal")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("20 words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProgressDashboardView()
        .environmentObject(AppState())
}
