import SwiftUI
import RealityKit

struct MedicalVisualizationView: View {
    @State private var heartRate = 72
    @State private var bloodPressure = "120/80"
    @State private var temperature = 98.6
    @State private var selectedOrgan: String?

    var body: some View {
        RealityView { content in
            // Create medical examination room
            let room = createMedicalRoom()
            content.add(room)

            // Add 3D human anatomy model
            let anatomy = createAnatomyModel()
            anatomy.position = [0, 1, -2]
            content.add(anatomy)

            // Add organ systems
            let heart = createOrgan(type: .heart)
            heart.position = [0, 1.5, -2]
            content.add(heart)

            let lungs = createOrgan(type: .lungs)
            lungs.position = [-0.3, 1.3, -1.8]
            content.add(lungs)

            let brain = createOrgan(type: .brain)
            brain.position = [0, 2.2, -2]
            content.add(brain)

            // Add medical equipment
            let scanner = createMedicalScanner()
            scanner.position = [1.5, 1, -2.5]
            content.add(scanner)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    selectOrgan(value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Medical Visualization")
                    .font(.title)
                    .fontWeight(.bold)

                Divider()

                // Vital signs
                VitalSignRow(icon: "heart.fill", label: "Heart Rate", value: "\(heartRate) BPM", color: .red)
                VitalSignRow(icon: "waveform.path.ecg", label: "Blood Pressure", value: bloodPressure, color: .blue)
                VitalSignRow(icon: "thermometer", label: "Temperature", value: String(format: "%.1f°F", temperature), color: .orange)

                if let organ = selectedOrgan {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected: \(organ)")
                            .font(.headline)
                        Text("3D model active")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.green.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
    }

    private func createMedicalRoom() -> Entity {
        let room = Entity()

        // Floor
        let floor = ModelEntity(
            mesh: .generatePlane(width: 6, depth: 6),
            materials: [SimpleMaterial(color: .init(white: 0.95, alpha: 1), isMetallic: false)]
        )
        floor.position.y = -0.5
        room.addChild(floor)

        return room
    }

    private func createAnatomyModel() -> ModelEntity {
        // Simplified body representation
        let body = ModelEntity(
            mesh: .generateCylinder(height: 1.5, radius: 0.2),
            materials: [SimpleMaterial(color: .init(white: 0.9, alpha: 0.8), isMetallic: false)]
        )

        return body
    }

    private func createOrgan(type: OrganType) -> ModelEntity {
        let color: UIColor = {
            switch type {
            case .heart: return .systemRed
            case .lungs: return .systemPink
            case .brain: return .systemPurple
            }
        }()

        let size: Float = type == .brain ? 0.15 : 0.12

        let organ = ModelEntity(
            mesh: .generateSphere(radius: size),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )

        // Add pulsing animation effect for heart
        if type == .heart {
            var material = SimpleMaterial()
            material.color = .init(tint: .red, texture: nil)
            organ.model?.materials = [material]
        }

        organ.components.set(CollisionComponent(shapes: [.generateSphere(radius: size)]))
        organ.components.set(InputTargetComponent())
        organ.name = type.rawValue

        return organ
    }

    private func createMedicalScanner() -> ModelEntity {
        let scanner = ModelEntity(
            mesh: .generateBox(width: 0.4, height: 0.6, depth: 0.3),
            materials: [SimpleMaterial(color: .white, isMetallic: true)]
        )

        return scanner
    }

    private func selectOrgan(_ entity: Entity) {
        let name = entity.name
        if !name.isEmpty {
            selectedOrgan = name.capitalized

            // Visual feedback
            entity.scale *= 1.3
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                entity.scale /= 1.3
            }
        }
    }
}

struct VitalSignRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }

            Spacer()
        }
    }
}

enum OrganType: String {
    case heart, lungs, brain
}

#Preview {
    MedicalVisualizationView()
}
