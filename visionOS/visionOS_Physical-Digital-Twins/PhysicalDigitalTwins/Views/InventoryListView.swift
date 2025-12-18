//
//  InventoryListView.swift
//  PhysicalDigitalTwins
//
//  Inventory list with search and filter
//

import SwiftUI

struct InventoryListView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var selectedCategory: ObjectCategory?

    var filteredItems: [InventoryItem] {
        var items = appState.inventory.items

        // Filter by category
        if let category = selectedCategory {
            items = items.filter { $0.digitalTwin.objectType == category }
        }

        // Filter by search
        if !searchText.isEmpty {
            items = items.filter { item in
                item.digitalTwin.displayName.localizedCaseInsensitiveContains(searchText) ||
                (item.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return items
    }

    var body: some View {
        NavigationStack {
            Group {
                if appState.inventory.items.isEmpty {
                    // Empty inventory state
                    emptyInventoryView
                } else {
                    List {
                        if filteredItems.isEmpty {
                            ContentUnavailableView.search
                        } else {
                            ForEach(filteredItems) { item in
                                NavigationLink(value: item) {
                                    InventoryRow(item: item)
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: filteredItems.count)
                    .refreshable {
                        await appState.loadInventory()
                    }
                }
            }
            .navigationTitle("Inventory")
            .navigationDestination(for: InventoryItem.self) { item in
                ItemDetailView(item: item)
            }
            .searchable(text: $searchText, prompt: "Search inventory")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                        Button("All Items") {
                            selectedCategory = nil
                        }

                        Divider()

                        ForEach(ObjectCategory.allCases, id: \.self) { category in
                            Button(category.displayName) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyInventoryView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
                .symbolEffect(.bounce, value: appState.inventory.items.count)

            VStack(spacing: 12) {
                Text("No Items Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start building your inventory by scanning a barcode or adding items manually")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }
}

// MARK: - Inventory Row

struct InventoryRow: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: item.digitalTwin.objectType.iconName)
                .font(.title2)
                .foregroundStyle(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.2))
                .clipShape(Circle())

            // Item info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.digitalTwin.displayName)
                    .font(.headline)
                    .lineLimit(1)

                if let bookTwin = item.digitalTwin.asTwin() as BookTwin? {
                    Text("by \(bookTwin.author)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(item.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Price (if available)
            if let price = item.purchasePrice {
                Text(formatCurrency(price))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        switch item.digitalTwin.objectType {
        case .book: return .blue
        case .food: return .green
        case .furniture: return .brown
        case .electronics: return .purple
        case .clothing: return .pink
        case .games: return .red
        case .tools: return .orange
        case .plants: return .mint
        case .unknown: return .gray
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0"
    }
}

#Preview {
    InventoryListView()
        .environment(AppState(dependencies: AppDependencies()))
}
