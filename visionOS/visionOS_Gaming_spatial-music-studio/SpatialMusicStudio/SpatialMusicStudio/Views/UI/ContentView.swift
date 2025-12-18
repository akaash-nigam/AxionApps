import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var audioEngine: SpatialAudioEngine
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    // Title
                    VStack(spacing: 10) {
                        Text("Spatial Music Studio")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("Compose symphonies in three-dimensional sound space")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    // Main Actions
                    VStack(spacing: 20) {
                        MainMenuButton(
                            icon: "music.note.list",
                            title: "New Composition",
                            description: "Create a new musical piece"
                        ) {
                            appCoordinator.createNewComposition()
                            Task {
                                await openImmersiveSpace(id: "MusicStudio")
                            }
                        }

                        MainMenuButton(
                            icon: "folder.fill",
                            title: "Open Project",
                            description: "Continue working on a saved composition"
                        ) {
                            // Show project browser
                        }

                        MainMenuButton(
                            icon: "graduationcap.fill",
                            title: "Learning Center",
                            description: "Interactive music theory lessons"
                        ) {
                            appCoordinator.startLearning()
                            Task {
                                await openImmersiveSpace(id: "MusicStudio")
                            }
                        }

                        MainMenuButton(
                            icon: "person.2.fill",
                            title: "Collaborate",
                            description: "Create music with others"
                        ) {
                            Task {
                                await appCoordinator.startCollaboration()
                                await openImmersiveSpace(id: "MusicStudio")
                            }
                        }
                    }
                    .frame(maxWidth: 500)

                    Spacer()

                    // Footer
                    HStack {
                        Button(action: {
                            // Show settings
                        }) {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .buttonStyle(.borderless)

                        Spacer()

                        Button(action: {
                            // Show help
                        }) {
                            Label("Help & Tutorials", systemImage: "questionmark.circle.fill")
                        }
                        .buttonStyle(.borderless)
                    }
                    .frame(maxWidth: 500)
                }
                .padding(40)
            }
        }
    }
}

// MARK: - Main Menu Button

struct MainMenuButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
        .environmentObject(SpatialAudioEngine.shared)
}
