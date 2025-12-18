import SwiftUI

struct FamilyCreationView: View {
    @Environment(AppState.self) private var appState
    @Environment(GameCoordinator.self) private var gameCoordinator

    @State private var familyName: String = ""
    @State private var familySize: Int = 2

    var body: some View {
        VStack(spacing: 30) {
            Text("Create Your Family")
                .font(.system(size: 48, weight: .bold))

            Form {
                Section("Family Details") {
                    TextField("Family Name", text: $familyName)

                    Picker("Family Size", selection: $familySize) {
                        Text("2 Members").tag(2)
                        Text("3 Members").tag(3)
                        Text("4 Members").tag(4)
                    }
                }

                Section("Family Members") {
                    Text("Character creation coming soon...")
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Back") {
                    appState.currentScene = .mainMenu
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Start Game") {
                    // TODO: Create family and start game
                    Task {
                        let family = createPlaceholderFamily()
                        await gameCoordinator.startNewGame(family: family)
                        appState.launchGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(familyName.isEmpty)
            }
            .padding()
        }
        .padding()
    }

    private func createPlaceholderFamily() -> Family {
        let family = Family(
            familyName: familyName.isEmpty ? "The Smiths" : familyName,
            generation: 1,
            familyFunds: 20000
        )

        // Create placeholder characters
        let sarah = Character(
            firstName: "Sarah",
            lastName: familyName.isEmpty ? "Smith" : familyName,
            age: 25,
            gender: .female,
            personality: .random()
        )

        let mike = Character(
            firstName: "Mike",
            lastName: familyName.isEmpty ? "Smith" : familyName,
            age: 28,
            gender: .male,
            personality: .random()
        )

        family.addMember(sarah.id)
        family.addMember(mike.id)

        return family
    }
}

#Preview {
    FamilyCreationView()
        .environment(AppState())
        .environment(GameCoordinator())
}
