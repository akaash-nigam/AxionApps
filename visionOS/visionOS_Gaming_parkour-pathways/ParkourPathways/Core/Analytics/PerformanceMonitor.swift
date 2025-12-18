//
//  PerformanceMonitor.swift
//  Parkour Pathways
//
//  Real-time performance monitoring and profiling
//

import Foundation
import OSLog
import QuartzCore

/// Monitors application performance metrics
class PerformanceMonitor: ObservableObject {

    // MARK: - Published Properties

    @Published var currentMetrics: PerformanceMetrics = PerformanceMetrics()

    // MARK: - Properties

    private var isMonitoring: Bool = false
    private var userId: UUID?

    private let logger = Logger(subsystem: "com.parkourpathways", category: "Performance")

    // Frame rate tracking
    private var fpssamples: [Double] = []
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0

    // Memory tracking
    private var memoryTimer: Timer?

    // Timing measurements
    private var timingMeasurements: [String: [TimeInterval]] = [:]

    // Configuration
    private let maxSampleCount = 120 // 2 seconds at 60 FPS
    private let memoryCheckInterval: TimeInterval = 1.0

    // MARK: - Initialization

    init() {
        // Setup will happen on start()
    }

    // MARK: - Public API

    /// Set the current user ID
    func setUserId(_ userId: UUID) {
        self.userId = userId
    }

    /// Start performance monitoring
    func start() {
        guard !isMonitoring else { return }
        isMonitoring = true

        startFrameRateMonitoring()
        startMemoryMonitoring()

        logger.info("Performance monitoring started")
    }

    /// Stop performance monitoring
    func stop() {
        guard isMonitoring else { return }
        isMonitoring = false

        stopFrameRateMonitoring()
        stopMemoryMonitoring()

        logger.info("Performance monitoring stopped")
    }

    /// Record a frame rate sample
    func recordFrameRate(_ fps: Double) {
        guard isMonitoring else { return }

        fpssamples.append(fps)

        // Keep only recent samples
        if fpssamples.count > maxSampleCount {
            fpssamples.removeFirst()
        }

        // Update metrics
        updateFPSMetrics()
    }

    /// Record memory usage
    func recordMemoryUsage(_ bytes: Int64) {
        guard isMonitoring else { return }

        let megabytes = Double(bytes) / (1024 * 1024)

        DispatchQueue.main.async {
            self.currentMetrics.memoryUsageMB = megabytes
            self.currentMetrics.peakMemoryMB = max(self.currentMetrics.peakMemoryMB, megabytes)
        }
    }

    /// Record a timing measurement
    func recordTiming(category: String, name: String, duration: TimeInterval) {
        let key = "\(category)_\(name)"

        if timingMeasurements[key] == nil {
            timingMeasurements[key] = []
        }

        timingMeasurements[key]?.append(duration)

        // Keep only recent measurements
        if timingMeasurements[key]?.count ?? 0 > 100 {
            timingMeasurements[key]?.removeFirst()
        }

        // Log slow operations
        if duration > 0.1 { // More than 100ms
            logger.warning("Slow operation: \(key) took \(duration * 1000)ms")
        }
    }

    /// Measure execution time of a block
    func measure<T>(category: String, name: String, block: () throws -> T) rethrows -> T {
        let startTime = CACurrentMediaTime()
        let result = try block()
        let duration = CACurrentMediaTime() - startTime

        recordTiming(category: category, name: name, duration: duration)

        return result
    }

    /// Measure async execution time
    func measureAsync<T>(
        category: String,
        name: String,
        block: () async throws -> T
    ) async rethrows -> T {
        let startTime = CACurrentMediaTime()
        let result = try await block()
        let duration = CACurrentMediaTime() - startTime

        recordTiming(category: category, name: name, duration: duration)

        return result
    }

