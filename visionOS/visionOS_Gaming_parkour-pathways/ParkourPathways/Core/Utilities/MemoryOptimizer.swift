//
//  MemoryOptimizer.swift
//  Parkour Pathways
//
//  Memory management and optimization utilities
//

import Foundation
import OSLog

/// Manages memory optimization and resource caching
class MemoryOptimizer {

    // MARK: - Singleton

    static let shared = MemoryOptimizer()

    // MARK: - Properties

    private let logger = Logger(subsystem: "com.parkourpathways", category: "MemoryOptimizer")

    // Cache management
    private var resourceCache: [String: CachedResource] = [:]
    private var cacheAccessTimes: [String: Date] = [:]

    // Configuration
    private let maxCacheSize: Int64 = 200 * 1024 * 1024 // 200 MB
    private var currentCacheSize: Int64 = 0
    private let cacheExpirationTime: TimeInterval = 300 // 5 minutes

    // Object pooling
    private var objectPools: [String: ObjectPool] = [:]

    // Memory warning handling
    private var memoryWarningObserver: NSObjectProtocol?

    // MARK: - Initialization

    private init() {
        setupMemoryWarningObserver()
    }

    // MARK: - Setup

    private func setupMemoryWarningObserver() {
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }

    // MARK: - Public API - Cache Management

    /// Cache a resource
    func cacheResource(_ resource: Any, forKey key: String, size: Int) {
        // Check if adding would exceed limit
        if currentCacheSize + Int64(size) > maxCacheSize {
            evictLRUResources(toFree: Int64(size))
        }

        // Cache the resource
        let cached = CachedResource(
            resource: resource,
            size: size,
            cachedAt: Date()
        )

        resourceCache[key] = cached
        cacheAccessTimes[key] = Date()
        currentCacheSize += Int64(size)

        logger.debug("Cached resource '\(key)' (\(size) bytes)")
    }

    /// Retrieve a cached resource
    func getCachedResource(_ key: String) -> Any? {
        guard let cached = resourceCache[key] else {
            return nil
        }

        // Check expiration
        if Date().timeIntervalSince(cached.cachedAt) > cacheExpirationTime {
            removeCachedResource(key)
            return nil
        }

        // Update access time (LRU)
        cacheAccessTimes[key] = Date()

        return cached.resource
    }

    /// Remove a cached resource
    func removeCachedResource(_ key: String) {
        if let cached = resourceCache[key] {
            currentCacheSize -= Int64(cached.size)
            resourceCache.removeValue(forKey: key)
            cacheAccessTimes.removeValue(forKey: key)
            logger.debug("Removed cached resource '\(key)'")
        }
    }

    /// Clear all cached resources
    func clearCache() {
        resourceCache.removeAll()
        cacheAccessTimes.removeAll()
        currentCacheSize = 0
        logger.info("Cleared all cached resources")
    }

    /// Get cache statistics
    func getCacheStats() -> CacheStats {
        return CacheStats(
            itemCount: resourceCache.count,
            totalSize: currentCacheSize,
            maxSize: maxCacheSize,
            utilizationPercent: Float(currentCacheSize) / Float(maxCacheSize) * 100
        )
    }

    // MARK: - Public API - Object Pooling

    /// Get or create an object pool
    func getPool<T: AnyObject>(for type: T.Type, capacity: Int = 50) -> ObjectPool {
        let key = String(describing: type)

        if let existingPool = objectPools[key] {
            return existingPool
        }

        let newPool = ObjectPool(capacity: capacity)
        objectPools[key] = newPool

        return newPool
    }

    /// Clear all object pools
    func clearAllPools() {
        for pool in objectPools.values {
            pool.clear()
        }
        objectPools.removeAll()
        logger.info("Cleared all object pools")
    }

    // MARK: - Public API - Memory Management

    /// Get current memory usage
    func getCurrentMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        guard kerr == KERN_SUCCESS else {
            return 0
        }

