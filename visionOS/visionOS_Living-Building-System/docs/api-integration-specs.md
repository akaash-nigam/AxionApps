# API Integration Specifications
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document specifies all external API integrations required for the Living Building System. Each integration includes authentication, endpoints, data models, error handling, and implementation patterns.

## 2. Integration Architecture

```
┌──────────────────────────────────────────┐
│      Living Building System App          │
├──────────────────────────────────────────┤
│                                           │
│  ┌────────────────────────────────────┐  │
│  │      Service Layer (Protocols)     │  │
│  ├────────────────────────────────────┤  │
│  │  • HomeKitService                  │  │
│  │  • MatterService                   │  │
│  │  • EnergyMeterService              │  │
│  │  • SolarInverterService            │  │
│  │  • BatterySystemService            │  │
│  │  • EnvironmentSensorService        │  │
│  └────────────────────────────────────┘  │
│              │                             │
└──────────────┼─────────────────────────────┘
               │
   ┌───────────┼────────────────┐
   │           │                │
   ▼           ▼                ▼
┌──────┐  ┌──────┐  ┌────────────────┐
│HomeKit│ │Matter│  │   Third-Party  │
│Framework│ │  SDK │  │      APIs      │
└──────┘  └──────┘  └────────────────┘
```

## 3. HomeKit Integration

### 3.1 Overview
HomeKit provides native iOS/visionOS integration with smart home devices using the Home app's secure communication framework.

### 3.2 Framework
```swift
import HomeKit
```

### 3.3 Authorization

#### Request Authorization
```swift
protocol HomeKitServiceProtocol {
    func requestAuthorization() async throws
    var authorizationStatus: HomeKitAuthStatus { get }
}

enum HomeKitAuthStatus {
    case notDetermined
    case authorized
    case denied
}

class HomeKitService: HomeKitServiceProtocol {
    private let homeManager = HMHomeManager()
    private var authorizationContinuation: CheckedContinuation<Void, Error>?

    func requestAuthorization() async throws {
        // HomeKit authorization is implicit through first use
        // Wait for homeManager to be ready
        try await withCheckedThrowingContinuation { continuation in
            authorizationContinuation = continuation
            homeManager.delegate = self
        }
    }
}

extension HomeKitService: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        // Handle home addition
    }
}
```

### 3.4 Device Discovery

```swift
extension HomeKitService {
    func discoverAccessories(in home: HMHome) async throws -> [HMAccessory] {
        return home.accessories
    }

    func addAccessory(setupCode: String) async throws {
        guard let home = homeManager.primaryHome else {
            throw HomeKitError.noPrimaryHome
        }

        try await withCheckedThrowingContinuation { continuation in
            home.addAndSetupAccessories { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
```

### 3.5 Device Control

```swift
extension HomeKitService {
    func readCharacteristic(_ characteristic: HMCharacteristic) async throws -> Any? {
        try await withCheckedThrowingContinuation { continuation in
            characteristic.readValue { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: characteristic.value)
                }
            }
        }
    }

    func writeCharacteristic(
        _ characteristic: HMCharacteristic,
        value: Any
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            characteristic.writeValue(value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func turnOnLight(_ accessory: HMAccessory) async throws {
        guard let service = accessory.services.first(where: {
            $0.serviceType == HMServiceTypeLightbulb
        }) else {
            throw HomeKitError.serviceNotFound
        }

        guard let characteristic = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypePowerState
        }) else {
            throw HomeKitError.characteristicNotFound
        }

        try await writeCharacteristic(characteristic, value: true)
    }
}
```

### 3.6 Scene & Automation

