import SwiftUI

struct CaseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameCoordinator: GameCoordinator

    @StateObject private var caseManager = CaseManager()
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var selectedCase: Case?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                header

                // Difficulty Filter
                difficultyFilter

                // Case Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(filteredCases) { caseItem in
                            CaseCard(case: caseItem) {
                                selectedCase = caseItem
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Select Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedCase) { caseItem in
                CaseDetailView(case: caseItem) {
                    startCase(caseItem)
                }
            }
        }
    }

    // MARK: - Components

    private var header: some View {
        VStack(spacing: 8) {
            Text("Choose Your Investigation")
                .font(.title2)
                .fontWeight(.bold)

            Text("\(filteredCases.count) cases available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    private var difficultyFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                DifficultyFilterButton(
                    difficulty: nil,
                    isSelected: selectedDifficulty == nil
                ) {
                    selectedDifficulty = nil
                }

                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    DifficultyFilterButton(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty
                    ) {
                        selectedDifficulty = difficulty
                    }
                }
            }
            .padding()
        }
        .background(.regularMaterial)
    }

    private var filteredCases: [Case] {
        let allCases = caseManager.getAllCases()

        if let difficulty = selectedDifficulty {
            return allCases.filter { $0.difficulty == difficulty }
        }

        return allCases
    }

    // MARK: - Actions

    private func startCase(_ case: Case) {
        Task {
            do {
                try await gameCoordinator.startCase(case.id)
                dismiss()
            } catch {
                print("Failed to start case: \(error)")
            }
        }
    }
}

// MARK: - Case Card

struct CaseCard: View {
    let `case`: Case
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Case image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(difficultyColor.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: genreIcon)
                            .font(.system(size: 50))
                            .foregroundColor(difficultyColor)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(`case`.title)
                        .font(.headline)
                        .lineLimit(2)

                    // Metadata
                    HStack {
                        difficultyBadge

                        Spacer()

                        durationBadge
                    }

                    // Description
                    Text(`case`.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding(.horizontal, 8)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var difficultyBadge: some View {
        Text(`case`.difficulty.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.2))
            .foregroundColor(difficultyColor)
            .cornerRadius(4)
    }

    private var durationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
            Text("\(Int(`case`.estimatedDuration / 60)) min")
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }

    private var difficultyColor: Color {
        switch `case`.difficulty {
        case .story, .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .expert: return .purple
        }
    }

    private var genreIcon: String {
        switch `case`.genre {
        case .classicMystery: return "book.fill"
        case .modernThriller: return "newspaper.fill"
        case .historical: return "building.columns.fill"
        case .sciFi: return "sparkles"
        case .noir: return "moon.fill"
        case .trueCrimeInspired: return "eye.fill"
        case .educational: return "graduationcap.fill"
        case .comedy: return "face.smiling.fill"
        }
    }
}

// MARK: - Difficulty Filter Button

struct DifficultyFilterButton: View {
    let difficulty: DifficultyLevel?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(difficulty?.displayName ?? "All")
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

// MARK: - Case Detail View

struct CaseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let `case`: Case
    let onStart: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: 200)

                    VStack(alignment: .leading, spacing: 12) {
                        // Title
                        Text(`case`.title)
                            .font(.title)
                            .fontWeight(.bold)

                        // Metadata
                        HStack(spacing: 16) {
                            Label(`case`.difficulty.displayName, systemImage: "star.fill")
                            Label("\(Int(`case`.estimatedDuration / 60)) min", systemImage: "clock")
                            Label(`case`.genre.rawValue, systemImage: "tag")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Divider()

                        // Description
                        Text("Case Brief")
                            .font(.headline)

                        Text(`case`.description)
                            .font(.body)

                        Divider()

                        // Details
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Investigation Details")
                                .font(.headline)

                            DetailRow(title: "Evidence Pieces", value: "\(`case`.evidence.count)")
                            DetailRow(title: "Suspects", value: "\(`case`.suspects.count)")
                            DetailRow(title: "Locations", value: "\(`case`.locations.count)")
                        }

                        // Start button
                        Button(action: {
                            onStart()
                            dismiss()
                        }) {
                            Label("Begin Investigation", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Case Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    CaseSelectionView()
        .environmentObject(GameCoordinator())
}
