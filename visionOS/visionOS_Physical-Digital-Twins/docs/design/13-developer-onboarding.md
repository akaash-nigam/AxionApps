# Developer Onboarding & Code Standards

## Overview

This document provides onboarding information for new developers and establishes code standards for the Physical-Digital Twins project.

## Getting Started

### Prerequisites

**Required**:
- Mac with Apple Silicon (M1 or later)
- macOS Sonoma 14.0+
- Xcode 15.2+
- Apple Developer account ($99/year)
- Vision Pro device (for full testing) or Simulator

**Recommended**:
- 16 GB RAM minimum
- Git knowledge
- Swift 5.9+ experience
- SwiftUI experience
- Basic understanding of AR/RealityKit

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourorg/physical-digital-twins.git
cd physical-digital-twins

# 2. Install dependencies (if using SPM packages)
open PhysicalDigitalTwins.xcodeproj
# Xcode will resolve Swift Package dependencies automatically

# 3. Configure code signing
# Open project settings → Signing & Capabilities
# Select your team and provisioning profile

# 4. Build and run
# Select Vision Pro simulator or device
# Cmd+R to build and run
```

### API Keys Setup

```swift
// DO NOT commit API keys to git
// Store in Keychain or environment variables for development

// Development: Create Config.xcconfig (gitignored)
AMAZON_API_KEY = your_key_here
GOOGLE_BOOKS_API_KEY = your_key_here
UPC_DATABASE_API_KEY = your_key_here

// Access in code via APIKeyManager
let amazonKey = try APIKeyManager.shared.retrieve(for: "amazon")
```

## Project Structure

```
PhysicalDigitalTwins/
├── App/
│   ├── PhysicalDigitalTwinsApp.swift
│   ├── AppState.swift
│   └── AppDependencies.swift
├── Features/
│   ├── Scanning/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── Inventory/
│   ├── DigitalTwin/
│   └── Settings/
├── Services/
│   ├── VisionService/
│   ├── StorageService/
│   ├── SyncService/
│   └── APIService/
├── Models/
│   ├── DigitalTwin.swift
│   ├── InventoryItem.swift
│   └── ...
├── Persistence/
│   ├── CoreData/
│   │   ├── PhysicalDigitalTwins.xcdatamodeld
│   │   └── PersistenceController.swift
│   └── Cache/
├── AR/
│   ├── Entities/
│   ├── Components/
│   └── Systems/
├── Utilities/
│   ├── Extensions/
│   ├── Helpers/
│   └── Constants/
├── Resources/
│   ├── Assets.xcassets
│   ├── MLModels/
│   └── Localizations/
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

## Code Standards

### Swift Style Guide

**Follow Apple's Swift API Design Guidelines**

#### Naming Conventions

```swift
// Types: UpperCamelCase
class DigitalTwinManager { }
struct BookTwin { }
enum ObjectCategory { }
protocol VisionService { }

// Functions & variables: lowerCamelCase
func recognizeObject(from image: CIImage) async throws { }
let totalValue: Decimal = 0
var isProcessing = false

// Constants: lowerCamelCase
let maxCacheSize = 500_000_000

// Enums: lowercase for cases
enum ReadingStatus {
    case unread, reading, finished
}
```

#### Code Organization

```swift
// MARK: - Comments for organization
class InventoryViewModel {
    // MARK: - Properties

    @Published var items: [InventoryItem] = []
    private let repository: StorageService

    // MARK: - Initialization

    init(repository: StorageService) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func loadItems() async {
        // Implementation
    }

    // MARK: - Private Methods

    private func sortItems() {
        // Implementation
    }
}
```

#### Type Inference

```swift
// ✅ Good: Use type inference where obvious
let name = "Atomic Habits"
let count = items.count
let isValid = validator.validate(input)

// ❌ Bad: Unnecessary explicit types
let name: String = "Atomic Habits"
let count: Int = items.count

// ✅ Good: Explicit types when needed
let price: Decimal = 19.99  // Not Double
let callback: ((Result<Data, Error>) -> Void)? = nil
```

#### Guard vs If

```swift
// ✅ Good: Use guard for early returns
func process(_ item: InventoryItem?) {
    guard let item = item else {
        return
    }

    // Continue with item
}

// ❌ Bad: Nested if
func process(_ item: InventoryItem?) {
    if let item = item {
        // All code nested
    }
}
```

#### Async/Await

```swift
// ✅ Good: Use async/await
func fetchData() async throws -> Data {
    let data = try await networkService.fetch()
    return data
}

// ❌ Bad: Completion handlers (avoid for new code)
func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
    networkService.fetch { result in
        completion(result)
    }
}
```

#### Error Handling

```swift
// ✅ Good: Specific error types
enum RecognitionError: LocalizedError {
    case unrecognized
    case lowConfidence
    case modelLoadFailed

    var errorDescription: String? {
        switch self {
        case .unrecognized:
            return "Could not identify object"
        case .lowConfidence:
            return "Low confidence in recognition"
        case .modelLoadFailed:
            return "Failed to load ML model"
        }
    }
}

// ❌ Bad: Generic errors
throw NSError(domain: "RecognitionError", code: 1, userInfo: nil)
```

### SwiftUI Best Practices

```swift
// ✅ Good: Small, focused views
struct InventoryListView: View {
    let items: [InventoryItem]

    var body: some View {
        List(items) { item in
            InventoryRow(item: item)
        }
    }
}

struct InventoryRow: View {
    let item: InventoryItem

    var body: some View {
        HStack {
            // Row content
        }
    }
}

// ❌ Bad: Monolithic views
struct InventoryListView: View {
    var body: some View {
        List {
            // 200 lines of view code
        }
    }
}
```

