# Contributing to Reality Realms RPG

Thank you for your interest in contributing to Reality Realms RPG! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Bug Reports](#bug-reports)
- [Feature Requests](#feature-requests)
- [Documentation](#documentation)

## 📜 Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## 🚀 Getting Started

### Prerequisites

- **macOS Sonoma 14.0+**
- **Xcode 16.0+** with visionOS SDK 2.0+
- **Swift 6.0+**
- **Apple Developer Account** (for device testing)
- **Apple Vision Pro** (recommended for spatial feature testing)
- **Git** for version control

### First Steps

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_reality-realms-rpg.git
   cd visionOS_Gaming_reality-realms-rpg
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Gaming_reality-realms-rpg.git
   ```

3. **Install dependencies**
   ```bash
   # Open project in Xcode
   open RealityRealms.xcodeproj

   # Xcode will automatically resolve Swift Package dependencies
   ```

4. **Verify setup**
   ```bash
   # Run tests to ensure everything works
   # In Xcode: ⌘U or Product > Test
   ```

For detailed setup instructions, see [DEVELOPER_ONBOARDING.md](DEVELOPER_ONBOARDING.md).

## 💻 Development Environment

### Required Tools

- **Xcode 16.0+**: Primary IDE for visionOS development
- **Swift 6.0+**: Programming language
- **Reality Composer Pro**: For 3D asset creation (optional)
- **SwiftLint**: Code style enforcement (recommended)

### Recommended Tools

- **Instruments**: Performance profiling
- **Git**: Version control
- **GitHub CLI**: For PR management
- **SF Symbols**: Icon resources

### Workspace Setup

```bash
# Install SwiftLint (recommended)
brew install swiftlint

# Verify installation
swiftlint version
```

## 🤝 How to Contribute

### Types of Contributions

We welcome various types of contributions:

1. **Bug Fixes**: Fix reported or discovered bugs
2. **Features**: Implement new features from the roadmap
3. **Performance**: Optimize code for better performance
4. **Tests**: Add or improve test coverage
5. **Documentation**: Improve or add documentation
6. **Accessibility**: Enhance accessibility features
7. **Localization**: Add translations for new languages

### Contribution Workflow

1. **Check existing issues**
   - Browse [open issues](https://github.com/OWNER/REPO/issues)
   - Look for issues tagged `good first issue` or `help wanted`
   - Comment on the issue to claim it

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

3. **Make your changes**
   - Follow [coding standards](#coding-standards)
   - Write tests for new functionality
   - Update documentation as needed

4. **Test thoroughly**
   ```bash
   # Run all tests
   ⌘U in Xcode

   # Run specific test suite
   # Use Test Navigator (⌘6)

   # Check code coverage
   # Product > Test with Coverage
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

   See [commit message guidelines](#commit-messages) below.

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill out the PR template
   - Submit for review

## 📝 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with some additions:

#### Naming Conventions

```swift
// Classes, Structs, Enums, Protocols: PascalCase
class GameEntity { }
struct PlayerStats { }
enum GameState { }
protocol Damageable { }

// Functions, Variables, Constants: camelCase
func calculateDamage() { }
var playerHealth: Int = 100
let maxLevel = 50

// Constants: camelCase (not SCREAMING_SNAKE_CASE)
let defaultSpeed = 1.0
let targetFrameRate = 90.0

// Enums: lowercase for cases
enum Direction {
    case north, south, east, west
}
```

#### Code Organization

```swift
// MARK: - Type declarations
class MyClass {
    // MARK: - Properties
    var publicProperty: String
    private var privateProperty: Int

    // MARK: - Initialization
    init() { }

    // MARK: - Public Methods
    func publicMethod() { }

    // MARK: - Private Methods
    private func privateMethod() { }
}
```

#### SwiftLint Configuration

We use SwiftLint to enforce code style. Configuration is in `.swiftlint.yml`.

```bash
# Run SwiftLint
swiftlint

# Auto-fix issues where possible
swiftlint --fix
```

### Swift Concurrency

All async code must use Swift 6 strict concurrency:

```swift
// ✅ Good: Proper async/await usage
func fetchData() async throws -> Data {
    let data = try await networkService.fetch()
    return data
}

// ✅ Good: Sendable types
struct GameEvent: Sendable {
    let type: EventType
    let timestamp: Date
}

// ❌ Bad: Avoid completion handlers
func fetchData(completion: @escaping (Data?) -> Void) {
    // Use async/await instead
}
```

### Performance Best Practices

```swift
// ✅ Good: Value types for data
struct PlayerStats {
    var health: Int
    var mana: Int
}

// ✅ Good: Lazy initialization
lazy var expensiveResource = createResource()

// ✅ Good: Weak references to avoid retain cycles
weak var delegate: GameDelegate?

// ❌ Bad: Force unwrapping (use guard let or if let)
let value = optional! // Avoid this

// ✅ Good: Safe unwrapping
guard let value = optional else { return }
```

### RealityKit Best Practices

```swift
// ✅ Good: Component-based architecture
struct HealthComponent: Component {
    var current: Float
    var maximum: Float
}

// ✅ Good: System-based logic
struct HealthSystem: System {
    func update(context: SceneUpdateContext) {
        // Update logic
    }
}

// ✅ Good: Efficient material usage
var material = SimpleMaterial()
material.color = .init(tint: .red)
```

## 🧪 Testing Requirements

### Test Coverage

All contributions must maintain or improve test coverage:

- **Core Systems**: ≥ 95% coverage
- **Game Logic**: ≥ 90% coverage
- **UI Components**: ≥ 75% coverage
- **Utilities**: ≥ 90% coverage

### Required Tests

Every new feature or bug fix must include:

1. **Unit Tests**: Test individual components
2. **Integration Tests**: Test system interactions (if applicable)
3. **Performance Tests**: For performance-critical code
4. **Accessibility Tests**: Update manual test documentation

### Writing Tests

```swift
import XCTest
@testable import RealityRealms

final class MyFeatureTests: XCTestCase {
    var sut: MyFeature!

    override func setUp() {
        super.setUp()
        sut = MyFeature()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFeatureBehavior() {
        // Given
        let input = "test"

        // When
        let result = sut.process(input)

        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### Running Tests

```bash
# Run all tests
⌘U in Xcode

# Run specific test file
# Right-click test file > Run Tests

# Run with coverage
# Product > Test with Coverage

# Generate coverage report
xcrun xccov view --report DerivedData/.../Coverage.xcresult
```

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows Swift style guidelines
- [ ] All tests pass (⌘U)
- [ ] New tests added for new functionality
- [ ] Code coverage maintained or improved
- [ ] SwiftLint shows no errors
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated (for notable changes)
- [ ] No merge conflicts with main branch

### PR Template

When creating a PR, please fill out the template:

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Performance improvement
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] Tested on visionOS Simulator
- [ ] Tested on Vision Pro device

## Screenshots/Videos
(If applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests pass locally
```

### Review Process

1. **Automated Checks**: CI/CD runs tests and linting
2. **Code Review**: At least one maintainer reviews
3. **Testing**: Reviewers test functionality
4. **Approval**: Maintainer approves after review
5. **Merge**: Maintainer merges (squash or merge commit)

### After Merge

- Your PR will be included in the next release
- You'll be added to the contributors list
- Close any related issues

## 🐛 Bug Reports

### Before Reporting

1. **Search existing issues**: Check if already reported
2. **Update to latest**: Verify bug exists in latest version
3. **Reproduce**: Ensure bug is reproducible

### Bug Report Template

```markdown
**Description**
Clear description of the bug

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Screenshots/Videos**
(If applicable)

**Environment**
- Device: Apple Vision Pro / Simulator
- OS Version: visionOS 2.0
- App Version: 1.0.0
- Xcode Version: 16.0

**Additional Context**
Any other relevant information
```

## ✨ Feature Requests

### Before Requesting

1. **Check roadmap**: See if already planned (IMPLEMENTATION_PLAN.md)
2. **Search issues**: Check if already requested
3. **Consider scope**: Ensure it fits the project vision

### Feature Request Template

```markdown
**Feature Description**
Clear description of the proposed feature

**Use Case**
Why is this feature needed? Who will benefit?

**Proposed Solution**
How you envision this working

**Alternatives Considered**
Other approaches you've thought about

**Additional Context**
Mockups, references, examples
```

## 📚 Documentation

### Documentation Standards

- **Clear**: Easy to understand
- **Concise**: No unnecessary words
- **Complete**: All necessary information
- **Current**: Kept up-to-date with code

### Types of Documentation

1. **Code Comments**
   ```swift
   /// Calculates damage after applying defense
   /// - Parameters:
   ///   - baseDamage: Raw damage before mitigation
   ///   - defense: Defense stat of the target
   /// - Returns: Final damage after mitigation
   func calculateDamage(baseDamage: Int, defense: Int) -> Int {
       // Implementation
   }
   ```

2. **README Files**: Project overviews in each major directory

3. **Architecture Docs**: High-level design documents

4. **API Documentation**: Generated from code comments

5. **User Guides**: End-user documentation

### Updating Documentation

When code changes affect documentation:

1. Update inline code comments
2. Update relevant .md files
3. Update API documentation
4. Update examples/tutorials
5. Note in CHANGELOG.md

## 🔒 Commit Messages

### Format

```
type(scope): Brief description

Longer explanation if needed. Wrap at 72 characters.

- Bullet points for multiple changes
- More details about the changes

Closes #123
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, no logic change)
- `refactor`: Code restructuring (no behavior change)
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(combat): Add critical hit system

Implements critical hit mechanics with configurable chance
and damage multiplier based on character stats.

- Add CriticalHit component
- Update CombatSystem to calculate crits
- Add tests for crit calculation

Closes #42

---

fix(ui): Prevent HUD flickering during combat

The health orb was flickering due to rapid updates.
Added debouncing to smooth out the animation.

Fixes #127

---

perf(entities): Optimize entity creation

Reduced entity creation time by 40% by pre-allocating
component arrays and using object pooling.

- Implement ComponentPool
- Add performance test
- Update benchmarks

Closes #89
```

## 🏷️ Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

Format: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)

## 🎯 Priority Labels

Issues and PRs use priority labels:

- `P0 - Critical`: Security, crashes, data loss
- `P1 - High`: Major features, significant bugs
- `P2 - Medium`: Minor features, small bugs
- `P3 - Low`: Nice-to-haves, polish

## 🌍 Localization

We support multiple languages. See [LOCALIZATION.md](LOCALIZATION.md) for translation guidelines.

## 📞 Getting Help

Need help contributing?

- **Documentation**: Check all .md files in the repo
- **Discussions**: GitHub Discussions for questions
- **Issues**: For bug reports and feature requests
- **Discord**: [Join our Discord](#) for real-time chat

## 🙏 Recognition

All contributors will be:

- Added to the contributors list
- Mentioned in release notes (for significant contributions)
- Credited in the app's About section

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to Reality Realms RPG!** 🎮✨

Your contributions help make this game better for everyone.
