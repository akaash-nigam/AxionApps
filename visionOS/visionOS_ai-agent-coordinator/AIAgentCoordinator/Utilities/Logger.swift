//
//  Logger.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import OSLog

/// Centralized logging utility
enum AppLogger {

    // MARK: - Log Categories

    static let general = Logger(subsystem: "com.aiagentcoordinator", category: "general")
    static let networking = Logger(subsystem: "com.aiagentcoordinator", category: "networking")
    static let database = Logger(subsystem: "com.aiagentcoordinator", category: "database")
    static let ui = Logger(subsystem: "com.aiagentcoordinator", category: "ui")
    static let performance = Logger(subsystem: "com.aiagentcoordinator", category: "performance")
    static let collaboration = Logger(subsystem: "com.aiagentcoordinator", category: "collaboration")

    // MARK: - Convenience Methods

    static func logInfo(_ message: String, category: Logger = general) {
        category.info("\(message)")
    }

    static func logDebug(_ message: String, category: Logger = general) {
        category.debug("\(message)")
    }

    static func logWarning(_ message: String, category: Logger = general) {
        category.warning("\(message)")
    }

    static func logError(_ message: String, error: Error? = nil, category: Logger = general) {
        if let error = error {
            category.error("\(message): \(error.localizedDescription)")
        } else {
            category.error("\(message)")
        }
    }

    static func logFault(_ message: String, category: Logger = general) {
        category.fault("\(message)")
    }

    // MARK: - Performance Logging

    static func measurePerformance(_ operation: String, category: Logger = performance, block: () throws -> Void) rethrows {
        let start = CFAbsoluteTimeGetCurrent()
        try block()
        let duration = CFAbsoluteTimeGetCurrent() - start
        category.info("\(operation) completed in \(String(format: "%.3f", duration))s")
    }

    static func measurePerformanceAsync(_ operation: String, category: Logger = performance, block: () async throws -> Void) async rethrows {
        let start = CFAbsoluteTimeGetCurrent()
        try await block()
        let duration = CFAbsoluteTimeGetCurrent() - start
        category.info("\(operation) completed in \(String(format: "%.3f", duration))s")
    }
}
