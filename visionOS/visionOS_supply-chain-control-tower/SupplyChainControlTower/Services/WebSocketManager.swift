//
//  WebSocketManager.swift
//  SupplyChainControlTower
//
//  Real-time WebSocket updates manager
//

import Foundation
import Observation

/// Manages WebSocket connection for real-time updates
@Observable
@MainActor
class WebSocketManager: NSObject {

    // MARK: - Properties

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var isConnecting = false

    /// Connection state
    var connectionState: ConnectionState = .disconnected

    /// Received updates
    var receivedUpdates: [RealtimeUpdate] = []

    /// Connection error
    var lastError: Error?

    /// Reconnect attempts
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5

    /// Update handlers
    private var updateHandlers: [(RealtimeUpdate) -> Void] = []

    // MARK: - Connection State

    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case reconnecting
        case failed(Error)

        var isConnected: Bool {
            if case .connected = self {
                return true
            }
            return false
        }

        static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected, .disconnected),
                 (.connecting, .connecting),
                 (.connected, .connected),
                 (.reconnecting, .reconnecting):
                return true
            case (.failed, .failed):
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Initialization

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    // MARK: - Public Methods

    /// Connect to WebSocket
    func connect() async {
        guard !isConnecting, connectionState != .connected else { return }

        isConnecting = true
        connectionState = .connecting

        AppConfiguration.Logger.info("WebSocket: Connecting...")

        let url = buildWebSocketURL()
        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()

        connectionState = .connected
        isConnecting = false
        reconnectAttempts = 0

        AppConfiguration.Logger.info("WebSocket: Connected")

        // Start receiving messages
        await receiveMessage()
    }

    /// Disconnect from WebSocket
    func disconnect() {
        AppConfiguration.Logger.info("WebSocket: Disconnecting...")

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
        reconnectAttempts = 0

        AppConfiguration.Logger.info("WebSocket: Disconnected")
    }

    /// Send a message
    func send(_ message: OutgoingMessage) async throws {
        guard connectionState.isConnected else {
            throw WebSocketError.notConnected
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(message)
        let string = String(data: data, encoding: .utf8)!

        try await webSocketTask?.send(.string(string))

        AppConfiguration.Logger.debug("WebSocket: Sent message - \(message.type)")
    }

    /// Register update handler
    func onUpdate(_ handler: @escaping (RealtimeUpdate) -> Void) {
        updateHandlers.append(handler)
    }

    // MARK: - Private Methods

    private func buildWebSocketURL() -> URL {
        var url = AppConfiguration.current.websocketURL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        // Add authentication token
        components.queryItems = [
            URLQueryItem(name: "token", value: AppConfiguration.current.apiKey),
            URLQueryItem(name: "client", value: "visionOS"),
            URLQueryItem(name: "version", value: AppConfiguration.API.version)
        ]

        return components.url!
    }

    private func receiveMessage() async {
        guard let webSocketTask else { return }

        do {
            let message = try await webSocketTask.receive()
            await handleMessage(message)

            // Continue receiving
            await receiveMessage()
        } catch {
            await handleError(error)
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case .string(let text):
            await parseUpdate(from: text)
        case .data(let data):
            await parseUpdate(from: data)
        @unknown default:
            AppConfiguration.Logger.warning("WebSocket: Unknown message type received")
        }
    }

    private func parseUpdate(from text: String) async {
        guard let data = text.data(using: .utf8) else { return }
        await parseUpdate(from: data)
    }

    private func parseUpdate(from data: Data) async {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let update = try decoder.decode(RealtimeUpdate.self, from: data)

            AppConfiguration.Logger.debug("WebSocket: Received update - \(update.type)")

            // Store update
            receivedUpdates.append(update)

            // Notify handlers
            for handler in updateHandlers {
                handler(update)
            }
        } catch {
            AppConfiguration.Logger.error("WebSocket: Failed to decode update - \(error)")
        }
    }

    private func handleError(_ error: Error) async {
        AppConfiguration.Logger.error("WebSocket: Error - \(error.localizedDescription)")

        lastError = error
        connectionState = .failed(error)

        // Attempt reconnect
        await attemptReconnect()
    }

    private func attemptReconnect() async {
        guard reconnectAttempts < maxReconnectAttempts else {
            AppConfiguration.Logger.error("WebSocket: Max reconnect attempts reached")
            return
        }

        reconnectAttempts += 1
        connectionState = .reconnecting

        let delay = min(Double(reconnectAttempts * 2), 30.0) // Max 30 seconds
        AppConfiguration.Logger.info("WebSocket: Reconnecting in \(delay)s (attempt \(reconnectAttempts)/\(maxReconnectAttempts))...")

        try? await Task.sleep(for: .seconds(delay))

        await connect()
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketManager: URLSessionWebSocketDelegate {

    nonisolated func urlSession(_ session: URLSession,
                                webSocketTask: URLSessionWebSocketTask,
                                didOpenWithProtocol protocol: String?) {
        Task { @MainActor in
            AppConfiguration.Logger.info("WebSocket: Connection opened")
            connectionState = .connected
        }
    }

    nonisolated func urlSession(_ session: URLSession,
                                webSocketTask: URLSessionWebSocketTask,
                                didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                                reason: Data?) {
        Task { @MainActor in
            AppConfiguration.Logger.info("WebSocket: Connection closed - \(closeCode)")
            connectionState = .disconnected

            // Attempt reconnect if not intentional disconnect
            if closeCode != .goingAway {
                await attemptReconnect()
            }
        }
    }
}

// MARK: - Realtime Update

struct RealtimeUpdate: Codable, Identifiable {
    let id: String
    let type: UpdateType
    let timestamp: Date
    let payload: UpdatePayload

    enum UpdateType: String, Codable {
        case shipmentUpdate = "shipment_update"
        case disruptionAlert = "disruption_alert"
        case nodeStatusChange = "node_status_change"
        case networkUpdate = "network_update"
        case inventoryChange = "inventory_change"
        case routeChange = "route_change"
    }

    struct UpdatePayload: Codable {
        // Shipment update
        var shipmentId: String?
        var status: String?
        var currentNode: String?
        var progress: Double?
        var eta: Date?

        // Disruption alert
        var disruptionId: String?
        var severity: String?
        var affectedNodes: [String]?
        var description: String?

        // Node status
        var nodeId: String?
        var nodeStatus: String?

        // Inventory change
        var sku: String?
        var quantity: Int?
        var location: String?
    }
}

// MARK: - Outgoing Message

struct OutgoingMessage: Codable {
    let type: MessageType
    let payload: [String: String]

    enum MessageType: String, Codable {
        case subscribe
        case unsubscribe
        case ping
        case updatePreferences
    }

    static func subscribe(to channel: String) -> OutgoingMessage {
        OutgoingMessage(type: .subscribe, payload: ["channel": channel])
    }

    static func unsubscribe(from channel: String) -> OutgoingMessage {
        OutgoingMessage(type: .unsubscribe, payload: ["channel": channel])
    }

    static var ping: OutgoingMessage {
        OutgoingMessage(type: .ping, payload: [:])
    }
}

// MARK: - WebSocket Error

enum WebSocketError: LocalizedError {
    case notConnected
    case connectionFailed
    case sendFailed
    case receiveFailed

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected"
        case .connectionFailed:
            return "Failed to establish WebSocket connection"
        case .sendFailed:
            return "Failed to send WebSocket message"
        case .receiveFailed:
            return "Failed to receive WebSocket message"
        }
    }
}
