//
//  ManufacturingFloorView.swift
//  IndustrialCADCAM
//
//  Virtual manufacturing floor immersive experience
//

import SwiftUI
import RealityKit

struct ManufacturingFloorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var rootEntity = Entity()
    @State private var showSafetyZones = true
    @State private var showProductionFlow = true

    var body: some View {
        RealityView { content in
            setupManufacturingFloor(content: content)
        }
        .ornament(attachmentAnchor: .scene(.topLeading)) {
            floorInfoOrnament
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            floorControlsOrnament
        }
    }

    // MARK: - Scene Setup

    private func setupManufacturingFloor(content: RealityViewContent) {
        content.add(rootEntity)

        // Add factory floor
        addFactoryFloor()

        // Add machine tools
        addMachineTools()

        // Add safety zones
        if showSafetyZones {
            addSafetyZones()
        }

        // Add production flow indicators
        if showProductionFlow {
            addProductionFlow()
        }
    }

    private func addFactoryFloor() {
        // Large factory floor (20m x 20m)
        let floorMesh = MeshResource.generatePlane(width: 20, depth: 20)

        var floorMaterial = SimpleMaterial()
        floorMaterial.color = .init(tint: .gray.withAlphaComponent(0.3))

        let floor = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        floor.position = SIMD3<Float>(0, 0, 0)

        rootEntity.addChild(floor)
    }

    private func addMachineTools() {
        // Add CNC machines
        let machinePositions: [(SIMD3<Float>, String)] = [
            (SIMD3<Float>(-3, 1, -3), "CNC Mill 1"),
            (SIMD3<Float>(3, 1, -3), "CNC Mill 2"),
            (SIMD3<Float>(-3, 1, 3), "CNC Lathe 1"),
            (SIMD3<Float>(3, 1, 3), "Assembly Station"),
        ]

        for (position, name) in machinePositions {
            let machine = createMachinePlaceholder(name: name)
            machine.position = position
            rootEntity.addChild(machine)
        }
    }

    private func createMachinePlaceholder(name: String) -> Entity {
        // Create a simple box representing a machine
        let mesh = MeshResource.generateBox(size: [2.0, 2.0, 1.5])

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .init(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0))
        material.metallic = 0.8
        material.roughness = 0.5

        let machineEntity = ModelEntity(mesh: mesh, materials: [material])

        // Add a label (placeholder)
        // TODO: Add 3D text label

        return machineEntity
    }

    private func addSafetyZones() {
        // Add yellow safety zone markers around machines
        let safetyZonePositions: [SIMD3<Float>] = [
            SIMD3<Float>(-3, 0.01, -3),
            SIMD3<Float>(3, 0.01, -3),
            SIMD3<Float>(-3, 0.01, 3),
            SIMD3<Float>(3, 0.01, 3),
        ]

        for position in safetyZonePositions {
            let zone = createSafetyZone()
            zone.position = position
            rootEntity.addChild(zone)
        }
    }

    private func createSafetyZone() -> Entity {
        // Create a yellow circle on the floor
        let mesh = MeshResource.generatePlane(width: 3, depth: 3)

        var material = UnlitMaterial()
        material.color = .init(tint: .yellow.withAlphaComponent(0.3))

        let zone = ModelEntity(mesh: mesh, materials: [material])
        return zone
    }

    private func addProductionFlow() {
        // Add arrows showing material flow
        // TODO: Add animated arrows showing production flow
    }

    // MARK: - Ornaments

    private var floorInfoOrnament: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏭 Manufacturing Floor")
                .font(.headline)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                FloorStatRow(label: "OEE", value: "85%", color: .green)
                FloorStatRow(label: "Active Machines", value: "3/4", color: .blue)
                FloorStatRow(label: "Queue Time", value: "12 min", color: .orange)
                FloorStatRow(label: "Cycle Time", value: "8.5 min", color: .cyan)
            }
        }
        .padding()
        .frame(width: 250)
        .glassBackgroundEffect()
    }

    private var floorControlsOrnament: some View {
        HStack(spacing: 16) {
            Toggle("Safety Zones", isOn: $showSafetyZones)
                .toggleStyle(.switch)

            Toggle("Production Flow", isOn: $showProductionFlow)
                .toggleStyle(.switch)

            Divider()

            Button(action: {}) {
                Label("View Details", systemImage: "info.circle")
            }
            .buttonStyle(.bordered)

            Button(action: { exitFloorView() }) {
                Label("Exit", systemImage: "xmark.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .glassBackgroundEffect()
    }

    // MARK: - Actions

    private func exitFloorView() {
        Task {
            await dismissImmersiveSpace()
        }
    }
}

// MARK: - Floor Stat Row

struct FloorStatRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    ManufacturingFloorView()
}
