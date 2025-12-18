# Contributing to Retail Space Optimizer

Thank you for your interest in contributing to Retail Space Optimizer! This document provides guidelines and instructions for contributing to this visionOS application.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## Getting Started

### Prerequisites

- **macOS Sonoma 14.5+** (Apple Silicon recommended)
- **Xcode 16.0+** with visionOS SDK 2.0+
- **Swift 6.0+**
- **Git** for version control
- **Apple Developer Account** (for device testing)

### Initial Setup

1. **Fork the repository**
   ```bash
   # Click "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_retail-space-optimizer.git
   cd visionOS_retail-space-optimizer
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/akaash-nigam/visionOS_retail-space-optimizer.git
   ```

4. **Run setup script**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

5. **Open in Xcode**
   ```bash
   open RetailSpaceOptimizer/RetailSpaceOptimizer.xcodeproj
   ```

## Development Environment

### Required Tools

- **Xcode 16.0+**: Primary IDE
- **visionOS Simulator**: For UI testing
- **Apple Vision Pro** (optional): For device testing and hand tracking
- **SwiftLint** (optional): Code style enforcement
  ```bash
  brew install swiftlint
  ```

### Project Structure

```
visionOS_retail-space-optimizer/
├── RetailSpaceOptimizer/
│   ├── RetailSpaceOptimizer/          # Main app code
│   │   ├── App/                       # App entry and state
│   │   ├── Models/                    # SwiftData models
│   │   ├── Views/                     # SwiftUI views
│   │   ├── Services/                  # Business logic
│   │   └── Utilities/                 # Helper functions
│   └── RetailSpaceOptimizerTests/     # Test suite
├── docs/                              # Documentation
├── scripts/                           # Automation scripts
└── example-data/                      # Sample data files
```

## How to Contribute

### Types of Contributions

We welcome the following types of contributions:

1. **Bug Fixes** - Fix issues and improve stability
2. **New Features** - Add new functionality (discuss first in issues)
3. **Performance Improvements** - Optimize rendering, memory, etc.
4. **Documentation** - Improve docs, add examples, fix typos
5. **Tests** - Add test coverage, improve test quality
6. **UI/UX Improvements** - Enhance user interface and experience
7. **Accessibility** - Improve VoiceOver, Dynamic Type support

### Finding Issues to Work On

- Check [GitHub Issues](https://github.com/akaash-nigam/visionOS_retail-space-optimizer/issues)
- Look for `good-first-issue` label for beginner-friendly tasks
- Look for `help-wanted` label for priority items
- Comment on an issue to claim it before starting work

### Reporting Bugs

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md):

1. **Clear title** describing the issue
2. **Steps to reproduce** the problem
3. **Expected behavior** vs actual behavior
4. **Environment details** (Xcode version, visionOS version, device)
5. **Screenshots/videos** if applicable
6. **Error messages** or crash logs

### Suggesting Features

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md):

1. **Problem statement** - What problem does this solve?
2. **Proposed solution** - How should it work?
3. **Alternatives considered** - Other approaches you've thought of
4. **Use cases** - Real-world scenarios where this helps

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide).

#### Key Principles

1. **Clarity at the point of use** is your most important goal
2. **Prefer clarity over brevity**
3. **Use type inference** where it improves readability
4. **Follow naming conventions** (UpperCamelCase for types, lowerCamelCase for everything else)

#### Code Examples

**Good:**
```swift
// Clear, descriptive names
func calculateStoreArea(width: Float, length: Float) -> Float {
    return width * length
}

// Proper use of @Observable
@Observable
class StoreService {
    var stores: [Store] = []

    func fetchStores() async throws -> [Store] {
        // Implementation
    }
}

// SwiftData model with proper annotations
@Model
final class Store {
    @Attribute(.unique) var id: UUID
    var name: String

    @Relationship(deleteRule: .cascade)
    var layouts: [StoreLayout]?
}
```

**Bad:**
```swift
// Unclear, abbreviated names
func calc(w: Float, l: Float) -> Float {
    return w * l
}

// Missing proper concurrency
class StoreService {
    func fetchStores(completion: @escaping ([Store]) -> Void) {
        // Old-style completion handlers
    }
}
```

### Swift 6.0 Concurrency

- **Always use async/await** for asynchronous operations
- **Use actors** for thread-safe shared state
- **Avoid @unchecked Sendable** unless absolutely necessary
- **Enable strict concurrency checking** in Xcode settings

### visionOS Best Practices

1. **Spatial Design**
   - Use appropriate window sizes (volumetric: 1.5m × 1.2m × 1.0m)
   - Respect user's physical space
   - Provide clear affordances for 3D interactions

2. **Performance**
   - Target 90 FPS in immersive spaces
   - Target 60 FPS in windows
   - Keep memory usage under 2GB
   - Use LOD (Level of Detail) for complex 3D models

3. **Accessibility**
   - Add accessibility labels to all interactive elements
   - Support VoiceOver navigation
   - Support Dynamic Type
   - Test with accessibility features enabled

### Code Organization

- **One type per file** (with exceptions for small helper types)
- **Group related files** in directories (Views/Windows, Views/Volumes, etc.)
- **Mark sections** with `// MARK: -` comments
- **Keep functions small** (prefer < 20 lines)
- **Extract complex logic** into separate functions

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

### Types