        return Int64(info.resident_size)
    }

    /// Get available memory
    func getAvailableMemory() -> Int64 {
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return 0
        }

        let freeMemory = Int64(stats.free_count) * Int64(pageSize)
        return freeMemory
    }

    /// Get memory pressure level
    func getMemoryPressure() -> MemoryPressure {
        let available = getAvailableMemory()
        let total = Int64(ProcessInfo.processInfo.physicalMemory)
        let percentAvailable = Float(available) / Float(total) * 100

        if percentAvailable < 10 {
            return .critical
        } else if percentAvailable < 20 {
            return .high
        } else if percentAvailable < 40 {
            return .moderate
        } else {
            return .normal
        }
    }

    /// Force garbage collection (Swift's ARC will handle this automatically)
    func triggerMemoryCleanup() {
        logger.info("Triggering memory cleanup")

        // Clear expired cache items
        evictExpiredResources()

        // Clear object pools
        clearAllPools()

        // Log results
        let currentUsage = getCurrentMemoryUsage()
        logger.info("Memory usage after cleanup: \(currentUsage / (1024 * 1024)) MB")
    }

    // MARK: - Private Helpers

    private func handleMemoryWarning() {
        logger.warning("Memory warning received")

        // Aggressive cache eviction
        let stats = getCacheStats()
        logger.warning("Current cache: \(stats.itemCount) items, \(stats.totalSize / (1024 * 1024)) MB")

        // Clear 50% of cache
        evictLRUResources(toFree: currentCacheSize / 2)

        // Clear object pools
        clearAllPools()

        logger.info("Memory warning handled")
    }

    private func evictLRUResources(toFree bytesToFree: Int64) {
        var freedBytes: Int64 = 0

        // Sort by access time (least recently used first)
        let sortedKeys = cacheAccessTimes.sorted { $0.value < $1.value }.map { $0.key }

        for key in sortedKeys {
            guard freedBytes < bytesToFree else { break }

            if let cached = resourceCache[key] {
                freedBytes += Int64(cached.size)
                removeCachedResource(key)
            }
        }

        logger.info("Evicted \(freedBytes / (1024 * 1024)) MB from cache")
    }

    private func evictExpiredResources() {
        let now = Date()
        var expiredKeys: [String] = []

        for (key, cached) in resourceCache {
            if now.timeIntervalSince(cached.cachedAt) > cacheExpirationTime {
                expiredKeys.append(key)
            }
        }

        for key in expiredKeys {
            removeCachedResource(key)
        }

        if !expiredKeys.isEmpty {
            logger.info("Evicted \(expiredKeys.count) expired resources")
        }
    }

    // MARK: - Cleanup

    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - Supporting Types

struct CachedResource {
    let resource: Any
    let size: Int
    let cachedAt: Date
}

struct CacheStats {
    let itemCount: Int
    let totalSize: Int64
    let maxSize: Int64
    let utilizationPercent: Float
}

enum MemoryPressure {
    case normal
    case moderate
    case high
    case critical
}

/// Simple object pool for reusable objects
class ObjectPool {
    private var pool: [AnyObject] = []
    private let capacity: Int
    private let lock = NSLock()

    init(capacity: Int) {
        self.capacity = capacity
    }

    /// Borrow an object from the pool
    func borrow() -> AnyObject? {
        lock.lock()
        defer { lock.unlock() }

        guard !pool.isEmpty else {
            return nil
        }

        return pool.removeLast()
    }

    /// Return an object to the pool
    func returnObject(_ object: AnyObject) {
        lock.lock()
        defer { lock.unlock() }

        guard pool.count < capacity else {
            return // Pool is full
        }

        pool.append(object)
    }

    /// Clear the pool
    func clear() {
        lock.lock()
        defer { lock.unlock() }

        pool.removeAll()
    }

    /// Get pool statistics
    func getStats() -> (available: Int, capacity: Int) {
        lock.lock()
        defer { lock.unlock() }

        return (available: pool.count, capacity: capacity)
    }
}
