import SwiftUI

struct MainMenuView: View {
    @State private var detectiveName = ""
    @State private var showImmersive = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Mystery Investigation")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Solve Crimes in Spatial Reality")
                    .font(.title)
                    .foregroundStyle(.secondary)

                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)

                    TextField("Detective Name", text: $detectiveName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .frame(maxWidth: 400)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)

                VStack(spacing: 15) {
                    Button(action: startInvestigation) {
                        Label("Start Investigation", systemImage: "person.badge.key")
                            .font(.title2)
                            .padding()
                            .frame(minWidth: 350)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(detectiveName.isEmpty)

                    Button(action: { }) {
                        Label("Case Files", systemImage: "folder.fill")
                            .font(.title3)
                            .padding()
                            .frame(minWidth: 350)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(60)
        }
    }

    func startInvestigation() {
        Task {
            if showImmersive {
                await dismissImmersiveSpace()
                showImmersive = false
            } else {
                await openImmersiveSpace(id: "CrimeScene")
                showImmersive = true
            }
        }
    }
}

#Preview {
    MainMenuView()
}
