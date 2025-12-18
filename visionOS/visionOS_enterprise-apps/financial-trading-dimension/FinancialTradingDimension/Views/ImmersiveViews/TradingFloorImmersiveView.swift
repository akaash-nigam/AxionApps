import SwiftUI
import RealityKit

struct TradingFloorImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // Create immersive trading floor environment
            let rootEntity = Entity()

            // Center: Main portfolio sphere
            let portfolioSphere = createPortfolioSphere()
            portfolioSphere.position = [0, 1.5, -2.0]
            rootEntity.addChild(portfolioSphere)

            // Left: Watchlist panel
            let watchlistPanel = createWatchlistPanel()
            watchlistPanel.position = [-1.5, 1.5, -2.0]
            watchlistPanel.look(at: [0, 1.5, 0], from: watchlistPanel.position, relativeTo: nil)
            rootEntity.addChild(watchlistPanel)

            // Right: Quick actions panel
            let actionsPanel = createActionsPanel()
            actionsPanel.position = [1.5, 1.5, -2.0]
            actionsPanel.look(at: [0, 1.5, 0], from: actionsPanel.position, relativeTo: nil)
            rootEntity.addChild(actionsPanel)

            // Above: Market indices
            let indicesDisplay = createIndicesDisplay()
            indicesDisplay.position = [0, 2.5, -2.0]
            rootEntity.addChild(indicesDisplay)

            // Floor: Trading controls
            let controls = createTradingControls()
            controls.position = [0, 0.8, -1.0]
            rootEntity.addChild(controls)

            content.add(rootEntity)

            // Environmental lighting
            setupImmersiveLighting(in: content)

        } update: { content in
            // Update real-time data
        }
        .overlay(alignment: .bottomTrailing) {
            Button("Exit Immersion") {
                // Exit immersive space
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }

    private func createPortfolioSphere() -> Entity {
        let sphere = Entity()

        let mesh = MeshResource.generateSphere(radius: 0.3)
        let material = SimpleMaterial(color: .blue.withAlphaComponent(0.5), isMetallic: true)
        sphere.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        return sphere
    }

    private func createWatchlistPanel() -> Entity {
        let panel = Entity()

        // Create a flat panel for watchlist
        let mesh = MeshResource.generatePlane(width: 0.4, depth: 0.6)
        let material = SimpleMaterial(color: .black.withAlphaComponent(0.7), isMetallic: false)
        panel.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        return panel
    }

    private func createActionsPanel() -> Entity {
        let panel = Entity()

        let mesh = MeshResource.generatePlane(width: 0.4, depth: 0.6)
        let material = SimpleMaterial(color: .black.withAlphaComponent(0.7), isMetallic: false)
        panel.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        return panel
    }

    private func createIndicesDisplay() -> Entity {
        let display = Entity()

        let mesh = MeshResource.generatePlane(width: 1.0, depth: 0.2)
        let material = SimpleMaterial(color: .black.withAlphaComponent(0.5), isMetallic: false)
        display.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        return display
    }

    private func createTradingControls() -> Entity {
        let controls = Entity()

        let mesh = MeshResource.generatePlane(width: 0.8, depth: 0.3)
        let material = SimpleMaterial(color: .white.withAlphaComponent(0.8), isMetallic: false)
        controls.components[ModelComponent.self] = ModelComponent(mesh: mesh, materials: [material])

        return controls
    }

    private func setupImmersiveLighting(in content: RealityViewContent) {
        // Directional light
        let dirLight = DirectionalLight()
        dirLight.light.intensity = 300
        dirLight.look(at: [0, 0, 0], from: [1, 2, 1], relativeTo: nil)
        content.add(dirLight)

        // Ambient light
        let ambientLight = AmbientLight()
        ambientLight.light.intensity = 150
        content.add(ambientLight)

        // Point lights for accent
        let accentLight1 = PointLight()
        accentLight1.light.intensity = 200
        accentLight1.light.color = .blue
        accentLight1.position = [-1, 2, -1]
        content.add(accentLight1)

        let accentLight2 = PointLight()
        accentLight2.light.intensity = 200
        accentLight2.light.color = .cyan
        accentLight2.position = [1, 2, -1]
        content.add(accentLight2)
    }
}

#Preview {
    TradingFloorImmersiveView()
        .environment(AppModel())
}
