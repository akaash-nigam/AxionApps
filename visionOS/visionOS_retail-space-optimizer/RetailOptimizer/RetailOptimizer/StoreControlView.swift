import SwiftUI

struct StoreControlView: View {
    @State private var storeName = ""
    @State private var storeType: StoreType = .clothing
    @State private var showSpace = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Retail Space Optimizer")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Design Your Perfect Store in 3D")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Store Configuration")
                        .font(.title3)
                        .fontWeight(.semibold)

                    TextField("Store Name", text: $storeName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)

                    Picker("Store Type", selection: $storeType) {
                        ForEach(StoreType.allCases) { type in
                            HStack {
                                Text(type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)

                // Metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    MetricCard(icon: "chart.bar.fill", title: "Sales", value: "$24.5K", color: .green)
                    MetricCard(icon: "person.3.fill", title: "Customers", value: "342", color: .blue)
                    MetricCard(icon: "clock.fill", title: "Avg. Time", value: "12m", color: .orange)
                    MetricCard(icon: "cart.fill", title: "Conversion", value: "23%", color: .purple)
                    MetricCard(icon: "square.grid.2x2.fill", title: "Products", value: "156", color: .pink)
                    MetricCard(icon: "star.fill", title: "Rating", value: "4.8", color: .yellow)
                }
                .padding()

                Button(action: openRetailSpace) {
                    Label("Enter Store Designer", systemImage: "building.2.crop.circle")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(storeName.isEmpty)
            }
            .padding(60)
        }
    }

    func openRetailSpace() {
        Task {
            if showSpace {
                await dismissImmersiveSpace()
                showSpace = false
            } else {
                await openImmersiveSpace(id: "RetailSpace")
                showSpace = true
            }
        }
    }
}

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(10)
    }
}

enum StoreType: String, CaseIterable, Identifiable {
    case clothing = "Clothing"
    case electronics = "Electronics"
    case grocery = "Grocery"
    case furniture = "Furniture"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .clothing: return "👔"
        case .electronics: return "📱"
        case .grocery: return "🛒"
        case .furniture: return "🛋️"
        }
    }
}

#Preview {
    StoreControlView()
}
