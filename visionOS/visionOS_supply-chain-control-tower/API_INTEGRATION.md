# API Integration Guide

Guide for integrating the Supply Chain Control Tower visionOS app with backend APIs.

## Table of Contents

- [Overview](#overview)
- [API Architecture](#api-architecture)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
- [Data Models](#data-models)
- [Real-time Updates](#real-time-updates)
- [Error Handling](#error-handling)
- [Caching Strategy](#caching-strategy)
- [Testing](#testing)
- [Production Deployment](#production-deployment)

---

## Overview

The Supply Chain Control Tower connects to backend APIs to fetch network data, track shipments, and receive real-time disruption alerts.

### Current State

- ✅ **NetworkService** fully implemented
- ✅ **Mock data** for development/testing
- 🔄 **Backend integration** ready for API endpoints
- 🔄 **WebSocket** support ready for real-time updates

### Architecture

```
visionOS App
    ↓
NetworkService (Swift)
    ↓
[REST API / WebSocket]
    ↓
Backend Server
    ↓
[Database / External Systems]
```

---

## API Architecture

### Base Configuration

Update `NetworkService.swift` with your API endpoint:

```swift
actor NetworkService {
    // MARK: - Configuration

    private let baseURL: URL
    private let apiKey: String

    init(baseURL: URL = URL(string: "https://api.yourcompany.com")!,
         apiKey: String = ProcessInfo.processInfo.environment["API_KEY"] ?? "") {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
}
```

### Environment Variables

Set API endpoint per environment:

```swift
struct AppConfiguration {
    static var current: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()

    enum Environment {
        case development
        case staging
        case production

        var apiBaseURL: URL {
            switch self {
            case .development:
                return URL(string: "https://dev-api.yourcompany.com")!
            case .staging:
                return URL(string: "https://staging-api.yourcompany.com")!
            case .production:
                return URL(string: "https://api.yourcompany.com")!
            }
        }
    }
}
```

---

## Authentication

### API Key Authentication

**Headers**:
```
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

**Implementation**:
```swift
private func createRequest(for endpoint: Endpoint) -> URLRequest {
    let url = baseURL.appendingPathComponent(endpoint.path)
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}
```

### OAuth 2.0 (Optional)

For OAuth authentication:

```swift
struct OAuth2Manager {
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpiry: Date?

    mutating func authenticate() async throws {
        // OAuth flow implementation
    }

    mutating func refreshAccessToken() async throws {
        // Token refresh implementation
    }
}
```

### Token Storage

Store tokens securely in Keychain:

```swift
import Security

class KeychainHelper {
    static func save(token: String, forKey key: String) throws {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }

    static func retrieve(forKey key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
```

---

## API Endpoints

### GET /api/v1/network

Fetch complete supply chain network.

**Request**:
```http
GET /api/v1/network HTTP/1.1
Host: api.yourcompany.com
Authorization: Bearer YOUR_API_KEY
```

**Response** (200 OK):
```json
{
  "id": "network-001",
  "nodes": [
    {
      "id": "NODE-NYC-WH01",
      "type": "warehouse",
      "location": {
        "latitude": 40.7128,
        "longitude": -74.0060
      },
      "capacity": {
        "total": 10000,
        "available": 3500,
        "unit": "pallets"
      },
      "inventory": [
        {
          "sku": "PROD-001",
          "name": "Widget A",
          "quantity": 500,
          "unit": "units",
          "value": 25.99,
          "lastUpdated": "2025-11-17T10:30:00Z"
        }
      ],
      "status": "healthy"
    }
  ],
  "edges": [
    {
      "id": "EDGE-001",
      "source": "NODE-NYC-WH01",
      "destination": "NODE-LA-PORT",
      "type": "truck",
      "capacity": {
        "volume": 50000,
        "weight": 25000,
        "units": 100
      },
      "cost": {
        "amount": 2500,
        "currency": "USD"
      },
      "duration": {
        "seconds": 259200
      }
    }
  ],
  "flows": [...],
  "disruptions": [...]
}
```

**Swift Implementation**:
```swift
func fetchNetwork() async throws -> SupplyChainNetwork {
    let endpoint = Endpoint.getNetwork
    let request = createRequest(for: endpoint)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw APIError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
    }

    return try JSONDecoder().decode(SupplyChainNetwork.self, from: data)
}
```

### GET /api/v1/shipments

Fetch all active shipments.

**Query Parameters**:
- `status`: Filter by status (`pending`, `inTransit`, `delayed`, etc.)
- `limit`: Maximum results (default: 100)
- `offset`: Pagination offset

**Request**:
```http
GET /api/v1/shipments?status=inTransit&limit=50 HTTP/1.1
```

**Response** (200 OK):
```json
{
  "shipments": [...],
  "total": 847,
  "limit": 50,
  "offset": 0
}
```

### GET /api/v1/disruptions

Fetch active disruptions and alerts.

**Request**:
```http
GET /api/v1/disruptions HTTP/1.1
```

**Response** (200 OK):
```json
{
  "disruptions": [
    {
      "id": "DISRUPT-001",
      "type": "weatherEvent",
      "severity": "critical",
      "affectedNodes": ["NODE-001", "NODE-002"],
      "predictedImpact": {
        "delayHours": 48,
        "affectedShipments": 25,
        "costImpact": 150000
      },
      "recommendations": [
        {
          "id": "REC-001",
          "title": "Reroute via alternative port",
          "description": "Use Port of Oakland instead of Port of LA",
          "estimatedCost": 25000,
          "estimatedTimeSavings": 24,
          "confidence": 0.85
        }
      ],
      "timestamp": "2025-11-17T08:00:00Z"
    }
  ]
}
```

### PUT /api/v1/shipments/:id

Update shipment status or route.

**Request**:
```http
PUT /api/v1/shipments/SHP-12345 HTTP/1.1
Content-Type: application/json

{
  "status": "inTransit",
  "currentNode": "NODE-002",
  "actualProgress": 0.35,
  "eta": "2025-11-18T14:00:00Z"
}
```

**Response** (200 OK):
```json
{
  "id": "SHP-12345",
  "status": "inTransit",
  "message": "Shipment updated successfully"
}
```

**Swift Implementation**:
```swift
func updateShipment(_ id: String, status: FlowStatus) async throws -> Flow {
    let endpoint = Endpoint.updateShipment(id)
    var request = createRequest(for: endpoint)

    let body = ["status": status.rawValue]
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw APIError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
    }

    return try JSONDecoder().decode(Flow.self, from: data)
}
```

---

## Data Models

### Request/Response Types

All API requests/responses use these models:

```swift
// Already implemented in DataModels.swift
struct SupplyChainNetwork: Codable {
    let id: UUID
    var nodes: [Node]
    var edges: [Edge]
    var flows: [Flow]
    var disruptions: [Disruption]
}

struct Node: Codable {
    let id: String
    let type: NodeType
    var location: GeographicCoordinate
    var capacity: Capacity
    var inventory: [InventoryItem]
    var status: NodeStatus
}

struct Flow: Codable {
    let id: String
    let shipmentId: String
    var currentNode: String
    let destinationNode: String
    var route: [String]
    var items: [InventoryItem]
    var status: FlowStatus
    var eta: Date
    var actualProgress: Double
}
```

### Date Formatting

Use ISO 8601 format for all dates:

```swift
extension JSONDecoder {
    static var supplyChain: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {
    static var supplyChain: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
```

---

## Real-time Updates

### WebSocket Connection

For real-time shipment tracking and disruption alerts:

**Connection**:
```swift
import Foundation

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?

    func connect(to url: URL) {
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue receiving
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            // Parse JSON update
            if let data = text.data(using: .utf8),
               let update = try? JSONDecoder.supplyChain.decode(RealtimeUpdate.self, from: data) {
                handleUpdate(update)
            }
        case .data(let data):
            // Handle binary data
            break
        @unknown default:
            break
        }
    }

    func send(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error {
                print("Send error: \(error)")
            }
        }
    }
}

struct RealtimeUpdate: Codable {
    let type: UpdateType
    let payload: UpdatePayload

    enum UpdateType: String, Codable {
        case shipmentUpdate
        case disruptionAlert
        case nodeStatusChange
    }

    struct UpdatePayload: Codable {
        // Dynamic payload based on type
    }
}
```

**WebSocket URL**:
```
wss://api.yourcompany.com/ws/v1/updates?token=YOUR_API_KEY
```

---

## Error Handling

### API Errors

```swift
enum APIError: LocalizedError {
    case invalidResponse
    case noData
    case decodingFailed
    case httpError(statusCode: Int)
    case networkUnavailable
    case timeout
    case unauthorized
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingFailed:
            return "Failed to decode response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .networkUnavailable:
            return "Network unavailable"
        case .timeout:
            return "Request timed out"
        case .unauthorized:
            return "Unauthorized - check API key"
        case .rateLimited:
            return "Rate limit exceeded"
        }
    }
}
```

### Retry Logic

```swift
func fetchWithRetry<T>(
    _ operation: () async throws -> T,
    maxRetries: Int = 3,
    delay: TimeInterval = 2.0
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error

            // Don't retry on certain errors
            if case APIError.unauthorized = error {
                throw error
            }

            // Wait before retry with exponential backoff
            if attempt < maxRetries - 1 {
                let backoffDelay = delay * Double(1 << attempt)
                try await Task.sleep(for: .seconds(backoffDelay))
            }
        }
    }

    throw lastError ?? APIError.networkUnavailable
}
```

---

## Caching Strategy

### Cache Implementation

Already implemented in `NetworkService.swift`:

```swift
actor CacheManager {
    private var cache: [String: CacheEntry] = [:]

    func get<T: Codable>(forKey key: String) -> T? {
        guard let entry = cache[key], !entry.isExpired else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.value as? T
    }

    func set<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval) {
        let entry = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))
        cache[key] = entry
    }
}
```

### Cache Keys

```swift
enum CacheKey {
    static let network = "network-data"
    static let disruptions = "disruptions"
    static func shipments(status: FlowStatus) -> String {
        "shipments-\(status.rawValue)"
    }
}
```

### TTL (Time To Live)

- **Network data**: 5 minutes (300 seconds)
- **Shipments**: 1 minute (60 seconds)
- **Disruptions**: 30 seconds
- **Static reference data**: 1 hour (3600 seconds)

---

## Testing

### Mock Server

Use a local mock server for development:

```swift
#if DEBUG
class MockNetworkService: NetworkServiceProtocol {
    func fetchNetwork() async throws -> SupplyChainNetwork {
        return SupplyChainNetwork.mockNetwork()
    }

