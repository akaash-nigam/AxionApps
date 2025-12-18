# Multiplayer Networking Guide - Tactical Team Shooters

Comprehensive guide to the multiplayer networking architecture for Tactical Team Shooters.

## Overview

Tactical Team Shooters uses a **client-server architecture** with **client-side prediction** and **server reconciliation** to provide responsive, low-latency gameplay for competitive 5v5 matches.

## Architecture

### Network Model

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Client 1   │◄───────►│    Server    │◄───────►│  Client 2   │
│ (Vision Pro)│         │ (Authoritative)│        │ (Vision Pro)│
└─────────────┘         └──────────────┘         └─────────────┘
       │                        │                        │
       │     Player Input       │     Player Input       │
       ├───────────────────────►│◄───────────────────────┤
       │                        │                        │
       │   Game State Update    │   Game State Update    │
       │◄───────────────────────┤───────────────────────►│
```

### Key Principles

1. **Server Authority**: Server has final say on all game state
2. **Client Prediction**: Clients predict their own actions for responsiveness
3. **Server Reconciliation**: Clients correct predictions based on server updates
4. **Lag Compensation**: Server rewinds time for hit detection
5. **Delta Compression**: Send only changed data to minimize bandwidth

## Network Stack

### Transport Layer

**MultipeerConnectivity Framework**:
- Automatic peer discovery
- Reliable and unreliable channels
- Built-in encryption
- NAT traversal

```swift
import MultipeerConnectivity

class NetworkManager: NSObject, ObservableObject {
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    func startHosting() {
        let peerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerId)
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerId,
            discoveryInfo: ["game": "TacticalTeamShooters"],
            serviceType: "tts-game"
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func joinGame() {
        let peerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerId)
        browser = MCNearbyServiceBrowser(
            peer: peerId,
            serviceType: "tts-game"
        )
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
}
```

### Message Types

#### Reliable Messages (TCP-like)
- Player join/leave
- Match start/end
- Round results
- Chat messages
- Equipment purchases

#### Unreliable Messages (UDP-like)
- Player movement
- Player rotation
- Shooting actions
- Projectile positions
- Animation states

## Client-Side Prediction

### Input Handling

Clients send inputs to server but also apply them immediately:

```swift
struct PlayerInput: Codable {
    let timestamp: TimeInterval       // Client timestamp
    let sequence: UInt32              // Input sequence number
    let position: SIMD3<Float>        // Predicted position
    let rotation: simd_quatf          // Predicted rotation
    let velocity: SIMD3<Float>        // Movement velocity
    let actions: PlayerActions        // Button presses
}

func handleInput(_ input: PlayerInput) {
    // 1. Apply input locally (prediction)
    applyInputLocally(input)

    // 2. Send to server
    networkManager.send(input)

    // 3. Store for reconciliation
    pendingInputs.append(input)
}
```

### Movement Prediction

```swift
func predictMovement(input: PlayerInput, deltaTime: TimeInterval) -> SIMD3<Float> {
    var newPosition = input.position

    // Apply velocity
    newPosition += input.velocity * Float(deltaTime)

    // Apply gravity
    newPosition.y -= PhysicsConstants.gravity * Float(deltaTime)

    // Collision detection
    newPosition = resolveCollisions(newPosition)

    return newPosition
}
```

## Server Reconciliation

### Server Update

Server sends authoritative state updates:

```swift
struct GameStateSnapshot: Codable {
    let timestamp: TimeInterval
    let lastProcessedInput: UInt32    // Last input server processed
    let players: [PlayerState]
    let projectiles: [ProjectileState]
    let events: [GameEvent]
}

