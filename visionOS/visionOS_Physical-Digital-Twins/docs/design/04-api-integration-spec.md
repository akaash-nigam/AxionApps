# API Integration Specification

## Overview

Physical-Digital Twins enriches recognized objects with data from multiple external APIs. This document defines the API integration strategy, data sources, fallback chains, and cost management.

## API Architecture

### Aggregator Pattern

```
┌──────────────────────────────────────────┐
│      ProductAPIAggregator                │
│  (Facade for all external APIs)         │
└────────────┬─────────────────────────────┘
             │
    ┌────────┼────────┬─────────┬──────────┐
    │        │        │         │          │
    ▼        ▼        ▼         ▼          ▼
┌────────┐┌──────┐┌───────┐┌────────┐┌─────────┐
│Amazon  ││Google││ UPC   ││  Book  ││ Recipe  │
│Product ││Shop  ││Database││ APIs   ││  APIs   │
│  API   ││      ││       ││        ││         │
└────────┘└──────┘└───────┘└────────┘└─────────┘
```

### Priority & Fallback Chain

For each object type, define primary and fallback APIs:

**Books**:
1. Google Books API (primary)
2. Open Library API (fallback)
3. Amazon Product API (fallback 2)

**Food/Products**:
1. UPC Database (primary for barcode)
2. Open Food Facts (for food products)
3. Amazon Product API (fallback)

**Electronics/Furniture**:
1. Amazon Product API (primary)
2. Google Shopping API (fallback)

## API Specifications

### 1. Amazon Product API (PAAPI 5.0)

**Purpose**: General product information, pricing, images

**Authentication**: AWS Signature Version 4

```swift
struct AmazonProductAPI {
    private let accessKey: String
    private let secretKey: String
    private let associateTag: String
    private let region = "us-east-1"

    func searchByBarcode(_ barcode: String) async throws -> ProductInfo {
        let request = SearchItemsRequest(
            keywords: barcode,
            searchIndex: .all,
            resources: [
                .itemInfo_title,
                .itemInfo_byLineInfo,
                .images_primary_large,
                .offers_listings_price,
                .itemInfo_features,
                .itemInfo_technicalInfo
            ]
        )

        let response = try await performRequest(request)
        return try parseResponse(response)
    }

    func getItemDetails(asin: String) async throws -> ProductInfo {
        let request = GetItemsRequest(
            itemIds: [asin],
            resources: [/* same as above */]
        )

        let response = try await performRequest(request)
        return try parseResponse(response)
    }
}

struct ProductInfo {
    let title: String
    let brand: String?
    let description: String?
    let imageURL: URL?
    let price: Price?
    let features: [String]
    let specifications: [String: String]
    let asin: String?
}

struct Price {
    let amount: Decimal
    let currency: String
}
```

**Rate Limits**:
- 1 request per second (free tier)
- 8,640 requests per day

**Costs**:
- Free tier: 1 req/sec
- Paid: $0.10 per 1,000 requests

**Caching Strategy**:
- Cache product info for 24 hours
- Cache images indefinitely (static)
- Invalidate price cache after 1 hour

### 2. Google Books API

**Purpose**: Book metadata, ratings, reviews

**Authentication**: API Key

```swift
struct GoogleBooksAPI {
    private let apiKey: String
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"

    func searchByISBN(_ isbn: String) async throws -> BookInfo {
        let url = "\(baseURL)?q=isbn:\(isbn)&key=\(apiKey)"
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        guard let firstItem = response.items?.first else {
            throw APIError.notFound
        }

        return BookInfo(from: firstItem)
    }

    func searchByTitle(_ title: String, author: String?) async throws -> [BookInfo] {
        var query = "intitle:\(title)"
        if let author = author {
            query += "+inauthor:\(author)"
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = "\(baseURL)?q=\(encodedQuery)&key=\(apiKey)&maxResults=5"

        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        return response.items?.map { BookInfo(from: $0) } ?? []
    }
}

struct BookInfo {
    let title: String
    let authors: [String]
    let isbn10: String?
    let isbn13: String?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let imageURL: URL?
    let averageRating: Double?
    let ratingsCount: Int?
    let previewLink: URL?
}

struct GoogleBooksResponse: Codable {
    let items: [BookItem]?

    struct BookItem: Codable {
        let volumeInfo: VolumeInfo

        struct VolumeInfo: Codable {
            let title: String
            let authors: [String]?
            let publisher: String?
            let publishedDate: String?
            let description: String?
            let pageCount: Int?
            let imageLinks: ImageLinks?
            let averageRating: Double?
            let ratingsCount: Int?
            let industryIdentifiers: [Identifier]?

            struct ImageLinks: Codable {
                let thumbnail: String?
                let smallThumbnail: String?
            }

            struct Identifier: Codable {
                let type: String // "ISBN_10" or "ISBN_13"
                let identifier: String
            }
        }
    }
}
```

