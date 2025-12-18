# API Integration Specifications
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Table of Contents

1. [Overview](#overview)
2. [Amazon Product Advertising API](#amazon-product-advertising-api)
3. [eBay Finding API](#ebay-finding-api)
4. [YouTube Data API](#youtube-data-api)
5. [Custom Manual Database API](#custom-manual-database-api)
6. [Parts Supplier APIs](#parts-supplier-apis)
7. [Authentication & Security](#authentication--security)
8. [Rate Limiting & Quotas](#rate-limiting--quotas)
9. [Error Handling](#error-handling)
10. [Testing & Mocking](#testing--mocking)

---

## Overview

### API Summary

| API | Purpose | Cost | Rate Limit | Priority |
|-----|---------|------|------------|----------|
| Amazon Product Advertising | Part search & affiliate | Free (affiliate) | 1 req/sec | High |
| eBay Finding API | Part search & pricing | Free | 5000 req/day | High |
| YouTube Data API | Tutorial videos | Free tier | 10,000 units/day | High |
| Manual Database API | Manual retrieval | Custom pricing | 100 req/min | Critical |
| RepairClinic API | Parts database | Partnership | TBD | Medium |
| iFixit API | Repair guides | Free (attribution) | Unknown | Low |

### Base URLs

```swift
enum APIBaseURL {
    static let amazon = "https://webservices.amazon.com/paapi5"
    static let ebay = "https://svcs.ebay.com/services/search/FindingService/v1"
    static let youtube = "https://www.googleapis.com/youtube/v3"
    static let manualDatabase = "https://api.manualdatabase.com/v1"  // Custom
    static let repairClinic = "https://api.repairclinic.com/v1"
    static let ifixit = "https://www.ifixit.com/api/2.0"
}
```

---

## Amazon Product Advertising API

### Overview

**Purpose**: Search for replacement parts, compare prices, generate affiliate links

**Documentation**: https://webservices.amazon.com/paapi5/documentation/

**Authentication**: Access Key + Secret Key + Partner Tag

### Setup

```swift
struct AmazonAPIConfig {
    let accessKey: String
    let secretKey: String
    let partnerTag: String
    let region: String = "us-east-1"
    let host: String = "webservices.amazon.com"
}
```

### Endpoints

#### 1. Search Items

**Request**:
```swift
struct AmazonSearchRequest: Encodable {
    let keywords: String
    let searchIndex: String = "Appliances"
    let itemCount: Int = 10
    let resources: [String] = [
        "ItemInfo.Title",
        "ItemInfo.ByLineInfo",
        "Offers.Listings.Price",
        "Offers.Listings.Availability",
        "Images.Primary.Large"
    ]
}

// Usage
let request = AmazonSearchRequest(
    keywords: "GE refrigerator water filter WR97X10006",
    searchIndex: "Appliances",
    itemCount: 10
)
```

**HTTP Request**:
```http
POST https://webservices.amazon.com/paapi5/searchitems
Content-Type: application/json
X-Amz-Target: com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems
X-Amz-Date: 20251124T120000Z
Authorization: AWS4-HMAC-SHA256 Credential=...

{
  "Keywords": "GE refrigerator water filter WR97X10006",
  "SearchIndex": "Appliances",
  "ItemCount": 10,
  "PartnerTag": "homemaintoracle-20",
  "PartnerType": "Associates",
  "Resources": [
    "ItemInfo.Title",
    "Offers.Listings.Price",
    "Images.Primary.Large"
  ]
}
```

**Response**:
```json
{
  "SearchResult": {
    "Items": [
      {
        "ASIN": "B00MJH8XUK",
        "DetailPageURL": "https://www.amazon.com/dp/B00MJH8XUK?tag=homemaintoracle-20",
        "ItemInfo": {
          "Title": {
            "DisplayValue": "GE MWF Refrigerator Water Filter"
          }
        },
        "Offers": {
          "Listings": [
            {
              "Price": {
                "Amount": 39.99,
                "Currency": "USD"
              },
              "Availability": {
                "Type": "Now"
              },
              "DeliveryInfo": {
                "IsPrimeEligible": true
              }
            }
          ]
        },
        "Images": {
          "Primary": {
            "Large": {
              "URL": "https://m.media-amazon.com/images/I/71abc.jpg"
            }
          }
        }
      }
    ]
  }
}
```

**Swift Model**:
```swift
struct AmazonSearchResponse: Decodable {
    let searchResult: SearchResult

    struct SearchResult: Decodable {
        let items: [AmazonItem]
    }
}

struct AmazonItem: Decodable {
    let asin: String
    let detailPageURL: URL
    let itemInfo: ItemInfo
    let offers: Offers?
    let images: Images?

    struct ItemInfo: Decodable {
        let title: Title

        struct Title: Decodable {
            let displayValue: String
        }
    }

    struct Offers: Decodable {
        let listings: [Listing]

        struct Listing: Decodable {
            let price: Price
            let availability: Availability
            let deliveryInfo: DeliveryInfo?

            struct Price: Decodable {
                let amount: Decimal
                let currency: String
            }

            struct Availability: Decodable {
                let type: String
            }

            struct DeliveryInfo: Decodable {
                let isPrimeEligible: Bool
            }
        }
    }

    struct Images: Decodable {
        let primary: ImageSize

        struct ImageSize: Decodable {
            let large: ImageURL

            struct ImageURL: Decodable {
                let url: URL
            }
        }
    }
}
```

#### 2. Get Items (by ASIN)

**Request**:
```swift
struct AmazonGetItemsRequest: Encodable {
    let itemIds: [String]  // ASINs
    let resources: [String] = [
        "ItemInfo.Title",
        "Offers.Listings.Price"
    ]
}
```

### Authentication

**AWS Signature Version 4**:

```swift
class AmazonAuthenticator {
    private let config: AmazonAPIConfig

    func sign(request: URLRequest) -> URLRequest {
        var signed = request

        let timestamp = ISO8601DateFormatter().string(from: Date())
        signed.setValue(timestamp, forHTTPHeaderField: "X-Amz-Date")

        let signature = generateSignature(
            method: request.httpMethod ?? "POST",
            path: request.url?.path ?? "",
            headers: request.allHTTPHeaderFields ?? [:],
            body: request.httpBody
        )

        signed.setValue(
            "AWS4-HMAC-SHA256 Credential=\(config.accessKey)/..., SignedHeaders=..., Signature=\(signature)",
            forHTTPHeaderField: "Authorization"
        )

        return signed
    }

    private func generateSignature(
        method: String,
        path: String,
        headers: [String: String],
        body: Data?
    ) -> String {
        // Implement AWS Signature V4 algorithm
        // https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html
        // ...
    }
}
```

### Implementation

```swift
protocol AmazonAPIClient {
    func searchParts(query: String) async throws -> [Part]
    func getItem(asin: String) async throws -> Part
}

class AmazonAPIClientImpl: AmazonAPIClient {
    private let httpClient: HTTPClient
    private let authenticator: AmazonAuthenticator
    private let config: AmazonAPIConfig

    func searchParts(query: String) async throws -> [Part] {
        let request = AmazonSearchRequest(
            keywords: query,
            searchIndex: "Appliances",
            itemCount: 10
        )

        var urlRequest = URLRequest(url: URL(string: APIBaseURL.amazon + "/searchitems")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(
            "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems",
            forHTTPHeaderField: "X-Amz-Target"
        )

        // Sign request
        urlRequest = authenticator.sign(request: urlRequest)

        let response: AmazonSearchResponse = try await httpClient.execute(urlRequest)

        return response.searchResult.items.map { item in
            Part(
                id: item.asin,
                name: item.itemInfo.title.displayValue,
                price: item.offers?.listings.first?.price.amount,
                url: item.detailPageURL,
                imageURL: item.images?.primary.large.url,
                isPrimeEligible: item.offers?.listings.first?.deliveryInfo?.isPrimeEligible
            )
        }
    }
}
```

### Rate Limiting

**Limit**: 1 request per second per account

**Implementation**:
```swift
actor RateLimiter {
    private var lastRequestTime: Date?
    private let minimumInterval: TimeInterval = 1.0

    func waitIfNeeded() async {
        if let last = lastRequestTime {
            let elapsed = Date().timeIntervalSince(last)
            if elapsed < minimumInterval {
                try? await Task.sleep(nanoseconds: UInt64((minimumInterval - elapsed) * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
}
```

---

## eBay Finding API

### Overview

**Purpose**: Alternative part search, price comparison

**Documentation**: https://developer.ebay.com/Devzone/finding/Concepts/FindingAPIGuide.html

**Authentication**: App ID (API Key)

### Endpoints

#### 1. Find Items by Keywords

**Request**:
```http
GET https://svcs.ebay.com/services/search/FindingService/v1?
  OPERATION-NAME=findItemsByKeywords&
  SERVICE-VERSION=1.0.0&
  SECURITY-APPNAME=YourAppID&
  RESPONSE-DATA-FORMAT=JSON&
  keywords=GE%20refrigerator%20water%20filter&
  paginationInput.entriesPerPage=10
```

**Response**:
```json
{
  "findItemsByKeywordsResponse": [{
    "searchResult": [{
      "item": [{
        "itemId": ["123456789"],
        "title": ["GE MWF Refrigerator Water Filter"],
        "sellingStatus": [{
          "currentPrice": [{
            "__value__": "34.99",
            "@currencyId": "USD"
          }]
        }],
        "shippingInfo": [{
          "shippingServiceCost": [{
            "__value__": "0.00",
            "@currencyId": "USD"
          }]
        }],
        "viewItemURL": ["https://www.ebay.com/itm/123456789"],
        "galleryURL": ["https://i.ebayimg.com/..."]
      }]
    }]
  }]
}
```

**Swift Model**:
```swift
struct EbaySearchResponse: Decodable {
    let findItemsByKeywordsResponse: [FindItemsResponse]

    struct FindItemsResponse: Decodable {
        let searchResult: [SearchResult]

        struct SearchResult: Decodable {
            let item: [Item]

            struct Item: Decodable {
                let itemId: [String]
                let title: [String]
                let sellingStatus: [SellingStatus]
                let shippingInfo: [ShippingInfo]
                let viewItemURL: [String]
                let galleryURL: [String]?

                struct SellingStatus: Decodable {
                    let currentPrice: [Price]

                    struct Price: Decodable {
                        let value: String
                        let currencyId: String

                        enum CodingKeys: String, CodingKey {
                            case value = "__value__"
                            case currencyId = "@currencyId"
                        }
                    }
                }

                struct ShippingInfo: Decodable {
                    let shippingServiceCost: [Price]

                    struct Price: Decodable {
                        let value: String

                        enum CodingKeys: String, CodingKey {
                            case value = "__value__"
                        }
                    }
                }
            }
        }
    }
}
```

### Implementation

```swift
protocol EbayAPIClient {
    func searchParts(query: String) async throws -> [Part]
}

class EbayAPIClientImpl: EbayAPIClient {
    private let appID: String
    private let httpClient: HTTPClient

    func searchParts(query: String) async throws -> [Part] {
        var components = URLComponents(string: APIBaseURL.ebay)!
        components.queryItems = [
            URLQueryItem(name: "OPERATION-NAME", value: "findItemsByKeywords"),
            URLQueryItem(name: "SERVICE-VERSION", value: "1.0.0"),
            URLQueryItem(name: "SECURITY-APPNAME", value: appID),
            URLQueryItem(name: "RESPONSE-DATA-FORMAT", value: "JSON"),
            URLQueryItem(name: "keywords", value: query),
            URLQueryItem(name: "paginationInput.entriesPerPage", value: "10")
        ]

        let request = URLRequest(url: components.url!)
        let response: EbaySearchResponse = try await httpClient.execute(request)

        return response.findItemsByKeywordsResponse.first?.searchResult.first?.item.compactMap { item in
            guard let price = Decimal(string: item.sellingStatus.first?.currentPrice.first?.value ?? "") else {
                return nil
            }

            return Part(
                id: item.itemId.first ?? "",
                name: item.title.first ?? "",
                price: price,
                url: URL(string: item.viewItemURL.first ?? ""),
                imageURL: URL(string: item.galleryURL?.first ?? "")
            )
        } ?? []
    }
}
```

---

## YouTube Data API

### Overview

**Purpose**: Search for repair tutorial videos

**Documentation**: https://developers.google.com/youtube/v3/docs

**Authentication**: API Key

### Endpoints

#### 1. Search Videos

**Request**:
```http
GET https://www.googleapis.com/youtube/v3/search?
  part=snippet&
  q=GE+dishwasher+not+draining+repair&
  type=video&
  maxResults=10&
  key=YOUR_API_KEY
```

**Response**:
```json
{
  "items": [
    {
      "id": {
        "videoId": "abc123xyz"
      },
      "snippet": {
        "title": "How to Fix GE Dishwasher Not Draining",
        "description": "Step by step guide...",
        "thumbnails": {
          "high": {
            "url": "https://i.ytimg.com/vi/abc123xyz/hqdefault.jpg"
          }
        },
        "channelTitle": "Repair Clinic"
      }
    }
  ]
}
```

**Swift Model**:
```swift
struct YouTubeSearchResponse: Decodable {
    let items: [VideoItem]

    struct VideoItem: Decodable {
        let id: VideoID
        let snippet: Snippet

        struct VideoID: Decodable {
            let videoId: String
        }

        struct Snippet: Decodable {
            let title: String
            let description: String
            let thumbnails: Thumbnails
            let channelTitle: String

            struct Thumbnails: Decodable {
                let high: Thumbnail

                struct Thumbnail: Decodable {
                    let url: URL
                }
            }
        }
    }
}
```

#### 2. Get Video Details

**Request**:
```http
GET https://www.googleapis.com/youtube/v3/videos?
  part=contentDetails,statistics&
  id=abc123xyz&
  key=YOUR_API_KEY
```

**Response**:
```json
{
  "items": [
    {
      "contentDetails": {
        "duration": "PT5M30S"
      },
      "statistics": {
        "viewCount": "125000"
      }
    }
  ]
}
```

### Implementation

```swift
protocol YouTubeAPIClient {
    func searchTutorials(query: String) async throws -> [Tutorial]
    func getVideoDetails(videoId: String) async throws -> VideoDetails
}

class YouTubeAPIClientImpl: YouTubeAPIClient {
    private let apiKey: String
    private let httpClient: HTTPClient

    func searchTutorials(query: String) async throws -> [Tutorial] {
        var components = URLComponents(string: APIBaseURL.youtube + "/search")!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "10"),
            URLQueryItem(name: "key", value: apiKey)
        ]

        let request = URLRequest(url: components.url!)
        let response: YouTubeSearchResponse = try await httpClient.execute(request)

        return response.items.map { item in
            Tutorial(
                id: item.id.videoId,
                title: item.snippet.title,
                description: item.snippet.description,
                videoURL: URL(string: "https://www.youtube.com/watch?v=\(item.id.videoId)")!,
                thumbnailURL: item.snippet.thumbnails.high.url,
                source: item.snippet.channelTitle
            )
        }
    }
}
```

### Rate Limiting

**Quota**: 10,000 units per day
- Search request: 100 units
- Video details: 1 unit

**Strategy**: Cache results aggressively, batch requests

---

## Custom Manual Database API

### Overview

**Purpose**: Retrieve appliance manuals by brand/model

**Authentication**: Bearer token

### Endpoints

#### 1. Search Manuals

**Request**:
```http
POST https://api.manualdatabase.com/v1/manuals/search
Authorization: Bearer YOUR_API_TOKEN
Content-Type: application/json

{
  "brand": "GE",
  "model": "GDT695SSJ2SS",
  "category": "dishwasher"
}
```

**Response**:
```json
{
  "results": [
    {
      "id": "man_12345",
      "brand": "GE",
      "model": "GDT695SSJ2SS",
      "title": "Owner's Manual and Installation Instructions",
      "type": "owner",
      "language": "en",
      "pageCount": 48,
      "fileSize": 2458624,
      "downloadURL": "https://cdn.manualdatabase.com/files/man_12345.pdf",
      "thumbnailURL": "https://cdn.manualdatabase.com/thumbs/man_12345.jpg"
    }
  ]
}
```

**Swift Model**:
```swift
struct ManualSearchRequest: Encodable {
    let brand: String
    let model: String
    let category: String?
}

struct ManualSearchResponse: Decodable {
    let results: [ManualResult]

    struct ManualResult: Decodable {
        let id: String
        let brand: String
        let model: String
        let title: String
        let type: String
        let language: String
        let pageCount: Int
        let fileSize: Int64
        let downloadURL: URL
        let thumbnailURL: URL
    }
}
```

#### 2. Download Manual

**Request**:
```http
GET https://cdn.manualdatabase.com/files/man_12345.pdf
Authorization: Bearer YOUR_API_TOKEN
```

**Response**: PDF file (binary)

### Implementation

```swift
protocol ManualDatabaseAPIClient {
    func searchManuals(brand: String, model: String) async throws -> [Manual]
    func downloadManual(id: String, to destination: URL) async throws
}

class ManualDatabaseAPIClientImpl: ManualDatabaseAPIClient {
    private let apiToken: String
    private let httpClient: HTTPClient

    func searchManuals(brand: String, model: String) async throws -> [Manual] {
        let searchRequest = ManualSearchRequest(
            brand: brand,
            model: model,
            category: nil
        )

        var request = URLRequest(url: URL(string: APIBaseURL.manualDatabase + "/manuals/search")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(searchRequest)

        let response: ManualSearchResponse = try await httpClient.execute(request)

        return response.results.map { result in
            Manual(
                id: result.id,
                brand: result.brand,
                model: result.model,
                title: result.title,
                type: ManualType(rawValue: result.type) ?? .owner,
                downloadURL: result.downloadURL,
                pageCount: result.pageCount,
                fileSize: result.fileSize
            )
        }
    }

    func downloadManual(id: String, to destination: URL) async throws {
        let url = URL(string: "https://cdn.manualdatabase.com/files/\(id).pdf")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")

        try await httpClient.download(request, to: destination)
    }
}
```

---

## Authentication & Security

### API Key Storage

```swift
class APIKeyManager {
    private let keychain = KeychainManager.shared

    func getAmazonCredentials() -> (accessKey: String, secretKey: String, partnerTag: String)? {
        guard let accessKey = keychain.get(key: "amazon_access_key"),
              let secretKey = keychain.get(key: "amazon_secret_key"),
              let partnerTag = keychain.get(key: "amazon_partner_tag") else {
            return nil
        }
        return (accessKey, secretKey, partnerTag)
    }

    func getYouTubeAPIKey() -> String? {
        keychain.get(key: "youtube_api_key")
    }

    func getManualDatabaseToken() -> String? {
        keychain.get(key: "manual_db_token")
    }
}
```

### Keychain Manager

```swift
class KeychainManager {
    static let shared = KeychainManager()

    func save(key: String, value: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8)!
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }
}
```

---

## Rate Limiting & Quotas

### Centralized Rate Limiter

```swift
actor APIRateLimiter {
    private var limiters: [String: TokenBucket] = [:]

    func request(api: String) async throws {
        let limiter = limiters[api] ?? createLimiter(for: api)
        try await limiter.consume()
    }

    private func createLimiter(for api: String) -> TokenBucket {
        switch api {
        case "amazon":
            return TokenBucket(capacity: 1, refillRate: 1.0)  // 1 req/sec
        case "ebay":
            return TokenBucket(capacity: 5000, refillRate: 5000.0 / 86400)  // 5000/day
        case "youtube":
            return TokenBucket(capacity: 100, refillRate: 10000.0 / 86400)  // 10000 units/day
        default:
            return TokenBucket(capacity: 100, refillRate: 100.0 / 60)  // 100/min default
        }
    }
}

actor TokenBucket {
    let capacity: Double
    let refillRate: Double  // tokens per second
    private var tokens: Double
    private var lastRefill: Date

    init(capacity: Double, refillRate: Double) {
        self.capacity = capacity
        self.refillRate = refillRate
        self.tokens = capacity
        self.lastRefill = Date()
    }

    func consume() async throws {
        refill()

        if tokens < 1 {
            let waitTime = (1 - tokens) / refillRate
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            refill()
        }

        tokens -= 1
    }

    private func refill() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefill)
        tokens = min(capacity, tokens + (elapsed * refillRate))
        lastRefill = now
    }
}
```

---

## Error Handling

### API Errors

```swift
enum APIError: Error {
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case rateLimitExceeded
    case authenticationFailed
    case quotaExceeded
    case notFound
    case serverError

    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError, .rateLimitExceeded:
            return true
        default:
            return false
        }
    }
}

extension HTTPURLResponse {
    func toAPIError() -> APIError {
        switch statusCode {
        case 401, 403:
            return .authenticationFailed
        case 404:
            return .notFound
        case 429:
            return .rateLimitExceeded
        case 500...599:
            return .serverError
        default:
            return .httpError(statusCode: statusCode)
        }
    }
}
```

### Retry Strategy

```swift
class APIRetryHandler {
    func executeWithRetry<T>(
        maxRetries: Int = 3,
        initialDelay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch let error as APIError where error.isRetryable {
                lastError = error

                if attempt < maxRetries - 1 {
                    let delay = initialDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                throw error
            }
        }

        throw lastError ?? APIError.serverError
    }
}
```

---

## Testing & Mocking

### Mock API Clients

```swift
class MockAmazonAPIClient: AmazonAPIClient {
    var mockParts: [Part] = []
    var shouldThrowError: APIError?

    func searchParts(query: String) async throws -> [Part] {
        if let error = shouldThrowError {
            throw error
        }
        return mockParts
    }
}

class MockYouTubeAPIClient: YouTubeAPIClient {
    var mockTutorials: [Tutorial] = []

    func searchTutorials(query: String) async throws -> [Tutorial] {
        return mockTutorials
    }
}
```

### Integration Tests

```swift
class AmazonAPIIntegrationTests: XCTestCase {
    var client: AmazonAPIClient!

    override func setUp() {
        let config = AmazonAPIConfig(
            accessKey: TestConfig.amazonAccessKey,
            secretKey: TestConfig.amazonSecretKey,
            partnerTag: TestConfig.amazonPartnerTag
        )
        client = AmazonAPIClientImpl(config: config)
    }

    func testSearchParts() async throws {
        let parts = try await client.searchParts(query: "GE refrigerator water filter")
        XCTAssertFalse(parts.isEmpty)
        XCTAssertNotNil(parts.first?.name)
        XCTAssertNotNil(parts.first?.price)
    }
}
```

---

**Document Status**: Ready for Review
**Next Steps**: Obtain API keys, implement clients, test integrations