- `Add:` - New feature or functionality
- `Fix:` - Bug fix
- `Update:` - Modify existing functionality
- `Remove:` - Delete code or files
- `Refactor:` - Code restructuring (no functional changes)
- `Test:` - Add or update tests
- `Docs:` - Documentation only
- `Style:` - Code formatting (no logic changes)
- `Perf:` - Performance improvements
- `Chore:` - Build process, dependencies

### Examples

```bash
# Feature addition
git commit -m "Add: Hand tracking support for fixture manipulation"

# Bug fix
git commit -m "Fix: Heat map rendering crash on large datasets"

# Documentation
git commit -m "Docs: Add API documentation for AnalyticsService"

# Multi-line commit
git commit -m "Add: A/B testing comparison view

- Create comparison view with side-by-side layouts
- Add metrics delta calculations
- Implement statistical significance tests
- Update analytics service with comparison endpoints

Closes #42"
```

## Pull Request Process

### Before Submitting

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Write tests** for your changes
   ```bash
   # Run tests locally
   ./scripts/test.sh
   ```

3. **Update documentation** if needed
   - Update README.md if adding features
   - Update TECHNICAL_README.md for technical changes
   - Add/update code comments
   - Update CHANGELOG.md

4. **Run code quality checks**
   ```bash
   # Format code (if using SwiftLint)
   swiftlint autocorrect

   # Check for issues
   swiftlint
   ```

5. **Ensure all tests pass**
   ```bash
   xcodebuild test \
     -scheme RetailSpaceOptimizer \
     -only-testing:RetailSpaceOptimizerTests
   ```

### Submitting a Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**
   - Use the [Pull Request template](.github/PULL_REQUEST_TEMPLATE.md)
   - Fill in all sections completely
   - Link related issues (e.g., "Closes #42")

3. **PR Title Format**
   ```
   Add: Brief description of changes
   ```

4. **PR Description Should Include**
   - Summary of changes
   - Motivation and context
   - Testing performed
   - Screenshots/videos (for UI changes)
   - Breaking changes (if any)
   - Checklist completion

### PR Review Process

1. **Automated checks** must pass:
   - Unit tests (60+ tests)
   - Integration tests
   - Code coverage (maintain 55%+)
   - SwiftLint (if configured)

2. **Code review** by maintainers:
   - At least one approval required
   - Address all review comments
   - Make requested changes in new commits

3. **Merge requirements**:
   - All tests passing
   - All review comments resolved
   - Up to date with main branch
   - No merge conflicts

4. **Merge strategy**:
   - Squash and merge (for small changes)
   - Merge commit (for large features)
   - Rebase and merge (for clean history)

## Testing Requirements

### Test Coverage Goals

- **Unit Tests**: Cover all models and services (target: 80%+)
- **Integration Tests**: Cover data flow and relationships
- **UI Tests**: Cover main user workflows (when on visionOS)
- **Performance Tests**: Validate FPS and memory targets

### Writing Tests

```swift
import XCTest
@testable import RetailSpaceOptimizer

final class MyFeatureTests: XCTestCase {
    // MARK: - Setup

    override func setUp() {
        super.setUp()
        // Setup code
    }

    override func tearDown() {
        // Cleanup code
        super.tearDown()
    }

    // MARK: - Tests

    func testFeatureBehavior() {
        // Given
        let input = "test data"

        // When
        let result = performOperation(input)

        // Then
        XCTAssertEqual(result, expectedValue)
    }

    func testAsyncOperation() async throws {
        // Test async code
        let result = try await asyncFunction()
        XCTAssertNotNil(result)
    }
}
```

### Running Tests

```bash
# All tests
./scripts/test.sh

# Specific test suite
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -only-testing:RetailSpaceOptimizerTests/StoreModelTests

# With coverage
xcodebuild test \
  -scheme RetailSpaceOptimizer \
  -enableCodeCoverage YES
```

## Documentation

### Code Documentation

Use Swift documentation comments for public APIs:

```swift
/// Calculates the total area of a store.
///
/// The area is calculated by multiplying the store's width and length.
/// This does not account for unusable space like walls or pillars.
///
/// - Parameters:
///   - width: The width of the store in meters
///   - length: The length of the store in meters
/// - Returns: The total area in square meters
/// - Throws: `ValidationError` if dimensions are invalid
func calculateArea(width: Float, length: Float) throws -> Float {
    guard width > 0, length > 0 else {
        throw ValidationError.invalidDimensions
    }
    return width * length
}
```

### Documentation Files

When adding new features, update:
- **README.md** - User-facing features
- **TECHNICAL_README.md** - Technical implementation details
- **ARCHITECTURE.md** - Architectural changes
- **CHANGELOG.md** - Version changes
- **API_DOCUMENTATION.md** - API endpoints

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Pull Requests**: Code review and collaboration

### Getting Help

1. **Check documentation** first (README, TECHNICAL_README)
2. **Search existing issues** for similar problems
3. **Ask in GitHub Discussions** for general questions
4. **Create an issue** for bugs or specific problems

### Recognition

Contributors will be recognized in:
- CHANGELOG.md for each release
- README.md contributors section
- GitHub contributors page

## License

By contributing to Retail Space Optimizer, you agree that your contributions will be licensed under the same license as the project. See [LICENSE](LICENSE) file for details.

## Questions?

If you have questions about contributing, please:
- Open a GitHub Discussion
- Create an issue with the `question` label
- Review existing documentation

Thank you for contributing to Retail Space Optimizer! 🎉

---

**Last Updated**: 2025-11-19