**Rate Limits**:
- 1,000 requests per day (free)
- 10 requests per second

**Costs**:
- Free tier: 1,000 req/day
- Paid: $0 (generous free tier)

### 3. Open Library API

**Purpose**: Fallback for book metadata

**Authentication**: None required

```swift
struct OpenLibraryAPI {
    private let baseURL = "https://openlibrary.org"

    func searchByISBN(_ isbn: String) async throws -> BookInfo {
        let url = "\(baseURL)/isbn/\(isbn).json"
        let (data, response) = try await URLSession.shared.data(from: URL(string: url)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.notFound
        }

        let bookData = try JSONDecoder().decode(OpenLibraryBook.self, from: data)
        return BookInfo(from: bookData)
    }

    func getCoverImage(isbn: String, size: CoverSize = .medium) async throws -> URL {
        // Open Library has free cover images
        let sizeParam = size.rawValue
        return URL(string: "\(baseURL)/isbn/\(isbn)-\(sizeParam).jpg")!
    }
}

enum CoverSize: String {
    case small = "S"
    case medium = "M"
    case large = "L"
}

struct OpenLibraryBook: Codable {
    let title: String
    let authors: [Author]?
    let publishers: [String]?
    let publishDate: String?
    let numberOfPages: Int?
    let isbn10: [String]?
    let isbn13: [String]?

    struct Author: Codable {
        let key: String // "/authors/OL23919A"
    }
}
```

**Rate Limits**:
- No official limit (be respectful)
- Recommended: 1 req/second

**Costs**: Free

### 4. UPC Database

**Purpose**: Product lookup by barcode

**Authentication**: API Key

```swift
struct UPCDatabaseAPI {
    private let apiKey: String
    private let baseURL = "https://api.upcitemdb.com/prod/trial/lookup"

    func lookupBarcode(_ barcode: String) async throws -> UPCProduct {
        var request = URLRequest(url: URL(string: "\(baseURL)?upc=\(barcode)")!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(UPCResponse.self, from: data)

        guard let item = response.items.first else {
            throw APIError.notFound
        }

        return UPCProduct(from: item)
    }
}

struct UPCProduct {
    let title: String
    let brand: String?
    let description: String?
    let imageURL: URL?
    let category: String?
}

struct UPCResponse: Codable {
    let items: [UPCItem]

    struct UPCItem: Codable {
        let title: String
        let brand: String?
        let description: String?
        let images: [String]?
        let category: String?
    }
}
```

**Rate Limits**:
- 100 requests per day (free)
- 10,000 requests per day (paid)

**Costs**:
- Free: 100 req/day
- Basic: $9.99/month (10k req/day)

### 5. Open Food Facts API

**Purpose**: Food nutrition and product information

**Authentication**: None (user-agent required)

```swift
struct OpenFoodFactsAPI {
    private let baseURL = "https://world.openfoodfacts.org/api/v2"
    private let userAgent = "PhysicalDigitalTwins/1.0"

    func getProduct(barcode: String) async throws -> FoodProduct {
        let url = "\(baseURL)/product/\(barcode).json"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OFFResponse.self, from: data)

        guard response.status == 1 else {
            throw APIError.notFound
        }

        return FoodProduct(from: response.product)
    }
}

struct FoodProduct {
    let productName: String
    let brand: String?
    let imageURL: URL?
    let nutritionInfo: NutritionInfo?
    let allergens: [String]
    let isVegan: Bool?
    let isVegetarian: Bool?
    let isGlutenFree: Bool?
    let isOrganic: Bool?
}

struct NutritionInfo {
    let servingSize: String?
    let calories: Double?
    let fat: Double?
    let carbohydrates: Double?
    let protein: Double?
    let salt: Double?
    let sugar: Double?
}

struct OFFResponse: Codable {
    let status: Int
    let product: OFFProduct

    struct OFFProduct: Codable {
        let productName: String?
        let brands: String?
        let imageFrontURL: String?
        let nutriments: Nutriments?
        let allergens: String?
        let labels: String?

        struct Nutriments: Codable {
            let energyKcal100g: Double?
            let fat100g: Double?
            let carbohydrates100g: Double?
            let proteins100g: Double?
            let salt100g: Double?
            let sugars100g: Double?
        }
    }
}
```

