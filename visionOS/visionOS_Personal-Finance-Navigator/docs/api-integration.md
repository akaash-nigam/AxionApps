# API Integration Design
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Overview](#overview)
2. [Plaid Integration](#plaid-integration)
3. [API Client Architecture](#api-client-architecture)
4. [Authentication & Security](#authentication--security)
5. [Error Handling & Retry Logic](#error-handling--retry-logic)
6. [Rate Limiting](#rate-limiting)
7. [Webhook Integration](#webhook-integration)
8. [Testing & Mock Data](#testing--mock-data)

## Overview

Personal Finance Navigator integrates with external APIs to fetch banking data, investment information, and market data. The primary integration is with Plaid for banking connectivity.

### Key Integrations
- **Plaid**: Banking data (accounts, transactions, balances)
- **CloudKit**: User data synchronization
- **Market Data** (Future): Real-time investment prices
- **Notification Service**: Push notifications

## Plaid Integration

### Plaid Link Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Flow                                 │
└─────────────────────────────────────────────────────────────────┘

1. User taps "Connect Bank Account"
         ↓
2. App requests Link Token from backend/Plaid
         ↓
3. Present Plaid Link UI
         ↓
4. User selects bank, enters credentials
         ↓
5. Plaid returns public_token
         ↓
6. Exchange public_token for access_token
         ↓
7. Store encrypted access_token in Keychain
         ↓
8. Fetch accounts and transactions
         ↓
9. Store in Core Data
         ↓
10. CloudKit sync (automatic)
```

### Plaid Configuration

```swift
// PlaidConfiguration.swift
struct PlaidConfiguration {
    static let clientId = Configuration.plaidClientId
    static let secret = Configuration.plaidSecret
    static let environment: PlaidEnvironment = {
        #if DEBUG
        return .sandbox
        #else
        return .production
        #endif
    }()

    static let products: [PlaidProduct] = [
        .transactions,
        .auth,
        .balance,
        .investments // Premium tier only
    ]

    static let countryCodes = ["US", "CA"]
}

enum PlaidEnvironment: String {
    case sandbox
    case development
    case production
}
```

### Link Token Creation

```swift
// PlaidLinkManager.swift
actor PlaidLinkManager {
    private let apiClient: PlaidAPIClient

    func createLinkToken(for userId: String) async throws -> String {
        let request = LinkTokenCreateRequest(
            user: User(clientUserId: userId),
            clientName: "Personal Finance Navigator",
            products: PlaidConfiguration.products,
            countryCodes: PlaidConfiguration.countryCodes,
            language: "en",
            webhook: Configuration.webhookURL
        )

        let response = try await apiClient.createLinkToken(request)
        return response.linkToken
    }
}

// Usage in SwiftUI
struct ConnectBankView: View {
    @State private var linkToken: String?
    @State private var showPlaidLink = false

    var body: some View {
        Button("Connect Bank Account") {
            Task {
                linkToken = try await plaidLinkManager.createLinkToken(
                    for: userProfile.id
                )
                showPlaidLink = true
            }
        }
        .sheet(isPresented: $showPlaidLink) {
            if let linkToken {
                PlaidLinkView(
                    linkToken: linkToken,
                    onSuccess: handlePlaidSuccess,
                    onExit: handlePlaidExit
                )
            }
        }
    }
}
```

### Token Exchange

```swift
// PlaidService.swift
class PlaidService {
    private let apiClient: PlaidAPIClient
    private let secureStorage: SecureStorage

    func exchangePublicToken(
        _ publicToken: String
    ) async throws -> PlaidAccessToken {
        let request = PublicTokenExchangeRequest(publicToken: publicToken)
        let response = try await apiClient.exchangePublicToken(request)

        // Store encrypted access token
        try secureStorage.save(
            response.accessToken,
            forKey: "plaid_access_token_\(response.itemId)"
        )

        return PlaidAccessToken(
            accessToken: response.accessToken,
            itemId: response.itemId
        )
    }
}
```

### Account Fetching

```swift
// BankingService.swift
actor BankingService {
    private let plaidClient: PlaidAPIClient
    private let accountRepository: AccountRepository

    func syncAccounts(itemId: String) async throws -> [Account] {
        // Get access token from secure storage
        guard let accessToken = try secureStorage.get(
            forKey: "plaid_access_token_\(itemId)"
        ) else {
            throw BankingError.missingAccessToken
        }

        // Fetch accounts from Plaid
        let request = AccountsGetRequest(accessToken: accessToken)
        let response = try await plaidClient.getAccounts(request)

        // Transform Plaid accounts to domain models
        let accounts = response.accounts.map { plaidAccount in
            Account(
                id: UUID(),
                plaidAccountId: plaidAccount.accountId,
                plaidItemId: itemId,
                name: plaidAccount.name,
                officialName: plaidAccount.officialName,
                type: AccountType(plaidType: plaidAccount.type),
                subtype: plaidAccount.subtype?.rawValue,
                mask: plaidAccount.mask,
                currentBalance: plaidAccount.balances.current,
                availableBalance: plaidAccount.balances.available,
                creditLimit: plaidAccount.balances.limit,
                isActive: true,
                isHidden: false,
                needsReconnection: false,
                institutionName: nil, // Fetch separately
                lastSyncedAt: Date(),
                createdAt: Date(),
                updatedAt: Date()
            )
        }

        // Save to Core Data
        try await accountRepository.saveAll(accounts)

        return accounts
    }
}
```

### Transaction Syncing

```swift
// TransactionSyncService.swift
actor TransactionSyncService {
    private let plaidClient: PlaidAPIClient
    private let transactionRepository: TransactionRepository
    private let categorizer: TransactionCategorizer

    func syncTransactions(
        for itemId: String,
        since startDate: Date? = nil
    ) async throws -> [Transaction] {
        guard let accessToken = try secureStorage.get(
            forKey: "plaid_access_token_\(itemId)"
        ) else {
            throw BankingError.missingAccessToken
        }

        // Use cursor-based pagination for large datasets
        var allTransactions: [PlaidTransaction] = []
        var cursor: String?
        var hasMore = true

        while hasMore {
            let request = TransactionsSyncRequest(
                accessToken: accessToken,
                cursor: cursor,
                count: 500 // Max per request
            )

            let response = try await plaidClient.syncTransactions(request)
            allTransactions.append(contentsOf: response.added)

            // Handle modified transactions
            for modified in response.modified {
                try await transactionRepository.update(modified)
            }

            // Handle removed transactions
            for removed in response.removed {
                try await transactionRepository.delete(id: removed.transactionId)
            }

            cursor = response.nextCursor
            hasMore = response.hasMore
        }

        // Transform and categorize
        let transactions = try await allTransactions.asyncMap { plaidTx in
            let category = await categorizer.categorize(plaidTx)

            return Transaction(
                id: UUID(),
                plaidTransactionId: plaidTx.transactionId,
                accountId: try await getAccountId(plaidAccountId: plaidTx.accountId),
                amount: plaidTx.amount,
                date: plaidTx.date,
                authorizedDate: plaidTx.authorizedDate,
                merchantName: plaidTx.merchantName,
                name: plaidTx.name,
                pending: plaidTx.pending,
                categoryId: category?.id,
                primaryCategory: plaidTx.category?.first ?? "Uncategorized",
                detailedCategory: plaidTx.category?.last,
                isRecurring: false, // Detect later
                confidence: category?.confidence,
                paymentChannel: PaymentChannel(plaidChannel: plaidTx.paymentChannel),
                isUserModified: false,
                isHidden: false,
                isExcludedFromBudget: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        }

        // Save in batches
        try await transactionRepository.saveAll(transactions)

        return transactions
    }
}
```

### Investment Data Fetching

```swift
// InvestmentSyncService.swift
actor InvestmentSyncService {
    func syncInvestments(for itemId: String) async throws -> InvestmentAccount {
        guard let accessToken = try secureStorage.get(
            forKey: "plaid_access_token_\(itemId)"
        ) else {
            throw BankingError.missingAccessToken
        }

        let request = InvestmentHoldingsGetRequest(accessToken: accessToken)
        let response = try await plaidClient.getInvestmentHoldings(request)

        let holdings = response.holdings.map { plaidHolding in
            Holding(
                id: UUID(),
                investmentAccountId: UUID(), // Resolve from account
                ticker: plaidHolding.security.tickerSymbol ?? "",
                name: plaidHolding.security.name,
                type: SecurityType(plaidType: plaidHolding.security.type),
                cusip: plaidHolding.security.cusip,
                quantity: plaidHolding.quantity,
                costBasis: plaidHolding.costBasis,
                currentPrice: plaidHolding.institutionPrice,
                currentValue: plaidHolding.institutionValue,
                totalGain: plaidHolding.institutionValue - plaidHolding.costBasis,
                totalGainPercent: Float(
                    (plaidHolding.institutionValue - plaidHolding.costBasis)
                    / plaidHolding.costBasis * 100
                ),
                lastUpdated: Date(),
                createdAt: Date()
            )
        }

        // Calculate totals and save
        let investmentAccount = InvestmentAccount(
            id: UUID(),
            accountId: UUID(), // Resolve
            type: .brokerage, // Determine from account
            totalValue: holdings.reduce(0) { $0 + $1.currentValue },
            totalCost: holdings.reduce(0) { $0 + $1.costBasis },
            totalGain: holdings.reduce(0) { $0 + $1.totalGain },
            totalGainPercent: 0, // Calculate
            lastSyncedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )

        try await investmentRepository.save(investmentAccount, with: holdings)

        return investmentAccount
    }
}
```

## API Client Architecture

### Base Network Client

```swift
// NetworkClient.swift
actor NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true

        self.session = URLSession(configuration: configuration)

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T {
        let urlRequest = try buildURLRequest(from: endpoint)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    private func buildURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path)
        urlComponents?.queryItems = endpoint.queryItems

        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }
}
```

### Endpoint Protocol

```swift
// Endpoint.swift
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// Plaid-specific endpoints
enum PlaidEndpoint: Endpoint {
    case createLinkToken(LinkTokenCreateRequest)
    case exchangePublicToken(PublicTokenExchangeRequest)
    case getAccounts(AccountsGetRequest)
    case syncTransactions(TransactionsSyncRequest)
    case getInvestmentHoldings(InvestmentHoldingsGetRequest)

    var baseURL: String {
        switch PlaidConfiguration.environment {
        case .sandbox:
            return "https://sandbox.plaid.com"
        case .development:
            return "https://development.plaid.com"
        case .production:
            return "https://production.plaid.com"
        }
    }

    var path: String {
        switch self {
        case .createLinkToken:
            return "/link/token/create"
        case .exchangePublicToken:
            return "/item/public_token/exchange"
        case .getAccounts:
            return "/accounts/get"
        case .syncTransactions:
            return "/transactions/sync"
        case .getInvestmentHoldings:
            return "/investments/holdings/get"
        }
    }

    var method: HTTPMethod {
        .post // All Plaid endpoints use POST
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "PLAID-CLIENT-ID": PlaidConfiguration.clientId,
            "PLAID-SECRET": PlaidConfiguration.secret
        ]
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Encodable? {
        switch self {
        case .createLinkToken(let request):
            return request
        case .exchangePublicToken(let request):
            return request
        case .getAccounts(let request):
            return request
        case .syncTransactions(let request):
            return request
        case .getInvestmentHoldings(let request):
            return request
        }
    }
}
```

### Plaid API Client

```swift
// PlaidAPIClient.swift
actor PlaidAPIClient {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }

    func createLinkToken(
        _ request: LinkTokenCreateRequest
    ) async throws -> LinkTokenCreateResponse {
        try await networkClient.request(
            PlaidEndpoint.createLinkToken(request)
        )
    }

    func exchangePublicToken(
        _ request: PublicTokenExchangeRequest
    ) async throws -> PublicTokenExchangeResponse {
        try await networkClient.request(
            PlaidEndpoint.exchangePublicToken(request)
        )
    }

    func getAccounts(
        _ request: AccountsGetRequest
    ) async throws -> AccountsGetResponse {
        try await networkClient.request(
            PlaidEndpoint.getAccounts(request)
        )
    }

    func syncTransactions(
        _ request: TransactionsSyncRequest
    ) async throws -> TransactionsSyncResponse {
        try await networkClient.request(
            PlaidEndpoint.syncTransactions(request)
        )
    }

    func getInvestmentHoldings(
        _ request: InvestmentHoldingsGetRequest
    ) async throws -> InvestmentHoldingsGetResponse {
        try await networkClient.request(
            PlaidEndpoint.getInvestmentHoldings(request)
        )
    }
}
```

## Authentication & Security

### Secure Token Storage

```swift
// SecureStorage.swift
actor SecureStorage {
    func save(_ value: String, forKey key: String) throws {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed(status)
        }
    }

    func get(forKey key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            if status == errSecItemNotFound {
                return nil
            }
            throw SecureStorageError.retrievalFailed(status)
        }

        return value
    }

    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deletionFailed(status)
        }
    }
}
```

### Token Refresh

```swift
// TokenManager.swift
actor TokenManager {
    private let plaidClient: PlaidAPIClient
    private let secureStorage: SecureStorage

    func refreshAccessTokenIfNeeded(itemId: String) async throws {
        // Plaid access tokens don't expire, but item may need re-authentication
        let healthRequest = ItemHealthGetRequest(
            accessToken: try getAccessToken(itemId: itemId)
        )

        do {
            _ = try await plaidClient.getItemHealth(healthRequest)
            // Token is healthy
        } catch let error as PlaidError where error.code == "ITEM_LOGIN_REQUIRED" {
            // User needs to re-authenticate
            throw BankingError.reconnectionRequired(itemId: itemId)
        }
    }

    private func getAccessToken(itemId: String) throws -> String {
        guard let token = try secureStorage.get(
            forKey: "plaid_access_token_\(itemId)"
        ) else {
            throw BankingError.missingAccessToken
        }
        return token
    }
}
```

## Error Handling & Retry Logic

### Plaid Error Handling

```swift
// PlaidError.swift
struct PlaidError: Codable, LocalizedError {
    let errorType: String
    let errorCode: String
    let errorMessage: String
    let displayMessage: String?

    var errorDescription: String? {
        displayMessage ?? errorMessage
    }

    var requiresUserAction: Bool {
        [
            "ITEM_LOGIN_REQUIRED",
            "INVALID_CREDENTIALS",
            "INVALID_MFA"
        ].contains(errorCode)
    }

    var isRetryable: Bool {
        [
            "INSTITUTION_DOWN",
            "INSTITUTION_NOT_RESPONDING",
            "RATE_LIMIT_EXCEEDED"
        ].contains(errorCode)
    }
}
```

### Retry Logic

```swift
// RetryPolicy.swift
actor RetryPolicy {
    func execute<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 2.0,
        multiplier: Double = 2.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var currentAttempt = 0
        var currentDelay = initialDelay

        while currentAttempt < maxAttempts {
            do {
                return try await operation()
            } catch let error as PlaidError where error.isRetryable {
                currentAttempt += 1

                guard currentAttempt < maxAttempts else {
                    throw error
                }

                Logger.network.info(
                    "Retrying operation (attempt \(currentAttempt)/\(maxAttempts)) after \(currentDelay)s"
                )

                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                currentDelay *= multiplier
            } catch {
                throw error
            }
        }

        fatalError("Unreachable")
    }
}

// Usage
let transactions = try await retryPolicy.execute {
    try await transactionSyncService.syncTransactions(for: itemId)
}
```

### Network Error Handling

```swift
// NetworkError.swift
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    case noInternetConnection
    case timeout
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request was cancelled"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .httpError(let statusCode, _):
            return [408, 429, 500, 502, 503, 504].contains(statusCode)
        case .timeout, .noInternetConnection:
            return true
        default:
            return false
        }
    }
}
```

## Rate Limiting

### Rate Limiter

```swift
// RateLimiter.swift
actor RateLimiter {
    private var requestTimestamps: [Date] = []
    private let maxRequests: Int
    private let timeWindow: TimeInterval

    init(maxRequests: Int = 100, timeWindow: TimeInterval = 60) {
        self.maxRequests = maxRequests
        self.timeWindow = timeWindow
    }

    func waitForAvailability() async {
        cleanOldTimestamps()

        while requestTimestamps.count >= maxRequests {
            let oldestRequest = requestTimestamps.first!
            let waitTime = timeWindow - Date().timeIntervalSince(oldestRequest)

            if waitTime > 0 {
                Logger.network.info("Rate limit reached. Waiting \(waitTime)s")
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }

            cleanOldTimestamps()
        }

        requestTimestamps.append(Date())
    }

    private func cleanOldTimestamps() {
        let cutoff = Date().addingTimeInterval(-timeWindow)
        requestTimestamps.removeAll { $0 < cutoff }
    }
}