```swift
extension HomeKitService {
    func createScene(name: String, actions: [HMCharacteristicWriteAction<NSCopying>]) async throws -> HMActionSet {
        guard let home = homeManager.primaryHome else {
            throw HomeKitError.noPrimaryHome
        }

        let actionSet = try await withCheckedThrowingContinuation { continuation in
            home.addActionSet(withName: name) { actionSet, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let actionSet = actionSet {
                    continuation.resume(returning: actionSet)
                } else {
                    continuation.resume(throwing: HomeKitError.unknown)
                }
            }
        }

        for action in actions {
            try await actionSet.addAction(action)
        }

        return actionSet
    }

    func executeScene(_ actionSet: HMActionSet) async throws {
        try await withCheckedThrowingContinuation { continuation in
            actionSet.executeActions { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
```

### 3.7 Notifications

```swift
extension HomeKitService {
    func enableNotifications(for characteristic: HMCharacteristic) async throws {
        try await withCheckedThrowingContinuation { continuation in
            characteristic.enableNotification(true) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

extension HomeKitService: HMAccessoryDelegate {
    func accessory(
        _ accessory: HMAccessory,
        service: HMService,
        didUpdateValueFor characteristic: HMCharacteristic
    ) {
        // Broadcast state change to app
        NotificationCenter.default.post(
            name: .homeKitCharacteristicDidUpdate,
            object: characteristic
        )
    }
}
```

### 3.8 Error Handling

```swift
enum HomeKitError: LocalizedError {
    case noPrimaryHome
    case serviceNotFound
    case characteristicNotFound
    case accessoryNotReachable
    case authorizationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .noPrimaryHome:
            return "No primary home configured in Home app"
        case .serviceNotFound:
            return "Device service not available"
        case .characteristicNotFound:
            return "Device characteristic not found"
        case .accessoryNotReachable:
            return "Device is not reachable"
        case .authorizationFailed:
            return "HomeKit authorization denied"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
```

## 4. Matter Integration

### 4.1 Overview
Matter is a unified smart home standard. Integration will use Matter SDK or HomeKit's Matter support (preferred).

### 4.2 Strategy
Since visionOS/iOS HomeKit supports Matter devices natively, we'll primarily use HomeKit framework for Matter devices. Direct Matter SDK integration is for advanced scenarios only.

### 4.3 Matter via HomeKit
```swift
class MatterService {
    private let homeKitService: HomeKitService

    init(homeKitService: HomeKitService) {
        self.homeKitService = homeKitService
    }

    func commissionMatterDevice(setupCode: String) async throws {
        // HomeKit handles Matter commissioning
        try await homeKitService.addAccessory(setupCode: setupCode)
    }

    func isMatterDevice(_ accessory: HMAccessory) -> Bool {
        // Check if accessory uses Matter protocol
        // HMAccessory doesn't expose protocol directly,
        // but Matter devices will have specific characteristics
        return accessory.category.categoryType != .other
    }
}
```

## 5. Energy Meter Integration

### 5.1 Overview
Integration with smart electricity, water, and gas meters for real-time consumption data.

### 5.2 Common Meter Providers
- **Electricity**: Sense, Emporia, Neurio, utility company APIs
- **Water**: Flume, StreamLabs
- **Gas**: Utility company APIs

### 5.3 Generic Meter Service Protocol

```swift
protocol EnergyMeterServiceProtocol {
    func authenticate(credentials: MeterCredentials) async throws
    func getCurrentReading() async throws -> EnergyReading
    func getHistoricalData(from: Date, to: Date) async throws -> [EnergyReading]
    func streamRealTimeData() -> AsyncStream<EnergyReading>
}

struct MeterCredentials: Codable {
    let apiKey: String?
    let username: String?
    let password: String?
    let deviceID: String?
}
```

### 5.4 Example: Sense Energy Monitor API

