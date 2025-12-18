//
//  MeetingVolumeView.swift
//  SpatialMeetingPlatform
//
//  3D meeting space volume with participant avatars
//

import SwiftUI
import RealityKit

struct MeetingVolumeView: View {

    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // Create the 3D meeting space
            await setupMeetingSpace(content: content)
        } update: { content in
            // Update participants when they change
            updateParticipants(content: content)
        }
        .task {
            // Initialize spatial scene
            await loadSpatialScene()
        }
    }

    // MARK: - Setup

    private func setupMeetingSpace(content: RealityViewContent) async {
        // Create floor grid
        let floorGrid = createFloorGrid()
        content.add(floorGrid)

        // Add lighting
        let lights = createLighting()
        for light in lights {
            content.add(light)
        }

        // Add participant avatars
        if let meeting = appModel.activeMeeting {
            for (index, participant) in meeting.participants.enumerated() {
                let avatar = createParticipantAvatar(
                    participant: participant,
                    index: index,
                    total: meeting.participants.count
                )
                content.add(avatar)
            }
        }

        // Add center content area
        let contentArea = createContentArea()
        content.add(contentArea)
    }

    private func updateParticipants(content: RealityViewContent) {
        // In real implementation: Update participant positions and states
        print("Updating participants in volume")
    }

    // MARK: - Entity Creation

    private func createFloorGrid() -> Entity {
        let gridEntity = Entity()

        // Create grid mesh
        let gridSize: Float = 4.0
        let divisions: Int = 20

        var meshDescriptor = MeshDescriptor()
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []

        // Create grid lines
        for i in 0...divisions {
            let t = Float(i) / Float(divisions)
            let pos = -gridSize / 2 + t * gridSize

            // Horizontal lines
            positions.append(SIMD3(-gridSize / 2, 0, pos))
            positions.append(SIMD3(gridSize / 2, 0, pos))

            // Vertical lines
            positions.append(SIMD3(pos, 0, -gridSize / 2))
            positions.append(SIMD3(pos, 0, gridSize / 2))
        }

        // Create indices for lines
        for i in stride(from: 0, to: positions.count, by: 2) {
            indices.append(UInt32(i))
            indices.append(UInt32(i + 1))
        }

        meshDescriptor.positions = MeshBuffer(positions)
        meshDescriptor.primitives = .lines(indices)

        do {
            let mesh = try MeshResource.generate(from: [meshDescriptor])
            let material = SimpleMaterial(color: .gray.withAlphaComponent(0.2), isMetallic: false)
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])

            gridEntity.addChild(modelEntity)
        } catch {
            print("Failed to create grid: \(error)")
        }

        return gridEntity
    }

    private func createLighting() -> [Entity] {
        var lights: [Entity] = []

        // Directional light (sun)
        let sunlight = Entity()
        let directionalLight = DirectionalLightComponent(
            color: .white,
            intensity: 1000,
            isRealWorldProxy: false
        )
        sunlight.components.set(directionalLight)
        sunlight.position = SIMD3(0, 3, 0)
        sunlight.look(at: SIMD3(0, 0, 0), from: sunlight.position, relativeTo: nil)
        lights.append(sunlight)

        // Ambient light
        let ambient = Entity()
        let ambientLight = AmbientLightComponent(
            color: .white,
            intensity: 300
        )
        ambient.components.set(ambientLight)
        lights.append(ambient)

        return lights
    }

    private func createParticipantAvatar(participant: Participant, index: Int, total: Int) -> Entity {
        let avatarEntity = Entity()

        // Position participants in a circle
        let radius: Float = 1.5
        let angle = (Float(index) / Float(total)) * 2 * .pi
        let x = radius * cos(angle)
        let z = radius * sin(angle)

        avatarEntity.position = SIMD3(x, 1.2, z)

        // Create avatar sphere
        let avatarMesh = MeshResource.generateSphere(radius: 0.2)
        let avatarMaterial = SimpleMaterial(
            color: participant.presenceState == .speaking ? .green : .blue,
            isMetallic: false
        )
        let avatarModel = ModelEntity(mesh: avatarMesh, materials: [avatarMaterial])
        avatarEntity.addChild(avatarModel)

        // Add speaking indicator ring
        if participant.presenceState == .speaking {
            let ringMesh = MeshResource.generateSphere(radius: 0.25)
            let ringMaterial = SimpleMaterial(
                color: .cyan.withAlphaComponent(0.3),
                isMetallic: false
            )
            let ring = ModelEntity(mesh: ringMesh, materials: [ringMaterial])
            avatarEntity.addChild(ring)
        }

        // Add nameplate
        let nameplate = createNameplate(for: participant)
        nameplate.position = SIMD3(0, 0.3, 0)
        avatarEntity.addChild(nameplate)

        return avatarEntity
    }

    private func createNameplate(for participant: Participant) -> Entity {
        let nameplateEntity = Entity()

        // Create text mesh
        let textMesh = MeshResource.generateText(
            participant.user.displayName,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )

        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])

        // Billboard component (always face camera)
        textModel.components.set(BillboardComponent())

        nameplateEntity.addChild(textModel)

        return nameplateEntity
    }

    private func createContentArea() -> Entity {
        let contentEntity = Entity()

        // Create placeholder for shared content
        let planeMesh = MeshResource.generatePlane(width: 1.2, height: 0.9)
        let planeMaterial = SimpleMaterial(
            color: .white.withAlphaComponent(0.8),
            isMetallic: false
        )
        let plane = ModelEntity(mesh: planeMesh, materials: [planeMaterial])

        contentEntity.addChild(plane)
        contentEntity.position = SIMD3(0, 1.5, -2)

        return contentEntity
    }

    // MARK: - Helpers

    private func loadSpatialScene() async {
        do {
            let _ = try await appModel.spatialService.syncSpatialState()
        } catch {
            print("Failed to load spatial scene: \(error)")
        }
    }
}

#Preview {
    MeetingVolumeView()
        .environment(AppModel())
}
