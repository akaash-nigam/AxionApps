import Foundation
import Logging
import Starscream
import os.lock

/// Sensor Integration Service - Handles real-time sensor data from industrial IoT systems
@Observable
final class SensorIntegrationService: @unchecked Sendable {

    // MARK: - Properties

    private let logger: Logging.Logger
    private var webSocket: WebSocket?
    private var mqttClient: MQTTClient?

    // Thread-safe sensor data buffer (actor-based)
    private let sensorBuffer: SensorDataBuffer

    // Active sensor streams with thread-safe access
    private let streamsLock = OSAllocatedUnfairLock<[UUID: SensorStream]>(initialState: [:])

    // Connection state (atomic access via lock)
    private let stateLock = OSAllocatedUnfairLock<ConnectionState>(initialState: .disconnected)
    var connectionState: ConnectionState {
        get { stateLock.withLock { $0 } }
        set { stateLock.withLock { $0 = newValue } }
    }

    private(set) var lastDataReceived: Date?

    // Performance metrics (atomic access)
    private let metricsLock = OSAllocatedUnfairLock<(received: Int, perSecond: Double)>(initialState: (0, 0))
    private var metricsTimer: Task<Void, Never>?

    var messagesPerSecond: Double {
        metricsLock.withLock { $0.perSecond }
    }

    // MARK: - Configuration

    struct Configuration {
        var reconnectDelay: TimeInterval = 5.0
        var maxReconnectAttempts: Int = 5
        var heartbeatInterval: TimeInterval = 30.0
        var bufferFlushInterval: TimeInterval = 1.0
    }

    private var config: Configuration

    // MARK: - Initialization

    init(
        config: Configuration = Configuration(),
        logger: Logging.Logger = Logging.Logger(label: "com.twinspace.sensor")
    ) {
        self.config = config
        self.logger = logger
        self.sensorBuffer = SensorDataBuffer(
            bufferSize: 100,
            flushInterval: config.bufferFlushInterval
        )

        startMetricsTracking()
        startBufferFlushing()
    }

    // MARK: - WebSocket Connection

    /// Connect to WebSocket sensor stream
    func connectWebSocket(url: URL, authToken: String? = nil) async throws {
        logger.info("Connecting to WebSocket: \(url)")

        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self

        connectionState = .connecting
        webSocket?.connect()

        // Start heartbeat
        startHeartbeat()
    }

    /// Disconnect from WebSocket
    func disconnectWebSocket() {
        logger.info("Disconnecting WebSocket")
        connectionState = .disconnected
        webSocket?.disconnect()
        webSocket = nil
    }

    // MARK: - Sensor Stream Management

    /// Subscribe to sensor data stream
    func subscribe(to sensorId: UUID) -> AsyncStream<SensorReading> {
        logger.info("Subscribing to sensor: \(sensorId)")

        let stream = AsyncStream<SensorReading> { continuation in
            let sensorStream = SensorStream(
                id: sensorId,
                continuation: continuation
            )

            // Thread-safe access to activeStreams
            self.streamsLock.withLock { streams in
                streams[sensorId] = sensorStream
            }

            // Send subscribe message via WebSocket
            self.sendSubscribeMessage(sensorId: sensorId)
        }

        return stream
    }

    /// Unsubscribe from sensor data stream
    func unsubscribe(from sensorId: UUID) {
        logger.info("Unsubscribing from sensor: \(sensorId)")

        // Thread-safe cancel and remove stream
        let stream = streamsLock.withLock { streams -> SensorStream? in
            let stream = streams[sensorId]
            streams.removeValue(forKey: sensorId)
            return stream
        }

        stream?.continuation.finish()

        // Send unsubscribe message
        sendUnsubscribeMessage(sensorId: sensorId)
    }

    /// Get continuation for a sensor stream (thread-safe)
    private func getStreamContinuation(for sensorId: UUID) -> AsyncStream<SensorReading>.Continuation? {
        streamsLock.withLock { streams in
            streams[sensorId]?.continuation
        }
    }

