import SwiftUI
import RealityKit

struct RetailSpaceView: View {
    @State private var customerCount = 8
    @State private var revenue: Double = 24537
    @State private var heatmapEnabled = true

    var body: some View {
        RealityView { content in
            // Create retail store environment
            let store = createRetailStore()
            content.add(store)

            // Add product displays
            let displays = createProductDisplays()
            displays.position = [0, 0, -2]
            content.add(displays)

            // Add checkout counter
            let checkout = createCheckoutCounter()
            checkout.position = [2, 0.8, -1]
            content.add(checkout)

            // Add mannequins/products
            let mannequins = createMannequins()
            mannequins.position = [-2, 0, -2]
            content.add(mannequins)

            // Add shopping path indicators
            let pathIndicators = createShoppingPath()
            pathIndicators.position = [0, 0.01, 0]
            content.add(pathIndicators)
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Store Analytics")
                    .font(.title2)
                    .fontWeight(.bold)

                Divider()

                // Real-time metrics
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Label("Active Customers", systemImage: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(customerCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }

                    Divider()
                        .frame(height: 50)

                    VStack(alignment: .leading) {
                        Label("Today's Revenue", systemImage: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "$%.0f", revenue))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                }

                Divider()

                // Heatmap toggle
                Toggle(isOn: $heatmapEnabled) {
                    Label("Customer Heatmap", systemImage: "map.fill")
                        .font(.headline)
                }
                .toggleStyle(.switch)
                .tint(.orange)

                // Hot zones
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hot Zones")
                        .font(.headline)

                    HotZoneRow(name: "Entrance Area", traffic: 95, color: .red)
                    HotZoneRow(name: "Main Display", traffic: 78, color: .orange)
                    HotZoneRow(name: "Checkout", traffic: 62, color: .yellow)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
    }

    private func createRetailStore() -> Entity {
        let store = Entity()

        // Floor
        let floor = ModelEntity(
            mesh: .generatePlane(width: 10, depth: 8),
            materials: [SimpleMaterial(color: .init(white: 0.9, alpha: 1), isMetallic: false)]
        )
        floor.position.y = -0.5
        store.addChild(floor)

        // Walls
        let wallMaterial = SimpleMaterial(color: .init(white: 0.95, alpha: 1), isMetallic: false)

        let backWall = ModelEntity(
            mesh: .generateBox(width: 10, height: 3, depth: 0.1),
            materials: [wallMaterial]
        )
        backWall.position = [0, 1, -5]
        store.addChild(backWall)

        return store
    }

    private func createProductDisplays() -> Entity {
        let displays = Entity()

        for i in 0..<3 {
            let display = ModelEntity(
                mesh: .generateBox(width: 0.8, height: 1.2, depth: 0.4),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            display.position = [Float(i - 1) * 1.5, 0.6, 0]
            displays.addChild(display)

            // Add product on display
            let product = ModelEntity(
                mesh: .generateBox(width: 0.3, height: 0.2, depth: 0.2),
                materials: [SimpleMaterial(color: .systemBlue, isMetallic: true)]
            )
            product.position = [Float(i - 1) * 1.5, 1.3, 0]
            displays.addChild(product)
        }

        return displays
    }

    private func createCheckoutCounter() -> ModelEntity {
        let counter = ModelEntity(
            mesh: .generateBox(width: 1.2, height: 0.9, depth: 0.6),
            materials: [SimpleMaterial(color: .systemGray, isMetallic: false)]
        )

        return counter
    }

    private func createMannequins() -> Entity {
        let mannequins = Entity()

        for i in 0..<2 {
            let mannequin = ModelEntity(
                mesh: .generateCylinder(height: 1.6, radius: 0.15),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            mannequin.position = [0, 0.8, Float(i) * 1]
            mannequins.addChild(mannequin)

            // Add head
            let head = ModelEntity(
                mesh: .generateSphere(radius: 0.12),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            head.position = [0, 1.6, Float(i) * 1]
            mannequins.addChild(head)
        }

        return mannequins
    }

    private func createShoppingPath() -> Entity {
        let path = Entity()

        // Create path indicators (arrows showing customer flow)
        for i in 0..<5 {
            let indicator = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .systemOrange, isMetallic: false)]
            )
            indicator.position = [Float(i - 2) * 0.8, 0, Float(-i) * 0.5]
            path.addChild(indicator)
        }

        return path
    }
}

struct HotZoneRow: View {
    let name: String
    let traffic: Int
    let color: Color

    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 5) {
                ProgressView(value: Double(traffic), total: 100)
                    .tint(color)
                    .frame(width: 60)

                Text("\(traffic)%")
                    .font(.caption)
                    .foregroundStyle(color)
                    .frame(width: 35)
            }
        }
    }
}

#Preview {
    RetailSpaceView()
}
