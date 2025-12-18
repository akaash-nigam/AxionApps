# Contributing to Spatial Music Studio

Thank you for your interest in contributing to Spatial Music Studio! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in your interactions.

### Expected Behavior

- ✅ Be respectful and inclusive
- ✅ Provide constructive feedback
- ✅ Accept constructive criticism gracefully
- ✅ Focus on what is best for the community
- ✅ Show empathy towards others

### Unacceptable Behavior

- ❌ Harassment, discrimination, or offensive comments
- ❌ Personal attacks or trolling
- ❌ Publishing others' private information
- ❌ Spam or off-topic discussions
- ❌ Any conduct inappropriate in a professional setting

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Development environment set up** - See [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md)
2. **Read the documentation:**
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
   - [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) - Technical specifications
   - [DESIGN.md](DESIGN.md) - Design guidelines
3. **Familiarize yourself with:**
   - Swift 6.0 language features
   - visionOS development
   - Project structure and conventions

### Finding Issues to Work On

**Good First Issues:**
Look for issues labeled `good-first-issue` - these are great for newcomers!

**Bug Fixes:**
Issues labeled `bug` are always welcome. Include reproduction steps in your PR.

**Feature Requests:**
Issues labeled `enhancement` need discussion before implementation.

**Documentation:**
Issues labeled `documentation` are perfect for non-code contributions.

---

## How to Contribute

### Types of Contributions

#### 1. Bug Reports

**Before submitting:**
- Search existing issues to avoid duplicates
- Test on latest version
- Gather reproduction steps

**Include in your report:**
```markdown
**Description:**
Clear description of the bug

**Steps to Reproduce:**
1. Step one
2. Step two
3. See error

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Environment:**
- macOS version: 14.x
- Xcode version: 16.x
- visionOS version: 2.x
- Device: Simulator / Vision Pro

**Additional Context:**
- Screenshots
- Console logs
- Crash reports
```

#### 2. Feature Requests

