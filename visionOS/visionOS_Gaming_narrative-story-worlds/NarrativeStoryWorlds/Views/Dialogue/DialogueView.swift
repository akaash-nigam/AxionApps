import SwiftUI
import RealityKit

/// SwiftUI view for displaying dialogue in 3D space
struct DialogueView: View {
    let dialogue: DialogueNode
    let characterName: String
    @State private var displayedText = ""
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Speaker name
            Text(characterName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            // Dialogue text with typewriter effect
            Text(displayedText)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            // Emotion indicator
            if dialogue.emotionalTone != .neutral {
                EmotionIndicator(emotion: dialogue.emotionalTone)
                    .opacity(0.7)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(maxWidth: 400)
        .task {
            await animateText()
        }
    }

    // MARK: - Text Animation

    private func animateText() async {
        isAnimating = true
        displayedText = ""

        let characters = Array(dialogue.text)
        for (index, character) in characters.enumerated() {
            displayedText.append(character)

            // Faster animation for spaces
            let delay: UInt64 = character == " " ? 10_000_000 : 30_000_000 // 0.01s or 0.03s

            try? await Task.sleep(nanoseconds: delay)
        }

        isAnimating = false
    }
}

/// Emotion indicator component
struct EmotionIndicator: View {
    let emotion: Emotion

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: emotionIcon)
                .font(.caption)
            Text(emotionText)
                .font(.caption2)
        }
        .foregroundStyle(emotionColor)
    }

    private var emotionIcon: String {
        switch emotion {
        case .happy: return "face.smiling"
        case .sad: return "face.dashed"
        case .angry: return "exclamationmark.triangle"
        case .surprised: return "exclamationmark.circle"
        case .fearful: return "exclamationmark.shield"
        case .loving: return "heart"
        default: return "circle"
        }
    }

    private var emotionText: String {
        emotion.rawValue.capitalized
    }

    private var emotionColor: Color {
        switch emotion {
        case .happy, .loving: return .green
        case .sad: return .blue
        case .angry: return .red
        case .surprised: return .orange
        case .fearful: return .purple
        default: return .gray
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleDialogue = DialogueNode(
        id: UUID(),
        speakerID: UUID(),
        text: "I need to tell you something important. This has been weighing on me for weeks.",
        audioClip: nil,
        responses: [],
        conditions: [],
        displayDuration: 5.0,
        autoAdvance: false,
        emotionalTone: .sad,
        facialAnimation: nil
    )

    return DialogueView(
        dialogue: sampleDialogue,
        characterName: "Sarah"
    )
    .frame(width: 500, height: 300)
}
