# Swift Code Style Guide

Official coding standards for the Supply Chain Control Tower visionOS application.

## Table of Contents

- [Naming Conventions](#naming-conventions)
- [Code Organization](#code-organization)
- [SwiftUI Best Practices](#swiftui-best-practices)
- [RealityKit Patterns](#realitykit-patterns)
- [Async/Await Guidelines](#asyncawait-guidelines)
- [Error Handling](#error-handling)
- [Comments and Documentation](#comments-and-documentation)
- [Performance Considerations](#performance-considerations)

---

## Naming Conventions

### General Rules

- Use **descriptive names** that clearly indicate purpose
- Prefer **clarity over brevity**
- Use **camelCase** for variables and functions
- Use **PascalCase** for types (classes, structs, enums, protocols)

### Types

```swift
// Good
struct SupplyChainNetwork { }
class NetworkService { }
enum NodeType { }
protocol NetworkServiceProtocol { }

// Bad
struct SCN { }
class netSvc { }
enum nodetp { }
```

### Variables and Constants

```swift
// Good
let maximumCapacity = 1000
var currentProgress: Double = 0.5
let geographicCoordinate = GeographicCoordinate(latitude: 40.7, longitude: -74.0)

// Bad
let max = 1000
var prog: Double = 0.5
let coord = GeographicCoordinate(latitude: 40.7, longitude: -74.0)
```

### Functions

```swift
// Good - Reads like a sentence
func fetchNetwork(withCachePolicy policy: CachePolicy) async throws -> SupplyChainNetwork
func updateShipment(_ id: String, status: FlowStatus) async throws
func calculateDistance(from start: GeographicCoordinate, to end: GeographicCoordinate) -> Double

// Bad
func fetch(policy: CachePolicy) async throws -> SupplyChainNetwork
func update(_ id: String, _ status: FlowStatus) async throws
func calcDist(_ start: GeographicCoordinate, _ end: GeographicCoordinate) -> Double
```

### Enums

```swift
// Good - Clear case names
enum FlowStatus: String, Codable {
    case pending
    case inTransit
    case delayed
    case delivered
    case cancelled
}

// Bad
enum FlowStatus {
    case p
    case it
    case d
}
```

### Booleans

Prefix with `is`, `has`, `should`, or `can`:

```swift
// Good
var isLoading: Bool = false
var hasInventory: Bool = true
var shouldRefresh: Bool = false
var canExpedite: Bool = true

// Bad
var loading: Bool = false
var inventory: Bool = true
```

---

## Code Organization

### File Structure

Each Swift file should follow this structure:

```swift
//
//  FileName.swift
//  SupplyChainControlTower
//
//  Brief description of what this file contains
//

import Foundation
import SwiftUI
import RealityKit

// MARK: - Main Type

struct/Class MainType {

    // MARK: - Properties

    // Public properties first
    var publicProperty: String

    // Private properties last
    private var privateProperty: Int

    // MARK: - Initialization

    init() { }

    // MARK: - Public Methods

    func publicMethod() { }

    // MARK: - Private Methods

    private func privateMethod() { }
}

// MARK: - Extensions

extension MainType {
    // Extension code
}

// MARK: - Supporting Types

struct SupportingType {
    // Supporting type code
}
```

### MARK Comments

Use `// MARK:` to organize code sections:

```swift
// MARK: - Type Definitions
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Protocol Conformance
```

Use `// MARK: -` (with dash) for major sections.

---

## SwiftUI Best Practices

### View Structure

Keep views small and focused:

```swift
// Good - Decomposed into subviews
struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                KPICardsView()
                ActiveShipmentsListView()
                QuickActionsView()
            }
        }
    }
}

// Bad - Monolithic view
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack {
                // 500 lines of nested views
            }
        }
    }
}
```

### @Observable Pattern

Use `@Observable` for ViewModels:

```swift
// Good
@Observable
@MainActor
class DashboardViewModel {
    var network: SupplyChainNetwork?
    var isLoading: Bool = false

    func loadNetwork() async {
        isLoading = true
        defer { isLoading = false }

        // Load network
    }
}

// Usage in view
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        // View code
    }
}
```

### Environment Objects

Use `@Environment` for shared state:

```swift
// Good
@Observable
class AppState {
    var selectedNode: Node?
    var selectedFlow: Flow?
}

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        DashboardView()
            .environment(appState)
    }
}

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        // Access appState
    }
}
```

---

## RealityKit Patterns

### Entity Creation

```swift
// Good - Clear, organized entity setup
func createGlobeEntity(radius: Float) -> ModelEntity {
    let mesh = MeshResource.generateSphere(radius: radius)

    var material = PhysicallyBasedMaterial()
    material.baseColor = PhysicallyBasedMaterial.BaseColor(
        tint: .blue.withAlphaComponent(0.3)
    )
    material.roughness = 0.5
    material.metallic = 0.0

    let entity = ModelEntity(mesh: mesh, materials: [material])
    entity.name = "Globe"
    entity.components.set(InputTargetComponent())

    return entity
}
```

### Component Pattern

```swift
// Good - Use components for entity behavior
struct SelectableComponent: Component {
    var isSelected: Bool = false
}

extension ModelEntity {
    func makeSelectable() {
        components.set(SelectableComponent())
        components.set(InputTargetComponent())
    }

    var isSelected: Bool {
        get { components[SelectableComponent.self]?.isSelected ?? false }
        set {
            var component = components[SelectableComponent.self] ?? SelectableComponent()
            component.isSelected = newValue
            components.set(component)
        }
    }
}
```

---

## Async/Await Guidelines

### Prefer Async/Await

```swift
// Good - Modern async/await
func fetchNetwork() async throws -> SupplyChainNetwork {
    let url = URL(string: "\(baseURL)/network")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(SupplyChainNetwork.self, from: data)
}

// Bad - Completion handlers
func fetchNetwork(completion: @escaping (Result<SupplyChainNetwork, Error>) -> Void) {
    let url = URL(string: "\(baseURL)/network")!
    URLSession.shared.dataTask(with: url) { data, _, error in
        // ...
    }.resume()
}
```

### Actor Isolation

Use actors for thread-safe shared state:

```swift
// Good
actor CacheManager {
    private var cache: [String: CacheEntry] = [:]

    func get<T: Codable>(forKey key: String) -> T? {
        guard let entry = cache[key], !entry.isExpired else {
            return nil
        }
        return entry.value as? T
    }

    func set<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval) {
        cache[key] = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))
    }
}
```

### Task Groups

Use task groups for concurrent operations:

```swift
// Good
func loadAllData() async throws -> (network: SupplyChainNetwork, disruptions: [Disruption]) {
    try await withThrowingTaskGroup(of: Any.self) { group in
        group.addTask { try await self.fetchNetwork() }
        group.addTask { try await self.fetchDisruptions() }

        var network: SupplyChainNetwork?
        var disruptions: [Disruption] = []

        for try await result in group {
            if let net = result as? SupplyChainNetwork {
                network = net
            } else if let disrupt = result as? [Disruption] {
                disruptions = disrupt
            }
        }

        return (network: network!, disruptions: disruptions)
    }
}
```

---

## Error Handling

### Custom Errors

Define clear, descriptive errors:

```swift
// Good
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case httpError(statusCode: Int)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .noData:
            return "No data received from server"
        case .decodingFailed:
            return "Failed to decode response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .timeout:
            return "Request timed out"
        }
    }
}
```

### Error Handling

```swift
// Good - Specific error handling
func loadNetwork() async {
    do {
        network = try await networkService.fetchNetwork()
    } catch NetworkError.invalidURL {
        errorMessage = "Configuration error: Invalid API endpoint"
    } catch NetworkError.httpError(let statusCode) {
        errorMessage = "Server error (\(statusCode)). Please try again."
    } catch {
        errorMessage = "Failed to load network: \(error.localizedDescription)"
    }
}

// Bad - Generic error handling
func loadNetwork() async {
    do {
        network = try await networkService.fetchNetwork()
    } catch {
        print("Error: \(error)")
    }
}
```

---

## Comments and Documentation

### Documentation Comments

Use triple-slash comments for public APIs:

```swift
/// Calculates the great circle distance between two geographic coordinates
///
/// Uses the Haversine formula to compute the shortest distance between
/// two points on a sphere.
///
/// - Parameters:
///   - from: Starting geographic coordinate
///   - to: Destination geographic coordinate
/// - Returns: Distance in kilometers
/// - Complexity: O(1)
func distance(from: GeographicCoordinate, to: GeographicCoordinate) -> Double {
    // Implementation
}
```

### Inline Comments

Use for non-obvious code:

```swift
// Good - Explains why, not what
func shouldRefreshCache() -> Bool {
    // Refresh if cache is older than 5 minutes to balance freshness and performance
    return Date().timeIntervalSince(lastRefresh) > 300
}

// Bad - States the obvious
func shouldRefreshCache() -> Bool {
    // Check if the current date minus last refresh is greater than 300
    return Date().timeIntervalSince(lastRefresh) > 300
}
```

### TODO and FIXME

```swift
// TODO: Implement caching for better performance
// FIXME: Handle edge case when route has only one node
// MARK: - This needs optimization
```

---

## Performance Considerations

### Lazy Loading

```swift
// Good - Lazy property for expensive computation
lazy var complexCalculation: Double = {
    // Expensive computation
    return result
}()
```

### Value Types

Prefer structs over classes when possible:

```swift
// Good - Immutable value type
struct GeographicCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

// Bad - Reference type for simple data
class GeographicCoordinate {
    var latitude: Double
    var longitude: Double
}
```

### Avoid Retain Cycles

```swift
// Good - Weak self in closures
networkService.fetchData { [weak self] result in
    guard let self else { return }
    self.handleResult(result)
}

// Good - Unowned for guaranteed lifetime
animation.onComplete = { [unowned self] in
    self.animationDidComplete()
}
```

### Collection Performance

```swift
// Good - Appropriate collection types
var nodesByID: [String: Node] = [:]  // O(1) lookup
var activeFlows: Set<Flow> = []      // O(1) contains

// Bad - Linear search
var nodes: [Node] = []
let node = nodes.first { $0.id == targetID }  // O(n)
```

---

## SwiftLint Integration

Run SwiftLint before committing:

```bash
swiftlint lint
swiftlint lint --fix  # Auto-fix violations
```

Configuration: `.swiftlint.yml` in project root

---

## Additional Resources

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Swift Evolution](https://apple.github.io/swift-evolution/)

---

*Last Updated: November 2025*
*Version: 1.0*
