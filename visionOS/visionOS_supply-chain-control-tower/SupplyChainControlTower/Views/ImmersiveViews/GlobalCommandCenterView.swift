//
//  GlobalCommandCenterView.swift
//  SupplyChainControlTower
//
//  Immersive space with global 3D globe visualization
//

import SwiftUI
import RealityKit

struct GlobalCommandCenterView: View {
    @Environment(AppState.self) private var appState
    @State private var globeRotation: Angle = .zero

    var body: some View {
        RealityView { content in
            await setupCommandCenter(content: content)
        } update: { content in
            if let network = appState.network {
                await updateCommandCenter(content: content, network: network)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Rotate globe based on drag
                    let rotationAmount = value.translation.width / 500
                    globeRotation = .degrees(Double(rotationAmount) * 360)
                }
        )
    }

    @MainActor
    private func setupCommandCenter(content: RealityViewContent) async {
        let rootEntity = Entity()
        rootEntity.name = "CommandCenterRoot"

        // Create the main globe entity (5m diameter as specified)
        let globeRadius: Float = 2.5 // 5m diameter = 2.5m radius
        let globe = createGlobe(radius: globeRadius)
        globe.name = "Globe"
        globe.position = [0, 1.5, -2.0] // 2m forward, 1.5m up (eye level)
        rootEntity.addChild(globe)

        // Add immersive lighting
        await setupLighting(rootEntity: rootEntity)

        // Add alert zone (0.5-1m from user)
        let alertZone = createAlertZone()
        alertZone.position = [0, 1.6, -0.75] // Eye level, 0.75m forward
        rootEntity.addChild(alertZone)

        content.add(rootEntity)
    }

    @MainActor
    private func updateCommandCenter(content: RealityViewContent, network: SupplyChainNetwork) async {
        guard let rootEntity = content.entities.first(where: { $0.name == "CommandCenterRoot" }),
              let globe = rootEntity.findEntity(named: "Globe") else {
            return
        }

        // Update globe rotation
        globe.orientation = simd_quatf(angle: Float(globeRotation.radians), axis: [0, 1, 0])

        // Update nodes on globe
        await updateGlobeNodes(globe: globe, network: network)

        // Update routes on globe
        await updateGlobeRoutes(globe: globe, network: network)
    }

    @MainActor
    private func createGlobe(radius: Float) -> Entity {
        let globe = Entity()

        // Create sphere mesh for Earth
        let mesh = MeshResource.generateSphere(radius: radius)

        // Create Earth-like material
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .systemBlue.withAlphaComponent(0.3))
        material.roughness = 0.5
        material.metallic = 0.1

        // Make it semi-transparent so we can see nodes inside
        material.blending = .transparent(opacity: 0.3)

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        globe.components.set(modelComponent)

        // Add rotation capability
        globe.components.set(InputTargetComponent())

