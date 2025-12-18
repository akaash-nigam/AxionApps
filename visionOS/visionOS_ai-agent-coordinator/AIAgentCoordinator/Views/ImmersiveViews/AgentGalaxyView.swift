//
//  AgentGalaxyView.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import SwiftUI
import RealityKit

/// Immersive 3D galaxy visualization of agent network
/// Shows agents as spheres in a spiral galaxy formation
struct AgentGalaxyView: View {
    @Environment(AgentNetworkViewModel.self) private var viewModel
    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            // Set up root entity
            content.add(rootEntity)

            // Create galaxy scene
            await setupGalaxyScene()

        } update: { content in
            // Update agent positions and states
            Task {
                await updateAgentEntities()
            }
        }
        .onAppear {
            Task {
                await viewModel.load()
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleAgentTap(value.entity)
                }
        )
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                HStack(spacing: 20) {
                    Button {
                        viewModel.changeLayout(to: .galaxy)
                    } label: {
                        Label("Galaxy", systemImage: "sparkles")
                    }

                    Button {
                        viewModel.changeLayout(to: .grid)
                    } label: {
                        Label("Grid", systemImage: "square.grid.3x3")
                    }

                    Button {
                        viewModel.changeLayout(to: .cluster)
                    } label: {
                        Label("Cluster", systemImage: "circle.hexagongrid")
                    }

                    Divider()

                    Toggle(isOn: Binding(
                        get: { viewModel.showConnections },
                        set: { viewModel.showConnections = $0 }
                    )) {
                        Label("Connections", systemImage: "arrow.triangle.branch")
                    }
                    .toggleStyle(.button)

                    Toggle(isOn: Binding(
                        get: { viewModel.enableLOD },
                        set: { viewModel.enableLOD = $0 }
                    )) {
                        Label("LOD", systemImage: "slider.horizontal.3")
                    }
                    .toggleStyle(.button)
                }
                .padding()
                .glassBackgroundEffect()
            }
        }
    }

    // MARK: - Scene Setup

    @MainActor
    private func setupGalaxyScene() async {
        // Create ambient lighting
        let ambientLight = DirectionalLight()
        ambientLight.light.intensity = 500
        ambientLight.orientation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
        rootEntity.addChild(ambientLight)

        // Create agents
        await createAgentEntities()
    }

    // MARK: - Agent Entities

    @MainActor
    private func createAgentEntities() async {
        // Clear existing agents
        rootEntity.children.removeAll { $0.name.starts(with: "agent-") }

        for agent in viewModel.agents {
            let entity = createAgentEntity(for: agent)
            rootEntity.addChild(entity)
        }

        // Create connections if enabled
        if viewModel.showConnections {
            createConnectionEntities()
        }
    }

    @MainActor
    private func createAgentEntity(for agent: AIAgent) -> Entity {
        let entity = Entity()
        entity.name = "agent-\(agent.id.uuidString)"

        // Get position from view model
        let position = viewModel.agentPositions[agent.id] ?? SIMD3(0, 0, 0)

        // Create sphere mesh
        let mesh = MeshResource.generateSphere(radius: 0.05)

        // Create material with agent color
        let color = viewModel.color(for: agent)
        var material = UnlitMaterial()
        material.color = .init(
            tint: .init(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1.0)
        )

        // Add model component
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Set position
        entity.position = position

        // Add collision for tap detection
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.05)]))

        // Add custom component to store agent ID
        entity.components.set(AgentIdentifierComponent(agentId: agent.id))

        return entity
    }

    @MainActor
    private func createConnectionEntities() {
        // Create lines between connected agents
        for agent in viewModel.agents {
            guard let sourcePos = viewModel.agentPositions[agent.id] else { continue }

            for connection in agent.connections {
                guard let targetPos = viewModel.agentPositions[connection.targetAgentId] else {
                    continue
                }

                let line = createConnectionLine(from: sourcePos, to: targetPos)
                rootEntity.addChild(line)
            }
        }
    }

    @MainActor
    private func createConnectionLine(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Entity {
        let entity = Entity()

        // Calculate line direction and length
        let direction = end - start
        let length = simd_length(direction)
        let midpoint = (start + end) / 2

        // Create cylinder mesh for line
        let mesh = MeshResource.generateCylinder(height: length, radius: 0.002)

        // Create material
        var material = UnlitMaterial()
        material.color = .init(tint: .cyan.withAlphaComponent(0.3))

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Position and orient the line
        entity.position = midpoint

        // Calculate rotation to align with direction
        let up = SIMD3<Float>(0, 1, 0)
        let normalizedDir = normalize(direction)
        let rotation = simd_quatf(from: up, to: normalizedDir)
        entity.orientation = rotation

        return entity
    }

    // MARK: - Updates

    @MainActor
    private func updateAgentEntities() async {
        for agent in viewModel.agents {
            guard let entity = rootEntity.findEntity(named: "agent-\(agent.id.uuidString)") else {
                continue
            }

            // Update position
            if let newPosition = viewModel.agentPositions[agent.id] {
                // Smoothly animate to new position
                entity.move(
                    to: Transform(translation: newPosition),
                    relativeTo: rootEntity,
                    duration: 0.5
                )
            }

            // Update color based on status
            if var modelComponent = entity.components[ModelComponent.self] {
                let color = viewModel.color(for: agent)
                var material = UnlitMaterial()
                material.color = .init(
                    tint: .init(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1.0)
                )
                modelComponent.materials = [material]
                entity.components.set(modelComponent)
            }
        }
    }

    // MARK: - Interaction

    private func handleAgentTap(_ entity: Entity) {
        // Find the agent ID from the entity
        if let component = entity.components[AgentIdentifierComponent.self],
           let agent = viewModel.agents.first(where: { $0.id == component.agentId }) {
            viewModel.selectAgent(agent)

            // Provide haptic feedback
            #if os(visionOS)
            // Haptic feedback would go here
            #endif
        }
    }
}

// MARK: - Custom Component

/// Component to store agent ID on entities
struct AgentIdentifierComponent: Component {
    let agentId: UUID
}

#Preview {
    AgentGalaxyView()
        .environment(AgentNetworkViewModel())
}
