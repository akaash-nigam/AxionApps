//
//  NetworkSyncManager.swift
//  Parkour Pathways
//
//  Real-time network state synchronization
//

import Foundation
import Network
import Combine

/// Manages real-time network synchronization for multiplayer
class NetworkSyncManager: ObservableObject {

    // MARK: - Published Properties

    @Published var syncState: NetworkSyncState = .disconnected
    @Published var latency: TimeInterval = 0
    @Published var packetLoss: Float = 0

    // MARK: - Properties

    private var connection: NWConnection?
    private var listener: NWListener?
    private var isRecording: Bool = false
    private var recordingBuffer: [(time: TimeInterval, position: SIMD3<Float>)] = []
    private var recordingStartTime: Date?

    private var sendQueue: [SyncEvent] = []
    private var receiveHandlers: [(SyncEvent) -> Void] = []

    private let queue = DispatchQueue(label: "com.parkourpathways.networksync")
    private var cancellables = Set<AnyCancellable>()

    // Network configuration
    private let maxPacketsPerSecond = 60 // 60Hz update rate
    private let maxBufferSize = 100
    private var lastSendTime: Date = Date()

    // MARK: - Initialization

    init() {
        setupNetworkMonitoring()
    }

    // MARK: - Setup

    private func setupNetworkMonitoring() {
        let monitor = NWPathMonitor()

        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                print("Network available")
            } else {
                print("Network unavailable")
                self?.disconnect()
            }
        }

        monitor.start(queue: queue)
    }

    // MARK: - Public API - Connection Management

    /// Connect to peer-to-peer network
    func connect(to endpoint: NWEndpoint) {
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true

        connection = NWConnection(to: endpoint, using: parameters)
        connection?.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionStateChanged(state)
        }

        connection?.start(queue: queue)
        syncState = .connecting
    }

    /// Start listening for connections (host mode)
    func startListening() throws {
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true

        listener = try NWListener(using: parameters)

        listener?.stateUpdateHandler = { [weak self] state in
            self?.handleListenerStateChanged(state)
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }

        listener?.start(queue: queue)
    }

    /// Disconnect from network
    func disconnect() {
        connection?.cancel()
        listener?.cancel()
        connection = nil
        listener = nil
        syncState = .disconnected
    }

    // MARK: - Public API - Sending Updates

    /// Send an update to connected peers
    func sendUpdate(_ event: SyncEvent) {
        guard syncState == .connected else {
            sendQueue.append(event)
            return
        }

        // Rate limiting
        let now = Date()
        let timeSinceLastSend = now.timeIntervalSince(lastSendTime)
        let minInterval = 1.0 / Double(maxPacketsPerSecond)

        if timeSinceLastSend < minInterval {
            sendQueue.append(event)
            return
        }

        // Send immediately
        Task {
            await sendEventImmediate(event)
            lastSendTime = now
        }
    }

    /// Send queued updates (called by timer)
    func flushSendQueue() {
        guard !sendQueue.isEmpty else { return }

        let eventsToSend = Array(sendQueue.prefix(10)) // Batch up to 10 events
        sendQueue.removeFirst(min(10, sendQueue.count))

        Task {
            for event in eventsToSend {
                await sendEventImmediate(event)
            }
        }
    }

    private func sendEventImmediate(_ event: SyncEvent) async {
        guard let connection = connection else { return }

        do {
            let data = try JSONEncoder().encode(event)
            let length = UInt32(data.count)

            // Send length prefix
            var lengthData = Data()
            lengthData.append(contentsOf: withUnsafeBytes(of: length.bigEndian) { Array($0) })

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                connection.send(content: lengthData + data, completion: .contentProcessed { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                })
            }

        } catch {
            print("Failed to send event: \(error)")
        }
    }

    // MARK: - Public API - Receiving Updates

    /// Register handler for receiving events
    func onReceiveUpdate(_ handler: @escaping (SyncEvent) -> Void) {
        receiveHandlers.append(handler)
    }

    private func startReceiving() {
        guard let connection = connection else { return }

        receiveMessage(on: connection)
    }

    private func receiveMessage(on connection: NWConnection) {
        // First receive the length (4 bytes)
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if let error = error {
                print("Receive error: \(error)")
                self.syncState = .error(error)
                return
            }

            guard let data = data, data.count == 4 else {
                // Continue receiving
                self.receiveMessage(on: connection)
                return
            }

            // Parse length
            let length = data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }

            // Now receive the message
            connection.receive(minimumIncompleteLength: Int(length), maximumLength: Int(length)) { data, _, _, error in
                if let error = error {
                    print("Message receive error: \(error)")
                    return
                }

                guard let data = data else {
                    // Continue receiving
                    self.receiveMessage(on: connection)
                    return
                }

                // Decode and handle event
                do {
                    let event = try JSONDecoder().decode(SyncEvent.self, from: data)
                    self.handleReceivedEvent(event)
                } catch {
                    print("Failed to decode event: \(error)")
                }

                // Continue receiving
                self.receiveMessage(on: connection)
            }
        }
    }

    private func handleReceivedEvent(_ event: SyncEvent) {
        // Notify all handlers
        DispatchQueue.main.async {
            for handler in self.receiveHandlers {
                handler(event)
            }
        }
    }

    // MARK: - Public API - Recording

    /// Start recording movement for replay
    func startRecording() {
        isRecording = true
        recordingBuffer.removeAll()
        recordingStartTime = Date()
    }

    /// Stop recording and return data
    func stopRecording() -> MovementRecording? {
        isRecording = false

        guard let startTime = recordingStartTime, !recordingBuffer.isEmpty else {
            return nil
        }

        let duration = Date().timeIntervalSince(startTime)

        return MovementRecording(
            positions: recordingBuffer,
            duration: duration
        )
    }

    /// Record a position (called each frame during recording)
    func recordPosition(_ position: SIMD3<Float>) {
        guard isRecording, let startTime = recordingStartTime else { return }

        let time = Date().timeIntervalSince(startTime)
        recordingBuffer.append((time: time, position: position))

        // Limit buffer size
        if recordingBuffer.count > 10000 { // ~166 seconds at 60fps
            recordingBuffer.removeFirst()
        }
    }

    // MARK: - Public API - Metrics

    /// Measure network latency (ping)
    func measureLatency() async -> TimeInterval {
        let sendTime = Date()

        // Send ping
        let pingEvent = SyncEvent.movement(
            playerId: UUID(),
            event: .jump(position: .zero, intensity: 0),
            timestamp: sendTime
        )

        await sendEventImmediate(pingEvent)

        // Wait for response (simplified - would need actual ping/pong)
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms estimate

        let latency = Date().timeIntervalSince(sendTime)
        self.latency = latency

        return latency
    }

    // MARK: - Private Connection Handlers

    private func handleConnectionStateChanged(_ state: NWConnection.State) {
        DispatchQueue.main.async {
            switch state {
            case .ready:
                self.syncState = .connected
                self.startReceiving()

            case .waiting(let error):
                print("Connection waiting: \(error)")
                self.syncState = .connecting

            case .failed(let error):
                print("Connection failed: \(error)")
                self.syncState = .error(error)

            case .cancelled:
                self.syncState = .disconnected

            default:
                break
            }
        }
    }

    private func handleListenerStateChanged(_ state: NWListener.State) {
        DispatchQueue.main.async {
            switch state {
            case .ready:
                print("Listener ready")
                self.syncState = .connected

            case .failed(let error):
                print("Listener failed: \(error)")
                self.syncState = .error(error)

            case .cancelled:
                self.syncState = .disconnected

            default:
                break
            }
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        self.connection = connection
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionStateChanged(state)
        }
        connection.start(queue: queue)
    }

    // MARK: - Cleanup

    deinit {
        disconnect()
    }
}

// MARK: - Supporting Types

enum NetworkSyncState {
    case disconnected
    case connecting
    case connected
    case error(Error)
}