// Usage in API client
actor PlaidAPIClient {
    private let rateLimiter = RateLimiter(maxRequests: 100, timeWindow: 60)

    func syncTransactions(_ request: TransactionsSyncRequest) async throws -> TransactionsSyncResponse {
        await rateLimiter.waitForAvailability()
        return try await networkClient.request(PlaidEndpoint.syncTransactions(request))
    }
}
```

## Webhook Integration

### Webhook Handler

```swift
// WebhookHandler.swift
actor WebhookHandler {
    private let transactionSyncService: TransactionSyncService
    private let accountService: AccountService

    func handle(_ webhook: PlaidWebhook) async throws {
        Logger.webhook.info("Received webhook: \(webhook.webhookType) - \(webhook.webhookCode)")

        switch (webhook.webhookType, webhook.webhookCode) {
        case ("TRANSACTIONS", "SYNC_UPDATES_AVAILABLE"):
            // New transactions available
            try await handleTransactionUpdate(webhook)

        case ("ITEM", "PENDING_EXPIRATION"):
            // Access token expiring soon
            try await handleTokenExpiration(webhook)

        case ("ITEM", "ERROR"):
            // Item error (reconnection required)
            try await handleItemError(webhook)

        case ("ITEM", "WEBHOOK_UPDATE_ACKNOWLEDGED"):
            // Webhook configuration confirmed
            Logger.webhook.info("Webhook acknowledged")

        default:
            Logger.webhook.warning("Unhandled webhook: \(webhook.webhookType) - \(webhook.webhookCode)")
        }
    }

    private func handleTransactionUpdate(_ webhook: PlaidWebhook) async throws {
        guard let itemId = webhook.itemId else { return }

        // Trigger background sync
        try await transactionSyncService.syncTransactions(for: itemId)

        // Post notification for UI update
        NotificationCenter.default.post(
            name: .transactionsUpdated,
            object: nil,
            userInfo: ["itemId": itemId]
        )
    }

    private func handleTokenExpiration(_ webhook: PlaidWebhook) async throws {
        guard let itemId = webhook.itemId else { return }

        // Mark account as needing reconnection
        try await accountService.markNeedsReconnection(itemId: itemId)

        // Notify user
        try await sendReconnectionNotification(itemId: itemId)
    }

    private func handleItemError(_ webhook: PlaidWebhook) async throws {
        guard let itemId = webhook.itemId,
              let error = webhook.error else { return }

        Logger.webhook.error("Item error for \(itemId): \(error.errorMessage)")

        if error.errorCode == "ITEM_LOGIN_REQUIRED" {
            try await accountService.markNeedsReconnection(itemId: itemId)
            try await sendReconnectionNotification(itemId: itemId)
        }
    }
}

