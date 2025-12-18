import SwiftUI
import RealityKit

struct MindMapView: View {
    var body: some View {
        RealityView { content in
            setupMindMap(content: content)
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("3D Mind Map")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Explore connections between ideas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
    }

    @MainActor
    private func setupMindMap(content: RealityViewContent) {
        // Central node
        let centralMesh = MeshResource.generateSphere(radius: 0.1)
        var centralMaterial = UnlitMaterial()
        centralMaterial.color = .init(tint: .blue)

        let centralNode = ModelEntity(mesh: centralMesh, materials: [centralMaterial])
        centralNode.position = [0, 0, -1]

        content.add(centralNode)

        // Connected nodes
        for i in 0..<6 {
            let angle = Float(i) * .pi / 3
            let x = cos(angle) * 0.3
            let z = sin(angle) * 0.3

            let nodeMesh = MeshResource.generateSphere(radius: 0.05)
            var nodeMaterial = UnlitMaterial()
            nodeMaterial.color = .init(tint: .purple.withAlphaComponent(0.8))

            let node = ModelEntity(mesh: nodeMesh, materials: [nodeMaterial])
            node.position = [x, 0, -1 + z]

            content.add(node)
        }
    }
}

struct AnalyticsVolumeView: View {
    var body: some View {
        RealityView { content in
            setup3DCharts(content: content)
        }
    }

    @MainActor
    private func setup3DCharts(content: RealityViewContent) {
        // 3D bar chart
        for i in 0..<5 {
            let height = Float.random(in: 0.1...0.5)
            let mesh = MeshResource.generateBox(size: [0.1, height, 0.1])
            var material = UnlitMaterial()
            material.color = .init(tint: .blue.withAlphaComponent(0.8))

            let bar = ModelEntity(mesh: mesh, materials: [material])
            bar.position = [Float(i) * 0.15 - 0.3, height / 2, -0.5]

            content.add(bar)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    MindMapView()
}
