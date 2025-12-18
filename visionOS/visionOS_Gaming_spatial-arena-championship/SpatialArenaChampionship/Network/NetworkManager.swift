//
//  NetworkManager.swift
//  Spatial Arena Championship
//
//  Multiplayer network manager
//

import Foundation
import MultipeerConnectivity
import Observation

// MARK: - Network Manager

@Observable
@MainActor
class NetworkManager: NSObject {
    // MARK: - Properties

    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    private let serviceType = GameConstants.Network.serviceType
    private let localPeerID: MCPeerID

    var connectionState: ConnectionState = .disconnected
    var connectedPeers: [MCPeerID] = []
    var latency: TimeInterval = 0
    var isHost: Bool = false

    // Message handling
    private var messageHandlers: [MessageType: (Data, MCPeerID) -> Void] = [:]
    private var reliableMessageQueue: [QueuedMessage] = []

    // Network stats
    private var bytesSent: Int = 0
    private var bytesReceived: Int = 0
    private var messagesSent: Int = 0
    private var messagesReceived: Int = 0

    override init() {
        // Create unique peer ID
        let deviceName = "Player_\(Int.random(in: 1000...9999))"
        self.localPeerID = MCPeerID(displayName: deviceName)

        super.init()
    }

    // MARK: - Host Match

    func hostMatch(maxPlayers: Int = 10) throws {
        guard connectionState == .disconnected else {
            throw NetworkError.alreadyConnected
        }

        // Create session
        session = MCSession(
            peer: localPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session?.delegate = self

        // Start advertising
        advertiser = MCNearbyServiceAdvertiser(
            peer: localPeerID,
            discoveryInfo: ["maxPlayers": "\(maxPlayers)"],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

        isHost = true
        connectionState = .hosting
    }

    // MARK: - Join Match

    func joinMatch() throws {
        guard connectionState == .disconnected else {
            throw NetworkError.alreadyConnected
        }

        // Create session
        session = MCSession(
            peer: localPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session?.delegate = self

        // Start browsing
        browser = MCNearbyServiceBrowser(
            peer: localPeerID,
            serviceType: serviceType
        )
        browser?.delegate = self
        browser?.startBrowsingForPeers()

        isHost = false
        connectionState = .browsing
    }

    // MARK: - Disconnect

    func disconnect() {
        session?.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()

        session = nil
        advertiser = nil
        browser = nil

        connectedPeers.removeAll()
        connectionState = .disconnected
        isHost = false
    }

    // MARK: - Send Messages

    func sendReliable(_ message: NetworkMessage, to peers: [MCPeerID]? = nil) throws {
        let data = try message.encode()
        let targetPeers = peers ?? connectedPeers

        guard !targetPeers.isEmpty else { return }

        try session?.send(
            data,
            toPeers: targetPeers,
            with: .reliable
        )

        bytesSent += data.count
        messagesSent += 1
    }

    func sendUnreliable(_ message: NetworkMessage, to peers: [MCPeerID]? = nil) throws {
        let data = try message.encode()
        let targetPeers = peers ?? connectedPeers

        guard !targetPeers.isEmpty else { return }

        try session?.send(
            data,
            toPeers: targetPeers,
            with: .unreliable
        )

        bytesSent += data.count
        messagesSent += 1
    }

    // MARK: - Message Handlers

    func registerHandler(for type: MessageType, handler: @escaping (Data, MCPeerID) -> Void) {
        messageHandlers[type] = handler
    }

    private func handleReceivedMessage(_ data: Data, from peer: MCPeerID) {
        bytesReceived += data.count
        messagesReceived += 1

        do {
            let message = try NetworkMessage.decode(data)

            if let handler = messageHandlers[message.type] {
                handler(message.payload, peer)
            }
        } catch {
            print("Failed to decode network message: \(error)")
        }
    }

    // MARK: - Network Stats

    func getNetworkStats() -> NetworkStats {
        NetworkStats(
            bytesSent: bytesSent,
            bytesReceived: bytesReceived,
            messagesSent: messagesSent,
            messagesReceived: messagesReceived,
            latency: latency,
            connectedPeers: connectedPeers.count
        )
    }

    func resetStats() {
        bytesSent = 0
        bytesReceived = 0
        messagesSent = 0
        messagesReceived = 0
    }
}

// MARK: - MCSessionDelegate

extension NetworkManager: MCSessionDelegate {
    nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        Task { @MainActor in
            switch state {
            case .connected:
                if !connectedPeers.contains(peerID) {
                    connectedPeers.append(peerID)
                }
                connectionState = .connected

            case .connecting:
                connectionState = .connecting

            case .notConnected:
                connectedPeers.removeAll { $0 == peerID }
                if connectedPeers.isEmpty {
                    connectionState = isHost ? .hosting : .browsing
                }

            @unknown default:
                break
            }
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            handleReceivedMessage(data, from: peerID)
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // Not used
    }

    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // Not used
    }

    nonisolated func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // Not used
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // Auto-accept if hosting
        Task { @MainActor in
            if isHost, let session = session {
                invitationHandler(true, session)
            }
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension NetworkManager: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        // Auto-invite when found
        Task { @MainActor in
            if let session = session {
                browser.invitePeer(
                    peerID,
                    to: session,
                    withContext: nil,
                    timeout: GameConstants.Network.timeoutDuration
                )
            }
        }
    }

    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        // Peer left range
    }
}

// MARK: - Network Message

struct NetworkMessage: Codable {
    let type: MessageType
    let timestamp: TimeInterval
    let payload: Data

    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }

    static func decode(_ data: Data) throws -> NetworkMessage {
        try JSONDecoder().decode(NetworkMessage.self, from: data)
    }
}

// MARK: - Message Types

enum MessageType: String, Codable {
    case playerJoined
    case playerLeft
    case playerInput
    case playerState
    case worldState
    case matchStart
    case matchEnd
    case abilityActivated
    case damageDealt
    case objectiveCaptured
    case chatMessage
}

// MARK: - Connection State

enum ConnectionState {
    case disconnected
    case browsing
    case hosting
    case connecting
    case connected
}

// MARK: - Network Error

enum NetworkError: Error {
    case alreadyConnected
    case notConnected
    case encodingFailed
    case decodingFailed
    case sendFailed
}

// MARK: - Network Stats

struct NetworkStats {
    let bytesSent: Int
    let bytesReceived: Int
    let messagesSent: Int
    let messagesReceived: Int
    let latency: TimeInterval
    let connectedPeers: Int

    var bandwidthUp: String {
        formatBytes(bytesSent)
    }

    var bandwidthDown: String {
        formatBytes(bytesReceived)
    }

    private func formatBytes(_ bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024.0 * 1024.0))
        }
    }
}

// MARK: - Queued Message

private struct QueuedMessage {
    let message: NetworkMessage
    let peers: [MCPeerID]
    let timestamp: TimeInterval
}
