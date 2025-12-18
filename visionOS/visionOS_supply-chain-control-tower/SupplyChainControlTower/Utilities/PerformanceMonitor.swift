//
//  PerformanceMonitor.swift
//  SupplyChainControlTower
//
//  Performance monitoring and optimization utilities
//

import Foundation
import QuartzCore

// MARK: - Performance Monitor

@Observable
class PerformanceMonitor {

    // MARK: - Metrics

    var currentFPS: Double = 0
    var averageFPS: Double = 0
    var memoryUsage: UInt64 = 0
    var renderTime: TimeInterval = 0

    private var frameTimestamps: [TimeInterval] = []
    private let maxFrameHistory = 60

    // MARK: - FPS Tracking

    /// Record a frame timestamp
    func recordFrame() {
        let timestamp = CACurrentMediaTime()
        frameTimestamps.append(timestamp)

        // Keep only recent frames
        if frameTimestamps.count > maxFrameHistory {
            frameTimestamps.removeFirst()
        }

        updateFPS()
    }

    /// Calculate current FPS
    private func updateFPS() {
        guard frameTimestamps.count >= 2 else { return }

        let timespan = frameTimestamps.last! - frameTimestamps.first!
        let frameCount = frameTimestamps.count - 1

        if timespan > 0 {
            currentFPS = Double(frameCount) / timespan
            averageFPS = (averageFPS * 0.9) + (currentFPS * 0.1) // Smoothed average
        }
    }

    /// Measure render time for a block of code
    func measureRenderTime<T>(_ block: () throws -> T) rethrows -> T {
        let start = CACurrentMediaTime()
        let result = try block()
        let end = CACurrentMediaTime()

        renderTime = end - start
        return result
    }

    /// Measure async render time
    func measureRenderTime<T>(_ block: () async throws -> T) async rethrows -> T {
        let start = CACurrentMediaTime()
        let result = try await block()
        let end = CACurrentMediaTime()

        renderTime = end - start
        return result
    }

    /// Get memory usage in bytes
    func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            memoryUsage = info.resident_size
        }
    }

    /// Get formatted memory usage string
    var formattedMemoryUsage: String {
        let bytes = Double(memoryUsage)
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }

    /// Check if performance meets targets
    func checkPerformanceTargets() -> PerformanceStatus {
        var warnings: [String] = []

        // Target: 90 FPS minimum
        if averageFPS < 90 {
            warnings.append("FPS below target: \(Int(averageFPS)) < 90")
        }

        // Target: <4GB memory
        if memoryUsage > 4_000_000_000 {
            warnings.append("Memory usage high: \(formattedMemoryUsage)")
        }

        // Target: <11ms frame time
        if renderTime > 0.011 {
            warnings.append("Frame time too long: \(Int(renderTime * 1000))ms")
        }

        return PerformanceStatus(
            isOptimal: warnings.isEmpty,
            warnings: warnings,
            fps: averageFPS,
            memoryMB: Double(memoryUsage) / 1_000_000
        )
    }
}

// MARK: - Performance Status

struct PerformanceStatus {
    let isOptimal: Bool
    let warnings: [String]
    let fps: Double
    let memoryMB: Double

    var description: String {
        if isOptimal {
            return "✓ Performance Optimal (FPS: \(Int(fps)), Memory: \(Int(memoryMB))MB)"
        } else {
            return "⚠️ Performance Issues:\n" + warnings.joined(separator: "\n")
        }
    }
}

// MARK: - Entity Pool (Object Pooling)

actor EntityPool<T: AnyObject> {
    private var pool: [T] = []
    private let factory: () -> T
    private let maxPoolSize: Int

    init(maxSize: Int = 1000, factory: @escaping () -> T) {
        self.maxPoolSize = maxSize
        self.factory = factory
    }

    /// Acquire an entity from the pool
    func acquire() -> T {
        if let entity = pool.popLast() {
            return entity
        } else {
            return factory()
        }
    }

    /// Release an entity back to the pool
    func release(_ entity: T) {
        guard pool.count < maxPoolSize else { return }
        pool.append(entity)
    }

    /// Clear the pool
    func clear() {
        pool.removeAll()
    }

    /// Get current pool size
    func size() -> Int {
        return pool.count
    }
}

// MARK: - Throttle

/// Throttle function calls to limit execution frequency
actor Throttle {
    private var lastExecutionTime: Date?
    private let minimumInterval: TimeInterval

    init(minimumInterval: TimeInterval) {
        self.minimumInterval = minimumInterval
    }

    /// Execute closure only if enough time has passed
    func execute(_ closure: () async -> Void) async {
        let now = Date()

        if let lastTime = lastExecutionTime {
            let elapsed = now.timeIntervalSince(lastTime)
            if elapsed < minimumInterval {
                return // Skip execution
            }
        }

        lastExecutionTime = now
        await closure()
    }

    /// Reset throttle timer
    func reset() {
        lastExecutionTime = nil
    }
}

