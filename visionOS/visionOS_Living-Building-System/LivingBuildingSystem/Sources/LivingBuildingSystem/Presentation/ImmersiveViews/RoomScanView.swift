import SwiftUI
import RealityKit
import ARKit

struct RoomScanView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow

    @State private var spatialManager: SpatialManager?
    @State private var scanProgress: Double = 0.0
    @State private var isScanning = false
    @State private var scannedMeshCount = 0

    var body: some View {
        RealityView { content in
            // Initialize spatial manager
            if let manager = spatialManager {
                do {
                    try await manager.startTracking()
                    isScanning = true
                } catch {
                    Logger.shared.log("Failed to start room scan", level: .error, error: error)
                }
            }

            // Create visualization for scanned meshes
            let rootEntity = Entity()
            content.add(rootEntity)

        } update: { content in
            // Update scan visualization
            if let manager = spatialManager {
                scannedMeshCount = manager.roomMeshes.count

                // Visualize mesh anchors
                for (_, meshAnchor) in manager.roomMeshes {
                    visualizeMesh(meshAnchor, in: content)
                }
            }

        } attachments: {
            Attachment(id: "scan-instructions") {
                ScanInstructionsView(
                    meshCount: scannedMeshCount,
                    onComplete: {
                        await completeScan()
                    },
                    onCancel: {
                        await cancelScan()
                    }
                )
            }
        }
        .task {
            spatialManager = SpatialManager(appState: appState)
        }
        .onDisappear {
            spatialManager?.stopTracking()
        }
    }

    // MARK: - Mesh Visualization

    private func visualizeMesh(_ meshAnchor: MeshAnchor, in content: RealityViewContent) {
        // Check if entity already exists
        let entityName = "mesh-\(meshAnchor.id)"
        guard content.entities.first(where: { $0.name == entityName }) == nil else {
            return
        }

        // Create mesh visualization
        let entity = Entity()
        entity.name = entityName

        // Create mesh resource from anchor geometry
        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffer(meshAnchor.geometry.vertices.asSIMD3(ofType: Float.self))
        descriptor.primitives = .triangles(meshAnchor.geometry.faces.asUInt32Array())

        if let meshResource = try? MeshResource.generate(from: [descriptor]) {
            // Semi-transparent material for visualization
            var material = UnlitMaterial()
            material.color = .init(tint: .cyan.withAlphaComponent(0.3))
            material.blending = .transparent(opacity: 0.3)

            let modelComponent = ModelComponent(mesh: meshResource, materials: [material])
            entity.components.set(modelComponent)

            // Position at mesh anchor transform
            entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)

            content.add(entity)
        }
    }

    // MARK: - Actions

    private func completeScan() async {
        Logger.shared.log("Completing room scan", category: "RoomScan")

        // Save scanned data
        if let manager = spatialManager, let currentRoom = appState.currentRoom {
            // Save anchors to room
            for (_, meshAnchor) in manager.roomMeshes {
                // Create wall anchor at prominent positions
                let position = meshAnchor.originFromAnchorTransform.columns.3.xyz
                do {
                    _ = try await manager.placeAnchor(at: position, for: currentRoom)
                } catch {
                    Logger.shared.log("Failed to save anchor", level: .error, error: error)
                }
            }
        }

        // Return to home view
        await dismissImmersiveSpace()
        openWindow(id: "home-view")
    }

    private func cancelScan() async {
        Logger.shared.log("Cancelling room scan", category: "RoomScan")
        await dismissImmersiveSpace()
        openWindow(id: "dashboard")
    }
}

// MARK: - Scan Instructions View

struct ScanInstructionsView: View {
    let meshCount: Int
    let onComplete: () async -> Void
    let onCancel: () async -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "camera.metering.multispot")
                    .font(.system(size: 48))
                    .foregroundStyle(.cyan)

                Text("Room Scanning")
                    .font(.title)
                    .fontWeight(.bold)
            }

            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(
                    icon: "arrow.turn.up.right",
                    text: "Look around the room slowly"
                )

                InstructionRow(
                    icon: "square.grid.3x3",
                    text: "Focus on walls and surfaces"
                )

                InstructionRow(
                    icon: "checkmark.circle",
                    text: "Complete when surfaces are scanned"
                )
            }

            Divider()

            // Progress
            VStack(spacing: 8) {
                Text("Scanned Surfaces")
                    .font(.headline)

                Text("\(meshCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.cyan)

                if meshCount > 5 {
                    Text("✓ Good coverage")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Keep scanning...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Actions
            HStack(spacing: 16) {
                Button {
                    Task { await onCancel() }
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.bordered)

                Button {
                    Task { await onComplete() }
                } label: {
                    Text("Complete")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                .disabled(meshCount < 3)
            }
        }
        .padding(32)
        .frame(width: 500)
        .glassBackgroundEffect()
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.cyan)
                .frame(width: 30)

            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Geometry Extensions

extension GeometrySource {
    func asSIMD3(ofType type: Float.Type) -> [SIMD3<Float>] {
        var result: [SIMD3<Float>] = []
        let stride = self.stride
        let offset = self.offset
        let count = self.count

        for i in 0..<count {
            let index = i * stride + offset
            let x = buffer[index]
            let y = buffer[index + MemoryLayout<Float>.size]
            let z = buffer[index + 2 * MemoryLayout<Float>.size]

            result.append(SIMD3<Float>(
                Float(bitPattern: UInt32(x)),
                Float(bitPattern: UInt32(y)),
                Float(bitPattern: UInt32(z))
            ))
        }

        return result
    }
}

extension GeometryElement {
    func asUInt32Array() -> [UInt32] {
        var result: [UInt32] = []

        for i in 0..<count {
            let index = i * bytesPerIndex
            let value = buffer.withUnsafeBytes { bytes in
                bytes.load(fromByteOffset: index, as: UInt32.self)
            }
            result.append(value)
        }

        return result
    }
}

// MARK: - Preview

#Preview(immersionStyle: .full) {
    RoomScanView()
        .environment(AppState.preview)
}
