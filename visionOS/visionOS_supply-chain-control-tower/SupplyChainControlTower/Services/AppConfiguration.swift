//
//  AppConfiguration.swift
//  SupplyChainControlTower
//
//  Environment configuration management
//

import Foundation

/// Application configuration manager
struct AppConfiguration {

    // MARK: - Environment

    static let current: Environment = {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }()

    enum Environment {
        case development
        case staging
        case production

        var name: String {
            switch self {
            case .development: return "Development"
            case .staging: return "Staging"
            case .production: return "Production"
            }
        }

        var apiBaseURL: URL {
            switch self {
            case .development:
                return URL(string: "https://dev-api.supplychain.example.com")!
            case .staging:
                return URL(string: "https://staging-api.supplychain.example.com")!
            case .production:
                return URL(string: "https://api.supplychain.example.com")!
            }
        }

        var websocketURL: URL {
            switch self {
            case .development:
                return URL(string: "wss://dev-api.supplychain.example.com/ws")!
            case .staging:
                return URL(string: "wss://staging-api.supplychain.example.com/ws")!
            case .production:
                return URL(string: "wss://api.supplychain.example.com/ws")!
            }
        }

        var apiKey: String {
            // In production, read from Keychain or environment variable
            switch self {
            case .development:
                return ProcessInfo.processInfo.environment["DEV_API_KEY"] ?? "dev_key_12345"
            case .staging:
                return ProcessInfo.processInfo.environment["STAGING_API_KEY"] ?? "staging_key_12345"
            case .production:
                return ProcessInfo.processInfo.environment["API_KEY"] ?? ""
            }
        }

        var cacheEnabled: Bool {
            switch self {
            case .development: return true
            case .staging: return true
            case .production: return true
            }
        }

        var cacheTTL: TimeInterval {
            switch self {
            case .development: return 300 // 5 minutes
            case .staging: return 300
            case .production: return 300
            }
        }

        var requestTimeout: TimeInterval {
            return 30
        }

        var maxRetries: Int {
            return 3
        }

        var logLevel: LogLevel {
            switch self {
            case .development: return .debug
            case .staging: return .info
            case .production: return .warning
            }
        }
    }

    // MARK: - Log Level

    enum LogLevel: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3

        var name: String {
            switch self {
            case .debug: return "DEBUG"
            case .info: return "INFO"
            case .warning: return "WARNING"
            case .error: return "ERROR"
            }
        }
    }

    // MARK: - Feature Flags

    struct FeatureFlags {
        static var enableRealTimeUpdates: Bool {
            current == .production || current == .staging
        }

        static var enablePredictiveAnalytics: Bool {
            current == .production
        }

        static var enableOfflineMode: Bool {
            true // Available in all environments
        }

        static var enablePerformanceMonitoring: Bool {
            current == .production
        }

        static var mockDataEnabled: Bool {
            current == .development
        }
    }

    // MARK: - API Configuration

    struct API {
        static let version = "v1"
        static let userAgent = "SupplyChainControlTower/1.0 (visionOS)"
        static let acceptLanguage = "en-US,en;q=0.9"
    }

    // MARK: - Performance

    struct Performance {
        static let targetFPS: Double = 90
        static let maxMemoryUsage: UInt64 = 4_000_000_000 // 4GB
        static let entityPoolSize: Int = 1000
        static let maxConcurrentRequests: Int = 5
    }

    // MARK: - Logger

    struct Logger {
        static func log(_ message: String, level: LogLevel = .info) {
            guard level.rawValue >= current.logLevel.rawValue else { return }

            let timestamp = DateFormatter.logTimestamp.string(from: Date())
            print("[\(timestamp)] [\(level.name)] \(message)")
        }

        static func debug(_ message: String) {
            log(message, level: .debug)
        }

        static func info(_ message: String) {
            log(message, level: .info)
        }

        static func warning(_ message: String) {
            log(message, level: .warning)
        }

        static func error(_ message: String) {
            log(message, level: .error)
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
