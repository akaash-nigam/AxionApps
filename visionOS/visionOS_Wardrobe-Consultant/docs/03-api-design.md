# API Design & Integration Specifications

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the API architecture, external service integrations, and internal service protocols for Wardrobe Consultant. The application integrates with Apple's WeatherKit, EventKit, and external fashion retailer APIs, while maintaining a clean internal service layer for testability and maintainability.

## 2. Internal API Architecture

### 2.1 Service Protocol Design

All services follow protocol-oriented design for testability and flexibility.

```swift
// MARK: - Base Protocol
protocol ServiceProtocol {
    associatedtype ResultType
    associatedtype ErrorType: Error

    func fetch() async throws -> ResultType
}

// MARK: - Result Type
enum ServiceResult<T> {
    case success(T)
    case failure(ServiceError)
}

enum ServiceError: Error {
    case networkError(underlying: Error)
    case parsingError(underlying: Error)
    case unauthorized
    case rateLimited
    case serviceUnavailable
    case invalidResponse
}
```

### 2.2 Repository Layer

**Protocol Definition**:
```swift
// MARK: - Generic Repository
protocol Repository {
    associatedtype Entity
    associatedtype ID: Hashable

    func fetch(id: ID) async throws -> Entity
    func fetchAll() async throws -> [Entity]
    func create(_ entity: Entity) async throws -> Entity
    func update(_ entity: Entity) async throws -> Entity
    func delete(id: ID) async throws
}

// MARK: - Wardrobe Repository
protocol WardrobeRepository: Repository where Entity == WardrobeItem, ID == UUID {
    func fetchByCategory(_ category: ClothingCategory) async throws -> [WardrobeItem]
    func fetchBySeason(_ season: Season) async throws -> [WardrobeItem]
    func fetchByColor(_ color: String) async throws -> [WardrobeItem]
    func search(query: String) async throws -> [WardrobeItem]
}

// MARK: - Outfit Repository
protocol OutfitRepository: Repository where Entity == Outfit, ID == UUID {
    func fetchByOccasion(_ occasion: OccasionType) async throws -> [Outfit]
    func fetchFavorites() async throws -> [Outfit]
    func fetchRecent(limit: Int) async throws -> [Outfit]
}

// MARK: - User Profile Repository
protocol UserProfileRepository {
    func fetch() async throws -> UserProfile
    func update(_ profile: UserProfile) async throws
    func getBodyMeasurements() async throws -> BodyMeasurements
    func updateBodyMeasurements(_ measurements: BodyMeasurements) async throws
}
```

## 3. External Service Integrations

### 3.1 WeatherKit Integration

**Purpose**: Retrieve current weather and forecasts for outfit recommendations.

#### 3.1.1 Service Protocol

```swift
protocol WeatherService {
    func getCurrentWeather(for location: CLLocation) async throws -> CurrentWeather
    func getForecast(for location: CLLocation, days: Int) async throws -> [DailyForecast]
    func getHourlyForecast(for location: CLLocation, hours: Int) async throws -> [HourlyForecast]
}

// MARK: - Data Models
struct CurrentWeather: Codable {
    let temperature: Measurement<UnitTemperature>
    let feelsLike: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let humidity: Double // 0.0-1.0
    let windSpeed: Measurement<UnitSpeed>
    let precipitationProbability: Double // 0.0-1.0
    let uvIndex: Int
    let timestamp: Date
}

struct DailyForecast: Codable {
    let date: Date
    let high: Measurement<UnitTemperature>
    let low: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let precipitationProbability: Double
}

struct HourlyForecast: Codable {
    let hour: Date
    let temperature: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let precipitationProbability: Double
}
```

#### 3.1.2 Implementation