**Rate Limits**:
- No hard limits (be respectful)
- Recommended: 1 req/second

**Costs**: Free (donation-funded)

### 6. Spoonacular API (Recipe)

**Purpose**: Recipe suggestions for expiring food

**Authentication**: API Key

```swift
struct SpoonacularAPI {
    private let apiKey: String
    private let baseURL = "https://api.spoonacular.com"

    func findRecipesByIngredients(_ ingredients: [String]) async throws -> [Recipe] {
        let ingredientsList = ingredients.joined(separator: ",")
        let url = "\(baseURL)/recipes/findByIngredients?ingredients=\(ingredientsList)&number=5&apiKey=\(apiKey)"

        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let (data, _) = try await URLSession.shared.data(from: URL(string: encodedURL)!)

        let recipes = try JSONDecoder().decode([SpoonacularRecipe].self, from: data)
        return recipes.map { Recipe(from: $0) }
    }
}

struct Recipe {
    let id: Int
    let title: String
    let imageURL: URL?
    let usedIngredients: [String]
    let missedIngredients: [String]
}

struct SpoonacularRecipe: Codable {
    let id: Int
    let title: String
    let image: String?
    let usedIngredients: [Ingredient]
    let missedIngredients: [Ingredient]

    struct Ingredient: Codable {
        let name: String
    }
}
```

**Rate Limits**:
- 150 requests per day (free)
- 500 points per day (1 point = 1 simple request)

**Costs**:
- Free: 150 req/day
- Basic: $1.99/month (500 req/day)

### 7. Sustainability APIs

#### Good On You API (Sustainability Scores)

```swift
struct GoodOnYouAPI {
    // Note: This is a conceptual API - may need to scrape website
    // or partner directly with Good On You

    func getBrandRating(_ brand: String) async throws -> SustainabilityRating {
        // Implementation would depend on partnership or scraping
        fatalError("Not yet implemented - requires partnership")
    }
}

struct SustainabilityRating {
    let brand: String
    let overallRating: Int // 1-5
    let environmentScore: Int
    let laborScore: Int
    let animalScore: Int
}
```

#### Carbon Footprint Estimation

```swift
struct CarbonFootprintEstimator {
    // Based on product category and weight
    func estimate(category: ObjectCategory, weight: Double, origin: String?) -> Double {
        // Simple heuristic-based estimation
        let baseCO2PerKg: [ObjectCategory: Double] = [
            .electronics: 50.0,  // kg CO2 per kg product
            .clothing: 15.0,
            .furniture: 10.0,
            .food: 2.0,
            .book: 1.5
        ]

        let base = baseCO2PerKg[category] ?? 5.0
        var total = base * weight

        // Add shipping estimate
        if let origin = origin, origin != "Local" {
            total += 5.0 // ~5kg CO2 for international shipping
        }

        return total
    }
}
```

### 8. Recall APIs

#### CPSC Recalls (Consumer Products)

```swift
struct CPSCRecallAPI {
    private let baseURL = "https://www.cpsc.gov/s3fs-public/Recall-Search.json"

    func checkRecalls(product: String) async throws -> [Recall] {
        // CPSC provides a JSON file with all recalls
        let (data, _) = try await URLSession.shared.data(from: URL(string: baseURL)!)
        let recalls = try JSONDecoder().decode([CPSCRecall].self, from: data)

        // Filter by product name/model
        return recalls
            .filter { $0.title.localizedCaseInsensitiveContains(product) }
            .map { Recall(from: $0) }
    }
}

struct Recall {
    let title: String
    let hazard: String
    let description: String
    let remedy: String
    let recallDate: Date
    let url: URL?
}
```

## API Aggregator Implementation

### Unified Interface

