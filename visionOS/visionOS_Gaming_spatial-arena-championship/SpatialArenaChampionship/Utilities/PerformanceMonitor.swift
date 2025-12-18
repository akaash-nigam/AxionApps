//
//  PerformanceMonitor.swift
//  Spatial Arena Championship
//
//  Performance tracking and monitoring system
//

import Foundation
import Observation
import os.signpost

// MARK: - Performance Monitor

@Observable
@MainActor
class PerformanceMonitor {
    // MARK: - Properties

    // FPS tracking
    private(set) var currentFPS: Int = 0
    private(set) var averageFPS: Double = 0.0
    private(set) var minFPS: Int = 90
    private(set) var maxFPS: Int = 90

    // Frame time tracking (milliseconds)
    private(set) var currentFrameTime: Double = 0.0
    private(set) var averageFrameTime: Double = 0.0
    private(set) var maxFrameTime: Double = 0.0

    // Memory tracking
    private(set) var memoryUsage: MemoryMetrics = .zero
    private(set) var peakMemoryUsage: UInt64 = 0

    // Thermal state
    private(set) var thermalState: ThermalState = .nominal

    // Performance warnings
    private(set) var activeWarnings: Set<PerformanceWarning> = []

    // Historical data
    private var fpsHistory: [Int] = []
    private var frameTimeHistory: [Double] = []
    private let historySize: Int = 300 // 5 seconds at 60fps

    // Timing
    private var lastFrameTime: TimeInterval = 0
    private var frameCount: Int = 0
    private var lastSampleTime: TimeInterval = 0
    private let sampleInterval: TimeInterval = 1.0

    // Signposts for Instruments
    private let signpostLog = OSLog(subsystem: "com.spatial.arena", category: "Performance")
    private var gameLoopSignpostID: OSSignpostID?

    // Configuration
    private let targetFPS: Int = GameConstants.Performance.targetFPS
    private let targetFrameTime: Double = GameConstants.Performance.targetFrameTime * 1000.0 // Convert to ms

    // State
    var isMonitoring: Bool = false

    // MARK: - Start/Stop

    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        lastFrameTime = currentTime()
        lastSampleTime = currentTime()
        frameCount = 0

        // Reset stats
        resetStats()

