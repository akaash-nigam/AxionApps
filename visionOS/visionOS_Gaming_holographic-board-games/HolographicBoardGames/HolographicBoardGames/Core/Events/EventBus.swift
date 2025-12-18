//
//  EventBus.swift
//  HolographicBoardGames
//
//  Event system for decoupled communication between systems
//

import Foundation

/// Protocol that all events must conform to
protocol GameEvent {
    var timestamp: Date { get }
}

/// Event subscription handle for unsubscribing
struct EventSubscription {
    let id: UUID
    fileprivate let unsubscribe: () -> Void

    func cancel() {
        unsubscribe()
    }
}

final class EventBus {
    static let shared = EventBus()

    private var subscribers: [String: [UUID: (GameEvent) -> Void]] = [:]
    private let queue = DispatchQueue(label: "com.holographicgames.eventbus", attributes: .concurrent)

    private init() {}

    // MARK: - Subscribe

    /// Subscribe to events of a specific type
    @discardableResult
    func subscribe<T: GameEvent>(
        _ eventType: T.Type,
        handler: @escaping (T) -> Void
    ) -> EventSubscription {
        let key = String(describing: eventType)
        let id = UUID()

        queue.async(flags: .barrier) { [weak self] in
            if self?.subscribers[key] == nil {
                self?.subscribers[key] = [:]
            }

            self?.subscribers[key]?[id] = { event in
                if let typedEvent = event as? T {
                    handler(typedEvent)
                }
            }
        }

        return EventSubscription(id: id) { [weak self] in
            self?.unsubscribe(id: id, eventType: key)
        }
    }

    private func unsubscribe(id: UUID, eventType: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.subscribers[eventType]?.removeValue(forKey: id)
        }
    }

    // MARK: - Publish

    /// Publish an event to all subscribers
    func publish<T: GameEvent>(_ event: T) {
        let key = String(describing: T.self)

        // Read subscribers synchronously to capture current state
        var handlers: [(GameEvent) -> Void] = []
        queue.sync {
            if let eventSubscribers = subscribers[key] {
                handlers = Array(eventSubscribers.values)
            }
        }

        // Call all handlers on main thread
        DispatchQueue.main.async {
            for handler in handlers {
                handler(event)
            }
        }
    }

    /// Remove all subscriptions
    func removeAllSubscriptions() {
        queue.async(flags: .barrier) { [weak self] in
            self?.subscribers.removeAll()
        }
    }

    /// Remove all subscriptions for a specific event type
    func removeSubscriptions<T: GameEvent>(for eventType: T.Type) {
        let key = String(describing: eventType)
        queue.async(flags: .barrier) { [weak self] in
            self?.subscribers.removeValue(forKey: key)
        }
    }
}
