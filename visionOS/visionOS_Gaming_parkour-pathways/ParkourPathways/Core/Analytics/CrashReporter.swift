//
//  CrashReporter.swift
//  Parkour Pathways
//
//  Crash reporting and error tracking system
//

import Foundation
import OSLog

/// Handles crash reporting and error tracking
class CrashReporter {

    // MARK: - Properties

    private var userId: UUID?
    private var customKeys: [String: String] = [:]
    private var breadcrumbs: [Breadcrumb] = []

    private let logger = Logger(subsystem: "com.parkourpathways", category: "CrashReporting")
    private let queue = DispatchQueue(label: "com.parkourpathways.crashreporter", qos: .utility)

    // Configuration
    private let maxBreadcrumbs = 100
    private let endpoint = "https://crashes.parkourpathways.app/v1/reports"

    // MARK: - Initialization

    init() {
        setupCrashHandler()
        setupSignalHandlers()
        loadPendingReports()
    }

    // MARK: - Public API

    /// Set the current user ID
    func setUserId(_ userId: UUID) {
        self.userId = userId
    }

    /// Set custom key-value pair for crash context
    func setCustomKey(_ key: String, value: String) {
        queue.async {
            self.customKeys[key] = value
        }
    }

    /// Report an error
    func reportError(
        _ error: Error,
        context: [String: Any],
        userId: UUID?,
        sessionId: UUID
    ) {
        let errorReport = ErrorReport(
            errorType: String(describing: type(of: error)),
            errorMessage: error.localizedDescription,
            errorDomain: (error as NSError).domain,
            errorCode: (error as NSError).code,
            context: context,
            customKeys: customKeys,
            breadcrumbs: breadcrumbs,
            userId: userId ?? self.userId,
            sessionId: sessionId,
            timestamp: Date(),
            stackTrace: Thread.callStackSymbols
        )

        sendErrorReport(errorReport)
        addBreadcrumb("Error: \(error.localizedDescription)", type: .error)

        logger.error("Error reported: \(error.localizedDescription)")
    }

    /// Report a non-fatal issue
    func reportIssue(
        message: String,
        severity: IssueSeverity,
        context: [String: Any],
        userId: UUID?,
        sessionId: UUID
    ) {
        let issue = IssueReport(
            message: message,
            severity: severity,
            context: context,
            customKeys: customKeys,
            breadcrumbs: breadcrumbs,
            userId: userId ?? self.userId,
            sessionId: sessionId,
            timestamp: Date(),
            stackTrace: Thread.callStackSymbols
        )

        sendIssueReport(issue)
        addBreadcrumb("Issue: \(message)", type: .log)

        switch severity {
        case .debug, .info:
            logger.info("Issue reported: \(message)")
        case .warning:
            logger.warning("Issue reported: \(message)")
        case .error, .critical:
            logger.error("Issue reported: \(message)")
        }
    }

    /// Add a breadcrumb for debugging
    func addBreadcrumb(_ message: String, type: BreadcrumbType = .log, metadata: [String: String] = [:]) {
        let breadcrumb = Breadcrumb(
            message: message,
            type: type,
            metadata: metadata,
            timestamp: Date()
        )

        queue.async {
            self.breadcrumbs.append(breadcrumb)

            // Keep only recent breadcrumbs
            if self.breadcrumbs.count > self.maxBreadcrumbs {
                self.breadcrumbs.removeFirst()
            }
        }
    }

    /// Flush pending reports
    func flush() {
        // Send any pending reports
        logger.info("Flushing crash reports")
    }

    // MARK: - Private Setup

