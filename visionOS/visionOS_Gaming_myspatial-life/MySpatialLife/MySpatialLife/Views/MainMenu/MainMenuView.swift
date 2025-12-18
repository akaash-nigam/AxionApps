import SwiftUI

struct MainMenuView: View {
    @Environment(AppState.self) private var appState
    @Environment(GameCoordinator.self) private var gameCoordinator

    var body: some View {
        VStack(spacing: 30) {
            Text("MySpatial Life")
                .font(.system(size: 60, weight: .bold))
                .padding(.top, 50)

            Spacer()

            VStack(spacing: 20) {
                Button("Continue") {
                    // TODO: Load last save
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("New Family") {
                    appState.currentScene = .familyCreation
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Load Game") {
                    // TODO: Show load menu
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Settings") {
                    appState.currentScene = .settings
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Spacer()

            Text("Generation: 1 | Play Time: 0h")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
        }
        .padding()
        .frame(width: 800, height: 600)
    }
}

#Preview {
    MainMenuView()
        .environment(AppState())
        .environment(GameCoordinator())
}
