import SwiftUI
import RealityKit

struct SupplyChainVolumeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            let scene = createSupplyChainGalaxy()
            content.add(scene)
        }
    }

    private func createSupplyChainGalaxy() -> Entity {
        let root = Entity()

        // Create supplier nodes as stars
        let suppliers = createSupplierNodes()
        suppliers.forEach { root.addChild($0) }

        // Create facility nodes
        let facilities = createFacilityNodes()
        facilities.forEach { root.addChild($0) }

        // Create logistics routes
        let routes = createLogisticsRoutes()
        routes.forEach { root.addChild($0) }

        return root
    }

    private func createSupplierNodes() -> [Entity] {
        var nodes: [Entity] = []
        let positions: [SIMD3<Float>] = [
            [-0.6, 0.4, -0.6],
            [0.6, 0.4, -0.6],
            [0, 0.6, 0.6]
        ]

        for position in positions {
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.08),
                materials: [SimpleMaterial(color: .systemYellow, isMetallic: true)]
            )
            sphere.position = position
            nodes.append(sphere)
        }

        return nodes
    }

    private func createFacilityNodes() -> [Entity] {
        var nodes: [Entity] = []
        let center = ModelEntity(
            mesh: .generateBox(width: 0.12, height: 0.12, depth: 0.12),
            materials: [SimpleMaterial(color: .systemBlue, isMetallic: false)]
        )
        center.position = [0, 0, 0]
        nodes.append(center)
        return nodes
    }

    private func createLogisticsRoutes() -> [Entity] {
        // Create connecting lines between nodes
        return []
    }
}

#Preview {
    SupplyChainVolumeView()
        .environment(AppState())
}