// Webhook models
struct PlaidWebhook: Codable {
    let webhookType: String
    let webhookCode: String
    let itemId: String?
    let error: PlaidError?
    let newTransactions: Int?
    let removedTransactions: [String]?
}
```

### Webhook Endpoint (if using custom backend)

```swift
// WebhookEndpoint.swift (Vapor example)
func routes(_ app: Application) throws {
    app.post("webhooks", "plaid") { req async throws -> HTTPStatus in
        let webhook = try req.content.decode(PlaidWebhook.self)

        // Verify webhook signature
        guard try verifyWebhookSignature(req) else {
            throw Abort(.unauthorized)
        }

        // Handle asynchronously
        Task {
            try await webhookHandler.handle(webhook)
        }

        return .ok
    }
}

func verifyWebhookSignature(_ req: Request) throws -> Bool {
    guard let signature = req.headers.first(name: "Plaid-Verification") else {
        return false
    }

    let payload = req.body.string ?? ""
    let secret = Configuration.plaidWebhookSecret

    let hmac = HMAC<SHA256>.authenticationCode(
        for: Data(payload.utf8),
        using: SymmetricKey(data: Data(secret.utf8))
    )

    return Data(hmac).base64EncodedString() == signature
}
```

## Testing & Mock Data

### Mock Plaid Client

```swift
// MockPlaidAPIClient.swift
#if DEBUG
actor MockPlaidAPIClient: PlaidAPIClient {
    var shouldFail = false
    var delaySeconds: TimeInterval = 0

    override func syncTransactions(
        _ request: TransactionsSyncRequest
    ) async throws -> TransactionsSyncResponse {
        if delaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
        }

        if shouldFail {
            throw PlaidError(
                errorType: "INSTITUTION_ERROR",
                errorCode: "INSTITUTION_DOWN",
                errorMessage: "The institution is temporarily unavailable",
                displayMessage: "Your bank is temporarily unavailable. Please try again later."
            )
        }

        return TransactionsSyncResponse(
            added: MockData.transactions,
            modified: [],
            removed: [],
            nextCursor: "mock_cursor",
            hasMore: false
        )
    }

    override func getAccounts(
        _ request: AccountsGetRequest
    ) async throws -> AccountsGetResponse {
        if shouldFail {
            throw PlaidError(
                errorType: "INVALID_REQUEST",
                errorCode: "INVALID_ACCESS_TOKEN",
                errorMessage: "The access token is invalid",
                displayMessage: "Please reconnect your bank account"
            )
        }

        return AccountsGetResponse(
            accounts: MockData.accounts,
            item: MockData.item
        )
    }
}
#endif
```

### Mock Data

```swift
// MockData.swift
#if DEBUG
enum MockData {
    static let accounts = [
        PlaidAccount(
            accountId: "mock_account_1",
            balances: PlaidBalances(
                current: 5432.10,
                available: 5432.10,
                limit: nil
            ),
            mask: "1234",
            name: "Chase Checking",
            officialName: "Chase Total Checking",
            type: .depository,
            subtype: .checking
        ),
        PlaidAccount(
            accountId: "mock_account_2",
            balances: PlaidBalances(
                current: -2150.50,
                available: 2849.50,
                limit: 5000
            ),
            mask: "5678",
            name: "Amex Blue",
            officialName: "American Express Blue Cash",
            type: .credit,
            subtype: .creditCard
        )
    ]

