import Foundation
import Observation
import MultipeerConnectivity

@Observable
class NetworkManager: NSObject {
    var isConnected: Bool = false
    var connectedPlayers: [Player] = []
    var latency: TimeInterval = 0.0

    private var session: MCSession?
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?

    private let serviceType = "tactical-team"
    private let peerID: MCPeerID

    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        setupSession()
    }

    // MARK: - Session Setup

    private func setupSession() {
        let session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        self.session = session
    }

    // MARK: - Host Match

    func hostMatch() {
        guard let session = session else { return }

        serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        serviceAdvertiser?.delegate = self
        serviceAdvertiser?.startAdvertisingPeer()
    }

    // MARK: - Join Match

    func joinMatch() {
        guard let session = session else { return }

        serviceBrowser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: serviceType
        )
        serviceBrowser?.delegate = self
        serviceBrowser?.startBrowsingForPeers()
    }

    // MARK: - Disconnect

    func disconnect() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        session?.disconnect()

        isConnected = false
        connectedPlayers.removeAll()
    }

    // MARK: - Send Data

    func sendPlayerInput(_ input: PlayerInput) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(input)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send player input: \(error)")
        }
    }

    func sendGameState(_ state: GameStateSnapshot) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(state)
            try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("Failed to send game state: \(error)")
        }
    }

    // MARK: - Receive Data

    private func handleReceivedData(_ data: Data, from peer: MCPeerID) {
        // Try to decode as different message types
        if let input = try? JSONDecoder().decode(PlayerInput.self, from: data) {
            handlePlayerInput(input, from: peer)
        } else if let state = try? JSONDecoder().decode(GameStateSnapshot.self, from: data) {
            handleGameState(state)
        }
    }

    private func handlePlayerInput(_ input: PlayerInput, from peer: MCPeerID) {
        // Process player input
        NotificationCenter.default.post(
            name: .playerInputReceived,
            object: input,
            userInfo: ["peer": peer]
        )
    }

    private func handleGameState(_ state: GameStateSnapshot) {
        // Update local game state
        NotificationCenter.default.post(
            name: .gameStateReceived,
            object: state
        )
    }
}

// MARK: - MCSessionDelegate

extension NetworkManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .connected:
                print("Connected to: \(peerID.displayName)")
                self?.isConnected = true

            case .connecting:
                print("Connecting to: \(peerID.displayName)")

            case .notConnected:
                print("Disconnected from: \(peerID.displayName)")
                self?.isConnected = false

            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        handleReceivedData(data, from: peerID)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle streams if needed
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle resources if needed
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle resources if needed
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations (in production, show UI prompt)
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension NetworkManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Invite found peer
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
}

// MARK: - Network Messages

struct PlayerInput: Codable {
    let timestamp: TimeInterval
    let sequence: UInt32
    let position: CodableSimd3
    let rotation: CodableQuaternion
    let movement: CodableSimd2
    let actions: PlayerActions
}

struct PlayerActions: Codable {
    var isFiring: Bool = false
    var isReloading: Bool = false
    var isJumping: Bool = false
    var isCrouching: Bool = false
}

struct GameStateSnapshot: Codable {
    let timestamp: TimeInterval
    let sequence: UInt32
    let players: [PlayerState]
}

struct PlayerState: Codable {
    let id: UUID
    let position: CodableSimd3
    let rotation: CodableQuaternion
    let health: Float
    let isAlive: Bool
}

// MARK: - Codable SIMD Types

struct CodableSimd3: Codable {
    let x: Float
    let y: Float
    let z: Float

    init(_ simd: SIMD3<Float>) {
        self.x = simd.x
        self.y = simd.y
        self.z = simd.z
    }

    var simd3: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}

struct CodableSimd2: Codable {
    let x: Float
    let y: Float

    init(_ simd: SIMD2<Float>) {
        self.x = simd.x
        self.y = simd.y
    }

    var simd2: SIMD2<Float> {
        SIMD2<Float>(x, y)
    }
}

struct CodableQuaternion: Codable {
    let x: Float
    let y: Float
    let z: Float
    let w: Float

    init(_ quat: simd_quatf) {
        self.x = quat.vector.x
        self.y = quat.vector.y
        self.z = quat.vector.z
        self.w = quat.vector.w
    }

    var quaternion: simd_quatf {
        simd_quatf(vector: SIMD4<Float>(x, y, z, w))
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let playerInputReceived = Notification.Name("playerInputReceived")
    static let gameStateReceived = Notification.Name("gameStateReceived")
}