```swift
class SenseEnergyService: EnergyMeterServiceProtocol {
    private let baseURL = "https://api.sense.com/apiservice/api/v1"
    private var accessToken: String?
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func authenticate(credentials: MeterCredentials) async throws {
        guard let username = credentials.username,
              let password = credentials.password else {
            throw EnergyMeterError.invalidCredentials
        }

        let url = URL(string: "\(baseURL)/authenticate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EnergyMeterError.authenticationFailed
        }

        struct AuthResponse: Codable {
            let access_token: String
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = authResponse.access_token

        // Store token securely in Keychain
        try KeychainHelper.save(
            accessToken,
            for: "com.lbs.sense.accessToken"
        )
    }

    func getCurrentReading() async throws -> EnergyReading {
        guard let token = accessToken else {
            throw EnergyMeterError.notAuthenticated
        }

        let url = URL(string: "\(baseURL)/app/monitors/your_monitor_id/status")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EnergyMeterError.requestFailed
        }

        struct SenseReading: Codable {
            let w: Double // Watts
            let devices: [DeviceReading]
        }

        struct DeviceReading: Codable {
            let name: String
            let w: Double
        }

        let senseData = try JSONDecoder().decode(SenseReading.self, from: data)

        var reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        reading.instantaneousPower = senseData.w / 1000.0 // Convert to kW

        // Map device breakdown
        reading.circuitBreakdown = Dictionary(
            uniqueKeysWithValues: senseData.devices.map { ($0.name, $0.w / 1000.0) }
        )

        return reading
    }

    func getHistoricalData(from startDate: Date, to endDate: Date) async throws -> [EnergyReading] {
        // Implementation for historical data retrieval
        // Similar pattern to getCurrentReading()
        []
    }

    func streamRealTimeData() -> AsyncStream<EnergyReading> {
        AsyncStream { continuation in
            // Poll every 5 seconds
            Task {
                while !Task.isCancelled {
                    do {
                        let reading = try await getCurrentReading()
                        continuation.yield(reading)
                        try await Task.sleep(for: .seconds(5))
                    } catch {
                        // Log error but continue streaming
                        print("Error fetching energy data: \(error)")
                        try? await Task.sleep(for: .seconds(10))
                    }
                }
                continuation.finish()
            }
        }
    }
}
```

### 5.5 Water Meter Integration (Flume)

```swift
class FlumeWaterService: EnergyMeterServiceProtocol {
    private let baseURL = "https://api.flumewater.com"
    private var accessToken: String?
    private var refreshToken: String?

    func authenticate(credentials: MeterCredentials) async throws {
        let url = URL(string: "\(baseURL)/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "grant_type": "password",
            "client_id": "your_client_id",
            "client_secret": "your_client_secret",
            "username": credentials.username ?? "",
            "password": credentials.password ?? ""
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EnergyMeterError.authenticationFailed
        }

        struct TokenResponse: Codable {
            let access_token: String
            let refresh_token: String
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = tokenResponse.access_token
        self.refreshToken = tokenResponse.refresh_token
    }

    func getCurrentReading() async throws -> EnergyReading {
        guard let token = accessToken else {
            throw EnergyMeterError.notAuthenticated
        }

        let url = URL(string: "\(baseURL)/users/user_id/devices/device_id/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "queries": [
                [
                    "request_id": "current_flow",
                    "bucket": "MIN",
                    "since_datetime": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-60))
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EnergyMeterError.requestFailed
        }

        struct FlumeResponse: Codable {
            let data: [FlumeData]
        }

        struct FlumeData: Codable {
            let value: Double // Gallons
            let datetime: String
        }

        let flumeData = try JSONDecoder().decode(FlumeResponse.self, from: data)

        var reading = EnergyReading(timestamp: Date(), energyType: .water)
        if let latest = flumeData.data.first {
            reading.instantaneousPower = latest.value // Gallons per minute
        }

        return reading
    }

    func getHistoricalData(from: Date, to: Date) async throws -> [EnergyReading] {
        []
    }

    func streamRealTimeData() -> AsyncStream<EnergyReading> {
        AsyncStream { continuation in
            Task {
                while !Task.isCancelled {
                    do {
                        let reading = try await getCurrentReading()
                        continuation.yield(reading)
                        try await Task.sleep(for: .seconds(10))
                    } catch {
                        print("Error fetching water data: \(error)")
                        try? await Task.sleep(for: .seconds(15))
                    }
                }
                continuation.finish()
            }
        }
    }
}
```

