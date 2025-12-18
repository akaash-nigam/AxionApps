import Foundation
import Observation

struct OrderConfirmation {
    var orderId: UUID
    var status: String
    var message: String
    var timestamp: Date
}

protocol TradingService {
    func submitOrder(_ order: Order) async throws -> OrderConfirmation
    func cancelOrder(orderId: UUID) async throws
    func getOrderStatus(orderId: UUID) async throws -> String
    func getOpenOrders() async throws -> [Order]
}

@Observable
class MockTradingService: TradingService {
    private var orders: [UUID: Order] = [:]

    func submitOrder(_ order: Order) async throws -> OrderConfirmation {
        // Simulate order processing delay
        try await Task.sleep(for: .milliseconds(50))

        // Store the order
        orders[order.id] = order

        // Simulate order execution
        Task {
            try? await Task.sleep(for: .milliseconds(500))

            // Update order status to filled
            if var updatedOrder = orders[order.id] {
                updatedOrder.status = "Filled"
                updatedOrder.filledQuantity = updatedOrder.quantity
                updatedOrder.averageFillPrice = updatedOrder.orderType == "Market"
                    ? nil
                    : updatedOrder.limitPrice
                updatedOrder.filledTime = Date()
                orders[order.id] = updatedOrder
            }
        }

        return OrderConfirmation(
            orderId: order.id,
            status: "Accepted",
            message: "Order submitted successfully",
            timestamp: Date()
        )
    }

    func cancelOrder(orderId: UUID) async throws {
        try await Task.sleep(for: .milliseconds(20))

        guard var order = orders[orderId] else {
            throw TradingError.orderNotFound
        }

        if order.status == "Pending" {
            order.status = "Cancelled"
            orders[orderId] = order
        } else {
            throw TradingError.cannotCancelOrder
        }
    }

    func getOrderStatus(orderId: UUID) async throws -> String {
        try await Task.sleep(for: .milliseconds(10))

        guard let order = orders[orderId] else {
            throw TradingError.orderNotFound
        }

        return order.status
    }

    func getOpenOrders() async throws -> [Order] {
        try await Task.sleep(for: .milliseconds(20))

        return orders.values.filter { order in
            order.status == "Pending" || order.status == "Accepted"
        }
    }
}

enum TradingError: Error {
    case orderNotFound
    case cannotCancelOrder
    case insufficientFunds
    case invalidQuantity
    case invalidPrice
    case marketClosed
}
