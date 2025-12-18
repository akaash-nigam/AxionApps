import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        @Bindable var appModel = appModel

        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.black.opacity(0.8), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    // Title
                    VStack(spacing: 10) {
                        Text("Narrative Story Worlds")
                            .font(.system(size: 48, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        Text("Your home becomes the story")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 60)

                    Spacer()

                    // Menu Options
                    VStack(spacing: 20) {
                        MenuButton(
                            title: "Continue Story",
                            icon: "play.fill",
                            action: { await continueStory() }
                        )
                        .disabled(!hasSavedGame)

                        MenuButton(
                            title: "New Story",
                            icon: "plus.circle.fill",
                            action: { await startNewStory() }
                        )

                        MenuButton(
                            title: "Settings",
                            icon: "gearshape.fill",
                            action: { appModel.currentState = .settings }
                        )
                    }
                    .padding(.horizontal, 60)

                    Spacer()

                    // Footer
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var hasSavedGame: Bool {
        // TODO: Check for saved game
        false
    }

    // MARK: - Actions
    private func startNewStory() async {
        await openImmersiveSpace(id: "StorySpace")
        appModel.isImmersiveSpaceShown = true
        await appModel.startNewStory()
    }

    private func continueStory() async {
        await openImmersiveSpace(id: "StorySpace")
        appModel.isImmersiveSpaceShown = true
        await appModel.continueStory()
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let title: String
    let icon: String
    let action: () async -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: { Task { await action() } }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title2)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .hoverEffect()
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
