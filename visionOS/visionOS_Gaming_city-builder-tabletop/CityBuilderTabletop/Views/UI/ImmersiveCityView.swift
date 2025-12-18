import SwiftUI
import RealityKit

/// Immersive space view for full city experience
struct ImmersiveCityView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        RealityView { content in
            // TODO: Setup immersive RealityKit scene
            // This will be implemented in Phase 3
        }
    }
}

#Preview {
    ImmersiveCityView()
        .environment(GameCoordinator())
}
