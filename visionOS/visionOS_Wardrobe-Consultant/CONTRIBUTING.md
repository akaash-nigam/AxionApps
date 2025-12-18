# Contributing to Wardrobe Consultant

First off, thank you for considering contributing to Wardrobe Consultant! It's people like you that make this app a great tool for fashion enthusiasts everywhere.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- **Be respectful** - Treat everyone with respect and consideration
- **Be collaborative** - Work together and help each other
- **Be professional** - Keep discussions focused and constructive
- **Be inclusive** - Welcome people of all backgrounds and identities

## Getting Started

### Prerequisites

Before you begin, ensure you have:

- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Git installed
- Familiarity with Swift, SwiftUI, and Clean Architecture

### First Steps

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/visionOS_Wardrobe-Consultant.git
   cd visionOS_Wardrobe-Consultant
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL-OWNER/visionOS_Wardrobe-Consultant.git
   ```
4. **Create a branch** for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** - Descriptive summary of the issue
- **Steps to reproduce** - Detailed steps to reproduce the behavior
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Screenshots** - If applicable
- **Environment** - OS version, device, app version
- **Logs** - Any relevant error messages or logs

**Bug Report Template:**
```markdown
## Bug Description
[Clear description of the bug]

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- Device: [e.g., iPhone 15 Pro, Vision Pro]
- OS: [e.g., iOS 17.0]
- App Version: [e.g., 1.0.0]

## Additional Context
[Any other relevant information]
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title** - Descriptive summary of the enhancement
- **Use case** - Why this enhancement would be useful
- **Proposed solution** - How you envision it working
- **Alternatives** - Any alternative solutions you've considered
- **Mockups** - Visual representations if applicable

### Code Contributions

We welcome code contributions! Here are areas where you can help:

1. **Bug Fixes** - Fix existing bugs from the issue tracker
2. **New Features** - Implement features from the roadmap
3. **Performance** - Improve app performance
4. **Tests** - Add missing test coverage
5. **Documentation** - Improve code or user documentation
6. **Refactoring** - Improve code quality and maintainability

## Development Setup

### 1. Install Dependencies

```bash
# Install SwiftLint
brew install swiftlint

# Install xcov (optional, for coverage reports)
gem install xcov
```

### 2. Open Project

```bash
# Open in Xcode
open WardrobeConsultant.xcodeproj
```

### 3. Build and Run

1. Select a simulator or device
2. Press `Cmd+R` to build and run
3. Press `Cmd+U` to run tests

### 4. Project Structure

```
WardrobeConsultant/
├── Domain/              # Business logic and entities
│   ├── Entities/        # Core data models
│   ├── Protocols/       # Repository interfaces
│   └── Services/        # Business logic services
├── Infrastructure/      # External dependencies
│   ├── Persistence/     # Data storage (Core Data)
│   └── Services/        # External services (Weather, Calendar)
├── Presentation/        # UI layer
│   ├── Screens/         # SwiftUI views by feature
│   ├── ViewModels/      # View models
│   └── Utilities/       # UI utilities
├── Tests/               # Test suites
│   ├── UnitTests/       # Unit tests
│   ├── IntegrationTests/# Integration tests
│   ├── UITests/         # UI tests
│   └── TestDataFactory.swift
└── docs/                # Documentation
```

### Architecture

We follow **Clean Architecture** principles:

- **Domain Layer** - Pure business logic, no dependencies
- **Infrastructure Layer** - External dependencies (database, APIs)
- **Presentation Layer** - UI and view models

**Key Patterns:**
- MVVM for presentation layer
- Repository pattern for data access
- Protocol-oriented design for testability
- Async/await for concurrency

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with some additions:

#### Naming Conventions

```swift
// Types: UpperCamelCase
class WardrobeRepository { }
struct WardrobeItem { }
enum ClothingCategory { }

// Functions and variables: lowerCamelCase
func fetchItems() { }
let primaryColor: String

// Constants: lowerCamelCase
let maximumItemCount = 1000

// Protocols: Descriptive names, often ending in -able or -ing
protocol WardrobeRepositoryProtocol { }
protocol Searchable { }
```

#### Code Organization

```swift
// MARK: - Type Definition
class MyViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: MyViewModel

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Public Methods
    func configure() { }

    // MARK: - Private Methods
    private func setupUI() { }

    // MARK: - Actions
    @objc private func buttonTapped() { }
}

// MARK: - Extensions
extension MyViewController: SomeProtocol {
    func protocolMethod() { }
}
```

#### SwiftLint

We use SwiftLint to enforce code style. Run before committing:

```bash
swiftlint lint
```

Fix auto-correctable issues:

```bash
swiftlint --fix
```

### Best Practices

#### 1. Use Async/Await

