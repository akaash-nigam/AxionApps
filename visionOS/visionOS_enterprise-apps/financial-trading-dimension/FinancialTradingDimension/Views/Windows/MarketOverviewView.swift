import SwiftUI

struct MarketOverviewView: View {
    @Environment(AppModel.self) private var appModel
    @State private var selectedIndex: MarketIndex?

    var body: some View {
        @Bindable var appModel = appModel

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Major Indices
                    IndicesSection(appModel: appModel, selectedIndex: $selectedIndex)

                    // Market Heatmap
                    MarketHeatmapSection()

                    // Top Gainers and Losers
                    HStack(spacing: 16) {
                        GainersLosersSection(title: "Top Gainers", isGainers: true)
                        GainersLosersSection(title: "Top Losers", isGainers: false)
                    }

                    // Watchlist
                    WatchlistSection(appModel: appModel)
                }
                .padding()
            }
            .navigationTitle("Market Overview")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Open settings
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await refreshMarketData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .glassBackgroundEffect()
        }
    }

    private func refreshMarketData() async {
        // Refresh market data
    }
}

struct IndicesSection: View {
    var appModel: AppModel
    @Binding var selectedIndex: MarketIndex?

    let indices: [MarketIndex] = [
        MarketIndex(name: "S&P 500", symbol: "SPY", value: 5234.56, change: 45.67, changePercent: 0.87),
        MarketIndex(name: "NASDAQ", symbol: "QQQ", value: 16789.12, change: 204.56, changePercent: 1.23),
        MarketIndex(name: "DOW JONES", symbol: "DIA", value: 42156.78, change: -143.89, changePercent: -0.34)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Major Indices")
                .font(.headline)

            HStack(spacing: 16) {
                ForEach(indices) { index in
                    IndexCard(index: index)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
        }
    }
}

struct IndexCard: View {
    var index: MarketIndex

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(index.name)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(index.value, format: .number.precision(.fractionLength(2)))
                .font(.title2.bold())

            HStack(spacing: 4) {
                Image(systemName: index.isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)

                Text(index.changePercent, format: .percent.precision(.fractionLength(2)))
                    .font(.caption.bold())
            }
            .foregroundStyle(index.isPositive ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }
}

struct MarketHeatmapSection: View {
    let assetClasses = [
        ("Equities", 0.75, Color.green),
        ("Fixed Income", 0.15, Color.blue),
        ("Commodities", 0.45, Color.orange),
        ("Currencies", 0.20, Color.purple),
        ("Crypto", 0.95, Color.cyan),
        ("Real Estate", 0.25, Color.brown)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Heatmap")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(assetClasses, id: \.0) { asset in
                    HStack {
                        Text(asset.0)
                            .font(.caption)

                        Spacer()

                        Rectangle()
                            .fill(asset.2.opacity(asset.1))
                            .frame(width: 60, height: 20)
                            .overlay {
                                Text("\(Int(asset.1 * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                    }
                    .padding(8)
                    .background(.regularMaterial, in: .rect(cornerRadius: 8))
                }
            }
        }
    }
}

struct GainersLosersSection: View {
    var title: String
    var isGainers: Bool

    var stocks: [(String, Double, Double)] {
        if isGainers {
            return [
                ("AAPL", 189.45, 5.2),
                ("GOOGL", 142.78, 3.8),
                ("NVDA", 789.23, 7.1)
            ]
        } else {
            return [
                ("MSFT", 412.34, -2.1),
                ("TSLA", 245.67, -3.4),
                ("AMZN", 178.90, -1.8)
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(stocks, id: \.0) { stock in
                    HStack {
                        Text(stock.0)
                            .font(.body.bold())

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("$\(stock.1, specifier: "%.2f")")
                                .font(.body)

                            Text("\(stock.2, specifier: "%+.1f")%")
                                .font(.caption)
                                .foregroundStyle(isGainers ? .green : .red)
                        }
                    }
                    .padding(8)
                    .background(.regularMaterial, in: .rect(cornerRadius: 8))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct WatchlistSection: View {
    var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Watchlist")
                    .font(.headline)

                Spacer()

                Button("Add Symbol") {
                    // Add symbol to watchlist
                }
                .buttonStyle(.bordered)
            }

            VStack(spacing: 8) {
                ForEach(appModel.activeMarketSymbols, id: \.self) { symbol in
                    if let data = appModel.marketDataUpdates[symbol] {
                        WatchlistRow(data: data)
                    }
                }
            }
        }
    }
}

struct WatchlistRow: View {
    var data: MarketData

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.symbol)
                    .font(.body.bold())

                Text(data.exchange)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(data.price, format: .currency(code: "USD"))
                    .font(.body.bold())

                HStack(spacing: 4) {
                    Image(systemName: data.dayChangePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)

                    Text(data.dayChangePercent, format: .percent.precision(.fractionLength(2)))
                        .font(.caption)
                }
                .foregroundStyle(data.dayChangePercent >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
        .contentShape(Rectangle())
    }
}

struct MarketIndex: Identifiable {
    var id: String { symbol }
    var name: String
    var symbol: String
    var value: Double
    var change: Double
    var changePercent: Double

    var isPositive: Bool {
        changePercent >= 0
    }
}

#Preview {
    MarketOverviewView()
        .environment(AppModel())
}