    // MARK: - MQTT Support

    /// Connect to MQTT broker
    func connectMQTT(
        broker: String,
        port: Int = 1883,
        clientId: String,
        username: String? = nil,
        password: String? = nil
    ) async throws {
        logger.info("Connecting to MQTT broker: \(broker):\(port)")

        mqttClient = MQTTClient(
            host: broker,
            port: port,
            clientId: clientId
        )

        if let username = username, let password = password {
            mqttClient?.username = username
            mqttClient?.password = password
        }

        try await mqttClient?.connect()
        connectionState = .connected
        logger.info("Connected to MQTT broker")
    }

    /// Subscribe to MQTT topic
    func subscribeMQTT(topic: String) -> AsyncStream<SensorReading> {
        logger.info("Subscribing to MQTT topic: \(topic)")

        let stream = AsyncStream<SensorReading> { continuation in
            Task {
                guard let client = mqttClient else {
                    continuation.finish()
                    return
                }

                await client.subscribe(to: topic) { message in
                    if let reading = self.parseMQTTMessage(message) {
                        continuation.yield(reading)
                    }
                }
            }
        }

        return stream
    }

    // MARK: - OPC UA Support

    /// Create OPC UA adapter for industrial protocols
    func createOPCUAAdapter(endpoint: URL) -> OPCUAAdapter {
        logger.info("Creating OPC UA adapter: \(endpoint)")
        return OPCUAAdapter(endpoint: endpoint, logger: logger)
    }

    // MARK: - Data Processing

    /// Buffer sensor readings for batch processing (thread-safe via actor)
    private func bufferReading(_ reading: SensorReading) {
        Task {
            let shouldFlush = await sensorBuffer.add(reading)
            if shouldFlush {
                await flushBuffer(for: reading.sensorId)
            }
        }
    }

    /// Flush buffered readings (thread-safe)
    private func flushBuffer(for sensorId: UUID) async {
        let readings = await sensorBuffer.flush(sensorId: sensorId)
        guard !readings.isEmpty else { return }

        logger.debug("Flushing \(readings.count) buffered readings for sensor \(sensorId)")

        // Get continuation safely
        if let continuation = getStreamContinuation(for: sensorId) {
            for reading in readings {
                continuation.yield(reading)
            }
        }
    }

