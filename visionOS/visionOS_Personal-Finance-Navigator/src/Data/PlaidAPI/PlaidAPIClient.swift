// PlaidAPIClient.swift
// Personal Finance Navigator
// HTTP client for Plaid API

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "plaid")

/// HTTP client for communicating with Plaid API
actor PlaidAPIClient {
    // MARK: - Configuration

    private let clientId: String
    private let secret: String
    private let environment: PlaidEnvironment
    private let session: URLSession

    private var baseURL: String {
        switch environment {
        case .sandbox:
            return "https://sandbox.plaid.com"
        case .development:
            return "https://development.plaid.com"
        case .production:
            return "https://production.plaid.com"
        }
    }

    // MARK: - Init

    init(
        clientId: String,
        secret: String,
        environment: PlaidEnvironment = .sandbox,
        session: URLSession = .shared
    ) {
        self.clientId = clientId
        self.secret = secret
        self.environment = environment
        self.session = session
    }

    // MARK: - Link Token

    /// Creates a link token for Plaid Link initialization
    func createLinkToken(userId: String) async throws -> LinkTokenResponse {
        let request = LinkTokenRequest(
            clientId: clientId,
            secret: secret,
            user: LinkUser(clientUserId: userId),
            clientName: "Personal Finance Navigator",
            products: ["auth", "transactions"],
            countryCodes: ["US"],
            language: "en"
        )

        return try await post(path: "/link/token/create", body: request)
    }

    // MARK: - Token Exchange

    /// Exchanges public token for access token
    func exchangePublicToken(_ publicToken: String) async throws -> TokenExchangeResponse {
        let request = TokenExchangeRequest(
            clientId: clientId,
            secret: secret,
            publicToken: publicToken
        )

        return try await post(path: "/item/public_token/exchange", body: request)
    }

    // MARK: - Accounts

    /// Fetches accounts for an access token
    func getAccounts(accessToken: String) async throws -> AccountsResponse {
        let request = AccountsRequest(
            clientId: clientId,
            secret: secret,
            accessToken: accessToken
        )

        return try await post(path: "/accounts/get", body: request)
    }

    // MARK: - Transactions

    /// Fetches transactions for a date range
    func getTransactions(
        accessToken: String,
        startDate: Date,
        endDate: Date
    ) async throws -> TransactionsResponse {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        let request = TransactionsRequest(
            clientId: clientId,
            secret: secret,
            accessToken: accessToken,
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            options: TransactionsOptions(count: 500, offset: 0)
        )

        return try await post(path: "/transactions/get", body: request)
    }

    /// Syncs transactions (newer API with cursor-based pagination)
    func syncTransactions(
        accessToken: String,
        cursor: String? = nil
    ) async throws -> TransactionsSyncResponse {
        let request = TransactionsSyncRequest(
            clientId: clientId,
            secret: secret,
            accessToken: accessToken,
            cursor: cursor
        )

        return try await post(path: "/transactions/sync", body: request)
    }

    // MARK: - Item Management

    /// Gets information about a Plaid item (institution connection)
    func getItem(accessToken: String) async throws -> ItemResponse {
        let request = ItemRequest(
            clientId: clientId,
            secret: secret,
            accessToken: accessToken
        )

        return try await post(path: "/item/get", body: request)
    }

    /// Removes a Plaid item (disconnects institution)
    func removeItem(accessToken: String) async throws -> RemoveItemResponse {
        let request = ItemRequest(
            clientId: clientId,
            secret: secret,
            accessToken: accessToken
        )

        return try await post(path: "/item/remove", body: request)
    }

    // MARK: - Balance

    /// Gets real-time balance for accounts
    func getBalance(accessToken: String) async throws -> BalanceResponse {
        let request = BalanceRequest(
            clientId: clientId,
            secret: secret,
            accessToken: accessToken
        )

        return try await post(path: "/accounts/balance/get", body: request)
    }

    // MARK: - HTTP Methods

    private func post<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request
    ) async throws -> Response {
        let url = URL(string: baseURL + path)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        logger.debug("Plaid API request: \(path)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlaidError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error response
            if let errorResponse = try? JSONDecoder().decode(PlaidErrorResponse.self, from: data) {
                logger.error("Plaid API error: \(errorResponse.errorMessage)")
                throw PlaidError.apiError(errorResponse)
            }
            throw PlaidError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let result = try decoder.decode(Response.self, from: data)
            logger.debug("Plaid API success: \(path)")
            return result
        } catch {
            logger.error("Plaid decode error: \(error.localizedDescription)")
            throw PlaidError.decodingError(error)
        }
    }
}