```swift
protocol ProductAPIService {
    func fetchProductInfo(barcode: String) async throws -> ProductInfo
    func fetchBookInfo(isbn: String) async throws -> BookInfo
    func fetchFoodInfo(barcode: String) async throws -> FoodProduct
    func searchProducts(query: String) async throws -> [ProductInfo]
}

class ProductAPIAggregator: ProductAPIService {
    private let amazonAPI: AmazonProductAPI
    private let googleBooksAPI: GoogleBooksAPI
    private let openLibraryAPI: OpenLibraryAPI
    private let upcDatabase: UPCDatabaseAPI
    private let openFoodFacts: OpenFoodFactsAPI
    private let spoonacular: SpoonacularAPI

    private let cache: APICache
    private let rateLimiter: RateLimiter

    func fetchProductInfo(barcode: String) async throws -> ProductInfo {
        // Check cache first
        if let cached = await cache.get(key: "product:\(barcode)") as? ProductInfo {
            return cached
        }

        // Try UPC Database first
        do {
            try await rateLimiter.checkLimit(api: "upcdb")
            let product = try await upcDatabase.lookupBarcode(barcode)
            await cache.set(key: "product:\(barcode)", value: product, ttl: 86400) // 24h
            return ProductInfo(from: product)
        } catch {
            // Fallback to Amazon
            try await rateLimiter.checkLimit(api: "amazon")
            let product = try await amazonAPI.searchByBarcode(barcode)
            await cache.set(key: "product:\(barcode)", value: product, ttl: 86400)
            return product
        }
    }

    func fetchBookInfo(isbn: String) async throws -> BookInfo {
        // Check cache
        if let cached = await cache.get(key: "book:\(isbn)") as? BookInfo {
            return cached
        }

        // Try Google Books first
        do {
            try await rateLimiter.checkLimit(api: "googlebooks")
            let book = try await googleBooksAPI.searchByISBN(isbn)
            await cache.set(key: "book:\(isbn)", value: book, ttl: 86400 * 7) // 7 days
            return book
        } catch {
            // Fallback to Open Library
            let book = try await openLibraryAPI.searchByISBN(isbn)
            await cache.set(key: "book:\(isbn)", value: book, ttl: 86400 * 7)
            return book
        }
    }

    func fetchFoodInfo(barcode: String) async throws -> FoodProduct {
        // Check cache
        if let cached = await cache.get(key: "food:\(barcode)") as? FoodProduct {
            return cached
        }

        // Try Open Food Facts first (free and comprehensive for food)
        do {
            let food = try await openFoodFacts.getProduct(barcode: barcode)
            await cache.set(key: "food:\(barcode)", value: food, ttl: 86400 * 30) // 30 days
            return food
        } catch {
            // Fallback to UPC Database
            try await rateLimiter.checkLimit(api: "upcdb")
            let product = try await upcDatabase.lookupBarcode(barcode)
            let food = FoodProduct(from: product)
            await cache.set(key: "food:\(barcode)", value: food, ttl: 86400 * 30)
            return food
        }
    }
}
```

## Rate Limiting

### Token Bucket Algorithm

```swift
actor RateLimiter {
    private var buckets: [String: TokenBucket] = [:]

    init() {
        // Configure rate limits for each API
        buckets["amazon"] = TokenBucket(capacity: 1, refillRate: 1.0) // 1 req/sec
        buckets["googlebooks"] = TokenBucket(capacity: 10, refillRate: 10.0) // 10 req/sec
        buckets["upcdb"] = TokenBucket(capacity: 100, refillRate: 0.001) // ~100/day
        buckets["spoonacular"] = TokenBucket(capacity: 150, refillRate: 0.0017) // ~150/day
    }

    func checkLimit(api: String) async throws {
        guard let bucket = buckets[api] else {
            throw APIError.unknownAPI
        }

        try await bucket.consume()
    }
}

actor TokenBucket {
    private var tokens: Double
    private let capacity: Double
    private let refillRate: Double // tokens per second
    private var lastRefill: Date

    init(capacity: Double, refillRate: Double) {
        self.capacity = capacity
        self.tokens = capacity
        self.refillRate = refillRate
        self.lastRefill = Date()
    }

    func consume() async throws {
        refill()

        if tokens >= 1.0 {
            tokens -= 1.0
        } else {
            // Calculate wait time
            let waitTime = (1.0 - tokens) / refillRate
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            refill()
            tokens -= 1.0
        }
    }

    private func refill() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefill)
        tokens = min(capacity, tokens + elapsed * refillRate)
        lastRefill = now
    }
}
```

## Caching Strategy

### Multi-Tier Cache

