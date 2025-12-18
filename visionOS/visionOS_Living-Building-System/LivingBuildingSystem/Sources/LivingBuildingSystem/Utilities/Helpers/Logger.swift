import Foundation
import os.log

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case critical
}

final class Logger {
    static let shared = Logger()

    private let subsystem = "com.lbs.app"

    private init() {}

    func log(
        _ message: String,
        level: LogLevel = .info,
        error: Error? = nil,
        category: String = "General",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let osLog = OSLog(subsystem: subsystem, category: category)

        var logMessage = "[\(filename):\(line)] \(function) - \(message)"

        if let error = error {
            logMessage += " Error: \(error.localizedDescription)"
        }

        switch level {
        case .debug:
            os_log(.debug, log: osLog, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: osLog, "%{public}@", logMessage)
        case .warning:
            os_log(.default, log: osLog, "%{public}@", logMessage)
        case .error:
            os_log(.error, log: osLog, "%{public}@", logMessage)
        case .critical:
            os_log(.fault, log: osLog, "%{public}@", logMessage)
        }
    }
}
