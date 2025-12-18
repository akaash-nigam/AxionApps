import SwiftUI
import RealityKit

struct ImmersiveGameView: View {
    @Environment(AppState.self) private var appState
    @Environment(GameCoordinator.self) private var gameCoordinator

    var body: some View {
        RealityView { content in
            // TODO: Add immersive space content
            // TODO: Add ARKit world tracking
            // TODO: Add character entities in real space

            // Placeholder for now
            let mesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = [0, 1.5, -1]

            content.add(entity)
        }
    }
}

#Preview {
    ImmersiveGameView()
        .environment(AppState())
        .environment(GameCoordinator())
}
