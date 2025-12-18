import Foundation

/// Thread-safe LRU (Least Recently Used) Cache implementation
/// Uses a doubly-linked list for O(1) access and eviction
actor LRUCache<Key: Hashable, Value> {

    // MARK: - Types

    private final class Node {
        let key: Key
        var value: Value
        var previous: Node?
        var next: Node?
        var lastAccessed: Date

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
            self.lastAccessed = Date()
        }
    }

    // MARK: - Properties

    private var cache: [Key: Node] = [:]
    private var head: Node?  // Most recently used
    private var tail: Node?  // Least recently used

    private let capacity: Int
    private let expirationInterval: TimeInterval?

    private(set) var hitCount: Int = 0
    private(set) var missCount: Int = 0

    // MARK: - Initialization

    /// Initialize LRU cache
    /// - Parameters:
    ///   - capacity: Maximum number of items to store
    ///   - expirationInterval: Optional TTL for cache entries (nil = no expiration)
    init(capacity: Int, expirationInterval: TimeInterval? = nil) {
        precondition(capacity > 0, "Cache capacity must be positive")
        self.capacity = capacity
        self.expirationInterval = expirationInterval
    }

    // MARK: - Public API

    /// Get value for key, returns nil if not found or expired
    func get(_ key: Key) -> Value? {
        guard let node = cache[key] else {
            missCount += 1
            return nil
        }

        // Check expiration
        if let expiration = expirationInterval,
           Date().timeIntervalSince(node.lastAccessed) > expiration {
            remove(key)
            missCount += 1
            return nil
        }

        // Move to head (most recently used)
        moveToHead(node)
        node.lastAccessed = Date()
        hitCount += 1

        return node.value
    }

    /// Set value for key
    func set(_ key: Key, value: Value) {
        if let existingNode = cache[key] {
            // Update existing
            existingNode.value = value
            existingNode.lastAccessed = Date()
            moveToHead(existingNode)
        } else {
            // Create new node
            let newNode = Node(key: key, value: value)
            cache[key] = newNode
            addToHead(newNode)

            // Evict if over capacity
            if cache.count > capacity {
                evictLRU()
            }
        }
    }

    /// Remove value for key
    @discardableResult
    func remove(_ key: Key) -> Value? {
        guard let node = cache[key] else {
            return nil
        }

        removeNode(node)
        cache.removeValue(forKey: key)
        return node.value
    }

    /// Check if key exists (without affecting LRU order)
    func contains(_ key: Key) -> Bool {
        guard let node = cache[key] else {
            return false
        }

        // Check expiration
        if let expiration = expirationInterval,
           Date().timeIntervalSince(node.lastAccessed) > expiration {
            remove(key)
            return false
        }

        return true
    }

    /// Clear all entries
    func clear() {
        cache.removeAll()
        head = nil
        tail = nil
        hitCount = 0
        missCount = 0
    }

    /// Current number of cached items
    var count: Int {
        cache.count
    }

    /// Cache hit ratio (0.0 - 1.0)
    var hitRatio: Double {
        let total = hitCount + missCount
        guard total > 0 else { return 0 }
        return Double(hitCount) / Double(total)
    }

    /// Get all keys (for debugging/testing)
    var keys: [Key] {
        Array(cache.keys)
    }

    /// Remove expired entries
    func pruneExpired() {
        guard let expiration = expirationInterval else { return }

        let now = Date()
        let expiredKeys = cache.compactMap { key, node -> Key? in
            if now.timeIntervalSince(node.lastAccessed) > expiration {
                return key
            }
            return nil
        }

        for key in expiredKeys {
            remove(key)
        }
    }

    // MARK: - Private Helpers

    private func addToHead(_ node: Node) {
        node.previous = nil
        node.next = head

        if let currentHead = head {
            currentHead.previous = node
        }

        head = node

        if tail == nil {
            tail = node
        }
    }

    private func removeNode(_ node: Node) {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }

        if let next = next {
            next.previous = prev
        } else {
            tail = prev
        }

        node.previous = nil
        node.next = nil
    }

    private func moveToHead(_ node: Node) {
        guard node !== head else { return }
        removeNode(node)
        addToHead(node)
    }

    private func evictLRU() {
        guard let lruNode = tail else { return }
        cache.removeValue(forKey: lruNode.key)
        removeNode(lruNode)
    }
}

// MARK: - Convenience Extensions

extension LRUCache {
    /// Get or compute value if not cached
    func getOrCompute(_ key: Key, compute: () async throws -> Value) async rethrows -> Value {
        if let cached = await get(key) {
            return cached
        }

        let value = try await compute()
        await set(key, value: value)
        return value
    }
}

// MARK: - Debug Description

extension LRUCache: CustomStringConvertible {
    nonisolated var description: String {
        "LRUCache(capacity: \(capacity))"
    }
}