```swift
import WeatherKit

class AppleWeatherService: WeatherService {
    private let weatherService = WeatherService.shared

    func getCurrentWeather(for location: CLLocation) async throws -> CurrentWeather {
        let weather = try await weatherService.weather(for: location)

        return CurrentWeather(
            temperature: weather.currentWeather.temperature,
            feelsLike: weather.currentWeather.apparentTemperature,
            condition: mapCondition(weather.currentWeather.condition),
            humidity: weather.currentWeather.humidity,
            windSpeed: weather.currentWeather.wind.speed,
            precipitationProbability: 0, // Not in current weather
            uvIndex: weather.currentWeather.uvIndex.value,
            timestamp: weather.currentWeather.date
        )
    }

    func getForecast(for location: CLLocation, days: Int = 7) async throws -> [DailyForecast] {
        let forecast = try await weatherService.weather(
            for: location,
            including: .daily(startDate: Date(), endDate: Date().addingDays(days))
        )

        return forecast.map { day in
            DailyForecast(
                date: day.date,
                high: day.highTemperature,
                low: day.lowTemperature,
                condition: mapCondition(day.condition),
                precipitationProbability: day.precipitationChance
            )
        }
    }

    private func mapCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherCondition {
        // Map WeatherKit conditions to app's WeatherCondition enum
        switch condition {
        case .clear: return .clear
        case .cloudy: return .cloudy
        case .rain: return .rainy
        // ... other mappings
        default: return .cloudy
        }
    }
}
```

#### 3.1.3 Caching Strategy

- Cache duration: 1 hour
- Cache key: Location coordinates (rounded to 2 decimals)
- Invalidation: Time-based + manual refresh

```swift
class CachedWeatherService: WeatherService {
    private let underlyingService: WeatherService
    private let cache: WeatherCache
    private let cacheDuration: TimeInterval = 3600 // 1 hour

    func getCurrentWeather(for location: CLLocation) async throws -> CurrentWeather {
        // Check cache first
        if let cached = cache.get(for: location),
           Date().timeIntervalSince(cached.timestamp) < cacheDuration {
            return cached
        }

        // Fetch fresh data
        let weather = try await underlyingService.getCurrentWeather(for: location)
        cache.set(weather, for: location)
        return weather
    }
}
```

#### 3.1.4 Error Handling

```swift
enum WeatherServiceError: Error {
    case locationUnavailable
    case weatherDataUnavailable
    case rateLimitExceeded
    case networkError(Error)

    var userMessage: String {
        switch self {
        case .locationUnavailable:
            return "Unable to determine your location. Please enable location services."
        case .weatherDataUnavailable:
            return "Weather data is temporarily unavailable."
        case .rateLimitExceeded:
            return "Too many weather requests. Using cached data."
        case .networkError:
            return "Network connection issue. Using cached weather data."
        }
    }
}
```

### 3.2 EventKit (Calendar) Integration

**Purpose**: Access calendar events to determine dress code requirements.

#### 3.2.1 Service Protocol

```swift
protocol CalendarService {
    func requestAccess() async throws -> Bool
    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEventDTO]
    func getEvent(id: String) async throws -> CalendarEventDTO?
}

// MARK: - Data Transfer Object
struct CalendarEventDTO: Codable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
    let calendar: String // Calendar name
    let isAllDay: Bool
}
```

#### 3.2.2 Implementation

```swift
import EventKit

class AppleCalendarService: CalendarService {
    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        return try await eventStore.requestAccess(to: .event)
    }

    func fetchEvents(from start: Date, to end: Date) async throws -> [CalendarEventDTO] {
        let hasAccess = try await requestAccess()
        guard hasAccess else {
            throw CalendarServiceError.accessDenied
        }

        let predicate = eventStore.predicateForEvents(
            withStart: start,
            end: end,
            calendars: nil
        )

        let events = eventStore.events(matching: predicate)
        return events.map { event in
            CalendarEventDTO(
                id: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                notes: event.notes,
                calendar: event.calendar.title,
                isAllDay: event.isAllDay
            )
        }
    }

    func getEvent(id: String) async throws -> CalendarEventDTO? {
        guard let event = eventStore.event(withIdentifier: id) else {
            return nil
        }

        return CalendarEventDTO(
            id: event.eventIdentifier,
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            notes: event.notes,
            calendar: event.calendar.title,
            isAllDay: event.isAllDay
        )
    }
}
```

