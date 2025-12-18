import SwiftUI
import RealityKit

struct TechnicalAnalysisVolumeView: View {
    @Environment(AppModel.self) private var appModel
    @State private var selectedSymbol = "AAPL"
    @State private var priceData: [OHLCV] = []

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()

            // Create 3D price chart
            generate3DChart(in: rootEntity)

            content.add(rootEntity)

            // Add lighting
            let light = DirectionalLight()
            light.light.intensity = 400
            light.look(at: [0, 0, 0], from: [0.5, 1, 0.5], relativeTo: nil)
            content.add(light)
        } update: { content in
            // Update when data changes
        }
        .task {
            await loadPriceData()
        }
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Technical Analysis")
                    .font(.title2.bold())

                Picker("Symbol", selection: $selectedSymbol) {
                    ForEach(appModel.activeMarketSymbols, id: \.self) { symbol in
                        Text(symbol).tag(symbol)
                    }
                }
                .pickerStyle(.menu)

                Text("3D price chart with multiple timeframes")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !priceData.isEmpty {
                    Text("\(priceData.count) data points")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            .padding()
        }
        .onChange(of: selectedSymbol) {
            Task {
                await loadPriceData()
            }
        }
    }

    private func generate3DChart(in root: Entity) {
        guard !priceData.isEmpty else { return }

        // Create 3D surface representing price over time
        for (index, candle) in priceData.enumerated() {
            let bar = createCandlestickBar(candle: candle, index: index, total: priceData.count)
            root.addChild(bar)
        }
    }

    private func createCandlestickBar(candle: OHLCV, index: Int, total: Int) -> Entity {
        let bar = Entity()

        // Normalize price to 0-1 range
        let minPrice = priceData.map { $0.low }.min() ?? 0
        let maxPrice = priceData.map { $0.high }.max() ?? 100
        let range = maxPrice - minPrice

        let openNorm = Float(truncating: ((candle.open - minPrice) / range) as NSNumber)
        let closeNorm = Float(truncating: ((candle.close - minPrice) / range) as NSNumber)
        let lowNorm = Float(truncating: ((candle.low - minPrice) / range) as NSNumber)
        let highNorm = Float(truncating: ((candle.high - minPrice) / range) as NSNumber)

        let bodyHeight = abs(closeNorm - openNorm)
        let bodyY = min(openNorm, closeNorm) + bodyHeight / 2

        // Create body
        let bodyMesh = MeshResource.generateBox(width: 0.01, height: bodyHeight * 0.5, depth: 0.01)
        let isGreen = candle.close >= candle.open
        let bodyMaterial = SimpleMaterial(
            color: isGreen ? .green.withAlphaComponent(0.8) : .red.withAlphaComponent(0.8),
            isMetallic: false
        )

        let bodyModel = ModelComponent(mesh: bodyMesh, materials: [bodyMaterial])
        bar.components[ModelComponent.self] = bodyModel

        // Position in X (time) and Y (price)
        let x = Float(index) / Float(total) * 1.0 - 0.5
        let y = bodyY * 0.5
        let z: Float = 0

        bar.position = [x, y, z]

        return bar
    }

    private func loadPriceData() async {
        do {
            priceData = try await appModel.marketDataService.getHistoricalData(
                symbol: selectedSymbol,
                timeframe: .oneMonth
            )
        } catch {
            print("Failed to load price data: \(error)")
        }
    }
}

#Preview {
    TechnicalAnalysisVolumeView()
        .environment(AppModel())
}
