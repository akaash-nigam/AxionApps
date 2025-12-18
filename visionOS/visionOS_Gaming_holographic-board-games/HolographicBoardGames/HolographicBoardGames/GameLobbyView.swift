import SwiftUI

struct GameLobbyView: View {
    @State private var selectedGame: BoardGame = .chess
    @State private var playerName = ""
    @State private var isPlaying = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Holographic Board Games")
                    .font(.system(size: 65, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Classic Games in Spatial Reality")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                // Game selection grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(BoardGame.allCases) { game in
                        GameCard(game: game, isSelected: selectedGame == game)
                            .onTapGesture {
                                selectedGame = game
                            }
                    }
                }
                .padding()

                TextField("Player Name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .frame(maxWidth: 400)

                Button(action: startGame) {
                    Label("Start Game", systemImage: "play.circle.fill")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .disabled(playerName.isEmpty)
            }
            .padding(60)
        }
    }

    func startGame() {
        Task {
            if isPlaying {
                await dismissImmersiveSpace()
                isPlaying = false
            } else {
                await openImmersiveSpace(id: "GameBoard")
                isPlaying = true
            }
        }
    }
}

struct GameCard: View {
    let game: BoardGame
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 15) {
            Text(game.icon)
                .font(.system(size: 60))

            Text(game.rawValue)
                .font(.title3)
                .fontWeight(.semibold)

            Text(game.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSelected ? Color.cyan.opacity(0.3) : Color.gray.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 3)
        )
    }
}

enum BoardGame: String, CaseIterable, Identifiable {
    case chess = "Chess"
    case checkers = "Checkers"
    case go = "Go"
    case backgammon = "Backgammon"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chess: return "♟️"
        case .checkers: return "⚫"
        case .go: return "⚪"
        case .backgammon: return "🎲"
        }
    }

    var description: String {
        switch self {
        case .chess: return "Classic strategy"
        case .checkers: return "Capture all pieces"
        case .go: return "Ancient strategy"
        case .backgammon: return "Race to victory"
        }
    }
}

#Preview {
    GameLobbyView()
}
