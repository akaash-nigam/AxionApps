# Contributing to Parkour Pathways

First off, thank you for considering contributing to Parkour Pathways! It's people like you that make this project such a great tool.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Process](#development-process)
- [Style Guides](#style-guides)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## 🤝 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members
- Accept constructive criticism gracefully

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK
- **Apple Vision Pro** (for hardware testing)
- **Git** installed and configured
- **SwiftLint** (optional but recommended)

### Initial Setup

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_parkour-pathways.git
   cd visionOS_Gaming_parkour-pathways
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/original-org/visionOS_Gaming_parkour-pathways.git
   ```

4. **Install dependencies** (if applicable)
   ```bash
   # SwiftLint for code quality
   brew install swiftlint
   ```

5. **Open in Xcode**
   ```bash
   open ParkourPathways/Package.swift
   ```

6. **Build and run tests**
   ```bash
   # In Xcode: ⌘ + U
   # Or via command line:
   swift test
   ```

## 💡 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue tracker as you might find that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Use this template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots/Video**
If applicable, add screenshots or screen recordings.

**Environment:**
- Device: [e.g., Apple Vision Pro]
- visionOS Version: [e.g., 2.0]
- App Version: [e.g., 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List some examples** of how it would be used
- **Describe the current behavior** and **expected behavior**

### Pull Requests

1. **Small, focused changes** are easier to review
2. **One feature per PR** - don't mix unrelated changes
3. **Update tests** for any code changes
4. **Update documentation** if needed
5. **Follow the style guide**

## 🔧 Development Process

### Branching Strategy

We use a simplified Git Flow:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Emergency fixes for production

### Creating a Feature Branch

```bash
# Update your local main
git checkout main
git pull upstream main

# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Make your changes...

# Commit your changes
git add .
git commit -m "Add your feature"

# Push to your fork
git push origin feature/your-feature-name
```

### Keeping Your Branch Updated

```bash
# Fetch latest changes
git fetch upstream

# Rebase your branch
git rebase upstream/main

# Force push if needed (only on your branch!)
git push --force-with-lease origin feature/your-feature-name
```

## 📝 Style Guides

### Swift Code Style

We follow the [Official Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

#### Key Points:

**Naming**
```swift
// ✅ Good
func processUserInput(_ input: String) -> Result<Data, Error>
class MovementMechanicsSystem { }
var isGameActive = true

// ❌ Bad
func proc_input(_ inp: String) -> Result<Data, Error>
class movement_mechanics_sys { }
var gameActive = true
```

**Documentation**
```swift
/// Calculates the score for a precision jump.
///
/// - Parameters:
///   - landingPosition: The 3D position where the player landed
///   - targetPosition: The intended landing target
/// - Returns: A score between 0.0 and 1.0
func calculateScore(landingPosition: SIMD3<Float>, targetPosition: SIMD3<Float>) -> Float {
    // Implementation
}
```

**Concurrency**
```swift
// ✅ Use async/await
func loadCourse() async throws -> CourseData {
    let data = try await networkManager.fetchCourse()
    return data
}

// ❌ Avoid completion handlers
func loadCourse(completion: @escaping (Result<CourseData, Error>) -> Void) {
    // Old style
}
```

**Error Handling**
```swift
// ✅ Explicit error types
enum CourseGenerationError: Error {
    case insufficientSpace
    case invalidConfiguration
    case generationFailed(reason: String)
}

// Use proper error handling
do {
    let course = try generateCourse()
} catch {
    logger.error("Course generation failed: \(error)")
}
```

### SwiftLint Configuration

We use SwiftLint to enforce code style. Key rules:

- **Line length**: 120 characters
- **File length**: 400 lines (warnings at 500)
- **Function length**: 40 lines
- **Cyclomatic complexity**: 10 (warnings at 15)
- **Force unwrapping**: Discouraged (use guard/if let)
- **Trailing whitespace**: Not allowed

### Testing Style

```swift
// ✅ Good test naming
func testPrecisionJumpScoring_WhenLandingPerfect_ReturnsMaxScore() {
    // Arrange
    let mechanic = PrecisionJumpMechanic()
    let target = SIMD3<Float>(0, 0.5, 0)

    // Act
    let score = mechanic.calculateScore(
        landingPosition: target,
        targetPosition: target
    )

    // Assert
    XCTAssertEqual(score, 1.0, accuracy: 0.01)
}

// ❌ Bad test naming
func testJump() {
    // Vague and unhelpful
}
```

## 📜 Commit Messages

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
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```bash
# Good commits
feat(movement): add wall climb mechanic
fix(audio): resolve spatial audio crackling issue
docs(readme): update installation instructions
perf(rendering): optimize obstacle rendering pipeline

# With body
feat(multiplayer): add ghost racing mode

Implement ghost racing functionality that allows players to
race against recorded runs from other players. Includes:
- Recording movement data during gameplay
- Playback of ghost recordings
- Visual representation of ghost player

Closes #123
```

### Commit Message Rules

1. **Use imperative mood** ("Add feature" not "Added feature")
2. **Keep subject line under 50 characters**
3. **Capitalize subject line**
4. **No period at the end of subject**
5. **Separate subject from body with blank line**
6. **Wrap body at 72 characters**
7. **Use body to explain what and why, not how**

## 🔀 Pull Request Process

### Before Submitting

- [ ] Code builds without errors or warnings
- [ ] All tests pass (`⌘ + U` in Xcode)
- [ ] New code has appropriate test coverage
- [ ] Documentation is updated
- [ ] SwiftLint shows no violations
- [ ] Commits are well-formed and descriptive
- [ ] Branch is rebased on latest `main`

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe the tests you ran and how to reproduce

## Screenshots/Videos
If applicable, add visual evidence

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where needed
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing unit tests pass locally
- [ ] Any dependent changes have been merged

## Related Issues
Closes #(issue number)
```

### Review Process

1. **Automated checks** must pass (tests, linting)
2. **At least one approval** from a maintainer
3. **No unresolved comments**
4. **Up-to-date with main branch**
5. **Squash and merge** (we'll handle this)

### After Approval

- We'll squash your commits and merge
- Delete your feature branch after merge
- Update your fork:
  ```bash
  git checkout main
  git pull upstream main
  git push origin main
  ```

## 🧪 Testing Guidelines

### Writing Tests

**Every PR should include tests for:**
- New features
- Bug fixes
- Edge cases

**Test Structure:**
```swift
class MyFeatureTests: XCTestCase {
    var sut: MyFeature! // System Under Test

    override func setUp() {
        super.setUp()
        sut = MyFeature()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFeature_WhenCondition_ExpectedOutcome() {
        // Arrange
        let input = "test"

        // Act
        let result = sut.process(input)

        // Assert
        XCTAssertEqual(result, "expected")
    }
}
```

### Test Coverage Goals

- **Unit Tests**: 80%+ coverage
- **Integration Tests**: Key user flows
- **Performance Tests**: Critical paths
- **UI Tests**: Main user journeys

## 📚 Documentation

### Code Documentation

```swift
// Document public APIs
/// Generates a parkour course tailored to the available space.
///
/// This method analyzes the provided room model and creates a course
/// that fits within the space while maintaining safety margins.
///
/// - Parameters:
///   - space: The scanned room model
///   - difficulty: Desired difficulty level
/// - Returns: A generated course or nil if space is insufficient
/// - Throws: `CourseGenerationError` if generation fails
public func generateCourse(
    for space: RoomModel,
    difficulty: DifficultyLevel
) async throws -> CourseData? {
    // Implementation
}
```

### Markdown Documentation

- Use proper headings hierarchy
- Include code examples
- Add screenshots/diagrams where helpful
- Keep language clear and concise
- Update table of contents

## 🐛 Debugging Tips

### Common Issues

**Build Failures**
```bash
# Clean build folder
⌘ + Shift + K

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**Test Failures on CI**
- Ensure tests are deterministic
- Don't rely on timing
- Mock external dependencies
- Use proper async/await patterns

## 🎯 Performance Considerations

When contributing, keep in mind:

- **90 FPS target** - Profile your changes
- **Memory limits** - Use Instruments to check
- **Battery life** - Minimize unnecessary work
- **Network usage** - Batch requests when possible

## 🏆 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Featured on our website (if desired)

## ❓ Questions?

- **Documentation**: Check docs first
- **Discussions**: Use GitHub Discussions
- **Issues**: For bugs and features
- **Discord**: Real-time chat with team

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

<p align="center">
  <strong>Thank you for contributing to Parkour Pathways! 🎮</strong>
</p>
