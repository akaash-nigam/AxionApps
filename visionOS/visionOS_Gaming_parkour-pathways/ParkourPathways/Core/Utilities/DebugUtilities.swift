//
//  DebugUtilities.swift
//  Parkour Pathways
//
//  Debug tools and development utilities
//

import Foundation
import SwiftUI
import OSLog

/// Debug utilities and development tools
class DebugUtilities {

    // MARK: - Singleton

    static let shared = DebugUtilities()

    // MARK: - Properties

    private let logger = Logger(subsystem: "com.parkourpathways", category: "Debug")
    private var isDebugMode: Bool = false

    // Debug overlays
    private var showFPSOverlay: Bool = false
    private var showMemoryOverlay: Bool = false
    private var showPhysicsDebug: Bool = false
    private var showCollisionDebug: Bool = false

    // Command history
    private var commandHistory: [String] = []
    private let maxHistorySize = 100

    // MARK: - Initialization

    private init() {
        #if DEBUG
        isDebugMode = true
        #endif
    }

    // MARK: - Public API - Debug Mode

    /// Check if running in debug mode
    func isDebugBuild() -> Bool {
        return isDebugMode
    }

    /// Enable debug overlays
    func setDebugOverlaysEnabled(_ enabled: Bool) {
        showFPSOverlay = enabled
        showMemoryOverlay = enabled
        logger.info("Debug overlays \(enabled ? "enabled" : "disabled")")
    }

    // MARK: - Public API - Logging

    /// Log debug message
    func log(_ message: String, level: LogLevel = .debug) {
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
    }

    /// Log with category
    func log(_ message: String, category: String, level: LogLevel = .debug) {
        let categoryLogger = Logger(subsystem: "com.parkourpathways", category: category)
        switch level {
        case .debug:
            categoryLogger.debug("\(message)")
        case .info:
            categoryLogger.info("\(message)")
        case .warning:
            categoryLogger.warning("\(message)")
        case .error:
            categoryLogger.error("\(message)")
        case .critical:
            categoryLogger.critical("\(message)")
        }
    }

    /// Log performance metric
    func logPerformance(_ operation: String, duration: TimeInterval) {
        logger.debug("⏱️ \(operation): \(String(format: "%.2f", duration * 1000))ms")
    }

    /// Log memory allocation
    func logMemory(_ label: String, bytes: Int) {
        let mb = Double(bytes) / (1024 * 1024)
        logger.debug("💾 \(label): \(String(format: "%.2f", mb)) MB")
    }

    // MARK: - Public API - Debug Commands

    /// Execute debug command
    func executeCommand(_ command: String) -> String {
        commandHistory.append(command)
        if commandHistory.count > maxHistorySize {
            commandHistory.removeFirst()
        }

        let parts = command.split(separator: " ").map { String($0) }
        guard let cmd = parts.first else {
            return "Error: Empty command"
        }

        let args = Array(parts.dropFirst())

        switch cmd.lowercased() {
        case "help":
            return getHelpText()

        case "fps":
            return toggleFPSOverlay()

        case "memory":
            return toggleMemoryOverlay()

        case "physics":
            return togglePhysicsDebug()

        case "collision":
            return toggleCollisionDebug()

        case "teleport":
            return handleTeleportCommand(args)

        case "spawn":
            return handleSpawnCommand(args)

        case "god":
            return toggleGodMode()

        case "noclip":
            return toggleNoClip()

        case "speed":
            return handleSpeedCommand(args)

        case "reset":
            return handleResetCommand()

        case "save":
            return handleSaveCommand()

        case "load":
            return handleLoadCommand()

        case "dump":
            return handleDumpCommand(args)

        default:
            return "Unknown command: \(cmd). Type 'help' for available commands."
        }
    }

    /// Get command history
    func getCommandHistory() -> [String] {
        return commandHistory
    }

    // MARK: - Public API - Debug Visualization

    /// Get FPS overlay view
    func getFPSOverlay() -> some View {
        if showFPSOverlay {
            return AnyView(FPSOverlayView())
        } else {
            return AnyView(EmptyView())
        }
    }

    /// Get memory overlay view
    func getMemoryOverlay() -> some View {
        if showMemoryOverlay {
            return AnyView(MemoryOverlayView())
        } else {
            return AnyView(EmptyView())
        }
    }

    // MARK: - Public API - Debug Helpers

    /// Measure execution time
    func measure(_ label: String, block: () throws -> Void) rethrows {
        let start = CACurrentMediaTime()
        try block()
        let duration = CACurrentMediaTime() - start
        logPerformance(label, duration: duration)
    }

    /// Measure async execution time
    func measureAsync(_ label: String, block: () async throws -> Void) async rethrows {
        let start = CACurrentMediaTime()
        try await block()
        let duration = CACurrentMediaTime() - start
        logPerformance(label, duration: duration)
    }

