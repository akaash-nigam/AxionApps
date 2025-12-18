# Contributing to Spatial Pictionary

First off, thank you for considering contributing to Spatial Pictionary! It's people like you that make this project such a great tool for the visionOS community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Code Contributions](#code-contributions)
  - [Documentation](#documentation)
  - [Translations](#translations)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [issue tracker](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/issues) as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Bug Report Template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Tap on '....'
3. Perform gesture '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots/Videos**
If applicable, add screenshots or screen recordings to help explain your problem.

**Environment:**
- Device: [e.g., Vision Pro]
- visionOS Version: [e.g., 2.0]
- App Version: [e.g., 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Features

Feature suggestions are tracked as [GitHub issues](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/issues). Before creating a feature request:

1. Check if the feature has already been suggested
2. Review the [roadmap](IMPLEMENTATION_PLAN.md) to see if it's already planned
3. Consider whether your feature fits the project's scope

**Feature Request Template:**

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear description of any alternative solutions or features you've considered.

**Additional context**
Add any other context, mockups, or screenshots about the feature request here.

**Platform considerations**
- Does this work with hand tracking?
- Performance impact?
- Accessibility considerations?
```

### Code Contributions

We love code contributions! Here's how to get started:

1. **Find an issue to work on** - Check the [good first issue](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/labels/good%20first%20issue) label
2. **Comment on the issue** - Let others know you're working on it
3. **Fork the repository**
4. **Create a branch** - `git checkout -b feature/your-feature-name`
5. **Make your changes** - Follow our coding standards
6. **Test thoroughly** - Add tests and ensure existing tests pass
7. **Submit a pull request**

### Documentation

Documentation improvements are always welcome! This includes:

- Fixing typos or clarifying existing documentation
- Adding examples or tutorials
- Improving API documentation
- Translating documentation to other languages
- Creating video tutorials or guides

### Translations

We want Spatial Pictionary to be accessible worldwide. To contribute translations:

1. Check existing translations in `SpatialPictionary/Resources/Localizations/`
2. Create a new localization file for your language
3. Translate all strings while maintaining context
4. Test the translation in the app
5. Submit a pull request

---

## Development Setup

### Prerequisites

- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 16.0 or later
- **Apple Vision Pro**: For device testing (simulator available)
- **Swift**: 6.0 knowledge recommended

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary.git
   cd visionOS_Gaming_spatial-pictionary
   ```

2. **Open in Xcode:**
   ```bash
   open SpatialPictionary.xcodeproj
   ```

3. **Configure signing:**
   - Select your development team in Xcode project settings
   - Update bundle identifier if needed

4. **Build the project:**
   - Select Vision Pro simulator or device
   - Press `Cmd+B` to build

5. **Run tests:**
   ```bash
   # Run all tests
   Cmd+U in Xcode

   # Or via command line
   xcodebuild test -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
   ```

### Project Structure

See [SOURCE_CODE_README.md](SOURCE_CODE_README.md) for detailed architecture documentation.

---

## Pull Request Process

### Before Submitting

1. **Ensure your code follows** our [coding standards](#coding-standards)
2. **Add tests** for new functionality
3. **Update documentation** if you've changed APIs or added features
4. **Run all tests** and ensure they pass
5. **Update CHANGELOG.md** with your changes
6. **Rebase on latest main** to avoid merge conflicts

### PR Template

When you create a PR, please use this template:

```markdown
## Description
Brief description of what this PR does.

## Related Issue
Fixes #(issue number)

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
Describe the tests you ran to verify your changes:
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Tested on Vision Pro simulator
- [ ] Tested on Vision Pro device (if available)

## Screenshots/Videos
If applicable, add screenshots or videos demonstrating the changes.

## Checklist
- [ ] My code follows the project's coding standards
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have updated the documentation accordingly
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have updated CHANGELOG.md
```

### Review Process

1. **Automated checks** will run on your PR
2. **Maintainers will review** your code
3. **Address feedback** if requested
4. **Once approved**, maintainers will merge your PR

---

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Use descriptive names for variables, functions, and types
- Prefer clarity over brevity
- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Use meaningful parameter labels

**Good:**
```swift
func draw(stroke: Stroke3D, at position: SIMD3<Float>, with color: Color) {
    // Implementation
}
```

**Bad:**
```swift
func drw(s: Stroke3D, p: SIMD3<Float>, c: Color) {
    // Implementation
}
```

### Architecture Patterns

- **State Management**: Use `@Observable` for reactive state
- **Data Flow**: Follow unidirectional data flow pattern
- **Concurrency**: Use Swift 6 strict concurrency (`async`/`await`)
- **Dependency Injection**: Pass dependencies explicitly, avoid singletons

### Code Organization

```swift
// MARK: - Type Definition
struct MyType {
    // MARK: - Properties
    var property: String

    // MARK: - Initialization
    init(property: String) {
        self.property = property
    }

    // MARK: - Public Methods
    func publicMethod() {
        // Implementation
    }

    // MARK: - Private Methods
    private func privateMethod() {
        // Implementation
    }
}

// MARK: - Protocol Conformance
extension MyType: Equatable {
    // Implementation
}
```

### Documentation

Use Swift DocC format for public APIs:

```swift
/// Draws a 3D stroke in spatial coordinates.
///
/// This method creates a new stroke entity in 3D space using the provided
/// points and material properties.
///
/// - Parameters:
///   - points: Array of 3D coordinates defining the stroke path
///   - color: The color to apply to the stroke
///   - thickness: The thickness of the stroke in meters
///   - material: The material type for rendering
///
/// - Returns: The created `Stroke3D` instance
///
/// - Throws: `DrawingError.invalidPoints` if the points array is empty
///
/// - Note: Ensure points are in world coordinate space
///
/// Example:
/// ```swift
/// let stroke = try drawStroke(
///     points: [SIMD3(0, 0, 0), SIMD3(1, 1, 1)],
///     color: .blue,
///     thickness: 0.01,
///     material: .solid
/// )
/// ```
func drawStroke(
    points: [SIMD3<Float>],
    color: Color,
    thickness: Float,
    material: MaterialType
) throws -> Stroke3D {
    // Implementation
}
```

---

## Testing Guidelines

### Test Coverage

- Aim for **>80% code coverage**
- All public APIs must have tests
- Critical paths require comprehensive testing

### Test Types

1. **Unit Tests** - Test individual components in isolation
2. **Integration Tests** - Test component interactions
3. **Performance Tests** - Ensure 90 FPS target
4. **UI Tests** - Test user interaction flows
5. **Accessibility Tests** - Test VoiceOver, reduced motion, etc.

### Writing Tests

```swift
import XCTest
@testable import SpatialPictionary

final class GameStateTests: XCTestCase {
    var gameState: GameState!

    override func setUp() {
        super.setUp()
        gameState = GameState()
    }

    override func tearDown() {
        gameState = nil
        super.tearDown()
    }

    func testInitialPhaseIsLobby() {
        // Given: A new game state

        // When: No actions taken

        // Then: Phase should be lobby
        XCTAssertEqual(gameState.currentPhase, .lobby)
    }

    func testAddPlayerIncreasesPlayerCount() {
        // Given: An empty game
        XCTAssertEqual(gameState.players.count, 0)

        // When: Adding a player
        let player = Player(name: "Test", avatar: .default, isLocal: true, deviceID: "test")
        gameState.addPlayer(player)

        // Then: Player count increases
        XCTAssertEqual(gameState.players.count, 1)
    }
}
```

### Performance Testing

```swift
func testDrawingPerformance() {
    measure {
        // Code to measure performance
        for _ in 0..<1000 {
            _ = drawingEngine.addPoint(SIMD3<Float>(0, 0, 0))
        }
    }
}
```

---

## Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Build process or tooling changes
- **ci**: CI/CD changes

### Examples

```bash
feat(drawing): add neon material type for strokes

Implemented new neon material with glow effect using custom shaders.
Includes UI controls in material picker and performance optimizations.

Closes #123
```

```bash
fix(multiplayer): resolve sync issue with late-joining players

Players joining mid-game now receive complete game state including
all previous drawings and current artist information.

Fixes #456
```

```bash
docs(readme): update installation instructions for Xcode 16

Updated setup guide to reflect new Xcode 16 requirements and
improved troubleshooting section.
```

### Best Practices

- Use the imperative mood ("add feature" not "added feature")
- Capitalize the subject line
- No period at the end of subject line
- Limit subject line to 50 characters
- Wrap body at 72 characters
- Reference issues and PRs in footer

---

## Community

### Getting Help

- **Questions**: Use [GitHub Discussions](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/discussions)
- **Bugs**: File an [issue](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/issues)
- **Documentation**: Check the [docs](README.md#documentation)

### Recognition

Contributors will be:
- Listed in CHANGELOG.md for their contributions
- Mentioned in release notes
- Added to our contributors page

---

## License

By contributing to Spatial Pictionary, you agree that your contributions will be licensed under the MIT License.

---

## Questions?

Don't hesitate to ask! Create a discussion post or reach out to the maintainers.

Thank you for contributing to Spatial Pictionary! 🎨✨
