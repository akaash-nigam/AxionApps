//
//  PerformanceMonitor.swift
//  Reality Realms RPG
//
//  Monitors game performance and dynamically adjusts quality
//

import Foundation
import os.signpost

/// Monitors and optimizes game performance
@MainActor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published private(set) var currentFPS: Double = 0
    @Published private(set) var averageFPS: Double = 0
    @Published private(set) var frameTime: TimeInterval = 0
    @Published private(set) var memoryUsage: UInt64 = 0

    // Performance targets
    private let targetFPS: Double = 90.0
    private let minimumFPS: Double = 72.0
    private let targetFrameTime: TimeInterval = 1.0 / 90.0

    // Tracking
    private var fpsHistory: [Double] = []
    private let historySize = 60  // 1 second at 60fps
    private var lastUpdateTime: Date?
    private var frameCount = 0

    // Quality scaling
    @Published private(set) var resolutionScale: Float = 1.0
    @Published private(set) var qualityLevel: QualityLevel = .high

    // Signposts for Instruments
    private let signposter = OSSignposter()
    private let updateSignpost: OSSignpostID

    enum QualityLevel: String {
        case ultra = "Ultra"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        case performance = "Performance"

        var resolutionScale: Float {
            switch self {
            case .ultra: return 1.0
            case .high: return 0.9
            case .medium: return 0.8
            case .low: return 0.7
            case .performance: return 0.6
            }
        }
    }

    private init() {
        updateSignpost = signposter.makeSignpostID()
        print("📊 PerformanceMonitor initialized")
        startMonitoring()
    }

    // MARK: - Monitoring

    func startMonitoring() {
        // Start periodic checks
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMetrics()
            }
        }
    }

    func recordFrame(deltaTime: TimeInterval) {
        frameCount += 1
        frameTime = deltaTime

        if deltaTime > 0 {
            let fps = 1.0 / deltaTime
            currentFPS = fps

            // Update history
            fpsHistory.append(fps)
            if fpsHistory.count > historySize {
                fpsHistory.removeFirst()
            }

            // Calculate average
            averageFPS = fpsHistory.reduce(0, +) / Double(fpsHistory.count)
        }

        // Check if quality adjustment needed
        if frameCount % 90 == 0 {  // Check every ~1 second
            adjustQualityIfNeeded()
        }
    }

    private func updateMetrics() {
        memoryUsage = getMemoryUsage()

        // Log performance
        if currentFPS < minimumFPS {
            print("⚠️ FPS below minimum: \(String(format: "%.1f", currentFPS)) FPS")
        }
    }

    // MARK: - Quality Adjustment

    private func adjustQualityIfNeeded() {
        guard fpsHistory.count >= historySize else { return }

        let recentAverage = fpsHistory.suffix(30).reduce(0, +) / 30.0

        if recentAverage < targetFPS - 5 {
            // Performance too low, reduce quality
            downgradeQuality()
        } else if recentAverage > targetFPS && qualityLevel != .ultra {
            // Performance good, try increasing quality
            upgradeQuality()
        }
    }

    private func downgradeQuality() {
        let newQuality: QualityLevel

        switch qualityLevel {
        case .ultra:
            newQuality = .high
        case .high:
            newQuality = .medium
        case .medium:
            newQuality = .low
        case .low:
            newQuality = .performance
        case .performance:
            return  // Already at lowest
        }

        setQualityLevel(newQuality)
        print("📉 Quality downgraded to \(newQuality.rawValue) due to performance")
    }

    private func upgradeQuality() {
        let newQuality: QualityLevel

        switch qualityLevel {
        case .ultra:
            return  // Already at highest
        case .high:
            newQuality = .ultra
        case .medium:
            newQuality = .high
        case .low:
            newQuality = .medium
        case .performance:
            newQuality = .low
        }

        setQualityLevel(newQuality)
        print("📈 Quality upgraded to \(newQuality.rawValue)")
    }

    func setQualityLevel(_ level: QualityLevel) {
        qualityLevel = level
        resolutionScale = level.resolutionScale

        // Notify systems of quality change
        NotificationCenter.default.post(
            name: .qualityLevelChanged,
            object: nil,
            userInfo: ["level": level]
        )
    }

    // MARK: - Memory

    private func getMemoryUsage() -> UInt64 {
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
            return info.resident_size
        }

        return 0
    }

    func getMemoryUsageMB() -> Double {
        return Double(memoryUsage) / 1024.0 / 1024.0
    }

    // MARK: - Public Interface

    func beginFrame() {
        signposter.beginInterval("Frame Update", id: updateSignpost)
    }

    func endFrame() {
        signposter.endInterval("Frame Update", id: updateSignpost)
    }

    func logPerformanceStats() {
        print("""
        📊 Performance Stats:
           FPS: \(String(format: "%.1f", currentFPS)) (avg: \(String(format: "%.1f", averageFPS)))
           Frame Time: \(String(format: "%.2f", frameTime * 1000))ms
           Memory: \(String(format: "%.1f", getMemoryUsageMB()))MB
           Quality: \(qualityLevel.rawValue) (\(String(format: "%.0f", resolutionScale * 100))%)
        """)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let qualityLevelChanged = Notification.Name("qualityLevelChanged")
}
