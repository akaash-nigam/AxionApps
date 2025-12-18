import SwiftUI
import RealityKit

struct CrimeSceneView: View {
    @State private var cluesFound = 0
    @State private var totalClues = 5
    @State private var evidenceBag: [String] = []

    var body: some View {
        RealityView { content in
            // Create crime scene room
            let room = createCrimeSceneRoom()
            content.add(room)

            // Add evidence objects
            let evidence1 = createEvidence(type: "Fingerprint", color: .red)
            evidence1.position = [-1, 1, -2]
            content.add(evidence1)

            let evidence2 = createEvidence(type: "Weapon", color: .gray)
            evidence2.position = [0.5, 0.7, -1.5]
            content.add(evidence2)

            let evidence3 = createEvidence(type: "Note", color: .yellow)
            evidence3.position = [1, 1.2, -2.5]
            content.add(evidence3)

            let evidence4 = createEvidence(type: "Blood", color: .red)
            evidence4.position = [-0.5, 0.1, -1]
            content.add(evidence4)

            let evidence5 = createEvidence(type: "Photo", color: .white)
            evidence5.position = [0, 1.5, -3]
            content.add(evidence5)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    collectEvidence(value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Crime Scene Investigation")
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Clues: \(cluesFound)/\(totalClues)")
                        .font(.title3)
                }

                if !evidenceBag.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Evidence Collected:")
                            .font(.headline)
                        ForEach(evidenceBag, id: \.self) { item in
                            HStack {
                                Image(systemName: "shippingbox.fill")
                                    .foregroundStyle(.orange)
                                Text(item)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
    }

    private func createCrimeSceneRoom() -> Entity {
        let room = Entity()

        // Floor
        let floor = ModelEntity(
            mesh: .generatePlane(width: 5, depth: 5),
            materials: [SimpleMaterial(color: .init(white: 0.8, alpha: 1), isMetallic: false)]
        )
        floor.position.y = -0.5
        room.addChild(floor)

        // Walls
        let wallMaterial = SimpleMaterial(color: .init(white: 0.9, alpha: 1), isMetallic: false)

        let backWall = ModelEntity(
            mesh: .generateBox(width: 5, height: 3, depth: 0.1),
            materials: [wallMaterial]
        )
        backWall.position = [0, 1, -3]
        room.addChild(backWall)

        // Furniture
        let table = ModelEntity(
            mesh: .generateBox(width: 1, height: 0.7, depth: 0.6),
            materials: [SimpleMaterial(color: .brown, isMetallic: false)]
        )
        table.position = [0, 0.35, -2]
        room.addChild(table)

        return room
    }

    private func createEvidence(type: String, color: UIColor) -> ModelEntity {
        let evidence = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [SimpleMaterial(color: color, isMetallic: true)]
        )

        // Add glow effect
        evidence.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)]))
        evidence.components.set(InputTargetComponent())

        // Store evidence type
        evidence.name = type

        return evidence
    }

    private func collectEvidence(_ entity: Entity) {
        let evidenceType = entity.name
        if !evidenceType.isEmpty && !evidenceBag.contains(evidenceType) {
            evidenceBag.append(evidenceType)
            cluesFound += 1

            // Visual feedback - make entity disappear
            entity.isEnabled = false
        }
    }
}

#Preview {
    CrimeSceneView()
}