### 5.6 Error Handling

```swift
enum EnergyMeterError: LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case authenticationFailed
    case requestFailed
    case deviceNotFound
    case rateLimitExceeded
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid meter credentials"
        case .notAuthenticated:
            return "Not authenticated with energy meter"
        case .authenticationFailed:
            return "Failed to authenticate with meter service"
        case .requestFailed:
            return "Failed to fetch meter data"
        case .deviceNotFound:
            return "Energy meter device not found"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
```

## 6. Solar Inverter Integration

### 6.1 Common Solar Inverters
- Tesla Powerwall API
- SolarEdge API
- Enphase Enlighten API

### 6.2 SolarEdge API Example

```swift
protocol SolarInverterServiceProtocol {
    func authenticate(apiKey: String, siteID: String) async throws
    func getCurrentProduction() async throws -> SolarProduction
    func getEnergyBalance() async throws -> EnergyBalance
}

struct SolarProduction {
    let currentPower: Double // kW
    let todayEnergy: Double // kWh
    let lifetimeEnergy: Double // kWh
    let timestamp: Date
}

struct EnergyBalance {
    let production: Double // kW
    let consumption: Double // kW
    let gridImport: Double // kW (negative if exporting)
    let batteryCharge: Double? // kW (positive = charging)
}

class SolarEdgeService: SolarInverterServiceProtocol {
    private let baseURL = "https://monitoringapi.solaredge.com"
    private var apiKey: String?
    private var siteID: String?

    func authenticate(apiKey: String, siteID: String) async throws {
        self.apiKey = apiKey
        self.siteID = siteID

        // Validate credentials with a test request
        let url = URL(string: "\(baseURL)/site/\(siteID)/overview?api_key=\(apiKey)")!
        let (_, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SolarInverterError.authenticationFailed
        }

        try KeychainHelper.save(apiKey, for: "com.lbs.solaredge.apikey")
    }

    func getCurrentProduction() async throws -> SolarProduction {
        guard let apiKey = apiKey, let siteID = siteID else {
            throw SolarInverterError.notAuthenticated
        }

        let url = URL(string: "\(baseURL)/site/\(siteID)/currentPowerFlow?api_key=\(apiKey)")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SolarInverterError.requestFailed
        }

        struct PowerFlowResponse: Codable {
            let siteCurrentPowerFlow: PowerFlow
        }

        struct PowerFlow: Codable {
            let PV: PVData?
        }

        struct PVData: Codable {
            let currentPower: Double
        }

        let powerFlow = try JSONDecoder().decode(PowerFlowResponse.self, from: data)

        return SolarProduction(
            currentPower: (powerFlow.siteCurrentPowerFlow.PV?.currentPower ?? 0) / 1000.0,
            todayEnergy: 0, // Requires separate API call
            lifetimeEnergy: 0,
            timestamp: Date()
        )
    }

    func getEnergyBalance() async throws -> EnergyBalance {
        guard let apiKey = apiKey, let siteID = siteID else {
            throw SolarInverterError.notAuthenticated
        }

        let url = URL(string: "\(baseURL)/site/\(siteID)/currentPowerFlow?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)

        struct PowerFlowResponse: Codable {
            let siteCurrentPowerFlow: PowerFlow
        }

        struct PowerFlow: Codable {
            let PV: PowerData?
            let LOAD: PowerData?
            let GRID: PowerData?
            let STORAGE: PowerData?
        }

        struct PowerData: Codable {
            let currentPower: Double
        }

        let response = try JSONDecoder().decode(PowerFlowResponse.self, from: data)
        let flow = response.siteCurrentPowerFlow

        return EnergyBalance(
            production: (flow.PV?.currentPower ?? 0) / 1000.0,
            consumption: (flow.LOAD?.currentPower ?? 0) / 1000.0,
            gridImport: (flow.GRID?.currentPower ?? 0) / 1000.0,
            batteryCharge: flow.STORAGE.map { $0.currentPower / 1000.0 }
        )
    }
}

enum SolarInverterError: LocalizedError {
    case notAuthenticated
    case authenticationFailed
    case requestFailed
    case siteNotFound

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with solar inverter"
        case .authenticationFailed:
            return "Failed to authenticate with solar API"
        case .requestFailed:
            return "Failed to fetch solar data"
        case .siteNotFound:
            return "Solar site not found"
        }
    }
}
```

