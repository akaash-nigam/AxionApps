import SwiftUI

/// Main menu view for browsing performances
struct MainMenuView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Interactive Theater")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Transform your space into immersive theatrical performances")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                // Placeholder for performance library
                VStack(spacing: 20) {
                    Button("Explore Performances") {
                        // Navigate to library
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Continue Last Performance") {
                        // Resume saved performance
                    }
                    .buttonStyle(.bordered)

                    Button("Settings") {
                        // Open settings
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppCoordinator())
}