// MARK: - Debounce

/// Debounce function calls to delay execution until calls stop
actor Debounce {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    /// Execute closure after delay, canceling previous pending executions
    func execute(_ closure: @escaping () async -> Void) {
        // Cancel previous task
        task?.cancel()

        // Create new task
        task = Task {
            try? await Task.sleep(for: .seconds(delay))

            guard !Task.isCancelled else { return }

            await closure()
        }
    }

    /// Cancel pending execution
    func cancel() {
        task?.cancel()
        task = nil
    }
}

// MARK: - Batch Processor

/// Process items in batches to avoid overwhelming the system
actor BatchProcessor<T> {
    private let batchSize: Int
    private let processingInterval: TimeInterval
    private let processor: ([T]) async throws -> Void

    private var queue: [T] = []
    private var isProcessing = false

    init(
        batchSize: Int,
        processingInterval: TimeInterval = 0.1,
        processor: @escaping ([T]) async throws -> Void
    ) {
        self.batchSize = batchSize
        self.processingInterval = processingInterval
        self.processor = processor
    }

    /// Add item to processing queue
    func add(_ item: T) async throws {
        queue.append(item)

        if queue.count >= batchSize && !isProcessing {
            try await processBatch()
        }
    }

    /// Add multiple items to queue
    func addBatch(_ items: [T]) async throws {
        queue.append(contentsOf: items)

        while queue.count >= batchSize && !isProcessing {
            try await processBatch()
        }
    }

    /// Process a batch
    private func processBatch() async throws {
        guard !queue.isEmpty else { return }

        isProcessing = true
        defer { isProcessing = false }

        let batch = Array(queue.prefix(batchSize))
        queue.removeFirst(min(batchSize, queue.count))

        try await processor(batch)

        // Delay before next batch
        try await Task.sleep(for: .seconds(processingInterval))
    }

    /// Flush remaining items
    func flush() async throws {
        while !queue.isEmpty {
            try await processBatch()
        }
    }

    /// Get queue size
    func queueSize() -> Int {
        return queue.count
    }
}

// MARK: - Performance Profiler

class PerformanceProfiler {
    private var measurements: [String: [TimeInterval]] = [:]

    /// Start measuring an operation
    func start(_ operation: String) -> ProfilerToken {
        return ProfilerToken(profiler: self, operation: operation, startTime: CACurrentMediaTime())
    }

    /// Record measurement
    fileprivate func record(_ operation: String, duration: TimeInterval) {
        if measurements[operation] == nil {
            measurements[operation] = []
        }
        measurements[operation]?.append(duration)

        // Keep only recent measurements
        if let count = measurements[operation]?.count, count > 100 {
            measurements[operation]?.removeFirst()
        }
    }

    /// Get statistics for an operation
    func statistics(for operation: String) -> ProfileStatistics? {
        guard let times = measurements[operation], !times.isEmpty else { return nil }

        let count = times.count
        let total = times.reduce(0, +)
        let average = total / Double(count)
        let min = times.min() ?? 0
        let max = times.max() ?? 0

        return ProfileStatistics(
            operation: operation,
            count: count,
            average: average,
            min: min,
            max: max
        )
    }

    /// Get all statistics
    func allStatistics() -> [ProfileStatistics] {
        return measurements.keys.compactMap { statistics(for: $0) }
    }

    /// Print statistics
    func printStatistics() {
        print("\n=== Performance Profile ===")
        for stat in allStatistics().sorted(by: { $0.average > $1.average }) {
            print(stat.description)
        }
        print("===========================\n")
    }
}

// MARK: - Profiler Token

class ProfilerToken {
    private let profiler: PerformanceProfiler
    private let operation: String
    private let startTime: TimeInterval

    init(profiler: PerformanceProfiler, operation: String, startTime: TimeInterval) {
        self.profiler = profiler
        self.operation = operation
        self.startTime = startTime
    }

    deinit {
        let duration = CACurrentMediaTime() - startTime
        profiler.record(operation, duration: duration)
    }
}

// MARK: - Profile Statistics

struct ProfileStatistics {
    let operation: String
    let count: Int
    let average: TimeInterval
    let min: TimeInterval
    let max: TimeInterval

    var description: String {
        let avgMs = average * 1000
        let minMs = min * 1000
        let maxMs = max * 1000

        return String(format: "%@ - Avg: %.2fms, Min: %.2fms, Max: %.2fms, Count: %d",
                     operation, avgMs, minMs, maxMs, count)
    }
}