    /// Periodically flush all buffers
    private func startBufferFlushing() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(config.bufferFlushInterval))
                await flushAllBuffers()
            }
        }
    }

    /// Flush all sensor buffers
    private func flushAllBuffers() async {
        let sensorIds = await sensorBuffer.allSensorIds()
        for sensorId in sensorIds {
            await flushBuffer(for: sensorId)
        }
    }

    // MARK: - WebSocket Message Handling

    private func sendSubscribeMessage(sensorId: UUID) {
        let message: [String: Any] = [
            "type": "subscribe",
            "sensorId": sensorId.uuidString,
            "timestamp": Date().timeIntervalSince1970
        ]

        sendWebSocketMessage(message)
    }

    private func sendUnsubscribeMessage(sensorId: UUID) {
        let message: [String: Any] = [
            "type": "unsubscribe",
            "sensorId": sensorId.uuidString
        ]

        sendWebSocketMessage(message)
    }

    private func sendWebSocketMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: data, encoding: .utf8) else {
            logger.error("Failed to serialize message")
            return
        }

        webSocket?.write(string: jsonString)
    }

    private func handleWebSocketMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            logger.error("Failed to parse message")
            return
        }

        // Parse sensor reading
        if let reading = parseSensorReading(from: json) {
            // Thread-safe metrics update
            metricsLock.withLock { metrics in
                metrics.received += 1
            }
            lastDataReceived = Date()

            // Buffer or stream directly based on quality
            if reading.quality == .excellent {
                // High-quality readings go straight through (thread-safe)
                if let continuation = getStreamContinuation(for: reading.sensorId) {
                    continuation.yield(reading)
                }
            } else {
                // Buffer lower quality readings
                bufferReading(reading)
            }
        }
    }

    private func parseSensorReading(from json: [String: Any]) -> SensorReading? {
        guard let sensorIdString = json["sensorId"] as? String,
              let sensorId = UUID(uuidString: sensorIdString),
              let value = json["value"] as? Double,
              let timestamp = json["timestamp"] as? TimeInterval else {
            return nil
        }

        let qualityString = json["quality"] as? String ?? "good"
        let quality = DataQuality(rawValue: qualityString) ?? .good

        return SensorReading(
            sensorId: sensorId,
            value: value,
            timestamp: Date(timeIntervalSince1970: timestamp),
            quality: quality
        )
    }

    private func parseMQTTMessage(_ message: String) -> SensorReading? {
        // Parse MQTT message format
        // This depends on your MQTT message structure
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return parseSensorReading(from: json)
    }

    // MARK: - Heartbeat & Connection Management

    private func startHeartbeat() {
        Task {
            while connectionState == .connected {
                sendWebSocketMessage(["type": "ping"])
                try? await Task.sleep(for: .seconds(config.heartbeatInterval))
            }
        }
    }

    private func attemptReconnect(attempt: Int = 0) async {
        guard attempt < config.maxReconnectAttempts else {
            logger.error("Max reconnect attempts reached")
            connectionState = .failed
            return
        }

        logger.info("Reconnecting (attempt \(attempt + 1)/\(config.maxReconnectAttempts))")

        // Exponential backoff with maximum cap of 60 seconds
        let maxDelay: TimeInterval = 60.0
        let calculatedDelay = config.reconnectDelay * pow(2.0, Double(attempt))
        let delay = min(calculatedDelay, maxDelay)

        logger.debug("Waiting \(delay) seconds before reconnect")
        try? await Task.sleep(for: .seconds(delay))

        webSocket?.connect()
    }

    // MARK: - Metrics

    private func startMetricsTracking() {
        metricsTimer = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))

                // Thread-safe metrics update
                let currentRate = metricsLock.withLock { metrics -> Double in
                    let rate = Double(metrics.received)
                    metrics.perSecond = rate
                    metrics.received = 0
                    return rate
                }

                if currentRate > 0 {
                    logger.debug("Sensor data rate: \(Int(currentRate)) msg/s")
                }
            }
        }
    }

    func getMetrics() -> SensorMetrics {
        let streamCount = streamsLock.withLock { $0.count }
        return SensorMetrics(
            connectionState: connectionState,
            activeStreams: streamCount,
            messagesPerSecond: messagesPerSecond,
            lastDataReceived: lastDataReceived
        )
    }

    // MARK: - Cleanup

    deinit {
        disconnectWebSocket()
        mqttClient?.disconnect()
        metricsTimer?.cancel()
    }
}

// MARK: - WebSocket Delegate

extension SensorIntegrationService: WebSocketDelegate {
    nonisolated func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected(let headers):
            logger.info("WebSocket connected")
            connectionState = .connected
            logger.debug("Headers: \(headers)")

        case .disconnected(let reason, let code):
            logger.warning("WebSocket disconnected: \(reason) (code: \(code))")
            connectionState = .disconnected

            // Attempt reconnect
            Task { [weak self] in
                await self?.attemptReconnect()
            }

        case .text(let text):
            handleWebSocketMessage(text)

        case .binary(let data):
            // Handle binary data if needed
            logger.debug("Received binary data: \(data.count) bytes")

        case .ping, .pong:
            // Heartbeat responses
            break

        case .viabilityChanged(let isViable):
            logger.info("Connection viability changed: \(isViable)")
            if !isViable {
                connectionState = .disconnected
            }