#### 3.2.3 Dress Code Extraction

```swift
class DressCodeExtractor {
    func extractDressCode(from event: CalendarEventDTO) -> DressCodeAnalysis {
        let text = "\(event.title) \(event.notes ?? "") \(event.location ?? "")"
        let lowercased = text.lowercased()

        // Keyword matching
        if lowercased.contains("black tie") {
            return DressCodeAnalysis(
                dressCode: .blackTie,
                confidence: 0.95,
                source: "explicit mention"
            )
        } else if lowercased.contains("cocktail") {
            return DressCodeAnalysis(
                dressCode: .cocktailAttire,
                confidence: 0.9,
                source: "explicit mention"
            )
        } else if lowercased.contains("business casual") {
            return DressCodeAnalysis(
                dressCode: .businessCasual,
                confidence: 0.9,
                source: "explicit mention"
            )
        }

        // Event type inference
        if lowercased.contains("wedding") {
            return DressCodeAnalysis(
                dressCode: .cocktailAttire,
                confidence: 0.7,
                source: "event type inference"
            )
        } else if lowercased.contains("interview") {
            return DressCodeAnalysis(
                dressCode: .businessProfessional,
                confidence: 0.85,
                source: "event type inference"
            )
        } else if lowercased.contains("meeting") || lowercased.contains("presentation") {
            return DressCodeAnalysis(
                dressCode: .businessCasual,
                confidence: 0.6,
                source: "event type inference"
            )
        }

        // Default to smart casual
        return DressCodeAnalysis(
            dressCode: .smartCasual,
            confidence: 0.4,
            source: "default"
        )
    }
}

struct DressCodeAnalysis {
    let dressCode: DressCode
    let confidence: Float // 0.0-1.0
    let source: String
}
```

#### 3.2.4 Privacy & Permissions

```swift
class CalendarPermissionManager {
    func checkPermission() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }

    func shouldRequestPermission() -> Bool {
        return checkPermission() == .notDetermined
    }

    func explainPermissionNeeds() -> String {
        """
        Wardrobe Consultant needs calendar access to:
        • Suggest appropriate outfits for upcoming events
        • Analyze dress codes from event descriptions
        • Plan your wardrobe for the week ahead

        Your calendar data stays on your device and is never shared.
        """
    }
}
```

### 3.3 Fashion Retailer Integration

**Purpose**: Virtual try-on for online shopping, product data extraction.

#### 3.3.1 Retailer API Protocol

```swift
protocol RetailerService {
    var retailerName: String { get }
    func searchProducts(query: String, filters: ProductFilters?) async throws -> [Product]
    func getProduct(id: String) async throws -> Product?
    func getProductImage(url: URL) async throws -> UIImage
    func getProduct3DModel(url: URL) async throws -> URL? // USDZ file
}

// MARK: - Data Models
struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let price: Decimal
    let currency: String
    let category: ClothingCategory
    let sizes: [String]
    let colors: [ProductColor]
    let images: [URL]
    let model3DURL: URL?
    let productURL: URL
    let description: String?
}

struct ProductColor: Codable {
    let name: String
    let hexCode: String
    let imageURL: URL?
}

struct ProductFilters: Codable {
    var category: ClothingCategory?
    var priceMin: Decimal?
    var priceMax: Decimal?
    var sizes: [String]?
    var colors: [String]?
    var brand: String?
}
```

#### 3.3.2 Web Scraping Strategy (Fallback)

For retailers without official APIs, use web scraping:

