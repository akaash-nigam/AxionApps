import SwiftUI
import RealityKit

struct RiskVolumeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var exposureData: [String: Decimal] = [:]

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()

            // Create 3D bar chart for risk exposure
            generateRiskVisualization(in: rootEntity)

            content.add(rootEntity)

            // Add lighting
            let light = DirectionalLight()
            light.light.intensity = 500
            content.add(light)
        }
        .task {
            await loadRiskData()
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Risk Exposure")
                    .font(.title2.bold())

                Text("Portfolio risk breakdown")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                ForEach(Array(exposureData.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                            .font(.caption)

                        Spacer()

                        Text(exposureData[key] ?? 0, format: .currency(code: "USD"))
                            .font(.caption.bold())
                    }
                }
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            .padding()
        }
    }

    private func generateRiskVisualization(in root: Entity) {
        let riskFactors = Array(exposureData.keys.sorted())
        let maxExposure = exposureData.values.max() ?? 1

        for (index, factor) in riskFactors.enumerated() {
            guard let exposure = exposureData[factor] else { continue }

            let height = Float(truncating: (exposure / maxExposure) as NSNumber) * 0.5
            let bar = createRiskBar(height: height, index: index, total: riskFactors.count)
            root.addChild(bar)
        }
    }

    private func createRiskBar(height: Float, index: Int, total: Int) -> Entity {
        let bar = Entity()

        // Create bar mesh
        let mesh = MeshResource.generateBox(width: 0.08, height: height, depth: 0.08)
        let material = SimpleMaterial(color: .red.withAlphaComponent(0.7), isMetallic: false)

        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        bar.components[ModelComponent.self] = modelComponent

        // Position bars in a row
        let spacing: Float = 0.12
        let totalWidth = Float(total - 1) * spacing
        let x = Float(index) * spacing - totalWidth / 2

        bar.position = [x, height / 2, 0]

        return bar
    }

    private func loadRiskData() async {
        exposureData = await appModel.riskService.calculateExposureByAssetClass()
    }
}

#Preview {
    RiskVolumeView()
        .environment(AppModel())
}