struct PlayerState: Codable {
    let playerId: UUID
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let health: Double
    let isAlive: Bool
}
```

### Client Reconciliation

Client corrects prediction errors:

```swift
func reconcileWithServer(_ snapshot: GameStateSnapshot) {
    // 1. Find our player state from server
    guard let serverState = snapshot.players.first(where: { $0.playerId == localPlayerId }) else {
        return
    }

    // 2. Remove acknowledged inputs
    pendingInputs.removeAll { $0.sequence <= snapshot.lastProcessedInput }

    // 3. Check for prediction error
    let positionError = distance(localPlayer.position, serverState.position)

    if positionError > reconciliationThreshold {
        // 4. Reset to server position
        localPlayer.position = serverState.position
        localPlayer.rotation = serverState.rotation

        // 5. Re-apply pending inputs
        for input in pendingInputs {
            applyInputLocally(input)
        }
    }

    // 6. Update authoritative values
    localPlayer.health = serverState.health
    localPlayer.isAlive = serverState.isAlive
}
```

### Reconciliation Threshold

```swift
let reconciliationThreshold: Float = 0.5  // 0.5 meters
```

Small errors are ignored to avoid jitter.

## Lag Compensation

### Server-Side Rewind

Server rewinds player positions for hit detection:

```swift
struct PlayerSnapshot {
    let timestamp: TimeInterval
    let position: SIMD3<Float>
    let rotation: simd_quatf
}

class LagCompensationSystem {
    private var playerHistory: [UUID: [PlayerSnapshot]] = [:]
    private let historyDuration: TimeInterval = 1.0  // Keep 1 second

    func recordSnapshot(_ player: Player) {
        let snapshot = PlayerSnapshot(
            timestamp: CACurrentMediaTime(),
            position: player.position,
            rotation: player.rotation
        )

        playerHistory[player.id, default: []].append(snapshot)

        // Clean old snapshots
        cleanHistory()
    }

    func rewindTo(timestamp: TimeInterval) -> [UUID: PlayerSnapshot] {
        var rewoundPlayers: [UUID: PlayerSnapshot] = [:]

        for (playerId, history) in playerHistory {
            // Find closest snapshot to timestamp
            if let snapshot = history.last(where: { $0.timestamp <= timestamp }) {
                rewoundPlayers[playerId] = snapshot
            }
        }

        return rewoundPlayers
    }
}
```

### Hit Detection with Lag Compensation

```swift
func processShot(from shooter: Player, input: PlayerInput) {
    // 1. Calculate ping/RTT
    let ping = networkManager.latency

    // 2. Rewind to shooter's perceived time
    let rewindTime = CACurrentMediaTime() - ping
    let rewoundPlayers = lagCompensation.rewindTo(timestamp: rewindTime)

    // 3. Perform raycast with rewound positions
    let ray = createRay(from: input.position, direction: input.rotation)

    for (targetId, snapshot) in rewoundPlayers {
        if rayIntersects(ray, player: snapshot) {
            // Hit confirmed!
            applyDamage(to: targetId, from: shooter)
        }
    }
}
```

## Bandwidth Optimization

### Delta Compression

Only send changed values:

```swift
struct PlayerStateDelta: Codable {
    let playerId: UUID
    var position: SIMD3<Float>?
    var rotation: simd_quatf?
    var health: Double?
    var isAlive: Bool?
}

func createDelta(previous: PlayerState, current: PlayerState) -> PlayerStateDelta {
    var delta = PlayerStateDelta(playerId: current.playerId)

    if distance(previous.position, current.position) > 0.01 {
        delta.position = current.position
    }

    if previous.health != current.health {
        delta.health = current.health
    }

    // ... other fields

    return delta
}
```

### Interest Management

Only send relevant updates to each client:

```swift
func getRelevantPlayers(for client: Player, maxDistance: Float = 50.0) -> [Player] {
    allPlayers.filter { other in
        guard other.id != client.id else { return false }
        return distance(client.position, other.position) < maxDistance
    }
}

