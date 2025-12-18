//
//  AfterActionReviewView.swift
//  MilitaryDefenseTraining
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct AfterActionReviewView: View {
    let sessionID: UUID

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query private var sessions: [TrainingSession]

    private var session: TrainingSession? {
        sessions.first { $0.id == sessionID }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack {
                ClassificationBanner(classification: appState.securityContext.sessionClassification)

                if let session = session {
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("After Action Review")
                                .font(.largeTitle)
                                .bold()

                            // Mission Success
                            VStack(spacing: 12) {
                                Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(session.isCompleted ? .green : .red)

                                Text(session.isCompleted ? "Mission Complete" : "Mission Failed")
                                    .font(.title)
                                    .bold()

                                Text("Score: \(session.score)/1000")
                                    .font(.title2)

                                if session.performanceData != nil {
                                    Text("Grade: B+")
                                        .font(.title3)
                                        .foregroundStyle(.orange)
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)

                            // Performance Summary (Placeholder)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Performance Summary")
                                    .font(.headline)

                                Text("Detailed performance metrics will be displayed here")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)

                            // Actions
                            HStack(spacing: 16) {
                                Button("Retry Mission") {
                                    appState.returnToMissionSelect()
                                }
                                .buttonStyle(.bordered)

                                Button("Continue") {
                                    appState.returnToMissionSelect()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("Session not found")
                        .foregroundStyle(.secondary)
                }

                ClassificationBanner(classification: appState.securityContext.sessionClassification)
            }
        }
    }
}

#Preview {
    AfterActionReviewView(sessionID: UUID())
        .environment(AppState())
}