```swift
class WebScrapingRetailerService: RetailerService {
    let retailerName: String
    private let baseURL: URL
    private let parser: HTMLParser

    func getProduct(id: String) async throws -> Product? {
        let url = baseURL.appendingPathComponent("/product/\(id)")
        let html = try await fetchHTML(from: url)

        return try parser.extractProduct(from: html, retailer: retailerName)
    }

    private func fetchHTML(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

// MARK: - HTML Parsing
class HTMLParser {
    func extractProduct(from html: String, retailer: String) throws -> Product {
        // Use regex or parsing library (e.g., SwiftSoup)
        // Extract: name, price, images, sizes, etc.

        // Retailer-specific selectors
        switch retailer {
        case "Zara":
            return try parseZaraProduct(html)
        case "H&M":
            return try parseHMProduct(html)
        default:
            throw ParsingError.unsupportedRetailer
        }
    }

    private func parseZaraProduct(_ html: String) throws -> Product {
        // Zara-specific DOM selectors
        // Example: <div class="product-name">Blue Shirt</div>
        // ...
        throw ParsingError.notImplemented
    }
}
```

#### 3.3.3 Share Sheet Integration

```swift
// Share extension for intercepting product URLs
class ProductURLHandler {
    func canHandle(url: URL) -> Bool {
        let supportedDomains = [
            "zara.com",
            "hm.com",
            "asos.com",
            "nordstrom.com"
        ]

        return supportedDomains.contains { url.host?.contains($0) ?? false }
    }

    func extractProductInfo(from url: URL) async throws -> Product {
        // Determine retailer from URL
        let retailer = determineRetailer(from: url)

        // Fetch and parse product page
        let service = retailerServiceFactory.service(for: retailer)
        let productID = extractProductID(from: url)

        return try await service.getProduct(id: productID)
    }

    private func determineRetailer(from url: URL) -> String {
        if url.host?.contains("zara.com") == true {
            return "Zara"
        } else if url.host?.contains("hm.com") == true {
            return "H&M"
        }
        // ... other retailers
        return "Unknown"
    }

    private func extractProductID(from url: URL) -> String {
        // Extract product ID from URL
        // Example: https://www.zara.com/us/en/shirt-p12345678.html
        // Returns: "12345678"
        let pattern = #"p(\d+)"#
        // ... regex extraction
        return ""
    }
}
```

#### 3.3.4 Rate Limiting & Caching

```swift
class RateLimitedRetailerService: RetailerService {
    private let underlyingService: RetailerService
    private let rateLimiter: RateLimiter
    private let cache: ProductCache

    func getProduct(id: String) async throws -> Product? {
        // Check cache first
        if let cached = cache.get(id: id) {
            return cached
        }

        // Rate limit check
        try await rateLimiter.wait()

        // Fetch product
        let product = try await underlyingService.getProduct(id: id)

        // Cache result
        if let product = product {
            cache.set(product, for: id)
        }

        return product
    }
}

actor RateLimiter {
    private var lastRequestTime: Date?
    private let minimumInterval: TimeInterval = 1.0 // 1 second between requests

    func wait() async throws {
        if let last = lastRequestTime {
            let elapsed = Date().timeIntervalSince(last)
            if elapsed < minimumInterval {
                try await Task.sleep(nanoseconds: UInt64((minimumInterval - elapsed) * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
}
```

### 3.4 Location Services Integration

#### 3.4.1 Service Protocol

```swift
protocol LocationService {
    func requestPermission() async throws -> Bool
    func getCurrentLocation() async throws -> CLLocation
    func getLocationName(for location: CLLocation) async throws -> String
}

class AppleLocationService: LocationService {
    private let locationManager = CLLocationManager()

    func requestPermission() async throws -> Bool {
        return await withCheckedContinuation { continuation in
            locationManager.requestWhenInUseAuthorization()
            // Check authorization status
            let status = locationManager.authorizationStatus
            continuation.resume(returning: status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }

    func getCurrentLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            // Handle delegate callback
            // continuation.resume(returning: location)
        }
    }

    func getLocationName(for location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        guard let placemark = placemarks.first else {
            throw LocationServiceError.geocodingFailed
        }

        return placemark.locality ?? placemark.administrativeArea ?? "Unknown"
    }
}
```