        case .reconnectSuggested(let shouldReconnect):
            if shouldReconnect {
                Task { [weak self] in
                    await self?.attemptReconnect()
                }
            }

        case .cancelled:
            logger.info("WebSocket cancelled")
            connectionState = .disconnected

        case .error(let error):
            logger.error("WebSocket error: \(error?.localizedDescription ?? "unknown")")
            connectionState = .failed

        @unknown default:
            logger.warning("Received unknown WebSocket event")
        }
    }
}

// MARK: - Supporting Types

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case failed
}

struct SensorStream {
    let id: UUID
    let continuation: AsyncStream<SensorReading>.Continuation
}

struct SensorMetrics {
    let connectionState: ConnectionState
    let activeStreams: Int
    let messagesPerSecond: Double
    let lastDataReceived: Date?
}

// MARK: - OPC UA Adapter

class OPCUAAdapter: @unchecked Sendable {
    private let endpoint: URL
    private let logger: Logging.Logger

    init(endpoint: URL, logger: Logging.Logger) {
        self.endpoint = endpoint
        self.logger = logger
    }

    func connect() async throws {
        logger.info("Connecting to OPC UA server: \(endpoint)")
        // Implementation would use an OPC UA library
        // For now, this is a stub
    }

    func subscribe(nodeId: String) -> AsyncStream<SensorReading> {
        AsyncStream { continuation in
            Task { [weak self] in
                // Subscribe to OPC UA node
                // Parse and yield readings
                self?.logger.info("Subscribed to node: \(nodeId)")
            }
        }
    }

    func disconnect() async {
        logger.info("Disconnecting from OPC UA server")
    }
}

// MARK: - MQTT Client Stub

class MQTTClient {
    let host: String
    let port: Int
    let clientId: String
    var username: String?
    var password: String?

    init(host: String, port: Int, clientId: String) {
        self.host = host
        self.port = port
        self.clientId = clientId
    }

    func connect() async throws {
        // Implementation would use CocoaMQTT
        print("MQTT: Connecting to \(host):\(port)")
    }

    func subscribe(to topic: String, handler: @escaping (String) -> Void) async {
        // Implementation would subscribe to MQTT topic
        print("MQTT: Subscribed to \(topic)")
    }

    func disconnect() {
        print("MQTT: Disconnected")
    }
}

// MARK: - Thread-Safe Sensor Data Buffer

/// Actor-based thread-safe buffer for high-frequency sensor data
actor SensorDataBuffer {
    private var buffers: [UUID: [SensorReading]] = [:]
    private let bufferSize: Int
    private let flushInterval: TimeInterval

    init(bufferSize: Int = 100, flushInterval: TimeInterval = 1.0) {
        self.bufferSize = bufferSize
        self.flushInterval = flushInterval
    }

    /// Add a reading to the buffer, returns true if buffer should be flushed
    func add(_ reading: SensorReading) -> Bool {
        if buffers[reading.sensorId] == nil {
            buffers[reading.sensorId] = []
        }

        buffers[reading.sensorId]?.append(reading)

        // Return true if buffer is full and should be flushed
        return (buffers[reading.sensorId]?.count ?? 0) >= bufferSize
    }

    /// Flush and return all readings for a sensor
    func flush(sensorId: UUID) -> [SensorReading] {
        let readings = buffers[sensorId] ?? []
        buffers[sensorId] = []
        return readings
    }

    /// Get all sensor IDs that have buffered data
    func allSensorIds() -> [UUID] {
        Array(buffers.keys)
    }

    /// Get count of buffered readings for a sensor
    func count(for sensorId: UUID) -> Int {
        buffers[sensorId]?.count ?? 0
    }

    /// Clear all buffers
    func clearAll() {
        buffers.removeAll()
    }

    /// Get total buffered reading count across all sensors
    var totalCount: Int {
        buffers.values.reduce(0) { $0 + $1.count }
    }
}
