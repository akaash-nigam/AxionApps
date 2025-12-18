//
//  CaseSelectionView.swift
//  Mystery Investigation
//
//  Case selection screen
//

import SwiftUI

struct CaseSelectionView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: {
                        coordinator.currentState = .mainMenu
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Select a Case")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)

                // Case grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                        ForEach(coordinator.caseManager.availableCases) { caseData in
                            CaseCard(caseData: caseData) {
                                coordinator.startNewCase(caseData)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
}

struct CaseCard: View {
    let caseData: CaseData
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                // Title and difficulty
                HStack {
                    Text(caseData.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    DifficultyStars(count: caseData.difficultyStars)
                }

                // Description
                Text(caseData.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(3)

                // Metadata
                HStack {
                    Label("\(Int(caseData.estimatedTime / 60)) min", systemImage: "clock")
                    Spacer()
                    Text(caseData.difficulty.rawValue.capitalized)
                }
                .font(.caption)
                .foregroundColor(.yellow)
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct DifficultyStars: View {
    let count: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index < count ? .yellow : .gray.opacity(0.3))
                    .font(.caption)
            }
        }
    }
}

#Preview {
    CaseSelectionView()
        .environment(GameCoordinator())
}
