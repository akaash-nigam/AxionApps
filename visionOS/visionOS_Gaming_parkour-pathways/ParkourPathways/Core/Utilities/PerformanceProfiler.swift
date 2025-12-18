//
//  PerformanceProfiler.swift
//  Parkour Pathways
//
//  Advanced performance profiling and optimization tools
//

import Foundation
import OSLog
import QuartzCore

/// Advanced performance profiling with frame time analysis
class PerformanceProfiler {

    // MARK: - Properties

    private var isEnabled: Bool = false
    private let logger = Logger(subsystem: "com.parkourpathways", category: "Profiler")

    // Frame timing
    private var frameTimings: [FrameTiming] = []
    private var currentFrameStart: CFTimeInterval = 0

    // CPU profiling
    private var profilePoints: [String: ProfilePoint] = [:]

    // Memory profiling
    private var allocationTracking: [String: AllocationInfo] = [:]

    // Configuration
    private let maxFrameTimings = 600 // 10 seconds at 60 FPS
    private let frameBudget: TimeInterval = 1.0 / 90.0 // 11.1ms for 90 FPS

    // MARK: - Initialization

    init() {
        #if DEBUG
        isEnabled = true
        #endif
    }

    // MARK: - Public API - Frame Profiling

    /// Begin a new frame
    func beginFrame() {
        guard isEnabled else { return }
        currentFrameStart = CACurrentMediaTime()
    }

    /// End current frame and record timing
    func endFrame() {
        guard isEnabled else { return }

        let frameDuration = CACurrentMediaTime() - currentFrameStart

        let timing = FrameTiming(
            duration: frameDuration,
            timestamp: Date(),
            isOverBudget: frameDuration > frameBudget
        )

        frameTimings.append(timing)

        // Keep only recent timings
        if frameTimings.count > maxFrameTimings {
            frameTimings.removeFirst()
        }

        // Log slow frames
        if timing.isOverBudget {
            logger.warning("Slow frame: \(frameDuration * 1000)ms (budget: \(frameBudget * 1000)ms)")
        }
    }

    /// Get frame timing statistics
    func getFrameStats() -> FrameStats {
        guard !frameTimings.isEmpty else {
            return FrameStats(
                averageDuration: 0,
                minDuration: 0,
                maxDuration: 0,
                p95Duration: 0,
                p99Duration: 0,
                framesOverBudget: 0,
                totalFrames: 0
            )
        }

        let sorted = frameTimings.map { $0.duration }.sorted()
        let count = sorted.count

        return FrameStats(
            averageDuration: sorted.reduce(0, +) / Double(count),
            minDuration: sorted.first ?? 0,
            maxDuration: sorted.last ?? 0,
            p95Duration: sorted[Int(Double(count) * 0.95)],
            p99Duration: sorted[Int(Double(count) * 0.99)],
            framesOverBudget: frameTimings.filter { $0.isOverBudget }.count,
            totalFrames: count
        )
    }

    // MARK: - Public API - CPU Profiling

    /// Begin profiling a code section
    func beginProfile(_ name: String) {
        guard isEnabled else { return }

        if profilePoints[name] == nil {
            profilePoints[name] = ProfilePoint(name: name)
        }

        profilePoints[name]?.begin()
    }

    /// End profiling a code section
    func endProfile(_ name: String) {
        guard isEnabled else { return }
        profilePoints[name]?.end()
    }

    /// Profile a synchronous block
    func profile<T>(_ name: String, block: () throws -> T) rethrows -> T {
        beginProfile(name)
        defer { endProfile(name) }
        return try block()
    }

    /// Profile an async block
    func profileAsync<T>(_ name: String, block: () async throws -> T) async rethrows -> T {
        beginProfile(name)
        defer { endProfile(name) }
        return try await block()
    }

    /// Get profiling statistics
    func getProfileStats(_ name: String) -> ProfileStats? {
        return profilePoints[name]?.getStats()
    }

    /// Get all profile points
    func getAllProfileStats() -> [ProfileStats] {
        return profilePoints.values.map { $0.getStats() }.sorted { $0.totalTime > $1.totalTime }
    }

    // MARK: - Public API - Memory Profiling

    /// Track allocation
    func trackAllocation(_ name: String, size: Int) {
        guard isEnabled else { return }

        if allocationTracking[name] == nil {
            allocationTracking[name] = AllocationInfo(name: name)
        }

        allocationTracking[name]?.recordAllocation(size: size)
    }

    /// Track deallocation
    func trackDeallocation(_ name: String, size: Int) {
        guard isEnabled else { return }
        allocationTracking[name]?.recordDeallocation(size: size)
    }

    /// Get memory statistics
    func getMemoryStats(_ name: String) -> MemoryStats? {
        return allocationTracking[name]?.getStats()
    }

    /// Get all memory statistics
    func getAllMemoryStats() -> [MemoryStats] {
        return allocationTracking.values.map { $0.getStats() }.sorted { $0.currentBytes > $1.currentBytes }
    }

