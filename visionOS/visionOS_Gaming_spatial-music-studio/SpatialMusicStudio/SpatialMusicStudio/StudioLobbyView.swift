import SwiftUI

struct StudioLobbyView: View {
    @State private var projectName = ""
    @State private var selectedGenre: MusicGenre = .electronic
    @State private var isRecording = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Spatial Music Studio")
                    .font(.system(size: 65, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.pink, .purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Create Music in 3D Space")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(spacing: 25) {
                    // Project info
                    VStack(alignment: .leading, spacing: 15) {
                        TextField("Project Name", text: $projectName)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)

                        Picker("Genre", selection: $selectedGenre) {
                            ForEach(MusicGenre.allCases) { genre in
                                HStack {
                                    Text(genre.icon)
                                    Text(genre.rawValue)
                                }
                                .tag(genre)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)

                    // Studio features
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        FeatureCard(icon: "waveform", title: "Spatial Audio", color: .pink)
                        FeatureCard(icon: "music.mic", title: "Voice Recording", color: .purple)
                        FeatureCard(icon: "pianokeys", title: "Virtual Instruments", color: .blue)
                        FeatureCard(icon: "music.note.list", title: "MIDI Controller", color: .cyan)
                    }
                }
                .padding()

                Button(action: enterStudio) {
                    Label("Enter Studio", systemImage: "music.note.house.fill")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(projectName.isEmpty)
            }
            .padding(60)
        }
    }

    func enterStudio() {
        Task {
            if isRecording {
                await dismissImmersiveSpace()
                isRecording = false
            } else {
                await openImmersiveSpace(id: "MusicStudio")
                isRecording = true
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)

            Text(title)
                .font(.callout)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.2))
        .cornerRadius(12)
    }
}

enum MusicGenre: String, CaseIterable, Identifiable {
    case electronic = "Electronic"
    case rock = "Rock"
    case jazz = "Jazz"
    case classical = "Classical"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .electronic: return "🎹"
        case .rock: return "🎸"
        case .jazz: return "🎷"
        case .classical: return "🎻"
        }
    }
}

#Preview {
    StudioLobbyView()
}
