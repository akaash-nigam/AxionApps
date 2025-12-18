//
//  InvestigationHUDView.swift
//  Mystery Investigation
//
//  Heads-up display during investigation
//

import SwiftUI

struct InvestigationHUDView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            // Top-center objective
            VStack {
                ObjectivePanel()
                    .padding(.top, 40)

                Spacer()

                // Bottom-left evidence count
                HStack {
                    EvidenceCountPanel()
                        .padding(.leading, 40)
                        .padding(.bottom, 40)

                    Spacer()

                    // Right-side tool belt (would be 3D in production)
                    ToolBeltPanel()
                        .padding(.trailing, 40)
                        .padding(.bottom, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ObjectivePanel: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 10) {
            if let caseData = coordinator.activeCase {
                Text(caseData.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Find evidence and question suspects")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(10)
    }
}

struct EvidenceCountPanel: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        if let progress = coordinator.progress,
           let caseData = coordinator.activeCase {
            VStack(alignment: .leading, spacing: 5) {
                Text("Evidence Collected")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(progress.discoveredEvidence.count) / \(caseData.evidence.count)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)

                ProgressView(value: Float(progress.discoveredEvidence.count), total: Float(caseData.evidence.count))
                    .tint(.yellow)
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
        }
    }
}

struct ToolBeltPanel: View {
    @State private var selectedTool: String?

    let tools = ["Magnifying Glass", "UV Light", "Fingerprint Kit"]

    var body: some View {
        VStack(spacing: 10) {
            Text("Tools")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(tools, id: \.self) { tool in
                Button(action: {
                    selectedTool = tool
                }) {
                    Text(tool)
                        .font(.caption)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedTool == tool ? Color.yellow.opacity(0.3) : Color.clear)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.yellow, lineWidth: selectedTool == tool ? 2 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(10)
    }
}

// MARK: - Supporting Views

struct PauseMenuView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        Text("Pause Menu")
            .font(.largeTitle)
    }
}

struct CaseSummaryView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        Text("Case Summary")
            .font(.largeTitle)
    }
}

struct EvidenceExaminationView: View {
    var body: some View {
        Text("Evidence Examination")
            .font(.largeTitle)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
    }
}

#Preview {
    InvestigationHUDView()
        .environment(GameCoordinator())
}
