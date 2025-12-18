import SwiftUI
import RealityKit

struct HazardVolumeView: View {
    @State private var foundHazards: Set<UUID> = []
    @State private var timeElapsed: TimeInterval = 0
    @State private var isComplete: Bool = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let totalHazards = 5

    var body: some View {
        ZStack {
            RealityView { content in
                await setupHazardScene(content: content)
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        handleEntityTap(value.entity)
                    }
            )

            VStack {
                statusOverlay
                Spacer()
                if isComplete {
                    completionOverlay
                }
            }
        }
        .onReceive(timer) { _ in
            if !isComplete {
                timeElapsed += 1
            }
        }
    }

    private var statusOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Identify Hazards")
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 20) {
                    Label("Found: \(foundHazards.count)/\(totalHazards)", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(foundHazards.count == totalHazards ? .green : .primary)

                    Label(formatTime(timeElapsed), systemImage: "clock.fill")
                }
                .font(.callout)
            }

            Spacer()

            Button("Hint", systemImage: "lightbulb.fill") {
                // Show hint
            }
            .buttonStyle(.bordered)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(24)
    }

    private var completionOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("All Hazards Found!")
                .font(.title)
                .fontWeight(.bold)

            Text("Time: \(formatTime(timeElapsed))")
                .font(.headline)

            Text("Score: \(calculateScore())/100")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)

            Button("Complete Training") {
                // Complete and exit
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
    }

    @MainActor
    private func setupHazardScene(content: RealityViewContent) async {
        // Create factory floor section
        let floor = createFloor()
        content.add(floor)

        // Add hazards
        let hazards = createHazards()
        hazards.forEach { content.add($0) }

        // Add safe equipment for contrast
        let equipment = createEquipment()
        equipment.forEach { content.add($0) }
    }

    @MainActor
    private func createFloor() -> Entity {
        let mesh = MeshResource.generatePlane(width: 3, depth: 3)
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, -0.5, 0)
        return entity
    }

    @MainActor
    private func createHazards() -> [Entity] {
        var hazards: [Entity] = []

        // Chemical spill
        let spill = createHazard(
            type: .chemical,
            position: SIMD3<Float>(-0.8, -0.45, -0.5),
            color: .yellow
        )
        hazards.append(spill)

        // Exposed wire
        let wire = createHazard(
            type: .electrical,
            position: SIMD3<Float>(0.5, 0.2, 0.3),
            color: .orange
        )
        hazards.append(wire)

        // Fire hazard
        let fire = createHazard(
            type: .fire,
            position: SIMD3<Float>(-0.3, -0.3, 0.8),
            color: .red
        )
        hazards.append(fire)

        // Slip hazard
        let slip = createHazard(
            type: .slipTrip,
            position: SIMD3<Float>(0.7, -0.48, -0.7),
            color: .yellow
        )
        hazards.append(slip)

        // Falling object hazard
        let falling = createHazard(
            type: .struckBy,
            position: SIMD3<Float>(0.0, 0.8, 0.0),
            color: .purple
        )
        hazards.append(falling)

        return hazards
    }

    @MainActor
    private func createHazard(type: HazardType, position: SIMD3<Float>, color: UIColor) -> Entity {
        let size: Float = 0.15
        let mesh = MeshResource.generateBox(size: [size, size, size])
        var material = SimpleMaterial(color: color, isMetallic: false)
        material.color = .init(tint: color)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = position
        entity.name = "hazard"

        // Make it interactive
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(shapes: [.generateBox(size: [size, size, size])]))

        // Store hazard type
        entity.components.set(HazardMarker(id: UUID(), type: type))

        return entity
    }

    @MainActor
    private func createEquipment() -> [Entity] {
        var equipment: [Entity] = []

        // Safe equipment (not hazards)
        let barrel = ModelEntity(
            mesh: .generateCylinder(height: 0.5, radius: 0.15),
            materials: [SimpleMaterial(color: .blue, isMetallic: true)]
        )
        barrel.position = SIMD3<Float>(-1.0, -0.25, 0.0)
        equipment.append(barrel)

        return equipment
    }

    private func handleEntityTap(_ entity: Entity) {
        if let marker = entity.components[HazardMarker.self], entity.name == "hazard" {
            if !foundHazards.contains(marker.id) {
                foundHazards.insert(marker.id)

                // Visual feedback
                if var model = entity.components[ModelComponent.self] {
                    model.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                    entity.components.set(model)
                }

                // Check if all found
                if foundHazards.count == totalHazards {
                    completeTraining()
                }
            }
        }
    }

    private func completeTraining() {
        isComplete = true
        timer.upstream.connect().cancel()
    }

    private func calculateScore() -> Int {
        let baseScore = 100
        let timePenalty = Int(timeElapsed / 10) // -1 point per 10 seconds
        return max(0, baseScore - timePenalty)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct HazardMarker: Component {
    let id: UUID
    let type: HazardType
}

#Preview(windowStyle: .volumetric) {
    HazardVolumeView()
}
