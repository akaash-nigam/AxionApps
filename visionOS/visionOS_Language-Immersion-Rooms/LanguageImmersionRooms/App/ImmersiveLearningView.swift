//
//  ImmersiveLearningView.swift
//  Language Immersion Rooms
//
//  Immersive learning experience view
//

import SwiftUI
import RealityKit

struct ImmersiveLearningView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneManager: SceneManager
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            // Setup RealityKit scene with content
            await sceneManager.setupScene(content: content)
        } update: { content in
            // Update scene based on state changes
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .overlay(alignment: .topTrailing) {
            ControlsOverlay()
        }
        .overlay(alignment: .bottom) {
            if sceneManager.isInConversation {
                ConversationBottomBar()
            }
        }
        .overlay(alignment: .center) {
            if let grammarCard = sceneManager.currentGrammarCard {
                GrammarCardView(error: grammarCard)
            }
        }
    }

    private func handleTap(on entity: Entity) {
        // Handle label taps for pronunciation
        print("👆 Tapped entity: \(entity.name)")
        sceneManager.handleLabelTap(on: entity)
    }
}

struct ControlsOverlay: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneManager: SceneManager
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 15) {
            // Exit button
            Button {
                exitSession()
            } label: {
                Label("Exit", systemImage: "xmark.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.bordered)

            Divider()
                .frame(width: 150)

            // Toggle labels
            Button {
                sceneManager.toggleLabels()
            } label: {
                Label(
                    sceneManager.showLabels ? "Hide Labels" : "Show Labels",
                    systemImage: sceneManager.showLabels ? "tag.slash" : "tag"
                )
            }
            .buttonStyle(.bordered)

            // Scan room
            Button {
                Task {
                    await sceneManager.startObjectDetection()
                }
            } label: {
                Label(
                    sceneManager.isScanning ? "Scanning..." : "Scan Room",
                    systemImage: "viewfinder"
                )
            }
            .buttonStyle(.bordered)
            .disabled(sceneManager.isScanning)

            Divider()
                .frame(width: 150)

            // Start/Stop conversation
            Button {
                if sceneManager.isInConversation {
                    sceneManager.endConversation()
                } else {
                    Task {
                        await sceneManager.startConversation()
                    }
                }
            } label: {
                Label(
                    sceneManager.isInConversation ? "End Chat" : "Start Chat",
                    systemImage: sceneManager.isInConversation ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(30)
    }

    private func exitSession() {
        appState.endLearningSession()
        sceneManager.cleanup()

        Task {
            await dismissImmersiveSpace()
        }
    }
}

struct ConversationBottomBar: View {
    @EnvironmentObject var sceneManager: SceneManager

    var body: some View {
        HStack(spacing: 20) {
            // Character info
            if let character = sceneManager.currentCharacter {
                VStack(alignment: .leading, spacing: 5) {
                    Text(character.name)
                        .font(.headline)
                    Text("Spanish Tutor")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Last message
            VStack(alignment: .leading, spacing: 5) {
                Text("Last Message:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(sceneManager.lastMessage.isEmpty ? "Start speaking..." : sceneManager.lastMessage)
                    .font(.body)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Microphone button
            Button {
                if sceneManager.isListening {
                    sceneManager.stopListening()
                } else {
                    sceneManager.startListening()
                }
            } label: {
                Image(systemName: sceneManager.isListening ? "mic.fill" : "mic")
                    .font(.system(size: 24))
                    .foregroundColor(sceneManager.isListening ? .red : .primary)
                    .padding()
                    .background(sceneManager.isListening ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
    }
}

struct GrammarCardView: View {
    let error: GrammarError
    @EnvironmentObject var sceneManager: SceneManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Grammar Tip")
                    .font(.headline)

                Spacer()

                Button {
                    sceneManager.dismissGrammarCard()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Error
            VStack(alignment: .leading, spacing: 5) {
                Text("You said:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(error.incorrectPhrase)
                    .font(.body)
                    .foregroundColor(.red)
            }

            // Correction
            VStack(alignment: .leading, spacing: 5) {
                Text("Correct:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(error.correctPhrase)
                    .font(.body)
                    .foregroundColor(.green)
            }

            Divider()

            // Explanation
            Text(error.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 400)
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

// MARK: - Preview

#Preview {
    ImmersiveLearningView()
        .environmentObject(AppState())
        .environmentObject(SceneManager())
}