    static let transactions = [
        PlaidTransaction(
            transactionId: "mock_tx_1",
            accountId: "mock_account_1",
            amount: -45.67,
            date: Date(),
            authorizedDate: Date(),
            merchantName: "Whole Foods",
            name: "WHOLE FOODS MARKET #123",
            pending: false,
            category: ["Food and Drink", "Groceries"],
            paymentChannel: .inStore
        ),
        PlaidTransaction(
            transactionId: "mock_tx_2",
            accountId: "mock_account_1",
            amount: -120.00,
            date: Date().addingTimeInterval(-86400),
            authorizedDate: Date().addingTimeInterval(-86400),
            merchantName: "Shell",
            name: "SHELL GAS STATION",
            pending: false,
            category: ["Transportation", "Gas"],
            paymentChannel: .inStore
        ),
        PlaidTransaction(
            transactionId: "mock_tx_3",
            accountId: "mock_account_2",
            amount: -15.99,
            date: Date().addingTimeInterval(-172800),
            authorizedDate: nil,
            merchantName: "Netflix",
            name: "NETFLIX.COM",
            pending: false,
            category: ["Entertainment", "Streaming"],
            paymentChannel: .online
        )
    ]

    static let item = PlaidItem(
        itemId: "mock_item_1",
        institutionId: "ins_1",
        webhook: nil,
        availableProducts: [.transactions, .auth, .balance],
        billedProducts: [.transactions],
        consentExpirationTime: nil
    )
}
#endif
```

### Sandbox Mode

```swift
// Configuration.swift
struct Configuration {
    static var usePlaidSandbox: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var plaidEnvironment: PlaidEnvironment {
        usePlaidSandbox ? .sandbox : .production
    }

    // Sandbox credentials for testing
    static let sandboxUsername = "user_good"
    static let sandboxPassword = "pass_good"
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: Security & Privacy Implementation Plan