## 4. Internal Service APIs

### 4.1 Style Recommendation Service

```swift
protocol StyleRecommendationService {
    func generateOutfits(
        wardrobe: [WardrobeItem],
        weather: CurrentWeather?,
        events: [CalendarEventDTO],
        profile: UserProfile
    ) async throws -> [OutfitRecommendation]

    func scoreOutfit(
        _ outfit: Outfit,
        for context: OutfitContext
    ) -> Float
}

struct OutfitRecommendation {
    let outfit: Outfit
    let score: Float // 0.0-1.0
    let reasoning: String
    let weatherAppropriate: Bool
    let eventAppropriate: Bool
}

struct OutfitContext {
    let temperature: Int16?
    let weather: WeatherCondition?
    let occasion: OccasionType?
    let dressCode: DressCode?
}
```

### 4.2 Body Tracking Service

```swift
protocol BodyTrackingService {
    func startTracking() async throws
    func stopTracking()
    func getBodyAnchor() -> ARBodyAnchor?
    func estimateBodyMeasurements() async throws -> BodyMeasurements
}

struct BodyMeasurements: Codable {
    let height: Measurement<UnitLength>
    let shoulderWidth: Measurement<UnitLength>
    let chest: Measurement<UnitLength>
    let waist: Measurement<UnitLength>
    let hips: Measurement<UnitLength>
    let inseam: Measurement<UnitLength>
    let confidence: Float // 0.0-1.0
}
```

### 4.3 Clothing Rendering Service

```swift
protocol ClothingRenderingService {
    func load3DModel(for item: WardrobeItem) async throws -> ModelEntity
    func applyToBody(_ model: ModelEntity, bodyAnchor: ARBodyAnchor) throws
    func updatePhysics(_ model: ModelEntity, bodyMovement: simd_float4x4)
}
```

### 4.4 ML Inference Service

```swift
protocol MLInferenceService {
    func classifyClothing(image: UIImage) async throws -> ClothingClassification
    func extractColors(from image: UIImage) async throws -> [String] // Hex colors
    func recommendSize(
        measurements: BodyMeasurements,
        product: Product
    ) async throws -> SizeRecommendation
}

struct ClothingClassification {
    let category: ClothingCategory
    let subcategory: String?
    let confidence: Float
    let colors: [String]
    let pattern: ClothingPattern?
    let fabric: FabricType?
}

struct SizeRecommendation {
    let recommendedSize: String
    let confidence: Float
    let fitType: FitType // slim, regular, relaxed
    let notes: String?
}
```

## 5. API Error Handling

### 5.1 Unified Error Type

```swift
enum APIError: Error {
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case httpError(statusCode: Int, message: String?)
    case rateLimited(retryAfter: TimeInterval?)
    case unauthorized
    case notFound
    case serverError
    case timeout
    case cancelled
    case unknown

    var isRecoverable: Bool {
        switch self {
        case .networkError, .timeout, .rateLimited, .serverError:
            return true
        case .unauthorized, .notFound, .decodingError:
            return false
        default:
            return false
        }
    }

    var userMessage: String {
        switch self {
        case .networkError:
            return "Network connection issue. Please check your internet."
        case .rateLimited:
            return "Too many requests. Please try again in a moment."
        case .unauthorized:
            return "Authentication required. Please log in."
        case .notFound:
            return "Requested resource not found."
        case .serverError:
            return "Server error. Please try again later."
        case .timeout:
            return "Request timed out. Please try again."
        default:
            return "An unexpected error occurred."
        }
    }
}
```

### 5.2 Retry Logic

