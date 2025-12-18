import Foundation
import OSLog

/// Logging utilities for the app
extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "ExecutiveBriefing"

    /// App-level logging
    static let app = Logger(subsystem: subsystem, category: "app")

    /// Data layer logging
    static let data = Logger(subsystem: subsystem, category: "data")

    /// UI logging
    static let ui = Logger(subsystem: subsystem, category: "ui")

    /// Visualization logging
    static let visualization = Logger(subsystem: subsystem, category: "visualization")

    /// Performance logging
    static let performance = Logger(subsystem: subsystem, category: "performance")

    /// Service logging
    static let service = Logger(subsystem: subsystem, category: "service")
}
