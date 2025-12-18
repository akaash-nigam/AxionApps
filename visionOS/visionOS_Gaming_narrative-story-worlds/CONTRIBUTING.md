# Contributing to Narrative Story Worlds

Thank you for your interest in contributing to Narrative Story Worlds! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [How to Contribute](#how-to-contribute)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Commit Messages](#commit-messages)
8. [Pull Request Process](#pull-request-process)
9. [Documentation](#documentation)
10. [Community](#community)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

---

## Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.2+** with visionOS SDK
- **Swift 6.0+**
- **Apple Vision Pro** (for hardware testing)
- **Git** for version control

### First-Time Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_narrative-story-worlds.git
   cd visionOS_Gaming_narrative-story-worlds
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/akaash-nigam/visionOS_Gaming_narrative-story-worlds.git
   ```

3. **Open in Xcode**
   ```bash
   open NarrativeStoryWorlds.xcodeproj
   ```

4. **Run tests to verify setup**
   ```bash
   xcodebuild test \
     -scheme NarrativeStoryWorlds \
     -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
   ```

---

## Development Setup

### Branch Strategy

We use a modified Git Flow:

- **`main`**: Production-ready code
- **`develop`**: Integration branch for features
- **`feature/`**: Feature branches
- **`bugfix/`**: Bug fix branches
- **`hotfix/`**: Urgent production fixes
- **`claude/`**: AI-assisted development branches

### Creating a Feature Branch

```bash
# Update develop branch
git checkout develop
git pull upstream develop

# Create feature branch
git checkout -b feature/your-feature-name

# Work on your feature...

# Push to your fork
git push origin feature/your-feature-name
```

---

## How to Contribute

### Types of Contributions

We welcome:

- **Bug reports** via GitHub Issues
- **Feature requests** via GitHub Discussions
- **Code contributions** via Pull Requests
- **Documentation improvements**
- **Test coverage improvements**
- **Performance optimizations**
- **Accessibility enhancements**

### Reporting Bugs

**Before submitting a bug**:
- Search existing issues to avoid duplicates
- Verify the bug exists in the latest version
- Collect reproduction steps and environment details

**Use the bug report template** when creating an issue:

```markdown
**Description**: Clear description of the bug

**Steps to Reproduce**:
1. Step one
2. Step two
3. ...

**Expected Behavior**: What should happen

**Actual Behavior**: What actually happens

**Environment**:
- visionOS version: 2.0
- Device: Apple Vision Pro / Simulator
- App version: 1.0.0

**Screenshots/Videos**: If applicable

**Additional Context**: Any other relevant information
```

### Suggesting Features

**Use GitHub Discussions** for feature discussions:

1. Check existing discussions for similar ideas
2. Provide a clear use case and rationale
3. Consider implementation complexity
4. Be open to feedback and iteration

**For approved features**, create an issue with the enhancement template.

---

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and [Google's Swift Style Guide](https://google.github.io/swift/) with modifications:

#### Naming Conventions

```swift
// Types: UpperCamelCase
class StoryDirectorAI { }
struct EmotionalState { }
enum Emotion { }

// Variables and functions: lowerCamelCase
var playerEngagement: Float
func adjustPacing(playerEngagement: Float)

// Constants: lowerCamelCase
let maxTrustValue: Float = 1.0

// Acronyms: Uppercase only at start
class URLSession { }  // Good
var htmlParser: Parser  // Good
var parseHTML()  // Good
```

#### Code Organization

```swift
// MARK: - Section Headers
class CharacterAI {

    // MARK: - Properties

    private let character: Character
    private var memoryCache: [CharacterMemory] = []

    // MARK: - Initialization

    init(character: Character) {
        self.character = character
    }

    // MARK: - Public Methods

    func updateEmotionalState(event: StoryEvent) {
        // Implementation
    }

    // MARK: - Private Methods

    private func calculateTrustDelta(choice: Choice) -> Float {
        // Implementation
    }
}
```

#### Concurrency

Use Swift 6.0 strict concurrency:

```swift
// Use @MainActor for UI-related code
@MainActor
class StoryViewModel: ObservableObject {
    @Published var currentDialogue: String = ""
}

// Use async/await for asynchronous operations
func generateDialogue() async throws -> String {
    // Async work
}

// Avoid completion handlers, prefer async
// Bad:
func loadStory(completion: @escaping (Story?) -> Void)

// Good:
func loadStory() async throws -> Story
```

#### Error Handling

```swift
// Define specific error types
enum StoryError: Error {
    case invalidNode(UUID)
    case missingCharacter(UUID)
    case corruptedSaveData
}

// Use do-catch for throwing functions
do {
    let dialogue = try await generateDialogue(context: context)
    displayDialogue(dialogue)
} catch StoryError.invalidNode(let id) {
    logger.error("Invalid node: \(id)")
} catch {
    logger.error("Unexpected error: \(error)")
}
```

### SwiftLint

Run SwiftLint before committing:

```bash
swiftlint
```

Auto-fix minor issues:

```bash
swiftlint --fix
```

**Zero warnings policy**: All SwiftLint warnings must be resolved before merging.

---

## Testing Guidelines

### Test Coverage Requirements

- **New features**: Must include tests
- **Bug fixes**: Must include regression test
- **Minimum coverage**: 70% overall, 80% for critical systems

### Writing Tests

Follow the **Arrange-Act-Assert** pattern:

```swift
func testEmotionalState_PositiveChoice_IncreaseTrust() {
    // Arrange
    let character = createTestCharacter()
    let initialTrust = character.emotionalState.trust
    let positiveChoice = Choice(/* ... */)

    // Act
    characterAI.processChoice(positiveChoice)

    // Assert
    XCTAssertGreaterThan(
        character.emotionalState.trust,
        initialTrust,
        "Trust should increase after positive choice"
    )
}
```

### Test Naming

Use descriptive names that explain what is being tested:

```swift
// Good
func testStoryDirector_LowEngagement_IncreaseTension()
func testCharacterMemory_HighEmotionalWeight_BecomesLongTerm()

// Bad
func testStory()
func testMemory1()
```

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme NarrativeStoryWorlds

# Run specific test class
xcodebuild test -scheme NarrativeStoryWorlds -only-testing:NarrativeStoryWorldsTests/AISystemTests

# Run with coverage
xcodebuild test -scheme NarrativeStoryWorlds -enableCodeCoverage YES
```

See [NarrativeStoryWorlds/Tests/README.md](NarrativeStoryWorlds/Tests/README.md) for detailed testing documentation.

---

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

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
- **chore**: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat(ai): add emotion recognition confidence scoring"

# Bug fix
git commit -m "fix(story): correct dialogue node progression logic"

# Breaking change
git commit -m "feat(api)!: change Character initializer signature

BREAKING CHANGE: Character now requires SpatialProperties parameter"

# Multiple paragraphs
git commit -m "refactor(audio): improve spatial audio performance

Optimized audio positioning calculations by caching frequently
accessed values and reducing redundant transformations.

Performance improved by 15% in multi-character scenes."
```

### Commit Best Practices

- **Atomic commits**: One logical change per commit
- **Present tense**: "Add feature" not "Added feature"
- **Imperative mood**: "Fix bug" not "Fixes bug"
- **Reference issues**: Include issue number when applicable
  ```bash
  git commit -m "fix(gesture): improve pinch detection accuracy

  Closes #42"
  ```

---

## Pull Request Process

### Before Submitting

✅ **Checklist**:

- [ ] Code compiles without errors
- [ ] All tests pass locally
- [ ] SwiftLint shows zero warnings
- [ ] Code coverage maintained or improved
- [ ] Documentation updated (if applicable)
- [ ] Commit messages follow conventions
- [ ] Branch is up to date with `develop`

### Creating a Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR on GitHub**
   - Base: `develop` (or `main` for hotfixes)
   - Compare: `your-feature-branch`
   - Fill out the PR template completely

3. **PR Title Format**
   ```
   feat(scope): brief description
   ```

4. **PR Description Template**
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
   - [ ] Integration tests added/updated
   - [ ] Manual testing completed

   ## Checklist
   - [ ] Code compiles
   - [ ] Tests pass
   - [ ] SwiftLint clean
   - [ ] Documentation updated
   - [ ] Branch up to date

   ## Screenshots (if applicable)
   [Add screenshots]

   Closes #[issue number]
   ```

### Review Process

1. **Automated Checks**: CI runs tests and linters
2. **Code Review**: At least one approval required
3. **Address Feedback**: Make requested changes
4. **Final Approval**: Maintainer approval
5. **Merge**: Squash and merge to develop

### After Merge

- Delete your feature branch
- Update your local develop branch
- Close related issues (if not auto-closed)

---

## Documentation

### Code Documentation

Use Swift documentation comments:

```swift
/// Adjusts story pacing based on player engagement and emotional intensity.
///
/// This method analyzes the current gameplay session and suggests pacing
/// adjustments to maintain optimal player engagement.
///
/// - Parameters:
///   - playerEngagement: Current engagement level (0.0-1.0)
///   - sessionDuration: Duration of current session in seconds
///   - emotionalIntensity: Current emotional intensity (0.0-1.0)
/// - Returns: A `PacingAdjustment` with suggested changes
/// - Note: Should be called once per story beat completion
func adjustPacing(
    playerEngagement: Float,
    sessionDuration: TimeInterval,
    emotionalIntensity: Float
) -> PacingAdjustment {
    // Implementation
}
```

### Markdown Documentation

- Use clear headings and structure
- Include code examples where helpful
- Keep language concise and accessible
- Update table of contents for long documents

---

## Community

### Getting Help

- **Questions**: GitHub Discussions
- **Bugs**: GitHub Issues
- **Chat**: [Discord/Slack link]

### Communication Guidelines

- Be respectful and inclusive
- Provide context and details
- Search before asking
- Give credit where due
- Help others when you can

---

## License

By contributing, you agree that your contributions will be licensed under the project's license.

---

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project README

Thank you for contributing to Narrative Story Worlds! 🎭✨
