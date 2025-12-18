import SwiftUI

struct TradingExecutionView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSymbol: String = "AAPL"
    @State private var orderType: OrderType = .market
    @State private var side: OrderSide = .buy
    @State private var quantity: String = "100"
    @State private var limitPrice: String = ""
    @State private var stopPrice: String = ""

    @State private var currentQuote: MarketData?
    @State private var showingConfirmation = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                // Symbol Selection
                Section("Symbol") {
                    Picker("Select Symbol", selection: $selectedSymbol) {
                        ForEach(appModel.activeMarketSymbols, id: \.self) { symbol in
                            Text(symbol).tag(symbol)
                        }
                    }
                    .pickerStyle(.menu)

                    if let quote = currentQuote {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Current Price:")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(quote.price, format: .currency(code: "USD"))
                                    .bold()
                            }

                            HStack {
                                Text("Bid:")
                                    .foregroundStyle(.secondary)
                                Text(quote.bidPrice, format: .currency(code: "USD"))
                                Spacer()
                                Text("Ask:")
                                    .foregroundStyle(.secondary)
                                Text(quote.askPrice, format: .currency(code: "USD"))
                            }
                            .font(.caption)
                        }
                    }
                }

                // Order Type
                Section("Order Type") {
                    Picker("Type", selection: $orderType) {
                        Text("Market").tag(OrderType.market)
                        Text("Limit").tag(OrderType.limit)
                        Text("Stop").tag(OrderType.stop)
                    }
                    .pickerStyle(.segmented)

                    if orderType == .limit {
                        TextField("Limit Price", text: $limitPrice)
                            .keyboardType(.decimalPad)
                    }

                    if orderType == .stop {
                        TextField("Stop Price", text: $stopPrice)
                            .keyboardType(.decimalPad)
                    }
                }

                // Quantity
                Section("Quantity") {
                    HStack {
                        TextField("Shares", text: $quantity)
                            .keyboardType(.numberPad)

                        Stepper("", value: Binding(
                            get: { Int(quantity) ?? 0 },
                            set: { quantity = String($0) }
                        ), in: 0...10000, step: 10)
                    }
                }

                // Side (Buy/Sell)
                Section("Side") {
                    Picker("Side", selection: $side) {
                        Text("Buy").tag(OrderSide.buy)
                        Text("Sell").tag(OrderSide.sell)
                    }
                    .pickerStyle(.segmented)
                }

                // Order Summary
                Section("Order Summary") {
                    if let quote = currentQuote, let qty = Int(quantity) {
                        let estimatedPrice = orderType == .limit && !limitPrice.isEmpty
                            ? Decimal(string: limitPrice) ?? quote.price
                            : quote.price
                        let estimatedCost = estimatedPrice * Decimal(qty)

                        HStack {
                            Text("Estimated Cost:")
                            Spacer()
                            Text(estimatedCost, format: .currency(code: "USD"))
                                .bold()
                        }

                        HStack {
                            Text("Commission:")
                            Spacer()
                            Text("$0.00")
                        }
                        .foregroundStyle(.secondary)

                        Divider()

                        HStack {
                            Text("Total:")
                            Spacer()
                            Text(estimatedCost, format: .currency(code: "USD"))
                                .font(.headline.bold())
                        }
                    }
                }
            }
            .navigationTitle("Trade Execution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Review Order") {
                        showingConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidOrder)
                }
            }
            .glassBackgroundEffect()
            .alert("Confirm Order", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button(side == .buy ? "Buy" : "Sell", role: side == .buy ? nil : .destructive) {
                    Task {
                        await submitOrder()
                    }
                }
            } message: {
                Text(orderSummaryText)
            }
            .alert("Order Submitted", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your order has been submitted successfully")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .task {
                await loadQuote()
            }
            .onChange(of: selectedSymbol) {
                Task {
                    await loadQuote()
                }
            }
        }
    }

    private var isValidOrder: Bool {
        guard Int(quantity) ?? 0 > 0 else { return false }

        if orderType == .limit {
            guard !limitPrice.isEmpty, Decimal(string: limitPrice) != nil else { return false }
        }

        if orderType == .stop {
            guard !stopPrice.isEmpty, Decimal(string: stopPrice) != nil else { return false }
        }

        return true
    }

    private var orderSummaryText: String {
        let action = side == .buy ? "Buy" : "Sell"
        let type = orderType.rawValue.capitalized
        var summary = "\(action) \(quantity) shares of \(selectedSymbol) at \(type) price"

        if orderType == .limit, !limitPrice.isEmpty {
            summary += " of $\(limitPrice)"
        }

        return summary
    }

    private func loadQuote() async {
        do {
            currentQuote = try await appModel.marketDataService.getQuote(symbol: selectedSymbol)
        } catch {
            errorMessage = "Failed to load quote: \(error.localizedDescription)"
        }
    }

    private func submitOrder() async {
        guard let qty = Int(quantity) else { return }

        let order = Order(
            symbol: selectedSymbol,
            orderType: orderType.rawValue,
            side: side.rawValue,
            quantity: Decimal(qty),
            limitPrice: orderType == .limit ? Decimal(string: limitPrice) : nil,
            stopPrice: orderType == .stop ? Decimal(string: stopPrice) : nil
        )

        do {
            let confirmation = try await appModel.tradingService.submitOrder(order)
            print("Order submitted: \(confirmation.orderId)")
            showingSuccess = true
        } catch {
            errorMessage = "Failed to submit order: \(error.localizedDescription)"
        }
    }
}

enum OrderType: String, CaseIterable {
    case market = "Market"
    case limit = "Limit"
    case stop = "Stop"
}

enum OrderSide: String, CaseIterable {
    case buy = "Buy"
    case sell = "Sell"
}

#Preview {
    TradingExecutionView()
        .environment(AppModel())
}