        // Start thermal state monitoring
        startThermalStateMonitoring()
    }

    func stopMonitoring() {
        isMonitoring = false
    }

    // MARK: - Frame Update

    func recordFrame() {
        guard isMonitoring else { return }

        let now = currentTime()

        // Calculate frame time
        let frameTime = (now - lastFrameTime) * 1000.0 // Convert to milliseconds
        lastFrameTime = now

        currentFrameTime = frameTime
        frameTimeHistory.append(frameTime)
        if frameTimeHistory.count > historySize {
            frameTimeHistory.removeFirst()
        }

        // Update max frame time
        if frameTime > maxFrameTime {
            maxFrameTime = frameTime
        }

        // Calculate average frame time
        averageFrameTime = frameTimeHistory.reduce(0, +) / Double(frameTimeHistory.count)

        // Increment frame count
        frameCount += 1

        // Sample FPS every second
        if now - lastSampleTime >= sampleInterval {
            let elapsed = now - lastSampleTime
            let fps = Int(Double(frameCount) / elapsed)

            currentFPS = fps
            fpsHistory.append(fps)
            if fpsHistory.count > historySize {
                fpsHistory.removeFirst()
            }

            // Update min/max FPS
            if fps < minFPS {
                minFPS = fps
            }
            if fps > maxFPS {
                maxFPS = fps
            }

            // Calculate average FPS
            averageFPS = Double(fpsHistory.reduce(0, +)) / Double(fpsHistory.count)

            // Reset counters
            frameCount = 0
            lastSampleTime = now

            // Check for performance issues
            checkPerformanceWarnings()
        }

        // Update memory usage periodically
        if frameCount % 60 == 0 {
            updateMemoryMetrics()
        }
    }

    // MARK: - Signpost Integration

    func beginGameLoopSignpost() {
        if gameLoopSignpostID == nil {
            gameLoopSignpostID = OSSignpostID(log: signpostLog)
        }

        if let signpostID = gameLoopSignpostID {
            os_signpost(.begin, log: signpostLog, name: "Game Loop", signpostID: signpostID)
        }
    }

    func endGameLoopSignpost() {
        if let signpostID = gameLoopSignpostID {
            os_signpost(.end, log: signpostLog, name: "Game Loop", signpostID: signpostID)
        }
    }

    func markSignpost(_ name: StaticString) {
        os_signpost(.event, log: signpostLog, name: name)
    }

    // MARK: - Memory Tracking

    private func updateMemoryMetrics() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return }

        let usedMemory = taskInfo.resident_size
        let availableMemory = ProcessInfo.processInfo.physicalMemory

        memoryUsage = MemoryMetrics(
            used: usedMemory,
            available: availableMemory,
            percentage: Double(usedMemory) / Double(availableMemory) * 100.0
        )

        if usedMemory > peakMemoryUsage {
            peakMemoryUsage = usedMemory
        }
    }

    // MARK: - Thermal State Monitoring

    private func startThermalStateMonitoring() {
        NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateThermalState()
        }

        updateThermalState()
    }

    private func updateThermalState() {
        let processInfo = ProcessInfo.processInfo

        thermalState = switch processInfo.thermalState {
        case .nominal:
            .nominal
        case .fair:
            .fair
        case .serious:
            .serious
        case .critical:
            .critical
        @unknown default:
            .nominal
        }
    }

    // MARK: - Performance Warnings

    private func checkPerformanceWarnings() {
        activeWarnings.removeAll()

        // Check FPS
        if currentFPS < targetFPS - 10 {
            activeWarnings.insert(.lowFPS(currentFPS))
        }

        // Check frame time
        if currentFrameTime > targetFrameTime * 1.5 {
            activeWarnings.insert(.highFrameTime(currentFrameTime))
        }

        // Check memory
        if memoryUsage.percentage > 85.0 {
            activeWarnings.insert(.highMemoryUsage(memoryUsage.percentage))
        }

        // Check thermal state
        if thermalState == .serious || thermalState == .critical {
            activeWarnings.insert(.thermalThrottling(thermalState))
        }

        // Check frame time variance
        if frameTimeHistory.count > 10 {
            let variance = calculateVariance(frameTimeHistory)
            if variance > 5.0 {
                activeWarnings.insert(.highFrameTimeVariance(variance))
            }
        }
    }

    // MARK: - Statistics

    func getPerformanceStats() -> PerformanceStats {
        PerformanceStats(
            currentFPS: currentFPS,
            averageFPS: averageFPS,
            minFPS: minFPS,
            maxFPS: maxFPS,
            currentFrameTime: currentFrameTime,
            averageFrameTime: averageFrameTime,
            maxFrameTime: maxFrameTime,
            memoryUsage: memoryUsage,
            peakMemoryUsage: peakMemoryUsage,
            thermalState: thermalState,
            activeWarnings: activeWarnings
        )
    }

    func resetStats() {
        fpsHistory.removeAll()
        frameTimeHistory.removeAll()
        minFPS = 90
        maxFPS = 90
        maxFrameTime = 0.0
        peakMemoryUsage = 0
        activeWarnings.removeAll()
    }

    // MARK: - Performance Report

    func generateReport() -> String {
        var report = "=== PERFORMANCE REPORT ===\n\n"

        report += "FPS Metrics:\n"
        report += "  Current: \(currentFPS) fps\n"
        report += "  Average: \(String(format: "%.1f", averageFPS)) fps\n"
        report += "  Min: \(minFPS) fps\n"
        report += "  Max: \(maxFPS) fps\n"
        report += "  Target: \(targetFPS) fps\n\n"

        report += "Frame Time Metrics:\n"
        report += "  Current: \(String(format: "%.2f", currentFrameTime)) ms\n"
        report += "  Average: \(String(format: "%.2f", averageFrameTime)) ms\n"
        report += "  Max: \(String(format: "%.2f", maxFrameTime)) ms\n"
        report += "  Target: \(String(format: "%.2f", targetFrameTime)) ms\n\n"

        report += "Memory Metrics:\n"
        report += "  Current: \(formatBytes(memoryUsage.used))\n"
        report += "  Peak: \(formatBytes(peakMemoryUsage))\n"
        report += "  Percentage: \(String(format: "%.1f", memoryUsage.percentage))%\n\n"

        report += "Thermal State: \(thermalState.description)\n\n"

        if !activeWarnings.isEmpty {
            report += "Active Warnings:\n"
            for warning in activeWarnings {
                report += "  • \(warning.description)\n"
            }
        } else {
            report += "No active performance warnings\n"
        }

        return report
    }

    // MARK: - Utilities

    private func currentTime() -> TimeInterval {
        return Date().timeIntervalSince1970
    }

    private func calculateVariance(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }

        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return squaredDiffs.reduce(0, +) / Double(values.count)
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let megabytes = Double(bytes) / (1024.0 * 1024.0)
        if megabytes < 1024 {
            return String(format: "%.1f MB", megabytes)
        } else {
            return String(format: "%.2f GB", megabytes / 1024.0)
        }
    }
}

