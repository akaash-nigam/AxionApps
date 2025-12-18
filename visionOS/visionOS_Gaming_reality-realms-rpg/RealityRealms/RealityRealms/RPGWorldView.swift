import SwiftUI
import RealityKit

struct RPGWorldView: View {
    @State private var playerLevel = 1
    @State private var experience: Float = 0
    @State private var health: Float = 100

    var body: some View {
        RealityView { content in
            // Create a fantasy environment
            let environment = createFantasyEnvironment()
            content.add(environment)

            // Add player avatar
            let avatar = createPlayerAvatar()
            avatar.position = [0, 0, -1.5]
            content.add(avatar)

            // Add NPC characters
            for i in 0..<3 {
                let npc = createNPC()
                let angle = Float(i) * (.pi * 2 / 3)
                npc.position = [sin(angle) * 2, 0, cos(angle) * 2 - 2]
                content.add(npc)
            }

            // Add magical effects
            let magicOrb = createMagicOrb()
            magicOrb.position = [0, 1.5, -2]
            content.add(magicOrb)
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Level \(playerLevel)")
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Text("HP:")
                    ProgressView(value: health, total: 100)
                        .tint(.red)
                        .frame(width: 150)
                }

                HStack {
                    Text("XP:")
                    ProgressView(value: experience, total: 100)
                        .tint(.yellow)
                        .frame(width: 150)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
    }

    private func createFantasyEnvironment() -> Entity {
        let environment = Entity()

        // Create ground plane
        let ground = ModelEntity(
            mesh: .generatePlane(width: 10, depth: 10),
            materials: [SimpleMaterial(color: .init(red: 0.2, green: 0.5, blue: 0.2, alpha: 1), isMetallic: false)]
        )
        ground.position.y = -0.5
        environment.addChild(ground)

        // Add trees
        for _ in 0..<5 {
            let tree = createTree()
            tree.position = [
                Float.random(in: -4...4),
                0,
                Float.random(in: -4...0)
            ]
            environment.addChild(tree)
        }

        return environment
    }

    private func createTree() -> ModelEntity {
        let trunk = ModelEntity(
            mesh: .generateCylinder(height: 1.5, radius: 0.1),
            materials: [SimpleMaterial(color: .init(red: 0.4, green: 0.2, blue: 0, alpha: 1), isMetallic: false)]
        )

        let leaves = ModelEntity(
            mesh: .generateSphere(radius: 0.5),
            materials: [SimpleMaterial(color: .green, isMetallic: false)]
        )
        leaves.position.y = 1.2

        let tree = Entity()
        tree.addChild(trunk)
        tree.addChild(leaves)

        return ModelEntity()
    }

    private func createPlayerAvatar() -> ModelEntity {
        let body = ModelEntity(
            mesh: .generateCylinder(height: 0.8, radius: 0.15),
            materials: [SimpleMaterial(color: .blue, isMetallic: true)]
        )

        let head = ModelEntity(
            mesh: .generateSphere(radius: 0.15),
            materials: [SimpleMaterial(color: .systemPink, isMetallic: false)]
        )
        head.position.y = 0.5

        let avatar = ModelEntity()
        avatar.addChild(body)
        avatar.addChild(head)

        // Add collision for interaction
        avatar.components.set(CollisionComponent(shapes: [.generateCapsule(height: 1, radius: 0.2)]))
        avatar.components.set(InputTargetComponent())

        return avatar
    }

    private func createNPC() -> ModelEntity {
        let npc = ModelEntity(
            mesh: .generateBox(width: 0.3, height: 0.8, depth: 0.3),
            materials: [SimpleMaterial(color: .systemYellow, isMetallic: false)]
        )

        // Add collision for interaction
        npc.components.set(CollisionComponent(shapes: [.generateBox(width: 0.3, height: 0.8, depth: 0.3)]))
        npc.components.set(InputTargetComponent())

        return npc
    }

    private func createMagicOrb() -> ModelEntity {
        let orb = ModelEntity(
            mesh: .generateSphere(radius: 0.2),
            materials: [SimpleMaterial(color: .purple, isMetallic: true)]
        )

        // Add glow effect
        var material = SimpleMaterial()
        material.color = .init(tint: .purple, texture: nil)
        material.metallic = .init(floatLiteral: 1.0)
        material.roughness = .init(floatLiteral: 0.1)
        orb.model?.materials = [material]

        return orb
    }
}

#Preview {
    RPGWorldView()
}
