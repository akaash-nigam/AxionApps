import Foundation

/// Event handler protocol
protocol EventHandler: Actor {
    func handle(_ event: GameEvent) async
}

/// Central event bus for publish/subscribe pattern
actor EventBus {
    private var subscriptions: [EventType: [WeakEventHandler]] = [:]

    /// Publish an event to all subscribers
    func publish(_ event: GameEvent) async {
        // Clean up nil handlers first
        cleanupSubscriptions()

        // Get handlers for this event type
        if let handlers = subscriptions[event.eventType] {
            await withTaskGroup(of: Void.self) { group in
                for weakHandler in handlers {
                    if let handler = weakHandler.handler {
                        group.addTask {
                            await handler.handle(event)
                        }
                    }
                }
            }
        }
    }

    /// Subscribe to a specific event type
    func subscribe<H: EventHandler>(_ eventType: EventType, handler: H) {
        let weakHandler = WeakEventHandler(handler: handler)
        subscriptions[eventType, default: []].append(weakHandler)
    }

    /// Unsubscribe from all events
    func unsubscribeAll() {
        subscriptions.removeAll()
    }

    /// Clean up any deallocated handlers
    private func cleanupSubscriptions() {
        for (key, handlers) in subscriptions {
            let cleanedHandlers = handlers.filter { $0.handler != nil }
            if cleanedHandlers.isEmpty {
                subscriptions.removeValue(forKey: key)
            } else {
                subscriptions[key] = cleanedHandlers
            }
        }
    }
}

/// Weak wrapper for event handlers to prevent retain cycles
private class WeakEventHandler {
    private weak var _handler: AnyObject?

    init<H: EventHandler>(handler: H) {
        self._handler = handler as AnyObject
    }

    var handler: (any EventHandler)? {
        _handler as? any EventHandler
    }
}
