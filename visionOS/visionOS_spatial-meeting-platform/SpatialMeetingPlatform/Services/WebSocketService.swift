//
//  WebSocketService.swift
//  SpatialMeetingPlatform
//
//  Real-time communication via WebSocket
//

import Foundation

class WebSocketService: NetworkServiceProtocol {

    // MARK: - Properties

    private var webSocket: URLSessionWebSocketTask?
    private var subscriptions: [String: [(Any) -> Void]] = [:]
    private var isConnected = false

    // MARK: - NetworkServiceProtocol

    func connect() async throws {
        let url = URL(string: "wss://api.example.com/realtime")!
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()

        isConnected = true
        print("WebSocket connected")

        // Start receiving messages
        receiveMessages()
    }

    func disconnect() async throws {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        isConnected = false

        print("WebSocket disconnected")
    }

    func send<T: Codable>(_ message: T) async throws {
        guard isConnected else {
            throw WebSocketError.notConnected
        }

        let data = try JSONEncoder().encode(message)
        guard let string = String(data: data, encoding: .utf8) else {
            throw WebSocketError.encodingFailed
        }

        try await webSocket?.send(.string(string))
        print("Sent message: \(String(describing: type(of: message)))")
    }

    func subscribe<T: Codable>(to channel: String, handler: @escaping (T) -> Void) {
        subscriptions[channel, default: []].append { message in
            if let typedMessage = message as? T {
                handler(typedMessage)
            }
        }

        print("Subscribed to channel: \(channel)")
    }

    func fetch<T: Codable>(_ request: T) async throws -> T {
        // In real implementation: Send request and wait for response
        print("Fetching: \(String(describing: type(of: request)))")
        return request // Placeholder
    }

    // MARK: - Private Methods

    private func receiveMessages() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessages() // Continue receiving

            case .failure(let error):
                print("WebSocket error: \(error)")
                self?.isConnected = false
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            print("Received message: \(text)")
            // In real implementation: Parse and route to appropriate subscription

        case .data:
            print("Received binary data")

        @unknown default:
            break
        }
    }
}

enum WebSocketError: LocalizedError {
    case notConnected
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected"
        case .encodingFailed:
            return "Failed to encode message"
        }
    }
}