// MARK: - Performance Stats

struct PerformanceStats {
    let currentFPS: Int
    let averageFPS: Double
    let minFPS: Int
    let maxFPS: Int
    let currentFrameTime: Double
    let averageFrameTime: Double
    let maxFrameTime: Double
    let memoryUsage: MemoryMetrics
    let peakMemoryUsage: UInt64
    let thermalState: ThermalState
    let activeWarnings: Set<PerformanceWarning>

    var isPerformanceGood: Bool {
        return currentFPS >= 85 &&
               averageFrameTime < 12.0 &&
               memoryUsage.percentage < 80.0 &&
               thermalState != .critical
    }
}

// MARK: - Memory Metrics

struct MemoryMetrics {
    let used: UInt64
    let available: UInt64
    let percentage: Double

    static let zero = MemoryMetrics(used: 0, available: 0, percentage: 0)
}

// MARK: - Thermal State

enum ThermalState: String {
    case nominal = "Nominal"
    case fair = "Fair"
    case serious = "Serious"
    case critical = "Critical"

    var description: String {
        return rawValue
    }
}

// MARK: - Performance Warning

enum PerformanceWarning: Hashable {
    case lowFPS(Int)
    case highFrameTime(Double)
    case highMemoryUsage(Double)
    case thermalThrottling(ThermalState)
    case highFrameTimeVariance(Double)

    var description: String {
        switch self {
        case .lowFPS(let fps):
            return "Low FPS: \(fps) fps"
        case .highFrameTime(let ms):
            return "High frame time: \(String(format: "%.2f", ms)) ms"
        case .highMemoryUsage(let percent):
            return "High memory usage: \(String(format: "%.1f", percent))%"
        case .thermalThrottling(let state):
            return "Thermal throttling: \(state.description)"
        case .highFrameTimeVariance(let variance):
            return "Frame time variance: \(String(format: "%.2f", variance)) ms"
        }
    }

    var severity: WarningSeverity {
        switch self {
        case .lowFPS(let fps):
            return fps < 60 ? .critical : .warning
        case .highFrameTime(let ms):
            return ms > 20.0 ? .critical : .warning
        case .highMemoryUsage(let percent):
            return percent > 90.0 ? .critical : .warning
        case .thermalThrottling(let state):
            return state == .critical ? .critical : .warning
        case .highFrameTimeVariance:
            return .info
        }
    }
}

enum WarningSeverity {
    case info
    case warning
    case critical
}

// MARK: - Performance Budget

struct PerformanceBudget {
    let targetFPS: Int = 90
    let maxFrameTime: Double = 11.11 // milliseconds
    let maxMemoryUsage: UInt64 = 2 * 1024 * 1024 * 1024 // 2 GB
    let maxEntityCount: Int = 500
    let maxDrawCalls: Int = 100
    let maxTriangles: Int = 500_000

    func validate(stats: PerformanceStats) -> [String] {
        var violations: [String] = []

        if stats.currentFPS < targetFPS - 5 {
            violations.append("FPS below target: \(stats.currentFPS) < \(targetFPS)")
        }

        if stats.currentFrameTime > maxFrameTime {
            violations.append("Frame time exceeds budget: \(String(format: "%.2f", stats.currentFrameTime))ms > \(String(format: "%.2f", maxFrameTime))ms")
        }

        if stats.memoryUsage.used > maxMemoryUsage {
            violations.append("Memory usage exceeds budget: \(stats.memoryUsage.used) > \(maxMemoryUsage)")
        }

        return violations
    }
}