    // MARK: - Public API - Reporting

    /// Generate a comprehensive performance report
    func generateReport() -> String {
        var report = "=== PERFORMANCE PROFILE REPORT ===\n\n"

        // Frame timing stats
        let frameStats = getFrameStats()
        report += "Frame Timing:\n"
        report += "  Average: \(String(format: "%.2f", frameStats.averageDuration * 1000))ms\n"
        report += "  Min: \(String(format: "%.2f", frameStats.minDuration * 1000))ms\n"
        report += "  Max: \(String(format: "%.2f", frameStats.maxDuration * 1000))ms\n"
        report += "  P95: \(String(format: "%.2f", frameStats.p95Duration * 1000))ms\n"
        report += "  P99: \(String(format: "%.2f", frameStats.p99Duration * 1000))ms\n"
        report += "  Frames over budget: \(frameStats.framesOverBudget)/\(frameStats.totalFrames)\n\n"

        // CPU profiling stats
        report += "CPU Profiling (top 10):\n"
        let topCPU = getAllProfileStats().prefix(10)
        for stat in topCPU {
            report += "  \(stat.name): "
            report += "avg=\(String(format: "%.2f", stat.averageTime * 1000))ms, "
            report += "total=\(String(format: "%.2f", stat.totalTime * 1000))ms, "
            report += "calls=\(stat.callCount)\n"
        }
        report += "\n"

        // Memory profiling stats
        report += "Memory Tracking (top 10):\n"
        let topMemory = getAllMemoryStats().prefix(10)
        for stat in topMemory {
            report += "  \(stat.name): "
            report += "current=\(formatBytes(stat.currentBytes)), "
            report += "peak=\(formatBytes(stat.peakBytes)), "
            report += "allocations=\(stat.allocationCount)\n"
        }

        report += "\n=== END REPORT ===\n"

        return report
    }

    /// Print report to console
    func printReport() {
        print(generateReport())
    }

    /// Clear all profiling data
    func reset() {
        frameTimings.removeAll()
        profilePoints.removeAll()
        allocationTracking.removeAll()
        logger.info("Profiler reset")
    }

    // MARK: - Private Helpers

    private func formatBytes(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024
        let mb = kb / 1024
        let gb = mb / 1024

        if gb >= 1 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(bytes) bytes"
        }
    }
}

// MARK: - Supporting Types

struct FrameTiming {
    let duration: TimeInterval
    let timestamp: Date
    let isOverBudget: Bool
}

struct FrameStats {
    let averageDuration: TimeInterval
    let minDuration: TimeInterval
    let maxDuration: TimeInterval
    let p95Duration: TimeInterval
    let p99Duration: TimeInterval
    let framesOverBudget: Int
    let totalFrames: Int
}

class ProfilePoint {
    let name: String
    private var startTime: CFTimeInterval = 0
    private var timings: [TimeInterval] = []
    private var isActive: Bool = false

    init(name: String) {
        self.name = name
    }

    func begin() {
        guard !isActive else { return }
        startTime = CACurrentMediaTime()
        isActive = true
    }

    func end() {
        guard isActive else { return }
        let duration = CACurrentMediaTime() - startTime
        timings.append(duration)
        isActive = false

        // Keep only recent timings
        if timings.count > 1000 {
            timings.removeFirst()
        }
    }

    func getStats() -> ProfileStats {
        guard !timings.isEmpty else {
            return ProfileStats(
                name: name,
                callCount: 0,
                totalTime: 0,
                averageTime: 0,
                minTime: 0,
                maxTime: 0
            )
        }

        let sorted = timings.sorted()
        let total = timings.reduce(0, +)

        return ProfileStats(
            name: name,
            callCount: timings.count,
            totalTime: total,
            averageTime: total / Double(timings.count),
            minTime: sorted.first ?? 0,
            maxTime: sorted.last ?? 0
        )
    }
}

struct ProfileStats {
    let name: String
    let callCount: Int
    let totalTime: TimeInterval
    let averageTime: TimeInterval
    let minTime: TimeInterval
    let maxTime: TimeInterval
}

class AllocationInfo {
    let name: String
    private var allocationCount: Int = 0
    private var deallocationCount: Int = 0
    private var currentBytes: Int = 0
    private var peakBytes: Int = 0

    init(name: String) {
        self.name = name
    }

    func recordAllocation(size: Int) {
        allocationCount += 1
        currentBytes += size
        peakBytes = max(peakBytes, currentBytes)
    }

    func recordDeallocation(size: Int) {
        deallocationCount += 1
        currentBytes -= size
    }

    func getStats() -> MemoryStats {
        return MemoryStats(
            name: name,
            allocationCount: allocationCount,
            deallocationCount: deallocationCount,
            currentBytes: currentBytes,
            peakBytes: peakBytes
        )
    }
}

struct MemoryStats {
    let name: String
    let allocationCount: Int
    let deallocationCount: Int
    let currentBytes: Int
    let peakBytes: Int
}
