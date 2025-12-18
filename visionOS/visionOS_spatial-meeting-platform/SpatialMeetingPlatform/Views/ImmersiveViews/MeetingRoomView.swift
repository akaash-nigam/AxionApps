import SwiftUI
import RealityKit

struct MeetingRoomView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            await setupMeetingRoom(content)
        }
        .onAppear {
            print("🏠 Meeting room appeared")
        }
        .onDisappear {
            print("👋 Meeting room disappeared")
        }
    }

    private func setupMeetingRoom(_ content: RealityViewContent) async {
        print("🎬 Setting up meeting room...")

        // Create root entity
        let roomEntity = Entity()
        roomEntity.name = "MeetingRoom"

        // Add environment lighting
        await addLighting(to: roomEntity)

        // Add participant avatars
        await addParticipants(to: roomEntity, participants: appState.participants)

        // Add shared content
        await addSharedContent(to: roomEntity, content: appState.sharedContent)

        content.add(roomEntity)

        print("✅ Meeting room setup complete")
    }

    private func addLighting(to parent: Entity) async {
        // Create ambient light
        let ambient = Entity()
        ambient.name = "AmbientLight"

        // In production, this would use ImageBasedLightComponent
        // For now, we'll just log it
        print("💡 Added lighting to meeting room")

        parent.addChild(ambient)
    }

    private func addParticipants(to parent: Entity, participants: [Participant]) async {
        print("👥 Adding \(participants.count) participants...")

        for (index, participant) in participants.enumerated() {
            let avatar = await createAvatar(for: participant, index: index)
            parent.addChild(avatar)
        }
    }

    private func createAvatar(for participant: Participant, index: Int) async -> Entity {
        let avatar = Entity()
        avatar.name = "Avatar_\(participant.displayName)"

        // Calculate position in circle
        let angle = (Float(index) / Float(max(appState.participants.count, 1))) * 2.0 * .pi
        let radius: Float = 2.0

        let x = radius * cos(angle)
        let z = radius * sin(angle)

        avatar.position = SIMD3(x, 0, z)

        // In production, this would create a proper 3D avatar model
        // For now, we'll create a simple representation
        let avatarModel = ModelEntity(
            mesh: .generateSphere(radius: 0.15),
            materials: [SimpleMaterial(color: .blue, isMetallic: false)]
        )
        avatarModel.position = [0, 1.7, 0] // Head height

        avatar.addChild(avatarModel)

        // Add name tag
        let nameTag = createNameTag(participant.displayName)
        nameTag.position = [0, 2.0, 0] // Above head
        avatar.addChild(nameTag)

        print("👤 Created avatar for: \(participant.displayName)")

        return avatar
    }

    private func createNameTag(_ name: String) -> Entity {
        let nameTag = Entity()
        nameTag.name = "NameTag"

        // In production, this would create a 3D text mesh
        // For now, it's a placeholder entity

        return nameTag
    }

    private func addSharedContent(to parent: Entity, content: [SharedContent]) async {
        print("📄 Adding \(content.count) shared content items...")

        for item in content {
            let contentEntity = await createContentEntity(for: item)
            parent.addChild(contentEntity)
        }
    }

    private func createContentEntity(for content: SharedContent) async -> Entity {
        let entity = Entity()
        entity.name = "Content_\(content.title)"

        // Position based on content's spatial position
        entity.position = SIMD3(content.position.x, content.position.y, content.position.z)
        entity.orientation = content.orientation

        // In production, this would load the actual content
        // For now, create a placeholder
        let placeholder = ModelEntity(
            mesh: .generateBox(width: 0.5, height: 0.7, depth: 0.05),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )

        entity.addChild(placeholder)

        print("📦 Created content entity: \(content.title)")

        return entity
    }
}

#Preview {
    MeetingRoomView()
        .environment(AppState())
}