### Concurrency

```swift
// ✅ Good: MainActor for UI updates
@MainActor
class ViewModel: ObservableObject {
    @Published var data: [Item] = []

    func loadData() async {
        let items = try? await fetchItems() // Background
        self.data = items ?? [] // Automatically on main thread
    }
}

// ✅ Good: Actor for shared state
actor ImageCache {
    private var cache: [String: UIImage] = [:]

    func get(key: String) -> UIImage? {
        cache[key]
    }

    func set(key: String, image: UIImage) {
        cache[key] = image
    }
}
```

## Testing Standards

### Test Organization

```swift
class InventoryViewModelTests: XCTestCase {
    var sut: InventoryViewModel! // System Under Test
    var mockRepository: MockStorageService!

    override func setUp() {
        super.setUp()
        mockRepository = MockStorageService()
        sut = InventoryViewModel(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadItems_Success() async throws {
        // Arrange
        let expectedItems = [InventoryItem.mock]
        mockRepository.itemsToReturn = expectedItems

        // Act
        await sut.loadItems()

        // Assert
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.id, expectedItems.first?.id)
    }

    func testLoadItems_Failure() async throws {
        // Arrange
        mockRepository.shouldFail = true

        // Act
        await sut.loadItems()

        // Assert
        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertNotNil(sut.error)
    }
}
```

### Test Coverage

**Targets**:
- Data layer: 90%+
- Service layer: 85%+
- ViewModels: 80%+
- Views: 60%+ (focus on logic, not UI)

**Required tests before merge**:
- All new functions have at least one test
- All bug fixes have regression test
- All public APIs have tests

## Git Workflow

### Branch Naming

```
feature/add-expiration-tracking
bugfix/fix-barcode-scanning-crash
refactor/improve-image-caching
hotfix/critical-sync-bug
```

### Commit Messages

```
feat: Add expiration date OCR extraction

- Implement text extraction from food labels
- Add date parsing with multiple formats
- Add unit tests for date extraction

Closes #123
```

**Format**:
```
<type>: <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing on device

## Checklist
- [ ] Code follows style guide
- [ ] Self-reviewed code
- [ ] Comments added where needed
- [ ] Tests pass locally
- [ ] No new warnings
```

## Documentation Standards

### Code Comments

```swift
/// Recognizes objects from camera feed using ML and barcode scanning.
///
/// This service tries barcode scanning first for speed and accuracy,
/// then falls back to ML classification if no barcode is found.
///
/// - Parameter image: The captured camera frame to analyze
/// - Returns: Recognition result with identified object type
/// - Throws: `RecognitionError` if recognition fails
func recognizeObject(from image: CIImage) async throws -> RecognitionResult {
    // Try barcode first (fastest)
    if let barcode = try? await scanBarcode(from: image) {
        return RecognitionResult(method: .barcode, identifier: barcode.value)
    }

    // Fall back to ML classification
    return try await classifyObject(image)
}
```

### README Files

Each feature module should have a README:

```markdown
# Expiration Tracking

## Overview
Tracks food expiration dates using OCR and sends notifications.

## Architecture
- `ExpirationTracker`: Main service
- `DateExtractor`: OCR for dates
- `NotificationScheduler`: Schedules alerts

## Usage
\`\`\`swift
let tracker = ExpirationTracker()
await tracker.trackExpiration(for: foodItem)
\`\`\`

## Testing
Run `ExpirationTrackerTests` for unit tests.
```

## Performance Guidelines

- Profile before optimizing
- Target 90 Hz in AR mode
- Keep memory under 850 MB
- Lazy load large datasets
- Cache aggressively
- Use Instruments regularly

## Accessibility

- All images need alt text
- All buttons need labels
- Support VoiceOver
- Support Dynamic Type
- Test with accessibility features enabled

## Common Pitfalls

### Pitfall 1: Blocking Main Thread

```swift
// ❌ Bad
func loadImage() {
    let data = try! Data(contentsOf: url) // Blocks main thread!
    image = UIImage(data: data)
}

// ✅ Good
func loadImage() async {
    let data = try? await URLSession.shared.data(from: url).0
    image = data.flatMap { UIImage(data: $0) }
}
```

### Pitfall 2: Retain Cycles

```swift
// ❌ Bad
class ViewModel {
    var completion: (() -> Void)?

    func setup() {
        completion = {
            self.doSomething() // Strong reference cycle!
        }
    }
}

// ✅ Good
func setup() {
    completion = { [weak self] in
        self?.doSomething()
    }
}
```

### Pitfall 3: Force Unwrapping

```swift
// ❌ Bad
let title = book.title! // Crashes if nil

// ✅ Good
guard let title = book.title else {
    return
}

// or
let title = book.title ?? "Unknown"
```

## Resources

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [Core ML Documentation](https://developer.apple.com/documentation/coreml)

## Questions?

- Check design docs in `/docs/design`
- Ask in team Slack channel
- Create GitHub issue for bugs
- Review existing PRs for examples

## Summary

Following these standards ensures:
- **Consistent Code**: Easy to read and maintain
- **Quality**: Tested and reliable
- **Collaboration**: Clear conventions
- **Performance**: Optimized from the start

Good code is not just code that works—it's code that others can understand, maintain, and extend.
