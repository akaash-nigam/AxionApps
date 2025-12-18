//
//  EventTracker.swift
//  Parkour Pathways
//
//  Event tracking and analytics pipeline
//

import Foundation
import OSLog

/// Tracks and batches analytics events
class EventTracker {

    // MARK: - Properties

    private var eventQueue: [TrackedEvent] = []
    private var userProperties: [String: Any] = [:]
    private var userId: UUID?

    private let logger = Logger(subsystem: "com.parkourpathways", category: "EventTracking")
    private let queue = DispatchQueue(label: "com.parkourpathways.eventtracker", qos: .utility)

    // Configuration
    private let maxQueueSize = 100
    private let flushInterval: TimeInterval = 30 // Flush every 30 seconds
    private let endpoint = "https://analytics.parkourpathways.app/v1/events"

    private var flushTimer: Timer?

    // MARK: - Initialization

    init() {
        setupAutoFlush()
        loadPersistedEvents()
    }

    // MARK: - Public API

    /// Set the current user ID
    func setUserId(_ userId: UUID) {
        self.userId = userId
    }

    /// Set user properties
    func setUserProperties(_ properties: [String: Any]) {
        queue.async {
            self.userProperties.merge(properties) { _, new in new }
        }
    }

    /// Track an event
    func track(_ event: AnalyticsEvent, userId: UUID?, sessionId: UUID) {
        let trackedEvent = TrackedEvent(
            event: event,
            userId: userId,
            sessionId: sessionId,
            userProperties: userProperties,
            deviceInfo: getDeviceInfo(),
            timestamp: Date()
        )

        queue.async {
            self.eventQueue.append(trackedEvent)
            self.logger.debug("Tracked event: \(event.name)")

            // Auto-flush if queue is full
            if self.eventQueue.count >= self.maxQueueSize {
                self.flush()
            }
        }
    }

    /// Flush all pending events
    func flush() {
        queue.async {
            guard !self.eventQueue.isEmpty else { return }

            let eventsToSend = self.eventQueue
            self.eventQueue.removeAll()

            Task {
                await self.sendEvents(eventsToSend)
            }
        }
    }

    // MARK: - Private Helpers

    private func setupAutoFlush() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            self?.flush()
        }
    }

    private func loadPersistedEvents() {
        // Load any events that were persisted but not sent
        queue.async {
            if let loaded = self.loadFromDisk() {
                self.eventQueue.append(contentsOf: loaded)
                self.logger.info("Loaded \(loaded.count) persisted events")
            }
        }
    }

    private func sendEvents(_ events: [TrackedEvent]) async {
        do {
            // Convert events to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(events)

            // Create request
            guard let url = URL(string: endpoint) else {
                logger.error("Invalid analytics endpoint")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("visionOS/1.0", forHTTPHeaderField: "User-Agent")
            request.httpBody = data

            // Send request
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    logger.info("Successfully sent \(events.count) events")
                } else {
                    logger.error("Failed to send events: HTTP \(httpResponse.statusCode)")
                    // Persist failed events
                    saveToDisk(events)
                }
            }

        } catch {
            logger.error("Error sending events: \(error.localizedDescription)")
            // Persist failed events
            saveToDisk(events)
        }
    }

    private func getDeviceInfo() -> DeviceInfo {
        return DeviceInfo(
            model: "Apple Vision Pro", // Would detect actual model
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier
        )
    }

    private func saveToDisk(_ events: [TrackedEvent]) {
        queue.async {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(events)

                let fileURL = self.getStorageURL()
                try data.write(to: fileURL)

                self.logger.info("Persisted \(events.count) events to disk")
            } catch {
                self.logger.error("Failed to persist events: \(error.localizedDescription)")
            }
        }
    }

    private func loadFromDisk() -> [TrackedEvent]? {
        do {
            let fileURL = getStorageURL()
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return nil
            }

            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let events = try decoder.decode([TrackedEvent].self, from: data)

            // Delete file after loading
            try FileManager.default.removeItem(at: fileURL)

            return events
        } catch {
            logger.error("Failed to load persisted events: \(error.localizedDescription)")
            return nil
        }
    }

    private func getStorageURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("pending_events.json")
    }

    // MARK: - Cleanup

    deinit {
        flushTimer?.invalidate()
        flush()
    }
}

// MARK: - Supporting Types

struct TrackedEvent: Codable {
    let eventId: UUID = UUID()
    let eventName: String
    let eventParameters: [String: String]
    let userId: UUID?
    let sessionId: UUID
    let userProperties: [String: String]
    let deviceInfo: DeviceInfo
    let timestamp: Date

    init(
        event: AnalyticsEvent,
        userId: UUID?,
        sessionId: UUID,
        userProperties: [String: Any],
        deviceInfo: DeviceInfo,
        timestamp: Date
    ) {
        self.eventName = event.name
        self.eventParameters = Self.convertParameters(from: event)
        self.userId = userId
        self.sessionId = sessionId
        self.userProperties = Self.convertToStringDict(userProperties)
        self.deviceInfo = deviceInfo
        self.timestamp = timestamp
    }

    private static func convertParameters(from event: AnalyticsEvent) -> [String: String] {
        var params: [String: String] = [:]

        switch event {
        case .screenView(let screenName, let parameters, _):
            params["screen_name"] = screenName
            params.merge(convertToStringDict(parameters)) { _, new in new }

        case .gameplay(let eventName, let courseId, let parameters, _):
            params["event_name"] = eventName
            if let courseId = courseId {
                params["course_id"] = courseId.uuidString
            }
            params.merge(convertToStringDict(parameters)) { _, new in new }

        case .purchase(let productId, let price, let currency, _):
            params["product_id"] = productId
            params["price"] = "\(price)"
            params["currency"] = currency

        case .achievementUnlocked(let achievementId, let value, _):
            params["achievement_id"] = achievementId
            params["value"] = "\(value)"

        case .performance(let metric, let value, let unit, _):
            params["metric"] = metric
            params["value"] = "\(value)"
            params["unit"] = unit

        case .error(let errorType, let errorMessage, let context, _):
            params["error_type"] = errorType
            params["error_message"] = errorMessage
            params.merge(convertToStringDict(context)) { _, new in new }

        case .funnel(let funnelName, let step, let stepName, _):
            params["funnel_name"] = funnelName
            params["step"] = "\(step)"
            params["step_name"] = stepName

        case .funnelComplete(let funnelName, let duration, _):
            params["funnel_name"] = funnelName
            params["duration"] = "\(duration)"

        case .experimentAssignment(let experimentId, let variant, _):
            params["experiment_id"] = experimentId
            params["variant"] = variant

        case .sessionStart(let sessionId, _):
            params["session_id"] = sessionId.uuidString

        case .sessionEnd(let sessionId, let duration, _):
            params["session_id"] = sessionId.uuidString
            params["duration"] = "\(duration)"
        }

        return params
    }

    private static func convertToStringDict(_ dict: [String: Any]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in dict {
            result[key] = "\(value)"
        }
        return result
    }
}

struct DeviceInfo: Codable {
    let model: String
    let osVersion: String
    let appVersion: String
    let locale: String
    let timezone: String
}