// MARK: - Configuration

enum PlaidEnvironment {
    case sandbox
    case development
    case production
}

// MARK: - Errors

enum PlaidError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case apiError(PlaidErrorResponse)
    case decodingError(Error)
    case invalidToken
    case itemLoginRequired

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Plaid"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let response):
            return response.errorMessage
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidToken:
            return "Invalid access token"
        case .itemLoginRequired:
            return "Please reconnect your bank account"
        }
    }
}

// MARK: - Request Models

struct LinkTokenRequest: Encodable {
    let clientId: String
    let secret: String
    let user: LinkUser
    let clientName: String
    let products: [String]
    let countryCodes: [String]
    let language: String
}

struct LinkUser: Encodable {
    let clientUserId: String
}

struct TokenExchangeRequest: Encodable {
    let clientId: String
    let secret: String
    let publicToken: String
}

struct AccountsRequest: Encodable {
    let clientId: String
    let secret: String
    let accessToken: String
}

struct TransactionsRequest: Encodable {
    let clientId: String
    let secret: String
    let accessToken: String
    let startDate: String
    let endDate: String
    let options: TransactionsOptions
}

struct TransactionsOptions: Encodable {
    let count: Int
    let offset: Int
}

struct TransactionsSyncRequest: Encodable {
    let clientId: String
    let secret: String
    let accessToken: String
    let cursor: String?
}

struct ItemRequest: Encodable {
    let clientId: String
    let secret: String
    let accessToken: String
}

struct BalanceRequest: Encodable {
    let clientId: String
    let secret: String
    let accessToken: String
}

// MARK: - Response Models

struct LinkTokenResponse: Decodable {
    let linkToken: String
    let expiration: String
    let requestId: String
}

struct TokenExchangeResponse: Decodable {
    let accessToken: String
    let itemId: String
    let requestId: String
}

struct AccountsResponse: Decodable {
    let accounts: [PlaidAccount]
    let item: PlaidItem
    let requestId: String
}

struct PlaidAccount: Decodable {
    let accountId: String
    let balances: PlaidBalance
    let mask: String?
    let name: String
    let officialName: String?
    let type: String
    let subtype: String?
}

struct PlaidBalance: Decodable {
    let available: Double?
    let current: Double
    let limit: Double?
    let isoCurrencyCode: String?
    let unofficialCurrencyCode: String?
}

struct PlaidItem: Decodable {
    let itemId: String
    let institutionId: String?
    let webhook: String?
    let error: PlaidErrorResponse?
    let availableProducts: [String]
    let billedProducts: [String]
    let consentExpirationTime: String?
    let updateType: String
}

struct TransactionsResponse: Decodable {
    let accounts: [PlaidAccount]
    let transactions: [PlaidTransaction]
    let totalTransactions: Int
    let item: PlaidItem
    let requestId: String
}

struct PlaidTransaction: Decodable {
    let transactionId: String
    let accountId: String
    let amount: Double
    let isoCurrencyCode: String?
    let unofficialCurrencyCode: String?
    let category: [String]?
    let categoryId: String?
    let date: String
    let authorizedDate: String?
    let name: String
    let merchantName: String?
    let pending: Bool
    let pendingTransactionId: String?
    let paymentChannel: String
    let location: PlaidLocation?
}

struct PlaidLocation: Decodable {
    let address: String?
    let city: String?
    let region: String?
    let postalCode: String?
    let country: String?
    let lat: Double?
    let lon: Double?
}

struct TransactionsSyncResponse: Decodable {
    let added: [PlaidTransaction]
    let modified: [PlaidTransaction]
    let removed: [RemovedTransaction]
    let nextCursor: String
    let hasMore: Bool
    let requestId: String
}

struct RemovedTransaction: Decodable {
    let transactionId: String
}

struct ItemResponse: Decodable {
    let item: PlaidItem
    let status: ItemStatus?
    let requestId: String
}

struct ItemStatus: Decodable {
    let transactions: TransactionsStatus?
}

struct TransactionsStatus: Decodable {
    let lastSuccessfulUpdate: String?
    let lastFailedUpdate: String?
}

struct RemoveItemResponse: Decodable {
    let requestId: String
}

struct BalanceResponse: Decodable {
    let accounts: [PlaidAccount]
    let item: PlaidItem
    let requestId: String
}

struct PlaidErrorResponse: Decodable {
    let errorType: String
    let errorCode: String
    let errorMessage: String
    let displayMessage: String?
    let requestId: String?
}