    func fetchDisruptions() async throws -> [Disruption] {
        return SupplyChainNetwork.mockNetwork().disruptions
    }
}
#endif
```

### API Integration Tests

```swift
@Suite("API Integration Tests")
struct APIIntegrationTests {

    @Test("Fetch network from real API")
    func testFetchNetwork() async throws {
        let service = NetworkService(
            baseURL: URL(string: "https://staging-api.yourcompany.com")!
        )

        let network = try await service.fetchNetwork()

        #expect(network.nodes.count > 0)
        #expect(network.flows.count > 0)
    }
}
```

---

## Production Deployment

### API Endpoint Configuration

Set in Xcode build configuration:

**Info.plist**:
```xml
<key>APIBaseURL</key>
<string>$(API_BASE_URL)</string>
```

**Build Settings**:
- Debug: `https://dev-api.yourcompany.com`
- Staging: `https://staging-api.yourcompany.com`
- Release: `https://api.yourcompany.com`

### Performance Monitoring

Track API performance:

```swift
func trackAPICall(_ endpoint: String, duration: TimeInterval, statusCode: Int) {
    // Send to analytics service
    Analytics.track(event: "api_call", properties: [
        "endpoint": endpoint,
        "duration_ms": duration * 1000,
        "status_code": statusCode
    ])
}
```

### Rate Limiting

Respect API rate limits:

```swift
actor RateLimiter {
    private var lastRequestTime: Date = .distantPast
    private let minimumInterval: TimeInterval = 0.1 // 10 requests/second max

    func throttle() async {
        let now = Date()
        let timeSinceLastRequest = now.timeIntervalSince(lastRequestTime)

        if timeSinceLastRequest < minimumInterval {
            let delay = minimumInterval - timeSinceLastRequest
            try? await Task.sleep(for: .seconds(delay))
        }

        lastRequestTime = Date()
    }
}
```

---

## Additional Resources

- **API Documentation**: Contact backend team for OpenAPI/Swagger specs
- **Authentication**: See security team for OAuth setup
- **Monitoring**: Set up DataDog/New Relic for API monitoring
- **Support**: backend-team@yourcompany.com

---

*Last Updated: November 2025*
*Version: 1.0*
