import SwiftUI
import RealityKit

struct FinancialUniverseSpace: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            let universe = createFinancialUniverse()
            content.add(universe)
        }
    }

    private func createFinancialUniverse() -> Entity {
        let root = Entity()

        // Revenue streams as flowing rivers (particle systems)
        // Cost centers as planetary systems
        // Profit margins as mountain terrain
        // Cash position as ocean level

        return root
    }
}

#Preview {
    FinancialUniverseSpace()
        .environment(AppState())
}
