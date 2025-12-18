import SwiftUI
import RealityKit

struct CollaborationSpaceView: View {
    @Environment(AppModel.self) private var appModel
    @State private var connectedUsers: [CollaborationUser] = []

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()

            // Shared visualization space
            let sharedSpace = createSharedVisualizationSpace()
            sharedSpace.position = [0, 1.5, -3.0]
            rootEntity.addChild(sharedSpace)

            // User presence indicators
            for (index, user) in connectedUsers.enumerated() {
                let indicator = createUserPresenceIndicator(user: user, index: index)
                rootEntity.addChild(indicator)
            }

            content.add(rootEntity)

            // Lighting
            let light = DirectionalLight()
            light.light.intensity = 400
            content.add(light)
        }
        .task {
            loadCollaborationUsers()
        }
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Collaboration")
                    .font(.headline)

                Text("\(connectedUsers.count) users connected")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(connectedUsers) { user in
                    HStack {
                        Circle()
                            .fill(user.color)
                            .frame(width: 8, height: 8)

                        Text(user.name)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            .padding()
        }
    }

    private func createSharedVisualizationSpace() -> Entity {
        let space = Entity()

        // Create a shared 3D visualization that all users can see
        let mesh = MeshResource.generateBox(size: 1.0)
        let material = SimpleMaterial(color: .white.withAlphaComponent(0.1), isMetallic: false)
        space.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        return space
    }

    private func createUserPresenceIndicator(user: CollaborationUser, index: Int) -> Entity {
        let indicator = Entity()

        // Create a sphere representing the user's view position
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: user.color, isMetallic: true)
        indicator.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        // Position around the shared space
        let angle = Float(index) * (2 * .pi / Float(connectedUsers.count))
        let radius: Float = 2.0
        indicator.position = [cos(angle) * radius, 1.5, sin(angle) * radius - 3.0]

        return indicator
    }

    private func loadCollaborationUsers() {
        // Mock collaboration users
        connectedUsers = [
            CollaborationUser(name: "Current User", color: .blue),
            CollaborationUser(name: "Trader 2", color: .green),
            CollaborationUser(name: "Analyst", color: .orange)
        ]
    }
}

struct CollaborationUser: Identifiable {
    var id = UUID()
    var name: String
    var color: UIColor
}

#Preview {
    CollaborationSpaceView()
        .environment(AppModel())
}
