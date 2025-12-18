import SwiftUI
import RealityKit

struct CorrelationVolumeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var correlationData: [[Double]] = []
    @State private var selectedAsset: String?

    var body: some View {
        RealityView { content in
            // Create the correlation visualization
            let rootEntity = Entity()

            // Generate asset spheres based on correlation
            generateCorrelationVisualization(in: rootEntity)

            content.add(rootEntity)

            // Add lighting
            let directionalLight = DirectionalLight()
            directionalLight.light.intensity = 500
            directionalLight.look(at: [0, 0, 0], from: [0, 1, 1], relativeTo: nil)
            content.add(directionalLight)

            let ambientLight = AmbientLight()
            ambientLight.light.intensity = 200
            content.add(ambientLight)
        } update: { content in
            // Update visualization when data changes
        }
        .task {
            await loadCorrelationData()
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Market Correlation")
                    .font(.title2.bold())

                Text("3D visualization of asset correlations")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let selected = selectedAsset {
                    Text("Selected: \(selected)")
                        .font(.body.bold())
                        .foregroundStyle(.blue)
                }

                Divider()

                Text("Legend:")
                    .font(.caption.bold())

                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                    Text("Positive correlation")
                        .font(.caption)
                }

                HStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                    Text("Negative correlation")
                        .font(.caption)
                }
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            .padding()
        }
    }

    private func generateCorrelationVisualization(in root: Entity) {
        let symbols = appModel.activeMarketSymbols
        let count = symbols.count

        // Position assets in 3D space based on correlation
        for (index, symbol) in symbols.enumerated() {
            let sphere = createAssetSphere(symbol: symbol, index: index, total: count)
            root.addChild(sphere)
        }

        // Create connection lines between correlated assets
        createCorrelationLines(in: root, symbols: symbols)
    }

    private func createAssetSphere(symbol: String, index: Int, total: Int) -> Entity {
        let sphere = Entity()

        // Create sphere mesh
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .blue, isMetallic: true)

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        sphere.components[ModelComponent.self] = modelComponent

        // Position in circle formation
        let angle = Float(index) * (2 * .pi / Float(total))
        let radius: Float = 0.3
        let x = cos(angle) * radius
        let z = sin(angle) * radius
        let y: Float = 0

        sphere.position = [x, y, z]

        // Add collision for interaction
        sphere.components[CollisionComponent.self] = CollisionComponent(
            shapes: [.generateSphere(radius: 0.05)]
        )

        // Add input target for tap gestures
        sphere.components[InputTargetComponent.self] = InputTargetComponent()

        return sphere
    }

    private func createCorrelationLines(in root: Entity, symbols: [String]) {
        // Create lines between assets based on correlation strength
        // (Simplified - in real app would use actual correlation values)
        for i in 0..<symbols.count {
            for j in (i+1)..<symbols.count {
                if Double.random(in: 0...1) > 0.5 {
                    // Create line between assets i and j
                    // (Line creation would require custom mesh or cylinder)
                }
            }
        }
    }

    private func loadCorrelationData() async {
        correlationData = await appModel.riskService.calculateCorrelationMatrix(
            symbols: appModel.activeMarketSymbols
        )
    }
}

#Preview {
    CorrelationVolumeView()
        .environment(AppModel())
}
