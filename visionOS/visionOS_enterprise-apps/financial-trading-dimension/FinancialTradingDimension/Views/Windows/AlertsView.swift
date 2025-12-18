import SwiftUI

struct AlertsView: View {
    @State private var alerts: [TradingAlert] = []

    var body: some View {
        NavigationStack {
            Group {
                if alerts.isEmpty {
                    ContentUnavailableView {
                        Label("No Alerts", systemImage: "bell.slash")
                    } description: {
                        Text("You have no active alerts")
                    } actions: {
                        Button("Create Alert") {
                            // Create new alert
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(alerts) { alert in
                            AlertRow(alert: alert)
                        }
                        .onDelete { indexSet in
                            alerts.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Create new alert
                        createSampleAlert()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .glassBackgroundEffect()
        }
        .task {
            loadAlerts()
        }
    }

    private func loadAlerts() {
        alerts = [
            TradingAlert(
                symbol: "AAPL",
                type: .price,
                condition: "Above $200",
                triggered: false,
                createdDate: Date()
            ),
            TradingAlert(
                symbol: "GOOGL",
                type: .volume,
                condition: "Volume > 10M",
                triggered: false,
                createdDate: Date().addingTimeInterval(-86400)
            ),
            TradingAlert(
                symbol: "TSLA",
                type: .priceChange,
                condition: "Up 5%",
                triggered: true,
                createdDate: Date().addingTimeInterval(-3600)
            )
        ]
    }

    private func createSampleAlert() {
        let newAlert = TradingAlert(
            symbol: "NVDA",
            type: .price,
            condition: "Above $800",
            triggered: false,
            createdDate: Date()
        )
        alerts.insert(newAlert, at: 0)
    }
}

struct AlertRow: View {
    var alert: TradingAlert

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.symbol)
                        .font(.headline)

                    if alert.triggered {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }

                Text(alert.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(alert.condition)
                    .font(.body)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(alert.createdDate, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if alert.triggered {
                    Text("Triggered")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TradingAlert: Identifiable {
    var id = UUID()
    var symbol: String
    var type: AlertType
    var condition: String
    var triggered: Bool
    var createdDate: Date

    enum AlertType {
        case price
        case volume
        case priceChange
        case technical

        var displayName: String {
            switch self {
            case .price: return "Price Alert"
            case .volume: return "Volume Alert"
            case .priceChange: return "Price Change"
            case .technical: return "Technical Indicator"
            }
        }
    }
}

#Preview {
    AlertsView()
}
