import SwiftUI
import RealityKit

/// Main volumetric view displaying the city
struct CityVolumeView: View {
    @Environment(GameCoordinator.self) private var coordinator

    var body: some View {
        RealityView { content in
            // TODO: Setup RealityKit scene
            // This will be implemented in Phase 2
        }
        .overlay(alignment: .topLeading) {
            // Tool palette overlay
            ToolPaletteView()
        }
        .overlay(alignment: .topTrailing) {
            // Statistics panel overlay
            StatisticsPanelView()
        }
    }
}

#Preview {
    CityVolumeView()
        .environment(GameCoordinator())
}
