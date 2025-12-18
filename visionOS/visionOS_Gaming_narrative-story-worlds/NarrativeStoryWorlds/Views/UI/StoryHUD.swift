import SwiftUI

/// Heads-up display for story progress and character relationships
struct StoryHUD: View {
    let currentChapter: Chapter?
    let characters: [Character]
    @State private var isVisible = true
    @State private var autoHideTask: Task<Void, Never>?

    var body: some View {
        VStack {
            // Top HUD
            if isVisible {
                TopHUDBar(chapter: currentChapter)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()

            // Bottom HUD (relationship indicators)
            if isVisible && !characters.isEmpty {
                BottomHUDBar(characters: characters)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear {
            scheduleAutoHide()
        }
        .onTapGesture {
            // Tapping brings back HUD temporarily
            showTemporarily()
        }
    }

    private func scheduleAutoHide() {
        autoHideTask?.cancel()
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            withAnimation {
                isVisible = false
            }
        }
    }

    private func showTemporarily() {
        withAnimation {
            isVisible = true
        }
        scheduleAutoHide()
    }
}

/// Top bar showing chapter progress
struct TopHUDBar: View {
    let chapter: Chapter?

    var body: some View {
        HStack {
            if let chapter = chapter {
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(.caption)
                        .fontWeight(.medium)

                    ChapterProgressBar(chapter: chapter)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}

/// Chapter progress indicator
struct ChapterProgressBar: View {
    let chapter: Chapter

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalScenes, id: \.self) { index in
                Circle()
                    .fill(index < completedScenes ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var totalScenes: Int {
        chapter.scenes.count
    }

    private var completedScenes: Int {
        // In production, count completed scenes
        min(totalScenes, 3)
    }
}

/// Bottom bar showing character relationships
struct BottomHUDBar: View {
    let characters: [Character]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(characters.prefix(3)) { character in
                CharacterRelationshipIndicator(character: character)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding()
    }
}

/// Individual character relationship indicator
struct CharacterRelationshipIndicator: View {
    let character: Character

    var body: some View {
        HStack(spacing: 8) {
            // Character name initial
            Text(character.name.prefix(1))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(relationshipColor))

            // Relationship hearts
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < filledHearts ? "heart.fill" : "heart")
                        .font(.caption2)
                        .foregroundStyle(index < filledHearts ? .red : .gray.opacity(0.3))
                }
            }
        }
    }

    private var trustLevel: Float {
        character.relationshipWithPlayer.trustLevel
    }

    private var filledHearts: Int {
        Int(trustLevel * 5)
    }

    private var relationshipColor: Color {
        switch character.relationshipWithPlayer.bondLevel {
        case .stranger: return .gray
        case .acquaintance: return .blue
        case .friend: return .green
        case .confidant: return .purple
        case .soulmate: return .pink
        case .nemesis: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleChapter = Chapter(
        id: UUID(),
        title: "Chapter 2: The Confession",
        scenes: [
            Scene(
                id: UUID(),
                location: .playerHome,
                characterIDs: [],
                storyBeats: [],
                requiredFlags: [],
                spatialConfiguration: SpatialConfiguration()
            ),
            Scene(
                id: UUID(),
                location: .playerHome,
                characterIDs: [],
                storyBeats: [],
                requiredFlags: [],
                spatialConfiguration: SpatialConfiguration()
            )
        ],
        completionState: .inProgress
    )

    let sampleCharacters = [
        Character(
            id: UUID(),
            name: "Sarah",
            bio: "A mysterious friend",
            appearance: CharacterAppearance(
                modelName: "sarah",
                texturePaths: [:],
                clothingLayers: []
            ),
            personality: Personality(
                openness: 0.7,
                conscientiousness: 0.8,
                extraversion: 0.5,
                agreeableness: 0.9,
                neuroticism: 0.4,
                loyalty: 0.8,
                deception: 0.2,
                vulnerability: 0.6
            ),
            emotionalState: EmotionalState(
                currentEmotion: .happy,
                intensity: 0.6,
                trust: 0.7,
                stress: 0.3,
                attraction: 0.5,
                fear: 0.2,
                history: []
            ),
            narrativeRole: .ally,
            relationshipWithPlayer: Relationship(characterID: UUID(), trustLevel: 0.7, bondLevel: .friend),
            storyFlags: []
        )
    ]

    return StoryHUD(currentChapter: sampleChapter, characters: sampleCharacters)
        .frame(width: 1000, height: 600)
}
