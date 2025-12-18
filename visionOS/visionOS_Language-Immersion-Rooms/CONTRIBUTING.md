# Contributing to Language Immersion Rooms

Thank you for your interest in contributing to Language Immersion Rooms! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

---

## Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS 2.0 SDK
- **Git** for version control
- **SwiftLint** for code quality (optional but recommended)

### Setup

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_Language-Immersion-Rooms.git
   cd visionOS_Language-Immersion-Rooms
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Language-Immersion-Rooms.git
   ```

4. **Install SwiftLint** (recommended):
   ```bash
   brew install swiftlint
   ```

5. **Open the project**:
   ```bash
   open LanguageImmersionRooms.xcodeproj
   ```

6. **Configure API keys** (for testing):
   - Product → Scheme → Edit Scheme → Run → Environment Variables
   - Add `OPENAI_API_KEY` with your OpenAI API key

7. **Build and run**:
   - Select "Apple Vision Pro (Simulator)" as destination
   - Press ⌘+R to build and run

See [SETUP.md](SETUP.md) for detailed setup instructions.

---

## Development Workflow

### Branching Strategy

We use **Git Flow** with the following branches:

- **`main`**: Production-ready code
- **`develop`**: Integration branch for features
- **`feature/*`**: New features
- **`bugfix/*`**: Bug fixes
- **`hotfix/*`**: Urgent fixes for production

### Creating a Feature Branch

```bash
# Update your local develop branch
git checkout develop
git pull upstream develop

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes
# Commit regularly with meaningful messages

# Push to your fork
git push origin feature/your-feature-name
```

### Staying in Sync

```bash
# Regularly sync with upstream
git fetch upstream
git merge upstream/develop

# Or rebase (preferred for cleaner history)
git rebase upstream/develop
```

---

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and use **SwiftLint** to enforce style.

**Key principles:**

1. **Clarity at the point of use**
2. **Prefer clarity over brevity**
3. **Use descriptive names**
4. **Follow Swift conventions**

### Code Organization

```swift
// File structure:

// 1. Import statements
import SwiftUI
import RealityKit

// 2. Type definition
struct MyView: View {
    // 3. Properties
    @State private var count = 0

    // 4. Body
    var body: some View {
        // View code
    }

    // 5. Private methods (grouped with MARK)
    // MARK: - Private Methods

    private func increment() {
        count += 1
    }
}

// 6. Extensions
extension MyView {
    // Extension code
}
```

### MARK Comments

Use `MARK` to organize code:

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - View Body
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Helper Methods
```

### Naming Conventions

- **Types**: `UpperCamelCase` (e.g., `VocabularyService`)
- **Functions**: `lowerCamelCase` (e.g., `translateWord()`)
- **Variables**: `lowerCamelCase` (e.g., `currentUser`)
- **Constants**: `lowerCamelCase` (e.g., `maxRetries`)
- **Enums**: `UpperCamelCase` for type, `lowerCamelCase` for cases

### Documentation

Use documentation comments for public APIs:

```swift
/// Translates an English word to the target language.
///
/// - Parameters:
///   - word: The English word to translate
///   - language: The target language
/// - Returns: The translated word, or nil if not found
func translate(_ word: String, to language: Language) -> String? {
    // Implementation
}
```

### Error Handling

- Use `Result` types for operations that can fail
- Throw errors for exceptional cases
- Provide meaningful error messages

```swift
enum TranslationError: Error {
    case wordNotFound(String)
    case unsupportedLanguage(Language)
}

func translate(_ word: String) throws -> String {
    guard let translation = dictionary[word] else {
        throw TranslationError.wordNotFound(word)
    }
    return translation
}
```

### Async/Await

- Prefer `async/await` over completion handlers
- Mark functions with `@MainActor` when they update UI
- Use `Task` for bridging sync/async code

```swift
@MainActor
func loadData() async {
    do {
        let data = try await service.fetchData()
        self.items = data
    } catch {
        self.errorMessage = error.localizedDescription
    }
}
```

---

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semi-colons, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Maintenance tasks
- **ci**: CI/CD changes

### Examples

```bash
feat(vocabulary): add French language support

Add 100 French vocabulary words across all categories.
Includes translations and pronunciation guides.

Closes #123

---

fix(speech): handle microphone permission denial

Gracefully handle case when user denies microphone permission.
Shows alert with instructions to enable in Settings.

Fixes #456

---

docs(readme): update installation instructions

Clarify Xcode version requirements and add troubleshooting section.

---

test(services): add unit tests for ConversationService

Covers greeting generation, error handling, and API integration.
Adds 15 new test cases with 100% coverage.
```

### Commit Best Practices

- **One logical change per commit**
- **Write clear, descriptive messages**
- **Reference related issues**
- **Keep commits atomic and focused**
- **Test before committing**

---

## Pull Request Process

### Before Submitting

1. **Update your branch**:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

2. **Run tests**:
   ```bash
   ./run_tests.sh
   ```

3. **Run SwiftLint**:
   ```bash
   swiftlint
   ```

4. **Verify build**:
   - Build for both Debug and Release configurations
   - Test on simulator

### Creating a Pull Request

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**:
   - Use a clear, descriptive title
   - Fill out the PR template completely
   - Link related issues
   - Add screenshots/videos if UI changes

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## How Has This Been Tested?
   Describe the tests you ran

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex code
   - [ ] Documentation updated
   - [ ] Tests added/updated
   - [ ] All tests pass
   - [ ] No new warnings
   ```

### Review Process

1. **Automated checks** must pass:
   - CI/CD tests
   - Code quality checks
   - Build verification

2. **Code review** by maintainers:
   - At least 1 approval required
   - Address all feedback
   - Keep discussion professional

3. **Merge**:
   - Squash and merge (default)
   - Or merge commit for feature branches
   - Delete branch after merge

---

## Testing

### Running Tests

```bash
# All unit tests
./run_tests.sh

# Specific test file
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit/Models/CoreModelsTests

# With coverage
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

### Test Guidelines

1. **Write tests for new features**
2. **Update tests when changing behavior**
3. **Aim for 80%+ code coverage**
4. **Test edge cases and error conditions**
5. **Keep tests fast and independent**

### Test Structure

```swift
final class MyServiceTests: XCTestCase {
    var service: MyService!

    override func setUp() {
        super.setUp()
        service = MyService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testSomething() {
        // Arrange
        let input = "test"

        // Act
        let result = service.doSomething(input)

        // Assert
        XCTAssertEqual(result, "expected")
    }
}
```

---

## Documentation

### Code Documentation

- **Document all public APIs**
- **Explain complex algorithms**
- **Add usage examples**
- **Keep docs in sync with code**

### Project Documentation

When adding features:
- Update `README.md` if user-facing
- Update relevant design docs in `docs/`
- Add to `CHANGELOG.md`

### Documentation Files

- **README.md**: Project overview
- **CONTRIBUTING.md**: This file
- **SETUP.md**: Development setup
- **ARCHITECTURE.md**: System architecture
- **docs/**: Design documents
- **API docs**: In-code documentation

---

## Code Review Checklist

### For Authors

Before requesting review:
- [ ] Code is self-explanatory or well-commented
- [ ] No debug code (print statements, commented code)
- [ ] Error handling is appropriate
- [ ] Performance implications considered
- [ ] Security implications considered
- [ ] Backward compatibility maintained
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CI passes

### For Reviewers

When reviewing:
- [ ] Code is clear and maintainable
- [ ] Logic is correct
- [ ] Edge cases handled
- [ ] Tests are comprehensive
- [ ] Performance is acceptable
- [ ] Security is not compromised
- [ ] Follows project conventions
- [ ] Documentation is adequate

---

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/OWNER/REPO/discussions)
- **Bugs**: Create an [Issue](https://github.com/OWNER/REPO/issues)
- **Chat**: Join our [Discord](https://discord.gg/INVITE) (if available)
- **Email**: dev@languageimmersionrooms.com

---

## Recognition

Contributors will be:
- Listed in `CONTRIBUTORS.md`
- Mentioned in release notes
- Featured on the website (with permission)

Thank you for contributing! 🎉

---

**Last Updated**: 2025-11-24
**Version**: 1.0
