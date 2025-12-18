//
//  MainMenuView.swift
//  RhythmFlow
//
//  Main menu interface
//

import SwiftUI

struct MainMenuView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var selectedSong: Song?
    @State private var selectedDifficulty: Difficulty = .normal

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Title
                titleHeader

                // Main Menu Options
                menuGrid

                // Quick Play Section
                quickPlaySection
            }
            .padding(60)
            .navigationTitle("Rhythm Flow")
        }
        .frame(minWidth: 800, minHeight: 600)
    }

    // MARK: - Title Header
    private var titleHeader: some View {
        VStack(spacing: 10) {
            Text("🎵 RHYTHM FLOW 🎵")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Transform your space into a musical universe")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Menu Grid
    private var menuGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
            MenuButton(
                title: "PLAY",
                icon: "play.circle.fill",
                color: .blue
            ) {
                startQuickPlay()
            }

            MenuButton(
                title: "FITNESS",
                icon: "figure.run",
                color: .green
            ) {
                // TODO: Open fitness mode
            }

            MenuButton(
                title: "MULTIPLAYER",
                icon: "person.2.fill",
                color: .purple
            ) {
                // TODO: Open multiplayer
            }

            MenuButton(
                title: "CREATE",
                icon: "wand.and.stars",
                color: .orange
            ) {
                // TODO: Open creator mode
            }
        }
    }

    // MARK: - Quick Play
    private var quickPlaySection: some View {
        VStack(spacing: 20) {
            Text("Quick Play")
                .font(.title3.bold())

            HStack(spacing: 20) {
                // Song selection
                Menu {
                    ForEach(Song.sampleLibrary) { song in
                        Button(song.title) {
                            selectedSong = song
                        }
                    }
                } label: {
                    Label(
                        selectedSong?.title ?? "Select Song",
                        systemImage: "music.note.list"
                    )
                }
                .buttonStyle(.bordered)

                // Difficulty selection
                Menu {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button(difficulty.rawValue) {
                            selectedDifficulty = difficulty
                        }
                    }
                } label: {
                    Label(
                        selectedDifficulty.rawValue,
                        systemImage: "chart.bar.fill"
                    )
                }
                .buttonStyle(.bordered)

                // Start button
                Button {
                    startQuickPlay()
                } label: {
                    Label("START", systemImage: "play.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedSong == nil)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Actions
    private func startQuickPlay() {
        let song = selectedSong ?? Song.sampleSong

        Task {
            await openImmersiveSpace(id: "gameplay")
            coordinator.startSong(song, difficulty: selectedDifficulty)
            dismissWindow(id: "main-menu")
        }
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(color)

                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(color, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .frame(height: 200)
    }
}

// MARK: - Preview

#Preview {
    MainMenuView()
        .environment(AppCoordinator())
}
