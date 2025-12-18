import SwiftUI
import RealityKit

/// Training mode view for skill development
struct TrainingView: View {

    @EnvironmentObject private var gameCoordinator: GameCoordinator

    var body: some View {
        RealityView { content in
            // Setup training scene
        }
        .overlay {
            VStack {
                Text("Training Mode")
                    .font(.title)
                    .foregroundColor(.white)

                Spacer()

                Button("Exit Training") {
                    Task {
                        await gameCoordinator.quitToMainMenu()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}