```swift
actor APICache {
    private var memoryCache: [String: CacheEntry] = [:]
    private let diskCache: DiskCache

    func get(key: String) -> Any? {
        // Try memory first
        if let entry = memoryCache[key], !entry.isExpired {
            return entry.value
        }

        // Try disk
        if let value = diskCache.get(key: key) {
            // Promote to memory
            memoryCache[key] = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(3600))
            return value
        }

        return nil
    }

    func set(key: String, value: Any, ttl: TimeInterval) {
        let expiresAt = Date().addingTimeInterval(ttl)
        memoryCache[key] = CacheEntry(value: value, expiresAt: expiresAt)
        diskCache.set(key: key, value: value, ttl: ttl)

        // Evict old entries (LRU)
        if memoryCache.count > 100 {
            evictOldest()
        }
    }

    private func evictOldest() {
        let sorted = memoryCache.sorted { $0.value.createdAt < $1.value.createdAt }
        if let oldest = sorted.first {
            memoryCache.removeValue(forKey: oldest.key)
        }
    }
}

struct CacheEntry {
    let value: Any
    let createdAt: Date = Date()
    let expiresAt: Date

    var isExpired: Bool {
        Date() > expiresAt
    }
}
```

## Error Handling

### API-Specific Errors

```swift
enum APIError: LocalizedError {
    case notFound
    case rateLimitExceeded
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case unknownAPI

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Product not found in database"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .invalidAPIKey:
            return "Invalid API credentials"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid API response"
        case .unknownAPI:
            return "Unknown API"
        }
    }
}
```

## Cost Management

### Monthly Budget Estimates

| API | Free Tier | Usage Estimate | Cost |
|-----|-----------|----------------|------|
| Amazon PAAPI | 1 req/sec | 1,000/day | $0 |
| Google Books | 1,000/day | 500/day | $0 |
| Open Library | Unlimited | 200/day | $0 |
| UPC Database | 100/day | 500/day | $5/month |
| Open Food Facts | Unlimited | 300/day | $0 (donate) |
| Spoonacular | 150/day | 100/day | $0 |
| **Total** | | | **~$5-10/month** |

### Usage Analytics

```swift
actor APIUsageTracker {
    private var usage: [String: APIUsageStats] = [:]

    func record(api: String, success: Bool, latency: TimeInterval) {
        var stats = usage[api] ?? APIUsageStats(api: api)
        stats.totalRequests += 1
        if success {
            stats.successfulRequests += 1
        }
        stats.totalLatency += latency
        usage[api] = stats
    }

    func getStats() -> [APIUsageStats] {
        Array(usage.values)
    }
}

struct APIUsageStats {
    let api: String
    var totalRequests: Int = 0
    var successfulRequests: Int = 0
    var totalLatency: TimeInterval = 0

    var successRate: Double {
        Double(successfulRequests) / Double(max(totalRequests, 1))
    }

    var averageLatency: TimeInterval {
        totalLatency / Double(max(totalRequests, 1))
    }
}
```

## Security

### API Key Management

```swift
import Security

class APIKeyManager {
    private let serviceName = "com.app.physicaldigitaltwins"

    func store(key: String, for api: String) throws {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: api,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Remove existing
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.storeFailed
        }
    }

    func retrieve(for api: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: api,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.retrieveFailed
        }

        return key
    }
}
```

**Important**: Never hardcode API keys in source code. Use:
1. Keychain for runtime storage
2. Environment variables for development
3. Secure backend for production key distribution

## Testing

### Mock API Responses

```swift
class MockProductAPIService: ProductAPIService {
    var mockProductInfo: ProductInfo?
    var mockBookInfo: BookInfo?
    var shouldFail = false

    func fetchProductInfo(barcode: String) async throws -> ProductInfo {
        if shouldFail {
            throw APIError.notFound
        }
        return mockProductInfo ?? ProductInfo(title: "Test Product", brand: "Test")
    }

    func fetchBookInfo(isbn: String) async throws -> BookInfo {
        if shouldFail {
            throw APIError.notFound
        }
        return mockBookInfo ?? BookInfo(title: "Test Book", authors: ["Test Author"])
    }

    // ... other methods
}
```

## Summary

This API integration strategy provides:
- **Comprehensive Coverage**: Multiple data sources for each object type
- **Resilience**: Fallback chains ensure data availability
- **Cost-Effective**: Primarily free APIs, <$10/month estimated cost
- **Performance**: Aggressive caching (24h-30d TTL)
- **Rate Limit Handling**: Token bucket algorithm prevents API throttling
- **Secure**: API keys stored in Keychain
- **Testable**: Mock implementations for unit testing

The API aggregator pattern abstracts complexity from the rest of the app, providing a clean interface for data enrichment.