func sendGameStateUpdate(to client: Player) {
    let relevantPlayers = getRelevantPlayers(for: client)
    let snapshot = GameStateSnapshot(
        timestamp: CACurrentMediaTime(),
        lastProcessedInput: lastProcessedInputs[client.id] ?? 0,
        players: relevantPlayers.map { createPlayerState($0) },
        projectiles: getRelevantProjectiles(for: client),
        events: pendingEvents[client.id] ?? []
    )

    networkManager.send(snapshot, to: client)
}
```

### Update Frequency

```swift
enum NetworkConstants {
    static let clientInputRate: Double = 60.0  // 60 Hz
    static let serverUpdateRate: Double = 20.0  // 20 Hz
    static let snapshotHistoryDuration: TimeInterval = 1.0
}
```

## Synchronization

### Time Synchronization

Sync clocks between client and server:

```swift
class TimeSyncManager {
    private var serverTimeOffset: TimeInterval = 0

    func synchronize() async {
        let t0 = CACurrentMediaTime()

        // Send ping
        let serverTime = try await networkManager.requestServerTime()

        let t1 = CACurrentMediaTime()
        let rtt = t1 - t0

        // Estimate server time offset
        serverTimeOffset = serverTime - t0 - (rtt / 2)
    }

    func getServerTime() -> TimeInterval {
        CACurrentMediaTime() + serverTimeOffset
    }
}
```

### Round Synchronization

Ensure all clients start round simultaneously:

```swift
struct RoundStartMessage: Codable {
    let roundNumber: Int
    let startTimestamp: TimeInterval
    let countdown: TimeInterval
}

func startRound() {
    let startTime = timeSyncManager.getServerTime() + 3.0  // 3 second countdown

    let message = RoundStartMessage(
        roundNumber: currentRound,
        startTimestamp: startTime,
        countdown: 3.0
    )

    // Send to all clients
    networkManager.broadcast(message)
}
```

## State Management

### Authoritative Server State

Server maintains authoritative game state:

```swift
actor GameServerState {
    private var players: [UUID: Player] = [:]
    private var projectiles: [Projectile] = []
    private var match: Match?

    func update(deltaTime: TimeInterval) {
        // Process pending inputs
        processPendingInputs()

        // Update physics
        updatePhysics(deltaTime)

        // Check win conditions
        checkWinConditions()

        // Send state updates to clients
        sendStateUpdates()
    }

    func processPendingInputs() {
        for input in pendingInputs {
            applyInput(input)
        }
        pendingInputs.removeAll()
    }
}
```

## Error Handling

### Disconnection Handling

```swift
func handlePlayerDisconnect(_ playerId: UUID) {
    // 1. Mark player as disconnected
    if var player = players[playerId] {
        player.connectionState = .disconnected

        // 2. Grace period for reconnection
        Task {
            try await Task.sleep(nanoseconds: 30 * 1_000_000_000)  // 30 seconds

            if player.connectionState == .disconnected {
                // Remove from match
                removePlayer(playerId)

                // Notify other players
                broadcastPlayerLeft(playerId)
            }
        }
    }
}
```

### Timeout Detection

```swift
func monitorConnection() {
    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
        for (playerId, player) in self.players {
            let timeSinceLastMessage = CACurrentMediaTime() - player.lastMessageTime

            if timeSinceLastMessage > 10.0 {
                self.handlePlayerDisconnect(playerId)
            }
        }
    }
}
```

### Packet Loss Handling

```swift
struct ReliableMessage {
    let id: UInt32
    let data: Data
    var attempts: Int = 0
    var lastSentTime: TimeInterval = 0
}

class ReliableDeliverySystem {
    private var pendingMessages: [UInt32: ReliableMessage] = [:]
    private var nextMessageId: UInt32 = 0

    func sendReliable(_ data: Data) {
        let message = ReliableMessage(
            id: nextMessageId,
            data: data,
            lastSentTime: CACurrentMediaTime()
        )

        pendingMessages[nextMessageId] = message
        nextMessageId += 1

        send(message)
    }

    func handleAck(_ messageId: UInt32) {
        pendingMessages.removeValue(forKey: messageId)
    }

