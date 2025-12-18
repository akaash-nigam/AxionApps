import SwiftUI
import RealityKit

struct FamilyVolumeView: View {
    @Environment(AppState.self) private var appState
    @Environment(GameCoordinator.self) private var gameCoordinator

    var body: some View {
        RealityView { content in
            // TODO: Add character entities
            // TODO: Add spatial anchors
            // For now, add a placeholder
            let mesh = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])

            content.add(entity)
        }
        .overlay(alignment: .topLeading) {
            FamilyHUDView()
                .padding()
        }
    }
}

struct FamilyHUDView: View {
    @Environment(GameCoordinator.self) private var gameCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let family = gameCoordinator.currentFamily {
                Text(family.familyName)
                    .font(.headline)

                Text("Generation: \(family.generation)")
                    .font(.caption)

                Text("Funds: $\(family.familyFunds)")
                    .font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    FamilyVolumeView()
        .environment(AppState())
        .environment(GameCoordinator())
}
