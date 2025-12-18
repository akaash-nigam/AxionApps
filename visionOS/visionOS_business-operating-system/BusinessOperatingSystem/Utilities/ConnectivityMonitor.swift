//
//  ConnectivityMonitor.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import Network
import Observation

/// Monitors network connectivity and provides offline mode support
@Observable
final class ConnectivityMonitor: @unchecked Sendable {
    // MARK: - Properties

    /// Whether the device currently has network connectivity
    private(set) var isConnected: Bool = true

    /// Whether the device is using an expensive connection (cellular)
    private(set) var isExpensive: Bool = false

    /// Whether the device is using a constrained connection (Low Data Mode)
    private(set) var isConstrained: Bool = false

    /// The current connection type
    private(set) var connectionType: ConnectionType = .unknown

    /// Last time connectivity was checked
    private(set) var lastChecked: Date = Date()

    // MARK: - Private Properties

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.bos.connectivity", qos: .utility)
    private var isMonitoring = false

    // MARK: - Connection Type

    enum ConnectionType: String, Sendable {
        case wifi
        case cellular
        case wiredEthernet
        case unknown

        var displayName: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .wiredEthernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        }
    }

    // MARK: - Lifecycle

    init() {}

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Start monitoring network connectivity
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateConnectivity(from: path)
            }
        }

        monitor.start(queue: queue)
    }

    /// Stop monitoring network connectivity
    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        monitor.cancel()
    }

    /// Perform a connectivity check with a specific host
    func checkConnectivity(to host: String = "api.example.com", port: UInt16 = 443) async -> Bool {
        return await withCheckedContinuation { continuation in
            let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!)
            let parameters = NWParameters.tcp
            let connection = NWConnection(to: endpoint, using: parameters)

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    connection.cancel()
                    continuation.resume(returning: true)
                case .failed, .cancelled:
                    continuation.resume(returning: false)
                default:
                    break
                }
            }

            connection.start(queue: self.queue)

            // Timeout after 5 seconds
            Task {
                try? await Task.sleep(for: .seconds(5))
                if connection.state != .ready {
                    connection.cancel()
                    continuation.resume(returning: false)
                }
            }
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func updateConnectivity(from path: NWPath) {
        lastChecked = Date()
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else {
            connectionType = .unknown
        }
    }
}

// MARK: - Connectivity-Aware Repository Wrapper

/// A wrapper that adds offline support to any repository
actor ConnectivityAwareRepository {
    private let connectivity: ConnectivityMonitor
    private let onlineRepository: BusinessDataRepository
    private let cacheRepository: BusinessDataRepository

    init(
        connectivity: ConnectivityMonitor,
        onlineRepository: BusinessDataRepository,
        cacheRepository: BusinessDataRepository
    ) {
        self.connectivity = connectivity
        self.onlineRepository = onlineRepository
        self.cacheRepository = cacheRepository
    }

    /// Fetch data with automatic fallback to cache when offline
    func fetchWithFallback<T>(
        online: @escaping () async throws -> T,
        cached: @escaping () async throws -> T,
        cache: @escaping (T) async throws -> Void
    ) async throws -> T {
        // Check if we're online
        let isOnline = await MainActor.run { connectivity.isConnected }

        if isOnline {
            do {
                let result = try await online()
                // Cache the result for offline use
                try? await cache(result)
                return result
            } catch {
                // Network error, try cache
                if let cachedResult = try? await cached() {
                    return cachedResult
                }
                throw error
            }
        } else {
            // Offline, use cache
            do {
                return try await cached()
            } catch {
                throw BOSError.networkUnavailable
            }
        }
    }
}

// MARK: - Offline Mode Banner View

import SwiftUI

struct OfflineBanner: View {
    let connectivity: ConnectivityMonitor

    var body: some View {
        if !connectivity.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(.white)

                Text("You're offline. Some features may be limited.")
                    .font(.caption)
                    .foregroundStyle(.white)

                Spacer()

                if connectivity.connectionType != .unknown {
                    Text("Last: \(connectivity.connectionType.displayName)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.orange)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Network Error Extension

extension BOSError {
    /// Create an appropriate error based on connectivity status
    static func fromNetworkError(_ error: Error, connectivity: ConnectivityMonitor) -> BOSError {
        if !connectivity.isConnected {
            return .networkUnavailable
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet:
                return .networkUnavailable
            case .cannotFindHost, .cannotConnectToHost:
                return .serverError(503)
            default:
                return .invalidResponse
            }
        }

        return .invalidResponse
    }
}
