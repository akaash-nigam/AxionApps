# ADR 0002: Service Container Dependency Injection

## Status
Accepted

## Context
We needed a dependency injection strategy that:
- Allows services to be easily mocked for testing
- Supports lazy initialization for performance
- Works with SwiftUI's environment system
- Handles service lifecycle appropriately

## Decision
We implemented a `ServiceContainer` class that:
1. Holds references to all application services
2. Uses protocol-based abstractions for all services
3. Integrates with SwiftUI via environment objects
4. Supports both production and mock implementations

### Implementation:
```swift
@Observable
final class ServiceContainer {
    let auth: AuthServiceProtocol
    let organization: OrganizationServiceProtocol
    let analytics: AnalyticsServiceProtocol
    let connectivity: ConnectivityMonitor

    init(
        auth: AuthServiceProtocol? = nil,
        organization: OrganizationServiceProtocol? = nil,
        // ...
    ) {
        self.auth = auth ?? AuthService()
        self.organization = organization ?? OrganizationService()
        // ...
    }
}
```

### Protocol-First Design:
```swift
protocol OrganizationServiceProtocol: Sendable {
    func fetchOrganization(id: UUID) async throws -> Organization
    func updateOrganization(_ org: Organization) async throws
}
```

## Consequences

### Positive
- Services can be easily mocked for unit tests
- Clear contracts via protocols
- Centralized service management
- SwiftUI environment integration is straightforward

### Negative
- Additional boilerplate for protocol definitions
- Service container can become a "god object" if not managed carefully

### Alternatives Considered
- **Swinject/Resolver**: Third-party DI frameworks - rejected for simplicity
- **Environment-only DI**: Using only SwiftUI environment - rejected for testability
- **Factory pattern**: More complex setup - not needed for our scale

## Related Decisions
- ADR 0001: MVVM Architecture
- ADR 0005: Protocol-Oriented Design
