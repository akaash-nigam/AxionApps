import SwiftUI
import RealityKit

struct HomeImmersiveView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow

    @State private var spatialManager: SpatialManager?
    @State private var deviceManager: DeviceManager?

    var body: some View {
        RealityView { content in
            // Initialize spatial tracking
            if let manager = spatialManager {
                do {
                    try await manager.startTracking()
                } catch {
                    Logger.shared.log("Failed to start tracking", level: .error, error: error)
                }
            }

            // Create root entity for home
            let rootEntity = Entity()
            content.add(rootEntity)

            // Add device entities
            await addDeviceEntities(to: rootEntity)

            // Add contextual displays
            await addContextualDisplays(to: rootEntity)

        } update: { content in
            // Update device positions and states
            updateDeviceEntities(in: content)

        } attachments: {
            // Contextual display attachment
            Attachment(id: "contextual-display") {
                if let currentRoom = appState.currentRoom {
                    ContextualDisplayView(room: currentRoom)
                }
            }

            // Device control attachments
            ForEach(appState.devicesList, id: \.id) { device in
                Attachment(id: "device-\(device.id)") {
                    CompactDeviceControl(device: device)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                ImmersiveControlsView(
                    onScanRoom: {
                        await startRoomScan()
                    },
                    onExit: {
                        await dismissImmersiveSpace()
                        openWindow(id: "dashboard")
                    }
                )
            }
        }
        .task {
            // Initialize managers
            spatialManager = SpatialManager(appState: appState)
            let homeKitService = HomeKitService()
            deviceManager = DeviceManager(appState: appState, homeKitService: homeKitService)
        }
        .onDisappear {
            spatialManager?.stopTracking()
        }
    }

    // MARK: - Entity Management

    private func addDeviceEntities(to rootEntity: Entity) async {
        for device in appState.devices.values {
            let deviceEntity = await createDeviceEntity(for: device)
            rootEntity.addChild(deviceEntity)
        }
    }

    private func createDeviceEntity(for device: SmartDevice) async -> Entity {
        let entity = Entity()

        // Position based on room location (placeholder for now)
        entity.position = SIMD3(
            Float.random(in: -2...2),
            Float.random(in: 0...2),
            Float.random(in: -2...2)
        )

        // Add visual indicator
        let mesh = MeshResource.generateSphere(radius: 0.05)
        var material = UnlitMaterial()
        material.color = .init(tint: device.currentState?.isOn == true ? .yellow : .gray)

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        entity.components.set(modelComponent)

        // Make it interactive
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.05)]))

        // Store device ID
        entity.name = device.id.uuidString

        return entity
    }

    private func updateDeviceEntities(in content: RealityViewContent) {
        // Update device states
        for device in appState.devices.values {
            if let entity = content.entities.first(where: { $0.name == device.id.uuidString }),
               var modelComponent = entity.components[ModelComponent.self] {

                // Update color based on state
                var material = UnlitMaterial()
                material.color = .init(tint: device.currentState?.isOn == true ? .yellow : .gray)
                modelComponent.materials = [material]
                entity.components.set(modelComponent)
            }
        }
    }

    private func addContextualDisplays(to rootEntity: Entity) async {
        guard let manager = spatialManager else { return }

        // Find nearest wall for contextual display
        if let wallPosition = manager.findNearestWallPosition() {
            // Contextual display will be shown as attachment
            Logger.shared.log("Wall position found for display", category: "Immersive")
        }
    }

    // MARK: - Actions

    private func startRoomScan() async {
        await dismissImmersiveSpace()
        openWindow(id: "room-scan")
    }
}

// MARK: - Contextual Display View

struct ContextualDisplayView: View {
    let room: Room

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: room.roomType.icon)
                    .font(.title2)
                Text(room.name)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Divider()

            // Room info
            VStack(alignment: .leading, spacing: 8) {
                if !room.devices.isEmpty {
                    Text("\(room.devices.count) devices")
                        .font(.subheadline)

                    let activeCount = room.devices.filter { $0.currentState?.isOn == true }.count
                    if activeCount > 0 {
                        Text("\(activeCount) active")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No devices")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(24)
        .frame(width: 400)
        .glassBackgroundEffect()
    }
}

// MARK: - Compact Device Control

struct CompactDeviceControl: View {
    let device: SmartDevice
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: device.deviceType.icon)
                .font(.title2)
                .foregroundStyle(device.currentState?.isOn == true ? .yellow : .primary)

            Text(device.name)
                .font(.caption)
                .lineLimit(1)

            if device.deviceType.supportsOnOff {
                Toggle("", isOn: Binding(
                    get: { device.currentState?.isOn ?? false },
                    set: { _ in
                        // Toggle via device manager
                    }
                ))
                .labelsHidden()
            }
        }
        .padding()
        .frame(width: 120, height: 120)
        .glassBackgroundEffect()
    }
}

// MARK: - Immersive Controls

struct ImmersiveControlsView: View {
    let onScanRoom: () async -> Void
    let onExit: () async -> Void

    var body: some View {
        HStack(spacing: 24) {
            Button {
                Task {
                    await onScanRoom()
                }
            } label: {
                Label("Scan Room", systemImage: "camera.fill")
            }
            .buttonStyle(.borderedProminent)

            Button {
                Task {
                    await onExit()
                }
            } label: {
                Label("Exit", systemImage: "xmark")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .glassBackgroundEffect()
    }
}

// MARK: - Preview

#Preview(immersionStyle: .mixed) {
    HomeImmersiveView()
        .environment(AppState.preview)
}