## 7. Environmental Sensor Integration

### 7.1 Awair Air Quality Monitor

```swift
protocol EnvironmentSensorServiceProtocol {
    func authenticate(token: String) async throws
    func getCurrentReadings(deviceID: String) async throws -> EnvironmentReading
    func streamReadings(deviceID: String) -> AsyncStream<EnvironmentReading>
}

class AwairSensorService: EnvironmentSensorServiceProtocol {
    private let baseURL = "https://developer-apis.awair.is/v1"
    private var accessToken: String?

    func authenticate(token: String) async throws {
        self.accessToken = token

        // Validate token
        let url = URL(string: "\(baseURL)/users/self/devices")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EnvironmentSensorError.authenticationFailed
        }

        try KeychainHelper.save(token, for: "com.lbs.awair.token")
    }

    func getCurrentReadings(deviceID: String) async throws -> EnvironmentReading {
        guard let token = accessToken else {
            throw EnvironmentSensorError.notAuthenticated
        }

        let url = URL(string: "\(baseURL)/users/self/devices/awair/\(deviceID)/air-data/latest")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EnvironmentSensorError.requestFailed
        }

        struct AwairResponse: Codable {
            let data: [AwairData]
        }

        struct AwairData: Codable {
            let timestamp: String
            let score: Double
            let sensors: [Sensor]
        }

        struct Sensor: Codable {
            let comp: String
            let value: Double
        }

        let awairData = try JSONDecoder().decode(AwairResponse.self, from: data)

        guard let latest = awairData.data.first else {
            throw EnvironmentSensorError.noData
        }

        let reading = EnvironmentReading(timestamp: Date())

        for sensor in latest.sensors {
            switch sensor.comp {
            case "temp":
                reading.temperature = sensor.value * 9/5 + 32 // Convert C to F
            case "humid":
                reading.humidity = sensor.value
            case "pm25":
                reading.pm25 = sensor.value
            case "co2":
                reading.co2 = Int(sensor.value)
            case "voc":
                reading.voc = Int(sensor.value)
            default:
                break
            }
        }

        // Calculate AQI from Awair score
        reading.airQualityIndex = Int(latest.score)

        return reading
    }

    func streamReadings(deviceID: String) -> AsyncStream<EnvironmentReading> {
        AsyncStream { continuation in
            Task {
                while !Task.isCancelled {
                    do {
                        let reading = try await getCurrentReadings(deviceID: deviceID)
                        continuation.yield(reading)
                        try await Task.sleep(for: .seconds(30))
                    } catch {
                        print("Error fetching environment data: \(error)")
                        try? await Task.sleep(for: .seconds(60))
                    }
                }
                continuation.finish()
            }
        }
    }
}

enum EnvironmentSensorError: LocalizedError {
    case notAuthenticated
    case authenticationFailed
    case requestFailed
    case noData

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with sensor service"
        case .authenticationFailed:
            return "Failed to authenticate with sensor API"
        case .requestFailed:
            return "Failed to fetch sensor data"
        case .noData:
            return "No sensor data available"
        }
    }
}
```

## 8. Rate Limiting & Throttling

### 8.1 Rate Limiter Implementation