    func resendUnacknowledged() {
        let now = CACurrentMediaTime()

        for (id, var message) in pendingMessages {
            if now - message.lastSentTime > 0.5 {  // 500ms timeout
                message.attempts += 1
                message.lastSentTime = now

                if message.attempts < 5 {
                    send(message)
                    pendingMessages[id] = message
                } else {
                    // Give up, connection lost
                    handleConnectionLost()
                }
            }
        }
    }
}
```

## Security

### Input Validation

```swift
func validateInput(_ input: PlayerInput) -> Bool {
    // Check sequence number
    guard input.sequence > lastProcessedSequence else {
        return false  // Old/duplicate input
    }

    // Check movement speed
    let maxSpeed: Float = 10.0  // m/s
    let speed = length(input.velocity)

    guard speed <= maxSpeed else {
        return false  // Speed hack attempt
    }

    // Check position validity
    guard isPositionValid(input.position) else {
        return false  // Teleport hack attempt
    }

    return true
}
```

### Anti-Cheat

```swift
class AntiCheatSystem {
    func checkForCheating(_ player: Player, input: PlayerInput) -> Bool {
        // Check impossible movements
        if detectTeleportation(player, input) {
            return true
        }

        // Check aim assistance patterns
        if detectAimbot(player, input) {
            return true
        }

        // Check fire rate
        if detectRapidFire(player) {
            return true
        }

        return false
    }
}
```

## Performance Monitoring

### Network Metrics

```swift
struct NetworkMetrics {
    var latency: TimeInterval           // Round-trip time
    var jitter: TimeInterval            // Latency variance
    var packetLoss: Double              // % packets lost
    var bandwidth: Double               // Bytes/second
}

class NetworkMonitor {
    func measureLatency() async -> TimeInterval {
        let start = CACurrentMediaTime()
        try? await networkManager.ping()
        return CACurrentMediaTime() - start
    }

    func calculateJitter() -> TimeInterval {
        let latencies = recentLatencies.suffix(10)
        let average = latencies.reduce(0, +) / Double(latencies.count)
        let variance = latencies.map { pow($0 - average, 2) }.reduce(0, +) / Double(latencies.count)
        return sqrt(variance)
    }
}
```

## Testing

### Network Simulation

```swift
class NetworkSimulator {
    var simulatedLatency: TimeInterval = 0.05  // 50ms
    var simulatedPacketLoss: Double = 0.01     // 1%

    func send(_ data: Data) {
        // Simulate packet loss
        if Double.random(in: 0...1) < simulatedPacketLoss {
            return  // Dropped packet
        }

        // Simulate latency
        DispatchQueue.global().asyncAfter(deadline: .now() + simulatedLatency) {
            self.actualSend(data)
        }
    }
}
```

### Load Testing

```swift
// Simulate 10 players sending inputs at 60 Hz
func loadTest() {
    for i in 0..<10 {
        Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            let input = generateRandomInput(playerId: i)
            server.processInput(input)
        }
    }
}
```

## Best Practices

1. **Minimize Input Latency**: Send inputs immediately, don't batch
2. **Prioritize Important Data**: Critical data (shots) on reliable channel
3. **Use Interpolation**: Smooth movement between updates
4. **Predict Everything**: Predict all player actions for responsiveness
5. **Trust Server**: Always defer to server for conflicts
6. **Monitor Performance**: Track latency, packet loss, bandwidth
7. **Handle Edge Cases**: Disconnects, timeouts, reconnects
8. **Test on Real Networks**: Test with actual latency and packet loss

## References

- [Valve Multiplayer Networking](https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking)
- [Gaffer on Games - Networked Physics](https://gafferongames.com/post/introduction_to_networked_physics/)
- [MultipeerConnectivity Documentation](https://developer.apple.com/documentation/multipeerconnectivity)

---

For implementation details, see `NetworkManager.swift` and related networking code.