        return globe
    }

    @MainActor
    private func updateGlobeNodes(globe: Entity, network: SupplyChainNetwork) async {
        // Remove existing node markers
        globe.children.removeAll(where: { $0.name.hasPrefix("Pin-") })

        // Add node markers for each facility
        for node in network.nodes {
            let pinEntity = createNodePin(node: node, globeRadius: 2.5)
            globe.addChild(pinEntity)
        }
    }

    @MainActor
    private func createNodePin(node: Node, globeRadius: Float) -> Entity {
        let entity = Entity()
        entity.name = "Pin-\(node.id)"

        // Convert lat/lon to 3D position on sphere
        let lat = Float(node.location.latitude) * .pi / 180
        let lon = Float(node.location.longitude) * .pi / 180

        // Spherical to Cartesian coordinates
        let x = globeRadius * cos(lat) * cos(lon)
        let y = globeRadius * sin(lat)
        let z = globeRadius * cos(lat) * sin(lon)

        // Create pin visualization
        let pinHeight: Float = 0.15 // 15cm pin rising from surface
        let pinMesh = MeshResource.generateCylinder(height: pinHeight, radius: 0.015)

        var material = PhysicallyBasedMaterial()
        let pinColor = statusColor(status: node.status)
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: pinColor)
        material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: pinColor)
        material.emissiveIntensity = 0.8

        let modelComponent = ModelComponent(mesh: pinMesh, materials: [material])
        entity.components.set(modelComponent)

        // Position on globe surface, extending outward
        let surfaceX = x * 1.05 // Slightly outside surface
        let surfaceY = y * 1.05
        let surfaceZ = z * 1.05

        entity.position = SIMD3(x: surfaceX, y: surfaceY, z: surfaceZ)

        // Orient pin to point away from globe center
        let normal = normalize(SIMD3(x: x, y: y, z: z))
        let up = SIMD3<Float>(0, 1, 0)
        let angle = acos(dot(normal, up))
        let axis = cross(up, normal)
        if length(axis) > 0.001 {
            entity.orientation = simd_quatf(angle: angle, axis: normalize(axis))
        }

        // Add interaction component
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())

        return entity
    }

    @MainActor
    private func updateGlobeRoutes(globe: Entity, network: SupplyChainNetwork) async {
        // Remove existing routes
        globe.children.removeAll(where: { $0.name.hasPrefix("Route-") })

        // Add route arcs between nodes
        for edge in network.edges {
            if let sourceNode = network.nodes.first(where: { $0.id == edge.source }),
               let destNode = network.nodes.first(where: { $0.id == edge.destination }) {
                let routeEntity = createRouteArc(from: sourceNode, to: destNode, globeRadius: 2.5)
                globe.addChild(routeEntity)
            }
        }
    }

    @MainActor
    private func createRouteArc(from sourceNode: Node, to destNode: Node, globeRadius: Float) -> Entity {
        let entity = Entity()
        entity.name = "Route-\(sourceNode.id)-\(destNode.id)"

        // Convert positions to 3D
        let sourceLat = Float(sourceNode.location.latitude) * .pi / 180
        let sourceLon = Float(sourceNode.location.longitude) * .pi / 180
        let sourceX = globeRadius * cos(sourceLat) * cos(sourceLon) * 1.15
        let sourceY = globeRadius * sin(sourceLat) * 1.15
        let sourceZ = globeRadius * cos(sourceLat) * sin(sourceLon) * 1.15

        let destLat = Float(destNode.location.latitude) * .pi / 180
        let destLon = Float(destNode.location.longitude) * .pi / 180
        let destX = globeRadius * cos(destLat) * cos(destLon) * 1.15
        let destY = globeRadius * sin(destLat) * 1.15
        let destZ = globeRadius * cos(destLat) * sin(destLon) * 1.15

        // Create simple line (in production, this would be a curved arc)
        let distance = sqrt(pow(destX - sourceX, 2) + pow(destY - sourceY, 2) + pow(destZ - sourceZ, 2))
        let mesh = MeshResource.generateCylinder(height: distance, radius: 0.005)

        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .systemGray)
        material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: .systemBlue)
        material.emissiveIntensity = 0.3

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        // Position at midpoint
        let midX = (sourceX + destX) / 2
        let midY = (sourceY + destY) / 2
        let midZ = (sourceZ + destZ) / 2
        entity.position = SIMD3(x: midX, y: midY, z: midZ)

        return entity
    }

    @MainActor
    private func setupLighting(rootEntity: Entity) async {
        // Directional light (sun)
        var sunLight = DirectionalLightComponent()
        sunLight.intensity = 8000
        sunLight.color = .white
        let sunEntity = Entity()
        sunEntity.components.set(sunLight)
        sunEntity.position = [5, 10, 5]
        rootEntity.addChild(sunEntity)

        // Ambient light
        var ambientLight = DirectionalLightComponent()
        ambientLight.intensity = 2000
        ambientLight.color = .white
        let ambientEntity = Entity()
        ambientEntity.components.set(ambientLight)
        rootEntity.addChild(ambientEntity)
    }

    @MainActor
    private func createAlertZone() -> Entity {
        let entity = Entity()
        entity.name = "AlertZone"

        // This would contain floating alert panels
        // For now, just a placeholder
        return entity
    }

    private func statusColor(status: NodeStatus) -> UIColor {
        switch status {
        case .healthy: return .systemGreen
        case .warning: return .systemYellow
        case .critical: return .systemRed
        case .offline: return .systemGray
        }
    }
}

#Preview {
    GlobalCommandCenterView()
        .environment(AppState())
}