```swift
actor RateLimiter {
    private var requestTimestamps: [Date] = []
    private let maxRequests: Int
    private let timeWindow: TimeInterval

    init(maxRequests: Int, per timeWindow: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }

    func checkLimit() async throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(-timeWindow)

        // Remove old timestamps
        requestTimestamps.removeAll { $0 < cutoff }

        if requestTimestamps.count >= maxRequests {
            let oldestRequest = requestTimestamps.first!
            let waitTime = oldestRequest.addingTimeInterval(timeWindow).timeIntervalSince(now)
            throw RateLimitError.limitExceeded(retryAfter: waitTime)
        }

        requestTimestamps.append(now)
    }
}

enum RateLimitError: LocalizedError {
    case limitExceeded(retryAfter: TimeInterval)

    var errorDescription: String? {
        switch self {
        case .limitExceeded(let retryAfter):
            return "Rate limit exceeded. Retry after \(Int(retryAfter)) seconds"
        }
    }
}
```

### 8.2 Usage Example

```swift
class ThrottledEnergyService {
    private let energyService: EnergyMeterServiceProtocol
    private let rateLimiter = RateLimiter(maxRequests: 100, per: 3600) // 100 per hour

    func getCurrentReading() async throws -> EnergyReading {
        try await rateLimiter.checkLimit()
        return try await energyService.getCurrentReading()
    }
}
```

## 9. Retry Logic

### 9.1 Exponential Backoff

```swift
func retryWithExponentialBackoff<T>(
    maxAttempts: Int = 3,
    initialDelay: TimeInterval = 1.0,
    operation: @escaping () async throws -> T
) async throws -> T {
    var attempt = 0
    var delay = initialDelay

    while attempt < maxAttempts {
        do {
            return try await operation()
        } catch {
            attempt += 1

            if attempt >= maxAttempts {
                throw error
            }

            // Check if error is retryable
            guard isRetryableError(error) else {
                throw error
            }

            try await Task.sleep(for: .seconds(delay))
            delay *= 2 // Exponential backoff
        }
    }

    fatalError("Should never reach here")
}

func isRetryableError(_ error: Error) -> Bool {
    // Network errors, timeouts, rate limits are retryable
    // Auth errors, not found errors are not
    if let urlError = error as? URLError {
        switch urlError.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet:
            return true
        default:
            return false
        }
    }

    if case RateLimitError.limitExceeded = error {
        return true
    }

    return false
}
```

## 10. Caching Strategy

### 10.1 Response Cache

```swift
actor APICache<Key: Hashable, Value> {
    private var cache: [Key: CachedValue<Value>] = [:]
    private let ttl: TimeInterval

    struct CachedValue<T> {
        let value: T
        let expiresAt: Date
    }

    init(ttl: TimeInterval) {
        self.ttl = ttl
    }

    func get(_ key: Key) -> Value? {
        guard let cached = cache[key], cached.expiresAt > Date() else {
            cache.removeValue(forKey: key)
            return nil
        }
        return cached.value
    }

    func set(_ key: Key, value: Value) {
        cache[key] = CachedValue(
            value: value,
            expiresAt: Date().addingTimeInterval(ttl)
        )
    }

    func clear() {
        cache.removeAll()
    }
}
```

## 11. Network Monitoring

### 11.1 Reachability Check

```swift
import Network

actor NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isConnected = false

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.updateStatus(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }

    private func updateStatus(_ connected: Bool) {
        isConnected = connected
        NotificationCenter.default.post(
            name: .networkStatusChanged,
            object: connected
        )
    }
}
```

## 12. Testing

### 12.1 Mock Services

```swift
class MockHomeKitService: HomeKitServiceProtocol {
    var mockDevices: [HMAccessory] = []
    var shouldThrowError = false

    func requestAuthorization() async throws {
        if shouldThrowError {
            throw HomeKitError.authorizationFailed
        }
    }

    func discoverAccessories(in home: HMHome) async throws -> [HMAccessory] {
        if shouldThrowError {
            throw HomeKitError.noPrimaryHome
        }
        return mockDevices
    }

    // ... other mock implementations
}
```

---

**Document Owner**: Integration Team
**Review Cycle**: On API version changes
**Next Review**: As needed
