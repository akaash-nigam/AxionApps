import Foundation
import Logging
import Network

/// Network Service - Handles all HTTP/HTTPS communication with retry logic and error handling
@Observable
final class NetworkService: @unchecked Sendable {

    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let logger: Logger
    private let authService: AuthenticationService
    private let maxRetries: Int = 3
    private let retryDelay: TimeInterval = 2.0

    // Request queue for offline support
    private var pendingRequests: [PendingRequest] = []
    private(set) var isOnline: Bool = true

    // Network monitoring
    private let networkMonitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "com.twinspace.network.monitor")

    // MARK: - Initialization

    init(
        baseURL: URL,
        authService: AuthenticationService,
        logger: Logger = Logger(label: "com.twinspace.network")
    ) {
        self.baseURL = baseURL
        self.authService = authService
        self.logger = logger
        self.networkMonitor = NWPathMonitor()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        self.session = URLSession(configuration: configuration)

        // Monitor network connectivity
        startNetworkMonitoring()
    }

    deinit {
        networkMonitor.cancel()
    }

    // MARK: - Public API

    /// Perform a network request with automatic retry and error handling
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        retry: Int = 0
    ) async throws -> T {
        logger.info("Request: \(endpoint.method) \(endpoint.path)")

        var urlRequest = try buildRequest(endpoint)

        // Add authentication if available
        if let token = await authService.currentToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            logger.info("Response: \(httpResponse.statusCode) for \(endpoint.path)")

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode and return
                return try JSONDecoder().decode(T.self, from: data)

            case 401:
                // Unauthorized - try to refresh token and retry
                if retry < maxRetries {
                    logger.info("Attempting to refresh authentication token")
                    try await authService.refreshToken()
                    return try await request(endpoint, retry: retry + 1)
                }
                throw NetworkError.unauthorized

            case 429:
                // Rate limited - wait and retry
                if retry < maxRetries {
                    let delay = retryDelay * pow(2.0, Double(retry))
                    logger.warning("Rate limited, retrying in \(delay)s")
                    try await Task.sleep(for: .seconds(delay))
                    return try await request(endpoint, retry: retry + 1)
                }
                throw NetworkError.rateLimited

            case 500...599:
                // Server error - retry with exponential backoff
                if retry < maxRetries {
                    let delay = retryDelay * pow(2.0, Double(retry))
                    logger.warning("Server error, retrying in \(delay)s")
                    try await Task.sleep(for: .seconds(delay))
                    return try await request(endpoint, retry: retry + 1)
                }
                throw NetworkError.serverError(httpResponse.statusCode)

            default:
                throw NetworkError.httpError(httpResponse.statusCode)
            }

        } catch let error as NetworkError {
            throw error
        } catch {
            // Network connectivity error
            if retry < maxRetries {
                let delay = retryDelay * pow(2.0, Double(retry))
                logger.warning("Network error: \(error), retrying in \(delay)s")
                try await Task.sleep(for: .seconds(delay))
                return try await request(endpoint, retry: retry + 1)
            }

            // Queue request for later if offline
            if !isOnline {
                queueRequest(endpoint)
            }

            throw NetworkError.connectionFailed(error)
        }
    }

    /// Upload data (for large payloads like 3D models)
    func upload<T: Decodable>(
        _ endpoint: APIEndpoint,
        data uploadData: Data,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> T {
        var urlRequest = try buildRequest(endpoint)
        urlRequest.httpBody = uploadData

        // Use URLSession's delegate-based upload for progress tracking
        let delegate = UploadProgressDelegate(progressHandler: progressHandler)
        let uploadSession = URLSession(
            configuration: session.configuration,
            delegate: delegate,
            delegateQueue: nil
        )

        defer {
            uploadSession.finishTasksAndInvalidate()
        }

        let (responseData, response) = try await uploadSession.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: responseData)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    /// Download data (for 3D models, etc.)
    func download(
        from url: URL,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> URL {
        // Use URLSession's delegate-based download for progress tracking
        let delegate = DownloadProgressDelegate(progressHandler: progressHandler)
        let downloadSession = URLSession(
            configuration: session.configuration,
            delegate: delegate,
            delegateQueue: nil
        )

        defer {
            downloadSession.finishTasksAndInvalidate()
        }

        let (localURL, response) = try await downloadSession.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        // Move to permanent location
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw NetworkError.fileOperationFailed(
                NSError(domain: "NetworkService", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not access documents directory"
                ])
            )
        }

        let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: localURL, to: destinationURL)
            return destinationURL
        } catch {
            throw NetworkError.fileOperationFailed(error)
        }
    }

    // MARK: - Offline Support

    private func queueRequest(_ endpoint: APIEndpoint) {
        let pending = PendingRequest(
            id: UUID(),
            endpoint: endpoint,
            timestamp: Date()
        )
        pendingRequests.append(pending)
        logger.info("Queued request for offline: \(endpoint.path)")
    }

    func processPendingRequests() async {
        guard isOnline, !pendingRequests.isEmpty else { return }

        logger.info("Processing \(pendingRequests.count) pending requests")

        for request in pendingRequests {
            do {
                let _: EmptyResponse = try await self.request(request.endpoint)
                // Remove from queue on success
                if let index = pendingRequests.firstIndex(where: { $0.id == request.id }) {
                    pendingRequests.remove(at: index)
                }
            } catch {
                logger.error("Failed to process pending request: \(error)")
            }
        }
    }

    // MARK: - Private Helpers

    private func buildRequest(_ endpoint: APIEndpoint) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add body if present
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let wasOnline = self.isOnline
            self.isOnline = path.status == .satisfied

            if self.isOnline && !wasOnline {
                self.logger.info("Network connection restored")
                Task {
                    await self.processPendingRequests()
                }
            } else if !self.isOnline && wasOnline {
                self.logger.warning("Network connection lost")
            }

            // Log connection type for debugging
            if path.usesInterfaceType(.wifi) {
                self.logger.debug("Connected via WiFi")
            } else if path.usesInterfaceType(.cellular) {
                self.logger.debug("Connected via Cellular")
            } else if path.usesInterfaceType(.wiredEthernet) {
                self.logger.debug("Connected via Ethernet")
            }
        }

        networkMonitor.start(queue: monitorQueue)
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case httpError(Int)
    case connectionFailed(Error)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case fileOperationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (\(code))"
        case .httpError(let code):
            return "HTTP error (\(code))"
        case .connectionFailed(let error):
            return "Connection failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .fileOperationFailed(let error):
            return "File operation failed: \(error.localizedDescription)"
        }
    }
}

struct PendingRequest: Identifiable {
    let id: UUID
    let endpoint: APIEndpoint
    let timestamp: Date
}

struct EmptyResponse: Codable {}

// MARK: - Authentication Service Stub

@Observable
class AuthenticationService {
    var currentToken: String?

    func refreshToken() async throws {
        // Implementation will depend on auth provider
        // For now, this is a stub
    }
}

// MARK: - Progress Delegates

/// Delegate for tracking upload progress
final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate {
    private let progressHandler: (Double) -> Void

    init(progressHandler: @escaping (Double) -> Void) {
        self.progressHandler = progressHandler
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else { return }
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        Task { @MainActor in
            self.progressHandler(progress)
        }
    }
}

/// Delegate for tracking download progress
final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Double) -> Void

    init(progressHandler: @escaping (Double) -> Void) {
        self.progressHandler = progressHandler
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        Task { @MainActor in
            self.progressHandler(progress)
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Required delegate method - actual file handling done in async download method
    }
}