```swift
class RetryableAPIClient {
    func performRequest<T: Decodable>(
        _ request: URLRequest,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 2.0
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }

                // Check status code
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 { // Rate limited
                        // Exponential backoff
                        let delay = retryDelay * pow(2.0, Double(attempt))
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                    throw APIError.httpError(
                        statusCode: httpResponse.statusCode,
                        message: nil
                    )
                }

                // Decode response
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)

            } catch {
                lastError = error

                // Don't retry if not recoverable
                if let apiError = error as? APIError, !apiError.isRecoverable {
                    throw apiError
                }

                // Wait before retry (exponential backoff)
                if attempt < maxRetries - 1 {
                    let delay = retryDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? APIError.unknown
    }
}
```

## 6. API Documentation & Testing

### 6.1 Mock Services

```swift
class MockWeatherService: WeatherService {
    var mockWeather: CurrentWeather?
    var shouldThrowError: Bool = false

    func getCurrentWeather(for location: CLLocation) async throws -> CurrentWeather {
        if shouldThrowError {
            throw WeatherServiceError.weatherDataUnavailable
        }

        return mockWeather ?? CurrentWeather(
            temperature: Measurement(value: 72, unit: .fahrenheit),
            feelsLike: Measurement(value: 70, unit: .fahrenheit),
            condition: .clear,
            humidity: 0.5,
            windSpeed: Measurement(value: 5, unit: .milesPerHour),
            precipitationProbability: 0.1,
            uvIndex: 6,
            timestamp: Date()
        )
    }

    func getForecast(for location: CLLocation, days: Int) async throws -> [DailyForecast] {
        if shouldThrowError {
            throw WeatherServiceError.weatherDataUnavailable
        }

        return (0..<days).map { day in
            DailyForecast(
                date: Date().addingDays(day),
                high: Measurement(value: 75, unit: .fahrenheit),
                low: Measurement(value: 60, unit: .fahrenheit),
                condition: .clear,
                precipitationProbability: 0.1
            )
        }
    }
}
```

### 6.2 Integration Tests

```swift
class WeatherServiceIntegrationTests: XCTestCase {
    var service: WeatherService!

    override func setUp() {
        super.setUp()
        service = AppleWeatherService()
    }

    func testGetCurrentWeather() async throws {
        // Test location: San Francisco
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)

        let weather = try await service.getCurrentWeather(for: location)

        XCTAssertNotNil(weather)
        XCTAssertGreaterThan(weather.temperature.value, -50)
        XCTAssertLessThan(weather.temperature.value, 150)
        XCTAssertGreaterThanOrEqual(weather.humidity, 0.0)
        XCTAssertLessThanOrEqual(weather.humidity, 1.0)
    }

    func testRateLimiting() async throws {
        let limiter = RateLimiter()

        let start = Date()

        // Make 3 rapid requests
        for _ in 0..<3 {
            try await limiter.wait()
        }

        let elapsed = Date().timeIntervalSince(start)

        // Should take at least 2 seconds (2 * 1s minimum interval)
        XCTAssertGreaterThanOrEqual(elapsed, 2.0)
    }
}
```

## 7. API Rate Limits & Quotas

| Service | Free Tier Limit | Rate Limit | Notes |
|---------|----------------|------------|-------|
| WeatherKit | 500,000 calls/month | 10/minute | Per Apple Developer account |
| EventKit | N/A (local) | N/A | Device-only, no server |
| Retailers | Varies | ~1/second | Respect robots.txt, use caching |
| CloudKit | 1M requests/month | Varies | Per user quota |

## 8. Next Steps

- ✅ API protocols defined
- ⬜ Implement concrete service classes
- ⬜ Create mock services for testing
- ⬜ Setup URLSession networking layer
- ⬜ Implement retry/rate limiting
- ⬜ Write integration tests

---

**Document Status**: Draft - Ready for Review
**Next Document**: UI/UX Design & Spatial Interface Specifications