    /// Get timing statistics for a category
    func getTimingStats(category: String, name: String) -> TimingStats? {
        let key = "\(category)_\(name)"
        guard let measurements = timingMeasurements[key], !measurements.isEmpty else {
            return nil
        }

        let sorted = measurements.sorted()
        let count = measurements.count

        return TimingStats(
            category: category,
            name: name,
            count: count,
            average: measurements.reduce(0, +) / Double(count),
            min: sorted.first ?? 0,
            max: sorted.last ?? 0,
            p50: sorted[count / 2],
            p95: sorted[Int(Double(count) * 0.95)],
            p99: sorted[Int(Double(count) * 0.99)]
        )
    }

    /// Flush all metrics
    func flush() {
        // Send aggregated metrics to analytics
        let report = generatePerformanceReport()
        logger.info("Performance Report: \(report)")

        // Could send to analytics endpoint here
    }

    // MARK: - Private Frame Rate Monitoring

    private func startFrameRateMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopFrameRateMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkCallback(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp

        if lastFrameTime > 0 {
            let frameDuration = currentTime - lastFrameTime
            let fps = 1.0 / frameDuration

            recordFrameRate(fps)
        }

        lastFrameTime = currentTime
    }

    private func updateFPSMetrics() {
        guard !fpssamples.isEmpty else { return }

        let average = fpssamples.reduce(0, +) / Double(fpssamples.count)
        let min = fpssamples.min() ?? 0
        let max = fpssamples.max() ?? 0

        DispatchQueue.main.async {
            self.currentMetrics.averageFPS = average
            self.currentMetrics.minFPS = min
            self.currentMetrics.maxFPS = max
        }
    }

    // MARK: - Private Memory Monitoring

    private func startMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: memoryCheckInterval, repeats: true) { [weak self] _ in
            self?.checkMemoryUsage()
        }
    }

    private func stopMemoryMonitoring() {
        memoryTimer?.invalidate()
        memoryTimer = nil
    }

    private func checkMemoryUsage() {
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

        if kerr == KERN_SUCCESS {
            let memoryBytes = Int64(info.resident_size)
            recordMemoryUsage(memoryBytes)
        }

        // Also check CPU usage
        checkCPUUsage()
    }

    private func checkCPUUsage() {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0

        guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS,
              let threads = threadList else {
            return
        }

        var totalCPU: Double = 0

        for i in 0..<Int(threadCount) {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)

            let kr = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(
                        threads[i],
                        thread_flavor_t(THREAD_BASIC_INFO),
                        $0,
                        &threadInfoCount
                    )
                }
            }

            if kr == KERN_SUCCESS {
                if threadInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalCPU += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
        }

        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(threadCount))

        DispatchQueue.main.async {
            self.currentMetrics.cpuUsagePercent = totalCPU
        }
    }

    // MARK: - Private Reporting

    private func generatePerformanceReport() -> String {
        var report = "Performance Report:\n"
        report += "  FPS: avg=\(String(format: "%.1f", currentMetrics.averageFPS)), "
        report += "min=\(String(format: "%.1f", currentMetrics.minFPS)), "
        report += "max=\(String(format: "%.1f", currentMetrics.maxFPS))\n"
        report += "  Memory: \(String(format: "%.1f", currentMetrics.memoryUsageMB)) MB "
        report += "(peak: \(String(format: "%.1f", currentMetrics.peakMemoryMB)) MB)\n"
        report += "  CPU: \(String(format: "%.1f", currentMetrics.cpuUsagePercent))%\n"

        // Add timing stats
        for (key, _) in timingMeasurements {
            if let stats = getTimingStats(category: "", name: key) {
                report += "  \(key): avg=\(String(format: "%.2f", stats.average * 1000))ms, "
                report += "p95=\(String(format: "%.2f", stats.p95 * 1000))ms\n"
            }
        }

        return report
    }
}

// MARK: - Supporting Types

struct TimingStats {
    let category: String
    let name: String
    let count: Int
    let average: TimeInterval
    let min: TimeInterval
    let max: TimeInterval
    let p50: TimeInterval // Median
    let p95: TimeInterval
    let p99: TimeInterval
}