```swift
// ✅ Good
func fetchItems() async throws -> [WardrobeItem] {
    return try await repository.fetchAll()
}

// ❌ Avoid completion handlers
func fetchItems(completion: @escaping (Result<[WardrobeItem], Error>) -> Void) { }
```

#### 2. Use @MainActor for ViewModels

```swift
// ✅ Good
@MainActor
class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = []
}
```

#### 3. Avoid Force Unwrapping

```swift
// ✅ Good
if let item = items.first {
    process(item)
}

// ❌ Avoid
let item = items.first!
```

#### 4. Use Guard for Early Returns

```swift
// ✅ Good
guard let item = items.first else {
    return
}
process(item)

// ❌ Avoid deep nesting
if let item = items.first {
    process(item)
}
```

#### 5. Document Public APIs

```swift
/// Fetches all wardrobe items from the repository.
///
/// - Returns: An array of `WardrobeItem` objects
/// - Throws: `RepositoryError` if fetch fails
func fetchAll() async throws -> [WardrobeItem]
```

## Pull Request Process

### Before Submitting

1. **Update your fork** with latest upstream changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests** and ensure they pass:
   ```bash
   ./scripts/run_tests.sh quick
   ```

3. **Run SwiftLint** and fix issues:
   ```bash
   swiftlint lint --strict
   ```

4. **Update documentation** if needed

5. **Add tests** for new functionality

### Commit Messages

Write clear, concise commit messages following [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style (formatting, missing semi-colons, etc.)
- `refactor:` - Code refactoring
- `perf:` - Performance improvement
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```bash
feat(wardrobe): Add color filter to wardrobe view

Added a new color filter dropdown that allows users to filter
items by primary color. Includes 10 predefined color options.

Closes #123
```

```bash
fix(ai): Correct outfit confidence score calculation

The confidence score was incorrectly weighting weather factors
at 40% instead of 20%. Updated to match specification.

Fixes #456
```

### Creating a Pull Request

1. **Push your branch** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR** on GitHub with:
   - Clear title describing the change
   - Reference to related issue(s)
   - Description of changes made
   - Screenshots/videos if UI changes
   - Checklist of completed items

3. **PR Template:**
   ```markdown
   ## Description
   [Clear description of changes]

   ## Related Issues
   Closes #123

   ## Changes Made
   - Added color filter feature
   - Updated WardrobeView
   - Added unit tests

   ## Screenshots
   [If applicable]

   ## Checklist
   - [ ] Tests added/updated
   - [ ] Documentation updated
   - [ ] SwiftLint passes
   - [ ] All tests pass
   - [ ] No breaking changes
   ```

4. **Respond to feedback** - Address review comments promptly

5. **Squash commits** if requested before merging

## Testing Guidelines

### Test Requirements

- **Unit tests** required for all business logic
- **Integration tests** for multi-component workflows
- **UI tests** for critical user flows
- **Minimum 80% coverage** for new code

### Writing Tests

```swift
// Unit test example
@MainActor
final class WardrobeRepositoryTests: XCTestCase {
    var repository: WardrobeRepository!

    override func setUp() async throws {
        repository = WardrobeRepository(inMemory: true)
    }

    func testFetchAll_ReturnsAllItems() async throws {
        // Given
        let item = createTestItem()
        _ = try await repository.create(item)

        // When
        let items = try await repository.fetchAll()

        // Then
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.id, item.id)
    }
}
```

### Running Tests

```bash
# Quick tests (unit + integration)
./scripts/run_tests.sh quick

# All tests
./scripts/run_tests.sh all

# With coverage
./scripts/run_tests.sh unit --coverage
```

## Documentation

### Code Documentation

- Document all public APIs with DocC comments
- Explain complex algorithms
- Include usage examples
- Document error conditions

### User Documentation

- Update README.md for user-facing changes
- Update USER_GUIDE.md for new features
- Add entries to FAQ.md for common questions

### Architecture Documentation

- Update design docs for architectural changes
- Add ADRs (Architecture Decision Records) for major decisions
- Keep diagrams up-to-date

## Community

### Getting Help

- **GitHub Issues** - For bugs and feature requests
- **Discussions** - For questions and general discussion
- **Documentation** - Check docs/ folder first

### Staying Updated

- Watch the repository for notifications
- Review the CHANGELOG.md for changes
- Follow the roadmap in PROJECT_STATUS.md

### Recognition

Contributors will be:
- Listed in CHANGELOG.md for their contributions
- Recognized in release notes
- Added to contributors list

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

## Questions?

If you have questions about contributing, please:
1. Check this guide thoroughly
2. Search existing issues and discussions
3. Create a new discussion if needed

Thank you for contributing to Wardrobe Consultant! 🎉
