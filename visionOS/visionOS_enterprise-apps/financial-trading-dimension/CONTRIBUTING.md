# Contributing to Financial Trading Dimension

Thank you for your interest in contributing to Financial Trading Dimension! This guide will help you get started with contributing to this visionOS trading platform.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [How to Contribute](#how-to-contribute)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Commit Guidelines](#commit-guidelines)
8. [Pull Request Process](#pull-request-process)
9. [Issue Reporting](#issue-reporting)
10. [Community](#community)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) before contributing.

**In summary:**
- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Respect different viewpoints and experiences
- Accept responsibility for mistakes

---

## Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS 2.0 SDK
- **Apple Vision Pro** (device or simulator)
- **Swift 6.0** knowledge
- Basic understanding of:
  - SwiftUI and RealityKit
  - Financial markets and trading concepts
  - MVVM architecture
  - Async/await and Swift concurrency

### First Contributions

Good first issues are labeled with `good-first-issue`. These are:
- Well-defined and scoped
- Don't require deep domain knowledge
- Have clear acceptance criteria
- Include guidance for implementation

---

## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/financial-trading-dimension.git
cd financial-trading-dimension
```

### 2. Install Dependencies

```bash
# Install SwiftLint
brew install swiftlint

# Install SwiftFormat (optional)
brew install swiftformat
```

### 3. Open in Xcode

```bash
cd financial-trading-dimension
open FinancialTradingDimension.xcodeproj
```

### 4. Select Target

- Select `FinancialTradingDimension` scheme
- Choose "Apple Vision Pro" simulator or device
- Build and run (⌘R)

### 5. Verify Setup

Run the test suite to ensure everything works:
```bash
⌘U in Xcode
# Or via command line:
xcodebuild test -scheme FinancialTradingDimension \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

---

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

**Code Contributions:**
- Bug fixes
- New features
- Performance improvements
- Refactoring
- Test coverage improvements

**Documentation:**
- README improvements
- Code comments
- API documentation
- User guides
- Tutorials and examples

**Design:**
- UI/UX improvements
- 3D visualizations
- Spatial interface design
- Accessibility enhancements

**Testing:**
- Writing tests
- Identifying bugs
- User testing and feedback
- Performance testing

**Community:**
- Answering questions
- Reviewing pull requests
- Improving documentation
- Sharing knowledge

---

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) with some project-specific conventions.

### SwiftLint

All code must pass SwiftLint checks:
```bash
swiftlint lint
```

Fix auto-correctable issues:
```bash
swiftlint --fix
```

### Code Organization

```swift
// MARK: - Properties
// Group related properties

// MARK: - Initialization
// Initializers

// MARK: - Lifecycle
// View lifecycle methods

// MARK: - Actions
// User action handlers

// MARK: - Private Methods
// Private helper methods
```

### Naming Conventions

**Variables and Functions:**
```swift
// Use clear, descriptive names
let portfolioTotalValue: Decimal  // Good
let ptv: Decimal                  // Bad

// Boolean properties start with "is", "has", "should"
var isMarketOpen: Bool
var hasActiveOrders: Bool
var shouldShowAlert: Bool
```

**Types:**
```swift
// PascalCase for types
class MarketDataService { }
struct PortfolioMetrics { }
enum OrderType { }
```

**Constants:**
```swift
// Use descriptive names, not ALL_CAPS
private let defaultUpdateInterval: TimeInterval = 1.0
private let maximumRetryAttempts = 3
```

### Comments

```swift
// Use comments to explain "why", not "what"

// Bad: Increment counter
count += 1

// Good: Track number of failed retries for exponential backoff
retryCount += 1

/// Use doc comments for public APIs
///
/// Calculates the Value at Risk for the portfolio.
///
/// - Parameters:
///   - portfolio: The portfolio to analyze
///   - confidence: Confidence level (0.95 for 95%, 0.99 for 99%)
/// - Returns: VaR amount in portfolio currency
func calculateVaR(portfolio: Portfolio, confidence: Double) async -> Decimal
```

### Error Handling

```swift
// Prefer throwing functions over optionals for error conditions
func submitOrder(_ order: Order) async throws -> OrderConfirmation {
    guard order.quantity > 0 else {
        throw TradingError.invalidQuantity
    }
    // ...
}

// Use guard for early returns
guard let portfolio = selectedPortfolio else {
    return
}

// Avoid force unwrapping - use optional binding
if let quote = marketData[symbol] {
    // Use quote
}
```

### Async/Await

```swift
// Prefer async/await over callbacks
func fetchMarketData() async throws -> [MarketData] {
    try await marketDataService.getQuotes(symbols: watchlist)
}

// Mark UI updates with @MainActor when needed
@MainActor
func updatePriceDisplay() {
    // UI updates
}
```

### SwiftUI Best Practices

```swift
// Extract subviews for clarity
struct PortfolioView: View {
    var body: some View {
        VStack {
            portfolioHeader
            positionsList
            performanceChart
        }
    }

    private var portfolioHeader: some View {
        // Header implementation
    }
}

// Use Environment for dependency injection
@Environment(AppModel.self) private var appModel

// Prefer @State for view-local state
@State private var isShowingAlert = false
```

---

## Testing Guidelines

### Test Coverage Requirements

- **Minimum coverage**: 80% overall
- **Critical business logic**: 100% coverage
- **New features**: Must include tests

### Writing Tests

```swift
// Use descriptive test names
func testPortfolioCalculatesTotalValue() {
    // Given
    let position1 = Position(symbol: "AAPL", quantity: 100, ...)
    let portfolio = Portfolio(positions: [position1])

    // When
    let totalValue = portfolio.totalValue

    // Then
    XCTAssertEqual(totalValue, 18000.00)
}

// Test edge cases
func testPortfolioWithZeroPositions() { }
func testOrderSubmissionWithInvalidQuantity() { }
```

### Test Organization

- Place tests in `Tests/` directory
- Name test files with `Tests` suffix: `PortfolioTests.swift`
- Group related tests in test classes
- Use `setUp()` and `tearDown()` for test fixtures

### Running Tests

```bash
# Run all tests
⌘U in Xcode

# Run specific test
⌘-click on test method > Run "testName"

# Command line
xcodebuild test -scheme FinancialTradingDimension
```

---

## Commit Guidelines

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(portfolio): add P&L calculation for positions

Implement unrealized profit/loss calculation for individual
positions based on current market price and average cost.

Closes #123

---

fix(trading): prevent order submission with negative quantity

Add validation to reject orders with quantity <= 0 before
submission to prevent API errors.

Fixes #456

---

docs(readme): update installation instructions

Add step for installing visionOS simulator and clarify
Xcode version requirements.
```

### Commit Best Practices

- **Atomic commits**: One logical change per commit
- **Clear messages**: Explain what and why, not how
- **Reference issues**: Include issue numbers
- **Sign commits**: Use GPG signing (optional but recommended)

---

## Pull Request Process

### Before Submitting

1. **Create an issue** (for non-trivial changes)
2. **Fork the repository**
3. **Create a feature branch**:
   ```bash
   git checkout -b feat/your-feature-name
   ```
4. **Make your changes**
5. **Write tests**
6. **Update documentation**
7. **Run tests**: Ensure all tests pass
8. **Run SwiftLint**: Fix all violations
9. **Commit changes**: Follow commit guidelines

### Submitting a Pull Request

1. **Push to your fork**:
   ```bash
   git push origin feat/your-feature-name
   ```

2. **Open a pull request** with:
   - Clear title and description
   - Reference to related issue
   - Screenshots/videos (for UI changes)
   - Test results

3. **Complete the PR template**

4. **Request review** from maintainers

### PR Requirements

Your PR must:
- [ ] Pass all CI checks
- [ ] Include tests for new functionality
- [ ] Update documentation if needed
- [ ] Follow coding standards
- [ ] Have a clear description
- [ ] Reference related issues
- [ ] Have no merge conflicts

### Review Process

1. **Automated checks** run first (CI/CD pipeline)
2. **Code review** by maintainers
3. **Feedback and iteration** (if needed)
4. **Approval** from at least 1 maintainer
5. **Merge** (squash and merge preferred)

### After Merge

- Your changes will be included in the next release
- Close related issues
- Update documentation if needed
- Celebrate! 🎉

---

## Issue Reporting

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check documentation** for answers
3. **Try the latest version** to see if it's fixed
4. **Gather information** (steps to reproduce, logs, etc.)

### Creating a Good Issue

Use the appropriate template:
- **Bug Report**: For reporting bugs
- **Feature Request**: For suggesting features
- **Performance Issue**: For performance problems
- **Documentation**: For documentation improvements

**Include:**
- Clear, descriptive title
- Environment details (Xcode version, visionOS version, device)
- Steps to reproduce (for bugs)
- Expected vs. actual behavior
- Screenshots or videos (if applicable)
- Error messages or logs
- Code snippets (if relevant)

### Issue Labels

- `bug`: Something isn't working
- `feature`: New feature request
- `documentation`: Documentation improvements
- `good-first-issue`: Good for newcomers
- `help-wanted`: Extra attention needed
- `performance`: Performance improvements
- `accessibility`: Accessibility improvements
- `security`: Security issues

---

## Community

### Getting Help

- **GitHub Discussions**: For questions and discussions
- **Issues**: For bug reports and feature requests
- **Documentation**: Check docs first
- **Code of Conduct**: Review community guidelines

### Communication Channels

- **GitHub Issues**: Primary communication
- **Pull Requests**: For code review and discussion
- **Discussions**: For questions and ideas

### Recognition

Contributors are recognized through:
- Credits in release notes
- Contributor badge
- Acknowledgments in documentation

---

## Development Workflow

### Branching Strategy

```
main          - Production-ready code
├── develop   - Integration branch (if used)
└── feature/* - Feature branches
    ├── fix/* - Bug fix branches
    └── docs/* - Documentation branches
```

### Release Process

1. Create release branch from `main`
2. Update version numbers
3. Update CHANGELOG
4. Test thoroughly
5. Merge to `main`
6. Tag release
7. Deploy to App Store

---

## Additional Resources

### Documentation

- [README.md](./README.md) - Project overview
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Architecture documentation
- [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) - API reference
- [TESTING_STRATEGY.md](./TESTING_STRATEGY.md) - Testing guide

### Learning Resources

- [Apple visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Tools

- [Xcode](https://developer.apple.com/xcode/) - IDE
- [SwiftLint](https://github.com/realm/SwiftLint) - Linting
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) - Formatting
- [Instruments](https://developer.apple.com/instruments/) - Profiling

---

## Questions?

If you have questions not covered in this guide:

1. Check the [documentation](./README.md)
2. Search [existing issues](../../issues)
3. Ask in [GitHub Discussions](../../discussions)
4. Contact maintainers

---

**Thank you for contributing to Financial Trading Dimension!** 🚀

Your contributions help make spatial computing trading better for everyone.