    /// Assert in debug builds only
    func debugAssert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
        #if DEBUG
        assert(condition(), message)
        #endif
    }

    /// Print object description
    func dump(_ object: Any, name: String = "") {
        #if DEBUG
        print("=== \(name.isEmpty ? "Debug Dump" : name) ===")
        Swift.dump(object)
        print("=========================")
        #endif
    }

    // MARK: - Private Command Handlers

    private func getHelpText() -> String {
        return """
        Available Debug Commands:
        - help: Show this help text
        - fps: Toggle FPS overlay
        - memory: Toggle memory overlay
        - physics: Toggle physics debug visualization
        - collision: Toggle collision debug visualization
        - teleport <x> <y> <z>: Teleport player to position
        - spawn <obstacle> [count]: Spawn obstacles
        - god: Toggle god mode (invincibility)
        - noclip: Toggle no-clip mode
        - speed <multiplier>: Set movement speed multiplier
        - reset: Reset current course
        - save: Save current game state
        - load: Load saved game state
        - dump <type>: Dump debug information
        """
    }

    private func toggleFPSOverlay() -> String {
        showFPSOverlay.toggle()
        return "FPS overlay: \(showFPSOverlay ? "ON" : "OFF")"
    }

    private func toggleMemoryOverlay() -> String {
        showMemoryOverlay.toggle()
        return "Memory overlay: \(showMemoryOverlay ? "ON" : "OFF")"
    }

    private func togglePhysicsDebug() -> String {
        showPhysicsDebug.toggle()
        return "Physics debug: \(showPhysicsDebug ? "ON" : "OFF")"
    }

    private func toggleCollisionDebug() -> String {
        showCollisionDebug.toggle()
        return "Collision debug: \(showCollisionDebug ? "ON" : "OFF")"
    }

    private func handleTeleportCommand(_ args: [String]) -> String {
        guard args.count == 3,
              let x = Float(args[0]),
              let y = Float(args[1]),
              let z = Float(args[2]) else {
            return "Usage: teleport <x> <y> <z>"
        }

        // Would trigger teleport in game
        logger.info("Teleporting to: (\(x), \(y), \(z))")
        return "Teleported to: (\(x), \(y), \(z))"
    }

    private func handleSpawnCommand(_ args: [String]) -> String {
        guard !args.isEmpty else {
            return "Usage: spawn <obstacle> [count]"
        }

        let obstacleType = args[0]
        let count = args.count > 1 ? Int(args[1]) ?? 1 : 1

        logger.info("Spawning \(count)x \(obstacleType)")
        return "Spawned \(count)x \(obstacleType)"
    }

    private func toggleGodMode() -> String {
        // Would toggle god mode in game
        logger.info("God mode toggled")
        return "God mode toggled"
    }

    private func toggleNoClip() -> String {
        // Would toggle no-clip in game
        logger.info("No-clip mode toggled")
        return "No-clip mode toggled"
    }

    private func handleSpeedCommand(_ args: [String]) -> String {
        guard args.count == 1, let multiplier = Float(args[0]) else {
            return "Usage: speed <multiplier>"
        }

        logger.info("Speed multiplier set to: \(multiplier)")
        return "Speed multiplier: \(multiplier)x"
    }

    private func handleResetCommand() -> String {
        logger.info("Resetting course")
        return "Course reset"
    }

    private func handleSaveCommand() -> String {
        logger.info("Saving game state")
        return "Game state saved"
    }

    private func handleLoadCommand() -> String {
        logger.info("Loading game state")
        return "Game state loaded"
    }

    private func handleDumpCommand(_ args: [String]) -> String {
        guard !args.isEmpty else {
            return "Usage: dump <type> (types: stats, cache, performance)"
        }

        let dumpType = args[0].lowercased()

        switch dumpType {
        case "stats":
            return dumpStats()
        case "cache":
            return dumpCache()
        case "performance":
            return dumpPerformance()
        default:
            return "Unknown dump type: \(dumpType)"
        }
    }

    private func dumpStats() -> String {
        return """
        === Game Statistics ===
        FPS Overlay: \(showFPSOverlay)
        Memory Overlay: \(showMemoryOverlay)
        Physics Debug: \(showPhysicsDebug)
        Collision Debug: \(showCollisionDebug)
        Command History: \(commandHistory.count) commands
        """
    }

    private func dumpCache() -> String {
        let stats = MemoryOptimizer.shared.getCacheStats()
        return """
        === Cache Statistics ===
        Items: \(stats.itemCount)
        Size: \(stats.totalSize / (1024 * 1024)) MB / \(stats.maxSize / (1024 * 1024)) MB
        Utilization: \(String(format: "%.1f", stats.utilizationPercent))%
        """
    }

    private func dumpPerformance() -> String {
        let memory = MemoryOptimizer.shared.getCurrentMemoryUsage()
        return """
        === Performance Stats ===
        Memory Usage: \(memory / (1024 * 1024)) MB
        Available Memory: \(MemoryOptimizer.shared.getAvailableMemory() / (1024 * 1024)) MB
        Memory Pressure: \(MemoryOptimizer.shared.getMemoryPressure())
        """
    }
}

// MARK: - Supporting Types

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case critical
}

// MARK: - Debug Overlay Views

struct FPSOverlayView: View {
    @State private var fps: Double = 0

    var body: some View {
        VStack {
            Text("FPS: \(Int(fps))")
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.green)
                .cornerRadius(8)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

struct MemoryOverlayView: View {
    @State private var memoryMB: Double = 0

    var body: some View {
        VStack {
            Spacer()
            Text("MEM: \(Int(memoryMB)) MB")
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.orange)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
