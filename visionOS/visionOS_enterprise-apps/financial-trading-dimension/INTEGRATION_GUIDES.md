# Integration Guides

Comprehensive guides for integrating Financial Trading Dimension with external services and data providers.

---

## Table of Contents

1. [Overview](#overview)
2. [Market Data Providers](#market-data-providers)
3. [Broker Integration](#broker-integration)
4. [Analytics Services](#analytics-services)
5. [Authentication Services](#authentication-services)
6. [Cloud Storage](#cloud-storage)
7. [Notification Services](#notification-services)
8. [Monitoring & Logging](#monitoring--logging)

---

## Overview

### Integration Architecture

Financial Trading Dimension uses a service-oriented architecture with protocol-based service definitions. This allows for:

- **Easy provider switching**: Swap implementations without changing app code
- **Mock implementations**: Develop and test without real APIs
- **Multiple providers**: Support multiple data sources simultaneously

### Service Protocol Pattern

```swift
// Define protocol
protocol MarketDataService {
    func getQuote(symbol: String) async throws -> MarketData
}

// Production implementation
class AlphaVantageMarketDataService: MarketDataService { }

// Mock for development
class MockMarketDataService: MarketDataService { }

// Dependency injection
@Observable
class AppModel {
    let marketDataService: MarketDataService

    init(marketDataService: MarketDataService) {
        self.marketDataService = marketDataService
    }
}
```

---

## Market Data Providers

### Alpha Vantage Integration

**Purpose**: Real-time and historical stock data

**Setup:**

1. **Get API Key**
   - Sign up at https://www.alphavantage.co/support/#api-key
   - Free tier: 5 API requests per minute, 500 per day
   - Premium tier: Higher limits

2. **Store API Key Securely**

```swift
// Store in Keychain
class KeychainManager {
    func saveAlphaVantageKey(_ key: String) throws {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "alphavantage_api_key",
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
}
```

3. **Implement Service**

```swift
class AlphaVantageMarketDataService: MarketDataService {
    private let apiKey: String
    private let baseURL = "https://www.alphavantage.co/query"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func getQuote(symbol: String) async throws -> MarketData {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apiKey)
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MarketDataError.requestFailed
        }

        let quote = try JSONDecoder().decode(AlphaVantageQuote.self, from: data)
        return quote.toMarketData()
    }

    func getHistoricalData(
        symbol: String,
        range: DateRange,
        interval: Interval
    ) async throws -> [OHLC] {
        // Implementation for TIME_SERIES_DAILY, etc.
    }
}

// Response structure
struct AlphaVantageQuote: Codable {
    let globalQuote: GlobalQuote

    struct GlobalQuote: Codable {
        let symbol: String
        let price: String
        let change: String
        let changePercent: String
        let volume: String
        // ... more fields

        enum CodingKeys: String, CodingKey {
            case symbol = "01. symbol"
            case price = "05. price"
            case change = "09. change"
            case changePercent = "10. change percent"
            case volume = "06. volume"
        }
    }

    func toMarketData() -> MarketData {
        return MarketData(
            symbol: globalQuote.symbol,
            price: Decimal(string: globalQuote.price) ?? 0,
            change: Decimal(string: globalQuote.change) ?? 0,
            // ... map other fields
        )
    }
}
```

4. **Rate Limiting**

```swift
actor RateLimiter {
    private var lastRequestTime: Date?
    private let minimumInterval: TimeInterval = 12 // 5 requests/minute = 12s

    func waitIfNeeded() async {
        if let lastTime = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minimumInterval {
                let waitTime = minimumInterval - elapsed
                try? await Task.sleep(for: .seconds(waitTime))
            }
        }
        lastRequestTime = Date()
    }
}

// Usage in service
class AlphaVantageMarketDataService: MarketDataService {
    private let rateLimiter = RateLimiter()

    func getQuote(symbol: String) async throws -> MarketData {
        await rateLimiter.waitIfNeeded()
        // ... make API call
    }
}
```

**Error Handling:**

```swift
enum AlphaVantageError: Error {
    case rateLimitExceeded
    case invalidAPIKey
    case symbolNotFound
    case networkError(Error)
    case invalidResponse

    var userMessage: String {
        switch self {
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment."
        case .invalidAPIKey:
            return "Invalid API key. Please check your settings."
        case .symbolNotFound:
            return "Symbol not found."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidResponse:
            return "Unexpected response from server."
        }
    }
}
```

### Polygon.io Integration

**Purpose**: Real-time and historical market data with WebSocket support

**Setup:**

1. Sign up at https://polygon.io
2. Get API key
3. Choose plan (free tier available)

**Implementation:**

```swift
class PolygonMarketDataService: MarketDataService {
    private let apiKey: String
    private let baseURL = "https://api.polygon.io"
    private var webSocket: URLSessionWebSocketTask?

    // REST API
    func getQuote(symbol: String) async throws -> MarketData {
        let url = URL(string: "\(baseURL)/v2/snapshot/locale/us/markets/stocks/tickers/\(symbol)?apiKey=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PolygonSnapshot.self, from: data)
        return response.toMarketData()
    }

    // WebSocket for real-time data
    func subscribeToUpdates(symbols: [String]) async throws {
        let url = URL(string: "wss://socket.polygon.io/stocks")!
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()

        // Authenticate
        let authMessage = ["action": "auth", "params": apiKey]
        try await sendMessage(authMessage)

        // Subscribe to symbols
        let subscribeMessage = [
            "action": "subscribe",
            "params": "T.\(symbols.joined(separator: ",T."))"
        ]
        try await sendMessage(subscribeMessage)

        // Start receiving messages
        Task {
            await receiveMessages()
        }
    }

    private func sendMessage(_ message: [String: String]) async throws {
        let data = try JSONEncoder().encode(message)
        let message = URLSessionWebSocketTask.Message.data(data)
        try await webSocket?.send(message)
    }

    private func receiveMessages() async {
        guard let webSocket = webSocket else { return }

        do {
            let message = try await webSocket.receive()

            switch message {
            case .string(let text):
                if let data = text.data(using: .utf8) {
                    processUpdate(data)
                }
            case .data(let data):
                processUpdate(data)
            @unknown default:
                break
            }

            // Continue receiving
            await receiveMessages()
        } catch {
            print("WebSocket error: \(error)")
        }
    }
}
```

---

## Broker Integration

### Interactive Brokers API

**Purpose**: Real trading execution

**Setup:**

1. Open Interactive Brokers account
2. Enable API trading in account settings
3. Install IB Gateway or TWS

**Integration:**

```swift
class InteractiveBrokersService: TradingService {
    private var socket: IBSocket?
    private let host: String
    private let port: Int
    private let clientId: Int

    init(host: String = "127.0.0.1", port: Int = 7497, clientId: Int = 1) {
        self.host = host
        self.port = port
        self.clientId = clientId
    }

    func connect() async throws {
        // Connect to IB Gateway
        socket = try await IBSocket.connect(host: host, port: port)

        // Send connection message
        try await socket?.send(connectionMessage())

        // Start message handler
        Task {
            await handleMessages()
        }
    }

    func placeOrder(
        symbol: String,
        quantity: Int,
        side: OrderSide,
        type: OrderType
    ) async throws -> Order {
        let orderId = generateOrderId()

        // Create IB order
        let ibOrder = IBOrder(
            orderId: orderId,
            action: side == .buy ? "BUY" : "SELL",
            totalQuantity: quantity,
            orderType: type.ibType,
            transmit: true
        )

        // Send order
        try await socket?.send(placeOrderMessage(orderId: orderId, order: ibOrder))

        // Wait for order confirmation
        return try await waitForOrderStatus(orderId: orderId)
    }

    private func handleMessages() async {
        // Process incoming messages from IB
        // Order status updates, fills, errors, etc.
    }
}
```

### Alpaca API

**Purpose**: Commission-free trading API

**Setup:**

1. Sign up at https://alpaca.markets
2. Get API keys (paper trading available)
3. Choose endpoint (paper or live)

**Implementation:**

```swift
class AlpacaTradingService: TradingService {
    private let apiKey: String
    private let secretKey: String
    private let baseURL: String // paper: https://paper-api.alpaca.markets
                                 // live: https://api.alpaca.markets

    init(apiKey: String, secretKey: String, paperTrading: Bool = true) {
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.baseURL = paperTrading
            ? "https://paper-api.alpaca.markets"
            : "https://api.alpaca.markets"
    }

    func placeOrder(
        symbol: String,
        quantity: Int,
        side: OrderSide,
        type: OrderType
    ) async throws -> Order {
        var request = URLRequest(url: URL(string: "\(baseURL)/v2/orders")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "APCA-API-KEY-ID")
        request.setValue(secretKey, forHTTPHeaderField: "APCA-API-SECRET-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let orderRequest = AlpacaOrderRequest(
            symbol: symbol,
            qty: quantity,
            side: side == .buy ? "buy" : "sell",
            type: type.rawValue,
            timeInForce: "day"
        )

        request.httpBody = try JSONEncoder().encode(orderRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TradingError.orderRejected
        }

        let alpacaOrder = try JSONDecoder().decode(AlpacaOrder.self, from: data)
        return alpacaOrder.toOrder()
    }

    func getPositions() async throws -> [Position] {
        var request = URLRequest(url: URL(string: "\(baseURL)/v2/positions")!)
        request.setValue(apiKey, forHTTPHeaderField: "APCA-API-KEY-ID")
        request.setValue(secretKey, forHTTPHeaderField: "APCA-API-SECRET-KEY")

        let (data, _) = try await URLSession.shared.data(for: request)
        let positions = try JSONDecoder().decode([AlpacaPosition].self, from: data)
        return positions.map { $0.toPosition() }
    }

    func getAccount() async throws -> AccountInfo {
        var request = URLRequest(url: URL(string: "\(baseURL)/v2/account")!)
        request.setValue(apiKey, forHTTPHeaderField: "APCA-API-KEY-ID")
        request.setValue(secretKey, forHTTPHeaderField: "APCA-API-SECRET-KEY")

        let (data, _) = try await URLSession.shared.data(for: request)
        let account = try JSONDecoder().decode(AlpacaAccount.self, from: data)
        return account.toAccountInfo()
    }
}
```

---

## Analytics Services

### TradingView Widgets Integration

**Purpose**: Professional charting

**Web View Implementation:**

```swift
import WebKit

class TradingViewChart: WKWebView {
    func loadChart(symbol: String, interval: String = "D") {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
        </head>
        <body>
            <div id="tradingview_chart"></div>
            <script type="text/javascript">
                new TradingView.widget({
                    "container_id": "tradingview_chart",
                    "width": "100%",
                    "height": "100%",
                    "symbol": "\(symbol)",
                    "interval": "\(interval)",
                    "timezone": "America/New_York",
                    "theme": "dark",
                    "style": "1",
                    "locale": "en",
                    "toolbar_bg": "#f1f3f6",
                    "enable_publishing": false,
                    "allow_symbol_change": true,
                    "studies": ["RSI@tv-basicstudies", "MACD@tv-basicstudies"]
                });
            </script>
        </body>
        </html>
        """

        loadHTMLString(html, baseURL: URL(string: "https://www.tradingview.com"))
    }
}
```

### Custom Analytics Engine

**Technical Indicators:**

```swift
class AnalyticsService {
    // Simple Moving Average
    func calculateSMA(data: [Decimal], period: Int) -> [Decimal] {
        guard data.count >= period else { return [] }

        var result: [Decimal] = []

        for i in (period - 1)..<data.count {
            let slice = data[(i - period + 1)...i]
            let sum = slice.reduce(0, +)
            let average = sum / Decimal(period)
            result.append(average)
        }

        return result
    }

    // Relative Strength Index
    func calculateRSI(data: [Decimal], period: Int = 14) -> [Decimal] {
        guard data.count > period else { return [] }

        var gains: [Decimal] = []
        var losses: [Decimal] = []

        // Calculate price changes
        for i in 1..<data.count {
            let change = data[i] - data[i - 1]
            gains.append(change > 0 ? change : 0)
            losses.append(change < 0 ? abs(change) : 0)
        }

        var rsiValues: [Decimal] = []

        // Calculate initial RSI
        let firstGain = gains.prefix(period).reduce(0, +) / Decimal(period)
        let firstLoss = losses.prefix(period).reduce(0, +) / Decimal(period)

        var avgGain = firstGain
        var avgLoss = firstLoss

        // Calculate RSI for each subsequent period
        for i in period..<gains.count {
            avgGain = ((avgGain * Decimal(period - 1)) + gains[i]) / Decimal(period)
            avgLoss = ((avgLoss * Decimal(period - 1)) + losses[i]) / Decimal(period)

            let rs = avgLoss == 0 ? 100 : avgGain / avgLoss
            let rsi = 100 - (100 / (1 + rs))
            rsiValues.append(rsi)
        }

        return rsiValues
    }

    // MACD
    func calculateMACD(
        data: [Decimal],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> MACDResult {
        let fastEMA = calculateEMA(data: data, period: fastPeriod)
        let slowEMA = calculateEMA(data: data, period: slowPeriod)

        var macdLine: [Decimal] = []
        for i in 0..<min(fastEMA.count, slowEMA.count) {
            macdLine.append(fastEMA[i] - slowEMA[i])
        }

        let signalLine = calculateEMA(data: macdLine, period: signalPeriod)

        var histogram: [Decimal] = []
        for i in 0..<signalLine.count {
            histogram.append(macdLine[i] - signalLine[i])
        }

        return MACDResult(
            macdLine: macdLine,
            signalLine: signalLine,
            histogram: histogram
        )
    }

    private func calculateEMA(data: [Decimal], period: Int) -> [Decimal] {
        guard data.count >= period else { return [] }

        let multiplier = 2 / Decimal(period + 1)
        var emaValues: [Decimal] = []

        // First EMA is SMA
        let firstSMA = data.prefix(period).reduce(0, +) / Decimal(period)
        emaValues.append(firstSMA)

        // Calculate EMA for rest
        for i in period..<data.count {
            let ema = (data[i] - emaValues.last!) * multiplier + emaValues.last!
            emaValues.append(ema)
        }

        return emaValues
    }
}
```

---

## Authentication Services

### Firebase Authentication

**Setup:**

1. Create Firebase project
2. Add visionOS app
3. Download GoogleService-Info.plist
4. Install Firebase SDK via SPM

**Implementation:**

```swift
import FirebaseAuth

class FirebaseAuthService: AuthenticationService {
    func signIn(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return User(
            id: result.user.uid,
            email: result.user.email ?? "",
            name: result.user.displayName ?? ""
        )
    }

    func signUp(email: String, password: String, name: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        // Set display name
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()

        return User(
            id: result.user.uid,
            email: result.user.email ?? "",
            name: name
        )
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
```

### Auth0 Integration

**Setup:**

1. Create Auth0 account
2. Create application
3. Configure callback URLs
4. Get domain and client ID

**Implementation:**

```swift
import Auth0

class Auth0Service: AuthenticationService {
    private let domain = "your-domain.auth0.com"
    private let clientId = "your-client-id"

    func signIn() async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            Auth0
                .webAuth(clientId: clientId, domain: domain)
                .audience("https://\(domain)/api/v2/")
                .scope("openid profile email")
                .start { result in
                    switch result {
                    case .success(let credentials):
                        // Get user info
                        Auth0
                            .authentication(clientId: self.clientId, domain: self.domain)
                            .userInfo(withAccessToken: credentials.accessToken)
                            .start { userResult in
                                switch userResult {
                                case .success(let profile):
                                    let user = User(
                                        id: profile.sub,
                                        email: profile.email ?? "",
                                        name: profile.name ?? ""
                                    )
                                    continuation.resume(returning: user)
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                            }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
```

---

## Cloud Storage

### iCloud Integration

**SwiftData with iCloud:**

```swift
import SwiftData

@main
struct FinancialTradingDimensionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Portfolio.self, Position.self], isStoredInMemoryOnly: false) { result in
            switch result {
            case .success(let container):
                // Configure iCloud sync
                container.mainContext.automaticallySavesChanges = true
            case .failure(let error):
                print("Failed to create model container: \(error)")
            }
        }
    }
}
```

### AWS S3 Integration

**For Large File Storage:**

```swift
import AWSS3

class S3StorageService {
    private let s3Client: S3Client
    private let bucketName = "financial-trading-dimension"

    func uploadFile(data: Data, key: String) async throws -> URL {
        let request = PutObjectRequest(
            bucket: bucketName,
            key: key,
            body: data
        )

        _ = try await s3Client.putObject(input: request)

        return URL(string: "https://\(bucketName).s3.amazonaws.com/\(key)")!
    }

    func downloadFile(key: String) async throws -> Data {
        let request = GetObjectRequest(
            bucket: bucketName,
            key: key
        )

        let response = try await s3Client.getObject(input: request)
        return response.body ?? Data()
    }
}
```

---

## Notification Services

### Apple Push Notifications

**Setup:**

1. Enable Push Notifications capability in Xcode
2. Create APNs certificates
3. Implement in app

**Implementation:**

```swift
import UserNotifications

class NotificationService {
    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func handleDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // Send token to your backend
        Task {
            try await uploadDeviceToken(token)
        }
    }

    func scheduleLocalNotification(title: String, body: String, delay: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        try await UNUserNotificationCenter.current().add(request)
    }
}
```

### SendGrid Email Integration

**For Email Notifications:**

```swift
class EmailService {
    private let apiKey: String
    private let baseURL = "https://api.sendgrid.com/v3/mail/send"

    func sendEmail(to: String, subject: String, body: String) async throws {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let email = SendGridEmail(
            personalizations: [Personalization(to: [Email(email: to)])],
            from: Email(email: "noreply@financialtradingdimension.com"),
            subject: subject,
            content: [Content(type: "text/html", value: body)]
        )

        request.httpBody = try JSONEncoder().encode(email)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw EmailError.sendFailed
        }
    }
}
```

---

## Monitoring & Logging

### Datadog Integration

**APM and Logging:**

```swift
import Datadog

class DatadogService {
    func initialize() {
        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(
                    clientToken: "your-client-token",
                    environment: "production"
                )
                .set(serviceName: "financial-trading-dimension")
                .build()
        )

        Logger.builder
            .sendNetworkInfo(true)
            .printLogsToConsole(true)
            .build()
    }

    func logError(_ error: Error, context: [String: Any] = [:]) {
        logger.error("Error occurred", error: error, attributes: context)
    }

    func logEvent(_ name: String, attributes: [String: Any] = [:]) {
        logger.info(name, attributes: attributes)
    }
}
```

### Sentry Crash Reporting

**Setup:**

```swift
import Sentry

class SentryService {
    func initialize() {
        SentrySDK.start { options in
            options.dsn = "your-dsn-here"
            options.environment = "production"
            options.tracesSampleRate = 1.0
            options.profilesSampleRate = 1.0
            options.enableAppHangTracking = true
        }
    }

    func captureError(_ error: Error, context: [String: Any] = [:]) {
        SentrySDK.capture(error: error) { scope in
            for (key, value) in context {
                scope.setExtra(value: value, key: key)
            }
        }
    }

    func addBreadcrumb(_ message: String, category: String) {
        let breadcrumb = Breadcrumb()
        breadcrumb.message = message
        breadcrumb.category = category
        breadcrumb.level = .info
        SentrySDK.addBreadcrumb(breadcrumb)
    }
}
```

---

## Environment Configuration

### Managing Multiple Environments

**Config.swift:**

```swift
enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var apiBaseURL: String {
        switch self {
        case .development:
            return "http://localhost:8080/api/v1"
        case .staging:
            return "https://api-staging.financialtradingdimension.com/v1"
        case .production:
            return "https://api.financialtradingdimension.com/v1"
        }
    }

    var useMockServices: Bool {
        return self == .development
    }
}
```

### Service Factory

**Create appropriate implementations based on environment:**

```swift
class ServiceFactory {
    static func createMarketDataService() -> MarketDataService {
        if Environment.current.useMockServices {
            return MockMarketDataService()
        } else {
            let apiKey = try! KeychainManager.shared.getAlphaVantageKey()
            return AlphaVantageMarketDataService(apiKey: apiKey)
        }
    }

    static func createTradingService() -> TradingService {
        if Environment.current.useMockServices {
            return MockTradingService()
        } else {
            let apiKey = try! KeychainManager.shared.getAlpacaAPIKey()
            let secretKey = try! KeychainManager.shared.getAlpacaSecretKey()
            return AlpacaTradingService(
                apiKey: apiKey,
                secretKey: secretKey,
                paperTrading: Environment.current == .development
            )
        }
    }
}

// Usage
@Observable
class AppModel {
    let marketDataService: MarketDataService
    let tradingService: TradingService

    init() {
        self.marketDataService = ServiceFactory.createMarketDataService()
        self.tradingService = ServiceFactory.createTradingService()
    }
}
```

---

## Testing Integrations

### Mock Services

Always provide mock implementations for testing:

```swift
class MockMarketDataService: MarketDataService {
    func getQuote(symbol: String) async throws -> MarketData {
        // Return predefined mock data
        return MarketData(
            symbol: symbol,
            price: Decimal(string: "189.45")!,
            change: Decimal(string: "2.15")!,
            changePercent: Decimal(string: "1.15")!,
            volume: 52_478_930,
            timestamp: Date()
        )
    }
}
```

### Integration Tests

```swift
class IntegrationTests: XCTestCase {
    func testAlphaVantageIntegration() async throws {
        let service = AlphaVantageMarketDataService(apiKey: testAPIKey)
        let quote = try await service.getQuote(symbol: "AAPL")

        XCTAssertEqual(quote.symbol, "AAPL")
        XCTAssertGreaterThan(quote.price, 0)
    }
}
```

---

## Best Practices

1. **Always use protocols** for service definitions
2. **Store credentials securely** in Keychain
3. **Implement rate limiting** to avoid API limits
4. **Provide mock implementations** for development
5. **Handle errors gracefully** with user-friendly messages
6. **Log integration events** for debugging
7. **Test with real APIs** before production
8. **Monitor API usage** and costs
9. **Have fallback options** for critical services
10. **Document all integrations** thoroughly

---

## Support

For integration assistance:
- **Email**: integrations@financialtradingdimension.com
- **Documentation**: https://docs.financialtradingdimension.com/integrations
- **Community**: https://community.financialtradingdimension.com

---

**Last Updated**: 2025-11-17
**Version**: 1.0
