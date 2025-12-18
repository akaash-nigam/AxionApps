# Contributing to Personal Finance Navigator

First off, thank you for considering contributing to Personal Finance Navigator! It's people like you that make this project a great tool for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to support@pfnavigator.app.

### Our Standards

- **Be respectful** and inclusive
- **Be collaborative** and constructive
- **Focus on what is best** for the community
- **Show empathy** towards other community members

## Getting Started

### Prerequisites

- macOS 14.0 or later
- Xcode 16.0 or later
- Apple Vision Pro simulator or device
- Git
- Basic knowledge of Swift and SwiftUI

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_Personal-Finance-Navigator.git
   cd visionOS_Personal-Finance-Navigator
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Personal-Finance-Navigator.git
   ```

4. **Open in Xcode**:
   ```bash
   open PersonalFinanceNavigator.xcodeproj
   ```

5. **Build the project** (⌘B) to ensure everything compiles

6. **Run tests** (⌘U) to verify the test suite passes

### Finding Something to Work On

- Check the [Issues](https://github.com/yourusername/visionOS_Personal-Finance-Navigator/issues) page
- Look for issues labeled `good first issue` or `help wanted`
- Read the project roadmap in README.md
- Check open Pull Requests to avoid duplicate work

## Development Process

### Branching Strategy

- `main` - Stable production code
- `develop` - Integration branch for features
- `feature/*` - New features (branch from `develop`)
- `bugfix/*` - Bug fixes (branch from `main` or `develop`)
- `hotfix/*` - Urgent fixes (branch from `main`)

### Workflow

1. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/amazing-feature develop
   ```

2. **Make your changes** following coding standards

3. **Write/update tests** for your changes

4. **Commit your changes**:
   ```bash
   git commit -m "Add amazing feature

   - Detailed description of what changed
   - Why the change was necessary
   - Any breaking changes or migrations needed"
   ```

5. **Keep your branch up to date**:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request** on GitHub

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and [Google Swift Style Guide](https://google.github.io/swift/).

#### Key Points

- **Naming**:
  - Use clear, descriptive names
  - Types and protocols: `UpperCamelCase`
  - Everything else: `lowerCamelCase`
  - Prefer methods and properties over free functions

- **Formatting**:
  - Indent with 4 spaces (no tabs)
  - Line length: 120 characters maximum
  - Opening braces on same line
  - Closing braces on new line

- **Structure**:
  - Group code with `// MARK: -` comments
  - Order: properties → init → lifecycle → public → private
  - Use extensions to organize protocol conformance

#### Example

```swift
// AccountViewModel.swift
// Personal Finance Navigator
// ViewModel for account management

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.pfn", category: "viewmodel")

/// ViewModel for managing accounts
@MainActor
@Observable
class AccountViewModel {
    // MARK: - Published State

    private(set) var accounts: [Account] = []
    private(set) var isLoading = false

    // MARK: - Dependencies

    private let repository: AccountRepository

    // MARK: - Init

    init(repository: AccountRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func loadAccounts() async {
        // Implementation
    }

    // MARK: - Private Methods

    private func handleError(_ error: Error) {
        // Implementation
    }
}
```

### Architecture Patterns

- **MVVM** for presentation layer
- **Repository Pattern** for data access
- **Dependency Injection** via DependencyContainer
- **Protocol-oriented** design
- **Actor** for thread-safe services
- **async/await** for concurrency (no completion handlers)

### SwiftUI Best Practices

- Keep views small and focused
- Extract reusable components
- Use `@Observable` for view models (not `@Published`)
- Prefer composition over inheritance
- Use environment objects sparingly
- Extract business logic to view models

### Core Data Guidelines

- All Core Data operations through repositories
- Use background contexts for heavy operations
- Always handle errors gracefully
- Implement proper fetch request optimization
- Use lightweight migration when possible

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass locally
- [ ] New tests added for new functionality
- [ ] Documentation updated (if needed)
- [ ] No compiler warnings
- [ ] Code is properly commented
- [ ] Commit messages are clear

### PR Template

```markdown
## Description
[Clear description of what this PR does]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
[How has this been tested?]

## Screenshots (if applicable)
[Add screenshots or videos]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

1. **Automated checks** must pass:
   - Build succeeds
   - Tests pass
   - Code style compliance

2. **Code review** by maintainers:
   - At least one approval required
   - Address all review comments
   - Keep discussions constructive

3. **Merge**:
   - Squash and merge for features
   - Rebase for bug fixes
   - Delete branch after merge

## Testing Guidelines

### Test Coverage Requirements

- **New features**: 80%+ coverage
- **Bug fixes**: Test reproducing the bug
- **View Models**: 90%+ coverage
- **Repositories**: 85%+ coverage
- **Domain Models**: 100% coverage

### Writing Tests

```swift
@testable import PersonalFinanceNavigator
import XCTest

@MainActor
final class AccountViewModelTests: XCTestCase {
    var sut: AccountViewModel!
    var mockRepository: MockAccountRepository!

    override func setUp() async throws {
        mockRepository = MockAccountRepository()
        sut = AccountViewModel(repository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
    }

    func testLoadAccounts_Success() async throws {
        // Given
        let expectedAccounts = [/* test data */]
        mockRepository.accountsToReturn = expectedAccounts

        // When
        await sut.loadAccounts()

        // Then
        XCTAssertEqual(sut.accounts.count, expectedAccounts.count)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
}
```

### Running Tests

```bash
# All tests
swift test

# Specific test
swift test --filter AccountViewModelTests

# With coverage
swift test --enable-code-coverage
```

## Documentation

### Code Documentation

- Public APIs must have documentation comments
- Use triple-slash (`///`) for documentation
- Include parameter descriptions
- Include return value descriptions
- Add code examples for complex functionality

```swift
/// Loads all accounts from the repository
///
/// This method fetches accounts asynchronously and updates the published state.
/// Loading indicator is shown during the operation.
///
/// - Throws: Repository errors are caught and converted to user-friendly messages
/// - Note: Filters out inactive and hidden accounts automatically
///
/// Example:
/// ```swift
/// await viewModel.loadAccounts()
/// ```
func loadAccounts() async {
    // Implementation
}
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(dashboard): add net worth trend indicator

Implemented trend calculation based on 30-day rolling average.
Displays up/down/neutral arrows with color coding.

Closes #123
```

## Community

### Getting Help

- **GitHub Discussions**: General questions and discussions
- **GitHub Issues**: Bug reports and feature requests
- **Email**: support@pfnavigator.app for private inquiries

### Communication Guidelines

- Search existing issues/discussions before creating new ones
- Provide detailed information and steps to reproduce
- Be patient and respectful
- Help others when you can

### Recognition

Contributors are recognized in:
- Project README.md
- Release notes
- Contributors page (coming soon)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Personal Finance Navigator! 🎉