    private func setupCrashHandler() {
        // Setup NSException handler
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.handleException(exception)
        }
    }

    private func setupSignalHandlers() {
        // Setup signal handlers for crashes
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE]

        for signal in signals {
            signal(signal) { signal in
                CrashReporter.handleSignal(signal)
            }
        }
    }

    private static func handleException(_ exception: NSException) {
        let logger = Logger(subsystem: "com.parkourpathways", category: "CrashReporting")
        logger.critical("Uncaught exception: \(exception.name.rawValue) - \(exception.reason ?? "Unknown")")

        // Create crash report
        let crashReport = CrashReport(
            crashType: "NSException",
            reason: exception.reason ?? "Unknown",
            name: exception.name.rawValue,
            stackTrace: exception.callStackSymbols,
            userInfo: exception.userInfo ?? [:],
            timestamp: Date()
        )

        // Save to disk for next launch
        saveCrashReport(crashReport)
    }

    private static func handleSignal(_ signal: Int32) {
        let logger = Logger(subsystem: "com.parkourpathways", category: "CrashReporting")
        let signalName = signalName(for: signal)
        logger.critical("Signal received: \(signalName)")

        // Create crash report
        let crashReport = CrashReport(
            crashType: "Signal",
            reason: signalName,
            name: signalName,
            stackTrace: Thread.callStackSymbols,
            userInfo: [:],
            timestamp: Date()
        )

        // Save to disk
        saveCrashReport(crashReport)

        // Re-raise signal to allow system handler to run
        Darwin.signal(signal, SIG_DFL)
        raise(signal)
    }

    private static func signalName(for signal: Int32) -> String {
        switch signal {
        case SIGABRT: return "SIGABRT"
        case SIGILL: return "SIGILL"
        case SIGSEGV: return "SIGSEGV"
        case SIGFPE: return "SIGFPE"
        case SIGBUS: return "SIGBUS"
        case SIGPIPE: return "SIGPIPE"
        default: return "UNKNOWN_SIGNAL_\(signal)"
        }
    }

    private static func saveCrashReport(_ report: CrashReport) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(report)

            let fileURL = getCrashReportURL()
            try data.write(to: fileURL)
        } catch {
            print("Failed to save crash report: \(error)")
        }
    }

    private static func getCrashReportURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("crash_report.json")
    }

    private func loadPendingReports() {
        queue.async {
            let fileURL = Self.getCrashReportURL()

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return
            }

            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let crashReport = try decoder.decode(CrashReport.self, from: data)

                // Send crash report
                self.sendCrashReport(crashReport)

                // Delete file
                try FileManager.default.removeItem(at: fileURL)

                self.logger.info("Sent pending crash report")
            } catch {
                self.logger.error("Failed to load pending crash report: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Sending

    private func sendErrorReport(_ report: ErrorReport) {
        Task {
            await sendReport(report, type: "error")
        }
    }

    private func sendIssueReport(_ report: IssueReport) {
        Task {
            await sendReport(report, type: "issue")
        }
    }

    private func sendCrashReport(_ report: CrashReport) {
        Task {
            await sendReport(report, type: "crash")
        }
    }

    private func sendReport<T: Encodable>(_ report: T, type: String) async {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(report)

            guard let url = URL(string: endpoint) else {
                logger.error("Invalid crash reporting endpoint")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("visionOS/1.0", forHTTPHeaderField: "User-Agent")
            request.setValue(type, forHTTPHeaderField: "X-Report-Type")
            request.httpBody = data

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    logger.info("Successfully sent \(type) report")
                } else {
                    logger.error("Failed to send \(type) report: HTTP \(httpResponse.statusCode)")
                }
            }

        } catch {
            logger.error("Error sending \(type) report: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Types

struct ErrorReport: Codable {
    let errorType: String
    let errorMessage: String
    let errorDomain: String
    let errorCode: Int
    let context: [String: String]
    let customKeys: [String: String]
    let breadcrumbs: [Breadcrumb]
    let userId: UUID?
    let sessionId: UUID
    let timestamp: Date
    let stackTrace: [String]

    init(
        errorType: String,
        errorMessage: String,
        errorDomain: String,
        errorCode: Int,
        context: [String: Any],
        customKeys: [String: String],
        breadcrumbs: [Breadcrumb],
        userId: UUID?,
        sessionId: UUID,
        timestamp: Date,
        stackTrace: [String]
    ) {
        self.errorType = errorType
        self.errorMessage = errorMessage
        self.errorDomain = errorDomain
        self.errorCode = errorCode
        self.context = context.mapValues { "\($0)" }
        self.customKeys = customKeys
        self.breadcrumbs = breadcrumbs
        self.userId = userId
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.stackTrace = stackTrace
    }
}

struct IssueReport: Codable {
    let message: String
    let severity: IssueSeverity
    let context: [String: String]
    let customKeys: [String: String]
    let breadcrumbs: [Breadcrumb]
    let userId: UUID?
    let sessionId: UUID
    let timestamp: Date
    let stackTrace: [String]

    init(
        message: String,
        severity: IssueSeverity,
        context: [String: Any],
        customKeys: [String: String],
        breadcrumbs: [Breadcrumb],
        userId: UUID?,
        sessionId: UUID,
        timestamp: Date,
        stackTrace: [String]
    ) {
        self.message = message
        self.severity = severity
        self.context = context.mapValues { "\($0)" }
        self.customKeys = customKeys
        self.breadcrumbs = breadcrumbs
        self.userId = userId
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.stackTrace = stackTrace
    }
}

struct CrashReport: Codable {
    let crashType: String
    let reason: String
    let name: String
    let stackTrace: [String]
    let userInfo: [String: String]
    let timestamp: Date

    init(
        crashType: String,
        reason: String,
        name: String,
        stackTrace: [String],
        userInfo: [AnyHashable: Any],
        timestamp: Date
    ) {
        self.crashType = crashType
        self.reason = reason
        self.name = name
        self.stackTrace = stackTrace
        self.userInfo = userInfo.reduce(into: [:]) { result, pair in
            result["\(pair.key)"] = "\(pair.value)"
        }
        self.timestamp = timestamp
    }
}

struct Breadcrumb: Codable {
    let message: String
    let type: BreadcrumbType
    let metadata: [String: String]
    let timestamp: Date
}

enum BreadcrumbType: String, Codable {
    case log
    case navigation
    case user
    case network
    case state
    case error
}
