# Contributing to Innovation Laboratory

Thank you for your interest in contributing to Innovation Laboratory! This document provides guidelines and instructions for contributing to the project.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Process](#development-process)
4. [Coding Standards](#coding-standards)
5. [Testing Requirements](#testing-requirements)
6. [Pull Request Process](#pull-request-process)
7. [Issue Guidelines](#issue-guidelines)
8. [Documentation](#documentation)
9. [Community](#community)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

**In Summary:**
- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards others

---

## Getting Started

### Prerequisites

- macOS 15.0+ (Sequoia or later)
- Xcode 16.0+ with visionOS 2.0 SDK
- Git
- Apple Developer account
- Familiarity with Swift, SwiftUI, and RealityKit

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_innovation-laboratory.git
   cd visionOS_innovation-laboratory
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_innovation-laboratory.git
   ```

4. **Open in Xcode**:
   ```bash
   cd InnovationLaboratory
   open InnovationLaboratory.xcodeproj
   ```

### Build and Run

1. Select "Apple Vision Pro" simulator as destination
2. Press ⌘B to build
3. Press ⌘R to run
4. Verify app launches successfully

---

## Development Process

### Branch Naming

Use descriptive branch names following this pattern:

- **Features**: `feature/description-of-feature`
- **Bug Fixes**: `fix/description-of-bug`
- **Documentation**: `docs/description-of-changes`
- **Tests**: `test/description-of-tests`
- **Refactoring**: `refactor/description-of-change`

**Examples:**
```bash
git checkout -b feature/add-idea-search
git checkout -b fix/prototype-crash
git checkout -b docs/update-readme
git checkout -b test/analytics-service
```

### Making Changes

1. **Sync with upstream**:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**:
   - Write clean, readable code
   - Follow coding standards (see below)
   - Add tests for new functionality
   - Update documentation as needed

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add feature: description"
   ```

### Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(ideas): add search functionality

Implement full-text search across idea titles and descriptions.
Includes fuzzy matching and category filtering.

Closes #123

---

fix(prototype): resolve crash when loading large models

Added size validation and memory management improvements.
Models over 100MB now show warning dialog.

Fixes #456

---

docs(readme): update installation instructions

Add visionOS 2.0 requirement and troubleshooting section.
```

### Keeping Your Branch Updated

```bash
# Fetch latest changes
git fetch upstream

# Rebase your branch
git rebase upstream/main

# If conflicts, resolve them and continue
git rebase --continue

# Force push to your fork
git push --force-with-lease origin feature/your-feature-name
```

---

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and [Google Swift Style Guide](https://google.github.io/swift/).

#### Key Principles

**1. Naming**

```swift
// ✅ Good
func fetchIdeas(matching filter: IdeaFilter) async throws -> [InnovationIdea]
var activeIdeas: [InnovationIdea]
let maximumPrototypeSize: Int = 100_000_000

// ❌ Bad
func getIdeas(_ f: IdeaFilter) async throws -> [InnovationIdea]
var ideas2: [InnovationIdea]
let MAX_SIZE = 100000000
```

**2. Type Inference**

```swift
// ✅ Good - Clear type when needed
let idea = InnovationIdea(title: "New Idea", description: "...", category: .technology)
let ideas: [InnovationIdea] = []

// ❌ Bad - Unnecessary type annotation
let idea: InnovationIdea = InnovationIdea(title: "New Idea", description: "...", category: .technology)
```

**3. Optional Handling**

```swift
// ✅ Good - Guard for early return
guard let prototype = idea.prototypes.first else {
    return
}

// ✅ Good - Optional chaining
let count = idea.prototypes?.count ?? 0

// ❌ Bad - Force unwrapping
let prototype = idea.prototypes.first!
```

**4. Access Control**

```swift
// ✅ Good - Explicit access levels
public class InnovationService {
    private let modelContext: ModelContext
    internal var cache: [UUID: InnovationIdea] = [:]

    public func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea {
        // ...
    }
}
```

**5. Error Handling**

```swift
// ✅ Good - Specific errors
enum IdeaError: Error {
    case notFound(UUID)
    case invalidData(String)
    case saveFailed(Error)
}

func fetchIdea(id: UUID) throws -> InnovationIdea {
    guard let idea = ideas[id] else {
        throw IdeaError.notFound(id)
    }
    return idea
}

// ❌ Bad - Generic errors
func fetchIdea(id: UUID) throws -> InnovationIdea {
    if ideas[id] == nil {
        throw NSError(domain: "error", code: 1)
    }
    return ideas[id]!
}
```

### SwiftUI Best Practices

```swift
// ✅ Good - Extract subviews
struct IdeaListView: View {
    var ideas: [InnovationIdea]

    var body: some View {
        List(ideas) { idea in
            IdeaRow(idea: idea)
        }
    }
}

struct IdeaRow: View {
    let idea: InnovationIdea

    var body: some View {
        HStack {
            categoryIcon
            ideaDetails
            Spacer()
            statusBadge
        }
    }

    private var categoryIcon: some View {
        Image(systemName: idea.category.icon)
            .foregroundStyle(idea.category.color)
    }

    private var ideaDetails: some View {
        VStack(alignment: .leading) {
            Text(idea.title)
                .font(.headline)
            Text(idea.ideaDescription)
                .font(.caption)
                .lineLimit(2)
        }
    }

    private var statusBadge: some View {
        Text(idea.status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(idea.status.color.opacity(0.2))
            .cornerRadius(4)
    }
}
```

### Code Organization

```swift
// ✅ Good - Organized with MARK comments
class InnovationService {

    // MARK: - Properties

    private let modelContext: ModelContext
    private var cache: [UUID: InnovationIdea] = [:]

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    public func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea {
        // ...
    }

    public func fetchIdeas(filter: IdeaFilter?) async throws -> [InnovationIdea] {
        // ...
    }

    // MARK: - Private Methods

    private func buildPredicate(from filter: IdeaFilter) -> Predicate<InnovationIdea> {
        // ...
    }

    private func updateCache(with idea: InnovationIdea) {
        // ...
    }
}
```

### SwiftLint

We use SwiftLint to enforce style guidelines:

```bash
# Install
brew install swiftlint

# Run
swiftlint

# Auto-fix
swiftlint --fix
```

**Configuration** (`.swiftlint.yml`):
```yaml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - explicit_init
line_length: 120
```

---

## Testing Requirements

### Test Coverage

All new code must include tests:

- **Unit Tests**: Required for all services and business logic
- **UI Tests**: Required for new user-facing features
- **Integration Tests**: Required for multi-component features
- **Performance Tests**: Required for performance-critical code

**Minimum Coverage:** 80% overall, 90% for services

### Writing Tests

**Unit Test Example:**

```swift
import XCTest
@testable import InnovationLaboratory

final class InnovationServiceTests: XCTestCase {
    var service: InnovationService!
    var modelContext: ModelContext!

    override func setUp() async throws {
        modelContext = createInMemoryContext()
        service = InnovationService(modelContext: modelContext)
    }

    override func tearDown() async throws {
        service = nil
        modelContext = nil
    }

    func testCreateIdea() async throws {
        // Given
        let idea = InnovationIdea(
            title: "Test Idea",
            description: "Test Description",
            category: .technology
        )

        // When
        let created = try await service.createIdea(idea)

        // Then
        XCTAssertNotNil(created.id)
        XCTAssertEqual(created.status, .concept)
        XCTAssertNotNil(created.analytics)
    }
}
```

### Running Tests

```bash
# All tests
xcodebuild test -scheme InnovationLaboratory

# Specific test suite
xcodebuild test \
  -scheme InnovationLaboratory \
  -only-testing:InnovationLaboratoryTests/InnovationServiceTests

# With coverage
xcodebuild test \
  -scheme InnovationLaboratory \
  -enableCodeCoverage YES
```

### Test Requirements Checklist

Before submitting a PR:

- [ ] All new code has tests
- [ ] All tests pass
- [ ] Code coverage doesn't decrease
- [ ] No test warnings
- [ ] Tests are well-documented

---

## Pull Request Process

### Before Submitting

1. **Self-review your code**
   - Check for typos and formatting
   - Remove debug code and console logs
   - Ensure no commented-out code
   - Verify all tests pass

2. **Update documentation**
   - Update README if needed
   - Add/update code comments
   - Update CHANGELOG.md

3. **Run checks**
   ```bash
   # Lint
   swiftlint

   # Format
   swift-format -i -r InnovationLaboratory/

   # Test
   xcodebuild test -scheme InnovationLaboratory

   # Build
   xcodebuild build -scheme InnovationLaboratory
   ```

### Submitting Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**:
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill out the PR template

3. **PR Title Format**:
   ```
   [Type] Brief description
   ```

   Examples:
   - `[Feature] Add idea search functionality`
   - `[Fix] Resolve prototype studio crash`
   - `[Docs] Update contributing guidelines`

4. **PR Description Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] UI tests added/updated
   - [ ] Manual testing completed

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex code
   - [ ] Documentation updated
   - [ ] No new warnings
   - [ ] Tests pass locally

   ## Screenshots (if applicable)
   Add screenshots or videos

   ## Related Issues
   Closes #123
   ```

### Review Process

1. **Automated Checks**:
   - SwiftLint passes
   - Tests pass
   - Builds successfully

2. **Code Review**:
   - At least one maintainer approval required
   - Address all review comments
   - Keep discussion respectful and constructive

3. **Changes Requested**:
   - Make requested changes
   - Push updates to same branch
   - Re-request review

4. **Approval**:
   - PR approved by maintainer(s)
   - All checks passing
   - Branch up to date with main

5. **Merge**:
   - Maintainer will merge PR
   - Delete feature branch after merge

### PR Review Checklist

Reviewers will check for:

- [ ] Code quality and style
- [ ] Test coverage
- [ ] Performance implications
- [ ] Security concerns
- [ ] Breaking changes
- [ ] Documentation updates
- [ ] Accessibility considerations

---

## Issue Guidelines

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check documentation** for answers
3. **Try latest version** to see if bug is fixed

### Creating an Issue

Use appropriate issue template:

- **Bug Report** - For reporting bugs
- **Feature Request** - For suggesting new features
- **Documentation** - For documentation improvements
- **Question** - For asking questions

### Bug Report Template

```markdown
**Describe the bug**
A clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Tap on '....'
3. See error

**Expected behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment**
- visionOS version: [e.g. 2.0]
- App version: [e.g. 1.0.0]
- Device: [Simulator / Vision Pro]

**Additional context**
Any other relevant information
```

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
Clear description of the problem

**Describe the solution you'd like**
What you want to happen

**Describe alternatives you've considered**
Other solutions you've thought about

**Additional context**
Mockups, examples, or other context
```

---

## Documentation

### Code Comments

```swift
/// Creates a new innovation idea and associated analytics.
///
/// - Parameter idea: The idea to create
/// - Returns: The created idea with generated ID and analytics
/// - Throws: `IdeaError.saveFailed` if persistence fails
///
/// Example:
/// ```swift
/// let idea = InnovationIdea(
///     title: "AI Assistant",
///     description: "Smart assistant for tasks",
///     category: .technology
/// )
/// let created = try await service.createIdea(idea)
/// print(created.id) // UUID
/// ```
public func createIdea(_ idea: InnovationIdea) async throws -> InnovationIdea {
    // Implementation
}
```

### Documentation Files

When updating functionality, also update:

- **README.md** - Overview and quick start
- **USER_GUIDE.md** - User-facing documentation
- **DEVELOPER_GUIDE.md** - Technical documentation
- **ARCHITECTURE.md** - System architecture
- **CHANGELOG.md** - Version history

### CHANGELOG Format

```markdown
# Changelog

## [Unreleased]

### Added
- New feature X
- New feature Y

### Changed
- Updated behavior of Z

### Fixed
- Bug fix for issue #123

## [1.0.0] - 2025-11-19

### Added
- Initial release
```

---

## Community

### Getting Help

- **Documentation**: Check USER_GUIDE.md and DEVELOPER_GUIDE.md
- **Issues**: Search existing issues or create new one
- **Discussions**: Use GitHub Discussions for questions
- **Discord**: Join our Discord server (link in README)

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general discussion
- **Discord**: Real-time chat and community
- **Email**: contact@innovationlab.com

### Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- Special thanks in documentation

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

## Questions?

If you have questions about contributing, please:
1. Check this guide
2. Search existing issues
3. Create a new issue with "Question" label
4. Ask in Discord

---

**Thank you for contributing to Innovation Laboratory!** 🚀

Your contributions help make spatial computing innovation accessible to teams worldwide.