**Before requesting:**
- Check if similar feature exists
- Review roadmap in [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
- Consider if it aligns with project goals

**Include in your request:**
```markdown
**Problem Statement:**
What problem does this solve?

**Proposed Solution:**
How would you implement it?

**Alternatives Considered:**
What other approaches did you consider?

**Additional Context:**
- Use cases
- Mockups/diagrams
- Impact on existing features
```

#### 3. Code Contributions

**Suitable contributions:**
- Bug fixes
- Performance improvements
- Test coverage improvements
- Documentation updates
- Approved feature implementations

**Not suitable without prior discussion:**
- Major architectural changes
- Breaking changes to APIs
- New dependencies
- Significant UI/UX changes

#### 4. Documentation

**Always welcome:**
- Fixing typos and grammar
- Improving clarity
- Adding examples
- Updating outdated information
- Translating documentation

---

## Development Workflow

### Step 1: Fork and Clone

```bash
# Fork repository on GitHub first

# Clone your fork
git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_spatial-music-studio.git
cd visionOS_Gaming_spatial-music-studio

# Add upstream remote
git remote add upstream https://github.com/akaash-nigam/visionOS_Gaming_spatial-music-studio.git

# Verify remotes
git remote -v
```

### Step 2: Create a Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/my-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

**Branch naming conventions:**
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `test/` - Test improvements
- `docs/` - Documentation updates
- `perf/` - Performance improvements

### Step 3: Make Changes

**Follow these guidelines:**

1. **Write clean, readable code**
2. **Follow Swift API Design Guidelines**
3. **Add tests for new functionality**
4. **Update documentation as needed**
5. **Keep commits focused and atomic**

### Step 4: Test Your Changes

```bash
# Run all tests
⌘U in Xcode

# Or via command line:
cd SpatialMusicStudio
xcodebuild test -scheme SpatialMusicStudio \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run SwiftLint
swiftlint

# Check for build warnings
⌘B in Xcode
```

### Step 5: Commit Changes

```bash
# Stage files
git add .

# Commit with descriptive message
git commit -m "Add: Implement feature X

- Detailed explanation of changes
- Why this change was made
- Any breaking changes or migration notes"
```

**Commit message format:**
```
Type: Short description (50 chars max)

Longer explanation (wrap at 72 chars). Explain what and why,
not how (the code shows how).

- Additional details as bullet points
- Reference issues: Fixes #123

Types:
- Add: New feature
- Fix: Bug fix
- Update: Improve existing feature
- Remove: Delete code/feature
- Refactor: Code restructuring
- Test: Add/improve tests
- Docs: Documentation updates
- Perf: Performance improvements
```

### Step 6: Keep Branch Updated

```bash
# Fetch latest changes
git fetch upstream

# Rebase on main
git rebase upstream/main

# Resolve any conflicts
# Then continue rebase
git rebase --continue

# Force push to your fork (if needed)
git push origin feature/my-feature-name --force-with-lease
```

---

## Coding Standards

### Swift Style Guide

**Follow Apple's Swift API Design Guidelines:**
- https://swift.org/documentation/api-design-guidelines/

**Key points:**

#### Naming

```swift
// ✅ Good: Clear, descriptive names
func calculateTotalDuration(for tracks: [Track]) -> TimeInterval

// ❌ Bad: Abbreviated or unclear
func calcDur(t: [Track]) -> TimeInterval

// ✅ Good: Boolean properties read naturally
var isPlaying: Bool
var hasUnsavedChanges: Bool

// ❌ Bad: Unclear boolean names
var playing: Bool
var unsaved: Bool
```

#### Code Organization

```swift
// ✅ Good: Organized with MARK comments
class SpatialAudioEngine {
    // MARK: - Properties

    private let audioEngine: AVAudioEngine
    private var sources: [UUID: AudioSource]

    // MARK: - Initialization

    init() {
        // ...
    }

    // MARK: - Public Methods

    func addInstrument(_ instrument: Instrument) {
        // ...
    }

    // MARK: - Private Methods

    private func setupAudioSession() {
        // ...
    }
}
```

#### Documentation

```swift
/// Adds a new instrument to the spatial audio scene.
///
/// The instrument is positioned at the specified 3D coordinates and
/// assigned a unique identifier for future reference.
///
/// - Parameters:
///   - instrument: The instrument to add to the scene
///   - position: 3D position in meters from the listener
/// - Returns: Unique identifier for the added instrument
/// - Throws: `AudioEngineError.maxSourcesReached` if limit exceeded
func addInstrument(
    _ instrument: Instrument,
    at position: SIMD3<Float>
) throws -> UUID {
    // Implementation
}
```

#### Error Handling

```swift
// ✅ Good: Specific error types
enum AudioEngineError: LocalizedError {
    case initializationFailed
    case maxSourcesReached
    case invalidSampleRate

    var errorDescription: String? {
        switch self {
        case .initializationFailed:
            return "Failed to initialize audio engine"
        case .maxSourcesReached:
            return "Maximum number of audio sources reached"
        case .invalidSampleRate:
            return "Sample rate must be between 44100 and 192000 Hz"
        }
    }
}

// ✅ Good: Proper error propagation
func loadComposition(_ url: URL) async throws -> Composition {
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Composition.self, from: data)
    } catch DecodingError.dataCorrupted {
        throw CompositionError.corruptedFile(url)
    } catch {
        throw CompositionError.loadFailed(url, underlying: error)
    }
}
```

#### Concurrency

```swift
// ✅ Good: Use modern Swift concurrency
@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentScene: AppScene

    func loadComposition() async throws {
        let composition = try await dataManager.load()
        self.currentComposition = composition
    }
}

// ✅ Good: Mark Sendable types
struct Composition: Codable, Sendable {
    let id: UUID
    var tracks: [Track]
}

// ✅ Good: Use actors for thread-safe state
actor AudioBufferPool {
    private var availableBuffers: [AudioBuffer] = []

    func checkout() -> AudioBuffer? {
        availableBuffers.popLast()
    }
}
```

### SwiftLint Configuration

The project uses SwiftLint for code style enforcement.

**Run before committing:**
```bash
swiftlint
```

**Key rules:**
- Line length: 120 characters
- Function length: 40 lines max
- Type body length: 200 lines max
- Cyclomatic complexity: 10 max
- Force unwrapping: Disabled (use guards)

---

## Testing Requirements

### Test Coverage

**Minimum requirements:**
- New features: 80% coverage
- Bug fixes: Include regression test
- Refactoring: Maintain existing coverage
- Public APIs: 100% coverage

### Writing Tests

#### Unit Tests

```swift
import XCTest
@testable import SpatialMusicStudio

class MusicTheoryTests: XCTestCase {
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

    func testNoteTransposition() {
        // Arrange
        let note = NoteName.c

        // Act
        let transposed = note.transpose(by: 7)

        // Assert
        XCTAssertEqual(transposed, NoteName.g)
    }

    func testInvalidTransposition() {
        // Arrange
        let note = NoteName.c

        // Act & Assert
        XCTAssertThrowsError(try note.transpose(by: 13)) { error in
            XCTAssertTrue(error is MusicTheoryError)
        }
    }
}
```

#### Performance Tests

```swift
func testAudioLatencyPerformance() {
    measure {
        // Code to benchmark
        let latency = audioEngine.measureLatency()
        XCTAssertLessThan(latency, 0.010) // < 10ms
    }
}
```

#### UI Tests

```swift
func testMainMenuNavigation() {
    let app = XCUIApplication()
    app.launch()

    // Test navigation
    let newCompositionButton = app.buttons["New Composition"]
    XCTAssertTrue(newCompositionButton.exists)

    newCompositionButton.tap()

    // Verify navigation occurred
    let compositionView = app.otherElements["Composition View"]
    XCTAssertTrue(compositionView.waitForExistence(timeout: 2))
}
```

### Running Tests

```bash
# All tests
⌘U in Xcode

# Specific test class
xcodebuild test -scheme SpatialMusicStudio \
  -only-testing:SpatialMusicStudioTests/DomainModelTests

# Specific test method
xcodebuild test -scheme SpatialMusicStudio \
  -only-testing:SpatialMusicStudioTests/MusicTheoryTests/testNoteTransposition

# Generate coverage report
⌘U with code coverage enabled
```

---

## Submitting Changes

### Pre-submission Checklist

Before opening a pull request:

- [ ] All tests pass (⌘U)
- [ ] No SwiftLint warnings
- [ ] Code is documented
- [ ] CHANGELOG.md updated (if applicable)
- [ ] No merge conflicts with main
- [ ] Commit messages follow format
- [ ] Screenshots included (for UI changes)
- [ ] Performance benchmarks (for performance changes)

### Creating a Pull Request

1. **Push to your fork:**
   ```bash
   git push origin feature/my-feature-name
   ```

2. **Open PR on GitHub:**
   - Navigate to original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill out PR template

3. **PR title format:**
   ```
   Type: Short description (#issue-number)

   Examples:
   Add: Implement spatial audio reverb (#123)
   Fix: Resolve audio glitch on track switch (#456)
   Update: Improve composition save performance (#789)
   ```

4. **PR description template:**
   ```markdown
   ## Description
   Brief description of changes

   ## Related Issue
   Fixes #123

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Performance improvement
   - [ ] Refactoring
   - [ ] Documentation update

   ## Testing
   - [ ] All existing tests pass
   - [ ] New tests added
   - [ ] Manual testing completed

   ## Screenshots (if applicable)
   Add screenshots for UI changes

   ## Performance Impact
   Describe any performance implications

   ## Breaking Changes
   List any breaking changes

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] Tests added/updated
   - [ ] No console warnings
   ```

---

## Review Process

### What to Expect

1. **Automated checks** run first:
   - Build verification
   - Test suite
   - SwiftLint
   - Documentation checks

2. **Code review** by maintainers:
   - Usually within 2-3 business days
   - May request changes
   - Discussion in PR comments

3. **Approval and merge:**
   - Once approved, maintainer will merge
   - PR will be closed automatically
   - Changes appear in next release

### Responding to Feedback

**Do:**
- ✅ Respond promptly and professionally
- ✅ Ask for clarification if needed
- ✅ Make requested changes
- ✅ Learn from feedback

**Don't:**
- ❌ Take criticism personally
- ❌ Argue without technical justification
- ❌ Ignore review comments
- ❌ Make unrelated changes

### After Your PR is Merged

**Celebrate!** 🎉 You've contributed to Spatial Music Studio!

**What happens next:**
- Your changes will be in the next release
- You'll be added to contributors list
- Issue will be closed automatically

---

## Additional Guidelines

### Performance Considerations

**Always consider:**
- Audio latency impact (target: <10ms)
- Frame rate impact (target: 90 FPS)
- Memory usage (target: <512MB)
- Battery life (on device)

**Profile your changes:**
```bash
# Use Instruments
⌘I in Xcode → Time Profiler
```

### Accessibility

**Ensure your changes:**
- Support VoiceOver
- Have proper contrast ratios
- Support Dynamic Type
- Work with accessibility gestures

### Localization

**Prepare for future localization:**
```swift
// ✅ Good: Use localized strings
Text("composition.title")

// ❌ Bad: Hardcoded strings
Text("Composition Title")
```

### Security

**Never commit:**
- API keys
- Passwords
- Certificates
- Personal information

**Use:**
- Environment variables
- Keychain for sensitive data
- Secure configuration files (not in repo)

---

## Getting Help

### Resources

- **Documentation:** Start with [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md)
- **Architecture:** Read [ARCHITECTURE.md](ARCHITECTURE.md)
- **Issues:** Search [GitHub Issues](https://github.com/akaash-nigam/visionOS_Gaming_spatial-music-studio/issues)

### Communication Channels

- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** General questions and discussions
- **Pull Request Comments:** Code-specific questions

### Questions?

If you have questions:
1. Check existing documentation
2. Search closed issues/PRs
3. Ask in GitHub Discussions
4. Tag maintainers if urgent

---

## Recognition

### Contributors

All contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Credited in About section (when applicable)

### Significant Contributions

Major contributions may result in:
- Core contributor status
- Write access to repository
- Participation in project planning

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE)).

---

**Thank you for contributing to Spatial Music Studio!** 🎵

*Your contributions help make spatial music creation accessible to everyone.*

*Last Updated: 2025-01-19*
