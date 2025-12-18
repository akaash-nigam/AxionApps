# ADR 0001: MVVM Architecture with @Observable

## Status
Accepted

## Context
We needed to choose an architecture pattern for the visionOS Business Operating System that:
- Integrates well with SwiftUI's reactive paradigm
- Supports testability and separation of concerns
- Works efficiently with visionOS spatial computing features
- Handles complex state management for business data

## Decision
We adopted the MVVM (Model-View-ViewModel) pattern using Swift's new `@Observable` macro (iOS 17+/visionOS 1.0+) instead of the older `ObservableObject` protocol.

### Key Implementation Details:
1. **ViewModels use `@Observable`** - Provides automatic observation without explicit `@Published` properties
2. **Views use `@Bindable`** - For two-way bindings to observable objects
3. **Services are injected** - Via `ServiceContainer` for testability
4. **AppState is global** - Single source of truth for app-wide state

### Example:
```swift
@Observable
final class DashboardViewModel {
    var departments: [Department] = []
    var isLoading = false

    private let organizationService: OrganizationServiceProtocol

    init(organizationService: OrganizationServiceProtocol) {
        self.organizationService = organizationService
    }
}
```

## Consequences

### Positive
- Simpler syntax than `ObservableObject` with `@Published`
- Better performance with fine-grained observation
- Native SwiftUI integration without Combine boilerplate
- Clear separation between UI logic and business logic
- Easy to test ViewModels in isolation

### Negative
- Requires iOS 17+/visionOS 1.0+ (acceptable for visionOS-only app)
- Team needs to learn new observation patterns
- Some edge cases with nested observable objects

### Neutral
- Migration path from ObservableObject is straightforward
- SwiftData models integrate seamlessly

## Related Decisions
- ADR 0002: Dependency Injection Pattern
- ADR 0003: SwiftData for Persistence
