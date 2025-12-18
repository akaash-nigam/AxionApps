import SwiftUI

struct MainMenuView: View {
    @State private var playerName = ""
    @State private var selectedClass: CharacterClass = .warrior
    @State private var isInGame = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Reality Realms RPG")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Spatial Role-Playing Adventure")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 20) {
                    TextField("Hero Name", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)

                    Picker("Class", selection: $selectedClass) {
                        ForEach(CharacterClass.allCases) { charClass in
                            HStack {
                                Text(charClass.icon)
                                Text(charClass.rawValue)
                            }
                            .tag(charClass)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)

                Button(action: startAdventure) {
                    Label("Begin Adventure", systemImage: "sparkles")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 300)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(playerName.isEmpty)
            }
            .padding(60)
        }
    }

    func startAdventure() {
        Task {
            if isInGame {
                await dismissImmersiveSpace()
                isInGame = false
            } else {
                await openImmersiveSpace(id: "rpgworld")
                isInGame = true
            }
        }
    }
}

enum CharacterClass: String, CaseIterable, Identifiable {
    case warrior = "Warrior"
    case mage = "Mage"
    case rogue = "Rogue"
    case ranger = "Ranger"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .warrior: return "⚔️"
        case .mage: return "🔮"
        case .rogue: return "🗡️"
        case .ranger: return "🏹"
        }
    }
}

#Preview {
    MainMenuView()
}
