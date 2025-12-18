# Architecture Decision Records (ADRs)

## What is an ADR?

An Architecture Decision Record (ADR) captures an important architectural decision made along with its context and consequences.

---

## ADR Template

Use this template for new ADRs:

```markdown
# ADR-XXXX: [Short Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Date**: YYYY-MM-DD
**Deciders**: [List of people involved]
**Technical Story**: [Link to issue/epic]

## Context

[Describe the context and problem statement]

## Decision Drivers

- [Driver 1]
- [Driver 2]
- [Driver 3]

## Considered Options

### Option 1: [Title]
[Description]

**Pros:**
- [Pro 1]
- [Pro 2]

**Cons:**
- [Con 1]
- [Con 2]

### Option 2: [Title]
[Description]

**Pros:**
- [Pro 1]

**Cons:**
- [Con 1]

## Decision Outcome

**Chosen option**: [Option X] because [justification]

### Positive Consequences

- [Benefit 1]
- [Benefit 2]

### Negative Consequences

- [Trade-off 1]
- [Trade-off 2]

## Implementation Notes

[How this will be implemented]

## References

- [Link 1]
- [Link 2]
```

---

## Existing ADRs

### ADR-0001: Use MVVM Architecture Pattern

**Status**: Accepted
**Date**: 2025-11-17
**Deciders**: Architecture Team

#### Context

Financial Trading Dimension requires a scalable, testable architecture that works well with SwiftUI and handles complex state management for real-time trading data.

#### Decision Drivers

- Need clear separation of concerns
- Must support SwiftUI's reactive paradigm
- Require high testability for financial calculations
- Need to handle complex async operations
- Must scale to enterprise requirements

#### Considered Options

**Option 1: MVVM (Model-View-ViewModel)**
- Industry standard for SwiftUI
- Clear separation: Models (data), Views (UI), ViewModels (logic)
- Highly testable
- Works naturally with SwiftUI's @Observable

**Pros:**
- Excellent testability
- Clear separation of concerns
- Native SwiftUI support
- Well-documented pattern
- Team familiarity

**Cons:**
- Can lead to "fat" ViewModels
- Requires discipline to maintain boundaries

**Option 2: MVC (Model-View-Controller)**
- Traditional iOS pattern
- Simple and well-known

**Pros:**
- Simple
- Well understood

**Cons:**
- Tends toward massive view controllers
- Poor testability
- Not ideal for SwiftUI

**Option 3: Clean Architecture (VIPER/VIP)**
- Very strict separation
- Maximum testability

**Pros:**
- Excellent separation
- Highly testable

**Cons:**
- Complex for this app size
- Steep learning curve
- Over-engineering for current needs

#### Decision Outcome

**Chosen**: MVVM with @Observable pattern

**Justification**:
- Best fit for SwiftUI
- Proven pattern for financial apps
- Excellent testability
- Team expertise
- Scales well to enterprise

#### Positive Consequences

- High test coverage achieved (90%)
- Clear code organization
- Easy to onboard new developers
- Natural fit with SwiftUI

#### Negative Consequences

- Need to watch for ViewModels growing too large
- Requires extracting services to prevent bloat

#### Implementation

```swift
// Models - Pure data
@Model class Portfolio { }

// Services - Business logic
class MarketDataService { }

// ViewModels - No longer needed with @Observable
// AppModel handles global state

// Views - SwiftUI, consume services directly
struct PortfolioView: View {
    @Environment(AppModel.self) private var appModel
}
```

---

### ADR-0002: Use SwiftData for Local Persistence

**Status**: Accepted
**Date**: 2025-11-17
**Deciders**: Architecture Team

#### Context

Need local data persistence for portfolio data, positions, order history, and settings. Must work seamlessly with SwiftUI and visionOS.

#### Decision Drivers

- Native visionOS support
- SwiftUI integration
- Type safety
- Automatic synchronization
- Migration support

#### Considered Options

**Option 1: SwiftData**
**Option 2: Core Data**
**Option 3: SQLite directly**
**Option 4: Realm**

#### Decision Outcome

**Chosen**: SwiftData

**Justification**:
- Native visionOS 2.0 framework
- Modern Swift-first API
- Automatic SwiftUI integration
- Type-safe by default
- Future-proof

#### Implementation

```swift
@Model class Portfolio {
    var id: UUID
    var positions: [Position]
    // SwiftData handles persistence automatically
}
```

---

### ADR-0003: Use Decimal for All Financial Values

**Status**: Accepted
**Date**: 2025-11-17
**Deciders**: Architecture Team, Compliance

#### Context

Financial calculations must be precise. Floating-point arithmetic (Float, Double) can introduce rounding errors that are unacceptable for money.

#### Decision Drivers

- Financial accuracy required
- Regulatory compliance
- No rounding errors
- Industry standard

#### Considered Options

**Option 1: Decimal**
- Exact decimal arithmetic
- No floating-point errors
- Industry standard for finance

**Pros:**
- Perfect accuracy
- Compliance friendly
- No rounding issues

**Cons:**
- Slightly slower than Double
- More memory (16 bytes vs 8 bytes)

