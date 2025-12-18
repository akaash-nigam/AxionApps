import Foundation
import SwiftData
import Logging

/// Service Container - Centralized dependency injection container for all services
/// Use this to manage service lifecycles and provide testable service instances
@Observable
@MainActor
final class ServiceContainer {

    // MARK: - Shared Instance

    static let shared = ServiceContainer()

    // MARK: - Services

    private(set) var authService: AuthenticationService
    private(set) var networkService: NetworkService?
    private(set) var digitalTwinService: DigitalTwinService?
    private(set) var sensorService: SensorIntegrationService?

    // MARK: - Configuration

    struct Configuration {
        var baseURL: URL
        var enableLogging: Bool
        var environment: Environment

        enum Environment {
            case development
            case staging
            case production
        }

        static var `default`: Configuration {
            Configuration(
                baseURL: URL(string: "https://api.twinspace.io")!,
                enableLogging: true,
                environment: .development
            )
        }

        #if DEBUG
        static var preview: Configuration {
            Configuration(
                baseURL: URL(string: "https://mock.twinspace.io")!,
                enableLogging: true,
                environment: .development
            )
        }
        #endif
    }

    private var configuration: Configuration

    // MARK: - Initialization

    private init() {
        self.configuration = .default
        self.authService = AuthenticationService()
    }

    /// Configure the service container with custom configuration
    /// Must be called before accessing network-dependent services
    func configure(with configuration: Configuration) {
        self.configuration = configuration

        let logger = Logger(label: "com.twinspace.services")

        // Initialize network service
        self.networkService = NetworkService(
            baseURL: configuration.baseURL,
            authService: authService,
            logger: logger
        )

        // Initialize sensor service
        self.sensorService = SensorIntegrationService(
            config: SensorIntegrationService.Configuration(),
            logger: Logger(label: "com.twinspace.sensor")
        )
    }

    /// Configure with model context for data layer services
    func configureDataServices(modelContext: ModelContext) {
        guard let networkService = networkService else {
            fatalError("NetworkService must be configured before data services. Call configure(with:) first.")
        }

        self.digitalTwinService = DigitalTwinService(
            networkService: networkService,
            modelContext: modelContext,
            config: DigitalTwinService.Configuration(),
            logger: Logger(label: "com.twinspace.digitaltwin")
        )
    }

    // MARK: - Service Access (Safe)

    /// Get network service or throw if not configured
    func requireNetworkService() throws -> NetworkService {
        guard let service = networkService else {
            throw ServiceContainerError.serviceNotConfigured("NetworkService")
        }
        return service
    }

    /// Get digital twin service or throw if not configured
    func requireDigitalTwinService() throws -> DigitalTwinService {
        guard let service = digitalTwinService else {
            throw ServiceContainerError.serviceNotConfigured("DigitalTwinService")
        }
        return service
    }

    /// Get sensor service or throw if not configured
    func requireSensorService() throws -> SensorIntegrationService {
        guard let service = sensorService else {
            throw ServiceContainerError.serviceNotConfigured("SensorIntegrationService")
        }
        return service
    }

    // MARK: - Testing Support

    #if DEBUG
    /// Reset all services (for testing)
    func reset() {
        networkService = nil
        digitalTwinService = nil
        sensorService = nil
        authService = AuthenticationService()
    }

    /// Inject mock services for testing
    func injectMockServices(
        authService: AuthenticationService? = nil,
        networkService: NetworkService? = nil,
        digitalTwinService: DigitalTwinService? = nil,
        sensorService: SensorIntegrationService? = nil
    ) {
        if let authService = authService {
            self.authService = authService
        }
        if let networkService = networkService {
            self.networkService = networkService
        }
        if let digitalTwinService = digitalTwinService {
            self.digitalTwinService = digitalTwinService
        }
        if let sensorService = sensorService {
            self.sensorService = sensorService
        }
    }
    #endif
}

// MARK: - Errors

enum ServiceContainerError: Error, LocalizedError {
    case serviceNotConfigured(String)
    case configurationFailed(String)

    var errorDescription: String? {
        switch self {
        case .serviceNotConfigured(let service):
            return "\(service) has not been configured. Call ServiceContainer.shared.configure() first."
        case .configurationFailed(let reason):
            return "Service configuration failed: \(reason)"
        }
    }
}

// MARK: - SwiftUI Environment Integration

import SwiftUI

extension View {
    /// Inject the service container into the environment
    /// Currently uses ServiceContainer.shared directly
    func withServices(_ container: ServiceContainer = .shared) -> some View {
        self
    }
}
