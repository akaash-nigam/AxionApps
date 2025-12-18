//
//  ImmersiveMeetingView.swift
//  SpatialMeetingPlatform
//
//  Fully immersive meeting space
//

import SwiftUI
import RealityKit

struct ImmersiveMeetingView: View {

    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            await setupImmersiveEnvironment(content: content)
        } update: { content in
            updateImmersiveContent(content: content)
        }
        .task {
            await loadEnvironment()
        }
    }

    // MARK: - Setup

    private func setupImmersiveEnvironment(content: RealityViewContent) async {
        // Load environment based on meeting type
        guard let meeting = appModel.activeMeeting else { return }

        switch meeting.meetingType {
        case .boardroom:
            await loadBoardroomEnvironment(content: content)
        case .innovationLab:
            await loadInnovationLabEnvironment(content: content)
        case .auditorium:
            await loadAuditoriumEnvironment(content: content)
        default:
            await loadDefaultEnvironment(content: content)
        }

        // Add participants
        addImmersiveParticipants(content: content, meeting: meeting)

        // Add content displays
        addContentDisplays(content: content)
    }

    private func updateImmersiveContent(content: RealityViewContent) {
        // Update participant states and positions
        print("Updating immersive content")
    }

    // MARK: - Environment Loading

    private func loadBoardroomEnvironment(content: RealityViewContent) async {
        // Create boardroom environment
        let roomEntity = Entity()

        // Floor
        let floorMesh = MeshResource.generatePlane(width: 6, depth: 4)
        let floorMaterial = SimpleMaterial(
            color: .gray,
            roughness: 0.8,
            isMetallic: false
        )
        let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        floor.position.y = 0
        roomEntity.addChild(floor)

        // Table
        let tableMesh = MeshResource.generateBox(width: 3, height: 0.05, depth: 1.5)
        let tableMaterial = SimpleMaterial(
            color: .brown,
            roughness: 0.3,
            isMetallic: false
        )
        let table = ModelEntity(mesh: tableMesh, materials: [tableMaterial])
        table.position = SIMD3(0, 0.75, 0)
        roomEntity.addChild(table)

        // Lighting
        let light = DirectionalLightComponent(
            color: .white,
            intensity: 800,
            isRealWorldProxy: false
        )
        let lightEntity = Entity()
        lightEntity.components.set(light)
        lightEntity.position = SIMD3(0, 3, 0)
        lightEntity.look(at: SIMD3(0, 0, 0), from: lightEntity.position, relativeTo: nil)
        roomEntity.addChild(lightEntity)

        content.add(roomEntity)
    }

    private func loadInnovationLabEnvironment(content: RealityViewContent) async {
        // Create innovation lab environment (open, creative space)
        let labEntity = Entity()

        // Open floor
        let floorMesh = MeshResource.generatePlane(width: 10, depth: 10)
        let floorMaterial = SimpleMaterial(
            color: .white,
            roughness: 0.9,
            isMetallic: false
        )
        let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        labEntity.addChild(floor)

        // Bright lighting
        let light = PointLightComponent(
            color: .white,
            intensity: 1000,
            attenuationRadius: 10
        )
        let lightEntity = Entity()
        lightEntity.components.set(light)
        lightEntity.position = SIMD3(0, 4, 0)
        labEntity.addChild(lightEntity)

        content.add(labEntity)
    }

    private func loadAuditoriumEnvironment(content: RealityViewContent) async {
        // Create auditorium environment
        let auditoriumEntity = Entity()

        // Stage
        let stageMesh = MeshResource.generateBox(width: 8, height: 0.5, depth: 4)
        let stageMaterial = SimpleMaterial(
            color: .darkGray,
            isMetallic: false
        )
        let stage = ModelEntity(mesh: stageMesh, materials: [stageMaterial])
        stage.position = SIMD3(0, 0.25, -5)
        auditoriumEntity.addChild(stage)

        // Spotlight on stage
        let spotlight = SpotLightComponent(
            color: .white,
            intensity: 1500,
            innerAngleInDegrees: 30,
            outerAngleInDegrees: 45,
            attenuationRadius: 10
        )
        let spotlightEntity = Entity()
        spotlightEntity.components.set(spotlight)
        spotlightEntity.position = SIMD3(0, 5, -5)
        spotlightEntity.look(at: SIMD3(0, 0, -5), from: spotlightEntity.position, relativeTo: nil)
        auditoriumEntity.addChild(spotlightEntity)

        content.add(auditoriumEntity)
    }

    private func loadDefaultEnvironment(content: RealityViewContent) async {
        // Simple default environment
        await loadBoardroomEnvironment(content: content)
    }

    // MARK: - Content Addition

    private func addImmersiveParticipants(content: RealityViewContent, meeting: Meeting) {
        // Add participant avatars in immersive space
        for (index, participant) in meeting.participants.enumerated() {
            let avatar = createImmersiveAvatar(
                participant: participant,
                index: index,
                total: meeting.participants.count
            )
            content.add(avatar)
        }
    }

    private func createImmersiveAvatar(participant: Participant, index: Int, total: Int) -> Entity {
        let avatarEntity = Entity()

        // Position around table or space
        let radius: Float = 2.0
        let angle = (Float(index) / Float(total)) * 2 * .pi
        let x = radius * cos(angle)
        let z = radius * sin(angle)

        avatarEntity.position = SIMD3(x, 1.5, z)

        // Create avatar
        let avatarMesh = MeshResource.generateSphere(radius: 0.3)
        let color: UIColor = participant.presenceState == .speaking ? .green : .systemBlue
        let avatarMaterial = SimpleMaterial(color: color, isMetallic: false)
        let avatarModel = ModelEntity(mesh: avatarMesh, materials: [avatarMaterial])

        avatarEntity.addChild(avatarModel)

        // Add nameplate
        let nameText = MeshResource.generateText(
            participant.user.displayName,
            extrusionDepth: 0.02,
            font: .systemFont(ofSize: 0.15)
        )
        let nameMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let nameModel = ModelEntity(mesh: nameText, materials: [nameMaterial])
        nameModel.position.y = 0.4
        nameModel.components.set(BillboardComponent())

        avatarEntity.addChild(nameModel)

        return avatarEntity
    }

    private func addContentDisplays(content: RealityViewContent) {
        // Add floating content screens
        let screenEntity = Entity()

        let screenMesh = MeshResource.generatePlane(width: 2, height: 1.2)
        let screenMaterial = SimpleMaterial(
            color: .white.withAlphaComponent(0.9),
            isMetallic: false
        )
        let screen = ModelEntity(mesh: screenMesh, materials: [screenMaterial])

        screenEntity.addChild(screen)
        screenEntity.position = SIMD3(0, 2, -3)

        content.add(screenEntity)
    }

    // MARK: - Helpers

    private func loadEnvironment() async {
        print("Loading immersive environment for meeting type: \(appModel.selectedEnvironment)")
    }
}

#Preview {
    ImmersiveMeetingView()
        .environment(AppModel())
}