**Option 2: Double**
- Fast
- Memory efficient

**Pros:**
- Performance

**Cons:**
- ❌ Rounding errors
- ❌ Not suitable for money
- ❌ Compliance risk

#### Decision Outcome

**Chosen**: Decimal for ALL financial values

**Rule**: NEVER use Float or Double for prices, quantities, P&L, or any monetary value.

```swift
// ✅ Correct
var price: Decimal = 189.45
var pnl: Decimal = 3250.00

// ❌ NEVER do this
var price: Double = 189.45  // NO!
```

#### Impact

- All financial models use Decimal
- All calculations are precise
- Compliance requirements met
- Slightly higher memory usage (acceptable)

---

### ADR-0004: Use Mock Services in Development

**Status**: Accepted
**Date**: 2025-11-17

#### Context

Real market data and trading APIs are:
- Expensive (subscription fees)
- Rate-limited
- Require credentials
- Unstable during development
- Not suitable for testing

#### Decision Outcome

**Chosen**: Protocol-based service layer with mock implementations

```swift
// Protocol
protocol MarketDataService {
    func getQuote(symbol: String) async throws -> MarketData
}

// Mock for development/testing
class MockMarketDataService: MarketDataService { }

// Real for production
class LiveMarketDataService: MarketDataService { }
```

**Benefits**:
- Develop without API costs
- Fast iteration
- Reliable testing
- No rate limits
- Offline development

---

### ADR-0005: Use RealityKit for 3D Visualizations

**Status**: Accepted
**Date**: 2025-11-17

#### Context

Need 3D visualizations for correlation matrices, risk exposure, and technical analysis.

#### Considered Options

**Option 1: RealityKit** ✅
- Native visionOS framework
- Optimized for Vision Pro
- SwiftUI integration
- Spatial audio

**Option 2: SceneKit**
- Older framework
- Less optimized for visionOS

**Option 3: Custom Metal**
- Maximum control
- Very complex

#### Decision Outcome

**Chosen**: RealityKit

- Best performance on Vision Pro
- Native spatial computing features
- SwiftUI integration
- Future-proof

---

### ADR-0006: Use Async/Await for Concurrency

**Status**: Accepted
**Date**: 2025-11-17

#### Context

App needs to handle:
- Real-time market data streaming
- Concurrent API calls
- Background data processing
- UI updates on main thread

#### Decision Outcome

**Chosen**: Swift async/await with structured concurrency

```swift
// Modern, safe concurrency
func updateMarketData() async {
    async let quotes = fetchQuotes()
    async let news = fetchNews()
    await updateUI(quotes: quotes, news: news)
}
```

**Benefits**:
- Compiler-checked
- No callback hell
- Structured cancellation
- @MainActor for UI safety

---

## Creating New ADRs

### When to Create an ADR

Create an ADR when making decisions about:
- Architecture patterns
- Technology choices
- Data models
- API design
- Security approaches
- Performance trade-offs
- Integration strategies

### ADR Workflow

1. **Identify decision** that needs documenting
2. **Create ADR** using template
3. **Discuss** with team
4. **Update** based on feedback
5. **Accept** when consensus reached
6. **Reference** in code/PRs

### ADR Numbering

- Use sequential numbers: ADR-0001, ADR-0002, etc.
- Never reuse numbers
- Keep in `docs/adr/` directory

### ADR Status

- **Proposed**: Under discussion
- **Accepted**: Decision made, being implemented
- **Deprecated**: No longer relevant
- **Superseded**: Replaced by newer ADR

---

## ADR Index

| Number | Title | Status | Date |
|--------|-------|--------|------|
| [0001](#adr-0001-use-mvvm-architecture-pattern) | Use MVVM Architecture | Accepted | 2025-11-17 |
| [0002](#adr-0002-use-swiftdata-for-local-persistence) | Use SwiftData | Accepted | 2025-11-17 |
| [0003](#adr-0003-use-decimal-for-all-financial-values) | Use Decimal for Money | Accepted | 2025-11-17 |
| [0004](#adr-0004-use-mock-services-in-development) | Use Mock Services | Accepted | 2025-11-17 |
| [0005](#adr-0005-use-realitykit-for-3d-visualizations) | Use RealityKit | Accepted | 2025-11-17 |
| [0006](#adr-0006-use-asyncawait-for-concurrency) | Use Async/Await | Accepted | 2025-11-17 |

---

## Future ADRs to Consider

Potential decisions that may need ADRs:

- [ ] Real-time data streaming protocol (WebSocket vs SSE)
- [ ] State management approach (if scaling beyond AppModel)
- [ ] Caching strategy for market data
- [ ] Error handling and recovery patterns
- [ ] Analytics and monitoring approach
- [ ] Deployment strategy (phased rollout, etc.)
- [ ] API versioning strategy
- [ ] Localization approach

---

## References

- [Architecture Decision Records](https://adr.github.io/)
- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR Tools](https://github.com/npryce/adr-tools)

---

**Last Updated**: 2025-11-17
**Version**: 1.0
